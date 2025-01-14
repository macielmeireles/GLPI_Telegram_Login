#!/bin/bash

# Version: 0.5
# Last updated: 01/14/2025
# Description: Installation script for GLPI Telegram Login Integration

# Changelog:
# v0.5 (01/14/2025) - Initial version
#   - Basic installation setup
#   - Telegram integration implementation
#   - Login notification system

# Variables - Review and modify as needed
folder_exec="/www/site"                      # WebServer - Folder 
glpi_folder="${folder_exec}/glpi"            # GLPI - Folder Install
github_glpi_login_orig="https://raw.githubusercontent.com/glpi-project/glpi/10.0/bugfixes/front/login.php"
custom_login_file="custom_front_login_with_telegram.php"
new_login_file="new_front_login.php"
backup_login_file="login_bak_local.php"      # Base name for the backup
telegram_script="$folder_exec/sendTelegram.sh"
telegram_github_url="https://raw.githubusercontent.com/macielmeireles/GLPI_Telegram_Login/main/sendTelegram.sh"
log_file="$folder_exec/install.log"
str_login_success="✅ Login successful: "    # Success message
str_login_fail="❌ Login failed: "           # Failure message

# Function to log operations
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

# Function to check dependencies
check_dependencies() {
    for cmd in curl sed; do
        if ! command -v $cmd &> /dev/null; then
            log "Error: $cmd is not installed."
            exit 1
        fi
    done
}

# Function to download file from GitHub
download_file() {
    curl -o "$2" "$1"
    if [ $? -ne 0 ]; then
        log "Error: Failed to download $2 from $1."
        exit 1
    fi
}

# Function to compare files
compare_files() {
    cmp -s "$1" "$2"
}

# Function to configure sendTelegram.sh
configure_telegram() {
    read -p "Enter your Telegram bot token: " bot_token
    read -p "Enter your Telegram chat ID: " chat_id
    log "Configuring sendTelegram.sh with provided credentials..."
    sed -i "s/your_bot_token/$bot_token/g" "$telegram_script"
    sed -i "s/your_chat_id/$chat_id/g" "$telegram_script"
    log "Configuration completed."
}

# Function to display help
show_help() {
    cat << EOF
Usage: ./install.sh [options]

Options:
  --check       Verify if the local login.php file matches the official one.
  --restore     Restore the login.php file from the official repository.
  --help        Display this help message.
EOF
}

# Function to create incremental backup
create_incremental_backup() {
    local base_name="$1"
    local ext="$2"
    local count=1
    while [ -f "${base_name}.${count}${ext}" ]; do
        count=$((count + 1))
    done
    mv "$base_name$ext" "${base_name}.${count}${ext}"
    log "Backup created as ${base_name}.${count}${ext}."
}

# Check dependencies
check_dependencies

# Navigate to the GLPI directory
cd "$glpi_folder" || { log "Error accessing the GLPI directory."; exit 1; }

# Handle script options
case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --check)
        download_file "$github_glpi_login_orig" "$folder_exec/login_github.php"
        if compare_files "$glpi_folder/front/login.php" "$folder_exec/login_github.php"; then
            log "The local login.php file matches the official GLPI login.php file. It is safe to proceed."
            exit 0
        else
            log "The local login.php file does not match the official GLPI login.php file. It is not safe to proceed."
            exit 1
        fi
        ;;
    --restore)
        download_file "$github_glpi_login_orig" "$glpi_folder/front/login.php"
        log "login.php file restored."
        exit 0
        ;;
    "")
        log "No option provided. Proceeding with default installation."
        ;;
    *)
        log "Error: Invalid option '$1'."
        show_help
        exit 1
        ;;
esac

# Check if sendTelegram.sh exists, otherwise download and configure
if [ ! -f "$telegram_script" ]; then
    log "sendTelegram.sh not found. Downloading and configuring..."
    download_file "$telegram_github_url" "$telegram_script"
    chmod +x "$telegram_script"
    configure_telegram
fi

# Download custom login files from GitHub
download_file "https://raw.githubusercontent.com/macielmeireles/glpi_sendTelegramLogin/main/$custom_login_file" "$folder_exec/$custom_login_file"
download_file "https://raw.githubusercontent.com/macielmeireles/glpi_sendTelegramLogin/main/$new_login_file" "$folder_exec/$new_login_file"

# Backup the local login.php file, if it exists
if [ -f "$glpi_folder/front/login.php" ]; then
    if [ -f "$glpi_folder/front/$backup_login_file" ]; then
        download_file "$github_glpi_login_orig" "$folder_exec/login_github.php"
        if compare_files "$glpi_folder/front/$backup_login_file" "$folder_exec/login_github.php"; then
            log "The existing backup login_bak_local.php matches the official GLPI login.php file. No new backup needed."
        else
            create_incremental_backup "$glpi_folder/front/login_bak_local" ".php"
        fi
    else
        mv "$glpi_folder/front/login.php" "$glpi_folder/front/$backup_login_file"
        log "Backup of the original login.php created as $backup_login_file."
    fi
fi

# Move new files to the correct directory
mv "$folder_exec/$custom_login_file" "$glpi_folder/front/$custom_login_file"
mv "$folder_exec/$new_login_file" "$glpi_folder/front/login.php"

# Replace strings in custom_front_login_with_telegram.php
sed -i "s|\$folder_exec/sendTelegram.sh \"my_string_sucess|${folder_exec}/sendTelegram.sh \"$str_login_success|g" "$glpi_folder/front/$custom_login_file"
sed -i "s|\$folder_exec/sendTelegram.sh \"my_string_fail|${folder_exec}/sendTelegram.sh \"$str_login_fail|g" "$glpi_folder/front/$custom_login_file"

log "Installation completed!"
log "To restore, use: ./install.sh --restore"