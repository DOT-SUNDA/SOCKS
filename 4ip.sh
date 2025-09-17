#!/bin/bash
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
clear
echo "========================================"
echo "   MASUKAN USER DAN PASS NYA BRE!!!"
echo "========================================"
read -p "Enter username: " SOCKS_USER
read -s -p "Enter password: " SOCKS_PASS
echo

# Buat passdb untuk autentikasi
echo "$SOCKS_USER:$SOCKS_PASS" > /etc/danted.passwd
chmod 600 /etc/danted.passwd

# Generate danted.conf
tee /etc/danted.conf > /dev/null <<EOF
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = 1080

external: ens3
external: ens4
external: ens5
external: ens6

method: username
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

systemctl restart danted

clear
echo "========================================"
echo "   AUTO SOCKS BY DOT AJA OFFICIAL"
echo "========================================"
echo "SOCKS aktif di SEMUA IP VPS kamu!"
echo "Gunakan format: IP-VPS:1080:$SOCKS_USER:$SOCKS_PASS"
echo
echo "Contoh:"
hostname -I | tr ' ' '\n' | while read ip; do
    echo "SOCKS : $ip:1080:$SOCKS_USER:$SOCKS_PASS"
done
echo "========================================"
echo "   GUNAKAN DENGAN BIJAK YA BREEE :)"
echo "========================================"
