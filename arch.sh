#!/usr/bin/env bash

# root 用户不建议使用此脚本
g_yh() {
 if [ "$USER" == "root"  ]; then
  echo "请先退出root用户，并登陆新创建的用户。"
  exit 1
 fi
}

# 判断显卡驱动
pd_xk() {
 if [ "$(lspci -vnn | grep -i "vga.*amd.*radeon")" ]; then
  gpu=xf86-video-amdgpu
 elif [ "$(lspci -vnn | grep -i "vga.*nvidia.*geforce")" ]; then
  gpu=xf86-video-nouveau
 fi
}

# 修改 pacman 配置
pac_pv() {
 # pacman 增加 multilib 源
 sudo sed -i "/^#\[multilib\]/,+1s/^#//g" /etc/pacman.conf
 # pacman 开启颜色
 sudo sed -i "/^#Color/s/^#//" /etc/pacman.conf
 # 加上 archlinuxcn 源
 if [ ! "$(grep "archlinuxcn" /etc/pacman.conf)" ]; then
  echo -e "[archlinuxcn]\nServer =  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" | sudo tee -a /etc/pacman.conf
  # 导入 GPG key
  sudo pacman -Syy --noconfirm archlinuxcn-keyring
 fi
}

# pacman 安装软件
pac_av() {
 # 更新系统并安装 btrfs 管理、网络管理器、tlp
 echo -e "\n" | sudo pacman -Syu btrfs-progs networkmanager tlp tlp-rdw
 # 声卡、触摸板、显卡驱动
 sudo pacman -S --noconfirm alsa-utils pulseaudio-alsa xf86-input-libinput ${gpu}
 # 繁简中日韩、emoji、Ubuntu字体
 sudo pacman -S --noconfirm noto-fonts-cjk noto-fonts-emoji ttf-ubuntu-font-family
 # 小企鹅输入法
 sudo pacman -S --noconfirm fcitx-im fcitx-rime fcitx-configtool
 # 显示服务器和 sway
 sudo pacman -S --noconfirm wayland sway swaybg swayidle swaylock xorg-server-xwayland
 # 图形挂件
 sudo pacman -S --noconfirm alacritty dmenu qt5-wayland
 # 播放控制、亮度控制、电源工具
 sudo pacman -S --noconfirm playerctl brightnessctl upower
 # 其他网络工具
 sudo pacman -S --noconfirm curl firefox firefox-i18n-zh-cn git wget yay
 # 必要工具
 sudo pacman -S --noconfirm neovim nnn p7zip zsh
 # 模糊搜索、图片
 sudo pacman -S --noconfirm fzf imv
 # mtp、蓝牙
 sudo pacman -S --noconfirm libmtp pulseaudio-bluetooth bluez-utils
 # 其他工具
 sudo pacman -S --noconfirm libreoffice-zh-CN nodejs tree vlc vim
 # steam
 #sudo pacman -S --noconfirm ttf-liberation wqy-zenhei steam
}

# 修改 yay 配置
yay_pv() {
 yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
}

# yay 安装软件
yay_av() {
 # 安装 ohmyzsh、jmtpfs
 yay -S --noconfirm oh-my-zsh-git jmtpfs
}

# 安装软件
av_rj() {
 pd_xk
 pac_pv
 pac_av
 yay_pv
 yay_av
}

# 设置 zsh
uv_zsh() {
 # 更改默认 shell 为 zsh
 sudo sed -i '/home/s/bash/zsh/' /etc/passwd
}

# 下载配置文件
xz_pvwj() {
 # 我的 github 仓库网址
 ck_wv=https://raw.githubusercontent.com/rraayy246/UZ/master/
 # 创建目录
 mkdir -p ~/.config/{alacritty,fcitx,nvim,sway}
 mkdir ~/{xxzd,gz}
 # 下载配置文件
 sudo wget -nv ${ck_wv}P/grub -O /etc/default/grub
 sudo wget -nv ${ck_wv}P/tlp -O /etc/tlp.conf
 wget -nv ${ck_wv}P/hjbl -O ~/.zprofile
 wget -nv ${ck_wv}P/zshenv -O ~/.zshenv
 wget -nv ${ck_wv}P/zshrc -O ~/.zshrc
 wget -nv ${ck_wv}P/sway -O ~/.config/sway/config
 wget -nv ${ck_wv}P/vtl.sh -O ~/.config/sway/vtl.sh
 wget -nv ${ck_wv}P/vsdr.yml -O ~/.config/alacritty/alacritty.yml
 wget -nv ${ck_wv}P/vim.vim -O ~/.config/nvim/init.vim
}

# 安装小鹤音形
av_xhyx() {
 # 到 http://flypy.ys168.com/ 小鹤音形挂接第三方 小鹤音形Rime平台鼠须管for macOS.zip
 # 下载小鹤配置包
 wget -nv ${ck_wv}P/flypy.7z -O ~/flypy.7z
 # 解压配置包
 7z x ~/flypy.7z
 cp -r ~/rime ~/.config/fcitx/
 # 删除压缩包
 rm -rf ~/rime ~/flypy.7z ~/.config/fcitx/rime/default.yaml
 # 重新加载 fcitx 配置
 fcitx-remote -r
}

# 自启动管理
zqd_gl() {
 sudo systemctl enable --now {bluetooth,NetworkManager,NetworkManager-dispatcher,tlp}
 sudo systemctl disable dhcpcd
 sudo systemctl mask {systemd-rfkill.service,systemd-rfkill.socket}
}

# 创建交换文件
ij_jhwj() {
 sudo touch /swap # 创建空白文件
 sudo chattr +C /swap # 修改档案属性 不执行写入时复制（COW）
 sudo fallocate -l 4G /swap # 创建4G空洞文件
 sudo chmod 600 /swap # 修改文件读写执行权限
 sudo mkswap /swap # 格式化交换文件
 sudo swapon /swap # 启用交换文件
}

# 挂载交换文件
gz_jhwj() {
 echo "/swap swap swap defaults 0 0" | sudo tee -a /etc/fstab
 # 最大限度使用物理内存；生效
 echo "vm.swappiness = 1" | sudo tee /etc/sysctl.conf
 # 更新 sysctl 配置
 sudo sysctl -p
}

# 设置内核参数
uv_nhcu() {
 # 设置 resume 参数
 sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT/s/resume=\/dev\/\w*/resume=\/dev\/$(lsblk -l | awk '{ if($7=="/"){print $1} }')/" /etc/default/grub
 # 下载 btrfs_map_physical 工具
 wget -nv "https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c" -P ~
 # 编译 btrfs_map_physical 工具
 gcc -O2 -o ~/btrfs_map_physical ~/btrfs_map_physical.c
 # 使用 btrfs_map_physical 提取 resume_offset 值
 offset=$(sudo ~/btrfs_map_physical /swap | awk '{ if($1=="0"){print $9} }')
 # 设置 resume_offset 参数
 sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT/s/resume_offset=[0-9]*/resume_offset=$((offset/4096))/" /etc/default/grub
 # 删除 btrfs_map_physical 工具
 rm ~/btrfs_map_physical*
 # 更新 grub 配置
 sudo grub-mkconfig -o /boot/grub/grub.cfg
}

# 添加 resume 钩子
tj_gz() {
 sudo sed -i "/^HOOKS/s/udev/& resume/" /etc/mkinitcpio.conf
 # 重新生成 initramfs 镜像
 sudo mkinitcpio -P
}

# 建立交换文件
jl_jhwj() {
 if [ ! -e "/swap" ]; then
  ij_jhwj
 fi

 if [ ! "$(grep "\/swap swap swap defaults 0 0" /etc/fstab)" ]; then
  gz_jhwj
 fi

 uv_nhcu

 if [ ! "$(grep "udev resume" /etc/mkinitcpio.conf)" ]; then
  tj_gz
 fi
}

# vim 插件
vim_ij() {
 # 安装 vim-plug
 sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
 # 插件下载
 nvim +PlugInstall +qall
}

# 文字提醒
wztx() {
 echo -e "\n请手动执行 fcitx-configtool 修改输入法。"
}

# ======= 主程序 =======
yx_vix() {
 g_yh
 av_rj
 uv_zsh
 xz_pvwj
 av_xhyx
 zqd_gl
 jl_jhwj
 vim_ij
 wztx
}

yx_vix
