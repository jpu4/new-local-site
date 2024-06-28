#!/bin/bash

# Check if a domain name is provided as an argument
if [ -z "$1" ]; then
  echo "Please provide a domain name as a parameter."
  echo "Usage: ./create-laravel-site.sh domain_name.local"
  exit 1
fi

# Configuration paths
conf_path="/etc/nginx/conf.d"
web_root="/var/www"
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
site_title="My Laravel Site"
site_user=$db_user
site_pass=$db_pass
site_email="support@$domain"

# Check if Composer is installed
if ! command -v composer &> /dev/null
then
    echo "Composer not found. Installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    if ! command -v composer &> /dev/null
    then
        echo "Failed to install Composer. Exiting."
        exit 1
    fi
    echo "Composer installed successfully."
fi

# Install Laravel using Composer
composer create-project --prefer-dist laravel/laravel "$web_root/$domain"

# Set the necessary file permissions
sudo chown -R $web_user:$web_group "$web_root/$domain"
sudo chmod -R 775 "$web_root/$domain/storage" "$web_root/$domain/bootstrap/cache"

# Update the .env file with the database credentials
env_file="$web_root/$domain/.env"
sed -i "s/DB_DATABASE=laravel/DB_DATABASE=$db_name/" $env_file
sed -i "s/DB_USERNAME=root/DB_USERNAME=$db_user/" $env_file
sed -i "s/DB_PASSWORD=/DB_PASSWORD=$db_pass/" $env_file

# Update /etc/hosts file
echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts

# Copy and configure the nginx config file
conf_template="$conf_path/base.conf.template"
conf_target="$conf_path/$domain.conf"
sudo cp $conf_template $conf_target
sudo sed -i "s/\[DOMAIN\]/$domain/g" $conf_target
sudo sed -i "s|\[WEB_ROOT\]|$web_root/$domain/public|g" $conf_target  # Point to the public directory of Laravel
sudo sed -i "s|\[CONFIG_PATH\]|$conf_path|g" $conf_target

# Create a new MySQL database
mysql -u root -p -e "CREATE DATABASE $db_name;"

# Reset nginx
sudo systemctl reload nginx

echo "Site $domain has been created and configured."
