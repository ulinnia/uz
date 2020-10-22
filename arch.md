# Arch Linux (UEFI with GPT) 安装

测试网络

```shell
ping www.163.com
```

更新系统时间

```shell
timedatectl set-ntp true
```

查看磁盘

```shell
fdisk -l
```

新建分区表

```shell
fdisk /dev/nvme0n1
```

-输入 g，新建 GPT 分区表
-输入 w，保存修改，这个操作会抹掉磁盘所有数据，慎重

分区创建

```shell
fdisk /dev/nvme0n1
```shell

-新建 EFI System 分区
 -输入 n\n2.选择分区区号，直接 Enter，使用默认值，fdisk 会自动递增分区号\n3.分区开始扇区号，直接 Enter，使用默认值\n4.分区结束扇区号，输入 +512M（推荐大小）\n5.输入 t 修改刚刚创建的分区类型\n6.输入 1，使用 EFI System 类型\n7.选择分区号，直接 Enter， 使用默认值，fdisk 会自动选择刚刚新建的分区"
