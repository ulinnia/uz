#!/bin/bash

# 输出颜色
N(){ echo -e $1; }
G(){ echo -e '\033[32m'$1'\033[0m'; }
Y(){ echo -e '\033[33m'$1'\033[0m'; }
R(){ echo -e '\033[31m'$1'\033[0m'; }

# 初始变量
var_init(){
    git_url='https://github.com/rraayy246/uz'
    base_pkg='base base-devel linux linux-firmware fish reflector'
    PASS='7777777'
}

# 系统检查
system_check(){
    # 请用超级用户执行此脚本
    if test "$USER" != 'root'; then
        R 'please use super user to execute this script.'
        R 'use command: "sudo su" and try again.'
        exit 1
    fi

    # 系统变量
    if test -d /sys/firmware/efi; then
        bios_type='uefi'
    else
        bios_type='bios'
    fi
    if lscpu | grep -q 'AuthenticAMD'; then
        cpu_vendor='amd'
    elif lscpu | grep -q 'GenuineIntel'; then
        cpu_vendor='intel'
    fi
}

# 用户输入变量
var_user(){
    read -rp 'R "enter your username"' username ans
    read -rp 'R "enter your hostname"' hostname ans
}

# 帮助文档
doc_help(){
    G 'a script to install arch linux on live environment.'
    N
    N 'Optional arguments:'
    N '  -h --help     Show this help message and exit.'
    N '  -s --ssh      Open SSH service and exit.'
    N '  -w --wifi     Connect to a WIFI and exit.'
}

# 选项功能
options(){
    case "$1" in
        -h | --help)
            doc_help
            exit 0;
            ;;
        -s | --ssh)
            open_ssh
            exit 0;
            ;;
        -w | --wifi)
            connect_internet
            exit 0;
            ;;
    esac
}

# 连接网络
connect_internet(){
    if ! network_check; then
        # 启动 DHCP
        dhcpcd &>/dev/null
        while ! network_check; do
            connect_wifi
        done
    fi
}

# 连接 wifi
connect_wifi(){
    # 取得网络设备名称
    local iw_dev=$(iw dev | awk '$1=="Interface"{print $2}')

    iwctl station $iw_dev scan
    iwctl station $iw_dev get-networks
    read -rp 'R "ssid you want to connect to: "' ssid ans
    iwctl station $iw_dev connect $ssid
}

# 网络检查
network_check(){
    if ping -c 1 -w 1 1.1.1.1 &>/dev/null; then
        # 更新系统时间
        timedatectl set-ntp true
        G 'Network connection is successful.'
        return 0
    else
        R 'Network connection failed.'
        return 1
    fi
}

# 连接 ssh
open_ssh(){
    echo $USER':'$PASS | chpasswd &>/dev/null
    systemctl start sshd
    local interface=$(ip -o -4 route show to default | awk '{print $5}')
    local ip=$(ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    G
    G '$ ssh '$USER'@'$ip
    G 'passwd = '$PASS
    G
}

# 磁盘分区
disk_partition(){
    R 'automatic partition or manual partition: '
    select ans in 'automatic' 'manual'; do
        if test "$ans" != ''; then
            break
        fi
    done

    if test "$ans" == 'automatic'; then
        # 选择硬盘
        select_part root
        # 创建 GPT 分区表
        parted /dev/$part mklabel gpt
        if test "$bios_type" == 'uefi'; then
            # 创建启动分区
            parted /dev/$part mkpart esp 1m 513m
            # 设置 esp 为启动分区
            parted /dev/$part set 1 boot on
            # 创建根分区
            parted /dev/$part mkpart arch 513m -1m
        else
            # 创建启动分区
            parted /dev/$part mkpart grub 1m 3m
            # 设置 grub 为启动分区
            parted /dev/$part set 1 bios_grub on
            # 创建根分区
            parted /dev/$part mkpart arch 3m -1m
        fi

        # 自动选择分区
        if echo "$part" | grep -q 'nvme'; then
            part_boot='/dev/'$part'p1'
            part_root='/dev/'$part'p2'
        else
            part_boot='/dev/'$part'1'
            part_root='/dev/'$part'2'
        fi
    else
        # 手动选择分区
        select_part boot
        part_boot='/dev/'$part
        select_part root
        part_root='/dev/'$part
    fi
    mount_subvol
}

# 选择分区
select_part(){
    # 列出现有分区
    lsblk
    list_part=$(sudo lsblk -l | awk '{ print $1 }')
    R 'select a partition as the '$1' partition: '
    R '(enter a non-number for manual operation)'
    # 选择分区
    select part in ${list_part[@]/NAME}; do
        if test "$part" == ''; then
            R 'type "exit" to continue selecting partition'
            bash
            continue
        fi
        break
    done
}

# 挂载子卷
mount_subvol(){
    mkfs.btrfs -fL arch $part_root
    mount $part_root /mnt

    # 创建子卷
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/home
    btrfs subvolume create /mnt/srv
    btrfs subvolume create /mnt/swap
    btrfs subvolume create /mnt/tmp
    btrfs subvolume create /mnt/var
    btrfs subvolume create /mnt/snap
    btrfs subvolume create /mnt/snap/root
    btrfs subvolume create /mnt/snap/home
    btrfs subvolume create /mnt/cache
    btrfs subvolume create /mnt/cache/$username
    umount /mnt

    # 挂载子卷
    mount -o autodefrag,compress=zstd,subvol=@ $part_root /mnt

    mkdir /mnt/btrfs
    mkdir /mnt/home
    mkdir /mnt/srv
    mkdir /mnt/swap
    mkdir /mnt/tmp
    mkdir /mnt/var
    mkdir /mnt/.snapshots
    mkdir /mnt/home/.snapshots
    mkdir -p /mnt/home/$username/.cache

    mount $part_root /mnt/btrfs
    mount -o subvol=home $part_root /mnt/home
    mount -o subvol=srv $part_root /mnt/srv
    mount -o subvol=swap $part_root /mnt/swap
    mount -o subvol=tmp $part_root /mnt/tmp
    mount -o subvol=var $part_root /mnt/var
    mount -o subvol=snap/root $part_root /mnt/.snapshots
    mount -o subvol=snap/home $part_root /mnt/home/.snapshots
    mount -o subvol=cache/$username $part_root /mnt/home/$username/.cache

    # 避免 /var/lib 资料遗失
    mkdir -p /mnt/{usr/var/lib,var/lib}
    mount --bind /mnt/usr/var/lib /mnt/var/lib
    # efi 目录挂载
    if test "$bios_type" == 'uefi'; then
        mkdir /mnt/efi
        mount $part_root /mnt/efi
    fi
}

# 安装基础包
base_install(){
    # 更新密钥环
    pacman -Sy archlinux-keyring

    # 镜像排序
    N 'sorting mirror...'
    pacman -S --noconfirm reflector &>/dev/null
    reflector --latest 9 --protocol https --save /etc/pacman.d/mirrorlist --sort delay

    # 安装必须软件包
    pacstrap /mnt $base_pkg
}

# 切换根目录
arch_chroot(){
    # 设置主机名
    echo $hostname > /etc/hostname

    # 复制镜像
    cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d

    # 生成 fstab 文件
    genfstab -L /mnt >> /mnt/etc/fstab

    # 下载脚本
    wget $git_url/raw/master/jb/arch.fish -O /mnt/arch.fish
    chmod +x /mnt/arch.fish

    # 切换根目录
    arch-chroot /mnt /bin/fish -c '/arch.fish -i'
    # 切换根目录结束
    rm /mnt/arch.fish
    umount -R /mnt
    R 'please reboot.'
}

# 主程序
main(){
    var_init
    system_check
    var_user
    options $@
    connect_internet
    disk_partition
    base_install
    arch_chroot
}

main

