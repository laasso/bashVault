#!/bin/bash

# Variables
PSW_SCRIPT_URL="https://raw.githubusercontent.com/laasso/gestorPasswords/refs/heads/main/pswManager.sh?token=GHSAT0AAAAAACXUMWWLRML5QHV2NJOMUS6SZZ4Z3JQ"
INSTALL_PATH="/usr/local/bin"
SCRIPT_NAME="pswManager.sh"
ALIAS_NAME="psw"
ALIAS_COMMAND="alias $ALIAS_NAME='$INSTALL_PATH/$SCRIPT_NAME'"

# Verificar permisos
if [[ $EUID -ne 0 ]]; then
  echo "Este instalador requiere permisos de superusuario. Usa 'sudo'."
  exit 1
fi

# Descargar el script del gestor
echo "Descargando el gestor de contraseñas desde $PSW_SCRIPT_URL..."
wget -q $PSW_SCRIPT_URL -O "$INSTALL_PATH/$SCRIPT_NAME"

if [[ $? -ne 0 ]]; then
  echo "Error: No se pudo descargar el script. Verifica la URL."
  exit 1
fi

# Hacer ejecutable el script
chmod +x "$INSTALL_PATH/$SCRIPT_NAME"
echo "El gestor se ha instalado en $INSTALL_PATH/$SCRIPT_NAME."

# Configurar alias en ~/.bashrc
echo "Configurando alias '$ALIAS_NAME'..."
if ! grep -q "$ALIAS_COMMAND" ~/.bashrc; then
  echo "$ALIAS_COMMAND" >> ~/.bashrc
  echo "Alias configurado. Ejecuta 'source ~/.bashrc' para activarlo."
else
  echo "El alias '$ALIAS_NAME' ya está configurado."
fi

echo "Instalación completa. Usa '$ALIAS_NAME' para abrir el gestor de contraseñas."

