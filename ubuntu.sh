#!/usr/bin/env bash


sudo apt install libgcc-s1:i386
#安装常用软件
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl fcitx fcitx-rime git vim wget wine p7zip-full gnome-tweaks chrome-gnome-shell
sudo apt autoremove -y

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

#GNOME扩展启用
echo "进入扩展页面启用 User Themes 扩展，enter" choice
firefox https://extensions.gnome.org/extension/19/user-themes/
echo "打开 GNOME 调整工具（优化），进入“外观”部分，就可以看到 shell 主题的选项，现在只需要把它启用就可以了。" choice


#用control+space来切换到rime
read -p "重启后，用control+space来切换到rime，请按任意键以重启，(n/N)停止:" choice
if [[ $choice = "n" ]]||[[ $choice = "N" ]]; then
    echo "脚本已停止"
    exit 1
fi

reboot
