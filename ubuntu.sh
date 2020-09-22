#!/usr/bin/env bash

#解决中文乱码
echo "以下命令需要超级用户权限。"
sudo su
apt-get install language-pack-zh-hans
echo -e "LANG=\"zh_CN.UTF-8\"\nLANGUAGE=\"zh_CN:zh:en_US:en\"" >> "/etc/environment"
echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8\nzh_CN.GBK GBK" >> "/var/lib/locales/supported.d/local"
locale-gen
