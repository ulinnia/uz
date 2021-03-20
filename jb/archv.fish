#!/usr/bin/env fish

# root 用户不建议使用此脚本
function yh_ud --description 'root 用户退出'
    if test "$USER" = 'root'
        echo '请先退出root用户，并登陆新创建的用户。'
        exit 1
    end
end

# 修改 pacman 配置
function pac_ud
    # pacman 增加 multilib 源
    sudo sed -i '/^#\[multilib\]/,+1s/^#//g' /etc/pacman.conf
    # pacman 开启颜色
    sudo sed -i '/^#Color$/s/#//' /etc/pacman.conf
    # 加上 archlinuxcn 源
    if not string match -q '*archlinuxcn*' < /etc/pacman.conf
        echo -e '[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' | sudo tee -a /etc/pacman.conf
        # 导入 GPG key
        sudo pacman -Syy --noconfirm archlinuxcn-keyring
    end
end

# 安装软件
function pac_av
    sudo pacman -Syu --noconfirm
    set pacn sudo pacman -S --noconfirm
    $pacn btrfs-progs neovim nnn ntp openssh wireguard-tools
    $pacn git wget yay
    $pacn fzf pkgstats nftables dnscrypt-proxy
    $pacn tree lua

    yay -S kmscon starship
end

# 设置 fish
function fish_ud
    mkdir -p ~/.config/fish/conf.d
    # 更改默认 shell 为 fish
    sudo sed -i '/home/s/bash/fish/' /etc/passwd
    sudo sed -i '/root/s/bash/fish/' /etc/passwd
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O ~/.config/fish/conf.d/z.lua
    echo 'source (lua ~/.config/fish/conf.d/z.lua --init fish | psub)' > ~/.config/fish/conf.d/z.fish
end

fuction zqd_ud
    ln -s /usr/lib/systemd/system/kmsconvt\@.service /etc/systemd/system/autovt\@.service
end

sudo sed -i '/set timeout=5/s/5/0/g' /boot/grub/grub.cfg


