#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MASTER_KEY="/home/imacias/sad/openssl/master_key.pem"
PUBLIC_KEY="/home/imacias/sad/openssl/master_key_public.pem"
PASSWORD_FILE="/home/imacias/sad/passwords.enc"
LOGIN_FILE="/home/imacias/sad/login.enc"

create_master_password() {
    echo -e "${YELLOW}Primera ejecución detectada. Por favor, cree una contraseña maestra:${NC}"
    read -s master_password
    echo

    openssl genpkey -algorithm RSA -out "$MASTER_KEY" 2>/dev/null
    chmod 600 "$MASTER_KEY"
    openssl rsa -pubout -in "$MASTER_KEY" -out "$PUBLIC_KEY" 2>/dev/null
    echo -n "$master_password" | openssl pkeyutl -encrypt -pubin -inkey "$PUBLIC_KEY" -out "$LOGIN_FILE"
    
    echo -e "${GREEN}Contraseña maestra creada con éxito.${NC}"
}

verify_master_password() {
    echo -e "${YELLOW}Ingrese la contraseña maestra:${NC}"
    read -s input_password
    echo

    decrypted_password=$(openssl pkeyutl -decrypt -inkey "$MASTER_KEY" -in "$LOGIN_FILE" 2>/dev/null)

    if [ "$?" -eq 0 ] && [ "$decrypted_password" == "$input_password" ]; then
        master_key="$input_password"
        return 0
    else
        echo -e "${RED}Contraseña incorrecta.${NC}"
        return 1
    fi
}

add_password() {
    echo -e "${YELLOW}Ingrese el nombre del servicio:${NC}"
    read service
    echo -e "${YELLOW}Elija una opción para la contraseña:${NC}"
    echo "1. Ingresar manualmente"
    echo "2. Generar contraseña aleatoria"
    read -p "Opción: " password_option

    case $password_option in
        1)
            echo -e "${YELLOW}Ingrese la contraseña para $service:${NC}"
            read -s password
            echo
            ;;
        2)
            password=$(openssl rand -base64 16)
            echo -e "${GREEN}Contraseña generada: $password${NC}"
            ;;
        *)
            echo -e "${RED}Opción inválida. Saliendo...${NC}"
            return 1
            ;;
    esac

    # Generar una sal única para esta contraseña
    salt=$(openssl rand -hex 16)

    # Cifrar la contraseña con AES-256-CBC
    encrypted=$(echo -n "$service:$password:$salt" | openssl enc -aes-256-cbc -k "$master_key" -salt -pbkdf2 -base64 -A)
    
    if [ $? -eq 0 ]; then
        echo "$encrypted" >> "$PASSWORD_FILE"
        echo -e "${GREEN}Contraseña agregada con éxito.${NC}"
    else
        echo -e "${RED}Error al cifrar la contraseña.${NC}"
    fi
}

view_passwords() {
    if [ ! -f "$PASSWORD_FILE" ] || [ ! -s "$PASSWORD_FILE" ]; then
        echo -e "${RED}No hay contraseñas guardadas.${NC}"
        return
    fi

    echo -e "${BLUE}Contraseñas guardadas:${NC}"
    printf "${YELLOW}%-4s | %-20s | %-30s${NC}\n" "ID" "Servicio" "Contraseña"
    echo "-----+----------------------+-------------------------------"
    
    id=1
    declare -A password_map
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            decrypted=$(echo "$line" | openssl enc -aes-256-cbc -d -k "$master_key" -pbkdf2 -base64 -A 2>/dev/null)
            if [ $? -eq 0 ]; then
                service=$(echo "$decrypted" | cut -d':' -f1)
                password=$(echo "$decrypted" | cut -d':' -f2)
                masked_password=$(echo "$password" | sed 's/./*/g')
                printf "${GREEN}%-4s${NC} | ${GREEN}%-20s${NC} | ${GREEN}%-30s${NC}\n" "$id" "$service" "$masked_password"
                password_map[$id]="$service:$password"
                ((id++))
            fi
        fi
    done < "$PASSWORD_FILE"

    copy_to_clipboard() {
        local text="$1"
        if command -v xclip &> /dev/null; then
            echo -n "$text" | xclip -selection clipboard
            return 0
        elif command -v xsel &> /dev/null; then
            echo -n "$text" | xsel --clipboard --input
            return 0
        else
            return 1
        fi
    }

    while true; do
        echo -e "\n${YELLOW}Opciones:${NC}"
        echo "1. Revelar contraseña"
        echo "2. Copiar contraseña al portapapeles"
        echo "3. Volver al menú principal"
        read -p "Seleccione una opción: " option

        case $option in
            1)
                read -p "Ingrese el ID de la contraseña que desea revelar: " reveal_id
                if [[ -n "${password_map[$reveal_id]}" ]]; then
                    IFS=':' read -r service password <<< "${password_map[$reveal_id]}"
                    echo -e "\n${GREEN}Servicio: $service${NC}"
                    echo -e "${GREEN}Contraseña: $password${NC}"
                    echo "La contraseña se ocultará en 10 segundos..."
                    sleep 10
                    clear
                else
                    echo -e "${RED}ID inválido.${NC}"
                fi
                ;;
            2)
                read -p "Ingrese el ID de la contraseña que desea copiar: " copy_id
                if [[ -n "${password_map[$copy_id]}" ]]; then
                    password=$(echo "${password_map[$copy_id]}" | cut -d':' -f2)
                    if copy_to_clipboard "$password"; then
                        echo -e "${GREEN}Contraseña copiada al portapapeles.${NC}"
                        echo "La contraseña se borrará del portapapeles en 30 segundos..."
                        (sleep 30; copy_to_clipboard "") &
                    else
                        echo -e "${YELLOW}No se pudo copiar automáticamente. Aquí está la contraseña para copiar manualmente:${NC}"
                        echo -e "${GREEN}$password${NC}"
                        echo "La contraseña se ocultará en 10 segundos..."
                        sleep 10
                        clear
                    fi
                else
                    echo -e "${RED}ID inválido.${NC}"
                fi
                ;;
            3)
                return
                ;;
            *)
                echo -e "${RED}Opción inválida.${NC}"
                ;;
        esac
    done
}

delete_password() {
    echo -e "${YELLOW}Ingrese el nombre del servicio a eliminar:${NC}"
    read service

    temp_file=$(mktemp)
    deleted=false

    while IFS= read -r line; do
        if [ -n "$line" ]; then
            decrypted=$(echo "$line" | openssl enc -aes-256-cbc -d -k "$master_key" -pbkdf2 -base64 -A 2>/dev/null)
            if [[ $decrypted != $service:* ]]; then
                echo "$line" >> "$temp_file"
            else
                deleted=true
            fi
        fi
    done < "$PASSWORD_FILE"

    mv "$temp_file" "$PASSWORD_FILE"

    if $deleted; then
        echo -e "${GREEN}Contraseña eliminada con éxito.${NC}"
    else
        echo -e "${RED}No se encontró el servicio especificado.${NC}"
    fi
}

main_menu() {
    while true; do
        echo -e "\n${BLUE}=== Gestor de Contraseñas ===${NC}"
        echo -e "${YELLOW}1. Agregar nueva contraseña${NC}"
        echo -e "${YELLOW}2. Ver contraseñas guardadas${NC}"
        echo -e "${YELLOW}3. Eliminar una contraseña${NC}"
        echo -e "${YELLOW}4. Salir${NC}"
        echo -e "${BLUE}=============================${NC}"
        echo -e "${YELLOW}Seleccione una opción:${NC}"
        read option

        case $option in
            1) add_password ;;
            2) view_passwords ;;
            3) delete_password ;;
            4) echo -e "${GREEN}¡Hasta luego!${NC}"; exit 0 ;;
            *) echo -e "${RED}Opción inválida. Por favor, intente de nuevo.${NC}" ;;
        esac
    done
}

if ! command -v openssl &> /dev/null; then
    echo -e "${RED}OpenSSL no está instalado. Por favor, instálalo e intenta de nuevo.${NC}"
    exit 1
fi

if [ ! -f "$LOGIN_FILE" ] || [ ! -f "$PUBLIC_KEY" ]; then
    create_master_password
fi

max_attempts=3
for ((i=1; i<=max_attempts; i++)); do
    if verify_master_password; then
        main_menu
        exit 0
    else
        if [ $i -lt $max_attempts ]; then
            echo -e "${RED}Intento $i de $max_attempts. Por favor, intente de nuevo.${NC}"
        else
            echo -e "${RED}Número máximo de intentos alcanzado. Saliendo...${NC}"
            exit 1
        fi
    fi
done
