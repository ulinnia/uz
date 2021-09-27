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
        set base_pkg $base_pkg 'efibootmgr'
    else
        set bios_type 'bios'
        set base_pkg $base_pkg 'dosfstools'
    end
    if lscpu | grep AuthenticAMD &>/dev/null
        set cpu_vendor 'amd'
        set base_pkg $base_pkg 'amd-ucode'
    else if lscpu | grep GenuineIntel &>/dev/null
        set cpu_vendor 'intel'
        set base_pkg $base_pkg 'intel-ucode'
    end
end

# 初始变量
function var_init
    set git_url 'https://github.com/rraayy246/uz'
    set base_pkg 'btrfs-progs dhcpcd grub os-prober vim'
    set area 'Asia/Shanghai'
    set PASS '7777777'
end

# 用户输入变量
function var_user
    read -rp 'R "enter your username"' username
    read -rp 'R "enter your hostname"' hostname
end

# 本地化
function local_set
    ln -sf /usr/share/zoneinfo/$area /etc/localtime
    hwclock --systohc
    sed -i '/\(en_US\|zh_CN\).UTF-8/s/#//' /etc/locale.gen
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf
end

# 主程序
function main
    system_check
    var_init
    var_user
end

main

