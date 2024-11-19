#!/bin/bash

# Define variables
SCRIPT_URL="https://raw.githubusercontent.com/<usuario>/<repositorio>/main/<archivo>.sh"
DEST_DIR="/usr/local/bin"
SCRIPT_NAME="pswManager.sh"
ALIAS_COMMAND="alias psw='/usr/local/bin/$SCRIPT_NAME'"

# Descargar el script
echo "Descargando el script desde $SCRIPT_URL..."
wget -q $SCRIPT_URL -O "$DEST_DIR/$SCRIPT_NAME"

# Verificar si la descarga fue exitosa
if [[ $? -ne 0 ]]; then
  echo "Error: No se pudo descargar el script. Verifica la URL."
  exit 1
fi

# Hacer el script ejecutable
chmod +x "$DEST_DIR/$SCRIPT_NAME"

# Añadir alias al bashrc
echo "Configurando alias 'psw'..."
if ! grep -q "$ALIAS_COMMAND" ~/.bashrc; then
  echo "$ALIAS_COMMAND" >> ~/.bashrc
  echo "Alias configurado. Ejecuta 'source ~/.bashrc' para activar."
else
  echo "El alias 'psw' ya está configurado."
fi

echo "Instalación completa. Usa 'psw' para ejecutar tu gestor de contraseñas."

