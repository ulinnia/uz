# ~/.config/fish/config.fish

# 如果登入没有图形显示，则启动 sway
if status is-login ;
    and test -z "$DISPLAY" -a (tty) = "/dev/tty1"
        exec sway

# 如果是交互状态，则启动 starship
else if status is-interactive
    starship init fish | source

end
