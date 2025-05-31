# 🐳 Proyecto Docker - Nagios Core 
Este repositorio contiene los archivos necesarios para construir y desplegar una imagen Docker personalizada de Nagios Core desde un computador personal (MacBook Pro M1, en este caso), utilizando Docker instalado localmente. 
La guía detalla todos los pasos realizados, desde la preparación del entorno local hasta la subida de la imagen a Docker Hub.

---

## 🧱 Estructura del Proyecto

Este repositorio contiene:

* `Dockerfile` → Imagen Docker con Nagios Core
* `docker-entrypoint.sh` → Script de arranque
* `.env` (local, no subido) → Variables de entorno para credenciales

---

## 💻 Requisitos del Entorno

* Computador MacOS (MacBook Pro)
* Docker Desktop instalado desde [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
* Terminal nativa de macOS 

---

## 🔧 Paso 1: Preparación del Proyecto Local

1. Crear carpeta del proyecto:

```bash
mkdir ~/Downloads/nagios-moreno
cd ~/Downloads/nagios-moreno
```

2. Crear el archivo `.env` con las credenciales:

```bash
echo -e "NAGIOS_USER=nagiosadmin\nNAGIOS_PASS=admin" > .env
```

3. Crear el archivo `docker-entrypoint.sh` con:

```bash
#!/bin/bash

service apache2 start
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg
tail -F /var/log/apache2/access.log /var/log/apache2/error.log
```

4. Crear el `Dockerfile`:

```Dockerfile
FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php \
    libgd-dev libmcrypt-dev libssl-dev snmp build-essential libperl-dev && \
    apt-get clean

RUN useradd nagios && groupadd nagcmd && \
    usermod -a -G nagcmd nagios && usermod -a -G nagcmd www-data

WORKDIR /tmp
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz && \
    tar xzf nagios-4.4.6.tar.gz && \
    cd nagios-4.4.6 && \
    ./configure --with-command-group=nagcmd && \
    make all && \
    make install && \
    make install-init && \
    make install-commandmode && \
    make install-config && \
    make install-webconf && \
    htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin admin

RUN a2enmod cgi

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
```

---

## 🛠️ Paso 2: Construcción y ejecución de la imagen Docker

1. Construir la imagen:

```bash
docker build -t nagios-core-moreno .
```

2. Ejecutar el contenedor:

```bash
docker run -d --env-file .env -p 8080:80 --name nagios-moreno nagios-core-moreno
```

3. Verificar en navegador:

```
http://localhost:8080/nagios
```

Usuario: `nagiosadmin`
Contraseña: `admin`

---

## 📦 Paso 3: Subida de imagen a Docker Hub

1. Iniciar sesión en Docker Hub:

```bash
docker login
```

2. Etiquetar la imagen:

```bash
docker tag nagios-core-moreno natalia610/nagios-core-moreno
```

3. Subir la imagen:

```bash
docker push natalia610/nagios-core-moreno
```

La imagen estará disponible en: [https://hub.docker.com/r/natalia610/nagios-core-moreno](https://hub.docker.com/r/natalia610/nagios-core-moreno)

---

## 🧪 Verificación

* Se puede verificar el estado del contenedor con:

```bash
docker ps
```

* Logs del contenedor:

```bash
docker logs -f nagios-moreno
```

---

## 🎓 Conclusión

Este proyecto fue desarrollado 100% desde mi MacBook personal utilizando Docker Desktop y terminal de macOS, cumpliendo con todos los requisitos de la evaluación. Se construyó, probó y subió exitosamente una imagen Docker personalizada de Nagios Core, lista para ser desplegada en AWS.


---

¡Gracias por visitar este repositorio!

