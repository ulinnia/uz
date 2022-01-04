#!/data/data/com.termux/files/usr/bin/fish

function main
    switch $argv[1]
        case a
            install_pkg
        case p
            copy_config
            write_config
        case u
            set_uz_repo
        case '*'
            install_pkg
            set_uz_repo
            copy_config
            write_config
            termux-reload-settings
            echo '完成！请重启 Termux。'
    end
end

# 连接内部存储。
termux-setup-storage

# 更换源
function change_source
    sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list

    sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list

    sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list

    pkg update
end

# 安装软件
function install_pkg
    pkg install -y curl fish git lua54 man neovim openssh rsync starship tree wget zsh
end

# uz 设定
function set_uz_repo
    # 克隆 uz 仓库
    git clone --depth 1 https://github.com/rraayy246/uz $HOME/storage/shared/a/uz
    # 链接 uz
    ln -s $HOME/storage/shared/a/uz $HOME
    cd $HOME/uz
    # 记忆账号密码
    git config credential.helper store
    git config --global user.email 'rraayy246@gmail.com'
    git config --global user.name 'ray'
    # 默认合并分支
    git config --global pull.rebase false
    cd
end

# 复制设定
function copy_config
    set uz_dir $HOME/storage/shared/a/uz

    # 创建文件夹
    mkdir -p $HOME/.config/{fish/conf.d,nvim/.backup}
    # fish 设置环境变量
    fish $uz_dir/pv/hjbl.fish
    # 链接配置文件
    rsync -a $uz_dir/pv/.config $HOME
    sed -i '/^call plug#begin/,$s/^[^"]/"&/' $HOME/.config/nvim/init.vim
end

# 写入设定
function write_config
    # 设 fish 为默认 shell
    chsh -s fish
    # 安装 zlua
    wget -nv https://raw.githubusercontent.com/skywind3000/z.lua/master/z.lua -O $HOME/.config/fish/conf.d/z.lua
    echo 'source (lua5.4 $HOME/.config/fish/conf.d/z.lua --init fish | psub)' > $HOME/.config/fish/conf.d/z.fish
    # 提示符
    echo -e 'if status is-interactive\n\tstarship init fish | source\nend' > $HOME/.config/fish/config.fish

    # 下载 Ubuntu 字体
    curl -fsLo $HOME/.termux/font.ttf --create-dirs https://github.com/powerline/fonts/raw/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf
end

main $argv

