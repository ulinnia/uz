#! /bin/fish

set config_dir "$HOME"/.wireguard/

mkdir -p $config_dir
cd $config_dir || begin
    echo 切换目录失败，程序退出
    exit
end
# 生成8对密钥，分别用作1服务器和7客户端使用
for i in (seq 8)
    wg genkey | tee pri"$i" | wg pubkey >pub"$i"
    # 设置密钥访问权限
    chmod 600 pri"$i"
end


function rand -a min -a max
    set max (math $max - $min + 1)
    set num (date +%s%N)
    echo (math $num % $max + $min)
end

set interface (ip -o -4 route show to default | awk '{print $5}')
set ip (ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
set port (rand 10000 60000)

# 打开流量转发
if not sudo grep -q 'ip_forward' /etc/sysctl.d/99-sysctl.conf
    echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-sysctl.conf
    sudo sysctl (bat /etc/sysctl.d/99-sysctl.conf | sed 's/ //g')
end

# 生成服务端配置文件
echo "\
[Interface]
PrivateKey = "(cat pri1)"
Address = 10.10.10.1
ListenPort = "$port"
PostUp   = nft add rule inet filter input udp dport "$port" accept; nft add rule inet filter forward iifname wg0 accept; nft add rule inet filter forward oifname wg0 accept; nft add rule inet nat postrouting oifname "$interface" masquerade
PostDown = nft flush ruleset; nft -f /etc/nftables.conf
" > wg0.conf

for i in (seq 2 8)
    echo "\
[Peer]
PublicKey = "(cat pub"$i")"
AllowedIPs = 10.10.10."$i"/32
" >> wg0.conf
    # 生成客户端配置文件
    echo "\
[Interface]
PrivateKey = "(cat pri"$i")"
Address = 10.10.10."$i"
DNS = 1.1.1.1

[Peer]
PublicKey = "(cat pub1)"
Endpoint = "$ip":"$port"
AllowedIPs = 0.0.0.0/0
" > client"$i".conf
end

# 复制配置文件并启动
sudo cp wg0.conf /etc/wireguard/ || begin
    echo 复制失败,请检查/etc/wireguard目录或wg0.conf是否存在
    exit
end
sudo wg-quick up wg0 || begin
    echo 启动wireguard失败，请检查/etc/wireguard/wg0.conf是否存在错误
    exit
end

# 开机自启
sudo systemctl enable wg-quick@wg0

echo "安装完成！"
echo "以下指令以显示客户端配置文件"
echo "cat ~/.wireguard/client[2-8].conf"
echo "以下指令显示客户端配置二维码"
echo "qrencode -t ansiutf8 <~/.wireguard/client[2-8].conf"


