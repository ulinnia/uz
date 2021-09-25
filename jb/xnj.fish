# qemu，图形界面
sudo pacman -S qemu libvirt virt-manager
# 连接网络，UEFI 支持
sudo pacman -S iptables-nft dnsmasq bridge-utils openbsd-netcat edk2-ovmf

# 加入 libvirt 组以获得权限
echo '/* 允许 kvm 组中的用户管理 libvirt 的守护进程  */
polkit.addRule(function(action, subject) {
  if (action.id == "org.libvirt.unix.manage" &&
    subject.isInGroup("kvm")) {
      return polkit.Result.YES;
  }
});' | sudo tee /etc/polkit-1/rules.d/50-libvirt.rules

# 加入 kvm 组
sudo usermod -a -G kvm (whoami)

# 启动服务
sudo systemctl enable --now libvirtd

echo '这个脚本将输出您的 PCI 设备是如何被分配到 IOMMU 组之中的。'
echo 'shopt -s nullglob
for g in `find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V`; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;' | bash

function 处理器
    if bat /proc/cpuinfo | string match -iq '*vendor*amd*'
        echo amd
    else if bat /proc/cpuinfo | string match -i '*vendor*intel*'
        echo intel
    end
end

sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/quiet/& '(处理器)'_iommu=on iommu=pt/' /etc/default/grub
