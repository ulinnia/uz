
# 如果没有图形显示，则启动 sway
if test -z $DISPLAY && test -e /bin/sway
    exec sway

# 如果是交互状态，则启动 starship
else if status is-interactive
    starship init fish | source

end
