#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo -n "$password" > plain.txt
    openssl enc -pbkdf2 -k "$master_key" -aes256 -e -in plain.txt | base64 > cipher.txt
    rm -f plain.txt
}

# Función para descifrar la contraseña utilizando openssl y ficheros
decrypt_password() {
    local encrypted_password_file="$1"
    local master_key="$2"
    if [ ! -f "$encrypted_password_file" ]; then
        echo -e "${RED}Error: El archivo cifrado no existe.${NC}"
        return 1
    fi
    base64 -d "$encrypted_password_file" | openssl enc -pbkdf2 -k "$master_key" -aes256 -d -out plain_again.txt
    if [ ! -f plain_again.txt ]; then
        echo -e "${RED}Error al desencriptar la contraseña.${NC}"
        return 1
    fi
    cat plain_again.txt
    rm -f plain_again.txt
}

# Función para generar el hash SHA-256 de una clave
generate_key_hash() {
    local key="$1"
    echo -n "$key" | sha256sum | awk '{print $1}'
}

# Función para generar una contraseña aleatoria de mínimo 15 caracteres
generate_random_password() {
    tr -dc 'A-Za-z0-9_@#$%^&+=!' </dev/urandom | head -c 15
    echo
}

# Función para inicializar la clave maestra
initialize_master_key() {
    local stored_key_hash
    stored_key_hash=$(sqlite3 $DB "SELECT key_hash FROM master_key LIMIT 1;")

    if [ -z "$stored_key_hash" ]; then
        echo -e "${YELLOW}No se ha configurado una clave maestra. Por favor, cree una:${NC}"
        read -s -p "Nueva clave maestra: " MASTER_KEY
        echo
        read -s -p "Confirme la nueva clave maestra: " confirm_key
        echo
        if [ "$MASTER_KEY" != "$confirm_key" ]; then
            echo -e "${RED}Las claves maestras no coinciden. Reinicie el programa e intente de nuevo.${NC}"
            exit 1
        fi
        key_hash=$(generate_key_hash "$MASTER_KEY")
        sqlite3 $DB "INSERT INTO master_key (key_hash) VALUES ('$key_hash');"
        echo -e "${GREEN}Clave maestra configurada exitosamente.${NC}"
    else
        echo -e "${YELLOW}Ingrese la clave maestra para desbloquear el gestor:${NC}"
        read -s MASTER_KEY_TRY
        echo
        
        stored_key_hash=$(sqlite3 "$DB" "SELECT key_hash FROM master_key LIMIT 1;")
        entered_key_hash=$(generate_key_hash "$MASTER_KEY_TRY")
        
        if [ "$entered_key_hash" != "$stored_key_hash" ]; then
            echo -e "${RED}Clave maestra incorrecta.${NC}"
            exit 1
        fi
        
        MASTER_KEY="$MASTER_KEY_TRY"
        echo -e "${GREEN}Gestor desbloqueado.${NC}"
    fi
}

# Función para añadir una nueva contraseña
add_password() {
    echo -e "${YELLOW}Usuario:${NC}"
    read usuario
    echo -e "${YELLOW}Sitio:${NC}"
    read sitio
    echo -e "${YELLOW}Nombre para la contraseña:${NC}"
    read nombrepassword

    echo -e "${YELLOW}¿Desea generar una contraseña aleatoria? (s/n):${NC}"
    read generar_aleatoria
    if [[ "$generar_aleatoria" == "s" ]]; then
        password=$(generate_random_password)
        echo -e "${GREEN}Contraseña generada: $password${NC}"
    else
        echo -e "${YELLOW}Contraseña:${NC}"
        read -s password
        echo
    fi

    encrypt_password "$password" "$MASTER_KEY"
    encrypted_password=$(cat cipher.txt)

    sqlite3 $DB "INSERT INTO passwords (usuario, password, sitio, nombrepassword) VALUES ('$usuario', '$encrypted_password', '$sitio', '$nombrepassword');"
    echo -e "${GREEN}Contraseña guardada correctamente.${NC}"

    rm -f cipher.txt
}

copy_to_clipboard() {
    echo -n "$1" | xclip -selection clipboard
}

get_password() {
    list_passwords
    echo -e "${YELLOW}ID de la contraseña:${NC}"
    read idpassword

    encrypted_password=$(sqlite3 $DB "SELECT password FROM passwords WHERE id='$idpassword';")
    if [ -z "$encrypted_password" ]; then
        echo -e "${RED}La contraseña no existe.${NC}"
        return
    fi

    echo -n "$encrypted_password" > cipher.txt
    decrypted_password=$(decrypt_password "cipher.txt" "$MASTER_KEY")

    if [ $? -eq 0 ]; then
       echo -e " "
    else
        echo -e "${RED}Error: No se pudo desencriptar el archivo.${NC}"
        rm -f cipher.txt
        return
    fi

    # Preguntar al usuario si desea ver o copiar la contraseña
    echo -e "\n${YELLOW}¿Qué te gustaría hacer con la contraseña?${NC}"
    echo "1. Ver la contraseña durante 10 segundos"
    echo "2. Copiar la contraseña al portapapeles"
    read -p "Seleccione una opción: " action

    case $action in
        1)
            echo -e "${GREEN}La contraseña es: $decrypted_password${NC}"
            echo "La contraseña se ocultará en 10 segundos..."
            sleep 10
            clear
            ;;
        2)
            if copy_to_clipboard "$decrypted_password"; then
                echo -e "${GREEN}Contraseña copiada al portapapeles.${NC}"
                echo "La contraseña se borrará del portapapeles en 30 segundos..."
                (sleep 30; copy_to_clipboard "") &
            else
                echo -e "${YELLOW}No se pudo copiar automáticamente. Aquí está la contraseña para copiar manualmente:${NC}"
                echo -e "${GREEN}$decrypted_password${NC}"
                echo "La contraseña se ocultará en 10 segundos..."
                sleep 10
                clear
            fi
            ;;
        *)
            echo -e "${RED}Opción inválida.${NC}"
            ;;
    esac

    # Limpiar archivo temporal
    rm -f cipher.txt
}

# Función para listar las contraseñas guardadas
list_passwords() {
    echo -e "${BLUE}Contraseñas guardadas:${NC}"
    printf "${YELLOW}%-4s | %-20s | %-20s | %-20s | %-30s${NC}\n" "ID" "Usuario" "Sitio" "Nombre" "Contraseña"
    echo "-----+----------------------+----------------------+----------------------+-------------------------------"
    sqlite3 $DB "SELECT id, usuario, sitio, nombrepassword, password FROM passwords;" | while IFS='|' read -r id usuario sitio nombrepassword encrypted_password; do
        masked_password=$(echo "$encrypted_password" | sed 's/./*/g')
        printf "${GREEN}%-4s${NC} | ${GREEN}%-20s${NC} | ${GREEN}%-20s${NC} | ${GREEN}%-20s${NC} | ${GREEN}%-30s${NC}\n" "$id" "$usuario" "$sitio" "$nombrepassword" "$masked_password"
    done
}

# Función para eliminar una contraseña
delete_password() {
    echo -e "${YELLOW}Ingrese el ID de la contraseña a eliminar:${NC}"
    read id
    sqlite3 $DB "DELETE FROM passwords WHERE id=$id;"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Contraseña eliminada con éxito.${NC}"
    else
        echo -e "${RED}No se encontró la contraseña especificada.${NC}"
    fi
}

end_message() {
  echo -e "${GREEN}¡Hasta luego!${NC}"
  echo -e "\n${RED}made by laasso & ikerm01${NC}"
  echo -e "https://github.com/laasso/gestorPasswords"
  echo -e "\n${YELLOW}Licencia MIT${NC}"
  echo -e "Copyright (c) 2024 laasso & ikerm01"

} 


# Menú principal
main_menu() {
    while true; do
        echo -e "\n${BLUE}=== Gestor de Contraseñas ===${NC}"
        echo -e "${YELLOW}1. Añadir nueva contraseña${NC}"
        echo -e "${YELLOW}2. Consultar una contraseña${NC}"
        echo -e "${YELLOW}3. Listar todas las contraseñas${NC}"
        echo -e "${YELLOW}4. Eliminar una contraseña${NC}"
        echo -e "${YELLOW}5. Salir${NC}"
        echo -e "${BLUE}=============================${NC}"
        echo -e "${YELLOW}Seleccione una opción:${NC}"
        read option

        case $option in
            1) add_password ;;
            2) get_password ;;
            3) list_passwords ;;
            4) delete_password ;;
            5) 
                clear
                end_message
                exit 0
                ;;
            *) echo -e "${RED}Opción inválida. Por favor, intente de nuevo.${NC}" ;;
        esac
    done
}

# Inicializar la clave maestra
initialize_master_key

# Ejecutar el menú principal
main_menu
