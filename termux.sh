#!/data/data/com.termux/files/usr/bin/bash

#连接内部存储。
termux-setup-storage

#下载常用软件。
pkg update -y
pkg upgrade -y
pkg install -y man vim curl wget git tree zsh

#安装oh-my-zsh。
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh --depth 1 #浅克隆
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
#换成amuse主题。
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="amuse"/' ~/.zshrc
#开启zsh自动更新。
echo "DISABLE_UPDATE_PROMPT=true" >> "~/.zshrc"

#安装zsh语法高亮。
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-syntax-highlighting --depth 1
echo "source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "~/.zshrc"

#设zsh为默认shell
chsh -s zsh

#vim设定：显示行号，语法高亮，大小写混搜。
echo -e "set nu\nsyntax on\nset ignorecase\nset smartcase" > "~/.vimrc"

#软连接aidn。
if [ -e "~/storage/shared/A/Y/aidn" ]; then ln -s ~/storage/shared/A/Y/aidn ~/aidn; fi
#安装Ubuntu字体。
curl -fsLo ~/.termux/font.ttf --create-dirs https://github.com/powerline/fonts/raw/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf

#应用设定。
termux-reload-settings

echo "完成！请重启Termux。"

exit
