#!/bin/bash

# Variables - Review and modify as needed
glpi_folder="/www/site/glpi"
bot_token="your_token_bot"
chat_id="your_chat_id"

glpi_version="10.0.10"
github_url="https://raw.githubusercontent.com/macielmeireles/glpi_sendTelegramLogin/main"
original_login_file="https://raw.githubusercontent.com/glpi-project/glpi/10.0/bugfixes/front/login.php"

# Navigate to GLPI directory
cd $glpi_folder

# Check GLPI version
current_version=$(grep "define('GLPI_VERSION'" inc/define.php | cut -d ',' -f 2 | tr -d " ');\r")
if [ "$current_version" != "$glpi_version" ]; then
    echo "Current GLPI version is $current_version, but required version is $glpi_version. Aborting installation."
    exit 1
fi

# Check if --restore option is provided
if [ "$1" == "--restore" ]; then
    curl -o $glpi_folder/front/login.php $original_login_file
    echo ""
    echo ""
    echo "original login.php file restored"
    echo ""
    exit 0
fi

# Download files from GitHub
for file in login_mod.php login_new.php sendTelegram.sh; do
    curl -O $github_url/$file
done

# Backup local login.php file
mv $glpi_folder/front/login.php $glpi_folder/login_bak_local.php

# Move new files to correct directory
mv login_mod.php $glpi_folder/front/login_mod.php 
mv login_new.php $glpi_folder/front/login.php
mv sendTelegram.sh $glpi_folder/../sendTelegram.sh

# Grant execute permission to sendTelegram.sh file
chmod +x $glpi_folder/../sendTelegram.sh

# Replace variables in sendTelegram.sh file
sed -i "s/your_token/$bot_token/g" $glpi_folder/../sendTelegram.sh
sed -i "s/your_chat_id/$chat_id/g" $glpi_folder/../sendTelegram.sh

echo " "
echo " "
echo "Installation complete!"
echo " "
echo "To restore, use: ./install --restore"
echo " "
