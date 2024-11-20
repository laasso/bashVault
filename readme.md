# Gestor de Contraseñas - `bashVault`

Este es un script en Bash diseñado para gestionar contraseñas de forma segura. Usa técnicas de cifrado avanzado para proteger contraseñas y permite operaciones como almacenamiento, recuperación, eliminación y generación de contraseñas aleatorias.

---

## **Características**

- **Cifrado seguro:** Utiliza AES-256-CBC con PBKDF2 para proteger las contraseñas.  
- **Base de datos SQLite:** Almacena las contraseñas cifradas de forma estructurada.  
- **Gestión completa:** Funciones para agregar, recuperar, listar y eliminar contraseñas.  
- **Generador de contraseñas:** Crea contraseñas aleatorias seguras.  
- **Integración con el portapapeles:** Copia las contraseñas directamente al portapapeles.  
- **Clave maestra:** Protege todo el acceso al gestor mediante una clave única definida por el usuario.

---

## **Requisitos**

El script requiere los siguientes programas instalados en tu sistema:

- **Bash:** Compatible con Linux o macOS.
- **SQLite3:** Para gestionar la base de datos de contraseñas.
- **OpenSSL:** Para cifrar y descifrar datos.
- **xclip:** Para copiar las contraseñas al portapapeles (solo en Linux).

---

## **Instalación**

### **1. Clonar el repositorio**
Descarga el script desde GitHub:  
```bash
git clone https://github.com/laasso/gestorPasswords.git
cd gestorPasswords
```

### **2. Instalar dependencias**
En sistemas basados en Debian/Ubuntu:  
```bash
sudo apt update
sudo apt install sqlite3 openssl xclip
```

### **3. Dar permisos al script**
Haz que el script sea ejecutable:  
```bash
chmod +x gestorPasswords.sh
```

---

## **Uso**

### **Iniciar el gestor**
Ejecuta el script:  
```bash
./gestorPasswords.sh
```

Al iniciarse por primera vez, se te pedirá que configures una **clave maestra**. Esta clave se usará para cifrar y descifrar las contraseñas almacenadas. **Recuerda esta clave, ya que no se puede recuperar.**

### **Menú principal**
El programa mostrará un menú interactivo con las siguientes opciones:  
1. **Añadir nueva contraseña:** Agrega una contraseña cifrada a la base de datos.  
2. **Consultar una contraseña:** Recupera una contraseña utilizando su ID.  
3. **Listar contraseñas:** Muestra un resumen enmascarado de todas las contraseñas.  
4. **Eliminar una contraseña:** Borra una contraseña de la base de datos.  
5. **Salir:** Cierra el programa.

### **Ejemplo de flujo**

#### **Añadir una contraseña**
1. Selecciona la opción **1. Añadir nueva contraseña**.
2. Ingresa los detalles requeridos:
   - Usuario
   - Sitio web
   - Nombre de la contraseña
3. Elige entre generar una contraseña aleatoria o ingresar una manual.

#### **Consultar una contraseña**
1. Selecciona la opción **2. Consultar una contraseña**.
2. Ingresa el ID de la contraseña que deseas recuperar.
3. Elige si deseas copiarla al portapapeles o mostrarla temporalmente en pantalla.

#### **Listar contraseñas**
1. Selecciona la opción **3. Listar contraseñas**.
2. Se mostrará una lista de contraseñas enmascaradas con sus respectivos IDs.

#### **Eliminar una contraseña**
1. Selecciona la opción **4. Eliminar una contraseña**.
2. Ingresa el ID de la contraseña que deseas eliminar.

---

## **Cifrado y seguridad**

El cifrado se realiza utilizando **AES-256-CBC** junto con **PBKDF2**, un estándar que protege contra ataques de fuerza bruta.  

### **Ejemplo de cifrado**  
El texto plano de una contraseña se cifra con el siguiente comando:
```bash
openssl enc -pbkdf2 -k "$master_key" -aes256 -e -in plain.txt | base64 > cipher.txt
rm -f plain.txt
```

- **AES-256-CBC:** Garantiza un cifrado robusto.
- **PBKDF2:** Deriva claves seguras de la clave maestra.
- **Base64:** Convierte los datos cifrados a un formato texto legible y almacenable.

### **Proceso de descifrado**
Para recuperar una contraseña, el gestor ejecuta:  
```bash
base64 -d cipher.txt | openssl enc -pbkdf2 -k "$master_key" -aes256 -d
```

---

## **Funciones del script**

### **`initialize_master_key`**  
Configura y valida la clave maestra del usuario.

### **`encrypt_password`**  
Cifra una contraseña utilizando AES-256-CBC y la almacena en la base de datos.

### **`decrypt_password`**  
Descifra una contraseña cifrada previamente.

### **`generate_key_hash`**  
Genera un hash SHA-256 de la clave maestra para autenticación interna.

### **`generate_random_password`**  
Crea contraseñas aleatorias seguras de al menos 15 caracteres.

### **`add_password`**  
Permite al usuario agregar una nueva contraseña al gestor.

### **`get_password`**  
Recupera y muestra una contraseña cifrada de forma segura.

### **`list_passwords`**  
Muestra un listado con los IDs y nombres de todas las contraseñas.

### **`delete_password`**  
Elimina una entrada de la base de datos.

---

## **Agregar a `.bashrc`**

Para facilitar el acceso al script, crea un alias en tu archivo `.bashrc`:
```bash
echo 'alias gestorPasswords="/ruta/al/script/gestorPasswords.sh"' >> ~/.bashrc
source ~/.bashrc
```

---

## **Consideraciones de seguridad**

- **Protege la clave maestra:** Sin la clave maestra, no podrás recuperar tus contraseñas.  
- **Almacena copias de seguridad cifradas:** Realiza copias de seguridad de la base de datos (`passwords.db`) en un entorno seguro.  
- **Uso exclusivo del usuario:** Asegúrate de que solo tú tengas permisos para ejecutar el script y acceder a la base de datos.

---

## **Licencia**

Este proyecto está licenciado bajo la **Licencia MIT**.  

**Copyright (c) 2024 laasso & ikerm01**

---

*Hecho con ❤️ por [laasso](https://github.com/laasso) y [ikerm01](https://github.com/ikerm01).*
