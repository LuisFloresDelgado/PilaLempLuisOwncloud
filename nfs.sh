#!/bin/bash

# Actualizar repositorios e instalar NFS y PHP 7.4
apt-get update -y
apt-get install -y nfs-kernel-server php7.4 php7.4-fpm php7.4-mysql php7.4-gd php7.4-xml php7.4-mbstring php7.4-curl php7.4-zip php7.4-intl php7.4-ldap unzip curl

# Crear carpeta compartida para OwnCloud y configurar permisos
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Configurar NFS para compartir la carpeta
echo "/var/www/html 192.168.6.11(rw,sync,no_subtree_check)" >> /etc/exports
echo "/var/www/html 192.168.6.12(rw,sync,no_subtree_check)" >> /etc/exports

# Reiniciar NFS para aplicar cambios
exportfs -a
systemctl restart nfs-kernel-server

# Descargar y configurar OwnCloud
cd /tmp
wget https://download.owncloud.com/server/stable/owncloud-10.9.1.zip
unzip owncloud-10.9.1.zip
mv owncloud /var/www/html/

# Configurar permisos de OwnCloud
chown -R www-data:www-data /var/www/html/owncloud
chmod -R 755 /var/www/html/owncloud

# Crear archivo de configuración inicial para OwnCloud
cat <<EOF > /var/www/html/owncloud/config/autoconfig.php
<?php
\$AUTOCONFIG = array(
  "dbtype" => "mysql",
  "dbname" => "owncloud",
  "dbuser" => "owncloud",
  "dbpassword" => "1234",
  "dbhost" => "192.168.5.4",
  "directory" => "/var/www/html/owncloud/data",
  "adminlogin" => "admin",
  "adminpass" => "1234"
);
EOF

# Configuración de PHP-FPM para escuchar en la IP del servidor NFS
sed -i 's/^listen = .*/listen = 192.168.6.13:8080/' /etc/php/7.4/fpm/pool.d/www.conf

# Reiniciar PHP-FPM
systemctl restart php7.4-fpm

# Quitar ip por defecto para no tener acceso a internet
ip route del default
