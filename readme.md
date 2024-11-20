# Gestor de Contraseñas - `bashVault`

Este es un programa OpenSource esccrito en Bash diseñado para gestionar contraseñas de forma segura. Usa técnicas de cifrado avanzado para proteger contraseñas y permite operaciones como almacenamiento, recuperación, eliminación y generación de contraseñas aleatorias.

![Static Badge](https://img.shields.io/badge/version-1.0-red)
[![!#/bin/bash](https://img.shields.io/badge/-%23!%2Fbin%2Fbash-1f425f.svg?logo=image%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw%2FeHBhY2tldCBiZWdpbj0i77u%2FIiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8%2BIDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTExIDc5LjE1ODMyNSwgMjAxNS8wOS8xMC0wMToxMDoyMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTUgKFdpbmRvd3MpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOkE3MDg2QTAyQUZCMzExRTVBMkQxRDMzMkJDMUQ4RDk3IiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOkE3MDg2QTAzQUZCMzExRTVBMkQxRDMzMkJDMUQ4RDk3Ij4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6QTcwODZBMDBBRkIzMTFFNUEyRDFEMzMyQkMxRDhEOTciIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6QTcwODZBMDFBRkIzMTFFNUEyRDFEMzMyQkMxRDhEOTciLz4gPC9yZGY6RGVzY3JpcHRpb24%2BIDwvcmRmOlJERj4gPC94OnhtcG1ldGE%2BIDw%2FeHBhY2tldCBlbmQ9InIiPz6lm45hAAADkklEQVR42qyVa0yTVxzGn7d9Wy03MS2ii8s%2BeokYNQSVhCzOjXZOFNF4jx%2BMRmPUMEUEqVG36jo2thizLSQSMd4N8ZoQ8RKjJtooaCpK6ZoCtRXKpRempbTv5ey83bhkAUphz8fznvP8znn%2B%2F3NeEEJgNBoRRSmz0ub%2FfuxEacBg%2FDmYtiCjgo5NG2mBXq%2BH5I1ogMRk9Zbd%2BQU2e1ML6VPLOyf5tvBQ8yT1lG10imxsABm7SLs898GTpyYynEzP60hO3trHDKvMigUwdeaceacqzp7nOI4n0SSIIjl36ao4Z356OV07fSQAk6xJ3XGg%2BLCr1d1OYlVHp4eUHPnerU79ZA%2F1kuv1JQMAg%2BE4O2P23EumF3VkvHprsZKMzKwbRUXFEyTvSIEmTVbrysp%2BWr8wfQHGK6WChVa3bKUmdWou%2BjpArdGkzZ41c1zG%2Fu5uGH4swzd561F%2BuhIT4%2BLnSuPsv9%2BJKIpjNr9dXYOyk7%2FBZrcjIT4eCnoKgedJP4BEqhG77E3NKP31FO7cfQA5K0dSYuLgz2TwCWJSOBzG6crzKK%2BohNfni%2Bx6OMUMMNe%2Fgf7ocbw0v0acKg6J8Ql0q%2BT%2FAXR5PNi5dz9c71upuQqCKFAD%2BYhrZLEAmpodaHO3Qy6TI3NhBpbrshGtOWKOSMYwYGQM8nJzoFJNxP2HjyIQho4PewK6hBktoDcUwtIln4PjOWzflQ%2Be5yl0yCCYgYikTclGlxadio%2BBQCSiW1UXoVGrKYwH4RgMrjU1HAB4vR6LzWYfFUCKxfS8Ftk5qxHoCUQAUkRJaSEokkV6Y%2F%2BJUOC4hn6A39NVXVBYeNP8piH6HeA4fPbpdBQV5KOx0QaL1YppX3Jgk0TwH2Vg6S3u%2BdB91%2B%2FpuNYPYFl5uP5V7ZqvsrX7jxqMXR6ff3gCQSTzFI0a1TX3wIs8ul%2Bq4HuWAAiM39vhOuR1O1fQ2gT%2F26Z8Z5vrl2OHi9OXZn995nLV9aFfS6UC9JeJPfuK0NBohWpCHMSAAsFe74WWP%2BvT25wtP9Bpob6uGqqyDnOtaeumjRu%2ByFu36VntK%2FPA5umTJeUtPWZSU9BCgud661odVp3DZtkc7AnYR33RRC708PrVi1larW7XwZIjLnd7R6SgSqWSNjU1B3F72pz5TZbXmX5vV81Yb7Lg7XT%2FUXriu8XLVqw6c6XqWnBKiiYU%2BMt3wWF7u7i91XlSEITwSAZ%2FCzAAHsJVbwXYFFEAAAAASUVORK5CYII%3D)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub watchers](https://badgen.net/github/watchers/laasso/bashVault/)](https://GitHub.com/laasso/bashVault/watchers/)


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
git clone https://github.com/laasso/bashVault.git
cd bashVault
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
chmod +x bashVault.sh
```

## **Agregar a `.bashrc`**

Para facilitar el acceso al script, crea un alias en tu archivo `.bashrc`:
```bash
echo 'alias bashVault="/ruta/al/script/bashVault.sh"' >> ~/.bashrc
source ~/.bashrc
```


---

## **Uso**

### **Iniciar el gestor**
Ejecuta el script:  
```bash
./bashVault.sh
```
---

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

## **Consideraciones de seguridad**

- **Protege la clave maestra:** Sin la clave maestra, no podrás recuperar tus contraseñas.  
- **Almacena copias de seguridad cifradas:** Realiza copias de seguridad de la base de datos (`passwords.db`) en un entorno seguro.  
- **Uso exclusivo del usuario:** Asegúrate de que solo tú tengas permisos para ejecutar el script y acceder a la base de datos.

---

## **Licencia**

Este proyecto está licenciado bajo la **Licencia MIT**.  

---

*Hecho con ❤️ por [laasso](https://github.com/laasso) y [ikerm01](https://github.com/ikerm01).*
