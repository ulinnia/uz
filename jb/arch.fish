#!/usr/bin/env fish

function color_var

    # 颜色变量

    set --global r '\033[1;31m'  # 红
    set --global g '\033[1;32m'  # 绿
    set --global y '\033[1;33m'  # 黄
    set --global b '\033[1;36m'  # 蓝
    set --global w '\033[1;37m'  # 白
    set --global h '\033[0m'     # 后缀
end

function system_var

    # 系统变量
    #
    #   变量：
    #       area:       地理区域
    #       disk_type:  分区类型
    #       git_url:    仓库地址

    set --global area       'Asia/Shanghai'
    set --global disk_type  'gpt'
    set --global git_url    'https://github.com/rraayy246/uz'
end

function read_format

    # 读取格式
    #
    #   参数：
    #       argv[1]: 要宣告的变量名
    #       argv[2]: 提示语
    #       argv[3]: 匹配的格式
    #
    #   只读取特定格式，且进行再确认。

    set ans ''
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

function user_var

    # 用户变量
    #
    #   变量：
    #       user_name:  用户名称
    #       host_name:  主机名
    #       root_pass:  根用户密码
    #       user_pass:  用户密码
    #       uz_dir:     uz 目录存放地址
    #       user_mkdir: 用户新建目录
    #
    #   如果处于 临时环境流程，则由用户手动输入，
    #   否则自动判断。

    if test "$action" = 'live_install'
        read_format user_name $r'enter your '$h'username: '     '^[a-z][-a-z0-9]*$'
        read_format host_name $r'enter your '$h'hostname: '     '^[a-zA-Z][-a-zA-Z0-9]*$'
        read_format root_pass $r'enter your '$h'root passwd: '  '^[-_,.a-zA-Z0-9]*$'
        read_format user_pass $r'enter your '$h'user passwd: '  '^[-_,.a-zA-Z0-9]*$'
    else
        set --global host_name  (cat /etc/hostname)
        set --global user_name  (ls /home | head -n 1)
        set --global uz_dir     "/home/$user_name/a/uz"
        set --global user_mkdir 'a/pixra/bimple' gz xz '.config/fish/conf.d' '.config/nvim/.backup'
    end
end

function pkg_var

    # 软件包变量
    #
    #   变量：
    #       base_pkg:   基本：文件系统，壳，DHCP，镜像排序，文本编辑
    #       bios_type:  引导程序类型
    #       boot_pkg:   引导程序包
    #
    #       network_pkg:    网络：下载管理，文件传输
    #       terminal_pkg:   终端：文本编辑，终端提示符
    #       file_pkg:       文件操作：文件管理，压缩，快照管理
    #       sync_pkg:       同步：时间同步，文件同步
    #       search_pkg:     查找：查找，高亮
    #       new_search_pkg: 新查找
    #       system_pkg:     系统：定时任务，系统监视，手册，软件包缓存，软件统计
    #       maintain_pkg:   维护：arch 安装脚本，兼容 fat32，分区工具
    #       security_pkg:   安全：DNS 加密，防火墙
    #       depend_pkg:     特殊依赖：lua 语言，文件类型，二维码
    #       aur_pkg:        AUR 软件
    #
    #   如果处于 临时环境流程，则宣告 基本包 后返回
    #   如果使用图形界面，则加载 图形软件包变量

    if test "$action" = 'live_install'
        set --global base_pkg base base-devel linux linux-firmware btrfs-progs fish dhcpcd reflector vim
        return
    end

    switch $bios_type
        case uefi
            set --global boot_pkg efibootmgr grub
        case bios
            set --global boot_pkg grub
    end

    set --global network_pkg    curl git openssh wget wireguard-tools
    set --global terminal_pkg   neovim starship
    set --global file_pkg       lf p7zip snapper
    set --global sync_pkg       chrony rsync
    set --global search_pkg     fzf mlocate tree highlight
    set --global new_search_pkg fd ripgrep bat tldr exa
    set --global system_pkg     fcron htop man pacman-contrib pkgstats
    set --global maintain_pkg   arch-install-scripts dosfstools parted
    set --global security_pkg   dnscrypt-proxy nftables
    set --global depend_pkg     lua perl-file-mimeinfo qrencode zsh
    set --global aur_pkg        yay

    if $use_graphic
        set --append boot_pkg os-prober

        graphic_pkg_var
    end
end

function graphic_pkg_var

    # 图形软件包变量
    #
    #   变量：
    #       cpu_vendor: cpu 提供商
    #       ucode_pkg:  cpu 微码
    #       gpu_vendor: gpu 提供商
    #       gpu_pkg:    gpu 驱动
    #
    #       audio_pkg:      声音驱动
    #       bluetooth_pkg:  蓝牙驱动
    #       touch_pkg:      触摸板驱动
    #
    #       driver_pkg:     整合驱动
    #       manager_pkg:    管理：网络管理，电源管理
    #       display_pkg:    显示：显示服务，平铺窗口，壁纸，超时，锁屏，兼容 Xorg
    #       desktop_pkg:    桌面：终端模拟，状态栏，截图，程序菜单，Qt 5 支持
    #       browser_pkg:    浏览器
    #       media_pkg:      多媒体：图像查看，视频播放
    #       input_pkg:      输入法
    #       control_pkg:    桌面控制：亮度控制，播放控制，硬件监视，电源工具
    #       virtual_pkg:    虚拟机：qemu，虚拟网络，uefi 支持
    #       office_pkg:     办公：电子书阅读，办公软件套装，帮助手册
    #       font_pkg:       字体
    #       program_pkg:    编程语言

    switch $cpu_vendor
        case amd
            set --global ucode_pkg amd-ucode
        case intel
            set --global ucode_pkg intel-ucode
    end

    switch $gpu_vendor
        case amd
            set --global gpu_pkg xf86-video-amdgpu
        case intel
            set --global gpu_pkg xf86-video-intel
        case nvidia
            set --global gpu_pkg xf86-video-nouveau
    end

    set audio_pkg       alsa-utils pulseaudio pulseaudio-alsa pulseaudio-bluetooth
    set bluetooth_pkg   bluez bluez-utils blueman
    set touch_pkg       libinput

    set --global driver_pkg     $ucode_pkg $gpu_pkg $audio_pkg $bluetooth_pkg $touch_pkg
    set --global manager_pkg    networkmanager tlp
    set --global display_pkg    wayland sway swaybg swayidle swaylock xorg-xwayland
    set --global desktop_pkg    alacritty i3status-rust grim slurp wofi lm_sensors qt5-wayland
    set --global browser_pkg    firefox firefox-i18n-zh-cn
    set --global media_pkg      imv vlc
    set --global input_pkg      fcitx5-im fcitx5-rime
    set --global control_pkg    brightnessctl playerctl lm_sensors upower
    set --global virtual_pkg    qemu libvirt virt-manager dnsmasq bridge-utils openbsd-netcat edk2-ovmf
    set --global office_pkg     calibre libreoffice-fresh-zh-cn
    set --global font_pkg       noto-fonts-cjk noto-fonts-emoji ttf-font-awesome ttf-ubuntu-font-family
    set --global program_pkg    bash-language-server clang nodejs rust yarn
end

function auto_start_var

    # 自启动变量
    #
    #   变量：
    #       mask_auto:  禁用：不安全 DNS
    #       auto_start: 自启动：时间同步，DNS 加密，定时任务，防火墙，软件包缓存，软件统计，ssh
    #       stop_auto:  不启动
    #
    #   如果使用图形界面，则网络管理 替换掉 DHCP，同时打开两者会出问题，
    #   并自启动：蓝牙，虚拟化，网络管理，电源管理
    #   否则自启动：DHCP

    set --global mask_auto  systemd-resolved
    set --global start_auto chronyd dnscrypt-proxy fcron nftables paccache.timer pkgstats.timer reflector.timer sshd

    if $use_graphic
        set --global --append stop_auto     dhcpcd
        set --global --append start_auto    bluetooth libvirtd NetworkManager tlp
    else
        set --global --append start_auto    dhcpcd
    end
end

function cpu_gpu_var

    # cpu 和 gpu 变量
    #
    #   变量：
    #       cpu_vendor: cpu 提供商
    #       gpu_vendor: gpu 提供商

    if lscpu | grep -q 'AuthenticAMD'
        set --global cpu_vendor 'amd'
    else if lscpu | grep -q 'GenuineIntel'
        set --global cpu_vendor 'intel'
    end

    if lspci | grep '3D\|VGA' | grep -q 'AMD'
        set --global gpu_vendor 'amd'
    else if lspci | grep '3D\|VGA' | grep -q 'Intel'
        set --global gpu_vendor 'intel'
    else if lspci | grep '3D\|VGA' | grep -q 'NVIDIA'
        set --global gpu_vendor 'nvidia'
    end
end

function system_check

    # 系统检查
    #
    #   变量：
    #       USER:       当下用户名
    #       bios_type:  引导程序类型
    #       use_graphic:使用图形界面
    #       root_part:  根目录的分区

    if test "$USER" != 'root'
        error not_root
    end

    if test -d /sys/firmware/efi
        set --global bios_type 'uefi'
    else
        set --global bios_type 'bios'
    end

    if test "$action" != 'live_install'
        if test (systemd-detect-virt) = 'none'
            set --global use_graphic true
        else
            set --global use_graphic false
        end

        set --global root_part (df | awk '$6=="/" {print $1}')

        if $use_graphic
            cpu_gpu_var
        end
    end
end

function network_check

    # 网络检查
    #
    #   如果能连上网络，则返回 0

    if ping -c 1 -w 1 1.1.1.1 &>/dev/null
        # 更新系统时间
        timedatectl set-ntp true
        echo -e $g'network connection is successful.'$h
        return 0
    else
        echo -e $r'Network connection failed.'$h
        return 1
    end
end

function select

    # 选择
    #
    #   参数：
    #       argv[1]:        储存选择结果的变数名
    #       list:           可供选择的选项
    #       argv[2..-1]:    输入可供选择的选项
    #
    #   输出：
    #       使用者选择的选项
    #
    #   如果 ans 包含非数字，或小于 0， 或大于清单长度，则重新输入。

    set ans 0
    set list $argv[2..-1]

    for i in (seq (count $list))
        echo $i. $list[$i]
    end

    while ! echo -- $ans | grep -q '^[1-9][0-9]*$'; or test $ans -gt (count $list)
        read -p 'echo "> "' ans
    end

    set --global $argv[1] $list[$ans]
end

function connect_network

    # 连接无线网络
    #
    # 变量：
    #   iw_dev: 取得网络设备名称

    set iw_dev (iw dev | awk '$1=="Interface"{print $2}')

    while ! network_check
        iwctl station $iw_dev scan
        iwctl station $iw_dev get-networks
        read -p 'echo -e $r"ssid you want to connect to: "$h' ssid
        iwctl station $iw_dev connect $ssid[1]
    end
end

function open_ssh

    # 打开 ssh
    #
    #   如果 ssh 未启动，则设定密码并启动 ssh.

    set interface   (ip -o -4 route show to default | awk '{print $5}')
    set ip          (ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

    read -p 'echo -e $r"enter your "$h"root passwd: "' root_pass
    echo "$USER:$root_pass" | chpasswd
    systemctl start sshd

    echo
    echo -e $g'$ ssh '$USER'@'$ip$h
    echo -e $g"passwd = $root_pass"$h
end

function disk_partition

    # 硬盘分区
    #
    #   流程：
    #       选择硬盘
    #       创建 GPT 分区表
    #
    #       创建启动分区
    #       启用启动分区
    #       创建根分区

    echo -e $r'automatic partition or manual partition: '$h

    select ans 'automatic' 'manual'
    if test $ans = 'automatic'
        select_part part

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
        select_part boot_part
        select_part root_part
        set boot_part /dev/$boot_part
        set root_part /dev/$root_part
    end

    mount_subvol
end

function select_part

    # 选择分区
    #
    #   参数：
    #       argv: 要宣告的变量名
    #
    #   流程：
    #       列出现有分区
    #       选择分区

    set list_part (lsblk -l | awk '{ print $1 }' | grep '^\(nvme\|sd.\|vd.\)')
    lsblk
    echo -e $r'select a partition as the '$h$argv[1]$r' partition: '$h
    select $argv[1] $list_part
end

function mount_subvol

    # 挂载子卷
    #
    #   流程：
    #       格式化根分区
    #       创建子卷
    #       挂载子卷
    #       避免 /var/lib 资料遗失
    #           将 /usr/var/lib 挂载到 /var/lib
    #       efi 目录挂载

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

    mkdir -p        /mnt/usr/var/lib /mnt/var/lib
    mount --bind    /mnt/usr/var/lib /mnt/var/lib

    if test $bios_type = 'uefi'
        mkdir /mnt/efi
        mount $boot_part /mnt/efi
    end
end

function base_install

    # 安装基本软件包
    #
    #   流程：
    #       更新密钥环
    #       镜像排序
    #       安装基本软件包

    pacman -Sy --noconfirm archlinux-keyring

    echo 'sorting mirror...'
    pacman -S --needed --noconfirm reflector &>/dev/null
    reflector --latest 9 --protocol https --save /etc/pacman.d/mirrorlist --sort rate

    pacstrap /mnt $base_pkg
end

function arch_chroot

    # 切换根目录
    #
    #   流程：
    #       设置主机名
    #       复制镜像
    #
    #       生成 fstab 文件
    #
    #       下载脚本
    #
    #       切换根目录
    #       切换根目录结束

    echo $host_name > /mnt/etc/hostname
    cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d

    umount /mnt/var/lib
    genfstab -L /mnt >> /mnt/etc/fstab
    mount --bind /mnt/usr/var/lib /mnt/var/lib
    echo '/usr/var/lib /var/lib none defaults,bind 0 0' >> /mnt/etc/fstab

    rsync (status -f) /mnt/arch.fish
    chmod +x /mnt/arch.fish

    arch-chroot /mnt /arch.fish --install "$root_pass" "$user_pass"
    rm /mnt/arch.fish
    #umount -R /mnt
    echo -e $r'please reboot.'$h
end

function pacman_set

    # 修改 pacman 设定
    #
    #   流程：
    #       开启颜色
    #
    #       加上 archlinuxcn 源
    #           导入 GPG key
    #
    #       初始化密钥环
    #       验证主密钥

    sed -i '/^#Color$/s/#//' /etc/pacman.conf

    echo -e '[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
    pacman -Syy --noconfirm archlinuxcn-keyring

    pacman-key --init
    pacman-key --populate archlinux
    pacman-key --populate archlinuxcn
end

function pacman_install

    # pacman 安装软件包
    #
    #   参数：
    #       要安装的软件包列表
    #
    #   一次性安装太多软件包容易安装失败，
    #   所以就连试三次，增加安装成功的几率。

    for i in (seq 3)
        if pacman -S --needed --noconfirm $argv
            break
        end
    end
end

function local_set

    # 本地化
    #
    #   流程：
    #       设置时区
    #       同步时钟
    #
    #       语言信息
    #           设置成英文避免显示问题
    #
    #       主机表
    #
    #       设定根密码
    #
    #       添加用户
    #       设定用户密码
    #       添加用户组超级权限
    #       更改目录拥有者为用户
    #
    #       安装引导程序和必要软件包
    #
    #       安装引导程序
    #
    #       设定 grub 超时为 1
    #       生成 grub 主配置文件

    ln -sf /usr/share/zoneinfo/$area /etc/localtime
    hwclock --systohc

    sed -i '/\(en_US\|zh_CN\).UTF-8/s/#//' /etc/locale.gen
    locale-gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf

    echo -e '127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t'$host_name'.localdomain '$host_name >> /etc/hosts

    echo "root:$root_pass" | chpasswd

    useradd -g wheel $user_name
    echo "$user_name:$user_pass" | chpasswd
    sed -i '/# %wheel ALL=(ALL) NOPASSWD: ALL/s/# //' /etc/sudoers
    chown -R $user_name:wheel /home/$user_name

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

    if $use_graphic
        echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
    end

    sed -i '/GRUB_TIMEOUT=/s/5/1/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
end

function pkg_install

    # 安装软件包
    #
    #   更新系统，然后安装软件包

    pacman -Syu --noconfirm

    pacman_install $network_pkg     $terminal_pkg
    pacman_install $file_pkg        $sync_pkg
    pacman_install $search_pkg      $new_search_pkg
    pacman_install $system_pkg      $maintain_pkg
    pacman_install $security_pkg    $depend_pkg $aur_pkg

    echo -e 'y\n\n' | pacman -S --needed iptables-nft

    if $use_graphic
        pacman_install $driver_pkg  $manager_pkg
        pacman_install $display_pkg $desktop_pkg
        pacman_install $browser_pkg $media_pkg
        pacman_install $input_pkg   $control_pkg
        pacman_install $virtual_pkg $office_pkg
        pacman_install $font_pkg    $program_pkg
    end
end

function su_user

    # 以用户执行
    #
    #   避免创建出的目录或文件，用户无权操作。

    cd /home/$user_name
    sudo -u $user_name $argv
    cd
end

function uz_config

    # uz 目录
    #
    #   流程：
    #       克隆 uz 仓库
    #       软链接 uz 到用户根目录
    #
    #       记忆账号密码
    #       默认合并分支

    su_user git clone https://github.com/rraayy246/uz $uz_dir --depth 1
    ln -sf $uz_dir /home/$user_name

    cd $uz_dir
    git config credential.helper store
    su_user git config --global user.email 'rraayy246@gmail.com'
    su_user git config --global user.name 'ray'
    su_user git config --global pull.rebase false
    cd
end

function sync_dir

    # 文件同步
    #
    #   参数：
    #       源目录
    #       目标目录
    #
    #   如果目标目录为用户的目录，则切换为用户执行复制，
    #   以免用户无权操作。

    if echo $argv[2] | grep -q '^/home'
        su_user rsync -a --inplace --no-whole-file $argv
    else
        rsync -a --inplace --no-whole-file $argv
    end
end

function config_copy

    # 设定复制
    #
    #   流程：
    #       创建目录
    #
    #       fish 设置环境变量
    #
    #       链接配置文件
    #

    su_user mkdir -p /home/$user_name/$user_mkdir

    fish $uz_dir/pv/hjbl.fish
    su_user fish $uz_dir/pv/hjbl.fish

    sync_dir $uz_dir/pv/etc /
    sync_dir $uz_dir/pv/.config /root
    sync_dir $uz_dir/pv/.config /home/$user_name
end

function config_write

    # 设定写入
    #
    #   流程：
    #
    #       更改默认壳层为 fish
    #
    #       安装 zlua
    #
    #       终端提示符用 starship
    #       把根用户的 vim 配置文件的插件内容注释掉
    #
    #       DNS 指向本地
    #           禁止修改
    #
    #       如果使用图形界面
    #           安装 vim-plug
    #           虚拟机设定
    #           输入法设定

    sed -i '/home\|root/s/bash/fish/' /etc/passwd

    su_user wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O /home/$user_name/.config/fish/conf.d/z.lua
    su_user echo 'source (lua $HOME/.config/fish/conf.d/z.lua --init fish | psub)' > /home/$user_name/.config/fish/conf.d/z.fish

    echo -e 'if status is-interactive\n\tstarship init fish | source\nend' > /root/.config/fish/config.fish
    sed -i '/^call plug#begin/,$ s/^/"/' /root/.config/nvim/init.vim

    echo -e 'nameserver ::1\nnameserver 127.0.0.1\noptions edns0 single-request-reopen' > /etc/resolv.conf
    chattr +i /etc/resolv.conf

    if $use_graphic
        sync_dir /home/$user_name/a/uz/img/hw.png /home/$user_name/a/pixra/bimple/hw.png

        su_user curl -fLo /home/$user_name/.local/share/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

        virtualizer_set
        flypy_inst
    else
        echo -e 'if status is-interactive\n\tstarship init fish | source\nend' > /home/$user_name/.config/fish/config.fish
        sed -i '/^call plug#begin/,$ s/^/"/' /home/$user_name/.config/nvim/init.vim
    end
end

function virtualizer_set

    # 虚拟机设定
    #
    #   加入 libvirt 组以获得权限
    #   加入 kvm 组

    echo '/* 允许 kvm 组中的用户管理 libvirt 的守护进程  */
polkit.addRule(function(action, subject) {
  if (action.id == "org.libvirt.unix.manage" &&
    subject.isInGroup("kvm")) {
      return polkit.Result.YES;
  }
});' | tee /etc/polkit-1/rules.d/50-libvirt.rules

    usermod -a -G kvm $user_name
end

function flypy_inst

    # 安装小鹤音形
    #
    #   原网址：http://flypy.ys168.com/
    #   原名称：小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
    #
    #   解压配置包
    #   复制到配置文件目录

    su_user 7z x /home/$user_name/a/uz/pv/flypy.7z -o/home/$user_name
    su_user mkdir -p /home/$user_name/.local/share/fcitx5
    su_user rsync -a --delete --inplace --no-whole-file /home/$user_name/rime /home/$user_name/.local/share/fcitx5
    rm -rf /home/$user_name/rime
end

function auto_start

    # 自启动
    #
    #   不启动
    #   禁用
    #   自启动

    auto_start_var

    systemctl disable $stop_auto
    systemctl mask $mask_auto
    systemctl enable --now $start_auto
end

function after_set

    # 系统装完后设定
    #
    #   流程：
    #       下载 nvim 插件
    #       snapper 设定
    #       交换文件
    #
    #   这些设定似乎要在系统安装完后才能设定，
    #   如果在安装期间设定，则会失败。

    su_user nvim +PlugInstall +qall

    if ! snapper list-configs | grep -q 'root'
        snapper_set
    end

    if test -d /swap -a ! -e /swap/swapfile
        swap_file
    end
end

function snapper_set

    # snapper 设定
    #
    #   流程：
    #       创建 snapper 配置：root，srv，home
    #           因为 snapper 在创建配置时，不允许目录被其他子卷占用，
    #           所以先把目录卸载，创建 snapper 配置文件，再把子卷挂载回去。
    #
    #       防止快照被索引

    set snap_dir / /srv/ /home/

    umount $snap_dir'.snapshots'
    rmdir $snap_dir'.snapshots'

    snapper -c root create-config /
    snapper -c srv create-config /srv
    snapper -c home create-config /home

    btrfs subvolume delete $snap_dir'.snapshots'
    mkdir $snap_dir'.snapshots'

    mount -a

    sed -i '/PRUNENAMES/s/.git/& .snapshot/' /etc/updatedb.conf
end

function swap_file

    # 交换文件
    #
    #   变量：
    #       swap_size: 交换文件的大小
    #
    #   流程：
    #       创建空文件
    #       禁止写时复制
    #       禁止压缩
    #
    #       文件大小
    #           跟随内存大小，最多 3 G
    #
    #       设定拥有者读写
    #       格式化交换文件
    #       启用交换文件
    #
    #       写入 fstab
    #
    #       最大限度使用物理内存

    touch /swap/swapfile
    chattr +C /swap/swapfile
    chattr -c /swap/swapfile

    set swap_size (math 'ceil('(free -m | sed -n '2p' | awk '{print $2}')' / 1024)')
    if test $swap_size -gt 3; set swap_size 3; end
    fallocate -l "$swap_size"G /swap/swapfile

    chmod 600 /swap/swapfile
    mkswap /swap/swapfile
    swapon /swap/swapfile

    echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab

    echo 'vm.swappiness = 0' >> /etc/sysctl.d/99-sysctl.conf
    sysctl (cat /etc/sysctl.d/99-sysctl.conf | sed 's/ //g')
end

function doc_help

    # 帮助文档
    #
    #   变量：
    #       LANG: 系统设定的语言

    echo
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

function input_option

    # 选项参数
    #
    #   参数：
    #       argv: 被认为是选项输入的，匹配 '^-' 的单项输入
    #
    #   变量：
    #       action: 参数解析完后执行的命令
    #       var_stack: 选项参数需要的额外变量
    #       is_option: 如果为 假，则不再匹配选项参数，后来参数皆当作普通参数

    switch $argv
        case -h --help
            set --global action 'doc_help'
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
            set is_option false
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
    #       is_option: 如果为 假，则不再匹配选项参数，后来参数皆当作普通参数
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

    set --global is_option true
    set --global var_stack 'overflow'

    for input in $argv
        if echo -- $input | grep -q '^-'; and $is_option
            input_option $input
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

    set --erase is_option var_stack

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
            doc_help
        case not_root
            echo -e $r'please use super user to execute this script.'$h
            echo -e $r'use command: "sudo su" and try again.'$h
        case wrong_option
            echo -e $r'invalid option "'$h$argv[2]$r'"!'$h
            doc_help
        case wrong_parameter
            echo -e $r'unexpected parameter "'$h$argv[2]$r'"!'$h
            doc_help
        case '*'
            echo -e $r'unknown error type!'$h
    end

    exit 1
end

function live_install

    # 临时环境流程

    system_check
    connect_network
    user_var
    disk_partition
    mount_subvol
    pkg_var
    base_install
    arch_chroot
end

function install_process

    # arch 安装流程

    system_check
    pacman_set
    system_var
    user_var
    pkg_var
    local_set
    pkg_install
    uz_config
    config_copy
    config_write
    auto_start
end

function main

    # 主程序

    color_var
    input_parameters $argv
    system_check
    pkg_var
    pkg_install
    user_var
    config_copy
    config_write
    after_set
    auto_start
end

main $argv

