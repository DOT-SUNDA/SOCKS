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

tee /etc/danted.conf > /dev/null <<EOF
logoutput: syslog
internal: eth0 port = 1080
external: eth0
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

INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
sed -i "s/eth0/$INTERFACE/g" /etc/danted.conf &> /dev/null

systemctl enable danted &> /dev/null &
pid4=$!
systemctl restart danted &> /dev/null &
pid5=$!
wait $pid4 $pid5

spinner $!
clear
echo "========================================"
echo "   MASUKAN USER DAN PASS NYA BRE!!!"
echo "========================================"
read -p "Enter username: " SOCKS_USER
read -s -p "Enter password: " SOCKS_PASS
echo
useradd -m -s /bin/false "$SOCKS_USER" &> /dev/null
echo "$SOCKS_USER:$SOCKS_PASS" | chpasswd &> /dev/null

echo "========================================"
echo "   AUTO SOCKS BY DOT AJA OFFICIAL"
echo "========================================"
echo "SOCKS : $(curl -s ifconfig.me):1080:$SOCKS_USER:$SOCKS_PASS"
echo "========================================"
echo "   GUNAKAN DENGAN BIJAK YA BREEE :)"
echo "========================================"
