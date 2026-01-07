#!/usr/bin/env sh

DOMAIN="${DOMAIN:-node68.lunes.host}"
PORT="${PORT:-10008}"
UUID="${UUID:-2584b733-9095-4bec-a7d5-62b473540f7a}"
HY2_PASSWORD="${HY2_PASSWORD:-vevc.HY2.Password}"

curl -sSL -o app.js https://raw.githubusercontent.com/crarm/one-node/refs/heads/main/lunes-host/app.js
curl -sSL -o package.json https://raw.githubusercontent.com/crarm/one-node/refs/heads/main/lunes-host/package.json

mkdir -p /home/container/xy
cd /home/container/xy
curl -sSL -o Xray-linux-64.zip https://github.com/XTLS/Xray-core/releases/download/v25.8.3/Xray-linux-64.zip
unzip Xray-linux-64.zip
rm Xray-linux-64.zip
mv xray xy
curl -sSL -o config.json https://raw.githubusercontent.com/crarm/one-node/refs/heads/main/lunes-host/xray-config.json
sed -i "s/10008/$PORT/g" config.json
sed -i "s/YOUR_UUID/$UUID/g" config.json
vmess="{\"v\": \"2\",\"ps\": \"lunes-vmess\",\"add\": \"$DOMAIN\",\"port\": \"$PORT\",\"id\": \"$UUID\",\"aid\": \"64\",\"scy\": \"auto\",\"net\": \"ws\",\"type\": \"none\",\"host\": \"$DOMAIN\",\"path\": \"/$UUID\",\"tls\": \"\",\"sni\": \"$DOMAIN\",\"alpn\": \"\"}"

vmessUrl="vmess://"$(echo $vmess | base64 -w 0 )
echo $vmessUrl > /home/container/node.txt

mkdir -p /home/container/h2
cd /home/container/h2
curl -sSL -o h2 https://github.com/apernet/hysteria/releases/download/app%2Fv2.6.2/hysteria-linux-amd64
curl -sSL -o config.yaml https://raw.githubusercontent.com/vevc/one-node/refs/heads/main/lunes-host/hysteria-config.yaml
openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -keyout key.pem -out cert.pem -subj "/CN=$DOMAIN"
chmod +x h2
sed -i "s/10008/$PORT/g" config.yaml
sed -i "s/HY2_PASSWORD/$HY2_PASSWORD/g" config.yaml
encodedHy2Pwd=$(node -e "console.log(encodeURIComponent(process.argv[1]))" "$HY2_PASSWORD")
hy2Url="hysteria2://$encodedHy2Pwd@$DOMAIN:$PORT?insecure=1#lunes-hy2"
echo $hy2Url >> /home/container/node.txt

echo "============================================================"
echo "🚀 VLESS Reality & HY2 Node Info"
echo "------------------------------------------------------------"
echo "$vmessUrl"
echo "$hy2Url"
echo "============================================================"
