#!/bin/bash
### Amazon Linux 2 machine
set -x

WP_ROOT="/var/www"
WP_PATH="$${WP_ROOT}/html"
mkdir -p $${WP_PATH}

### Install Apache PHP packages ###
yum update -y
amazon-linux-extras install -y php7.2
yum install -y httpd php-xml
yum install -y amazon-efs-utils nfs-utils cachefilesd

### Apache Config ###
echo -e '<IfModule mod_setenvif.c>\n\tSetEnvIf X-Forwarded-Proto "^https$" HTTPS\n</IfModule>' > /etc/httpd/conf.d/xforwarded.conf
chown -R apache:apache $${WP_PATH}
systemctl start httpd
systemctl enable httpd

### Enable PHP opcache ###
amazon-linux-extras install -y epel
yum-config-manager --enable remi-php72
yum install -y php-opcache
OPCACHE_PATH='/var/cache/opcache'
mkdir $${OPCACHE_PATH}
chown apache:apache $${OPCACHE_PATH}
# Replace OPCACHE_PATH manually in sed command below!
sed -i '/opcache.memory_consumption=/c\opcache.memory_consumption=2048' /etc/php.d/10-opcache.ini
sed -i '/opcache.revalidate_freq=/c\opcache.revalidate_freq=10' /etc/php.d/10-opcache.ini
sed -i '/opcache.file_cache=/c\opcache.file_cache="/var/cache/opcache/"' /etc/php.d/10-opcache.ini
sed -i '/opcache.max_accelerated_files=/c\opcache.max_accelerated_files=12000' /etc/php.d/10-opcache.ini
systemctl restart php-fpm.service
systemctl restart httpd

### if this is the first run of the wordpress app, EFS data must be initiated.
if [[ ${wp_init} = true ]]; then
  WP_TEMP="$${WP_ROOT}/temp"
  EFS_TEMP="$${WP_TEMP}/efs"
  mkdir -p $${EFS_TEMP}
  mount -t efs ${wp_efs_id}:/ $${EFS_TEMP}
  cd $${WP_TEMP}
  mkdir ${wp_name}
  wget http://wordpress.org/latest.zip
  unzip -q latest.zip -d ./
  mv wordpress/* ${wp_name}/
  rm -rf wordpress latest.zip
  chown -R apache:apache ${wp_name}
  cd ${wp_name}
  find . -type d -exec chmod 775 {} \;
  find . -type f -exec chmod 664 {} \;
  cp -p wp-config-sample.php wp-config.php
  sed -i -e "s/database_name_here/"${wp_db_name}"/g" wp-config.php
  sed -i -e "s/username_here/"${wp_db_user}"/g" wp-config.php
  sed -i -e "s/password_here/"${wp_db_password}"/g" wp-config.php
  sed -i -e "s/localhost/"${wp_db_host}"/g" wp-config.php
  cd ..
  mv ${wp_name} $${EFS_TEMP}
  umount -f $${EFS_TEMP}
  sleep 1
  rm -rf $${EFS_TEMP}
#  mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,fsc,async ${wp_efs_id}.efs.${wp_region}.amazonaws.com:/${wp_name} $${WP_PATH}
fi

### Mount the NFS volume on AWS EFS ###
systemctl start cachefilesd
systemctl enable cachefilesd
mount -t efs ${wp_efs_id}:/${wp_name} $${WP_PATH}
echo -e "${wp_efs_id}:/${wp_name}\t$${WP_PATH}\tefs" >> /etc/fstab
systemctl restart cachefilesd
