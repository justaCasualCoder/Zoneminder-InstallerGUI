#!/bin/bash
read -p "This Script MUST be run as root!"
read -p "press enter to continue"
if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root"
    exit 1
fi
echo -n "What is your current passsword? : "
# Assign input value into a variable
read password
sudo ufw allow 80
sudo ufw allow 443
apt update -y
# Update Respitories
apt upgrade -y
# Update The System
apt install apache2 -y
ufw allow in "Apache"
apt install mysql-server -y
sudo echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by '$password';" >> /tmp/temp.txt
sudo mysql -u root -p  <  /tmp/temp.txt
sudo rm /tmp/temp.txt
sudo mysql_secure_installation
sed -i 25 a "define( 'ZM_TIMEZONE', 'America/Chicago' );" /usr/share/zoneminder/www/includes/config.php
sudo apt install php libapache2-mod-php php-mysql -y
sudo add-apt-repository ppa:iconnor/zoneminder-1.36 -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
rm /etc/mysql/my.cnf 
cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/my.cnf
mysql -uroot -p < /usr/share/zoneminder/db/zm_create.sql
mysql -uroot -p -e "grant lock tables,alter,drop,select,insert,update,delete,create,index,alter routine,create routine, trigger,execute on zm.* to 'zmuser'@localhost identified by 'zmpass';"
sudo systemctl restart mysql
apt-get install zoneminder -y
chmod 740 /etc/zm/zm.conf
chown root:www-data /etc/zm/zm.conf
chown -R www-data:www-data /usr/share/zoneminder/
a2enmod cgi
a2enmod rewrite
a2enconf zoneminder
a2enmod expires
a2enmod headers
sudo systemctl enable zoneminder
sudo systemctl start zoneminder
sudo zmupdate.pl -f
sudo systemctl reload apache2
echo " 

    Open up a browser and go to http://hostname_or_ip/zm - should bring up ZoneMinder Console

    (Optional API Check)Open up a tab in the same browser and go to http://hostname_or_ip/zm/api/host/getVersion.json

        If it is working correctly you should get version information similar to the example below:

        {
            "version": "1.29.0",
            "apiversion": "1.29.0.1"
        }

"
echo Congratulations! Your installation is complete! 
