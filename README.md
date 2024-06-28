# New Local Site Setup

## Overview

This project provides a set of scripts to help developers quickly set up their local Linux workstation for developing WordPress and Laravel sites. It automates the creation of site directories, configuration of Nginx, and setting up MySQL databases, making it easier to start new projects with consistent settings.

## Features

- **Automated Site Setup**: Quickly create directories, configure Nginx, and set up MySQL databases.
- **WordPress Integration**: Automate the download, configuration, and setup of WordPress sites.
- **Laravel Integration**: Automate the creation of Laravel projects with Composer.
- **Customizable Configuration**: Easily customize paths, user, and group settings through a guided installer.

## Why This Project?

Setting up a local development environment can be time-consuming and prone to inconsistencies. This project aims to streamline the process, ensuring a standardized setup across multiple projects. It saves time and reduces the potential for errors by automating repetitive tasks.

## Installation

1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/jpu4/new-local-site.git
   cd new-local-site

2. Run the installer script to configure your environment:

```bash
./installer.sh
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
./create-site.sh domain_name.local
```

### Creating a WordPress Site

To create a WordPress site:
Run the `create-wp-site.sh` script with your desired domain name:

```bash
./create-wp-site.sh domain_name.local
```

### Creating a Laravel Site

To create a Laravel site:
Run the `create-laravel-site.sh` script with your desired domain name:

```bash
./create-laravel-site.sh domain_name.local
```

### Creating Multiple WordPress Sites

To create multiple WordPress sites:
Update the array of domain names in `create-wp-sites-array.sh`.
Run the script:
```bash
./create-wp-sites-array.sh
```

## File Structure

- `nginx-conf/`: Contains Nginx configuration templates for WordPress, Laravel, and basic sites.
- `create-site.sh`: Script to create a basic site.
- `create-wp-site.sh`: Script to create a WordPress site.
- `create-laravel-site.sh`: Script to create a Laravel site.
- `create-wp-sites-array.sh`: Script to create multiple WordPress sites from an array.
- `installer.sh`: Script to configure your environment and update other scripts with your settings.

## FastCGI Pass Configuration

The default configuration uses `/run/php/php8.2-fpm.sock` for the FastCGI pass. If you need to change this, you can modify the Nginx configuration templates in the `nginx-conf/` directory.

## Contributions

Contributions are welcome! Feel free to submit a pull request or open an issue to suggest improvements or report bugs.