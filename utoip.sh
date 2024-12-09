#!/bin/bash

# Fungsi untuk menampilkan animasi loading
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    echo -n " "
    while ps a | awk '{print $1}' | grep -q "$pid"; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo "   "
}

clear
# Update system
echo "Updating system"
apt update &> /dev/null &
pid1=$!
apt upgrade -y &> /dev/null &
pid2=$!
wait $pid1 $pid2

apt install -y dante-server &> /dev/null &
pid3=$!
wait $pid3

cp /etc/danted.conf /etc/danted.conf.bak

# Meminta input awalan IP dari user
echo "========================================"
echo "   MASUKKAN AWALAN IP YANG DIIZINKAN"
echo "========================================"
read -p "Enter IP prefix (e.g., 104.28.159): " IP_PREFIX

# Jika input kosong, gunakan default (semua IP diizinkan)
if [[ -z "$IP_PREFIX" ]]; then
    ALLOWED_IP="0.0.0.0/0"
    echo "Tidak ada IP yang dimasukkan, semua IP diizinkan!"
else
    ALLOWED_IP="$IP_PREFIX.0/24"
    echo "IP yang diizinkan: $ALLOWED_IP"
fi

# Konfigurasi danted.conf untuk auth IP
tee /etc/danted.conf > /dev/null <<EOF
logoutput: syslog
internal: eth0 port = 1080
external: eth0
method: none
user.privileged: root
user.unprivileged: nobody
user.libwrap: nobody
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}
socks pass {
    from: $ALLOWED_IP to: 0.0.0.0/0
    log: connect disconnect error
}
EOF

# Deteksi interface jaringan
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
sed -i "s/eth0/$INTERFACE/g" /etc/danted.conf &> /dev/null

# Restart dan enable dante server
systemctl enable danted &> /dev/null &
pid4=$!
systemctl restart danted &> /dev/null &
pid5=$!
wait $pid4 $pid5

spinner $!
clear
echo "========================================"
echo "   AUTO SOCKS BY DOT AJA OFFICIAL"
echo "========================================"
echo "SOCKS : $(curl -s ifconfig.me):1080"
echo "========================================"
echo "IP yang diizinkan: $ALLOWED_IP"
echo "========================================"
echo "   GUNAKAN DENGAN BIJAK YA BREEE :)"
echo "========================================"
