#!/usr/bin/env bash

#添加源
sudo pacman-mirrors -i -c China -m rank
#增加archlinuxcn库和antergos库
echo -e "\n[archlinuxcn]\nSigLevel = TrustAll\nServer = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch\n\n[antergos]\nSigLevel = TrustAll\nServer = https://mirrors.tuna.tsinghua.edu.cn/antergos/\$repo/\$arch\n"|sudo tee -a /etc/pacman.conf
#更新
sudo pacman -Syy
#安装archlinuxcn签名钥匙&antergos签名钥匙
sudo pacman -S --noconfirm archlinuxcn-keyring antergos-keyring
sudo pacman -S firefox yay
