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
    # 更新系统
    sudo pacman -Syu --noconfirm
    # 缩写
    set pacn sudo pacman -S --noconfirm
    # 软件
    $pacn btrfs-progs neovim nnn ntp openssh wireguard-tools
    $pacn git wget yay
    $pacn fzf pkgstats nftables dnscrypt-proxy
    $pacn tree lua zsh
    $pacn ttf-dejavu wqy-microhei
    # yay
    yay -S kmscon starship
end

# 配置文件
function pvwj_ud
    # 创建目录
    mkdir -p ~/{a,xz,.config/{fish/conf.d,nvim/.backup}}
    # 提示符
    echo -e 'if status is-interactive\n    starship init fish | source\nend' > ~/.config/fish/config.fish
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O ~/.config/fish/conf.d/z.lua
    echo 'source (lua ~/.config/fish/conf.d/z.lua --init fish | psub)' > ~/.config/fish/conf.d/z.fish
    # 更改默认 shell 为 fish
    sudo sed -i '/home/s/bash/fish/' /etc/passwd
    sudo sed -i '/root/s/bash/fish/' /etc/passwd
    # ssh
    sudo sed -i '/#Port 22/s/#//' /etc/ssh/sshd_config
    # dns
    echo -e 'nameserver 127.0.0.1\noptions edns0 single-request-reopen' | sudo tee /etc/resolv.conf
    sudo chattr +i /etc/resolv.conf
    # grub 超时
    sudo sed -i '/set timeout=5/s/5/0/g' /boot/grub/grub.cfg
    # 克隆 uz 仓库
    git clone https://github.com/rraayy246/uz ~/a/uz --depth 1
    # 缩写
    set pvwj ~/a/uz/pv/
    # fish 设置环境变量
    fish {$pvwj}hjbl.fish
    # 链接配置文件
    cp -f {$pvwj}vim.vim ~/.config/nvim/init.vim
    sudo ln -f {$pvwj}dns /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    sudo ln -f {$pvwj}fhq /etc/nftables.conf
    sudo ln -f {$pvwj}zt.conf /etc/fonts/conf.d/99-kmscon.conf
    # nvim 注释 plug 配置
    sed -i '/^call plug#begin/,$s/^[^"]/"&/' ~/.config/nvim/init.vim
    # sudo 免密码
    if not string match -q '%sudo*NOPASSWD:' < /etc/sudoers
        echo '%sudo ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
    end
end

# 自启动
function zqd_ud
    sudo systemctl enable --now {dnscrypt-proxy,nftables,ntpd,sshd} ;
    sudo systemctl mask {systemd-resolved,systemd-rfkill.service,systemd-rfkill.socket}
    # 更换虚拟终端为 kmscon
    ln -s /usr/lib/systemd/system/kmsconvt\@.service /etc/systemd/system/autovt\@.service
end

# uz 设置。
function uz_ud
    ln -s ~/storage/shared/a/uz ~/uz
    cd ~/uz
    # 默认合并分支
    git config --global pull.rebase false
    cd
end


# ======= 主程序 =======

yh_ud
switch $argv[1]
case a
    pac_av
case p
    pvwj_ud
case '*'
    pac_ud
    pac_av
    pvwj_ud
    zqd_ud
    uz_ud
end


