#!/usr/bin/env bash

if [ "$USER" == "root"  ]; then
 echo "请先退出root用户，并登陆新创建的用户。"
 exit 1
fi

#更新系统并安装声卡、显卡、触摸板驱动
sudo pacman -Syu alsa-utils pulseaudio-alsa xf86-input-libinput fcitx-config
sudo pacman -S noto-fonts-cjk ttf-ubuntu-font-family fcitx-im fcitx-rime #字体、输入法
sudo pacman -S xorg xorg-xinit i3 dmenu rxvt-unicode #图形界面
sudo pacman -S blueman curl feh firefox git gvim libreoffice-zh-CN networkmanager p7zip ranger tree vlc wget yay zsh

#修改yay源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save

#更改默认shell
sudo sed -i '/home/s/bash/zsh/' /etc/passwd
#安装ohmyzsh
echo -e "\n\n" | yay -S oh-my-zsh-git

#配置xinit、i3u、rxvt、tlp、vim、zsh
link=https://raw.githubusercontent.com/rraayy246/UZ/master/
wget ${link}conf/xinitrc -O ~/.xinitrc
wget ${link}conf/i3 -O ~/.config/i3/config
wget ${link}conf/urxvt -O ~/.Xresources
wget ${link}conf/vimrc -O ~/.vimrc
wget ${link}conf/zshrc -O ~/.zshrc
sudo wget ${link}conf/tlp -O /etc/tlp.conf

#自启动
sudo systemctl enable {NetworkManager,tlp,NetworkManager-dispatcher}
sudo systemctl disable {dhcpcd,netctl}
sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}

#startx自启
if [ "$(grep "exec startx" ~/.zprofile)" == "" ]; then
 echo "exec startx" > ~/.zprofile
fi

#加上archlinuxcn源
if [ "$(grep "archlinuxcn" /etc/pacman.conf)" == "" ]; then
 echo -e "[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" | sudo tee -a /etc/pacman.conf
 sudo pacman -Syy
 echo -e "\n" | sudo pacman -S archlinuxcn-keyring
fi

#安装小鹤音形
#到http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
wget ${link}flypy.7z -O ~/flypy.7z
7z x ~/flypy.7z
cp -Rf ~/rime ~/.config/fcitx
rm -rf ~/rime ~/flypy.7z ~/.config/fcitx/rime/default.yaml
fcitx-remote -r

