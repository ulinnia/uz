#!/usr/bin/env bash


#安装常用软件
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl fcitx fcitx-rime git wget vim p7zip-full gnome-tweaks chrome-gnome-shell
sudo apt autoremove -ygnome-tweaks 

#CAPS改为CTRL
sudo sed -i 's/XKBOPTIONS=""/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard

#安装小鹤音形
#到http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
link=https://github.com/rraayy246/UZ/raw/master/flypy.zip
wget ${link} -O hrime.zip
7z x hrime.zip
cp -Rf 小鹤音形Rime平台鼠须管for\ macOS/rime ~/.config/fcitx
rm -rf 小鹤音形Rime平台鼠须管for\ macOS hrime.zip
fcitx-remote -r
echo "请在下个视窗切换成fcitx, enter" choice
im-config

#用control+space来切换到rime
read -p "重启后，用control+space来切换到rime，请按任意键以重启，(n/N)停止:" choice
if [[ $choice = "n" ]]||[[ $choice = "N" ]]; then
    echo "脚本已停止"
    exit 1
fi

reboot
