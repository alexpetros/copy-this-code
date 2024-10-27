# Node v20 setup on Ubuntu 24.10
#
#!/bin/bash
set -ev

export DEBIAN_FRONTEND="noninteractive"
export SERVER_USER="node"
export RUNAS_USER="awp"
export DOMAIN="garbagedaylive.com"

# Create server user; note that this is a passwordless account
useradd -m -s /bin/bash $SERVER_USER || echo "User $SERVER_USER" already exists
rsync --archive --chown=$SERVER_USER:$SERVER_USER ~/.ssh /home/$SERVER_USER

# Install basic packages
apt-get -y update
apt-get -y upgrade
apt-get -y install nginx make fzf sqlite3 nodejs npm

# Install certbot
snap install --classic certbot || echo "Certbot already installed"
ln -fs /snap/bin/certbot /usr/bin/certbot

# Download basic redirect conf and link it to sites-enabled
cat > /etc/nginx/sites-available/node <<EOF
# Server configuration for node application
server {
	index index.html;

	# Uncomment if you have a custom error page to use
	# error_page 404 404.html;

	# This is the ubuntu default www directory; replace with your chosen one
	root /var/www/html;
	server_name $DOMAIN;

	location / {
		proxy_pass http://localhost:8080;
		proxy_http_version 1.1;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection 'upgrade';
		proxy_set_header Host \$host;
		proxy_cache_bypass \$http_upgrade;
	}
}
EOF

ln -fs /etc/nginx/sites-available/node /etc/nginx/sites-enabled/node
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

# Verify that nginx is serving on port 80
systemctl status nginx --no-pager --full
curl localhost:80 2>/dev/null | grep nginx > /dev/null

# Setup firewall to only allow nginx and ssh access
ufw allow 'OpenSSH'
ufw allow 'Nginx Full'
ufw --force enable
ufw status

# Install pm2
npm install -g pm2

echo "You're done!"
echo "Don't forget to update your nginx server name and then run: certbot --nginx -d $DOMAIN"
echo "You also have to download the your app and pm2 start it"
