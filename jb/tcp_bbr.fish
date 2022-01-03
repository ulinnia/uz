# 为内核加载 bbr 模块
echo 'tcp_bbr' | sudo tee /etc/modules-load.d/modules.conf

# 将默认的拥塞算法设置为 bbr
echo 'net.core.default_qdisc=fq' | sudo tee /etc/sysctl.d/bbr.conf
echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.d/bbr.conf

echo 'please reboot.'

