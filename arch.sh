#!/usr/bin/env bash

# root 用户不建议使用此脚本
if [ "$USER" == "root"  ]; then
echo "请先退出root用户，并登陆新创建的用户。"; exit 1; fi

# ======= 下载软件 =======
# 增加 multilib 源
sudo sed -i "/\[multilib\]/,+1s/#//g" /etc/pacman.conf
# 更新系统并安装 btrfs 管理和联网管理软件
echo -e "\n" | sudo pacman -Syu btrfs-progs networkmanager
# 安装声卡、显卡、触摸板驱动
sudo pacman -S --noconfirm alsa-utils pulseaudio-alsa xf86-video-nouveau xf86-input-libinput
# 安装字体
sudo pacman -S --noconfirm noto-fonts-cjk noto-fonts-emoji ttf-ubuntu-font-family
# 安装小企鹅输入法
sudo pacman -S --noconfirm fcitx-im fcitx-rime fcitx-configtool
# 安装图形界面和 sway
sudo pacman -S --noconfirm dmenu wayland sway swaylock xorg-server-xwayland
# 安装图形挂件
sudo pacman -S --noconfirm alacritty qt5-wayland swaybg swayidle
# 安装音量、亮度、状态栏工具
sudo pacman -S --noconfirm playerctl brightnessctl upower
# 安装其他网络工具
sudo pacman -S --noconfirm curl firefox firefox-i18n-zh-cn git wget yay
# 安装必要工具
sudo pacman -S --noconfirm neovim p7zip ranger tlp tlp-rdw zsh
# 安装其他工具
sudo pacman -S --noconfirm blueman libreoffice-zh-CN libmtp tree vlc vim
sudo pacman -S --noconfirm nodejs
# 安裝 steam
sudo pacman -S --noconfirm ttf-liberation wqy-zenhei steam

# ======= 设定 zsh =======
# 修改 yay 源
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save

# 更改默认 shell 为 zsh
sudo sed -i '/home/s/bash/zsh/' /etc/passwd
# 安装 ohmyzsh，安装 jmtpfs
yay -S --noconfirm oh-my-zsh-git jmtpfs

# ======= 配置文件 =======
# 用变数代替我的 github 仓库网址
link=https://raw.githubusercontent.com/rraayy246/UZ/master/
# 下载配置文件
sudo wget -nv ${link}P/grub -O /etc/default/grub
sudo wget -nv ${link}P/tlp -O /etc/tlp.conf
wget -nv ${link}P/hjbl -O ~/.zprofile
wget -nv ${link}P/zsh -O ~/.zshrc
wget -nv -x ${link}P/sway -O ~/.config/sway/config
wget -nv -x ${link}P/vtl -O ~/.config/sway/vtl.sh
wget -nv -x ${link}P/vsdr -O ~/.config/alacritty/alacritty.yml
wget -nv -x ${link}P/vim -O ~/.config/nvim/init.vim

# 加上 archlinuxcn 源
if [ "$(grep "archlinuxcn" /etc/pacman.conf)" == "" ]; then
echo -e "[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" | sudo tee -a /etc/pacman.conf
# 导入 GPG key
sudo pacman -Syy --noconfirm archlinuxcn-keyring; fi

# ======= 安装小鹤音形 =======
# 到 http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
# 下载小鹤配置包
wget -nv ${link}P/flypy.7z -O ~/flypy.7z
# 解压配置包
7z x ~/flypy.7z
cp -r ~/rime ~/.config/fcitx/
# 删除压缩包
rm -rf ~/rime ~/flypy.7z ~/.config/fcitx/rime/default.yaml
# 重新加载 fcitx 配置
fcitx-remote -r

# ======= 自启动 =======
sudo systemctl enable --now {NetworkManager,NetworkManager-dispatcher,tlp}
sudo systemctl disable dhcpcd
sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}

# ======= 创建交换文件 =======
if [ ! -e "/swap" ]; then
sudo touch /swap # 创建空白文件
sudo chattr +C /swap # 修改档案属性 不执行写入时复制（COW）
sudo fallocate -l 4G /swap # 创建4G空洞文件
sudo chmod 600 /swap # 修改文件读写执行权限
sudo mkswap /swap # 格式化交换文件
sudo swapon /swap; fi # 启用交换文件

# 挂载交换文件
if [ "$(grep "\/swap swap swap defaults 0 0" /etc/fstab)" == "" ]; then
echo "/swap swap swap defaults 0 0" | sudo tee -a /etc/fstab
# 最大限度使用物理内存；生效
echo "vm.swappiness = 1" | sudo tee /etc/sysctl.conf; sudo sysctl -p; fi

# 设置内核参数
# 设置 resume 参数
sudo sed -i "/GRUB_CMDLINE_LINUX_DEFAULT/s/resume=\/dev\/\w*/resume=\/dev\/$(lsblk -l | awk '{ if($7=="/"){print $1} }')/" /etc/default/grub
# 下载 btrfs_map_physical 工具
wget -nv "https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c" -P ~
# 编译 btrfs_map_physical 工具
gcc -O2 -o ~/btrfs_map_physical ~/btrfs_map_physical.c
# 使用 btrfs_map_physical 提取 resume_offset 值
offset=$(sudo ~/btrfs_map_physical /swap | awk '{ if($1=="0"){print $9} }')
# 设置 resume_offset 参数
sudo sed -i "/GRUB_CMDLINE_LINUX_DEFAULT/s/resume_offset=[0-9]*/resume_offset=$((offset/4096))/" /etc/default/grub
# 删除 btrfs_map_physical 工具
rm ~/btrfs_map_physical*
# 更新 grub 配置
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 添加 resume 钩子；重新生成 initramfs 镜像
if [ "$(grep "udev resume" /etc/mkinitcpio.conf)" == "" ]; then
sudo sed -i "/HOOKS/s/udev/udev resume/" /etc/mkinitcpio.conf; sudo mkinitcpio -P; fi

# ======= vim 插件管理 =======
# 安装 vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# 插件下载
nvim +PlugInstall +qall

# ======= 手动执行 =======
echo -e "\n请手动执行 fcitx-configtool 修改输入法。"


