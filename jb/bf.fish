#!/usr/bin/env fish

# 根目录地址
set root (string split ' ' (string match '* /' (df)))

if df | grep -q ' /mnt'
    sudo umount /mnt
end
sudo mount $root[1] /mnt; or begin
    echo 挂载根目录失败 $root[1]
    exit 1
end
sudo btrfs subvolume delete -c /mnt/b; or begin
    echo 删除子卷失败
    exit 2
end
sudo btrfs subvolume snapshot /mnt/a /mnt/b;
and sudo mkinitcpio -g /boot/initramfs-linux-b.img; or begin
    echo 创建备份失败
    exit 3
end
sudo umount /mnt
echo 备份成功


