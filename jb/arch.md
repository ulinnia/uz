# Arch Linux (UEFI with GPT) 安装

## 安装前的准备

### 下载 Arch Linux 镜像

<https://www.archlinux.org/download/>

`md5sum archlinux.iso` 验证镜像完整性

将输出和下载页面提供的 md5 值对比一下，看看是否一致，不一致则不要继续安装，换个节点重新下载直到一致为止。

### 镜像写入 U 盘

`sudo fdisk -l` 查看设备

`sudo umount /dev/sdx*` /dev/sdx是我的U盘设备，umount U盘。

`sudo cp path/to/archlinux.iso /dev/sdx` 镜像写入 U 盘

windows 用户请使用 rufus

### 启动到 live 环境

在 UEFI BIOS 中设置启动硬盘为刚刚写入 Arch 系统的 U 盘。

进入 U 盘的启动引导程序后，选择第一项：Arch Linux archiso x86_64 UEFI CD

### 检查网络

可选用 `ip link` 查看连接

对于有线网络，安装镜像启动的时候，默认会启动 dhcpcd，如果没有启动，可以手动启动：`dhcpcd`

无线网络请使用 `wifi-menu`

可选用 `ping www.163.com` 测试网络是否可用，安装过程中需要用到网络

### 更新系统时间

`timedatectl set-ntp true` 更新系统时间

### 建立硬盘分区

`fdisk -l` 查看硬盘设备

`fdisk /dev/nvme0n1` 新建分区表


我要把系统安装在nvme0n1这个硬盘中

nvme0n1是固态硬盘，sda是普通硬盘

1. 输入 `g`，新建 GPT 分区表
2. 输入 `w`，保存修改，这个操作会抹掉硬盘所有数据，慎重

`fdisk /dev/nvme0n1` 分区创建

1. 新建 EFI System 分区
    1. 输入 `n`
    2. 选择分区区号，直接 `Enter`，使用默认值，fdisk 会自动递增分区号
    3. 分区开始扇区号，直接 `Enter`，使用默认值
    4. 分区结束扇区号，输入 `+512M`（推荐大小）
    5. 输入 `t` 修改刚刚创建的分区类型
    6. 输入 `1`，使用 EFI System 类型
2. 新建 Linux root (x86-64) 分区
    1. 输入 `n`
    2. 选择分区区号，直接 `Enter`，使用默认值，fdisk 会自动递增分区号
    3. 分区开始扇区号，直接 `Enter`，使用默认值
    4. 分区结束扇区号，直接 `Enter`，选择全部剩余空间
    5. 输入 `t` 修改分区类型
    6. 选择分区区号，直接 `Enter`，选择刚创建的分区
    7. 输入 `23`，使用 Linux root (x86-64) 类型
3. 保存新建的分区
    1. 输入 `w`

### 格式化分区

`mkfs.fat -F32 /dev/nvme0n1p1` 格式化 EFI System 分区为 fat32 格式

如果格式化失败，可能是硬盘设备存在 Device Mapper：`dmsetup status` 显示 dm 状态 `dmsetup remove <dev-id>` 删除 dm

`mkfs.btrfs -f /dev/nvme0n1p2` 格式化 Linux root 分区为 brtfs 格式

### 挂载分区

```shell
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

## 安装

### 选择镜像

`vim /etc/pacman.d/mirrorlist` 配置 pacman mirror 镜像源

找到标有China的镜像源，命令模式下按下 `dd` 可以剪切光标下的行，按 `gg` 回到文件首，按 `P`（注意是大写的）将行粘贴到文件最前面的位置（优先级最高）。

最后记得用 `:wq` 命令保存文件并退出。

### 安装必须软件包

`pacman -Syy` 更新mirror数据库

`pacstrap /mnt base base-devel linux linux-firmware fish` 安装 Arch 和 Package Group 和 fish

## 配置系统

### Fstab

`genfstab -U /mnt >> /mnt/etc/fstab` 生成 fstab 文件

可选用 `cat /mnt/etc/fstab` 检查fstab文件

### 切换根目录

`arch-chroot /mnt` 切换至安装好的 Arch

## 安装基本软件包

`fish` 使用 fish，补全更智能

`pacman -S amd-ucode btrfs-progs dhcpcd efibootmgr grub os-prober vim` 安装必要软件

amd-ucode 为 AMD CPU 微码，使用 Intel CPU 者替换成 intel-ucode

因为本次安装使用btrfs文件系统，所以要安装 btrfs-progs。

### 设置时区

`ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime` 设置时区

`hwclock --systohc` 设置时间标准为UTC

### 本地化

`vim /etc/locale.gen` 修改本地化信息

移除 en_US.UTF-8 UTF-8 、zh_CN.UTF-8 UTF-8前面的 # 后保存。

按 `x` 删除当前光标所在处的字符，按 `u` 撤消最后执行的命令，`:x` 命令保存文件并退出。

`locale-gen` 生成本地化信息

`echo LANG=en_US.UTF-8 > /etc/locale.conf` 将系统 locale 设置为en_US.UTF-8

`echo 主机名 > /etc/hostname` 修改主机名

### 网络配置

`vim /etc/hosts` 编辑hosts

加入以下字串

```shell
127.0.0.1       localhost
::1             localhost
127.0.1.1       主机名.localdomain 主机名
```

按 `o` 切换到下行输入模式，按 `ESC` 回到命令模式，`:x` 命令保存文件并退出。

`systemctl enable dhcpcd` 设置dhcpcd自启动

### Root 密码

`passwd` 修改root密码

### 安装引导程序

`grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub` 安装 grub

`grub-mkconfig -o /boot/grub/grub.cfg` 生成主配置文件

可选用 `vim /boot/grub/grub.cfg` 检查 grub 文件

### 重启

`exit` 退出 fish

`exit` 退出 chroot 环境

可选用 `umount -R /mnt` 手动卸载被挂载的分区

`reboot` 重启时，记得移除安装介质

## 搭建桌面环境

以root登入

### 创建用户

`useradd -m 用户名` 创建新用户

`passwd 用户名` 设置登陆密码

`vim /etc/sudoers` 编辑sudo权限

复制一行 root ALL=(ALL) ALL，并替换其中的root为新用户名，`:x!` 强制保存并退出。

`exit` 退出root用户，并登陆新创建的用户。

## 快速配置 arch

```shell
sudo pacman -S curl
sh -c "$(curl -fsSL https://github.com/rraayy246/uz/raw/master/jb/arch.sh)"
```
