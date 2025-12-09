#!/bin/bash
# WireGuard Auto Installer + iPhone Client Setup
# For Ubuntu/Debian

set -e

# 1. Install WireGuard
echo "[*] Installing WireGuard..."
sudo apt update && sudo apt install wireguard qrencode -y

# 2. Enable IP forwarding
echo "[*] Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i '/net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf

# 3. Create server keys
SERVER_PRIVATE=$(wg genkey)
SERVER_PUBLIC=$(echo $SERVER_PRIVATE | wg pubkey)
SERVER_PORT=51820
SERVER_CONF="/etc/wireguard/wg0.conf"

# 4. Create initial server config
echo "[*] Creating server configuration..."
cat <<EOF | sudo tee $SERVER_CONF
[Interface]
Address = 10.8.0.1/24
ListenPort = $SERVER_PORT
PrivateKey = $SERVER_PRIVATE
SaveConfig = true
EOF

# 5. Generate client keys
CLIENT_PRIVATE=$(wg genkey)
CLIENT_PUBLIC=$(echo $CLIENT_PRIVATE | wg pubkey)
CLIENT_IP="10.8.0.2"

# 6. Add client to server config
cat <<EOF | sudo tee -a $SERVER_CONF

[Peer]
PublicKey = $CLIENT_PUBLIC
AllowedIPs = $CLIENT_IP/32
EOF

# 7. Restart WireGuard
echo "[*] Starting WireGuard..."
sudo wg-quick down wg0 2>/dev/null || true
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0

# 8. Create client config
CLIENT_CONF="client.conf"
SERVER_IP=$(curl -s https://ipinfo.io/ip)

cat <<EOF > $CLIENT_CONF
[Interface]
PrivateKey = $CLIENT_PRIVATE
Address = $CLIENT_IP/32
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC
Endpoint = $SERVER_IP:$SERVER_PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

# 9. Generate QR code for iPhone
echo "[*] Your client config is ready as $CLIENT_CONF"
echo "[*] Scan this QR code in WireGuard iOS app:"
qrencode -t ansiutf8 < $CLIENT_CONF

echo "[*] Done! Your iPhone can now connect to your India server via WireGuard."
