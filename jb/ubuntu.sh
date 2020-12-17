#!/usr/bin/env bash

#解决Ubuntu 20.04安装程序崩溃
sudo apt install -y libgcc-s1:i386
#安装常用软件
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl fcitx fcitx-rime git vim wget wine p7zip-full gnome-tweaks chrome-gnome-shell
sudo apt autoremove -y

#CAPS改为CTRL
sudo sed -i 's/XKBOPTIONS=""/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard
read -p "进入键盘设定页面确定更改。enter" choice
sudo dpkg-reconfigure keyboard-configuration

#安装小鹤音形
#到http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
link=https://github.com/rraayy246/UZ/raw/master/flypy.zip
wget ${link} -O flypy.zip
7z x flypy.zip
cp -Rf "小鹤音形Rime平台鼠须管for macOS/rime" ~/.config/fcitx
rm -rf "小鹤音形Rime平台鼠须管for macOS" flypy.zip
fcitx-remote -r
read -p "请在下个视窗切换成fcitx。enter"
im-config

#GNOME扩展启用
read -p "进入扩展页面启用User Themes扩展。enter" choice
firefox "https://extensions.gnome.org/extension/19/user-themes/"
read -p "打开GNOME调整工具（优化），进入“外观”部分，就可以看到shell主题的选项，现在只需要把它启用就可以了。enter" choice
gnome-tweaks

#游戏
read -p "有玩游戏的需求吗？[y/*]" choice
if [ "$choice" = "y" ]||[ "$choice" = "Y" ]; then
 sudo dpkg --add-architecture i386
 sudo add-apt-repository -y ppa:lutris-team/lutris
 sudo apt update -y
 sudo apt install -y lutris steam
 read -p "打开steam，设置，steam play，启用 steam play，下面选单选择Proton。enter"
 steam
 read -p "打开steam，库，选择要玩的游戏右键，属性，设置启动选项，输入gamemoderun %command%，enter"
 steam
 read -p "你是N卡还是A卡？[n/*]" choice
 if [ "$choice" = "n" ]||[ "$choice" = "N" ]; then
  sudo add-apt-repository -y ppa:graphics-drivers/ppa
  sudo apt update -y
#https://github.com/lutris/docs/blob/master/InstallingDrivers.md
  sudo apt install -y nvidia-driver-450 libvulkan1 libvulkan1:i386
 else
  sudo add-apt-repository -y ppa:kisak/kisak-mesa
  sudo apt update && sudo apt upgrade -y
  sudo apt install libgl1-mesa-dri:i386
  sudo apt install mesa-vulkan-drivers mesa-vulkan-drivers:i386
 fi
 wget -nc https://dl.winehq.org/wine-builds/winehq.key
 sudo apt-key add winehq.key
#https://github.com/lutris/docs/blob/master/WineDependencies.md
 ver=focal
 sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ ${ver} main'
 sudo apt update -y
 sudo apt install --install-recommends winehq-staging -y
 sudo apt install -y libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386
 read -p "打开lutris，选项，首选项，系统选项，显示高级选项，在命令前缀输入gamemoderun，保存。enter" choice
fi

#用control+space来切换到rime
read -p "重启后，用control+space来切换到rime。[*/n]" choice
if [ "$choice" = "n" ]||[ "$choice" = "N" ]; then
 echo "脚本已停止"
 exit 1
else
 reboot
fi
