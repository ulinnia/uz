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

    # 系统配置变量

    set area 'Asia/Shanghai'
    set disk_type 'gpt'
    set git_url 'https://github.com/rraayy246/uz'
    set PASS '7777777'
end

function pkg_var

    # 软件包变量
    #
    #   引导程序
    #
    #   必要
    #   网络：下载管理，文件传输
    #   终端：壳层，文本编辑，终端提示符
    #   文件操作：文件管理，压缩，分区工具，快照管理
    #   同步：时钟同步，文件同步
    #   查找：查找，高亮
    #   新查找
    #   系统：定时任务，系统监视
    #   arch 安装脚本，兼容 fat32
    #   软件：软件包缓存，软件统计
    #   兼容
    #   安全：DNS 加密，防火墙
    #   特殊依赖：lua 语言，确定文件类型，二维码
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
    set terminal_pkg fish neovim starship
    set file_pkg lf p7zip parted snapper
    set sync_pkg ntp rsync
    set search_pkg fzf mlocate tree highlight
    set new_search_pkg fd ripgrep bat tldr exa
    set system_pkg fcron htop
    set arch_inst_pkg arch-install-scripts dosfstools
    set soft_pkg pacman-contrib pkgstats
    set compatible_pkg vim zsh
    set security_pkg dnscrypt-proxy nftables
    set depend_pkg lua perl-file-mimeinfo qrencode

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
    set manager_pkg networkmanager tlp tlp-rdw
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
    set auto_start dnscrypt-proxy fcron nftables ntpd paccache.timer pkgstats.timer sshd
end

function init_var
    color_var
    system_var
    pkg_var
end

# 用户输入变量
function var_user
    set username (ls /home)
    set hostname (cat /etc/hostname)
end

# pacman 安装软件包
function pacman_install
    for i in (seq 3)
        if pacman -S --noconfirm --needed $argv
            break
        end
    end
end

# 修改 pacman 设定
function pacman_set
    # pacman 开启颜色
    sed -i '/^#Color$/s/#//' /etc/pacman.conf
    # 加上 archlinuxcn 源
    if ! grep -q 'archlinuxcn' /etc/pacman.conf
        echo -e '[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
        # 导入 GPG key
        pacman -Syy --noconfirm archlinuxcn-keyring
    end
    # 初始化密钥环
    pacman-key --init
    # 验证主密钥
    pacman-key --populate archlinux
    pacman-key --populate archlinuxcn
end

# 本地化
function local_set
    # 安装基本软件包
    pacman_install $base_pkg
    # 设置时区
    ln -sf /usr/share/zoneinfo/$area /etc/localtime
    # 同步时钟
    hwclock --systohc
    # 语言信息
    sed -i '/\(en_US\|zh_CN\).UTF-8/s/#//' /etc/locale.gen
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf
    # 主机表
    echo -e '127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t'$hostname'.localdomain '$hostname >> /etc/hosts

    # 设定根密码
    R 'enter your root passwd: '
    passwd

    # 安装引导程序
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
    # 生成 grub 主配置文件
    grub-mkconfig -o /boot/grub/grub.cfg
end

function 软件安装
    # 更新系统
    pacman -Syu --noconfirm
    # 文件系统管理，网络管理，电源管理
    pacman_install btrfs-progs networkmanager tlp tlp-rdw
    # 声卡，触摸板，显卡驱动
    pacman_install alsa-utils pulseaudio-alsa xf86-input-libinput (显卡驱动)

    # 互联网
    # 虛拟私人网络
    pacman_install wireguard-tools
    # 网络浏览
    pacman_install firefox firefox-i18n-zh-cn
    # 下载管理，文件传输
    pacman_install curl git wget openssh

    # 多媒体
    # 显示服务，平铺窗口，壁纸，超时，锁屏，兼容 Xorg
    pacman_install wayland sway swaybg swayidle swaylock xorg-xwayland
    # 状态栏，截图，程序菜单，Qt 5 支持
    pacman_install i3status-rust grim slurp wofi qt5-wayland
    # 图像查看，视频播放
    pacman_install imv vlc

    # 工具
    # 终端模拟，壳层，文本编辑，终端提示符
    pacman_install alacritty fish neovim starship
    # 文件管理，压缩，分区工具，快照管理
    pacman_install lf p7zip parted snapper
    # 时钟同步，文件同步
    pacman_install ntp rsync
    # 系统监视，硬件监视
    pacman_install htop lm_sensors
    # 输入法
    pacman_install fcitx5-im fcitx5-rime
    # 查找，高亮
    pacman_install fzf mlocate tree highlight
    # 新查找
    pacman_install fd ripgrep bat tldr exa
    # 定时任务，二维码，确定文件类型
    pacman_install fcron qrencode perl-file-mimeinfo
    # 播放控制，亮度控制，电源工具
    pacman_install playerctl brightnessctl upower
    # 蓝牙
    pacman_install pulseaudio-bluetooth bluez-utils
    # arch 安装脚本，兼容 fat32
    pacman_install arch-install-scripts dosfstools
    # 软件包缓存，软件统计
    pacman_install pacman-contrib pkgstats
    # 兼容
    pacman_install vim zsh

    # 文档
    # 电子书阅读，办公软件套装，帮助手册
    pacman_install calibre libreoffice-fresh-zh-cn man
    # 字体
    pacman_install noto-fonts-cjk noto-fonts-emoji ttf-font-awesome ttf-ubuntu-font-family

    # 安全
    # 域名加密，防火墙
    pacman_install dnscrypt-proxy nftables

    # 科学
    # 编程语言
    pacman_install bash-language-server clang lua nodejs rust yarn
    # 游戏
    #pacman_install gamemode ttf-liberation wqy-microhei wqy-zenhei steam

    # 安装 yay
    pacman_install yay; or begin
        echo 'yay 下载失败'
    end
    # 修改 yay 配置
    yay --aururl 'https://aur.tuna.tsinghua.edu.cn' --save
end

# uz 设定
function uz目录
    # 克隆 uz 仓库
    git clone https://github.com/rraayy246/uz $HOME/a/uz --depth 1
    # 链接 uz
    ln -s $HOME/a/uz $HOME
    cd $HOME/uz
    # 记忆账号密码
    git config credential.helper store
    git config --global user.email 'rraayy246@gmail.com'
    git config --global user.name 'ray'
    # 默认合并分支
    git config --global pull.rebase false
    cd
end

function sync_file
    rsync -a --inplace --no-whole-file $argv
end

function 复制设定
    # 创建目录
    mkdir -p $HOME/{a/vp/bv,gz,xz,.config/{fish/conf.d,nvim/.backup}}
    # 缩写
    set 配置文件 $HOME/a/uz/pv
    # fish 设置环境变量
    fish $配置文件/hjbl.fish
    su $username fish $配置文件/hjbl.fish
    # 链接配置文件
    sync_file -a $配置文件/etc /
    sync_file -a $配置文件/.config $HOME

    # 根用户配置文件
    sync_file -a $配置文件/.config /root
    sed -i '/^call plug#begin/,$s/^[^"]/"&/' /root/.config/nvim/init.vim

end

function 写入设定
    # 主机表
    sed -i '/localhost\|localdomain/d' /etc/hosts
    # sudo 免密码
    if ! grep -q '^[^#].*NOPASSWD:' /etc/sudoers
        sed -i 's/(ALL) ALL/(ALL) NOPASSWD: ALL/g' /etc/sudoers
    end
    # grub 设置
    sed -i '/GRUB_TIMEOUT=/s/5/1/' /etc/default/grub
    if ! grep -q 'GRUB_DISABLE_OS_PROBER' /etc/default/grub
        echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
    end
    grub-mkconfig -o /boot/grub/grub.cfg
    # 域名解析
    echo -e 'nameserver 127.0.0.1\noptions edns0 single-request-reopen' > /etc/resolv.conf
    chattr +i /etc/resolv.conf
    # 创建 snapper 配置
    if ! snapper list-configs | grep -q 'root'
        umount /.snapshots
        rmdir /.snapshots
        snapper -c root create-config /
        btrfs subvolume delete /.snapshots
        mkdir /.snapshots
        mount -a

        snapper -c home create-config /home
    end
    # 防止快照索引
    if ! grep -q '.snapshot' /etc/updatedb.conf
        sed -i '/PRUNENAMES/s/.git/& .snapshot/' /etc/updatedb.conf
    end

    # 更改默认壳层为 fish
    sed -i '/home/s/bash/fish/' /etc/passwd
    sed -i '/root/s/bash/fish/' /etc/passwd
    rm $HOME/.bash*
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O $HOME/.config/fish/conf.d/z.lua
    echo 'source (lua $HOME/.config/fish/conf.d/z.lua --init fish | psub)' > $HOME/.config/fish/conf.d/z.fish
    # 终端提示符
    echo -e 'if status is-interactive\n    starship init fish | source\nend' > /root/.config/fish/config.fish
    # 壁纸
    rsync -a $HOME/a/uz/img/hw.png $HOME/a/vp/bv/hw.png

    # 安装 vim-plug
    curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # 插件下载
    nvim +PlugInstall +qall
end

# 安装小鹤音形
# http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
function 小鹤音形
    # 解压配置包
    7z x $HOME/a/uz/pv/flypy.7z -o$HOME
    mkdir -p $HOME/.local/share/fcitx5
    rsync -a --delete --inplace --no-whole-file $HOME/rime $HOME/.local/share/fcitx5
    rm -rf $HOME/rime
    # 重新加载输入法
    fcitx5-remote -r
end

function 自启动
    systemctl enable --now NetworkManager
    and systemctl disable dhcpcd
    systemctl enable --now {bluetooth,dnscrypt-proxy,fcron,NetworkManager-dispatcher,nftables,ntpd,paccache.timer,pkgstats.timer,tlp}
    systemctl mask {systemd-resolved,systemd-rfkill.service,systemd-rfkill.socket}
end

function 交换文件
    if ! test -e /swap/swapfile -a -d /swap
        # 创建空文件
        touch /swap/swapfile
        # 禁止写时复制
        chattr +C /swap/swapfile
        # 禁止压缩
        chattr -c /swap/swapfile
        # 文件大小
        set i (math 'ceil('(free -m | sed -n '2p' | awk '{print $2}')' / 1024)')
        if test "$i" -gt 3; set i 3; end
        fallocate -l "$i"G /swap/swapfile
        # 设定拥有者读写
        chmod 600 /swap/swapfile
        # 格式化交换文件
        mkswap /swap/swapfile
        # 启用交换文件
        swapon /swap/swapfile
        # 写入 fstab
        if ! grep -q '/swap/swapfile' /etc/fstab
            echo '/swap/swapfile none swap defaults 0 0' >> /etc/fstab
        end

        # 最大限度使用物理内存，生效
        if ! grep -q 'swappiness' /etc/sysctl.d/99-sysctl.conf
            echo 'vm.swappiness = 0' >> /etc/sysctl.d/99-sysctl.conf
            sysctl (bat /etc/sysctl.d/99-sysctl.conf | sed 's/ //g')
        end
    end
end

# 主程序
function main
    system_check
    init_var
    pacman_set
    local_set
end

main

