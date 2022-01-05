sudo pacman -S --noconfirm caddy

# 创建日志目录
sudo mkdir /var/log/caddy
sudo chown -R caddy: /var/log/caddy

# 增加 UDP 缓冲区大小
echo 'net.core.rmem_max = 2500000' | sudo tee /etc/sysctl.d/rmem_max.conf
sudo sysctl (cat /etc/sysctl.d/rmem_max.conf | sed 's/ //g')

