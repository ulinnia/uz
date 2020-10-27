#!/usr/bin/env bash

#安装声卡、显卡、xorg、触摸板、字体及常用程序
sudo pacman -S alsa-utils pulseaudio-alsa xf86-video-vesa xorg xorg-xinit xf86-input-libinput noto-fonts-cjk ttf-ubuntu-font-family curl git p7zip tree vlc wget zsh

cp /etc/X11/xinit/xinitrc ~/.xinitrc
