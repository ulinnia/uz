#!/usr/bin/env bash

#更新系统并安装声卡、显卡、xorg、触摸板、字体、fcitx、urxvt、i3、yay、feh、dmenu及常用程序
sudo pacman -Syyu alsa-utils pulseaudio-alsa xf86-video-vesa xorg xorg-xinit xf86-input-libinput noto-fonts-cjk ttf-ubuntu-font-family fcitx-im fcitx-rime fcitx-config rxvt-unicode i3 yay feh dmenu-git curl firefox git p7zip tree vlc wget

#配置xinit
cp -f /etc/X11/xinit/xinitrc ~/.xinitrc
#设定i3自启
​sed -i '$a exec i3' ~/.xinitrc
#设置中文界面
​sed -i '2i\export LANGUAGE=zh_CN:en_US' ~/.xinitrc

#配置i3
cp -f /etc/i3/config ~/.config/i3/config
#火狐快捷键
sed '/bindsym $mod+Return/a\bindsym $mod+Shift+f exec firefox' ~/.config/i3/config

​​#设定fcitx参数
if​ [ ​"​$(​grep ​"export GTK_IM_MODULE=fcitx​​"​ ​~/.xprofile)​"​ ​==​ ​"​"​ ]​;​ ​then
 echo -e "export GTK_IM_MODULE=fcitx\nexport QT_IM_MODULE=fcitx\nexport XMODIFIERS=\"@im=fcitx\"" > "~/.xprofile"
fi

#注解无效命令
sed '/twm &/,/exec xterm -geometry/s/^/#/' ~/.xinitrc

#startx自启
if​ [ ​"​$(​grep ​"exec startx​​"​ ​~/.bash_profile)​"​ ​==​ ​"​"​ ]​;​ ​then
 echo -e "if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then\n exec startx\nfi" > "~/.bash_profile"
fi

#加上archlinuxcn源
sudo echo -e "[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch" > "/etc/pacman.conf"
sudo pacman -Syy
sudo pacman -S archlinuxcn-keyring

#修改yay源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save

#安装小鹤音形
​link=https://github.com/rraayy246/UZ/raw/master/flypy.zip
​wget ​${link}​ -O flypy.zip
​7z x flypy.zip
​cp -Rf ​"​小鹤音形Rime平台鼠须管for macOS/rime​"​ ​~​/.config/fcitx
​rm -rf ​"​小鹤音形Rime平台鼠须管for macOS​"​ flypy.zip
rm ~/.config/fcitx/rime/default.yaml && fcitx-remote -r



