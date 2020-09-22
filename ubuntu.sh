#!/usr/bin/env bash

#解决中文乱码
echo "以下代码需要超级使用者权限。"
sudo su
echo -e "LANG=\"zh_CN.UTF-8\"\nLANGUAGE=\"zh_CN:zh:en_US:en\"" >> "/etc/environment"
