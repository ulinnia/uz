# Arch Linux (UEFI with GPT) 安装

### 检查网络时间

测试网络

```shell
ping www.163.com
```

更新系统时间

```shell
timedatectl set-ntp true
```

### 磁盘分区

查看磁盘

```shell
fdisk -l
```

新建分区表

```shell
fdisk /dev/nvme0n1
```

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
    4. 分区结束扇区号，输入 +2G
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


