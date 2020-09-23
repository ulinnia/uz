#!/usr/bin/env bash

#解决中文乱码
echo "以下命令需要超级用户权限。"
sudo su
apt-get install `check-language-support -l zh-hans`
echo -e "LANG=\"zh_CN.UTF-8\"\nLANGUAGE=\"zh_CN:zh:en_US:en\"" >> "/etc/environment"
echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8\nzh_CN.GBK GBK" >> "/var/lib/locales/supported.d/local"
locale-gen

#安装常用软件
apt update
apt upgrade
apt install vim fcitx fcitx-rime wget curl p7zip
apt autoremove

#CAPS改为CTRL
sed -i 's/XKBOPTIONS=""/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard

#安装小鹤音形
exit
if [ -e "$HOME/下载" ]; then dl="下载"; else dl="Download"; fi
wget http://ys-j.ys168.com/116124311/TTv6jFq712X632VHKLHL/小鹤音形Rime平台鼠须管for%20macOS.zip -O $HOME/${dl}/hrime.zip
7z x $HOME/${dl}/hrime.zip -o$HOME/${dl}
cp -rf $HOME/${dl}/小鹤音形Rime平台鼠须管for\ macOS/rime $HOME/.config/fcitx
echo "请将默认的输入工具由iBus切换为fcitx"
im-config -s fcitx
#用control+space来切换到rime

reboot
