#!/data/data/com.termux/files/usr/bin/fish

# 连接内部存储。
termux-setup-storage

# 更换源
function rj_ud
    sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list

    sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list

    sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list

    pkg update
end

# 安装软件
function rj_av
    pkg install -y curl fish git lua54 man neovim openssh starship tree wget zsh
end

# uz 设定
function uz_ud
    # 克隆 uz 仓库
    git clone https://github.com/rraayy246/uz ~/storage/shared/a/uz --depth 1
    # 链接 uz
    ln -s ~/storage/shared/a/uz ~/uz
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
    # 创建文件夹
    mkdir -p ~/.config/{fish/conf.d,nvim/.backup}
    mkdir ~/storage/shared/a
    # 缩写
    set pvwj ~/storage/shared/a/uz/pv/
    # fish 设置环境变量
    fish "$pvwj"hjbl.fish
    # 链接配置文件
    cp -f "$pvwj"vim.vim ~/.config/nvim/init.vim
end

# 写入设定
function xr_ud
    # 设 fish 为默认 shell
    chsh -s fish
    rm ~/.bash*
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O ~/.config/fish/conf.d/z.lua
    echo 'source (lua5.4 ~/.config/fish/conf.d/z.lua --init fish | psub)' > ~/.config/fish/conf.d/z.fish
    # 提示符
    echo -e 'if status is-interactive\n    starship init fish | source\nend' > ~/.config/fish/config.fish

    # nvim 注释 plug 配置
    sed -i '/^call plug#begin/,$s/^[^"]/"&/' ~/.config/nvim/init.vim
    # 下载 Ubuntu 字体
    curl -fsLo ~/.termux/font.ttf --create-dirs https://github.com/powerline/fonts/raw/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf
end


# ======= 主程序 =======

switch $argv[1]
case a
    rj_av
case p
    fv_ud
    xr_ud
case u
    uz_ud
case '*'
    rj_av
    uz_ud
    fv_ud
    xr_ud
    termux-reload-settings
    echo "完成！请重启Termux。"
end

