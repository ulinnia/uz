

# 增加 UDP 接收缓冲区大小
if not sudo grep -q 'net.core.rmem_max' /etc/sysctl.d/99-sysctl.conf
    echo 'net.core.rmem_max = 2500000' | sudo tee -a /etc/sysctl.d/99-sysctl.conf
    sudo sysctl (bat /etc/sysctl.d/99-sysctl.conf | sed 's/ //g')
end
