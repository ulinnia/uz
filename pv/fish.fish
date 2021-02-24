
# 如果没有图形显示，则启动 sway
if test -z $DISPLAY && test -e /bin/sway
    exec sway

# 如果是交互状态
else if status is-interactive

    # 目录跳回
    alias 1='cd -'
    alias 2='cd -2'
    alias 3='cd -3'
    alias 4='cd -4'
    alias 5='cd -5'
    alias 6='cd -6'
    alias 7='cd -7'
    alias 8='cd -8'
    alias 9='cd -9'

    # git 控制
    alias g=git
    alias ga='git add'
    alias gaa='git add --all'
    alias gb='git branch'
    alias gba='git branch -a'
    alias gcmsg='git commit -m'
    alias gd='git diff'
    alias gl='git pull'
    alias gp='git push'
    alias grh='git reset --hard'
    alias grs='git reset --soft'
    alias gst='git status'

    # 其他
    alias fu='fusermount -u ~/gz'
    alias la='ls -a'
    alias nm='nmtui-connect'
    alias nn='nnn'
    alias gx='sudo pacman -Syu'
    alias svi='sudo nvim'
    alias uz='cd ~/uz'
    alias vi='nvim'

    # 提示符
    function fish_prompt --description '信息提示'
        # 保存上一条命令的返回状态
        set -l last_pipestatus $pipestatus
        set -l pipestatus_string (__fish_print_pipestatus "[" "] " "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)

        set -l prefix
        switch "$USER"
            case root toor
                if set -q fish_color_cwd_root
                    set color_cwd $fish_color_cwd_root
                else
                    set color_cwd $fish_color_cwd
                end
                set suffix '#'
            case '*'
                set color_cwd $fish_color_cwd
                set suffix '$'
        end

        printf '\n%s%s %s%s%s%s ' \
            (set_color brred) (date "+%H:%M:%S") \
            (set_color $color_cwd) (prompt_pwd) \
            (set_color normal) (fish_vcs_prompt)
        echo -n $pipestatus_string
        printf '\n%s ' $suffix

    end
end
