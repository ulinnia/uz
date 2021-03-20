# 安装 Arch (VPS 和 BIOS)

## 安装前的准备

### 上传 Arch Linux 镜像

<https://www.archlinux.org/download/>

将镜像上传到 VPS 上。然后打开 VNC。

# 启动到 Live 环境

进入闪盘的启动引导程序后，选择第一项：Arch Linux archiso

### 联网

`# ip addr` 查看网卡

比如我的网卡是 `ens3`

`# vim /etc/systemd/network/w.network` 设置网络

写入`网卡名称`和 VPS 提供的`IP地址/网络掩码、网路遮罩、默认网关`如下：

```
[Match]
Name=ens3

[Network]
Address=104.168.142.56/24
Netmask=255.255.255.0
Gateway=104.168.142.1
DNS=1.1.1.1
```

命令模式下按 `i` 输入，按 `ESC` 回到命令模式，`:x` 保存退出。

`# systemctl enable --now systemd-networkd` 应用网络设定

`# ping 1.1.1.1` 测试有没连上网

`# timedatectl set-ntp true` 更新系统时间

`# pacman -Sy archlinux-keyring` 更新密钥环

### 建立硬盘分区

`# parted -l` 查看硬盘设备

我要把系统安装在 vda 这个硬盘中

`# parted /dev/vda` 打开分区

命令提示符会从 `#` 变成 `(parted)`

`(parted) mklabel gpt` 创建 GPT 分区表

`(parted) mkpart grub fat32 1m 3m` 创建启动分区 (vda1)

`(parted) set 1 bios_grub on` 设置启动分区

`(parted) mkpart root btrfs 3m 100%` 创建根分区 (vda2)

`(parted) p` 查看分区结果

`(parted) q` 退出 parted 交互模式

### 格式化分区

`# mkfs.fat -F32 /dev/vda1` 假装格式化 Grub 分区，免得无法挂载

`# mkfs.btrfs --label arch /dev/vda2` 格式化根分区为 Brtfs 格式

### 挂载分区

`# mount -o autodefrag,compress=zstd /dev/vda2 /mnt` 挂载根分区并启用碎片整理和压缩

`# mkdir /mnt/boot` 创建启动目录

`# mount /dev/vda1 /mnt/boot` 挂载启动分区

## 安装

### 安装必须软件包

`# pacstrap /mnt base base-devel linux linux-firmware fish` 安装基本包和 Fish

## 配置系统

### Fstab

`# genfstab -L /mnt >> /mnt/etc/fstab` 生成 fstab 文件

可选用 `cat /mnt/etc/fstab` 检查 fstab 文件

### 切换根目录

`# arch-chroot /mnt` 切换至安装好的 Arch

### 安装基本软件包

`# fish` 使用 fish，补全更智能

`# pacman -S btrfs-progs grub vim` 安装必要软件

### 设置时区

`# ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime` 设置时区

`# hwclock --systohc` 设置时间标准为 UTC

### 本地化

`# vim /etc/locale.gen` 修改本地化信息

移除 en_US.UTF-8 UTF-8 、zh_CN.UTF-8 UTF-8 前面的 # 后保存。

按 `x` 删除当前光标所在处的字符，按 `u` 撤消最后执行的命令，`:x`  命令保存文件并退出。

`# locale-gen` 生成本地化信息

`# echo LANG=en_US.UTF-8 > /etc/locale.conf` 将系统语言设置为英文，避免乱码

`# echo 主机名 > /etc/hostname` 修改主机名

### 网络配置

`# vim /etc/hosts` 编辑主机表

加入以下字串：

```shell
主机IP      localhost
::1         localhost
主机IP      主机名.localdomain 主机名
```

按 `o` 切换到下行输入模式，按 `ESC` 回到命令模式，`:x` 命令保存文件并退出


### 设置网络

`# vim /etc/systemd/network/w.network` 设置网络

写入`网卡名称`和 VPS 提供的`IP地址/网络掩码、网路遮罩、默认网关`如下：

```
[Match]
Name=ens3

[Network]
Address=104.168.142.56/24
Netmask=255.255.255.0
Gateway=104.168.142.1
DNS=1.1.1.1
```
命令模式下按 `i` 输入，按 `ESC` 回到命令模式，`:x` 保存退出。

`# systemctl enable --now systemd-networkd` 应用网络设定

`# passwd` 修改 root 密码

### 安装引导程序

`# grub-install --target=i386-pc /dev/vda` 安装 grub

`# grub-mkconfig -o /boot/grub/grub.cfg` 生成主配置文件

### 重启

`# exit` 退出 Fish

`# exit` 退出 chroot 环境

`# systemctl poweroff` 关机


