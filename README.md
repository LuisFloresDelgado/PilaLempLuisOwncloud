# PilaLempLuisOwncloud

## Descripción de las máquinas

### `Luis-db` (Servidor de Base de Datos)

Este servidor ejecuta **MariaDB** y proporciona la base de datos para los servidores web. Se configura con una IP estática dentro de la red privada `prnetwork_db`.

### `Luis-NFS` (Servidor NFS)

Este servidor se utiliza para compartir recursos a través de NFS (Network File System). Está conectado tanto a la red privada `prnetwork` como a la red privada `prnetwork_db`.

### `Luis-web1` y `Luis-web2` (Servidores Web)

Estos servidores ejecutan aplicaciones web y se conectan al servidor de base de datos **MariaDB**. También están conectados a la red privada `prnetwork`.

### `Luis-balanceador` (Balanceador de Carga)

Este servidor se encarga de distribuir el tráfico entre los servidores web. Está conectado a una red pública para ser accesible desde el exterior y a la red privada `prnetwork` para comunicarse con los servidores web.

## Descripción de los scripts de aprovisionamiento

### `bd.sh` (Servidor de Base de Datos)

Este script instala y configura **MariaDB** en el servidor de base de datos. Se asegura de que MariaDB esté configurado para aceptar conexiones desde otras máquinas y habilita la base de datos para el proyecto.

Contenido del script `bd.sh`:

```bash
#!/bin/bash

# Instalar MariaDB
apt-get update
apt-get install -y mariadb-server

# Configurar MariaDB para aceptar conexiones desde cualquier IP
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Iniciar el servicio de MariaDB
systemctl start mariadb
systemctl enable mariadb

# Configurar el usuario root para acceder desde cualquier IP
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '1234'; FLUSH PRIVILEGES;"

nfs.sh (Servidor NFS)
Este script configura NFS para compartir recursos entre las máquinas virtuales. Se configura para que los servidores web puedan acceder a un directorio compartido desde el servidor NFS.

Contenido del script nfs.sh:
#!/bin/bash

# Instalar NFS
apt-get update
apt-get install -y nfs-kernel-server

# Crear un directorio para compartir
mkdir -p /mnt/shared

# Configurar el archivo exports para permitir acceso desde las máquinas web
echo "/mnt/shared 192.168.6.11(rw,sync,no_subtree_check)" >> /etc/exports
echo "/mnt/shared 192.168.6.12(rw,sync,no_subtree_check)" >> /etc/exports

# Exportar los directorios
exportfs -a

# Iniciar el servicio NFS
systemctl start nfs-kernel-server
systemctl enable nfs-kernel-server

backend.sh (Servidores Web)
Este script configura los servidores web para ejecutar aplicaciones y conectarse al servidor de base de datos MariaDB. También monta el directorio compartido desde el servidor NFS.
Contenido del script backend.sh:
#!/bin/bash

# Actualizar y instalar NFS y Apache
apt-get update
apt-get install -y nfs-common apache2 php php-mysqli

# Montar el directorio compartido desde el servidor NFS
mount 192.168.6.13:/mnt/shared /var/www/html

# Iniciar el servicio de Apache
systemctl start apache2
systemctl enable apache2

balanceador.sh (Balanceador de Carga)
Este script instala Nginx en el balanceador de carga y configura la distribución de tráfico entre los servidores web Luis-web1 y Luis-web2.

Contenido del script balanceador.sh:
#!/bin/bash

# Instalar Nginx
apt-get update
apt-get install -y nginx

# Configurar Nginx para balanceo de carga
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;

    location / {
        proxy_pass http://192.168.6.11;
        proxy_pass http://192.168.6.12;
    }
}
EOF

# Iniciar Nginx
systemctl start nginx
systemctl enable nginx


