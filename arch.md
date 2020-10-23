# Arch Linux (UEFI with GPT) 安装

## 检查网络时间

测试网络是否可用，安装过程中需要用到网络

```shell
ping www.163.com
```

更新系统时间

```shell
timedatectl set-ntp true
```

## 磁盘分区

查看磁盘设备

```shell
fdisk -l
```

新建分区表

```shell
fdisk /dev/nvme0n1
```


我要把系统安装在nvme0n1这个硬盘中

nvme0n1是固态硬盘，sda是普通硬盘

1. 输入 g，新建 GPT 分区表
2. 输入 w，保存修改，这个操作会抹掉磁盘所有数据，慎重

分区创建

```shell
fdisk /dev/nvme0n1
```

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
    4. 分区结束扇区号，直接 Enter，选择剩下全部
    5. 输入 t 修改分区类型
    6. 选择分区区号，输入 2，选择刚创建的分区
    7. 输入 24，使用 Linux root (x86-64) 类型
4. 保存新建的分区
    1. 输入 w

## 磁盘格式化

格式化 EFI System 分区为 fat32 格式

```shell
mkfs.fat -F32 /dev/nvme0n1p1
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

```shell
pacman -S amd-ucode dhcpcd efibootmgr grub os-prober vim
```

amd-ucode 为 AMD CPU 微码，使用 Intel CPU 者替换成 intel-ucode

```shell
vim /etc/locale.gen
```
修改本地化信息，移除 en_US.UTF-8 UTF-8 、zh_CN.UTF-8 UTF-8前面的 # 后保存。

生成本地化信息

```shell
locale-gen
```

```shell
echo LANG=en_US.UTF-8 > /etc/locale.conf
```


