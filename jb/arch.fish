#!/usr/bin/env fish

function system_check

    # 系统检查
    #
    #   是否为根用户
    #
    #   是否为虚拟机
    #
    #   引导程序类型
    #
    #   根分区位置
    #
    #   如果不是虚拟机
    #       cpu 提供商
    #
    #       gpu 提供商

    if test "$USER" != 'root'
        echo -e $r'please use super user to execute this script.'$h
        echo -e $r'use command: "sudo su" and try again.'$h
        exit 1
    end

    if test (systemd-detect-virt) = 'none'
        set not_virt 1
    else
        set not_virt 0
    end

    if test -d /sys/firmware/efi
        set bios_type 'uefi'
    else
        set bios_type 'bios'
    end

    set root_part (df | awk '$6=="/" {print $1}')

    if test $not_virt
        if lscpu | grep -q 'AuthenticAMD'
            set cpu_vendor 'amd'
        else if lscpu | grep -q 'GenuineIntel'
            set cpu_vendor 'intel'
        end

        if lspci | grep 'VGA' | grep -q 'AMD'
            set gpu_vendor 'amd'
        else if lspci | grep 'VGA' | grep -q 'Intel'
            set gpu_vendor 'intel'
        else if lspci | grep 'VGA' | grep -q 'NVIDIA'
            set gpu_vendor 'nvidia'
        end
    end
end

function color_var

    # 颜色变量

    set r '\033[1;31m'  # 红
    set g '\033[1;32m'  # 绿
    set y '\033[1;33m'  # 黄
    set b '\033[1;36m'  # 蓝
    set w '\033[1;37m'  # 白
    set h '\033[0m'     # 后缀
end

function system_var

    # 系统变量
    #
    #   地理区域
    #   分区类型
    #   仓库地址
    #
    # 用户变量
    #
    #   主机名
    #   用户名：第一个匹配的用户
    #   uz 目录存放地址

    set area 'Asia/Shanghai'
    set disk_type 'gpt'
    set git_url 'https://github.com/rraayy246/uz'

    set host_name (cat /etc/hostname)
    set user_name (ls /home | head -n 1)
    set uz_dir '/home/'$user_name'/a/uz'
end

function pkg_var

    # 软件包变量
    #
    #   引导程序
    #   必要：文件系统，壳，DHCP，镜像排序，文本编辑
    #
    #   网络：下载管理，文件传输
    #   终端：文本编辑，终端提示符
    #   文件操作：文件管理，压缩，快照管理
    #   同步：时间同步，文件同步
    #   查找：查找，高亮
    #   新查找
    #   系统：定时任务，系统监视，手册，软件包缓存，软件统计
    #   维护：arch 安装脚本，兼容 fat32，分区工具
    #   软件：手册，软件包缓存，软件统计
    #   安全：DNS 加密，防火墙
    #   特殊依赖：lua 语言，文件类型，二维码
    #   AUR 软件
    #
    #   如果不是虚拟机
    #       桌面软件包变量

    switch $bios_type
        case uefi
            set boot_pkg efibootmgr grub os-prober
        case bios
            set boot_pkg grub os-prober
    end
    set base_pkg btrfs-progs fish dhcpcd reflector vim

    set network_pkg curl git openssh wget wireguard-tools
    set terminal_pkg neovim starship
    set file_pkg lf p7zip snapper
    set sync_pkg chrony rsync
    set search_pkg fzf mlocate tree highlight
    set new_search_pkg fd ripgrep bat tldr exa
    set system_pkg fcron htop man pacman-contrib pkgstats
    set maintain_pkg arch-install-scripts dosfstools parted
    set security_pkg dnscrypt-proxy nftables
    set depend_pkg lua perl-file-mimeinfo qrencode zsh
    set aur_pkg yay

    if test $not_virt
        desktop_pkg_var
    end
end

function desktop_pkg_var

    # 桌面软件包变量
    #
    #   cpu 微码
    #
    #   gpu 驱动
    #
    #   声音驱动
    #   蓝牙驱动
    #   触摸板驱动
    #
    #   整合驱动
    #   管理：网络管理，电源管理
    #   显示：显示服务，平铺窗口，壁纸，超时，锁屏，兼容 Xorg
    #   桌面：终端模拟，状态栏，截图，程序菜单，Qt 5 支持
    #   浏览器
    #   多媒体：图像查看，视频播放
    #   输入法
    #   桌面控制：亮度控制，播放控制，硬件监视，电源工具
    #   办公：电子书阅读，办公软件套装，帮助手册
    #   字体
    #   编程语言

    switch $cpu_vendor
        case amd
            set ucode_pkg amd-ucode
        case intel
            set ucode_pkg intel-ucode
    end

    switch $gpu_vendor
        case amd
            set gpu_pkg xf86-video-amdgpu
        case intel
            set gpu_pkg xf86-video-intel
        case nvidia
            set gpu_pkg xf86-video-nouveau
    end

    set audio_pkg alsa-utils pulseaudio pulseaudio-alsa pulseaudio-bluetooth
    set bluetooth_pkg bluez bluez-utils blueman
    set touch_pkg libinput

    set driver_pkg $ucode_pkg $gpu_pkg $audio_pkg $bluetooth_pkg $touch_pkg
    set manager_pkg networkmanager tlp
    set display_pkg wayland sway swaybg swayidle swaylock xorg-xwayland
    set desktop_pkg alacritty i3status-rust grim slurp wofi lm_sensors qt5-wayland
    set browser_pkg firefox firefox-i18n-zh-cn
    set media_pkg imv vlc
    set input_pkg fcitx5-im fcitx5-rime
    set control_pkg brightnessctl playerctl lm_sensors upower
    set office_pkg calibre libreoffice-fresh-zh-cn
    set font_pkg noto-fonts-cjk noto-fonts-emoji ttf-font-awesome ttf-ubuntu-font-family
    set program_pkg bash-language-server clang nodejs rust yarn
end

function auto_start_var

    # 自启动变量
    #
    #   禁用：不安全 DNS
    #   自启动：时间同步，DNS 加密，定时任务，防火墙，软件包缓存，软件统计，ssh
    #
    #   如果不是虚拟机
    #       不启动：DHCP
    #       自启动：蓝牙，网络管理，电源管理
    #           网络管理 替换掉 DHCP，同时打开会出问题。
    #   否则
    #       自启动：DHCP

    set mask_auto systemd-resolved
    set start_auto chronyd dnscrypt-proxy fcron nftables paccache.timer pkgstats.timer sshd

    if test $not_virt
        set stop_auto $stop_auto dhcpcd
        set start_auto $start_auto bluetooth NetworkManager tlp
    else
        set start_auto $start_auto dhcpcd
    end
end

function init_var

    # 初始变量
    #
    #   颜色变量
    #   系统变量
    #   软件包变量
    #   自启动变量

    color_var
    system_var
    pkg_var
    auto_start_var
end

function doc_help

    # 帮助文档

    echo $g'a script to install and configure arch software'$h
    echo
    echo 'Optional arguments:'
    echo '  -h --help     Show this help message and exit.'
    echo '  -i --install  install and configure arch and exit.'
end

function options

    # 选项功能

    switch $argv[1]
        case -h --help
            doc_help
            exit 0
        case -i --install
            pacman_set
            local_set
            swap_file
            pkg_install
            uz_config
            config_copy
            config_write
            flypy_inst
            auto_start
            exit 0
    end
end

function pacman_set

    # 修改 pacman 设定
    #
    #   开启颜色
    #
    #   加上 archlinuxcn 源
    #       导入 GPG key
    #
    #   初始化密钥环
    #   验证主密钥

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
        if pacman -S --noconfirm --needed $argv
            break
        end
    end
end

function local_set

    # 本地化
    #
    #   设置时区
    #   同步时钟
    #
    #   语言信息
    #       设置成英文避免显示问题
    #
    #   主机表
    #
    #   设定根密码
    #
    #   添加用户
    #   设定用户密码
    #   添加用户组超级权限
    #   更改目录拥有者为用户
    #
    #   安装引导程序和必要软件包
    #
    #   安装引导程序
    #
    #   设定 grub 超时为 1
    #   生成 grub 主配置文件

    ln -sf /usr/share/zoneinfo/$area /etc/localtime
    hwclock --systohc

    sed -i '/\(en_US\|zh_CN\).UTF-8/s/#//' /etc/locale.gen
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf

    echo -e '127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t'$host_name'.localdomain '$host_name >> /etc/hosts

    echo -e $r'input a passwd for root: '$h
    passwd

    useradd -g wheel $user_name
    echo -e $r'input a passwd for '$user_name': '$h
    passwd $user_name
    sed -i '/# %wheel ALL=(ALL) NOPASSWD: ALL/s/# //' /etc/sudoers
    chown -R $user_name:wheel /home/$user_name

    pacman_install $boot_pkg $base_pkg

    switch $bios_type
        case uefi
            grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=grub
        case bios
            if echo $root_part | grep -q 'nvme'
                set grub_part (echo $i | sed 's/p[0-9]$//')
            else
                set grub_part (echo $i | sed 's/[0-9]$//')
            end
            grub-install --target=i386-pc $grub_part
    end

    sed -i '/GRUB_TIMEOUT=/s/5/1/' /etc/default/grub
    echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
end

function swap_file

    # 交换文件
    #
    #   创建空文件
    #   禁止写时复制
    #   禁止压缩
    #
    #   文件大小
    #       跟随内存大小，最多 3 G
    #
    #   设定拥有者读写
    #   格式化交换文件
    #   启用交换文件
    #
    #   写入 fstab
    #
    #   最大限度使用物理内存

    touch /swap/swapfile
    chattr +C /swap/swapfile
    chattr -c /swap/swapfile

    set i (math 'ceil('(free -m | sed -n '2p' | awk '{print $2}')' / 1024)')
    if test "$i" -gt 3; set i 3; end
    fallocate -l "$i"G /swap/swapfile

    chmod 600 /swap/swapfile
    mkswap /swap/swapfile
    swapon /swap/swapfile

    echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab

    echo 'vm.swappiness = 0' >> /etc/sysctl.d/99-sysctl.conf
    sysctl (cat /etc/sysctl.d/99-sysctl.conf | sed 's/ //g')
end

function pkg_install

    # 安装软件包
    #
    #   更新系统
    #
    #   网络，终端
    #   文件操作，同步
    #   查找，新查找
    #   系统，维护
    #   安全，特殊依赖，AUR 软件
    #
    #   如果不是虚拟机
    #       驱动，管理
    #       显示，桌面
    #       浏览器，多媒体
    #       输入法，桌面控制
    #       办公，字体，编程语言

    pacman -Syu --noconfirm

    pacman_install $network_pkg $terminal_pkg
    pacman_install $file_pkg $sync_pkg
    pacman_install $search_pkg $new_search_pk
    pacman_install $system_pkg $maintain_pkg
    pacman_install $security_pkg $depend_pkg $aur_pkg

    if test $not_virt
        pacman_install $driver_pkg $manager_pkg
        pacman_install $display_pkg $desktop_pkg
        pacman_install $browser_pkg $media_pkg
        pacman_install $input_pkg $control_pkg
        pacman_install $office_pkg $font_pkg $program_pkg
    end
end

function uz_config

    # uz 目录
    #
    #   克隆 uz 仓库
    #   软链接 uz 到用户根目录
    #
    #   记忆账号密码
    #   默认合并分支

    git clone https://github.com/rraayy246/uz $uz_dir --depth 1
    ln -s $uz_dir /home/$user_name

    cd $uz_dir
    git config credential.helper store
    git config --global user.email 'rraayy246@gmail.com'
    git config --global user.name 'ray'
    git config --global pull.rebase false
    cd
end

function sync_dir

    # 文件同步
    #
    #   参数：
    #       拥有者
    #       源目录
    #       目标目录
    #
    #   文件复制后，调整拥有者参数。

    rsync -a --inplace --no-whole-file --chown $argv
end

function config_copy

    # 设定复制
    #
    #   创建目录
    #
    #   fish 设置环境变量
    #
    #   链接配置文件
    #
    #   根用户配置文件
    #       把 vim 配置文件的插件内容注释掉，
    #       因为根用户很少用到插件。

    mkdir -p /home/$user_name/{a/vp/bv,gz,xz,.config/{fish/conf.d,nvim/.backup}}

    fish $uz_dir/pv/hjbl.fish
    su $user_name -c 'fish '$uz_dir'/pv/hjbl.fish'

    sync_dir root:root $uz_dir/pv/etc /
    sync_dir $user_name:wheel $uz_dir/pv/.config /home/$user_name

    sync_dir root:root $uz_dir/pv/.config /root
    sed -i '/^call plug#begin/,$s/^[^"]/"&/' /root/.config/nvim/init.vim

end

function config_write

    # 设定写入
    #
    #   创建 snapper 配置：root，srv，home
    #       因为 snapper 在创建配置时，不允许目录被其他子卷占用，
    #       所以先把目录卸载，创建 snapper 配置文件，再把子卷挂载回去。
    #
    #   防止快照被索引
    #   更改默认壳层为 fish
    #
    #   安装 zlua
    #
    #   终端提示符用 starship
    #   下载初始壁纸
    #
    #   安装 vim-plug
    #       插件下载
    #
    #   DNS 指向本地
    #       禁止修改

    if ! snapper list-configs | grep -q 'root'
        umount /.snapshots
        umount /srv/.snapshots
        umount /home/$user_name/.snapshots

        rmdir /.snapshots
        rmdir /srv/.snapshots
        rmdir /home/$user_name/.snapshots

        snapper -c root create-config /
        snapper -c srv create-config /srv
        snapper -c home create-config /home

        btrfs subvolume delete /.snapshots
        btrfs subvolume delete /srv/.snapshots
        btrfs subvolume delete /home/$user_name/.snapshots

        mkdir /.snapshots
        mkdir /srv/.snapshots
        mkdir /home/$user_name/.snapshots

        mount -a
    end
    sed -i '/PRUNENAMES/s/.git/& .snapshot/' /etc/updatedb.conf

    sed -i '/home\|root/s/bash/fish/' /etc/passwd

    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O /home/$user_name/.config/fish/conf.d/z.lua
    echo 'source (lua $HOME/.config/fish/conf.d/z.lua --init fish | psub)' > /home/$user_name/.config/fish/conf.d/z.fish

    echo -e 'if status is-interactive\n    starship init fish | source\nend' > /root/.config/fish/config.fish
    rsync -a /home/$user_name/a/uz/img/hw.png /home/$user_name/a/vp/bv/hw.png

    curl -fLo /home/$user_name/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    nvim +PlugInstall +qall

    echo -e 'nameserver ::1\nnameserver 127.0.0.1\noptions edns0 single-request-reopen' > /etc/resolv.conf
    chattr +i /etc/resolv.conf
end

function flypy_inst

    # 安装小鹤音形
    #
    #   原网址：http://flypy.ys168.com/
    #   原名称：小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
    #
    #   解压配置包
    #   复制到配置文件目录
    #
    #   重新加载输入法

    7z x /home/$user_name/a/uz/pv/flypy.7z -o/home/$user_name
    mkdir -p /home/$user_name/.local/share/fcitx5
    rsync -a --delete --inplace --no-whole-file /home/$user_name/rime /home/$user_name/.local/share/fcitx5
    rm -rf /home/$user_name/rime

    fcitx5-remote -r
end

function auto_start

    # 自启动
    #
    #   不启动
    #   禁用
    #   自启动

    systemctl disable $stop_auto
    systemctl mask $mask_auto
    systemctl enable --now $start_auto
end

# 主程序
function main
    system_check
    init_var
    options $argv
    pkg_install
    config_copy
end

main

