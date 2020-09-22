#!/usr/bin/env bash

#解决中文乱码
sudo su
echo -e "LANG=\"zh_CN.UTF-8\"\nLANGUAGE=\"zh_CN:zh:en_US:en\"" >> "/etc/environment"
