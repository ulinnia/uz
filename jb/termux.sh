#!/data/data/com.termux/files/usr/bin/bash

# 连接内部存储。
nbci_lj() {
 termux-setup-storage
}

# 安装软件
rj_av() {
 pkg install -y curl git man neovim tree wget zsh
 # 安装 oh-my-zsh。
 git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh --depth 1
}

# 下载配置文件
pvwj_xz() {
 # 创建文件夹
 mkdir -p ~/{storage/shared/a,.config/nvim}
 # 克隆 uz 仓库
 cd ~/storage/shared/a; git clone https://github.com/rraayy246/uz --depth 1; cd
 # 移动配置文件
 cp ~/storage/shared/a/uz/pv/vim.vim ~/.config/nvim/init.vim
 cp ~/storage/shared/a/uz/pv/zshrc ~/.zshrc
 # 下载 Ubuntu 字体
 curl -fsLo ~/.termux/font.ttf --create-dirs https://github.com/powerline/fonts/raw/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf
}

# 设置 zsh
zsh_uv() {
 # 修改安装路径
 sed -i "/^ZSH=/s/.*/export ZSH=~\/.oh-my-zsh/" ~/.zshrc
 # 设 zsh 为默认 shell
 chsh -s zsh
}

# 设置 vim
vim_uv() {
 # nvim 注释 plug 配置
 sed -i '/^call plug#begin/,$s/^[^"]/"&/' ~/.config/nvim/init.vim
}

# 软连接 uz。
uz_lj() {
 ln -s ~/storage/shared/a/uz ~/uz
}

# 应用设定。
ud_yy() {
 termux-reload-settings
}

# 文字提醒
wztx() {
 echo "完成！请重启Termux。"
 exit
}

# ======= 主程序 =======
vix_yx() {
 nbci_lj
 rj_av
 pvwj_xz
 zsh_uv
 vim_uv
 uz_lj
 ud_yy
 wztx
}

vix_yx
