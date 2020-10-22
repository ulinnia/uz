#测试网络
ping www.163.com
#更新系统时间
timedatectl set-ntp true
#查看磁盘
fdisk -l
#新建分区表
fdisk /dev/nvme0n1
echo -e "1.输入 g，新建 GPT 分区表\n2.输入 w，保存修改，这个操作会抹掉磁盘所有数据，慎重"
#分区创建
fdisk /dev/nvme0n1
#新建 EFI System 分区
echo -e "新建 EFI System 分区\n1.输入 n\n2.选择分区区号，直接 Enter，使用默认值，fdisk 会自动递增分区号\n3.分区开始扇区号，直接 Enter，使用默认值\n4.分区结束扇区号，输入 +512M（推荐大小）\n5.输入 t 修改刚刚创建的分区类型\n6.输入 1，使用 EFI System 类型\n7.选择分区号，直接 Enter， 使用默认值，fdisk 会自动选择刚刚新建的分区"
