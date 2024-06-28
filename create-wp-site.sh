#!/bin/bash

# Check if WP-CLI is installed
if ! command -v wp &> /dev/null
then
    echo "WP-CLI not found. Installing WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    if ! command -v wp &> /dev/null
    then
        echo "Failed to install WP-CLI. Exiting."
        exit 1
    fi
    echo "WP-CLI installed successfully."
fi

# Check if a domain name is provided as an argument
if [ -z "$1" ]; then
  echo "Please provide a domain name as a parameter."
  echo "Usage: ./create-wp-site.sh domain_name.local"
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
site_title="My WordPress Site"
site_user=$db_user
site_pass=$db_pass
site_email="support@$domain"

# Check if WordPress zip file exists, download if not
if [ ! -f wordpress-latest.zip ]; then
    echo "Downloading the latest WordPress zip file..."
    wget https://wordpress.org/latest.zip -O wordpress-latest.zip
    if [ $? -ne 0 ]; then
        echo "Failed to download WordPress. Please check your internet connection."
        exit 1
    fi
else
    echo "WordPress zip file already exists. Skipping download."
fi

# Unzip the latest WordPress zip file
unzip -q wordpress-latest.zip

# Check if unzip was successful
if [ $? -ne 0 ]; then
  echo "Failed to unzip WordPress. Please check the downloaded file."
  exit 1
fi

# Rename the extracted wordpress folder to the domain name
mv wordpress "$site_root"

# Check if move was successful
if [ $? -ne 0 ]; then
  echo "Failed to move WordPress files. Please check permissions."
  exit 1
fi

# Rename the config file
mv "$site_root/wp-config-sample.php" "$site_root/wp-config.php"

# Update /etc/hosts file
echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts

# Copy and configure the nginx config file
conf_template="$conf_path/wordpress.conf.template"
conf_target="$conf_path/$domain.conf"
sudo cp $conf_template $conf_target
sudo sed -i "s|\[DOMAIN\]|$domain|g" $conf_target
sudo sed -i "s|\[SITE_ROOT\]|$sites_root\/$domain|g" $conf_target
sudo sed -i "s|\[WEB_ROOT\]|$web_root|g" $conf_target
sudo sed -i "s|\[CONFIG_ROOT\]|$conf_path|g" $conf_target

# Create a new MySQL database
mysql -u root -p -e "CREATE DATABASE $db_name;"

# Update wp-config.php with DB details
sed -i "s/database_name_here/$db_name/g" "$site_root/wp-config.php"
sed -i "s/username_here/$db_user/g" "$site_root/wp-config.php"
sed -i "s/password_here/$db_pass/g" "$site_root/wp-config.php"

# Fetch unique keys and salts
salts=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

# Replace the placeholder salts in wp-config.php with the new salts
# Using a here document to simplify inserting multiple lines
sed -i "/AUTH_KEY/d" "$site_root/wp-config.php"
sed -i "/SECURE_AUTH_KEY/d" "$site_root/wp-config.php"
sed -i "/LOGGED_IN_KEY/d" "$site_root/wp-config.php"
sed -i "/NONCE_KEY/d" "$site_root/wp-config.php"
sed -i "/AUTH_SALT/d" "$site_root/wp-config.php"
sed -i "/SECURE_AUTH_SALT/d" "$site_root/wp-config.php"
sed -i "/LOGGED_IN_SALT/d" "$site_root/wp-config.php"
sed -i "/NONCE_SALT/d" "$site_root/wp-config.php"

# Insert the new salts
sed -i "/#@-/r /dev/stdin" "$site_root/wp-config.php" <<< "$salts"

# Add FS_METHOD direct to wp-config.php
echo "define('FS_METHOD', 'direct');" | tee -a "$site_root/wp-config.php"

# Delete akismet/ and hello.php from the plugins folder
rm -rf "$site_root/wp-content/plugins/akismet"
rm -f "$site_root/wp-content/plugins/hello.php"

# Unzip all plugin zips from plugin_path to the plugins folder
if [ -d "$plugin_path" ] && [ "$(ls -A $plugin_path/*.zip 2>/dev/null)" ]; then
  for plugin_zip in $plugin_path/*.zip; do
    unzip -q "$plugin_zip" -d "$site_root/wp-content/plugins"
  done
else
  echo "No plugin zips found in $plugin_path"
fi

sudo chown -R $web_user:$web_group $site_root/

# Reset nginx
sudo systemctl reload nginx

# Install WordPress using WP-CLI
sudo -u $web_user -i -- wp core install --path="$site_root" --url="http://$domain" --title="$site_title" --admin_user="$site_user" --admin_password="$site_pass" --admin_email="$site_email"

# Update all plugins using WP-CLI
sudo -u $web_user -i -- wp plugin update --all --path="$site_root"

# Activate all plugins using WP-CLI
sudo -u $web_user -i -- wp plugin activate --all --path="$site_root"

find "$site_root" -type d -exec chmod 755 {} \;
find "$site_root" -type f -exec chmod 644 {} \;
chmod 640 "$site_root"/wp-config.php
chmod -R 777 "$site_root"/wp-content/ai1wm-backups
chmod -R 777 "$site_root"/wp-content/plugins
chmod -R 777 "$site_root"/wp-content/uploads

sudo chown -R $web_user:$web_group $site_root/

echo "Site $domain has been created and configured."

# Output the site URL
echo "Your new site is ready at: http://$domain"

