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
#到http://flypy.ys168.com/下载 小鹤音形挂接第三方之MacOS文件到本地，将上述文件解压，将文件夹下的rime文件夹复制到~/.config/fcitx/下，若已存在rime文件夹，先将其删除；最后命令行输入im-config，将默认的输入工具由iBus切换为fcitx，再重启。这时候就能用control+space来切换到rime了
