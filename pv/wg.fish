#! /bin/fish

set config_dir "$HOME"/.wireguard/

mkdir -p $config_dir
cd $config_dir || begin
    echo 切换目录失败，程序退出
    exit
end
# 生成两对密钥，分别用作服务器和客户端使用
wg genkey | tee pri1 | wg pubkey >pub1
wg genkey | tee pri2 | wg pubkey >pub2

# 设置密钥访问权限
chmod 600 pri1
chmod 600 pri2

set interface (ip -o -4 route show to default | awk '{print $5}')
set ip (ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# 生成服务端配置文件
echo "\
[Interface]
PrivateKey = "(cat pri1)"
Address = 10.10.10.1
ListenPort = 54321
PostUp   = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o "$interface" -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o "$interface" -j MASQUERADE
[Peer]
PublicKey = "(cat pub2)"
AllowedIPs = 10.10.10.2/32
" > wg0.conf

# 生成客户端配置文件
echo "\
[Interface]
PrivateKey = "(cat pri2)"
Address = 10.10.10.2
DNS = 8.8.8.8

[Peer]
PublicKey = "(cat pub1)"
Endpoint = "$ip":54321
AllowedIPs = 0.0.0.0/0
" > client.conf

# 复制配置文件并启动
sudo cp wg0.conf /etc/wireguard/ || begin
    echo 复制失败,请检查/etc/wireguard目录或wg0.conf是否存在
    exit
end
sudo systemctl start wg-quick@wg0 || begin
    echo 启动wireguard失败，请检查/etc/wireguard/wg0.conf是否存在错误
    exit
end

sudo systemctl enable --now wg-quick@wg0

# 显示客户端配置文件
echo "----------以下是客户端配置文件，请保存并在客户端中使用----------"
cat client.conf

echo "----------以下是客户端配置二维码----------"
qrencode -t ansiutf8 <client.conf


