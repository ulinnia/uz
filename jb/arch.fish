#!/usr/bin/env fish

function echo_color
    set --global r '\033[1;31m'  # 红
    set --global g '\033[1;32m'  # 绿
    set --global y '\033[1;33m'  # 黄
    set --global b '\033[1;36m'  # 蓝
    set --global w '\033[1;37m'  # 白
    set --global h '\033[0m'     # 后缀
end

function read_format_only

    # 只读取特定格式，且进行再确认。
    #
    #   参数：
    #       1. 要宣告的变量名
    #       2. 提示语
    #       3. 匹配的格式

    while true
        read -p 'echo -e "$argv[2]"' ans
        if echo -- "$ans" | grep -q $argv[3]
            read -p 'echo -e "$ans, are you sure? "' sure
            if test "$sure" = 'y' -o "$sure" = ''
                break
            end
        else
            echo -e $r'wrong format.'$h
        end
    end

    set --global $argv[1] "$ans"
end

function enter_user_var
    read_format_only user_name $r'enter'$h' your username: '    '^[a-z][-a-z0-9]*$'
    read_format_only host_name $r'enter'$h' your hostname: '    '^[a-zA-Z][-a-zA-Z0-9]*$'
    read_format_only root_pass $r'enter'$h' your root passwd: ' '^[-_,.a-zA-Z0-9]*$'
    read_format_only user_pass $r'enter'$h' your user passwd: ' '^[-_,.a-zA-Z0-9]*$'
end

function system_check
    if test $USER != 'root'
        error not_root
    end

    if test -d /sys/firmware/efi
        set --global bios_type 'uefi'
    else
        set --global bios_type 'bios'
    end

    if test $action != 'live_install'
        if test (systemd-detect-virt) = 'none'
            set --global use_graphical_interface true
        else
            set --global use_graphical_interface false
        end

        set --global root_part  (df | awk '$6=="/" {print $1}')
        set --global host_name  (cat /etc/hostname)
        set --global user_name  (ls /home | head -n 1)
        set --global uz_dir     "/home/$user_name/a/uz"
        set --global user_mkdir 'a/pixra/bimple' gz xz '.config/fish/conf.d' '.config/nvim/.backup'
    end
end

function network_connected

    # 如果能连上网络，则返回 0

    if ping -c 1 -w 1 1.1.1.1 &>/dev/null
        timedatectl set-ntp true
        echo -e $g'network connection is successful.'$h
        return 0
    else
        echo -e $r'Network connection failed.'$h
        return 1
    end
end

function select

    #   参数：
    #       1. 储存选择结果的变数名
    #       2+. 输入可供选择的选项
    #
    #   输出：
    #       使用者选择的选项

    set list $argv[2..-1]

    for i in (seq (count $list))
        echo $i. $list[$i]
    end

    while true
        read -p 'echo "> "' ans
        if echo -- $ans | grep -q '^[1-9][0-9]*$'; and test $ans -le (count $list)
            read -p 'echo -e "$list[$ans], are you sure? "' sure
            if test "$sure" = 'y' -o "$sure" = ''
                break
            end
        else
            echo -e $r'wrong format.'$h
        end
    end

    set --global $argv[1] $list[$ans]
end

function connect_network
    set iw_dev (iw dev | awk '$1=="Interface"{print $2}')

    while ! network_connected
        iwctl station $iw_dev scan
        iwctl station $iw_dev get-networks
        read -p 'echo -e $r"ssid you want to connect to: "$h' ssid
        iwctl station $iw_dev connect $ssid[1]
    end
end

function open_ssh
    set interface   (ip -o -4 route show to default | awk '{print $5}')
    set ip          (ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

    read_format_only root_pass $r'enter'$h' your root passwd: ' '^[-_,.a-zA-Z0-9]*$'
    echo "$USER:$root_pass" | chpasswd
    systemctl start sshd

    echo -e $g'# ssh '$USER'@'$ip$h
    echo -e $g"passwd = $root_pass"$h
end

function disk_partition
    echo -e $r'automatic partition or manual partition: '$h
    select ans 'automatic' 'manual'

    if test $ans = 'automatic'
        select_partition part

        parted /dev/$part mklabel gpt
        if test $bios_type = 'uefi'
            parted /dev/$part mkpart esp 1m 513m
            parted /dev/$part set 1 boot on
            parted /dev/$part mkpart arch 513m 100%
        else
            parted /dev/$part mkpart grub 1m 3m
            parted /dev/$part set 1 bios_grub on
            parted /dev/$part mkpart arch 3m 100%
        end

        if echo $part | grep -q 'nvme'
            set --global boot_part /dev/$part'p1'
            set --global root_part /dev/$part'p2'
        else
            set --global boot_part /dev/$part'1'
            set --global root_part /dev/$part'2'
        end

        if test $bios_type = 'uefi'
            mkfs.fat -F32 $boot_part
        end
    else
        select_partition boot_part
        select_partition root_part
        set boot_part /dev/$boot_part
        set root_part /dev/$root_part
    end

    mount_subvol
end

function select_partition

    #   参数：
    #       1. 要宣告的变量名

    set list_part (lsblk -l | awk '{ print $1 }' | grep '^\(nvme\|sd.\|vd.\)')
    lsblk

    echo -e $r'select a partition as the '$h$argv[1]$r' partition: '$h
    select $argv[1] $list_part
end

function mount_subvol
    umount -fR /mnt &>/dev/null

    mkfs.btrfs -fL arch $root_part
    mount $root_part /mnt

    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/home
    btrfs subvolume create /mnt/srv
    btrfs subvolume create /mnt/swap
    btrfs subvolume create /mnt/tmp
    btrfs subvolume create /mnt/var
    btrfs subvolume create /mnt/snap
    btrfs subvolume create /mnt/snap/root
    btrfs subvolume create /mnt/snap/srv
    btrfs subvolume create /mnt/snap/home
    btrfs subvolume create /mnt/cache
    btrfs subvolume create /mnt/cache/$user_name

    umount -R /mnt

    mount -o autodefrag,compress=zstd,subvol=@ $root_part /mnt

    mkdir /mnt/btrfs
    mkdir /mnt/home
    mkdir /mnt/srv
    mkdir /mnt/swap
    mkdir /mnt/tmp
    mkdir /mnt/var
    mkdir /mnt/.snapshots

    mount $root_part /mnt/btrfs
    mount -o subvol=home $root_part /mnt/home
    mount -o subvol=srv $root_part /mnt/srv
    mount -o subvol=swap $root_part /mnt/swap
    mount -o subvol=tmp $root_part /mnt/tmp
    mount -o subvol=var $root_part /mnt/var
    mount -o subvol=snap/root $root_part /mnt/.snapshots

    mkdir /mnt/srv/.snapshots
    mkdir /mnt/home/.snapshots
    mkdir -p /mnt/home/$user_name/.cache

    mount -o subvol=snap/srv $root_part /mnt/srv/.snapshots
    mount -o subvol=snap/home $root_part /mnt/home/.snapshots
    mount -o subvol=cache/$user_name $root_part /mnt/home/$user_name/.cache

    # 避免 /var/lib 资料遗失，将 /usr/var/lib 挂载到 /var/lib
    mkdir -p        /mnt/usr/var/lib /mnt/var/lib
    mount --bind    /mnt/usr/var/lib /mnt/var/lib

    if test $bios_type = 'uefi'
        mkdir /mnt/efi
        mount $boot_part /mnt/efi
    end
end

function install_basic_pkg
    set basic_pkg base base-devel linux linux-firmware btrfs-progs fish dhcpcd reflector vim

    pacman -Sy --noconfirm archlinux-keyring

    echo 'wait for sorting mirror...'
    pacman -S --needed --noconfirm reflector &>/dev/null
    reflector --latest 9 --protocol https --save /etc/pacman.d/mirrorlist --sort rate

    pacstrap /mnt $basic_pkg
end

function change_root_dir
    echo $host_name > /mnt/etc/hostname
    cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d

    # 绑定挂载无法被 genfstab 正确识别，所以先卸载 /mnt/var/lib
    umount /mnt/var/lib

    genfstab -L /mnt >> /mnt/etc/fstab
    mount --bind /mnt/usr/var/lib /mnt/var/lib

    # 手动写入绑定挂载 /mnt/var/lib
    echo '/usr/var/lib /var/lib none defaults,bind 0 0' >> /mnt/etc/fstab

    rsync (status -f) /mnt/arch.fish
    chmod +x /mnt/arch.fish

    arch-chroot /mnt /arch.fish --install "$root_pass" "$user_pass"

    rm /mnt/arch.fish
    umount -R /mnt
    echo -e $r'please reboot.'$h
end

function set_pacman
    sed -i '/^#Color$/s/#//' /etc/pacman.conf

    pacman-key --init
    pacman-key --populate archlinux

    # 添加 archlinuxcn 源
    curl -fsLo /etc/pacman.d/archlinuxcn-mirrorlist https://raw.githubusercontent.com/archlinuxcn/mirrorlist-repo/master/archlinuxcn-mirrorlist
    sed -i '/Server =/s/^#//' /etc/pacman.d/archlinuxcn-mirrorlist
    echo -e '[archlinuxcn]\nInclude = /etc/pacman.d/archlinuxcn-mirrorlist' >> /etc/pacman.conf

    pacman-key --populate archlinuxcn
    pacman -Syy --noconfirm archlinuxcn-keyring
end

function pacman_install

    # 一次性安装太多软件包容易安装失败，
    # 所以就连试三次，增加安装成功的几率。
    #
    #   参数：
    #       1+. 要安装的软件包列表

    for i in (seq 3)
        if pacman -S --needed --noconfirm $argv
            break
        end
    end
end

function set_localization
    ln -sf /usr/share/zoneinfo/'Asia/Shanghai' /etc/localtime
    hwclock --systohc

    sed -i '/\(en_US\|zh_CN\).UTF-8/s/#//' /etc/locale.gen
    locale-gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf

    set host_name (cat /etc/hostname)
    echo -e '127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t'$host_name'.localdomain '$host_name >> /etc/hosts

    echo "root:$root_pass" | chpasswd

    useradd -g wheel $user_name
    echo "$user_name:$user_pass" | chpasswd
    sed -i '/# %wheel ALL=(ALL) NOPASSWD: ALL/s/# //' /etc/sudoers
    chown -R $user_name:wheel /home/$user_name

    set_boot_loader
end

function set_boot_loader
    set boot_pkg grub

    if test $bios_type = 'uefi'
        set --append boot_pkg efibootmgr
    end

    if $use_graphical_interface
        set --append boot_pkg os-prober
    end

    pacman_install $boot_pkg

    switch $bios_type
        case uefi
            grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=grub
        case bios
            if echo $root_part | grep -q 'nvme'
                set grub_part (echo $root_part | sed 's/p[0-9]$//')
            else
                set grub_part (echo $root_part | sed 's/[0-9]$//')
            end
            grub-install --target=i386-pc $grub_part
    end

    if $use_graphical_interface
        echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
    end

    sed -i '/GRUB_TIMEOUT=/s/5/1/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
end

function install_pkg
    set network_pkg     curl git openssh wget wireguard-tools
    set terminal_pkg    neovim python-pynvim starship
    set file_pkg        lf p7zip snapper
    set sync_pkg        chrony rsync
    set search_pkg      ctags fzf mlocate tree highlight
    set new_search_pkg  fd ripgrep bat tldr exa
    set system_pkg      fcron htop man pacman-contrib pkgstats
    set maintain_pkg    arch-install-scripts dosfstools parted
    set security_pkg    dnscrypt-proxy nftables
    set depend_pkg      lua perl-file-mimeinfo qrencode zsh
    set aur_pkg         yay

    pacman -Syu --noconfirm

    pacman_install $network_pkg     $terminal_pkg
    pacman_install $file_pkg        $sync_pkg
    pacman_install $search_pkg      $new_search_pkg
    pacman_install $system_pkg      $maintain_pkg
    pacman_install $security_pkg    $depend_pkg $aur_pkg

    # iptables-nft 不能直接装，需要进行确认
    echo -e 'y\n\n' | pacman -S --needed iptables-nft

    if $use_graphical_interface
        install_graphic_pkg
    end
end

function install_graphic_pkg
    set lscpu (lscpu)
    if echo $lscpu | grep -q 'AuthenticAMD'
        set ucode_pkg amd-ucode
    else if echo $lscpu | grep -q 'GenuineIntel'
        set ucode_pkg intel-ucode
    end

    set lspci_VGA (lspci | grep '3D\|VGA')
    if echo $lspci_VGA | grep -q 'AMD'
        set gpu_pkg xf86-video-amdgpu
    else if echo $lspci_VGA | grep -q 'Intel'
        set gpu_pkg xf86-video-intel
    else if echo $lspci_VGA | grep -q 'NVIDIA'
        set gpu_pkg xf86-video-nouveau
    end

    set audio_pkg       alsa-utils pulseaudio pulseaudio-alsa pulseaudio-bluetooth
    set bluetooth_pkg   bluez bluez-utils blueman
    set touch_pkg       libinput

    set driver_pkg      $ucode_pkg $gpu_pkg $audio_pkg $bluetooth_pkg $touch_pkg
    set manager_pkg     networkmanager tlp
    set display_pkg     wayland sway swaybg swayidle swaylock xorg-xwayland
    set desktop_pkg     alacritty i3status-rust grim slurp wofi lm_sensors qt5-wayland
    set browser_pkg     firefox firefox-i18n-zh-cn
    set media_pkg       imv vlc
    set input_pkg       fcitx5-im fcitx5-rime
    set control_pkg     brightnessctl playerctl lm_sensors upower
    set virtual_pkg     qemu libvirt virt-manager dnsmasq bridge-utils openbsd-netcat edk2-ovmf
    set office_pkg      calibre libreoffice-fresh-zh-cn
    set font_pkg        noto-fonts-cjk noto-fonts-emoji ttf-font-awesome ttf-ubuntu-font-family
    set program_pkg     bash-language-server clang nodejs rust yarn

    pacman_install $driver_pkg  $manager_pkg
    pacman_install $display_pkg $desktop_pkg
    pacman_install $browser_pkg $media_pkg
    pacman_install $input_pkg   $control_pkg
    pacman_install $virtual_pkg $office_pkg
    pacman_install $font_pkg    $program_pkg
end

function do_as_user

    # 避免创建出的目录或文件，用户无权操作。

    cd /home/$user_name
    sudo -u $user_name $argv
    cd
end

function set_uz_repo

    # uz 是存放我所有设定的仓库

    do_as_user git clone https://github.com/rraayy246/uz $uz_dir --depth 1
    ln -sf $uz_dir /home/$user_name

    cd $uz_dir
    git config credential.helper store
    do_as_user git config --global user.email 'rraayy246@gmail.com'
    do_as_user git config --global user.name 'ray'
    do_as_user git config --global pull.rebase false
    cd
end

function sync_uz_dir

    # 如果目标目录非用户的目录，则不复制所有者信息，
    # 以免其他程序无权限操作。
    #
    #   参数：
    #       1. 源目录
    #       2. 目标目录

    if echo $argv[2] | grep -q '^/home'
        rsync -a --inplace --no-whole-file $uz_dir/$argv
    else
        rsync -rlptD --inplace --no-whole-file $uz_dir/$argv
    end
end

function config_copy
    do_as_user mkdir -p /home/$user_name/$user_mkdir

    fish $uz_dir/pv/hjbl.fish
    do_as_user fish $uz_dir/pv/hjbl.fish

    sync_uz_dir pv/etc /
    sync_uz_dir pv/.config /root
    sync_uz_dir pv/.config /home/$user_name
end

function config_write
    sed -i '/home\|root/s/bash/fish/' /etc/passwd

    do_as_user wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O /home/$user_name/.config/fish/conf.d/z.lua
    do_as_user echo 'source (lua $HOME/.config/fish/conf.d/z.lua --init fish | psub)' > /home/$user_name/.config/fish/conf.d/z.fish

    echo -e 'if status is-interactive\n\tstarship init fish | source\nend' > /root/.config/fish/config.fish
    sed -i '/^call plug#begin/,$ s/^/"/' /root/.config/nvim/init.vim

    echo -e 'nameserver ::1\nnameserver 127.0.0.1\noptions edns0 single-request-reopen' > /etc/resolv.conf
    chattr +i /etc/resolv.conf

    if $use_graphical_interface
        sync_uz_dir img/hw.png /home/$user_name/a/pixra/bimple/hw.png

        do_as_user curl -fLo /home/$user_name/.local/share/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

        set_virtualizer
        set_flypy
    else
        echo -e 'if status is-interactive\n\tstarship init fish | source\nend' > /home/$user_name/.config/fish/config.fish
        sed -i '/^call plug#begin/,$ s/^/"/' /home/$user_name/.config/nvim/init.vim

        fcrontab $uz_dir/pv/cron
    end
end

function set_virtualizer
    echo '/* 允许 kvm 组中的用户管理 libvirt 的守护进程  */
polkit.addRule(function(action, subject) {
  if (action.id == "org.libvirt.unix.manage" &&
    subject.isInGroup("kvm")) {
      return polkit.Result.YES;
  }
});' | tee /etc/polkit-1/rules.d/50-libvirt.rules

    usermod -a -G kvm $user_name
end

function set_flypy

    # 设定小鹤音形
    #
    #   原网址：http://flypy.ys168.com/
    #   原名称：小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip

    do_as_user 7z x /home/$user_name/a/uz/pv/flypy.7z -o/home/$user_name
    do_as_user mkdir -p /home/$user_name/.local/share/fcitx5
    do_as_user rsync -a --delete --inplace --no-whole-file /home/$user_name/rime /home/$user_name/.local/share/fcitx5
    rm -rf /home/$user_name/rime
end

function set_auto_start
    set mask_auto_start  systemd-resolved
    set enable_auto_start chronyd dnscrypt-proxy fcron nftables paccache.timer pkgstats.timer reflector.timer sshd

    if $use_graphical_interface
        set --append disable_auto_start dhcpcd
        set --append enable_auto_start  bluetooth libvirtd NetworkManager tlp
        # dhcpcd 和 NetworkManager 不能同时启动
    else
        set --append enable_auto_start  dhcpcd
    end

    systemctl disable $disable_auto_start
    systemctl enable --now $enable_auto_start
    systemctl mask $mask_auto_start
end

function after_set

    #   这些设定似乎要在系统安装完后才能设定，
    #   如果在安装期间设定，则会失败。

    if ! snapper list-configs | grep -q 'root'
        set_snapper
    end

    if test -d /swap -a ! -e /swap/swapfile
        set_swap
    end

    if $use_graphical_interface
        do_as_user nvim +PlugInstall +qall
    end
end

function set_snapper

    # 因为 snapper 在创建配置时，不允许目录被其他子卷占用，
    # 所以先把目录卸载，创建 snapper 配置文件，再把子卷挂载回去。

    set snap_dir / /srv/ /home/

    umount $snap_dir'.snapshots'
    rmdir $snap_dir'.snapshots'

    snapper -c root create-config /
    snapper -c srv create-config /srv
    snapper -c home create-config /home

    btrfs subvolume delete $snap_dir'.snapshots'
    mkdir $snap_dir'.snapshots'

    mount -a

    # 防止快照被索引
    sed -i '/PRUNENAMES/s/.git/& .snapshot/' /etc/updatedb.conf
end

function set_swap
    set swap_size (math 'ceil('(free -m | sed -n '2p' | awk '{print $2}')' / 1024)')
    if test $swap_size -gt 3
        set swap_size 3
    end

    touch /swap/swapfile
    chattr +C /swap/swapfile
    chattr -c /swap/swapfile

    fallocate -l "$swap_size"G /swap/swapfile

    chmod 600 /swap/swapfile
    mkswap /swap/swapfile
    swapon /swap/swapfile

    echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab

    # 最大限度使用物理内存
    echo 'vm.swappiness = 0' >> /etc/sysctl.d/99-sysctl.conf
    sysctl (cat /etc/sysctl.d/99-sysctl.conf | sed 's/ //g')
end

function help_doc
    switch (echo $LANG | grep -o '^..')
        case zh
            echo -e $g'用于安装和配置 arch 的脚本'$h
            echo
            echo '可选参数：'
            echo '  -h --help     显示此帮助消息。'
            echo '  -i --install  本地化和配置 arch.'
            echo '  -l --live     从临时环境安装基本 arch.'
            echo '  -s --ssh      打开 ssh 服务。'
            echo '  -w --wifi     连接到无线网络。'
        case '*'
            echo -e $g'a script to install and configure arch software'$h
            echo
            echo 'Optional arguments:'
            echo '  -h --help     Show this help message.'
            echo '  -i --install  localization and configuration arch.'
            echo '  -l --live     install the base arch from the live environment.'
            echo '  -s --ssh      open ssh service.'
            echo '  -w --wifi     connect to a wifi.'
    end
end

function option_parameter

    #   参数：
    #       1. 被认为是选项输入的，匹配 '^-' 的单项输入
    #
    #   变量：
    #       action: 参数解析完后执行的命令
    #       var_stack: 选项参数需要的额外变量

    switch $argv
        case -h --help
            set --global action 'help_doc'
        case -i --install
            set --prepend var_stack 'root_pass' 'user_pass'
            set --global action 'install_process'
        case -l --live
            set --global action 'live_install'
        case -s --ssh
            set --global action 'open_ssh'
        case -w --wifi
            set --global action 'connect_network'
        case --
            set enable_option false
        case '*'
            error wrong_option $argv
    end
end

function input_parameters

    # 输入参数
    #
    #   参数：
    #       argv: 所有的输入参数
    #
    #   变量：
    #       enable_option: 如果为 假，则不再匹配选项参数，后来参数皆当作普通参数
    #       var_stack: 对于某些选项参数，需要输入其他参数才能起作用，
    #                  由这个 '变量堆' 来存放必要的参数名字。
    #       input: 单个输入参数
    #       action: 参数解析完后执行的命令，由选项参数宣告
    #
    #   流程：
    #       先把所有参数分成单一的参数以进行解读
    #       如果参数的开头为 '-'，则当作选项参数进行匹配
    #           否则当作普通参数，以 '变量堆' 的第一个名字进行宣告，
    #           并移除已使用的 '变量堆' 名字。
    #       检查是否缺少必要参数
    #       删除 var_stack 变量以节省内存
    #       如果 action 变量存在则执行

    set --global enable_option true
    set --global var_stack 'overflow'

    for input in $argv
        if echo -- $input | grep -q '^-'; and $enable_option
            option_parameter $input
        else
            if test $var_stack[1] = 'overflow'
                error wrong_parameter $input
            end
            set --global $var_stack[1] $input
            set --erase var_stack[1]
        end
    end

    if test $var_stack[1] != 'overflow'
        set --erase var_stack[-1]
        error missing_parameter $var_stack
    end

    set --erase enable_option var_stack

    if set -q action
        $action
        exit 0
    else
        set --global action 'no'
    end
end

function error

    # 输出错误类型
    #
    #   参数：
    #       argv[1]: 错误类型
    #       argv[2]: 造成错误的输入

    echo
    switch $argv[1]
        case missing_parameter
            echo -e $r'missing parameter "'$h$argv[2]$r'"!'$h
            help_doc
        case not_root
            echo -e $r'please use super user to execute this script.'$h
            echo -e $r'use command: "sudo su" and try again.'$h
        case wrong_option
            echo -e $r'invalid option "'$h$argv[2]$r'"!'$h
            help_doc
        case wrong_parameter
            echo -e $r'unexpected parameter "'$h$argv[2]$r'"!'$h
            help_doc
        case '*'
            echo -e $r'unknown error type!'$h
    end

    exit 1
end

function live_install

    # 临时环境流程

    connect_network
    enter_user_var
    disk_partition
    mount_subvol
    install_basic_pkg
    change_root_dir
end

function install_process

    # arch 安装流程

    set_pacman
    set_localization
    install_pkg
    set_uz_repo
    config_copy
    config_write
    set_auto_start
end

function main

    # 主程序

    echo_color
    system_check
    input_parameters $argv
    install_pkg
    config_copy
    config_write
    after_set
    set_auto_start
end

main $argv

