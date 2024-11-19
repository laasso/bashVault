# Gestor de Contraseñas bashVault

Este es un script en Bash para gestionar contraseñas de manera segura. Permite cifrar, almacenar, recuperar, y eliminar contraseñas usando AES-256-CBC y PBKDF2. La base de datos utilizada es SQLite.

## Características

- Cifrado de contraseñas con AES-256-CBC y PBKDF2.
- Almacenamiento seguro de contraseñas en una base de datos SQLite.
- Funciones para agregar, recuperar, listar y eliminar contraseñas.
- Generación de contraseñas aleatorias.
- Opciones para copiar contraseñas al portapapeles o visualizarlas temporalmente.
- Gestión mediante una clave maestra.

## Requisitos

- Bash (Linux o macOS).
- SQLite3.
- OpenSSL.
- xclip (para copiar contraseñas al portapapeles en Linux).

## Instalación

1. Clona este repositorio en tu máquina local:

   ```bash
   git clone https://github.com/laasso/gestorPasswords.git
   cd gestorPasswords
   ```

2. Asegúrate de que tienes todos los requisitos instalados:

   ```bash
   sudo apt update
   sudo apt install sqlite3 openssl xclip
   ```

3. Dale permisos de ejecución al script:

   ```bash
   chmod +x gestorPasswords.sh
   ```

## Despliegue y uso

### Iniciar el Gestor de Contraseñas

Para iniciar el gestor de contraseñas, simplemente ejecuta el script:

```bash
./gestorPasswords.sh
```

Cuando se ejecute por primera vez, se te pedirá que configures una clave maestra para el gestor. Esta clave se usará para cifrar y descifrar las contraseñas almacenadas.

### Añadir una nueva contraseña

Selecciona la opción **1. Añadir nueva contraseña** en el menú principal y proporciona los siguientes detalles:

- **Usuario**
- **Sitio web**
- **Nombre de la contraseña**

También podrás generar una contraseña aleatoria o introducir una personalizada.

### Consultar una contraseña

Selecciona la opción **2. Consultar una contraseña**, luego elige la contraseña por su **ID**. Después, podrás ver o copiar la contraseña.

### Listar contraseñas

Selecciona la opción **3. Listar todas las contraseñas** para ver todas las contraseñas almacenadas de forma enmascarada.

### Eliminar una contraseña

Selecciona la opción **4. Eliminar una contraseña** e ingresa el **ID** de la contraseña que deseas eliminar.

### Salir

Selecciona la opción **5. Salir** para cerrar el gestor de contraseñas.

## Agregar al archivo `.bashrc`

Para que el script esté disponible globalmente, puedes agregar el siguiente alias a tu archivo `.bashrc`:

```bash
echo 'alias gestorPasswords="/ruta/al/script/gestorPasswords.sh"' >> ~/.bashrc
source ~/.bashrc
```

Ahora podrás ejecutar el gestor de contraseñas con el comando `gestorPasswords`.

## Funciones del script

### `initialize_master_key`
Inicializa la clave maestra para cifrar y descifrar contraseñas.

### `encrypt_password`
Cifra una contraseña utilizando AES-256-CBC con PBKDF2.

### `decrypt_password`
Descifra una contraseña cifrada.

### `generate_key_hash`
Genera un hash SHA-256 de una clave maestra.

### `generate_random_password`
Genera una contraseña aleatoria de al menos 15 caracteres.

### `add_password`
Añade una nueva contraseña al gestor, cifrándola antes de almacenarla.

### `get_password`
Recupera una contraseña almacenada y permite ver o copiarla al portapapeles.

### `list_passwords`
Muestra todas las contraseñas almacenadas de manera enmascarada.

### `delete_password`
Elimina una contraseña de la base de datos.

### `end_message`
Muestra un mensaje de despedida.

## Licencia

Este proyecto está licenciado bajo la **Licencia MIT**.

Copyright (c) 2024 laasso & ikerm01

---

*Hecho por [laasso](https://github.com/laasso) y [ikerm01](https://github.com/ikerm01).*
