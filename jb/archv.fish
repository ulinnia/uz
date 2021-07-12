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
        echo -e '[archlinuxcn]\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' | sudo tee -a /etc/pacman.conf
        # 导入 GPG key
        sudo pacman -Syy --noconfirm archlinuxcn-keyring
    end
end

# 安装软件
function rj_av
    # 更新系统
    sudo pacman -Syu --noconfirm
    # 缩写
    set pacn sudo pacman -S --noconfirm
    # btrfs 管理
    $pacn btrfs-progs

    # 互联网
        # 网络连接
        $pacn curl git wget

    # 工具
        # 终端
        $pacn fcron fish neovim nnn
        # 查找
        $pacn fzf htop tree
        # 新查找
        $pacn fd ripgrep bat tldr exa
        # 缓存，统计，兼容
        $pacn pacman-contrib pkgstats vim zsh

    # 安全
        # 网络安全
        $pacn dnscrypt-proxy nftables ntp openssh wireguard-tools

    # 科学
        # 编程语言
        $pacn lua

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
    # yay 安装 kmscon，starship
    yay -S --noconfirm kmscon starship
end

# uz 设定
function uz_ud
    # 克隆 uz 仓库
    git clone https://github.com/rraayy246/uz ~/a/uz --depth 1
    # 链接 uz
    ln -s ~/a/uz ~/
    cd ~/uz
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
    mkdir -p ~/{a,xz,.config/{fish/conf.d,nvim/.backup}}
    # 缩写
    set pvwj ~/a/uz/pv/
    # fish 设置环境变量
    fish "$pvwj"hjbl.fish
    # 链接配置文件
    sudo ln -f "$pvwj"dns /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    sudo ln -f "$pvwj"fhq /etc/nftables.conf
    cp -f "$pvwj"vim.vim ~/.config/nvim/init.vim
end

# 写入设定
function xr_ud
    # 主机表
    sudo sed -i '/localhost\|localdomain/d' /etc/hosts
    set ipp (ip addr show | grep -o 'inet .*/24' | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]')
    echo -e $ipp'\tlocalhost\n::1\t\tlocalhost\n'$ipp'\t'$hostname'.localdomain '$hostname | sudo tee -a /etc/hosts
    # sudo 免密码
    if not sudo grep -q '^[^#].*NOPASSWD:' /etc/sudoers
        sudo sed -i 's/(ALL) ALL/(ALL) NOPASSWD: ALL/g' /etc/sudoers
    end
    # grub 超时
    sudo sed -i '/set timeout=5/s/5/0/g' /boot/grub/grub.cfg
    # dns
    echo -e 'nameserver 127.0.0.1\noptions edns0 single-request-reopen' | sudo tee /etc/resolv.conf
    sudo chattr +i /etc/resolv.conf
    # ssh
    sudo sed -i '/#Port 22/s/#//' /etc/ssh/sshd_config

    # 更改默认 shell 为 fish
    sudo sed -i '/home/s/bash/fish/' /etc/passwd
    sudo sed -i '/root/s/bash/fish/' /etc/passwd
    rm ~/.bash*
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O ~/.config/fish/conf.d/z.lua
    echo 'source (lua ~/.config/fish/conf.d/z.lua --init fish | psub)' > ~/.config/fish/conf.d/z.fish
    # 提示符
    echo -e 'if status is-interactive\n    starship init fish | source\nend' > ~/.config/fish/config.fish

    # nvim 注释 plug 配置
    sed -i '/^call plug#begin/,$s/^[^"]/"&/' ~/.config/nvim/init.vim
end

# 自启动
function zqd_ud
    sudo systemctl enable --now {dnscrypt-proxy,fcron,nftables,ntpd,paccache.timer,pkgstats.timer,sshd}
    sudo systemctl mask {systemd-resolved,systemd-rfkill.service,systemd-rfkill.socket}
    fcrontab ~/a/uz/pv/cron
end

# 交换文件
function jhwj_ud
    if not test -e /swap/swap
        # 创建子卷
        sudo btrfs subvolume create /swap
        # 创建空文件
        sudo touch /swap/swap
        # 禁止写时复制
        sudo chattr +C /swap/swap
        # 禁止压缩
        sudo chattr -c /swap/swap
        # 文件大小
        sudo fallocate -l 512M /swap/swap
        # 设定拥有者读写
        sudo chmod 600 /swap/swap
        # 格式化交换文件
        sudo mkswap /swap/swap
        # 启用交换文件
        sudo swapon /swap/swap
        # 写入 fstab
        if not sudo grep -q '/swap/swap' /etc/fstab
            echo '/swap/swap none swap defaults 0 0' | sudo tee -a /etc/fstab
        end

        # 最大限度使用物理内存，生效
        if not sudo grep -q 'swappiness' /etc/sysctl.conf
            echo 'vm.swappiness = 0' | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
        end
    end
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
    zqd_ud
    jhwj_ud
end

