#!/bin/bash

# Configuración inicial: nombre de la base de datos
DB="password_manager.db"

# Crear la base de datos y tabla si no existen
sqlite3 $DB "CREATE TABLE IF NOT EXISTS passwords (
    id INTEGER PRIMARY KEY,
    usuario TEXT NOT NULL,
    password TEXT NOT NULL,
    sitio TEXT NOT NULL,
    nombrepassword TEXT NOT NULL
);"
sqlite3 $DB "CREATE TABLE IF NOT EXISTS master_key (
    id INTEGER PRIMARY KEY,
    key_hash TEXT NOT NULL
);"

# Función para cifrar una cadena usando AES-256-CBC y PBKDF2 con ficheros temporales
encrypt_password() {
    local password="$1"
    local master_key="$2"

    # Crear un archivo temporal con la contraseña en texto plano
    echo -n "$password" > plain.txt

    # Cifrar el archivo con openssl y luego codificarlo en base64
    openssl enc -pbkdf2 -k "$master_key" -aes256 -e -in plain.txt | base64 > cipher.txt

    # Eliminar el archivo temporal con la contraseña en texto plano
    rm -f plain.txt
}

# Función para descifrar la contraseña utilizando openssl y ficheros
decrypt_password() {
    local encrypted_password_file="$1"
    local master_key="$2"

    # Verificar si el archivo cifrado existe
    if [ ! -f "$encrypted_password_file" ]; then
        echo "Error: El archivo cifrado no existe."
        exit 1
    fi

    # Decodificar el archivo de base64 y luego desencriptar
    base64 -d "$encrypted_password_file" | openssl enc -pbkdf2 -k "$master_key" -aes256 -d -out plain_again.txt

    # Verificar si la desencriptación fue exitosa
    if [ ! -f plain_again.txt ]; then
        echo "Error al desencriptar la contraseña."
        exit 1
    fi

    # Mostrar el contenido del archivo desencriptado
    cat plain_again.txt

    # Eliminar el archivo temporal con la contraseña desencriptada
    rm -f plain_again.txt
}

# Función para generar el hash SHA-256 de una clave
generate_key_hash() {
    local key="$1"
    echo -n "$key" | sha256sum | awk '{print $1}'
}

# Función para inicializar la clave maestra
initialize_master_key() {
    local stored_key_hash
    stored_key_hash=$(sqlite3 $DB "SELECT key_hash FROM master_key LIMIT 1;")

    if [ -z "$stored_key_hash" ]; then
        echo "No se ha configurado una clave maestra. Por favor, cree una:"
        read -s -p "Nueva clave maestra: " MASTER_KEY
        echo
        read -s -p "Confirme la nueva clave maestra: " confirm_key
        echo
        if [ "$MASTER_KEY" != "$confirm_key" ]; then
            echo "Las claves maestras no coinciden. Reinicie el programa e intente de nuevo."
            exit 1
        fi
        # Guardar el hash de la clave maestra en la base de datos
        key_hash=$(generate_key_hash "$MASTER_KEY")
        sqlite3 $DB "INSERT INTO master_key (key_hash) VALUES ('$key_hash');"
        echo "Clave maestra configurada exitosamente."
    else
        # Pedir clave maestra al usuario y verificarla
        echo "Ingrese la clave maestra para desbloquear el gestor:"
        read -s MASTER_KEY_TRY
        echo
        
        stored_key_hash=$(sqlite3 "$DB" "SELECT key_hash FROM master_key LIMIT 1;")
        
        # Generar el hash de la clave maestra ingresada
        entered_key_hash=$(generate_key_hash "$MASTER_KEY_TRY")
        
        # Comparar el hash de la clave ingresada con el almacenado
        if [ "$entered_key_hash" != "$stored_key_hash" ]; then
            echo "Clave maestra incorrecta."
            exit 1
        fi
        
        MASTER_KEY="$MASTER_KEY_TRY"
        echo "Gestor desbloqueado."
    fi
}

# Función para añadir una nueva contraseña
add_password() {
    read -p "Usuario: " usuario
    read -p "Sitio: " sitio
    read -p "Nombre para la contraseña: " nombrepassword
    read -s -p "Contraseña: " password
    echo

    # Cifrar la contraseña con la clave maestra
    encrypt_password "$password" "$MASTER_KEY"

    # Leer el contenido del archivo cifrado
    encrypted_password=$(cat cipher.txt)

    # Insertar en la base de datos
    sqlite3 $DB "INSERT INTO passwords (usuario, password, sitio, nombrepassword) VALUES ('$usuario', '$encrypted_password', '$sitio', '$nombrepassword');"
    echo "Contraseña guardada correctamente."

    # Eliminar el archivo temporal cifrado
    rm -f cipher.txt
}

# Función para obtener y descifrar una contraseña
get_password() {
    read -p "Nombre de la contraseña: " nombrepassword

    # Recuperar la contraseña cifrada desde la base de datos
    encrypted_password=$(sqlite3 $DB "SELECT password FROM passwords WHERE nombrepassword='$nombrepassword';")
    if [ -z "$encrypted_password" ]; then
        echo "La contraseña no existe."
        return
    fi

    # Guardar la contraseña cifrada en un archivo temporal
    echo -n "$encrypted_password" > cipher.txt
    echo "Archivo cifrado guardado como cipher.txt"

    # Desencriptar la contraseña y mostrarla
    decrypted_password=$(decrypt_password "cipher.txt" "$MASTER_KEY")

    # Comprobar si el descifrado fue exitoso
    if [ $? -eq 0 ]; then
        echo "Contraseña desencriptada: $decrypted_password"
    else
        echo "Error: No se pudo desencriptar el archivo."
    fi

    # Eliminar el archivo temporal cifrado
    rm -f cipher.txt
}

# Función para listar las contraseñas guardadas
list_passwords() {
    sqlite3 $DB "SELECT id, usuario, sitio, nombrepassword FROM passwords;" | while read -r row; do
        IFS="|" read -r id usuario sitio nombrepassword <<< "$row"
        echo "ID: $id | Usuario: $usuario | Sitio: $sitio | Nombre: $nombrepassword"
    done
}

# Inicializar la clave maestra (solicita la clave y desbloquea el gestor)
initialize_master_key

# Menú principal
while true; do
    echo "Gestor de Contraseñas"
    echo "1. Añadir nueva contraseña"
    echo "2. Consultar una contraseña"
    echo "3. Listar todas las contraseñas"
    echo "4. Salir"
    read -p "Seleccione una opción: " option

    case $option in
        1) add_password ;;
        2) get_password ;;
        3) list_passwords ;;
        4) exit ;;
        *) echo "Opción inválida." ;;
    esac
done
