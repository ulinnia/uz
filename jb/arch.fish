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
    # 是不是虚拟机
    if (systemd-detect-virt) == 'none'
        set is_virt 0
    else
        set is_virt 1
    end
    # 引导加载程序
    if test -d /sys/firmware/efi
        set bios_type 'uefi'
        set base_pkg $base_pkg 'efibootmgr'
    else
        set bios_type 'bios'
        set base_pkg $base_pkg 'dosfstools'
    end
    # 根分区
    set root_part (df | awk '$6=="/" {print $1}')
    # cpu 型号
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
    set username (ls /home)
    set hostname (cat /etc/hostname)
end

# 本地化
function local_set
    # 安装基本软件包
    pacman -S $base_pkg
    # 设置时区
    ln -sf /usr/share/zoneinfo/$area /etc/localtime
    # 同步时钟
    hwclock --systohc
    # 语言信息
    sed -i '/\(en_US\|zh_CN\).UTF-8/s/#//' /etc/locale.gen
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf
    # 主机表
    echo -e '127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t'$hostname'.localdomain '$hostname | sudo tee -a /etc/hosts

    # 设定根密码
    R 'enter your root passwd: '
    passwd

    # 安装引导程序
    if test $bios_type == 'uefi'
        grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=grub
    else
        if echo $root_part | grep 'nvme'
            set grub_part (echo $i | sed 's/p[0-9]$//')
        else
            set grub_part (echo $i | sed 's/[0-9]$//')
        end
        grub-install --target=i386-pc $grub_part
    end
    # 生成 grub 主配置文件
    grub-mkconfig -o /boot/grub/grub.cfg
end

# 主程序
function main
    system_check
    var_init
    var_user
    local_set
end

main

