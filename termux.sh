#!/data/data/com.termux/files/usr/bin/bash

# 连接内部存储。
termux-setup-storage

# 安装软件
pkg install -y curl git man neovim tree wget zsh

# 安装 oh-my-zsh。
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh --depth 1

# ======= 配置文件 =======
# 用变数代替我的 github 仓库网址
link=https://raw.githubusercontent.com/rraayy246/UZ/master/
# 下载配置文件
mkdir -p ~/.config/nvim
wget -nv -x ${link}P/vim.vim -O ~/.config/nvim/init.vim
wget -nv ${link}P/zshrc -O ~/.zshrc

# 设 zsh 为默认 shell
chsh -s zsh

# 软连接 aidn。
if [ -e "~/storage/shared/A/B/aidn" ]; then ln -s ~/storage/shared/A/Y/aidn ~/aidn; fi
#安装Ubuntu字体。
curl -fsLo ~/.termux/font.ttf --create-dirs https://github.com/powerline/fonts/raw/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf

# 应用设定。
termux-reload-settings

echo "完成！请重启Termux。"

exit
