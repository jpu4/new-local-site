#!/bin/bash

# Check if a domain name is provided as an argument
if [ -z "$1" ]; then
  echo "Please provide a domain name as a parameter."
  echo "Usage: ./delete-site.sh domain_name.local"
  exit 1
fi

# Domain name parameter
domain=$1

# Configuration paths
conf_path="/etc/nginx/conf.d"
web_root="/var/www"
sites_root="/var/www/sites"
site_root="$sites_root/$domain"
bak_root="$web_root/bak"

# Database credentials
db_user="my_local_dev_user"
db_pass="my_local_dev_pass"
db_name=${domain//./_}

# Get current datetime for backup folder
datetime=$(date '+%Y%m%d_%H%M%S')
backup_folder="$bak_root/$domain"

current_user=${SUDO_USER:-$(whoami)}

# Create backup folder
mkdir -p "$backup_folder"

# Backup site folder
if [ -d "$site_root" ]; then
  echo "Backing up site folder $site_root..."
  zip -r "$backup_folder/${datetime}_${domain}.zip" "$site_root"
  echo "Site folder backed up to $backup_folder/${datetime}_${domain}.zip"
fi

# Remove hosts entry
echo "Removing hosts entry for $domain..."
sudo sed -i "/127.0.0.1 $domain/d" /etc/hosts

# Remove site folder
if [ -d "$site_root" ]; then
  echo "Removing site folder at $site_root..."
  sudo rm -rf "$site_root"
else
  echo "Site folder $site_root does not exist."
fi

# Remove nginx config file
conf_file="$conf_path/$domain.conf"
if [ -f "$conf_file" ]; then
  echo "Removing nginx config file at $conf_file..."
  sudo rm -f "$conf_file"
else
  echo "Nginx config file $conf_file does not exist."
fi

# Prompt user if they want to delete the database
read -p "Do you want to delete the database $db_name? (yes/no): " delete_db

if [ "$delete_db" == "yes" ]; then
  # Export the database
  echo "Exporting database $db_name..."
  mysqldump -u $db_user -p$db_pass $db_name > "$backup_folder/${datetime}_${domain}-db.sql"

  # Zip the exported database
  echo "Zipping the exported database..."
  zip -j "$backup_folder/${datetime}_${domain}-db.zip" "$backup_folder/${datetime}_${domain}-db.sql"

  # Remove the SQL file after zipping
  rm "$backup_folder/${datetime}_${domain}-db.sql"

  # Delete the database
  echo "Deleting database $db_name..."
  mysql -u root -p -e "DROP DATABASE $db_name;"

  echo "Database $db_name backed up to $backup_folder/${datetime}_${domain}-db.zip"
fi

# Reload nginx to apply changes
sudo systemctl reload nginx

sudo chown -R $current_user:$current_user "$bak_root"

echo "Site $domain has been removed and backed up."

# Output confirmation
echo "Site $domain has been successfully deleted and the backups are stored in $backup_folder."
