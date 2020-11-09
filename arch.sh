#!/usr/bin/env bash

if [ "$USER" == "root"  ]; then
echo "请先退出root用户，并登陆新创建的用户。"; exit 1; fi

# 更新系统并安装系统级软件
sudo sed -i "/\[multilib\]/,+1s/#//g" /etc/pacman.conf
echo -e "\n" | sudo pacman -Syu btrfs-progs networkmanager
sudo pacman -S --noconfirm alsa-utils pulseaudio-alsa xf86-input-libinput # 声卡、显卡、触摸板驱动
sudo pacman -S --noconfirm noto-fonts-cjk ttf-liberation ttf-ubuntu-font-family wqy-zenhei #字体
sudo pacman -S --noconfirm fcitx-im fcitx-rime fcitx-configtool # 输入法
sudo pacman -S --noconfirm xorg xorg-xinit i3 dmenu # 图形界面
sudo pacman -S --noconfirm feh network-manager-applet rxvt-unicode xss-lock # 图形挂件
sudo pacman -S --noconfirm curl firefox git wget yay # 网络工具
sudo pacman -S --noconfirm neovim p7zip ranger tlp tlp-rdw zsh # 必要工具
sudo pacman -S --noconfirm blueman libreoffice-zh-CN tree vlc vim # 其他工具
sudo pacman -S --noconfirm ttf-liberation wqy-zenhei nvidia lib32-nvidia-libgl steam # 安装 steam

# 修改 yay 源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save

# 更改默认 shell
sudo sed -i '/home/s/bash/zsh/' /etc/passwd

# 安装 ohmyzsh
yay -S --noconfirm oh-my-zsh-git

# 安装 vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# 配置 grub、tlp、init、i3、urxvt、nvim、zsh、CAPS CTRL 对调、壁纸
link=https://raw.githubusercontent.com/rraayy246/UZ/master/
sudo wget ${link}P/grub -O /etc/default/grub
sudo wget ${link}P/tlp -O /etc/tlp.conf
wget ${link}P/xinitrc -O ~/.xinitrc
mkdir ~/.config/i3; wget ${link}P/i3 -O ~/.config/i3/config
wget ${link}P/urxvt -O ~/.Xresources
mkdir ~/.config/nvim; wget ${link}P/nvim -O ~/.config/nvim/init.vim
wget ${link}P/zshrc -O ~/.zshrc
wget ${link}P/xmodmap -O ~/.Xmodmap
wget ${link}P/hw.png -O ~/.config/i3/hw.png

# startx 自启
if [ "$(grep "exec startx" ~/.zprofile)" == "" ]; then
echo "exec startx" > ~/.zprofile; fi

# 加上 archlinuxcn 源
if [ "$(grep "archlinuxcn" /etc/pacman.conf)" == "" ]; then
echo -e "[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" | sudo tee -a /etc/pacman.conf
sudo pacman -Syy --noconfirm archlinuxcn-keyring; fi

# 安装小鹤音形
# 到 http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
wget ${link}P/flypy.7z -O ~/flypy.7z; 7z x ~/flypy.7z
cp -Rf ~/rime ~/.config/fcitx
rm -rf ~/rime ~/flypy.7z ~/.config/fcitx/rime/default.yaml
fcitx-remote -r

# 自启动
sudo systemctl enable --now {NetworkManager,NetworkManager-dispatcher,tlp}
sudo systemctl disable dhcpcd
sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}

# 创建交换文件
if [ ! -e "/swap" ]; then
sudo touch /swap; sudo chattr +C /swap; sudo fallocate -l 4G /swap
sudo chmod 600 /swap; sudo mkswap /swap; sudo swapon /swap; fi

if [ "$(grep "\/swap swap swap defaults 0 0" /etc/fstab)" == "" ]; then
echo "/swap swap swap defaults 0 0" | sudo tee -a /etc/fstab
echo "vm.swappiness = 1" | sudo tee /etc/sysctl.conf; sudo sysctl -p; fi

# 设定内核参数
sudo sed -i "/GRUB_CMDLINE_LINUX_DEFAULT/s/resume=\/dev\/\w*/resume=\/dev\/$(lsblk -l | awk '{ if($7=="/"){print $1} }')/" /etc/default/grub
wget "https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c" -P ~
gcc -O2 -o ~/btrfs_map_physical ~/btrfs_map_physical.c
offset=$(sudo ~/btrfs_map_physical /swap | awk '{ if($1=="0"){print $9} }')
sudo sed -i "/GRUB_CMDLINE_LINUX_DEFAULT/s/resume_offset=[0-9]*/resume_offset=$((offset/4096))/" /etc/default/grub
rm ~/btrfs_map_physical*

# 添加 resume 钩子
if [ "$(grep "udev resume" /etc/mkinitcpio.conf)" == "" ]; then
sudo sed -i "/HOOKS/s/udev/udev resume/" /etc/mkinitcpio.conf; sudo mkinitcpio -P; fi

sudo sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/" /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 安装 nodejs
curl -sL install-node.now.sh/lts | sudo bash

# 手动执行
echo -e "\n请手动执行 fcitx-configtool 修改输入法。\n进入nvim,使用命令 :PlugInstall 安装插件。"


