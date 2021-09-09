#!/usr/bin/env fish

function 拒绝根用户 --description 'root 用户退出'
    if test "$USER" = 'root'
        echo '请先退出root用户，并登陆新创建的用户。'
        exit 1
    end
end

# 修改 pacman 配置
function 软件包管理器
    # pacman 开启颜色
    sudo sed -i '/^#Color$/s/#//' /etc/pacman.conf
    # 加上 archlinuxcn 源
    if not string match -q '*archlinuxcn*' < /etc/pacman.conf
        echo -e '[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' | sudo tee -a /etc/pacman.conf
        # 导入 GPG key
        sudo pacman -Syy --noconfirm archlinuxcn-keyring
    end
    # 初始化密钥环
    sudo pacman-key --init
    # 验证主密钥
    sudo pacman-key --populate archlinux
    sudo pacman-key --populate archlinuxcn
end

# 判断显卡驱动
function 显卡驱动
    if lspci -vnn | string match -iq '*vga*amd*'
        echo xf86-video-amdgpu
    else if lspci -vnn | string match -iq '*vga*intel*'
        echo xf86-video-intel
    else if lspci -vnn | string match -iq '*vga*nvidia*'
        # 垃圾英伟达，能不用就不用。
        echo xf86-video-nouveau
    end
end

function 软件安装
    # 更新系统
    sudo pacman -Syu --noconfirm
    # 缩写
    set pacs sudo pacman -S --noconfirm
    # 文件系统管理，网络管理，电源管理
    $pacs btrfs-progs networkmanager tlp tlp-rdw
    # 声卡，触摸板，显卡驱动
    $pacs alsa-utils pulseaudio-alsa xf86-input-libinput (显卡驱动)

    # 互联网
        # 虛拟私人网络
        $pacs wireguard-tools
        # 网络浏览
        $pacs firefox firefox-i18n-zh-cn
        # 下载管理，文件传输
        $pacs curl git wget openssh

    # 多媒体
        # 显示服务，平铺窗口，壁纸，超时，锁屏，兼容 Xorg
        $pacs wayland sway swaybg swayidle swaylock xorg-xwayland
        # 状态栏，截图，程序菜单，Qt 5 支持
        $pacs i3status-rust grim slurp wofi qt5-wayland
        # 图像查看，视频播放
        $pacs imv vlc

    # 工具
        # 终端模拟，壳层，文本编辑，终端提示符
        $pacs alacritty fish neovim starship
        # 文件管理，压缩，分区工具
        $pacs lf p7zip parted
        # 时钟同步，文件同步
        $pacs ntp rsync
        # 系统监视，硬件监视
        $pacs htop lm_sensors
        # 快照管理
        $pacs snapper snap-pac
        # 输入法
        $pacs fcitx5-im fcitx5-rime
        # 查找，高亮
        $pacs fzf mlocate tree highlight
        # 新查找
        $pacs fd ripgrep bat tldr exa
        # 定时任务，二维码，确定文件类型
        $pacs fcron qrencode perl-file-mimeinfo
        # 播放控制，亮度控制，电源工具
        $pacs playerctl brightnessctl upower
        # 蓝牙
        $pacs pulseaudio-bluetooth bluez-utils
        # arch 安装脚本，兼容 fat32
        $pacs arch-install-scripts dosfstools
        # 软件包缓存，软件统计
        $pacs pacman-contrib pkgstats
        # 兼容
        $pacs vim zsh

    # 文档
        # 电子书阅读，办公软件套装，帮助手册
        $pacs calibre libreoffice-fresh-zh-cn man
        # 字体
        $pacs noto-fonts-cjk noto-fonts-emoji ttf-ubuntu-font-family ttf-font-awesome

    # 安全
        # 域名加密，防火墙
        $pacs dnscrypt-proxy nftables

    # 科学
        # 编程语言
        $pacs bash-language-server clang lua nodejs rust yarn
        # 游戏
        #$pacs gamemode ttf-liberation wqy-microhei wqy-zenhei steam

    # 安装 yay
    $pacs yay; or begin
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

function 复制设定
    # 创建目录
    mkdir -p $HOME/{a/vp/bv,gz,xz,.config/{fish/conf.d,nvim/.backup}}
    # 缩写
    set 配置文件 $HOME/a/uz/pv
    set sync rsync -ah --inplace --no-whole-file --info=progress2
    # fish 设置环境变量
    fish $配置文件/hjbl.fish
    sudo fish $配置文件/hjbl.fish
    # 链接配置文件
    sudo $sync -a $配置文件/etc /
    $sync -a $配置文件/.config $HOME

    # 根用户配置文件
    sudo $sync -a $配置文件/.config /root
    sudo sed -i '/^call plug#begin/,$s/^[^"]/"&/' /root/.config/nvim/init.vim

end

function 写入设定
    # 主机表
    sudo sed -i '/localhost\|localdomain/d' /etc/hosts
    echo -e '127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t'$hostname'.localdomain '$hostname | sudo tee -a /etc/hosts
    # sudo 免密码
    if not sudo grep -q '^[^#].*NOPASSWD:' /etc/sudoers
        sudo sed -i 's/(ALL) ALL/(ALL) NOPASSWD: ALL/g' /etc/sudoers
    end
    # grub 设置
    sudo sed -i '/GRUB_TIMEOUT=/s/5/1/' /etc/default/grub
    if not sudo grep -q 'GRUB_DISABLE_OS_PROBER' /etc/default/grub
        echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub
    end
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    # 域名解析
    echo -e 'nameserver 127.0.0.1\noptions edns0 single-request-reopen' | sudo tee /etc/resolv.conf
    sudo chattr +i /etc/resolv.conf
    # 创建 snapper 配置
    if not string length -q (sudo ls -A /.snapshots)
        sudo umount /.snapshots
        sudo rmdir /.snapshots
        sudo snapper -c root create-config /
        sudo btrfs subvolume delete /.snapshots
        sudo mkdir /.snapshots
        sudo mount -a

        sudo snapper -c home create-config /home
    end
    # 防止快照索引
    if not sudo grep -q '.snapshot' /etc/updatedb.conf
        sudo sed -i '/PRUNENAMES/s/.git/& .snapshot/' /etc/updatedb.conf
    end

    # 更改默认壳层为 fish
    sudo sed -i '/home/s/bash/fish/' /etc/passwd
    sudo sed -i '/root/s/bash/fish/' /etc/passwd
    rm $HOME/.bash*
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O $HOME/.config/fish/conf.d/z.lua
    echo 'source (lua $HOME/.config/fish/conf.d/z.lua --init fish | psub)' > $HOME/.config/fish/conf.d/z.fish
    # 终端提示符
    echo -e 'if status is-interactive\n    starship init fish | source\nend' | sudo tee /root/.config/fish/config.fish
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
    rsync -a --delete $HOME/rime $HOME/.local/share/fcitx5
    rm -rf $HOME/rime
    # 重新加载输入法
    fcitx5-remote -r
end

function 自启动
    sudo systemctl enable --now NetworkManager
    and sudo systemctl disable dhcpcd
    sudo systemctl enable --now {bluetooth,dnscrypt-proxy,fcron,NetworkManager-dispatcher,nftables,ntpd,paccache.timer,pkgstats.timer,tlp}
    sudo systemctl mask {systemd-resolved,systemd-rfkill.service,systemd-rfkill.socket}
end

function 交换文件
    if not test -e /swap/swapfile -a -d /swap
        # 创建空文件
        sudo touch /swap/swapfile
        # 禁止写时复制
        sudo chattr +C /swap/swapfile
        # 禁止压缩
        sudo chattr -c /swap/swapfile
        # 文件大小
        set i (math 'ceil('(free -m | sed -n '2p' | awk '{print $2}')' / 1024)')
        if test "$i" -gt 3; set i 3; end
        sudo fallocate -l "$i"G /swap/swapfile
        # 设定拥有者读写
        sudo chmod 600 /swap/swapfile
        # 格式化交换文件
        sudo mkswap /swap/swapfile
        # 启用交换文件
        sudo swapon /swap/swapfile
        # 写入 fstab
        if not sudo grep -q '/swap/swapfile' /etc/fstab
            echo '/swap/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
        end

        # 最大限度使用物理内存，生效
        if not sudo grep -q 'swappiness' /etc/sysctl.d/99-sysctl.conf
            echo 'vm.swappiness = 0' | sudo tee -a /etc/sysctl.d/99-sysctl.conf
            sudo sysctl (bat /etc/sysctl.d/99-sysctl.conf | sed 's/ //g')
        end
    end
end


# ======= 主程序 =======

拒绝根用户
switch $argv[1]
case a
    软件安装
case p
    复制设定
    写入设定
case u
    uz目录
case '*'
    软件包管理器
    软件安装
    uz目录
    复制设定
    写入设定
    小鹤音形
    自启动
    交换文件
end


