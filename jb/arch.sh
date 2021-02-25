#!/usr/bin/env bash

# root 用户不建议使用此脚本
yh_g() {
    if [ "$USER" == "root"  ]; then
        echo "请先退出root用户，并登陆新创建的用户。"
        exit 1
    fi
}

# 判断显卡驱动
xk_pd() {
    if [ "$(lspci -vnn | grep -i "vga.*amd.*radeon")" ]; then
        gpu=xf86-video-amdgpu
    elif [ "$(lspci -vnn | grep -i "vga.*nvidia.*geforce")" ]; then
        gpu=xf86-video-nouveau
    fi
}

# 修改 pacman 配置
pac_pv() {
    # pacman 增加 multilib 源
    #sudo sed -i "/^#\[multilib\]/,+1s/^#//g" /etc/pacman.conf
    # pacman 开启颜色
    sudo sed -i "/^#Color$/s/#//" /etc/pacman.conf
    # 加上 archlinuxcn 源
    if [ ! "$(grep "archlinuxcn" /etc/pacman.conf)" ]; then
        echo -e "[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" | sudo tee -a /etc/pacman.conf
        # 导入 GPG key
        sudo pacman -Syy --noconfirm archlinuxcn-keyring
    fi
}

# pacman 安装软件
pac_av() {
    # 更新系统并安装 btrfs 管理，网络管理器，tlp
    echo -e "\n" | sudo pacman -Syu btrfs-progs networkmanager tlp tlp-rdw
    # 声卡，触摸板，显卡驱动
    sudo pacman -S --noconfirm alsa-utils pulseaudio-alsa xf86-input-libinput ${gpu}
    # 繁简中日韩，emoji，Ubuntu字体
    sudo pacman -S --noconfirm noto-fonts-cjk noto-fonts-emoji ttf-ubuntu-font-family
    # 小企鹅输入法
    sudo pacman -S --noconfirm fcitx5-im fcitx5-rime
    # 显示服务器，sway
    sudo pacman -S --noconfirm wayland sway swaybg swayidle swaylock xorg-server-xwayland
    # 终端，软件启动器，qt5
    sudo pacman -S --noconfirm alacritty dmenu qt5-wayland
    # 播放控制，亮度控制，电源工具
    sudo pacman -S --noconfirm playerctl brightnessctl upower
    # 网络工具
    sudo pacman -S --noconfirm curl firefox firefox-i18n-zh-cn git wget yay
    # 必要工具
    sudo pacman -S --noconfirm fish neovim nnn p7zip zsh
    # 模糊搜索，图片
    sudo pacman -S --noconfirm fzf imv
    # mtp，蓝牙
    sudo pacman -S --noconfirm libmtp pulseaudio-bluetooth bluez-utils
    # 其他工具
    sudo pacman -S --noconfirm libreoffice-zh-CN tree vlc vim
    # 编程语言
    sudo pacman -S --noconfirm bash-language-server clang lua nodejs rust yarn
    # steam
    #sudo pacman -S --noconfirm gamemode ttf-liberation wqy-microhei wqy-zenhei steam
}

# 修改 yay 配置
yay_pv() {
    yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
}

# yay 安装软件
yay_av() {
    # 安装 ohmyzsh、jmtpfs
    yay -S --noconfirm jmtpfs
}

# 安装软件
rj_av() {
    xk_pd
    pac_pv
    pac_av
    yay_pv
    yay_av
}

# 设置 fish
zsh_uv() {
    mkdir -p ~/.config/fish/conf.d
    # 更改默认 shell 为 fish
    sudo sed -i '/home/s/bash/fish/' /etc/passwd
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O ~/.config/fish/conf.d/z.lua
    echo "source (lua ~/.config/fish/conf.d/z.lua --init fish | psub)" > ~/.config/fish/conf.d/z.fish

    fish_hjbl
}

# fish 设置环境变量
fish_hjbl() {

    fish -c "
        # 移除欢迎语
        set -U fish_greeting \"\"

        # 语言设置
        set -Ux LANG zh_CN.UTF-8
        set -Ux LANGUAGE zh_CN:en_US
        set -Ux LC_CTYPE en_US.UTF-8

        # 设定输入法
        set -Ux GTK_IM_MODULE fcitx
        set -Ux QT_IM_MODULE fcitx
        set -Ux XMODIFIERS @im=fcitx
        set -Ux SDL_IM_MODULE fcitx

        # nnn 书签，选择，插件，缓存
        set -Ux NNN_BMS 'a:~/a;x:~/xz;j:~;g:~/gz'
        set -Ux NNN_SEL '/tmp/.sel'
        set -Ux NNN_PLUG ''
        set -Ux NNN_FIFO '/tmp/nnn.fifo'

        # 默认编辑器
        set -Ux EDITOR nvim

        # 控制键替换大写锁定键
        set -Ux XKB_DEFAULT_OPTIONS ctrl:nocaps

        # git 控制
        abbr -a -U g git
        abbr -a -U ga 'git add'
        abbr -a -U gaa 'git add --all'
        abbr -a -U gb 'git branch'
        abbr -a -U gba 'git branch -a'
        abbr -a -U gcmsg 'git commit -m'
        abbr -a -U gd 'git diff'
        abbr -a -U gl 'git pull'
        abbr -a -U gp 'git push'
        abbr -a -U grh 'git reset --hard'
        abbr -a -U grs 'git reset --soft'
        abbr -a -U gst 'git status'

        # 其他
        abbr -a -U 1 'cd -'
        abbr -a -U fu 'fusermount -u ~/gz'
        abbr -a -U la 'ls -a'
        abbr -a -U nm 'nmtui-connect'
        abbr -a -U nn 'nnn'
        abbr -a -U gx 'sudo pacman -Syu'
        abbr -a -U svi 'sudo nvim'
        abbr -a -U uz 'cd ~/uz'
        abbr -a -U vi 'nvim'

        # fish 提示符
        set -U __fish_git_prompt_show_informative_status 1
        set -U __fish_git_prompt_hide_untrackedfiles 1

        set -U __fish_git_prompt_color_branch magenta --bold
        set -U __fish_git_prompt_showupstream \"informative\"
        set -U __fish_git_prompt_char_upstream_ahead \"↑\"
        set -U __fish_git_prompt_char_upstream_behind \"↓\"
        set -U __fish_git_prompt_char_upstream_prefix \"\"

        set -U __fish_git_prompt_char_stagedstate \"+\"
        set -U __fish_git_prompt_char_dirtystate \"*\"
        set -U __fish_git_prompt_char_untrackedfiles \"…\"
        set -U __fish_git_prompt_char_conflictedstate \"\#\"
        set -U __fish_git_prompt_char_cleanstate \"√\"

        set -U __fish_git_prompt_color_dirtystate blue
        set -U __fish_git_prompt_color_stagedstate yellow
        set -U __fish_git_prompt_color_invalidstate red
        set -U __fish_git_prompt_color_untrackedfiles $fish_color_normal
        set -U __fish_git_prompt_color_cleanstate green --bold
    "
}

# 下载配置文件
pvwj_xz() {
    # 创建目录
    mkdir -p ~/{a,gz,xz,.config/{alacritty,fcitx5,fish,nvim/.backup,sway}}
    # 克隆 uz 仓库
    git clone https://github.com/rraayy246/uz ~/a/uz --depth 1
    # 链接配置文件
    pvwj=~/a/uz/pv/
    sudo ln -f ${pvwj}grub /etc/default/grub
    sudo ln -f ${pvwj}tlp /etc/tlp.conf
    ln -f ${pvwj}fish.fish ~/.config/fish/config.fish
    ln -f ${pvwj}sway ~/.config/sway/config
    ln -f ${pvwj}vtl.sh ~/.config/sway/vtl.sh
    ln -f ${pvwj}vsdr.yml ~/.config/alacritty/alacritty.yml
    ln -f ${pvwj}vim.vim ~/.config/nvim/init.vim
}

# 安装小鹤音形
# http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
xhyx_av() {
    cd
    # 解压配置包
    7z x ${pvwj}flypy.7z
    mkdir -p ~/.local/share/fcitx5
    mv -f ~/rime ~/.local/share/fcitx5
    # 重新加载 fcitx 配置
    fcitx5-remote -r
}

# 自启动管理
zqd_gl() {
    sudo systemctl enable --now {bluetooth,NetworkManager,NetworkManager-dispatcher,tlp}
    sudo systemctl disable dhcpcd
    sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}
}

# 创建交换文件
jhwj_ij() {
    sudo touch /swap # 创建空白文件
    sudo chattr +C /swap # 修改档案属性 不执行写入时复制（COW）
    sudo fallocate -l 4G /swap # 创建4G空洞文件
    sudo chmod 600 /swap # 修改文件读写执行权限
    sudo mkswap /swap # 格式化交换文件
    sudo swapon /swap # 启用交换文件
}

# 挂载交换文件
jhwj_gz() {
    echo "/swap swap swap defaults 0 0" | sudo tee -a /etc/fstab
    # 最大限度使用物理内存；生效
    echo "vm.swappiness = 1" | sudo tee /etc/sysctl.conf
    # 更新 sysctl 配置
    sudo sysctl -p
}

# 设置内核参数
nhcu_uv() {
    # 设置 resume 参数
    sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT/s/resume=\/dev\/\w*/resume=\/dev\/$(lsblk -l | awk '{ if($7=="/"){print $1} }')/" /etc/default/grub
    # 下载 btrfs_map_physical 工具
    wget -nv "https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c" -P ~
    # 编译 btrfs_map_physical 工具
    gcc -O2 -o ~/btrfs_map_physical ~/btrfs_map_physical.c
    # 使用 btrfs_map_physical 提取 resume_offset 值
    offset=$(sudo ~/btrfs_map_physical /swap | awk '{ if($1=="0"){print $9} }')
    # 设置 resume_offset 参数
    sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT/s/resume_offset=[0-9]*/resume_offset=$((offset/4096))/" /etc/default/grub
    # 删除 btrfs_map_physical 工具
    rm ~/btrfs_map_physical*
    # 更新 grub 配置
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

# 设置 resume 钩子
gz_uv() {
    sudo sed -i "/^HOOKS/s/udev/& resume/" /etc/mkinitcpio.conf
    # 重新生成 initramfs 镜像
    sudo mkinitcpio -P
}

# 建立交换文件
jhwj_jl() {
    if [ ! -e "/swap" ]; then
        jhwj_ij
        jhwj_gz
        nhcu_uv
        gz_uv
    fi
}

# 设置 vim
vim_uv() {
    # 安装 vim-plug
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    # 插件下载
    nvim +PlugInstall +qall
}

# uz 设置。
uz_uv() {
    if [ -d "$HOME/a/up/xt" ]; then
        ln -s ~/a/uz ~/
        cd ~/a/uz
        # 记忆账号密码
        git config credential.helper store
        git config --global user.email "rraayy246@gmail.com"
        git config --global user.name "ray"
        # 默认合并分支
        git config --global pull.rebase false
        cd
    fi
}

# 文字提醒
wztx() {
    echo -e "\n请手动执行 fcitx5-configtool 修改输入法。"
}

# ======= 主程序 =======

yh_g
case $1 in
    a)
        pac_av
        ;;
    h)
        fish_hjbl
        ;;
    *)
        rj_av
        zsh_uv
        pvwj_xz
        xhyx_av
        zqd_gl
        jhwj_jl
        vim_uv
        uz_uv
        wztx
        ;;
esac

