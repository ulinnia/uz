#!/usr/bin/env bash

if [ "$USER" == "root"  ]; then
 echo "请先退出root用户，并登陆新创建的用户。"
 exit 1
fi

#更新系统并安装系统级软件
sudo pacman -Syu --noconfirm btrfs-progs networkmanager
sudo pacman -S --noconfirm alsa-utils pulseaudio-alsa xf86-input-libinput #声卡、显卡、触摸板驱动
sudo pacman -S --noconfirm noto-fonts-cjk ttf-liberation ttf-ubuntu-font-family wqy-zenhei #字体
sudo pacman -S --noconfirm fcitx-im fcitx-rime fcitx-configtool #输入法
sudo pacman -S --noconfirm xorg xorg-xinit i3 dmenu #图形界面
sudo pacman -S --noconfirm feh network-manager-applet rxvt-unicode xss-lock #图形挂件
sudo pacman -S --noconfirm curl firefox git wget yay #网络工具
sudo pacman -S --noconfirm neovim p7zip ranger tlp tlp-rdw zsh #必要工具
sudo pacman -S --noconfirm blueman libreoffice-zh-CN tree vlc #其他工具

#修改yay源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save

#更改默认shell
sudo sed -i '/home/s/bash/zsh/' /etc/passwd
#安装ohmyzsh
yay -S --noconfirm oh-my-zsh-git

#配置tlp、init、i3、urxvt、nvim、zsh、CAPS CTRL 对调、壁纸
link=https://raw.githubusercontent.com/rraayy246/UZ/master/
sudo wget ${link}P/tlp -O /etc/tlp.conf
wget ${link}P/xinitrc -O ~/.xinitrc
wget ${link}P/i3 -O ~/.config/i3/config
wget ${link}P/urxvt -O ~/.Xresources
mkdir ~/.config/nvim && wget ${link}P/nvim -O ~/.config/nvim/init.vim
wget ${link}P/zshrc -O ~/.zshrc
wget ${link}P/xmodmap -O ~/.Xmodmap
wget ${link}P/hw.png -O ~/.config/i3/hw.png

#startx自启
if [ "$(grep "exec startx" ~/.zprofile)" == "" ]; then
 echo "exec startx" > ~/.zprofile
fi

#加上archlinuxcn源
if [ "$(grep "archlinuxcn" /etc/pacman.conf)" == "" ]; then
 echo -e "[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" | sudo tee -a /etc/pacman.conf
 sudo pacman -Syy --noconfirm archlinuxcn-keyring
fi

#安装小鹤音形
#到http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
wget ${link}P/flypy.7z -O ~/flypy.7z
7z x ~/flypy.7z
cp -Rf ~/rime ~/.config/fcitx
rm -rf ~/rime ~/flypy.7z ~/.config/fcitx/rime/default.yaml
fcitx-remote -r

#自启动
sudo systemctl enable --now {NetworkManager,NetworkManager-dispatcher,tlp}
sudo systemctl disable dhcpcd
sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}

#创建交换文件
sudo touch /swap
sudo chattr +C /swap
sudo fallocate -l 4G /swap
sudo chmod 600 /swap
sudo mkswap /swap
sudo swapon /swap
echo "/swap swap swap defaults 0 0" | sudo tee -a /etc/fstab
echo "vm.swappiness = 10" | sudo tee /etc/sysctl.conf
sudo sysctl -p

read -p "安装 steam 吗？[y/*]" choice
if [ "$choice" = "y" ]||[ "$choice" = "Y" ];then
 sudo sed -i "/\[multilib\]/,+1s/#//g" /etc/pacman.conf
 sudo pacman -Syy --noconfirm ttf-liberation wqy-zenhei nvidia lib32-nvidia-libgl steam
fi

