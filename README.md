# New Local Site Setup

## Overview

This project provides a set of scripts to help developers quickly set up their local Linux workstation for developing WordPress and Laravel sites. It automates the creation of site directories, configuration of Nginx, and setting up MySQL databases, making it easier to start new projects with consistent settings.

## Features

- **Automated Site Setup**: Quickly create directories, configure Nginx, and set up MySQL databases.
- **WordPress Integration**: Automate the download, configuration, and setup of WordPress sites.
- **Laravel Integration**: Automate the creation of Laravel projects with Composer.
- **Customizable Configuration**: Easily customize paths, user, and group settings through a guided installer.
- **Plugin Installation**: Automatically install WordPress plugins from ZIP files placed in the plugins folder.
- **Site Deletion with Backup**: Easily delete sites with an option to back up the site and database before deletion.

## Why This Project?

Setting up a local development environment can be time-consuming and prone to inconsistencies. This project aims to streamline the process, ensuring a standardized setup across multiple projects. It saves time and reduces the potential for errors by automating repetitive tasks.

## Installation
> `sudo` is required.

1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/jpu4/new-local-site.git
   cd new-local-site

2. Run the installer script to configure your environment:

```bash
sudo ./installer.sh
```

Follow the prompts to enter your preferred configuration settings, including:

- Nginx configuration folder
- Web root directory
- Web user and group
- Database user and password
- Scripts folder where the customized scripts will be copied

## Usage

### Creating a Basic Site

To create a basic site:
Run the `create-site.sh` script with your desired domain name:

```bash
sudo ./create-site.sh domain_name.local
```

### Creating a WordPress Site

To create a WordPress site:
Run the `create-wp-site.sh` script with your desired domain name:

```bash
sudo ./create-wp-site.sh domain_name.local
```

### Creating a Laravel Site

To create a Laravel site:
Run the `create-laravel-site.sh` script with your desired domain name:

```bash
sudo ./create-laravel-site.sh domain_name.local
```

### Creating Multiple WordPress Sites

To create multiple WordPress sites:
Update the array of domain names in `create-wp-sites-array.sh`.
Run the script:
```bash
sudo ./create-wp-sites-array.sh
```

## Deleting a Site
To delete a site:
Run the delete-site.sh script with your domain name:
```bash
sudo ./delete-site.sh domain_name.local
```
You will be prompted to choose whether to delete the database. If you choose yes, the database will be exported, zipped, and stored in the backup folder before deletion.

## File Structure

- `nginx-conf/`: Contains Nginx configuration templates for WordPress, Laravel, and basic sites.
- `create-site.sh`: Script to create a basic site.
- `create-wp-site.sh`: Script to create a WordPress site.
- `create-laravel-site.sh`: Script to create a Laravel site.
- `create-wp-sites-array.sh`: Script to create multiple WordPress sites from an array.
- `delete-site.sh`: Script to delete a site and optionally back up the site and database.
- `installer.sh`: Script to configure your environment and update other scripts with your settings.
- `scripts/`: Folder where the customized scripts will be copied.
- `web_root/plugins`: Folder to place WordPress plugin ZIP files to be installed during site setup.
- `web_root/bak`: Folder where backups will be stored when sites are deleted.

## FastCGI Pass Configuration

The default configuration uses `/run/php/php8.2-fpm.sock` for the FastCGI pass. If you need to change this, you can modify the Nginx configuration templates in the `nginx-conf/` directory.

## Contributions

Contributions are welcome! Feel free to submit a pull request or open an issue to suggest improvements or report bugs.
