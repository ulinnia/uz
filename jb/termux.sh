#!/data/data/com.termux/files/usr/bin/bash

# 连接内部存储。
nbci_lj() {
    termux-setup-storage
}

# 更换源
y_gh() {
    sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list

    sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list

    sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list

    pkg update
}

# 安装软件
rj_av() {
#   y_gh
    pkg install -y curl fish git lua54 man neovim nnn tree wget
}

# 下载配置文件
pvwj_xz() {
    # 创建文件夹
    mkdir -p ~/.config/nvim/.backup
    mkdir ~/storage/shared/a
    # 克隆 uz 仓库
    git clone https://github.com/rraayy246/uz ~/storage/shared/a/uz --depth 1
    # 链接配置文件
    pvwj=~/storage/shared/a/uz/pv/
    cp ${pvwj}vim.vim ~/.config/nvim/init.vim
    ln -fs ${pvwj}fish.fish ~/.config/fish/config.fish
    # 下载 Ubuntu 字体
    curl -fsLo ~/.termux/font.ttf --create-dirs https://github.com/powerline/fonts/raw/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf
}

# 设置 fish
zsh_uv() {
    # 设 fish 为默认 shell
    chsh -s fish
    # 安装 zlua
    mkdir -p ~/.config/fish/conf.d
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O ~/.config/fish/conf.d/z.lua
    echo "source (lua5.4 ~/.config/fish/conf.d/z.lua --init fish | psub)" > ~/.config/fish/conf.d/z.fish

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
    "
}

# 设置 vim
vim_uv() {
    # nvim 注释 plug 配置
    sed -i '/^call plug#begin/,$s/^[^"]/"&/' ~/.config/nvim/init.vim
}

# uz 设置。
uz_uv() {
    if [ -d "$HOME/storage/shared/a/up/xt" ]; then
        ln -s ~/storage/shared/a/uz ~/uz
        cd ~/uz
        # 记忆账号密码
        git config credential.helper store
        git config --global user.email "rraayy246@gmail.com"
        git config --global user.name "ray"
        # 默认合并分支
        git config --global pull.rebase false
        cd
    fi
}

# 应用设定。
ud_yy() {
    termux-reload-settings
}

# 文字提醒
wztx() {
    echo "完成！请重启Termux。"
    exit
}

# ======= 主程序 =======
vix_yx() {
    nbci_lj
    rj_av
    pvwj_xz
    zsh_uv
    vim_uv
    uz_uv
    ud_yy
    wztx
}

vix_yx
