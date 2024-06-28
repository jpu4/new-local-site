#!/bin/bash

# Check if a domain name is provided as an argument
if [ -z "$1" ]; then
  echo "Please provide a domain name as a parameter."
  echo "Usage: ./create-laravel-site.sh domain_name.local"
  exit 1
fi

# Domain name parameter
domain=$1

# Configuration paths
conf_path="/etc/nginx/conf.d"
web_root="/var/www"
sites_root="/var/www/sites"
site_root="$sites_root/$domain"
plugin_path="$web_root/plugins"  # Update this path with the actual path to your plugins

# Permissions
web_user="www-data"
web_group="www-data"

# Database credentials
db_user="my_local_dev_user"
db_pass="my_local_dev_pass"
db_name=${domain//./_}

# Site credentials
# Extract the first part of the domain (before the dot)
site_title=$(echo $domain | cut -d '.' -f 1)
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

# Get the original user who invoked sudo
current_user=${SUDO_USER:-$(whoami)}

# Create the site directory
sudo mkdir -p "$site_root"
sudo chown -R $current_user:$current_user "$site_root"

# Install Laravel using Composer as the original user
sudo -u $current_user -H sh -c "composer create-project --prefer-dist laravel/laravel \"$site_root\""

# Set the necessary file permissions
sudo chown -R $web_user:$web_group "$site_root"
sudo chmod -R 775 "$site_root/storage" "$site_root/bootstrap/cache"

# Update the .env file with the database credentials
env_file="$site_root/.env"
sed -i "s/APP_NAME=.*/APP_NAME=$site_title/" $env_file
sed -i "s/APP_URL=.*/APP_URL=http:\/\/$domain/" $env_file
sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=mysql/" $env_file
sed -i "s/# DB_HOST=.*/DB_HOST=127.0.0.1/" $env_file
sed -i "s/# DB_PORT=.*/DB_PORT=3306/" $env_file
sed -i "s/# DB_DATABASE=laravel/DB_DATABASE=$db_name/" $env_file
sed -i "s/# DB_USERNAME=root/DB_USERNAME=$db_user/" $env_file
sed -i "s/# DB_PASSWORD=/DB_PASSWORD=$db_pass/" $env_file


# Update /etc/hosts file
echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts

# Copy and configure the nginx config file
conf_template="$conf_path/laravel.conf.template"
conf_target="$conf_path/$domain.conf"
sudo cp $conf_template $conf_target
sudo sed -i "s|\[DOMAIN\]|$domain|g" $conf_target
sudo sed -i "s|\[SITE_ROOT\]|$sites_root\/$domain\/public|g" $conf_target
sudo sed -i "s|\[WEB_ROOT\]|$web_root|g" $conf_target
sudo sed -i "s|\[CONFIG_ROOT\]|$conf_path|g" $conf_target

# Create a new MySQL database
mysql -u root -p -e "CREATE DATABASE $db_name;"

# Reset nginx
sudo systemctl reload nginx

echo "Site $domain has been created and configured."

cd "$site_root"
php artisan migrate

# Output the site URL
echo "Your new site is ready at: http://$domain"
