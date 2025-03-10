#!/bin/bash

# Prompt user for the preferred nginx configuration folder
read -p "Enter your preferred nginx configuration folder (default: /etc/nginx/conf.d): " conf_path
conf_path=${conf_path:-/etc/nginx/conf.d}

# Prompt user for the web root directory
read -p "Enter your web root directory (default: /var/www): " web_root
web_root=${web_root:-/var/www}

# Create the wordpress plugins folder if it doesn't exist
mkdir -p "$web_root/plugins"

# Create the logs folder if it doesn't exist
mkdir -p "$web_root/logs"

# Create the backup folder if it doesn't exist
mkdir -p "$web_root/bak"

# Prompt user for the sites directory
read -p "Enter your web sites directory (default: /var/www/sites): " sites_root
sites_root=${sites_root:-/var/www/sites}

# Create the sites folder if it doesn't exist
mkdir -p $sites_root

# Prompt user for the default web user
read -p "Enter your web user (default: www-data): " web_user
web_user=${web_user:-www-data}

# Prompt user for the default web group
read -p "Enter your web group (default: www-data): " web_group
web_group=${web_group:-www-data}

# Prompt user for the database user
read -p "Enter your database user (default: my_local_dev_user): " db_user
db_user=${db_user:-my_local_dev_user}

# Prompt user for the database password
read -p "Enter your database password (default: my_local_dev_pass): " db_pass
db_pass=${db_pass:-my_local_dev_pass}

# Prompt user for the scripts folder
read -p "Enter the folder where you want the scripts copied (default: /var/www/scripts): " scripts_folder
scripts_folder=${scripts_folder:-/var/www/scripts}

# Create the scripts folder if it doesn't exist
mkdir -p "$scripts_folder"

# Copy and update variables in the script files
for script in create-site.sh create-laravel-site.sh create-wp-site.sh create-wp-sites-array.sh delete-site.sh; do
    if [ -f "$script" ]; then
        cp $script "$scripts_folder/"
        script_path="$scripts_folder/$(basename $script)"
        sed -i "s|conf_path=.*|conf_path=\"$conf_path\"|" $script_path
        sed -i "s|web_root=.*|web_root=\"$web_root\"|" $script_path
        sed -i "s|sites_root=.*|sites_root=\"$sites_root\"|" $script_path
        sed -i "s|web_user=.*|web_user=\"$web_user\"|" $script_path
        sed -i "s|web_group=.*|web_group=\"$web_group\"|" $script_path
        sed -i "s|db_user=.*|db_user=\"$db_user\"|" $script_path
        sed -i "s|db_pass=.*|db_pass=\"$db_pass\"|" $script_path
    fi
done

# Check if the specified nginx configuration folder exists, if not create it
if [ ! -d "$conf_path" ]; then
    echo "Configuration folder does not exist. Creating $conf_path..."
    sudo mkdir -p "$conf_path"
fi

# Copy nginx configuration templates to the specified folder
echo "Copying nginx configuration templates to $conf_path..."
sudo cp nginx-conf/*.template "$conf_path/"

# Confirm the installation
echo "Configuration templates have been copied to $conf_path."
echo "Scripts have been copied to $scripts_folder and configured with your settings."

# Optional: Set execute permissions on the copied scripts
chmod +x "$scripts_folder/create-site.sh" "$scripts_folder/create-laravel-site.sh" "$scripts_folder/create-wp-site.sh" "$scripts_folder/create-wp-sites-array.sh" "$scripts_folder/delete-site.sh"

# Debugging: Print current user and scripts folder
current_user=${SUDO_USER:-$(whoami)}
echo "Current user: $current_user"
echo "Scripts folder: $scripts_folder"

# Change ownership of the scripts folder to the current user
sudo chown -R $current_user:$current_user "$scripts_folder"
sudo chown -R $web_user:$web_group "$sites_root"
sudo chown -R $current_user:$current_user "$web_root/plugins"
sudo chown -R $current_user:$current_user "$web_root/bak"
sudo chown -R $current_user:$current_user "$web_root/logs"

echo "Installer script has completed successfully."
cd "$scripts_folder"
