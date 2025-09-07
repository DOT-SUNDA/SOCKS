apt update
apt install -y docker.io npm

# MEMBUAT DAN INSTALL COLI

git clone https://github.com/oneevil/stratum-ethproxy
cd stratum-ethproxy
npm install

# SETUP GPU POINTING
LOCAL_IP=$(hostname -I | awk '{print $1}')

cat <<EOL >> .env
REMOTE_HOST=asia.rplant.xyz
REMOTE_PORT=7022
REMOTE_PASSWORD=x
LOCAL_HOST=$LOCAL_IP
LOCAL_PORT=80
EOL

# MENJALANKAN STRATUM GULA
screen -dmS GULA npm start
