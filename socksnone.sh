#!/bin/bash
clear

# Update system
echo "Updating system..."
apt update -y 
apt upgrade -y

# Install dante-server
echo "Installing dante-server..."
apt install -y dante-server

# Backup konfigurasi asli
cp /etc/danted.conf /etc/danted.conf.bak

# Buat konfigurasi baru tanpa autentikasi (method: none)
tee /etc/danted.conf > /dev/null <<EOF
logoutput: syslog
internal: 0.0.0.0 port = 1080
external: eth0
socksmethod: none
user.privileged: root
user.unprivileged: nobody
user.libwrap: nobody
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}
EOF

# Ganti 'eth0' dengan interface network default yang aktif
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
sed -i "s/eth0/$INTERFACE/g" /etc/danted.conf &> /dev/null

# Enable dan restart service danted
echo "Starting danted service..."
systemctl enable danted &> /dev/null
systemctl restart danted &> /dev/null

clear
echo "========================================"
echo "   AUTO SOCKS BY DOT AJA OFFICIAL"
echo "========================================"
echo "SOCKS : $(curl -s ifconfig.me):1080"
echo "========================================"
echo "   GUNAKAN DENGAN BIJAK YA BREEE :)"
echo "========================================"
