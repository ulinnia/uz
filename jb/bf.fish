#!/usr/bin/env fish

# 根目录地址
set root (string split ' ' (string match '* /' (df)))

sudo umount /mnt
sudo mount $root[1] /mnt
sudo btrfs subvolume delete -c /mnt/b
sudo btrfs subvolume snapshot /mnt/a /mnt/b
sudo umount /mnt
