#! /bin/fish

set config_dir "$HOME"/.wireguard/

mkdir -p $config_dir
cd $config_dir || begin
    echo 切换目录失败，程序退出
    exit
end

function wg0_av
    set i (sudo wg)
    if test -n "$i"
        sudo wg-quick down wg0
    end
    rm -rf $config_dir/*

    # 打开流量转发
    if not sudo grep -q 'ip_forward' /etc/sysctl.d/99-sysctl.conf
        echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-sysctl.conf
        sudo sysctl (bat /etc/sysctl.d/99-sysctl.conf | sed 's/ //g')
    end

    # 生成密钥，分别用作服务器和客户端使用
    wg genkey | tee pri1 | wg pubkey >pub1
    wg genkey | tee pri2 | wg pubkey >pub2
    # 设置密钥访问权限
    chmod 600 pri1
    chmod 600 pri2

    # 随机数
    function rand -a min -a max
        set max (math $max - $min + 1)
        set num (date +%s%N)
        echo (math $num % $max + $min)
    end

    set interface (ip -o -4 route show to default | awk '{print $5}')
    set ip (ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    set port (rand 10000 60000)

    # 生成服务端配置文件
    echo "\
[Interface]
PrivateKey = "(cat pri1)"
Address = 10.10.10.1/32
ListenPort = "$port"
PostUp   = nft add rule inet filter input udp dport "$port" accept; nft add rule inet filter forward iifname wg0 accept; nft add rule inet filter forward oifname wg0 accept; nft add rule inet nat postrouting oifname "$interface" masquerade
PostDown = nft flush ruleset; nft -f /etc/nftables.conf

[Peer]
PublicKey = "(cat pub2)"
AllowedIPs = 10.10.10.2/32
" > wg0.conf

    # 生成客户端配置文件
    echo "\
[Interface]
PrivateKey = "(cat pri2)"
Address = 10.10.10.2
DNS = 1.1.1.1

[Peer]
PublicKey = "(cat pub1)"
Endpoint = "$ip":"$port"
AllowedIPs = 0.0.0.0/0
" > client2.conf

    # 复制配置文件并启动
    sudo cp wg0.conf /etc/wireguard/ || begin
        echo 复制失败,请检查/etc/wireguard目录或wg0.conf是否存在
        exit
    end
    rm wg0.conf
    sudo wg-quick up wg0 || begin
        echo 启动wireguard失败，请检查/etc/wireguard/wg0.conf是否存在错误
        exit
    end

    # 开机自启
    sudo systemctl enable wg-quick@wg0

    echo "安装完成！"
    cli_av
end

function cli_av
    while true
        set cli (sudo cat /etc/wireguard/wg0.conf | grep -oP '(?<=\.)\d+(?=\/)')
        echo 已存在成员：
        echo $cli

        echo 输入成员数字（存在则删除，不存在则创建）
        read -p 'echo "> "' i
        if string match -qr '^[0-9]+$' $i && test "$i" -ge 2 -a "$i" -le 254
            if echo $cli | grep -qE '(^| )'$i'($| )'
                sudo wg set wg0 peer (cat pub"$i") remove
                sudo wg-quick save wg0
                rm client"$i".conf pub"$i" pri"$i"
            else
                wg genkey | tee pri"$i" | wg pubkey >pub"$i"
                chmod 600 pri"$i"
                sudo wg set wg0 peer (cat pub"$i") allowed-ips 10.10.10."$i"/32
                sudo wg-quick save wg0

                set interface (ip -o -4 route show to default | awk '{print $5}')
                set ip (ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
                set port (sudo cat /etc/wireguard/wg0.conf | grep -oP '(?<=ListenPort = )\d+')

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
        else
            break
        end
    end
    cli_ud
end

function cli_ud
    set cli (sudo cat /etc/wireguard/wg0.conf | grep -oP '(?<=\.)\d+(?=\/)')
    while true
        echo 已存在成员：
        echo $cli

        echo 输入成员数字（查看配置）
        read -p 'echo "> "' i
        if string match -qr '^[0-9]+$' $i && test "$i" -ge 2 -a "$i" -le 254
            echo -e "\n=======请将此复制到 client"$i".conf 文件========\n"
            cat client"$i".conf
            echo -e "=============================================\n"
            qrencode -t ansiutf8 <client"$i".conf
            echo
        else
            break
        end
    end
end

echo 输入 a 安装 wg0
echo 输入 b 增减成员
echo 输入 c 查看成员配置
read -p 'echo "> "' i
switch $i
case a
    wg0_av
case b
    cli_av
case c
    cli_ud
end


