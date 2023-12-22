#!/bin/bash

# Variables - Review and modify as needed
folder_exec="/www/site"                      # WebServer - Folder 
glpi_folder="${folder_exec}/glpi"            # GLPI - Folder Install
bot_token="your_bot_token"                   # Telegram - Bot token
chat_id="your_chat_id"                       # Telegram - Chat ID
str_login_success="✅ Login successful: "    # Telegram - Msg ok
str_login_fail="❌ Login failed: "           # Telegram - Msg fail
glpi_version="10.0.10"                       # Tested GLPI version
github_url="https://raw.githubusercontent.com/macielmeireles"
glpi_github_url="${github_url}/glpi_sendTelegramLogin/main"
telegram_github_url="${github_url}/GLPI_Telegram_Login/main/sendTelegram.sh"
original_login_file="https://raw.githubusercontent.com/glpi-project/glpi/10.0/bugfixes/front/login.php"
custom_login_file="custom_front_login_with_telegram.php"
new_login_file="new_front_login.php"
backup_login_file="login_bak_local.php"

# Function to check GLPI version
check_glpi_version() {
    current_version=$(grep "define('GLPI_VERSION'" inc/define.php | cut -d ',' -f 2 | tr -d " ');\r")
    if [ "$current_version" != "$glpi_version" ]; then
        echo "Current GLPI version is $current_version, but required version is $glpi_version. Aborting installation."
        exit 1
    fi
}

# Function to download file from GitHub
download_file() {
    if [ ! -f $2 ]; then
        curl -O $1
    fi
}

# Function to replace variables in file
replace_variables() {
    sed -i "s|$1|$2|g" $3
}

# Navigate to GLPI directory
cd $glpi_folder

# Check if --check option is provided
if [ "$1" == "--check" ]; then
    check_glpi_version
    exit 0
fi

# Check if --restore option is provided
if [ "$1" == "--restore" ]; then
    download_file $original_login_file $glpi_folder/front/login.php
    echo "login.php file restored"
    exit 0
fi

# Download files from GitHub
for file in $custom_login_file $new_login_file; do
    download_file $glpi_github_url/$file $glpi_folder/front/$file
done

# Download sendTelegram.sh from GitHub
download_file $telegram_github_url $folder_exec/sendTelegram.sh

# Backup local login.php file
mv $glpi_folder/front/login.php $glpi_folder/front/$backup_login_file

# Move new files to correct directory
mv $custom_login_file $glpi_folder/front/$custom_login_file 
mv $new_login_file $glpi_folder/front/login.php

# Grant execute permission to sendTelegram.sh file
chmod +x $folder_exec/sendTelegram.sh

# Replace variables in sendTelegram.sh file
replace_variables "your_token" "$bot_token" "$folder_exec/sendTelegram.sh"
replace_variables "your_chat_id" "$chat_id" "$folder_exec/sendTelegram.sh"

# Replace strings in custom_front_login_with_telegram.php file
replace_variables "\$folder_exec/sendTelegram.sh \"my_string_sucess" "${folder_exec}/sendTelegram.sh \"$str_login_success" "$glpi_folder/front/$custom_login_file"
replace_variables "\$folder_exec/sendTelegram.sh \"my_string_fail" "${folder_exec}/sendTelegram.sh \"$str_login_fail" "$glpi_folder/front/$custom_login_file"

echo " "
echo " "
echo "Instalação concluída!"
echo " "
echo "Para restaurar, use: ./install --restore"
echo " "
