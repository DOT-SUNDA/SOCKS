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
echo "Updating system..."
(sudo apt update && sudo apt upgrade -y) &> /dev/null &
spinner $!
clear
# Install Dante server
echo "Installing Dante server..."
(sudo apt install -y dante-server) &> /dev/null &
spinner $!
clear
# Backup default config
echo "Backing up default configuration..."
(sudo cp /etc/danted.conf /etc/danted.conf.bak) &
spinner $!
clear
# Create new configuration file
echo "Configuring Dante server..."
sudo tee /etc/danted.conf > /dev/null <<EOF
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
spinner $!
clear
# Replace "eth0" with the active network interface
echo "Detecting active network interface..."
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
sudo sed -i "s/eth0/$INTERFACE/g" /etc/danted.conf &
spinner $!
clear
# Create a user for authentication
echo "========================================"
echo "   MASUKAN USER DAN PASS NYA BRE!!!"
echo "========================================"
read -p "Enter username: " SOCKS_USER
read -s -p "Enter password: " SOCKS_PASS
echo
(sudo useradd -m -s /bin/false "$SOCKS_USER" &&
echo "$SOCKS_USER:$SOCKS_PASS" | sudo chpasswd) &
spinner $!
clear
# Enable and start Dante service
echo "Enabling and starting Dante server..."
(sudo systemctl enable danted &&
sudo systemctl restart danted) &
spinner $!
clear
# Show success message
echo "========================================"
echo "   AUTO SOCKS BY DOT AJA OFFICIAL"
echo "========================================"
echo "$(curl -s ifconfig.me):1080:$SOCKS_USER:$SOCKS_PASS"
echo "========================================"
echo "   GUNAKAN DENGAN BIJAK YA BREEE :)"
echo "========================================"
