#!/usr/bin/env fish

# root 用户不建议使用此脚本
function yh_ud --description 'root 用户退出'
    if test "$USER" = 'root'
        echo '请先退出root用户，并登陆新创建的用户。'
        exit 1
    end
end

# 修改 pacman 配置
function rj_ud
    # pacman 增加 multilib 源
    #sudo sed -i '/^#\[multilib\]/,+1s/^#//g' /etc/pacman.conf
    # pacman 开启颜色
    sudo sed -i '/^#Color$/s/#//' /etc/pacman.conf
    # 加上 archlinuxcn 源
    if not string match -q '*archlinuxcn*' < /etc/pacman.conf
        echo -e '[archlinuxcn]\nServer = https://repo.archlinuxcn.org/$arch' | sudo tee -a /etc/pacman.conf
        # 导入 GPG key
        sudo pacman -Syy --noconfirm archlinuxcn-keyring
    end
end

# 判断显卡驱动
function xk_ud
    if lspci -vnn | string match -iq '*vga*amd*radeon*'
        echo xf86-video-amdgpu
    else if lspci -vnn | string match -iq '*vga*nvidia*geforce*'
        echo xf86-video-nouveau
    end
end

# 安装软件
function rj_av
    # 更新系统
    sudo pacman -Syu --noconfirm
    # 同步包名数据库
    sudo pacman -Fy --noconfirm
    # 缩写
    set pacn sudo pacman -S --noconfirm
    # btrfs 管理，网络管理器，tlp
    $pacn btrfs-progs networkmanager tlp tlp-rdw
    # 声卡，触摸板，显卡驱动
    $pacn alsa-utils pulseaudio-alsa xf86-input-libinput (xk_ud)

    # 互联网
        # 网络连接
        $pacn curl firefox firefox-i18n-zh-cn git wget

    # 多媒体
        # wayland 显示服务器
        $pacn wayland sway swaybg swayidle swaylock xorg-xwayland
        # 显示
        $pacn imv p7zip vlc
        # xorg 显示服务器
        #$pacn xorg xorg-xinit i3-gaps i3lock imagemagick rofi
        # 截图，菜单
        $pacn grim slurp wofi qt5-wayland

    # 工具
        # 终端
        $pacn alacritty fish i3status-rust neovim nnn
        # 小企鹅输入法
        $pacn fcitx5-im fcitx5-rime
        # 播放控制，亮度控制，电源工具
        $pacn playerctl brightnessctl upower lm_sensors
        # 查找
        $pacn fzf htop tree
        # 新查找
        $pacn fd ripgrep bat tldr exa
        # mtp，蓝牙
        $pacn libmtp pulseaudio-bluetooth bluez-utils
        # 安装 arch
        $pacn arch-install-scripts dosfstools parted
        # 缓存，统计，兼容
        $pacn pacman-contrib pkgstats vim zsh

    # 文档
        # 繁简中日韩，emoji，Ubuntu字体
        $pacn noto-fonts-cjk noto-fonts-emoji ttf-ubuntu-font-family ttf-font-awesome
        # 电子书，办公
        $pacn calibre libreoffice-fresh-zh-cn

    # 安全
        # 网络安全
        $pacn dnscrypt-proxy nftables ntp openssh wireguard-tools

    # 科学
        # 编程语言
        $pacn bash-language-server clang lua nodejs rust yarn
        # steam
        #$pacn gamemode ttf-liberation wqy-microhei wqy-zenhei steam

    # 安装 yay
    $pacn yay; or begin
        # 删除 gnupg 目录及其文件
        sudo rm -R  /etc/pacman.d/gnupg/
        # 初始化密钥环
        sudo pacman-key --init
        # 验证主密钥
        sudo pacman-key --populate archlinux
        sudo pacman-key --populate archlinuxcn
        $pacn yay; or begin
            echo '下载 yay 失败'
        end
    end
    # 修改 yay 配置
    yay --aururl 'https://aur.tuna.tsinghua.edu.cn' --save
    # yay 安装 jmtpfs，starship
    yay -S --noconfirm jmtpfs starship
end

# uz 设定
function uz_ud
    # 克隆 uz 仓库
    git clone https://github.com/rraayy246/uz ~/a/uz --depth 1
    # 链接 uz
    ln -s ~/a/uz ~/
    cd ~/a/uz
    # 记忆账号密码
    git config credential.helper store
    git config --global user.email 'rraayy246@gmail.com'
    git config --global user.name 'ray'
    # 默认合并分支
    git config --global pull.rebase false
    cd
end

# 复制设定
function fv_ud
    # 创建目录
    mkdir -p ~/{a/vp/bv,gz,xz,.config/{alacritty,fcitx5,fish/conf.d,i3status-rust,nvim/.backup,sway}}
    sudo mkdir -p /root/.config/{fish,nvim}
    # 缩写
    set pvwj ~/a/uz/pv/
    # fish 设置环境变量
    fish "$pvwj"hjbl.fish
    sudo fish "$pvwj"hjbl.fish
    # 链接配置文件
    sudo ln -f "$pvwj"dns /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    sudo ln -f "$pvwj"fhq /etc/nftables.conf
    sudo ln -f "$pvwj"tlp /etc/tlp.conf
    #sudo ln -f "$pvwj"keyb /etc/X11/xorg.conf.d/00-keyboard.conf
    ln -f "$pvwj"fish.fish ~/.config/fish/config.fish
    ln -f "$pvwj"sway ~/.config/sway/config
    #ln -f "$pvwj"i3 ~/.config/i3/config
    ln -f "$pvwj"urf ~/.config/fcitx5/profile
    ln -f "$pvwj"vtl.toml ~/.config/i3status-rust/config.toml
    ln -f "$pvwj"vd.yml ~/.config/alacritty/alacritty.yml
    ln -f "$pvwj"vim.vim ~/.config/nvim/init.vim
    sudo cp -f "$pvwj"vim.vim /root/.config/nvim/init.vim
end

# 写入设定
function xr_ud
    # 主机表
    sudo sed -i '/localhost\|localdomain/d' /etc/hosts
    echo -e '127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t'$hostname'.localdomain '$hostname | sudo tee -a /etc/hosts
    # sudo 免密码
    if not sudo grep -q '^[^#].*NOPASSWD:' /etc/sudoers
        sudo sed -i 's/(ALL) ALL/(ALL) NOPASSWD: ALL/g' /etc/sudoers
    end
    # grub 超时
    sudo sed -i '/set timeout=5/s/5/1/g' /boot/grub/grub.cfg
    # dns
    echo -e 'nameserver 127.0.0.1\noptions edns0 single-request-reopen' | sudo tee /etc/resolv.conf
    sudo chattr +i /etc/resolv.conf

    # 更改默认 shell 为 fish
    sudo sed -i '/home/s/bash/fish/' /etc/passwd
    sudo sed -i '/root/s/bash/fish/' /etc/passwd
    rm ~/.bash*
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O ~/.config/fish/conf.d/z.lua
    echo 'source (lua ~/.config/fish/conf.d/z.lua --init fish | psub)' > ~/.config/fish/conf.d/z.fish
    # 提示符
    echo -e 'if status is-interactive\n    starship init fish | source\nend' | sudo tee /root/.config/fish/config.fish
    # xinit
    #echo 'exec i3' > ~/.xinitrc
    # 壁纸
    wget -nv https://github.com/rraayy246/uz/raw/master/pv/hw.png -O ~/a/vp/bv/hw.png

    # 根用户 nvim 注释 plug 配置
    sudo sed -i '/^call plug#begin/,$s/^[^"]/"&/' /root/.config/nvim/init.vim
    # 安装 vim-plug
    curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # 插件下载
    nvim +PlugInstall +qall
end

# 安装小鹤音形
# http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
function xhyx_av
    cd
    # 解压配置包
    7z x ~/a/uz/pv/flypy.7z
    mkdir -p ~/.local/share/fcitx5
    cp -rf ~/rime ~/.local/share/fcitx5
    rm -rf ~/rime
    # 重新加载 fcitx 配置
    fcitx5-remote -r
end

# 自启动
function zqd_ud
    sudo systemctl enable --now NetworkManager ;
    and sudo systemctl disable dhcpcd
    sudo systemctl enable --now {bluetooth,dnscrypt-proxy,NetworkManager-dispatcher,nftables,ntpd,paccache.timer,pkgstats.timer,tlp} ;
    sudo systemctl mask {systemd-resolved,systemd-rfkill.service,systemd-rfkill.socket}
end


# ======= 主程序 =======

yh_ud
switch $argv[1]
case a
    rj_av
case p
    fv_ud
    xr_ud
case u
    uz_ud
case '*'
    rj_ud
    rj_av
    uz_ud
    fv_ud
    xr_ud
    xhyx_av
    zqd_ud
end


