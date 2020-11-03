#!/usr/bin/env bash

if [ "$USER" == "root"  ]; then
 echo "请先退出root用户，并登陆新创建的用户。"
 exit 1
fi

#更新系统并安装系统级软件
echo -e "\n" | sudo pacman -Syu btrfs-progs systemd-swap
echo -e "\n" | sudo pacman -S alsa-utils pulseaudio-alsa xf86-input-libinput #声卡、显卡、触摸板驱动
echo -e "\n\n" | sudo pacman -S noto-fonts-cjk ttf-liberation ttf-ubuntu-font-family wqy-zenhei fcitx-im fcitx-rime fcitx-configtool #输入法、字体
echo -e "\n\n\n" | sudo pacman -S xorg xorg-xinit i3 dmenu rxvt-unicode networkmanager network-manager-applet #图形界面
echo -e "\n\n" | sudo pacman -S blueman curl feh firefox git gvim libreoffice-zh-CN
echo -e "\n" | sudo pacman -S p7zip ranger tree vlc wget yay zsh

#修改yay源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save

#更改默认shell
sudo sed -i '/home/s/bash/zsh/' /etc/passwd
#安装ohmyzsh
echo -e "\n\n" | yay -S oh-my-zsh-git

#配置tlp、swap、xinit、i3、urxvt、vim、zsh、CAPS CTRL 对调
link=https://raw.githubusercontent.com/rraayy246/UZ/master/
sudo wget ${link}conf/tlp -O /etc/tlp.conf
sudo wget ${link}conf/swap -O /etc/systemd/swap.conf
wget ${link}conf/xinitrc -O ~/.xinitrc
wget ${link}conf/i3 -O ~/.config/i3/config
wget ${link}conf/urxvt -O ~/.Xresources
wget ${link}conf/vimrc -O ~/.vimrc
wget ${link}conf/zshrc -O ~/.zshrc
wget ${link}conf/xmodmap -O ~/.Xmodmap

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

#自启动
sudo NetworkManager
sudo systemctl enable {tlp,systemd-swap,NetworkManager}
sudo systemctl disable {dhcpcd,netctl}
sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}

read -p "安装 steam 吗？[y/*]" choice
if [ "$choice" = "y" ]||[ "$choice" = "Y" ];then
 sudo sed -n "/[multilib]/,/Include = \/etc\/pacman.d\/mirrorlist/s/#//" /etc/pacman.conf
 sudo pacman -Syy
 sudo pacman -S ttf-liberation wqy-zenhei nvidia lib32-nvidia-libgl nvidia-setting
fi

