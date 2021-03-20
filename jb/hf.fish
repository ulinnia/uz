#!/usr/bin/env fish

# 警告
echo '即将恢复上次备份，确定？'
read rrr
if test "$rrr" != 'y'
    exit 1
end

# 根目录地址
set root (string split ' ' (string match '* /' (df)))

sudo umount /mnt
sudo mount $root[1] /mnt
sudo btrfs send -p /mnt/a /mnt/c | sudo btrfs receive /mnt/a
