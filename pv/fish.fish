
# 如果没有图形显示，则启动 sway
if test -z $DISPLAY && test -e /bin/sway
    exec sway

# 如果是交互状态
else if status is-interactive

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
