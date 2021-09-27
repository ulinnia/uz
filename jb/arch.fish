#!/usr/bin/env fish

# 输出颜色
function N
    echo -e $argv[1]
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

# 初始变量
function init_variable
    set git_url 'https://github.com/rraayy246/uz'
    set base_pkg 'base base-devel linux linux-firmware fish reflector'
    set PASS '7777777'
end

# 系统检查
function system_check
    # 请用超级用户执行此脚本
    if test "$USER" != 'root'
        R 'please use super user to execute this script.'
        R 'use command: "sudo su" and try again.'
        exit 1
    end

    # 系统变量
    if test -d /sys/firmware/efi
        set bios_type 'uefi'
    else
        set bios_type 'bios'
    end
    if lscpu | grep AuthenticAMD &>/dev/null
        set cpu_vendor 'amd'
    else if lscpu | grep GenuineIntel &>/dev/null
        set cpu_vendor 'intel'
    end
end

# 主程序
function main
    init_variable
    system_check
end

main

