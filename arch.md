# Arch Linux (UEFI with GPT) 安装

## 下载 Arch Linux 镜像

<https://www.archlinux.org/download/>

验证镜像完整性 `md5 archlinux.iso`

将输出和下载页面提供的 md5 值对比一下，看看是否一致，不一致则不要继续安装，换个节点重新下载直到一致为止。

## 镜像写入 U 盘

查看设备 `sudo fdisk -l`

/dev/sdx是我的U盘设备，umount U盘 `sudo umount /dev/sdx*`

格式化U盘 `sudo mkfs.vfat /dev/sdx –I`

镜像写入 U 盘 `dd bs=4M if=/path/to/archlinux.iso of=/dev/sdx status=progress && sync`

## 从 U 盘启动 Arch live 环境

在 UEFI BIOS 中设置启动磁盘为刚刚写入 Arch 系统的 U 盘。

进入 U 盘的启动引导程序后，选择第一项：Arch Linux archiso x86_64 UEFI CD

## 检查网络时间

查看连接 `ip link`

对于有线网络，安装镜像启动的时候，默认会启动 dhcpcd，如果没有启动，可以手动启动：`dhcpcd`

无线网络请使用 wifi-menu

测试网络是否可用，安装过程中需要用到网络 `ping www.163.com`

更新系统时间 `timedatectl set-ntp true`

## 磁盘分区

查看磁盘设备 `fdisk -l`

新建分区表 `fdisk /dev/nvme0n1`


我要把系统安装在nvme0n1这个硬盘中

nvme0n1是固态硬盘，sda是普通硬盘

1. 输入 g，新建 GPT 分区表
2. 输入 w，保存修改，这个操作会抹掉磁盘所有数据，慎重

分区创建 `fdisk /dev/nvme0n1`

1. 新建 EFI System 分区
    1. 输入 n
    2. 选择分区区号，直接 Enter，使用默认值，fdisk 会自动递增分区号
    3. 分区开始扇区号，直接 Enter，使用默认值
    4. 分区结束扇区号，输入 +512M（推荐大小）
    5. 输入 t 修改刚刚创建的分区类型
    6. 输入 1，使用 EFI System 类型
2. 新建 Linux swap 分区
    1. 输入 n
    2. 选择分区区号，输入 3
    3. 分区开始扇区号，直接 Enter，使用默认值
    4. 分区结束扇区号，输入 +2G（512M~2G可选）
    5. 输入 t 修改分区类型
    6. 选择分区区号，输入 3，选择刚创建的分区
    7. 输入 19，使用 Linux swap 类型
3. 新建 Linux root (x86-64) 分区
    1. 输入 n
    2. 选择分区区号，输入 2
    3. 分区开始扇区号，直接 Enter，使用默认值
    4. 分区结束扇区号，直接 Enter，选择全部剩余空间
    5. 输入 t 修改分区类型
    6. 选择分区区号，输入 2，选择刚创建的分区
    7. 输入 24，使用 Linux root (x86-64) 类型
4. 保存新建的分区
    1. 输入 w

## 磁盘格式化

格式化 EFI System 分区为 fat32 格式 `mkfs.fat -F32 /dev/nvme0n1p1`

如果格式化失败，可能是磁盘设备存在 Device Mapper：
```shell
dmsetup status #显示 dm 状态
dmsetup remove <dev-id> #删除 dm
```

格式化 Linux root 分区为 brtfs 格式

```shell
mkfs.btrfs -f /dev/nvme0n1p2
```

格式化 Linux swap 分区

```shell
mkswap /dev/nvme0n1p3
swapon /dev/nvme0n1p3
```

## 挂载文件系统

```shell
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

配置 pacman mirror 镜像源

```shell
vim /etc/pacman.d/mirrorlist
```

找到标有China的镜像源，normal模式下按下dd可以剪切光标下的行，按gg回到文件首，按P（注意是大写的）将行粘贴到文件最前面的位置（优先级最高）。

更新mirror数据库

```shell
pacman -Syy
```

安装 Arch 和 Package Group

```shell
pacstrap /mnt base base-devel linux linux-firmware
```

生成 fstab 文件

```shell
genfstab -U /mnt >> /mnt/etc/fstab
```

切换至安装好的 Arch

```shell
arch-chroot /mnt
```

## 本地化

安装必要软件

```shell
pacman -S amd-ucode btrfs-progs dhcpcd efibootmgr grub os-prober vim
```

amd-ucode 为 AMD CPU 微码，使用 Intel CPU 者替换成 intel-ucode

因为本次安装使用btrfs文件系统，所以要安装 btrfs-progs

设置时区

```shell
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc
```

修改本地化信息

```shell
vim /etc/locale.gen
```
移除 en_US.UTF-8 UTF-8 、zh_CN.UTF-8 UTF-8前面的 # 后保存。

生成本地化信息

```shell
locale-gen
```

将系统 locale 设置为en_US.UTF-8

```shell
echo LANG=en_US.UTF-8 > /etc/locale.conf
```

修改主机名为 myhostname

```shell
echo myhostname > /etc/hostname
```

编辑hosts

```shell
vim /etc/hosts
```

加入以下字串（myhostname 替换为主机名）

```shell
127.0.0.1 localhost
::1    localhost
127.0.1.1 myhostname.localdomain myhostname
```

设置dhcpcd自启动

```shell
systemctl enable dhcpcd
```

修改root密码

```shell
passwd
```

安装GRUB引导程序

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
```

重新启动

```shell
exit  #退出 chroot 环境
umount -R /mnt #手动卸载被挂载的分区
reboot
```

