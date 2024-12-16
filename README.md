# Owncloud en Docker: Instalación con Diseño de 3 Capas

El objetivo de este proyecto es asegurar una implementación escalable, fácil de mantener y desplegar. **Se basa en una infraestructura de tres capas para proporcionar mayor escalabilidad y seguridad**, separando de manera modular las funcionalidades de cada servicio.

# Índice

1. [¿Cómo arrancar este proyecto con Docker Compose?](#1-cómo-arrancar-este-proyecto-con-docker-compose)
   1. [Configuración inicial](#configuración-inicial)  
   2. [Puesta en marcha](#puesta-en-marcha)
2. [Infraestructura de este proyecto](#2-infraestructura-de-este-proyecto)
   1. [Capa 1: Expuesta a Red “Pública”](#capa-1-expuesta-a-red-pública)  
   2. [Capa 2: BackEnd](#capa-2-backend)  
   3. [Capa 3: Datos](#capa-3-datos)
3. [Explicación detallada de cada contenedor](#3-explicación-detallada-de-cada-contenedor)
   1. [Contenedor de Base de Datos](#contenedor-de-base-de-datos)  
   2. [Contenedor de PHP-FPM](#contenedor-de-php-fpm)  
   3. [Contenedores de NGINX](#contenedores-de-nginx)  
   4. [Contenedor del Balanceador de Cargas](#contenedor-del-balanceador-de-cargas)
4. [Conclusión](#4-conclusión)

# 1. ¿Cómo arrancar este proyecto con Docker Compose?

Para poder **arrancar** este proyecto, necesitaremos tener instaladas dos herramientas imprescindibles:

1.  **Docker:** es necesario para ejecutar los contenedores que forman la infraestructura del proyecto. Permite crear, gestionar y ejecutar contenedores de manera eficiente.
2.  **Docker Compose:** es la herramienta que nos permitirá orquestar y gestionar múltiples contenedores de forma sencilla, usando un solo archivo de configuración (`docker-compose.yml`).

## Configuración inicial:

Para poder lanzar este contenedor, tendremos ajustar las variables de entorno definidas en el archivo `.env`.

Este contiene la siguientes variables:

- **DB_USER**: esta variable especifica el usuario de la base de datos que Owncloud utilizará para almacenar su información.
- **DB_PASS**: esta variable especifica la contraseña del usuario $DB_USER de la base de datos.
- **DB_NAME**: esta especifica el nombre de la base de datos empleada por Owncloud.
- **ADMIN_USER**: esta variable se utiliza para definir el usuario de inicio de sesión de Owncloud.
- **ADMIN_PASS**: esta variable especifica la contraseña de inicio de sesión del usuario $ADMIN_USER.
- **DOMAIN**: esta variable es una de las más importantes ya que definirá el nombre de dominio por el cual nos conectaremos a Owncloud.
- **DB_PASSWD**: esta especifica la contraseña del usuario ROOT de la base de datos.

Todas estas variables tendrán que ser definidas para la correcta ejecución del `docker-compose.yml`.

**Además, es necesario que nuestra máquina host sepa que el nombre de dominio (definido en la variable) apunta a nuestra IP local. Esto se puede hacer de dos maneras:**

- **Usando un servidor DNS**: Configura un registro A o CNAME que apunte a tu IP.
- **Modificando el archivo `hosts` local**:
    - **Linux/Mac**: Edita `/etc/hosts` y agrega:
        
        ```bash
        127.0.0.1   mi-dominio.com
        ```
        
    - **Windows**: Edita `C:\Windows\System32\drivers\etc\hosts` y agrega lo mismo.

Esto permite que el dominio se resuelva localmente a la IP de la máquina.

## Puesta en marcha:

Para esto, tendremos que ejecutar simplemente el siguiente comando dentro de la carpeta donde se encuentre el proyecto descargado:

```bash
docker compose up -d --build
```

Este descargará las imágenes necesarias y arrancará los contenedores.

Una vez arrancado y ver la página de Owncloud, tendremos que esperar unos 10 segundos para que la configuración de post-instalación se aplique de manera automática. Tras esto, ya podremos conectarnos con nuestro dominio por el navegador añadiendo [`https://dominio.com`](https://dominio.com) iniciar sesión con el usuario y contraseña definidos en el `.env`.

# 2. Infraestructura de este proyecto

### **Capa 1: Expuesta a Red “Pública”**

- **Balanceador de carga (Nginx)**: Este es el primer punto de contacto para las solicitudes externas. El balanceador distribuye el tráfico entre los servidores web NGINX.
    
    **Redes**:
    
    - **Red**: `red-capa-1` (Expuesta a la red pública)
    - **Subred**: `192.168.2.0/24`
    - **IP**: `192.168.2.2`

---

### **Capa 2: BackEnd**

En esta capa se encuentran los servidores web que gestionan las solicitudes y el PHP-FPM.

- **NGINX 1**: Servidor web en el primer nodo, encargado de procesar el tráfico HTTP/HTTPS.
    - **Redes**:
        - **Red**: `red-capa-2`
        - **Subred**: `192.168.3.0/24`
        - **IP**: `192.168.3.3`
- **NGINX 2**: Servidor web en el segundo nodo, también se encarga de manejar el tráfico entrante.
    - **Redes**:
        - **Red**: `red-capa-2`
        - **Subred**: `192.168.3.0/24`
        - **IP**: `192.168.3.4`
        - **Nombre de la máquina**: `serverweb2TuNombre`
- **PHP-FPM**: En esta máquina, se ejecuta PHP-FPM, el cual es responsable de procesar las solicitudes dinámicas de PHP. En esta infraestructura he obviado el servidor de NFS ya que utilizamos volúmenes de Docker para la sincronización de los datos.
    - **Redes**:
        - **Red**: `red-capa-2`
        - **Subred**: `192.168.3.0/24`
        - **IP**: `192.168.3.7`
        - **Nombre de la máquina**: `serverNFSTuNombre`

---

### **Capa 3: Datos**

Esta capa se encarga de gestionar la base de datos.

- **MariaDB**: Base de datos utilizada para almacenar toda la información de la aplicación.
    - **Redes**:
        - **Red**: `red-capa-2` (para la comunicación con los servidores web).
        - **Red**: `red-capa-3` (para un mejor aislamiento y para futuras bases de datos).
        - **Subred**: `192.168.4.0/24`
        - **IP**: `192.168.4.2`

# 3. Explicación detallada de cada contenedor

Aquí explico como se configuran de manera automática todos los servicios:

### Contenedor de base de datos

Esta consta de los siguientes parámetros en el docker compose:

- **image:** este indica la imagen hecha que se utilizará para crear el contenedor.
- **env_file**: esta propiedad indica la ruta de donde debe coger las variables que utilizará tanto para su propia configuración como para el script de configuración de la base de datos.
- **volumes**:  en este apartado añadimos el script de configuración de la base de datos a una carpeta que la imagen de MariaDB ejecuta automáticamente.

Este contenedor no utiliza el parámetro `depends_on` , por que es uno de los primeros en iniciarse.

---

### Contenedor PHP-FPM

Este contenedor contiene los siguiente parámetros:

- **bluid**:
    - **context**: indica la ruta donde se debe de encontrar el dockerfile.
    - dockerfile: indica el nombre del archivo que crea la imagen.
- **depends_on**:
    - Este depende de los dos servidor NGINX para encenderse.

El volumen que montamos en este contenedor es el mismo en el que almacenan los datos del sitio **OwnCloud**, ya que para utilizar un módulo de **PHP-FPM** de manera externa a los servidores web, se necesita que las carpetas de datos sean accesibles por todos los servicios que gestionan el sitio web.

Además, este contiene el script de post-instalación que es el encargado de automatizar los pasos necesarios que de manera normal tendríamos que introducir manualmente. 

---

### Contenedores NGINX

Los contenedores **NGINX** se encargan de gestionar las solicitudes HTTP entrantes provenientes del balanceador de carga.

Estos contenedores están basados en una imagen de **Ubuntu 20.04**, sobre la cual se instala el servidor **NGINX**. Para la gestión de procesos, se utiliza la herramienta **supervisorctl**, que se encarga de iniciar **NGINX** automáticamente al arrancar el contenedor.

En caso de realizar alguna personalización de la infraestructura, una de las configuraciones clave a modificar es la línea `fastcgi_pass 192.168.3.7:9000;` en el archivo de configuración de **NGINX**. Esta directiva indica la ubicación del servidor **PHP-FPM**, que se encarga de procesar las solicitudes PHP.

---

### Contenedor del Balanceador de cargas

Este es el encargado de redirigir las peticiones de cada cliente a un servidor NGINX distinto. 

Esta basado en una imagen base de Ubuntu 20.04, la cual realiza los siguientes pasos:

- **Instalación de NGINX**: Actualiza el sistema e instala **NGINX** junto con herramientas necesarias como **sed** y **openssl**.
- **Configuración del Certificado SSL**: Crea un certificado autofirmado para habilitar HTTPS en el servidor usando **OpenSSL**, utilizando el dominio proporcionado a través de un argumento (`DOMAIN`).
- **Copia de la configuración personalizada**: Copia un archivo de configuración de **NGINX** (`nginx.conf`) al contenedor y reemplaza un marcador de dominio (`domain1`) con el valor del dominio especificado en el archivo `.env`.
- **Exposición de puertos**: Expone los puertos 80 y 443 para permitir las conexiones HTTP y HTTPS.
- **Inicio de NGINX**: Configura **NGINX** para que se ejecute en primer plano al iniciar el contenedor.

# 4. Conclusión

La implementación de **OwnCloud en Docker con un diseño de tres capas** proporciona una solución escalable, modular y fácil de mantener. Este enfoque mejora la seguridad al aislar los diferentes servicios (base de datos, servidor web y balanceador de carga), y facilita el despliegue y la configuración con **Docker Compose**.  Esta solución, orquestada con **Docker Compose**, permite un despliegue simplificado y una fácil personalización para adaptarse a diferentes necesidades.
