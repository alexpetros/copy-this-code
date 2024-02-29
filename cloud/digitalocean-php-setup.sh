#!/bin/bash
#
# Digital Ocean PHP Server Setup
# Tested on Ubuntu 22.04 (LTS) x64
set -ev

# CHANGE THESE TO YOUR DESIRED ACCOUNT NAME AND DOTFILES_URL
export PERSONAL_USER="awp"
export DOTFILES_URL="https://github.com/alexpetros/dotfiles"

# Change these if you're using a different distro
export SERVER_USER="www-data"
export WWW_DIR="/var/www"

# Leave these
export DEBIAN_FRONTEND="noninteractive"

# Install basic packages
apt-get -y update
apt-get -y upgrade
apt-get -y install nginx make fzf sqlite3 php php-fpm

# Install certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

# Create the nginx config
cat > /etc/nginx/sites-available/main <<EOF
server {
    listen 80;
    server_name your_domain www.your_domain;
    root $WWW_DIR/main;

    index index.html index.htm index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \\.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
     }

    location ~ /\\.ht {
        deny all;
    }
}
EOF

# Link the config
ln -s /etc/nginx/sites-available/main /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default

nginx -t
systemctl restart nginx


mkdir $WWW_DIR/main
cat > $WWW_DIR/main/index.php <<"EOF"
<title>Test Site</title>
<h1>Verification</h1>
<?php echo "If you don't see the PHP tags, you're good to go!" ?>
EOF

chown -R "$SERVER_USER:$SERVER_USER" "$WWW_DIR"
chgrp -R "$SERVER_USER" "$WWW_DIR"
chmod g+rw /var/www -R

# Verify that nginx is serving on port 80
systemctl status nginx --no-pager --full
curl localhost:80 2>/dev/null | grep "good to go" > /dev/null

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

# Create non-root user with the authorized ssh keys; note that this is a passwordless account
useradd --create-home --shell /bin/bash $PERSONAL_USER
usermod --append --groups sudo $PERSONAL_USER
usermod --append --groups admin $PERSONAL_USER
usermod --append --groups www-data $PERSONAL_USER
rsync --archive --chown="$PERSONAL_USER:$PERSONAL_USER" ~/.ssh "/home/$PERSONAL_USER"

echo '%admin        ALL=(ALL)       NOPASSWD: ALL' > /etc/sudoers.d/admin-passwordless

# Login to $PERSONAL_USER and install dotfiles
sudo -i -u $PERSONAL_USER bash << EOF
git clone $DOTFILES_URL
EOF

echo "You're done!"
echo "Don't forget you need to run: certbot --nginx -d example.com -d www.example.com"
