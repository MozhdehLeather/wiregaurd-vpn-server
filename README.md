# WireGuard VPN Auto Installer for iPhone/Android

This repository contains a **ready-to-use script** to set up a WireGuard VPN server on an **Ubuntu/Debian server in India** and generate **client configurations for iPhone/Android**. The script automates server and client setup, including key generation, configuration, and outputs a **QR code** for easy import into mobile WireGuard apps.

WireGuard is a modern, secure, and lightweight VPN protocol — faster and simpler than traditional VPNs like OpenVPN or IPSec.

---

## 📋 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Why Each Step is Needed](#why-each-step-is-needed)
- [Installation & Usage](#installation--usage)
- [Client Setup on iPhone](#client-setup-on-iphone)
- [Client Setup on Android](#client-setup-on-android)
- [Adding Additional Clients](#adding-additional-clients)
- [Server Management](#server-management)
- [Troubleshooting](#troubleshooting)
- [Security Notes](#security-notes)
- [FAQs](#faqs)
- [License](#license)

---

## ✨ Features

- ✅ **One-command installation** - Complete setup in under 60 seconds
- ✅ **Automatic configuration** - Server and client configs generated automatically
- ✅ **QR code generation** - Scan directly into WireGuard mobile apps
- ✅ **Full tunnel support** - All internet traffic routed through VPN
- ✅ **Multiple DNS options** - CloudFlare (1.1.1.1) or Google DNS (8.8.8.8)
- ✅ **Persistent service** - Survives server reboots
- ✅ **Multi-client ready** - Easy to add additional devices
- ✅ **IPv4 forwarding** - Enabled automatically for proper routing

---

## 📋 Requirements

### Server Requirements
- **Ubuntu 18.04+ or Debian 10+** server
- **Root/sudo access** on the server
- **Public IP address** (your India server's public IP)
- **Port 51820 UDP** open in firewall
- At least **512MB RAM** and **1 CPU core**

### Client Requirements
- **iPhone/iOS**: WireGuard app from App Store
- **Android**: WireGuard app from Google Play Store
- Active internet connection on mobile device

---

## 🛠 Why Each Step is Needed

The script performs these essential operations:

### 1. **Update System & Install WireGuard**
```bash
sudo apt update && sudo apt install wireguard qrencode -y
```
- **Why**: Updates package lists and installs WireGuard VPN software
- **qrencode**: Required to generate QR codes for mobile setup

### 2. **Enable IP Forwarding**
```bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i '/net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf
```
- **Why**: Allows the server to route traffic between VPN clients and internet
- **Permanent**: Modifies sysctl.conf so setting persists after reboot

### 3. **Generate Cryptographic Keys**
```bash
SERVER_PRIVATE=$(wg genkey)
SERVER_PUBLIC=$(echo $SERVER_PRIVATE | wg pubkey)
CLIENT_PRIVATE=$(wg genkey)
CLIENT_PUBLIC=$(echo $CLIENT_PRIVATE | wg pubkey)
```
- **Why**: WireGuard uses public-key cryptography for authentication
- **Security**: Each key pair is unique and generated locally

### 4. **Create Server Configuration**
```bash
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = (server private key)
SaveConfig = true
```
- **Why**: Defines VPN server network (10.8.0.0/24) and port
- **SaveConfig**: Automatically saves peer changes

### 5. **Add Client as Peer**
```bash
[Peer]
PublicKey = (client public key)
AllowedIPs = 10.8.0.2/32
```
- **Why**: Authorizes specific clients to connect
- **AllowedIPs**: Restricts client to specific IP address

### 6. **Create Client Configuration**
```bash
[Interface]
PrivateKey = (client private key)
Address = 10.8.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = (server public key)
Endpoint = SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```
- **Why**: Client needs this config to connect to server
- **DNS**: Sets VPN DNS to CloudFlare for privacy
- **AllowedIPs = 0.0.0.0/0**: Routes ALL traffic through VPN
- **PersistentKeepalive**: Keeps connection alive behind NAT

### 7. **Generate QR Code**
```bash
qrencode -t ansiutf8 < client.conf
```
- **Why**: Allows iPhone/Android to import config by scanning
- **Alternative**: Manual config import also supported

### 8. **Start & Enable Service**
```bash
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0
```
- **Why**: Starts VPN service immediately and enables auto-start on boot

---

## 🚀 Installation & Usage

### Option 1: One-Command Installation (Recommended)
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/wireguard-auto-setup/main/wg-setup.sh)"
```

### Option 2: Manual Download & Run
```bash
# Download the script
curl -O https://raw.githubusercontent.com/yourusername/wireguard-auto-setup/main/wg-setup.sh

# Make it executable
chmod +x wg-setup.sh

# Run with sudo
sudo ./wg-setup.sh
```

### Option 3: Clone Repository
```bash
# Clone the repo
git clone https://github.com/yourusername/wireguard-auto-setup.git
cd wireguard-auto-setup

# Run the script
sudo ./wg-setup.sh
```

### 📊 Expected Output
After running the script, you'll see:
```
[*] Installing WireGuard...
[*] Enabling IP forwarding...
[*] Creating server configuration...
[*] Starting WireGuard...
[*] Your client config is ready as client.conf
[*] Scan this QR code in WireGuard iOS/Android app:
```
Followed by a QR code in your terminal.

---

## 📱 Client Setup on iPhone

### Method 1: QR Code Scan (Easiest)
1. **Install WireGuard** from App Store
2. Open app → Tap **"Add Tunnel"** → **"Scan from QR Code"**
3. Point camera at the QR code displayed in terminal
4. Tap **"Add Tunnel"** → Name it (e.g., "India VPN")
5. Toggle the switch to **ON** (turns green)

### Method 2: Manual Configuration
1. Copy the content of `client.conf` from server:
   ```bash
   cat client.conf
   ```
2. On iPhone, open WireGuard app
3. Tap **"Add Tunnel"** → **"Create from scratch"**
4. Paste configuration → Save
5. Toggle to connect

---

## 🤖 Client Setup on Android

### Method 1: QR Code Scan
1. **Install WireGuard** from Google Play Store
2. Tap **"+"** button → **"Scan from QR Code"**
3. Scan QR code from terminal
4. Tap **"Add Tunnel"** → Toggle to connect

### Method 2: File Import
1. Transfer `client.conf` to Android (email, messaging, etc.)
2. Open WireGuard app
3. Tap **"+"** → **"Import from file or archive"**
4. Select `client.conf` file
5. Tap **"Add Tunnel"** → Toggle to connect

---

## 👥 Adding Additional Clients

### Using the Multi-Client Script
```bash
# Generate multiple clients at once
sudo ./add-client.sh --name "friend-phone" --count 3
```

### Manual Method
```bash
# Generate new client
NEW_CLIENT_IP="10.8.0.3"
NEW_CLIENT_PRIVATE=$(wg genkey)
NEW_CLIENT_PUBLIC=$(echo $NEW_CLIENT_PRIVATE | wg pubkey)

# Add to server
sudo wg set wg0 peer $NEW_CLIENT_PUBLIC allowed-ips $NEW_CLIENT_IP/32
sudo wg-quick save wg0

# Create client config
cat > client2.conf <<EOF
[Interface]
PrivateKey = $NEW_CLIENT_PRIVATE
Address = $NEW_CLIENT_IP/32
DNS = 1.1.1.1

[Peer]
PublicKey = $(sudo cat /etc/wireguard/wg0.conf | grep PrivateKey | head -1 | awk '{print $3}' | wg pubkey)
Endpoint = $(curl -s https://ipinfo.io/ip):51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Generate QR
qrencode -t ansiutf8 < client2.conf
```

---

## 🖥️ Server Management

### Check VPN Status
```bash
sudo wg show
```

### Start/Stop VPN
```bash
# Start
sudo wg-quick up wg0

# Stop
sudo wg-quick down wg0

# Restart
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

### View Server Config
```bash
sudo cat /etc/wireguard/wg0.conf
```

### Check Service Status
```bash
sudo systemctl status wg-quick@wg0
```

### Remove a Client
```bash
sudo wg set wg0 peer CLIENT_PUBLIC_KEY remove
sudo wg-quick save wg0
```

---

## 🔧 Troubleshooting

### ❌ QR Code Not Scanning
```bash
# Generate PNG file instead
qrencode -t png -o vpn-qr.png < client.conf
# Transfer PNG to phone and scan from gallery
```

### ❌ Connection Timeout
1. Check firewall allows UDP port 51820:
   ```bash
   sudo ufw allow 51820/udp
   sudo ufw reload
   ```
2. Verify server IP is correct in client config
3. Check WireGuard is running:
   ```bash
   sudo systemctl status wg-quick@wg0
   ```

### ❌ No Internet Through VPN
1. Ensure IP forwarding is enabled:
   ```bash
   cat /proc/sys/net/ipv4/ip_forward  # Should output "1"
   ```
2. Check server has internet access
3. Verify DNS in client config

### ❌ "Permission Denied" Errors
Always run scripts with sudo:
```bash
sudo ./wg-setup.sh
```

---

## 🔒 Security Notes

### Firewall Configuration
```bash
# Allow only WireGuard port
sudo ufw allow 51820/udp
sudo ufw enable
```

### Key Security
- **Never share** `client.conf` publicly
- Each client should have **unique key pair**
- Regenerate keys if compromised

### Best Practices
1. Use **strong server passwords**
2. Enable **fail2ban** for SSH
3. Keep system **updated regularly**
4. Monitor `/var/log/syslog` for WireGuard logs
5. Consider changing default port 51820

---

## ❓ FAQs

### Q: Can I use this for streaming Indian content?
**A:** Yes! Once connected, your traffic appears from India. Works with Hotstar, SonyLIV, etc.

### Q: How many devices can connect simultaneously?
**A:** By default, one device per client config. Add more clients for more devices.

### Q: Will this slow my internet?
**A:** Minimal overhead (~5-10%). WireGuard is very efficient.

### Q: Can I use on Windows/Mac?
**A:** Yes! Use the `client.conf` file in WireGuard desktop apps.

### Q: How to change DNS servers?
**A:** Edit `client.conf` and change `DNS = 1.1.1.1` to your preferred DNS.

### Q: Is logging enabled?
**A:** No, WireGuard doesn't log traffic by default.

### Q: How to update server IP if it changes?
**A:** Update `Endpoint` in all client configs with new server IP.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## ⚠️ Disclaimer

This tool is for **educational and legitimate privacy purposes only**. Users are responsible for complying with all applicable laws. The author assumes no liability for misuse.

---

## 🔗 Useful Links

- [Official WireGuard Website](https://www.wireguard.com/)
- [WireGuard Installation Guide](https://www.wireguard.com/install/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [DigitalOcean WireGuard Tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-ubuntu-20-04)

---

**Need Help?** Open an issue or check the [Wiki](https://github.com/yourusername/wireguard-auto-setup/wiki) for detailed guides.

**Star this repo** if it helped you! ⭐
