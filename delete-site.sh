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

# Reload nginx to apply changes
sudo systemctl reload nginx

echo "Site $domain has been removed."

# Output confirmation
echo "Site $domain has been successfully deleted."
