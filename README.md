# Glpi_Telegram_Login
GLPI | This script automates the setup of a Telegram login feature for GLPI, managing the download, backup, and configuration of necessary files.
<br /><br />

## Donation | Doações
(En)      Support our project via Pix or PayPal.<br />
(Pt-Br) Apoie nosso projeto via Pix ou PayPal:<br /><br />

Brazilian Pix: d56da244-4dc5-4f77-be6d-28e94fdd46b2<br />
Paypal: https://bit.ly/MonitTelegram<br />

## Descrição
- Este script automatiza a instalação e configuração de um recurso de login do Telegram para o GLPI.
- Ele verifica a versão do GLPI, faz o download de arquivos necessários do GitHub, faz backup do arquivo login.php existente, move os novos arquivos para o diretório correto, concede permissão de execução ao arquivo sendTelegram.sh e substitui variáveis nos arquivos baixados.
- O script também fornece opções para verificar a versão do GLPI e restaurar o arquivo login.php original.
<br /><br />

## Description
- This script automates the installation and configuration of a Telegram login feature for GLPI.
- It checks the GLPI version, downloads necessary files from GitHub, backs up the existing login.php file, moves the new files to the correct directory, grants execute permission to the sendTelegram.sh file, and replaces variables in the downloaded files.
- The script also provides options to check the GLPI version and restore the original login.php file.

## Instalação 
- Irei detalhar mas basicamente: 
1) Acesse o terminal como root.
2) Baixe o instalador: `wget https://raw.githubusercontent.com/macielmeireles/GLPI_Telegram_Login/main/install.sh`
3) Edite as variaveis no topo do script, ex: `nano install.sh`
4) Dê permissão de execução: `chmod +x install.sh`
5) Execute: `./install.sh`

<br /><br />

## Installation
- I will go into detail but basically:
1) Access the terminal as root.
2) Download the installer: `wget https://raw.githubusercontent.com/macielmeireles/GLPI_Telegram_Login/main/install.sh`
3) Edit the variables at the top of the script, e.g. `nano install.sh`
4) Give execute permission: `chmod +x install.sh`
5) Run: `./install.sh`
