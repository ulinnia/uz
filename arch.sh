#!/usr/bin/env bash

if [ "$USER" == "root"  ]; then
 echo "请先退出root用户，并登陆新创建的用户。"
 exit 1
fi

#更新系统并安装声卡、显卡、xorg、触摸板、字体、fcitx、urxvt、i3、yay、feh、dmenu及常用程序
echo -e "\n\n\n" | sudo pacman -Syyu alsa-utils pulseaudio-alsa xf86-video-vesa xorg xorg-xinit xf86-input-libinput noto-fonts-cjk ttf-ubuntu-font-family fcitx-im fcitx-rime fcitx-config rxvt-unicode i3 yay feh dmenu networkmanager curl firefox git gvim libreoffice-zh-CN p7zip tree vlc wget zsh

#配置xinit、i3u、rxvt、tlp
link=https://github.com/rraayy246/UZ/raw/master/
wget ${link}conf/xinitrc -O ~/.xinitrc
wget ${link}conf/i3 -O ~/.config/i3/config
wget ${link}conf/urxvt -O ~/.Xresources
sudo wget ${link}conf/tlp -O /etc/tlp.conf

#自启动
sudo systemctl enable {NetworkManager,tlp,NetworkManager-dispatcher}
sudo systemctl disable {dhcpcd,netctl}
sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}

#startx自启
if [ "$(grep "exec startx" ~/.bash_profile)" == "" ]; then
 echo -e "if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then\n exec startx\nfi" > "~/.bash_profile"
fi

#加上archlinuxcn源
if [ "$(grep "archlinuxcn" /etc/pacman.conf)" == "" ]; then
 echo -e "[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch" | sudo tee -a /etc/pacman.conf
 sudo pacman -Syy
 echo -e "\n" | sudo pacman -S archlinuxcn-keyring
fi

#修改yay源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save

#安装小鹤音形
wget ${link}flypy.zip -O ~/flypy.zip
7z x ~/flypy.zip
cp -Rf "~/小鹤音形Rime平台鼠须管for macOS/rime" ~/.config/fcitx
rm -rf "~/小鹤音形Rime平台鼠须管for macOS" ~/flypy.zip
rm ~/.config/fcitx/rime/default.yaml && fcitx-remote -r

