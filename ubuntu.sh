#!/usr/bin/env bash

#解决中文乱码
echo "以下命令需要超级用户权限。"
apt install -y `check-language-support -l zh-hans`
echo -e "LANG=\"zh_CN.UTF-16\"\nLANGUAGE=\"zh_CN:zh:en_US:en\"" >> "/etc/environment"
echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-16 UTF-16\nzh_CN.GBK GBK" >> "/var/lib/locales/supported.d/local"
locale-gen

#安装常用软件
apt update -y
apt upgrade -y
apt install -y vim fcitx fcitx-rime wget curl p7zip
apt autoremove -y

#CAPS改为CTRL
sed -i 's/XKBOPTIONS=""/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard

#安装小鹤音形
exit
if [ -e "~/下载" ]; then dl="下载"; else dl="Download"; fi
#到http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
link=https://github.com/rraayy246/UZ/raw/master/flypy.zip
wget ${link} -O ~/${dl}/hrime.zip
7z x ~/${dl}/hrime.zip -o~/${dl}
cp -rf ~/${dl}/小鹤音形Rime平台鼠须管for\ macOS/rime ~/.config/fcitx
rm -rf ~/${dl}/小鹤音形Rime平台鼠须管for\ macOS ~/${dl}/hrime.zip
im-config -s fcitx

#用control+space来切换到rime
read -p "重启后，用control+space来切换到rime，请按任意键以重启，(n/N)停止:" choice
if [[ $choice = "n" ]]||[[ $choice = "N" ]]; then
    echo "脚本已停止"
    exit 1
fi

reboot
