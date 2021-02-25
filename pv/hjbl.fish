#!/bin/fish

# 移除欢迎语
set -U fish_greeting ""

# 语言设置
set -Ux LANG zh_CN.UTF-8
set -Ux LANGUAGE zh_CN:en_US
set -Ux LC_CTYPE en_US.UTF-8
#设定输入法
set -Ux GTK_IM_MODULE fcitx
set -Ux QT_IM_MODULE fcitx
set -Ux XMODIFIERS @im=fcitx
set -Ux SDL_IM_MODULE fcitx

# nnn 书签，选择，插件，缓存
set -Ux NNN_BMS 'a:~/a;x:~/xz;j:~;g:~/gz'
set -Ux NNN_SEL '/tmp/.sel'
set -Ux NNN_PLUG ''
set -Ux NNN_FIFO '/tmp/nnn.fifo'

# 默认编辑器
set -Ux EDITOR nvim

# 控制键替换大写锁定键
set -Ux XKB_DEFAULT_OPTIONS ctrl:nocaps

# git 控制
abbr -a -U g git
abbr -a -U ga 'git add'
abbr -a -U gaa 'git add --all'
abbr -a -U gb 'git branch'
abbr -a -U gba 'git branch -a'
abbr -a -U gcmsg 'git commit -m'
abbr -a -U gd 'git diff'
abbr -a -U gl 'git pull'
abbr -a -U gp 'git push'
abbr -a -U grh 'git reset --hard'
abbr -a -U grs 'git reset --soft'
abbr -a -U gst 'git status'

# 其他
abbr -a -U 1 'cd -'
abbr -a -U fu 'fusermount -u ~/gz'
abbr -a -U la 'ls -a'
abbr -a -U n 'nnn'
abbr -a -U nm 'nmtui-connect'
abbr -a -U gx 'sudo pacman -Syu'
abbr -a -U sv 'sudo nvim'
abbr -a -U u 'cd ~/uz'
abbr -a -U v 'nvim'

