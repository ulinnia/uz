#!/usr/bin/env fish

# 根分区名
set 根分区 (string split ' ' (string match '* /' (df)))

if df | grep -q ' /mnt'
    sudo umount /mnt; or begin
        echo 卸载 /mnt 失败
        exit
    end
end
sudo mount $根分区[1] /mnt; or begin
    echo 挂载根分区失败 $根分区[1]
    exit
end
sudo btrfs subvolume delete -c /mnt/b; or begin
    if sudo btrfs subvolume list /mnt | grep -q 'path b'
        echo 删除子卷失败
        exit
    end
end
sudo btrfs subvolume snapshot /mnt/a /mnt/b;
and sudo mkinitcpio -g /boot/initramfs-linux-b.img; or begin
    echo 创建备份失败
    exit
end
sudo umount /mnt

echo
echo 备份成功！


