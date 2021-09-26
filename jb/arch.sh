#!/bin/bash

# 输出颜色
N(){ echo -e "$1"; }
G(){ echo -e "\033[32m$1\033[0m"; }
Y(){ echo -e "\033[33m$1\033[0m"; }
R(){ echo -e "\033[31m$1\033[0m"; }

# 初始变量
init_variable(){
    git_url="https://github.com/rraayy246/uz"
    localtime="Asia/Shanghai"
    base_pkg="base base-devel linux linux-firmware fish"
    PASS="7777777"
}

# 系统检查
system_check(){
    # 请用超级用户执行此脚本
    if [ "$USER" != "root" ]; then
        R "please use super user to execute this script."
        R "use command: 'sudo su' and try again."
        exit 1
    fi

    # 系统变量
    if [ -d /sys/firmware/efi ]; then
        bios_type="uefi"
    else
        bios_type="bios"
    fi
    if lscpu | grep GenuineIntel &>/dev/null ; then
        cpu_vendor="intel"
    elif lscpu | grep AuthenticAMD &>/dev/null ; then
        cpu_vendor="amd"
    fi
}

# 帮助文档
doc_help(){
    G "a script to install arch linux on live environment."
    N
    N "Optional arguments:"
    N "  -h --help     Show this help message and exit."
    N "  -s --ssh      Open SSH service and exit."
    N "  -w --wifi     Connect to a WIFI and exit."
}

# 选项功能
options(){
    case ${1} in
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
    if ! network_check;then
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
    read -rp "R 'ssid you want to connect to: '" ssid
    iwctl station $iw_dev connect $ssid
}

# 网络检查
network_check(){
    if ping -c 1 -w 1 1.1.1.1 &>/dev/null; then
        # 更新系统时间
        timedatectl set-ntp true
        G "Network connection is successful."
        return 0
    else
        R "Network connection failed."
        return 1
    fi
}

# 连接 ssh
open_ssh(){
    echo "${USER}:${PASS}" | chpasswd &>/dev/null
    systemctl start sshd
    local interface=$(ip -o -4 route show to default | awk '{print $5}')
    local ip=$(ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    G
    G "$ ssh $USER@$ip"
    G "passwd = $PASS"
    G
}

# 磁盘分区
disk_partition(){
    R "automatic partition or manual partition: "
    select ans in 'automatic' 'manual'; do
        if [ "$ans" != "" ]; then
            break
        fi
    done

    if [ "$ans" == "automatic" ]; then
        select_part root
        # 创建 GPT 分区表
        parted /dev/$part mklabel gpt
        if [ "$bios_type" == "uefi" ]; then
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
    fi
    select_part boot
    part_boot="/dev/${part}"
    select_part root
    part_root="/dev/${part}"
    mount_subvol
}

# 选择分区
select_part(){
    lsblk
    list_part=$(sudo lsblk -l | awk '{ print $1 }')
    R "select a partition as the $1 partition: "
    R "(enter a non-number for manual operation)"
    select part in ${list_part[@]/NAME}; do
        if [ "$part" == "" ]; then
            R "type 'exit' to continue selecting partition"
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
    btrfs subvolume create /mnt/swap
    btrfs subvolume create /mnt/tmp
    btrfs subvolume create /mnt/var
    btrfs subvolume create /mnt/snap
    btrfs subvolume create /mnt/snap/root
    btrfs subvolume create /mnt/snap/home
    btrfs subvolume create /mnt/cache
    umount /mnt

    # 挂载子卷
    mount -o autodefrag,compress=zstd,subvol=@ $part_root /mnt

    mkdir /mnt/btrfs
    mkdir /mnt/home
    mkdir /mnt/swap
    mkdir /mnt/tmp
    mkdir /mnt/var
    mkdir /mnt/.snapshots
    mkdir /mnt/home/.snapshots
    mkdir -p /mnt/home/$username/.cache

    mount $part_root /mnt/btrfs
    mount -o subvol=home $part_root /mnt/home
    mount -o subvol=swap $part_root /mnt/swap
    mount -o subvol=tmp $part_root /mnt/tmp
    mount -o subvol=var $part_root /mnt/var
    mount -o subvol=snap/root $part_root /mnt/.snapshots
    mount -o subvol=snap/home $part_root /mnt/home/.snapshots
    mount -o subvol=cache $part_root /mnt/home/$username/.cache

    # 避免 /var/lib 资料遗失
    mount --bind /mnt/usr/var/lib /mnt/var/lib
    # efi 目录挂载
    if test "$bios_type" == "uefi"; then
        mkdir -p /mnt/boot/efi
        mount $part_root /mnt/boot/efi
    fi
}

# 主程序
main(){
    init_variable
    system_check
    options $@
    Y "(1/5) connect to internet..."
    connect_internet
    Y "(2/5) create disk partition..."
    disk_partition
}

main

