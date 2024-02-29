#!/bin/bash
#
# Digital Ocean Webserver Setup
# Tested on Ubuntu 23.10 x64 and Ubuntu 22.04 (LTS) x64
set -ev

# CHANGE THESE TO YOUR DESIRED ACCOUNT NAME AND DOTFILES_URL
export PERSONAL_USER="awp"
export DOTFILES_URL="https://github.com/alexpetros/dotfiles"

# Leave these
export DEBIAN_FRONTEND="noninteractive"

# Install basic packages
apt-get -y update
apt-get -y upgrade
apt-get -y install nginx make fzf sqlite3

# Install certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

# # This is from when I had a custom nginx setuo for node
# # Leaving it here for whenever I setup one again
# curl "$NODE_CONF_URL" > /etc/nginx/sites-available/node
# ln -s /etc/nginx/sites-available/node node
# rm /etc/nginx/sites-enabled/default
# systemctl restart nginx

# Verify that nginx is serving on port 80
systemctl status nginx --no-pager --full
curl localhost:80 2>/dev/null | grep nginx > /dev/null

# Setup firewall to only allow nginx and ssh access
ufw allow 'OpenSSH'
ufw allow 'Nginx Full'
ufw --force enable
ufw status

# Disable password authentication on ssh (yes I'm using ed)
ed /etc/ssh/sshd_config << EOF
%s/^PasswordAuthentication.*/PasswordAuthentication no
wq
EOF

# # Install node 18.x
# curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
# apt-get install -y nodejs
# npm install -g pm2

# Create non-root user with the authorized ssh keys; note that this is a passwordless account
useradd -m -s /bin/bash $PERSONAL_USER
usermod -aG sudo $PERSONAL_USER
rsync --archive --chown=$PERSONAL_USER:$PERSONAL_USER ~/.ssh /home/$PERSONAL_USER

# Login to $PERSONAL_USER and install dotfiles
sudo -i -u $PERSONAL_USER bash << EOF
git clone $DOTFILES_URL
cd dotfiles && make
EOF

echo "You're done!"
echo "Don't forget you need to run: certbot --nginx -d example.com -d www.example.com"
