#!/bin/bash

# Variáveis
glpi_folder="/www/site/glpi"
glpi_version="10.0.10"
github_url="https://raw.githubusercontent.com/macielmeireles/glpi_sendTelegramLogin/main"
original_login_file="https://raw.githubusercontent.com/glpi-project/glpi/$glpi_version/bugfixes/front/login.php"
bot_token="seu_token_do_bot"
chat_id="seu_chat_id"

# Navega para a pasta do GLPI
cd $glpi_folder

# Verifica a versão do GLPI
current_version=$(php -r "include 'inc/config.php'; echo substr(trim(GLPI_VERSION), 0, 6);")
if [ "$current_version" != "$glpi_version" ]; then
    echo "A versão atual do GLPI é $current_version, mas a versão necessária é $glpi_version. Interrompendo a instalação."
    exit 1
fi

# Verifica se a opção --restore foi fornecida
if [ "$1" == "--restore" ]; then
    curl -o front/login.php $original_login_file
    echo "Arquivo login.php restaurado"
    exit 0
fi

# Baixa os arquivos do GitHub
for file in login_mod.php login_new.php sendTelegram.sh; do
    curl -O $github_url/$file
done

# Faz backup do arquivo login.php local
mv front/login.php login_bak_local.php

# Move os novos arquivos para a pasta correta
mv login_mod.php front/login_mod.php 
mv login_new.php front/login.php
mv sendTelegram.sh ../sendTelegram.sh

echo "Fim"

