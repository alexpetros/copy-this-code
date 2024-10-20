#!/bin/bash
#
# Note that this needs to be run as root
# On a fresh install, I typically just `cat go-ubuntu-setup.sh | ssh root@YOUR_VPS_IP`
# Tested for Ubuntu 24.04 (LTS) x64

set -veuo pipefail

export DEBIAN_FRONTEND="noninteractive"

export RUNAS_USER="goweb"
export SERVICE_NAME="gomain"
export EXECUTEABLE_NAME="main"

# Create server user; note that this is a passwordless account
useradd -m -s /bin/bash $RUNAS_USER
usermod -aG sudo $RUNAS_USER
rsync --archive --chown=$RUNAS_USER:$RUNAS_USER ~/.ssh /home/$RUNAS_USER

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
  server_name example.com;

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

echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/$RUNAS_USER/.profile

# Make log directory
mkdir /var/log/$SERVICE_NAME

# Setup go service for systemd
cat > /lib/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=$SERVICE_NAME

[Service]
WorkingDirectory=/home/$RUNAS_USER
Type=simple
User=$RUNAS_USER
Restart=always
RestartSec=1s
StandardOutput=append:/var/log/$SERVICE_NAME/output.log
StandardError=append:/var/log/$SERVICE_NAME/error.log
ExecStart=/home/$RUNAS_USER/go/bin/$EXECUTEABLE_NAME

[Install]
WantedBy=multi-user.target
EOF

# Login to $RUNAS_USER, and set up the go environment,
# You can also add the necessary commands here to install your program
# i.e. git clone, make, and so on
sudo -i -u $RUNAS_USER bash << EOF
echo "PATH=\$PATH:/home/$RUNAS_USER/go/bin" >> .profile
source .profile
cd /home/$RUNAS_USER
# ADD PROGRAM INSTALLATION COMMANDS HERE
EOF

systemctl restart $SERVICE_NAME

echo "You're done!"
echo "Don't forget you need to run: certbot --nginx -d example.com -d www.example.com"
echo "You will need to 'go install' the service as the service user"
