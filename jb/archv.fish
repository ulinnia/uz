#!/usr/bin/env fish

# root 用户不建议使用此脚本
function yh_ud --description 'root 用户退出'
    if test "$USER" = 'root'
        echo '请先退出root用户，并登陆新创建的用户。'
        exit 1
    end
end


