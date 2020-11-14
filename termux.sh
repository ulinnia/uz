#!/data/data/com.termux/files/usr/bin/bash

#连接内部存储。
termux-setup-storage

# ======= 安装 Arch 系统 =======
pkg install proot git bsdtar
cd ~
git clone https://github.com/sdrausty/TermuxArch
bash TermuxArch/setupTermuxArch.sh
vi /etc/pacman.d/mirrorlist
pacman -Syy
pacman -S jdk8-openjdk

pacman -S curl man nvim tree wget zsh

#安装oh-my-zsh。
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh --depth 1 #浅克隆
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
#换成amuse主题。
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="amuse"/' ~/.zshrc
#开启zsh自动更新。
if [ "$(grep "DISABLE_UPDATE_PROMPT=true" ~/.zshrc)" == "" ]; then
 echo "DISABLE_UPDATE_PROMPT=true" >> "~/.zshrc"
fi

#安装zsh语法高亮。
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-syntax-highlighting --depth 1
if [ "$(grep "source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ~/.zshrc)" == "" ]; then
 echo "source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "~/.zshrc"
fi

#设zsh为默认shell
chsh -s zsh

#vim设定：显示行号，语法高亮，大小写混搜。

#软连接aidn。
if [ -e "~/storage/shared/A/Y/aidn" ]; then ln -s ~/storage/shared/A/Y/aidn ~/aidn; fi
#安装Ubuntu字体。
curl -fsLo ~/.termux/font.ttf --create-dirs https://github.com/powerline/fonts/raw/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf

#应用设定。
termux-reload-settings

echo "完成！请重启Termux。"

exit
