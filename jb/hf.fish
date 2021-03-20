#!/usr/bin/env fish

# 警告
read -p '即将恢复上次备份，确定？' rrr
if test "$rrr" != 'y'
    exit 1
end

# 根目录地址
set root (string split ' ' (string match '* /' (df)))

sudo umount /mnt
sudo mount $root[1] /mnt
sudo btrfs subvolume delete -c /mnt/a
sudo btrfs subvolume snapshot /mnt/b /mnt/a
