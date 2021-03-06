#!/usr/bin/env fish

# root 用户不建议使用此脚本
function yh_g
    if test $USER = 'root'
        echo '请先退出root用户，并登陆新创建的用户。'
        exit 1
    end
end

# 判断显卡驱动
function xk_pd
    if test -n (lspci -vnn | grep -i 'vga.*amd.*radeon')
        set gpu xf86-video-amdgpu
    else if test -n (lspci -vnn | grep -i 'vga.*nvidia.*geforce')
        set gpu xf86-video-nouveau
    end
end

# 修改 pacman 配置
function pac_pv
    # pacman 增加 multilib 源
    #sudo sed -i '/^#\[multilib\]/,+1s/^#//g' /etc/pacman.conf
    # pacman 开启颜色
    sudo sed -i '/^#Color$/s/#//' /etc/pacman.conf
    # 加上 archlinuxcn 源
    if test -z (grep 'archlinuxcn' /etc/pacman.conf)
        echo -e '[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch' | sudo tee -a /etc/pacman.conf
        # 导入 GPG key
        sudo pacman -Syy --noconfirm archlinuxcn-keyring
    end
end

# pacman 安装软件
function pac_av
    # 更新系统并安装 btrfs 管理，网络管理器，tlp
    echo -e '\n' | sudo pacman -Syu btrfs-progs networkmanager tlp tlp-rdw
    # 缩写
    set pacn sudo pacman -S --noconfirm
    # 声卡，触摸板，显卡驱动
    $pacn alsa-utils pulseaudio-alsa xf86-input-libinput $gpu
    # 繁简中日韩，emoji，Ubuntu字体
    $pacn noto-fonts-cjk noto-fonts-emoji ttf-ubuntu-font-family ttf-font-awesome
    # 小企鹅输入法
    $pacn fcitx5-im fcitx5-rime
    # 显示服务器，sway
    $pacn wayland sway swaybg swayidle swaylock i3status-rust xorg-xwayland
    # 终端，软件启动器，qt5
    $pacn alacritty wofi qt5-wayland
    # 播放控制，亮度控制，电源工具
    $pacn playerctl brightnessctl upower lm_sensors
    # 网络工具
    $pacn curl firefox firefox-i18n-zh-cn git wget yay
    # 必要工具
    $pacn fish neovim nnn p7zip zsh
    # 模糊搜索，图片
    $pacn fzf imv pkgstats nftables dnscrypt-proxy
    # mtp，蓝牙
    $pacn libmtp pulseaudio-bluetooth bluez-utils
    # 其他工具
    $pacn libreoffice-fresh-zh-cn tree vlc vim
    # 编程语言
    $pacn bash-language-server clang lua nodejs rust yarn
    # steam
    #$pacn gamemode ttf-liberation wqy-microhei wqy-zenhei steam
end

# 修改 yay 配置
function yay_pv
    yay --aururl 'https://aur.tuna.tsinghua.edu.cn' --save
end

# yay 安装软件
function yay_av
    # 安装 jmtpfs，starship
    yay -S --noconfirm jmtpfs starship
end

# 安装软件
function rj_av
    xk_pd
    pac_pv
    pac_av
    yay_pv
    yay_av
end

# 设置 fish
function zsh_uv
    mkdir -p ~/.config/fish/conf.d
    # 更改默认 shell 为 fish
    sudo sed -i '/home/s/bash/fish/' /etc/passwd
    sudo sed -i '/root/s/bash/fish/' /etc/passwd
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O ~/.config/fish/conf.d/z.lua
    echo 'source (lua ~/.config/fish/conf.d/z.lua --init fish | psub)' > ~/.config/fish/conf.d/z.fish
end

# 下载配置文件
function pvwj_xz
    # 创建目录
    mkdir -p ~/{a/vp/bv,gz,xz,.config/{alacritty,fcitx5,fish,i3status-rust,nvim/.backup,sway}}
    # 壁纸
    wget -nv https://github.com/rraayy246/uz/raw/master/pv/hw.png -O ~/a/vp/bv/hw.png
    # 克隆 uz 仓库
    git clone https://github.com/rraayy246/uz ~/a/uz --depth 1
    set pvwj ~/a/uz/pv/
    # fish 设置环境变量
    fish {$pvwj}hjbl.fish
    # dns
    echo -e 'nameserver 127.0.0.1\noptions edns0 single-request-reopen' | sudo tee /etc/resolv.conf
    sudo chattr +i /etc/resolv.conf
    # 链接配置文件
    sudo ln -f {$pvwj}dns /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    sudo ln -f {$pvwj}fhq /etc/nftables.conf
    sudo ln -f {$pvwj}grub /etc/default/grub
    sudo ln -f {$pvwj}tlp /etc/tlp.conf
    ln -f {$pvwj}fish.fish ~/.config/fish/config.fish
    ln -f {$pvwj}sway ~/.config/sway/config
    ln -f {$pvwj}urf ~/.config/fcitx5/profile
    ln -f {$pvwj}vtl.toml ~/.config/i3status-rust/config.toml
    ln -f {$pvwj}vd.yml ~/.config/alacritty/alacritty.yml
    ln -f {$pvwj}vim.vim ~/.config/nvim/init.vim
end

# 安装小鹤音形
# http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
function xhyx_av
    cd
    # 解压配置包
    7z x {$pvwj}flypy.7z
    mkdir -p ~/.local/share/fcitx5
    mv -f ~/rime ~/.local/share/fcitx5
    # 重新加载 fcitx 配置
    fcitx5-remote -r
end

# 自启动管理
function zqd_gl
    sudo systemctl enable --now {bluetooth,dnscrypt-proxy,NetworkManager,NetworkManager-dispatcher,nftables,tlp}
    sudo systemctl disable dhcpcd
    sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}
end

# 创建交换文件
function jhwj_ij
    sudo touch /swap # 创建空白文件
    sudo chattr +C /swap # 修改档案属性 不执行写入时复制（COW）
    sudo fallocate -l 4G /swap # 创建4G空洞文件
    sudo chmod 600 /swap # 修改文件读写执行权限
    sudo mkswap /swap # 格式化交换文件
    sudo swapon /swap # 启用交换文件
end

# 挂载交换文件
function jhwj_gz
    echo '/swap swap swap defaults 0 0' | sudo tee -a /etc/fstab
    # 最大限度使用物理内存；生效
    echo 'vm.swappiness = 1' | sudo tee /etc/sysctl.conf
    # 更新 sysctl 配置
    sudo sysctl -p
end

### 设置内核参数
function nhcu_uv
    # 设置 resume 参数
    sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/resume=\/dev\/\w*/resume=\/dev\/'(lsblk -l | awk '{ if($7=='/'){print $1} }')'/' /etc/default/grub
    # 下载 btrfs_map_physical 工具
    wget -nv 'https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c' -P ~
    # 编译 btrfs_map_physical 工具
    gcc -O2 -o ~/btrfs_map_physical ~/btrfs_map_physical.c
    # 使用 btrfs_map_physical 提取 resume_offset 值
    set offset (sudo ~/btrfs_map_physical /swap | awk '{ if($1=='0'){print $9} }')
    # 设置 resume_offset 参数
    sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/resume_offset=[0-9]*/resume_offset='(math $offset/4096)'/' /etc/default/grub
    # 删除 btrfs_map_physical 工具
    rm ~/btrfs_map_physical*
    # 更新 grub 配置
    sudo grub-mkconfig -o /boot/grub/grub.cfg
end

# 设置 resume 钩子
function gz_uv
    sudo sed -i '/^HOOKS/s/udev/& resume/' /etc/mkinitcpio.conf
    # 重新生成 initramfs 镜像
    sudo mkinitcpio -P
end

# 建立交换文件
function jhwj_jl
    if test ! -e '/swap'
        jhwj_ij
        jhwj_gz
        nhcu_uv
        gz_uv
    end
end

# 设置 vim
function vim_uv
    # 安装 vim-plug
    sh -c 'curl -fLo '${XDG_DATA_HOME:-$HOME/.local/share}'/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    # 插件下载
    nvim +PlugInstall +qall
end

# uz 设置。
function uz_uv
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

# 文字提醒
function wztx
    echo -e '\n请手动执行 sensors-detect 生成内核模块列表。'
end

# ======= 主程序 =======

yh_g
switch $argv
case a
    pac_av
case p
    pvwj_xz
case u
    uz_uv
case '*'
    rj_av
    zsh_uv
    pvwj_xz
    xhyx_av
    zqd_gl
    jhwj_jl
    vim_uv
    wztx
end

