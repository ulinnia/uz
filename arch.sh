#!/usr/bin/env bash

#更新系统并安装声卡、显卡、xorg、触摸板、字体、fcitx、urxvt、i3、yay、feh、dmenu及常用程序
sudo pacman -Syyu alsa-utils pulseaudio-alsa xf86-video-vesa xorg xorg-xinit xf86-input-libinput noto-fonts-cjk ttf-ubuntu-font-family fcitx-im fcitx-rime fcitx-config rxvt-unicode i3 yay feh dmenu-git curl firefox git p7zip tree vlc wget

#配置xinit
cp -f /etc/X11/xinit/xinitrc ~/.xinitrc
#设定i3自启
​sed -i '$a exec i3' ~/.xinitrc
#设置中文界面
​sed -i '2i\export LANGUAGE=zh_CN:en_US' ~/.xinitrc

​​if​ [ ​"​$(​grep ​"export GTK_IM_MODULE=fcitx​​"​ ​~/.xprofile)​"​ ​==​ ​"​"​ ]​;​ ​then
 echo -e "export GTK_IM_MODULE=fcitx\nexport QT_IM_MODULE=fcitx\nexport XMODIFIERS=\"@im=fcitx\"" ~/.xprofile
fi



