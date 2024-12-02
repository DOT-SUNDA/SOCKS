#!/bin/bash

# Update system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install Dante server
echo "Installing Dante server..."
sudo apt install -y dante-server

# Backup default config
echo "Backing up default configuration..."
sudo cp /etc/danted.conf /etc/danted.conf.bak

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

# Replace "eth0" with the active network interface
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
sudo sed -i "s/eth0/$INTERFACE/g" /etc/danted.conf

# Create a user for authentication
echo "Creating user for SOCKS authentication..."
read -p "Enter username: " SOCKS_USER
read -s -p "Enter password: " SOCKS_PASS
echo
sudo useradd -m -s /bin/false "$SOCKS_USER"
echo "$SOCKS_USER:$SOCKS_PASS" | sudo chpasswd

# Enable and start Dante service
echo "Enabling and starting Dante server..."
sudo systemctl enable danted
sudo systemctl restart danted

# Show success message
echo "Dante server installation completed!"
echo "SOCKS5 Proxy is running on port 1080."
echo "Use the following credentials to connect:"
echo "Username: $SOCKS_USER"
echo "Password: (hidden)"
