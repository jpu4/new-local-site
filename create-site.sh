#!/bin/bash

# Check if a domain name is provided as an argument
if [ -z "$1" ]; then
  echo "Please provide a domain name as a parameter."
  echo "Usage: ./create-site.sh domain_name.local"
  exit 1
fi

# Configuration paths
conf_path="/etc/nginx/conf.d"
web_root="/var/www"
sites_root="/var/www/sites"
site_root="$sites_root/$domain"
plugin_path="$web_root/plugins"  # Update this path with the actual path to your plugins

# Permissions
web_user="www-data"
web_group="www-data"

# Domain name parameter
domain=$1

# Database credentials
db_user="my_local_dev_user"
db_pass="my_local_dev_pass"
db_name=${domain//./_}

# Site credentials
site_title="My Site"
site_user=$db_user
site_pass=$db_pass
site_email="support@$domain"

# Create the web root directory for the domain
mkdir -p "$site_root"

# Create a basic index.php file
echo "<?php echo '$domain ready for development';" > "$site_root/index.php"

# Update /etc/hosts file
echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts

# Copy and configure the nginx config file
conf_template="$conf_path/base.conf.template"
conf_target="$conf_path/$domain.conf"
sudo cp $conf_template $conf_target
sudo sed -i "s/\[DOMAIN\]/$domain/g" $conf_target
sudo sed -i "s/\[SITE_ROOT\]/$site_root/g" $conf_target
sudo sed -i "s/\[WEB_ROOT\]/$web_root/g" $conf_target
sudo sed -i "s/\[CONFIG_ROOT\]/$conf_path/g" $conf_target

# Create a new MySQL database
mysql -u root -p -e "CREATE DATABASE $db_name;"

# Set the necessary file permissions
sudo chown -R $web_user:$web_group "$site_root"

# Reset nginx
sudo systemctl reload nginx

echo "Site $domain has been created and configured."
