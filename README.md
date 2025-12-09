# WireGuard VPN Auto Installer for iPhone

This repository contains a **ready-to-use script** to set up a WireGuard VPN server on an **Ubuntu/Debian server in India** and generate a **client configuration for iPhone**. The script automates server and client setup, including key generation, configuration, firewall setup, and outputs a **QR code** for easy import into the WireGuard iOS app.

WireGuard is a modern, secure, and lightweight VPN protocol — faster and simpler than traditional VPNs like OpenVPN or IPSec.

---

## Table of Contents

- [Features](#features)  
- [Requirements](#requirements)  
- [Why Each Step is Needed](#why-each-step-is-needed)  
- [Installation & Usage](#installation--usage)  
- [Client Setup on iPhone](#client-setup-on-iphone)  
- [Adding Additional Clients](#adding-additional-clients)  
- [Security Notes](#security-notes)  
- [License](#license)  

---

## Features

- Installs WireGuard and required dependencies automatically  
- Configures server interface and firewall for VPN  
- Generates server and client keys securely  
- Outputs client configuration and QR code for iPhone  
- Enables full internet routing through the VPN  
- Supports multiple clients  

---

## Requirements

- Ubuntu/Debian server with **root access**  
- Public IP for the server  
- iPhone with **WireGuard app** installed  
- Firewall allowing **UDP port 51820**  

---

## Why Each Step is Needed

The script does the following and here’s why:

1. **Update & install WireGuard**  
   ```bash
   sudo apt update && sudo apt install wireguard qrencode -y
