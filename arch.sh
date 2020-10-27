#!/usr/bin/env bash

#安装声卡、显卡、xorg、触摸板、字体、fcitx、urxvt、i3、yay、feh、dmenu及常用程序
sudo pacman -Syu alsa-utils pulseaudio-alsa xf86-video-vesa xorg xorg-xinit xf86-input-libinput noto-fonts-cjk ttf-ubuntu-font-family fcitx-im fcitx-rime fcitx-config rxvt-unicode i3 yay feh dmenu-git curl firefox git p7zip tree vlc wget

cp /etc/X11/xinit/xinitrc ~/.xinitrc
