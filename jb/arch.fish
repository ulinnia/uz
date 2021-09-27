#!/usr/bin/env fish

# 输出颜色
function N
    echo -e "$argv[1]"
end
function G
    echo -e '\033[32m'$argv[1]'\033[0m'
end
function Y
    echo -e '\033[33m'$argv[1]'\033[0m'
end
function R
    echo -e '\033[31m'$argv[1]'\033[0m'
end

