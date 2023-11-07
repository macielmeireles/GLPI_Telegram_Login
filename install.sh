#!/bin/bash

# Variables - Review and modify as needed
folder_exec="/www/site/"                     # WebServer - Folder 
glpi_folder="${folder_exec}glpi"             # GLPI - Folder Install
bot_token="your_bot_token"                   # Telegram - Bot token
chat_id="your_chat_id"                       # Telegram - Chat ID
str_login_success="✅ Login successful: "    # Telegram - Msg ok
str_login_fail="❌ Login failed: "           # Telegram - Msg fail

# Variables - Modify with caution
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
    echo "login.php file restored"
    exit 0
fi

# Download files from GitHub
for file in login_mod.php login_new.php; do
    curl -O $github_url/$file
done

# Download sendTelegram.sh from GitHub if it doesn't exist
if [ ! -f $folder_exec/sendTelegram.sh ]; then
    curl -O $github_url/sendTelegram.sh
    mv sendTelegram.sh $folder_exec/sendTelegram.sh
fi

# Backup local login.php file
mv $glpi_folder/front/login.php $glpi_folder/login_bak_local.php

# Move new files to correct directory
mv login_mod.php $glpi_folder/front/login_mod.php 
mv login_new.php $glpi_folder/front/login.php

# Grant execute permission to sendTelegram.sh file
chmod +x $folder_exec/sendTelegram.sh

# Replace variables in sendTelegram.sh file
sed -i "s/your_token/$bot_token/g" $folder_exec/sendTelegram.sh
sed -i "s/your_chat_id/$chat_id/g" $folder_exec/sendTelegram.sh

# Replace strings in login_mod.php file
sed -i "s|/folder_exec/sendTelegram.sh \"my_string_sucess|${folder_exec}sendTelegram.sh \"$str_login_success|g" $glpi_folder/front/login_mod.php
sed -i "s|/folder_exec/sendTelegram.sh \"my_string_fail|${folder_exec}sendTelegram.sh \"$str_login_fail|g" $glpi_folder/front/login_mod.php

echo " "
echo " "
echo "Installation complete!"
echo " "
echo "To restore, use: ./install --restore"
echo " "
