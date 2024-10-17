#!/bin/bash
#
# Tested for Ubuntu 24.04 (LTS) x64

set -euo pipefail

export DEBIAN_FRONTEND="noninteractive"

export SERVICE_USER="goweb"
export SERVICE_NAME="goweb"
export EXECUTEABLE_NAME="main"

# Create server user; note that this is a passwordless account
useradd -m -s /bin/bash $SERVICE_USER
usermod -aG sudo $SERVICE_USER
rsync --archive --chown=$SERVICE_USER:$SERVICE_USER ~/.ssh /home/$SERVICE_USER

# Install packages
apt-get -y install nginx golang make sqlite3
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

# Setup firewall to only allow nginx and ssh access
ufw allow 'OpenSSH'
ufw allow 'Nginx Full'
ufw --force enable
ufw status

# Download basic redirect conf and link it to sites-enabled
cat > /etc/nginx/sites-available/$SERVICE_NAME <<EOF
server {
  server_name example.com

  location / {
    proxy_pass http://localhost:9090;
    proxy_set_header Connection '';
    proxy_http_version 1.1;

    # These are necessary for Server-Sent Events
    # Comment them out if you don't need them
    chunked_transfer_encoding off;
    proxy_buffering off;
    proxy_cache off;
  }
}
EOF

ln -s /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/sites-enabled/$SERVICE_NAME
rm /etc/nginx/sites-enabled/default
systemctl restart nginx

# Verify that nginx is serving on port 80
systemctl status nginx --no-pager --full

# curl localhost:80 2>/dev/null | grep nginx > /dev/null

# # Disable password authentication on ssh (yes I'm using ed)
# ed /etc/ssh/sshd_config << EOF
# %s/^PasswordAuthentication.*/PasswordAuthentication no
# wq
# EOF

echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/$SERVICE_USER/.profile

# Make log directory
mdkir /var/log/$SERVICE_NAME

# Setup go service for systemd
cat > /lib/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=$SERVICE_NAME

[Service]
WorkingDirectory=/home/$SERVICE_NAME
Type=simple
User=$SERVICE_NAME
Restart=always
RestartSec=1s
StandardOutput=append:/var/log/$SERVICE_NAME/output.log
StandardError=append:/var/log/$SERVICE_NAME/error.log
ExecStart=/home/$SERVICE_NAME/$EXECUTEABLE_NAME

[Install]
WantedBy=multi-user.target
EOF

# Login to $SERVICE_USER
sudo -i -u $SERVICE_USER bash << EOF
echo "PATH=$PATH:$HOME/go/bin" >> .profile
mkdir /var
EOF

echo "You're done!"
echo "Don't forget you need to run: certbot --nginx -d example.com -d www.example.com"
echo "You will need to 'go install' the service as the service user"
