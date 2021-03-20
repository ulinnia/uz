#!/usr/bin/env fish

# 警告
read -p '# 即将进行备份，确定？' rrr
if test "$rrr" != 'y'
    exit 1
end

# 根目录地址
set root (string split ' ' (string match '* /' (df)))

sudo umount /mnt
sudo mount $root[1] /mnt
sudo btrfs subvolume delete -c /mnt/b
sudo btrfs subvolume snapshot -r /mnt/a /mnt/b
