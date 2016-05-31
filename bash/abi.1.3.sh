#!/usr/bin/env bash

# OS VERSION: CentOS 6.x + Minimal
# ARCH: 32bit + 64bit

ARD_BASH_INSTALLER=1.0

#blok fungsi
#==============================================================

#lompat ke label tertentu
function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

ard_version='1.0 (beta)'
red='tput setaf 1'
green='tput setaf 2'
orange='tput setaf 3'
reset='tput sgr0'
_now=$(date '+%Y%m%d-%H%M%S%N')
_serial=$(date '+%Y%m%d0%u')

cd /root

#jumpto 13
#jumpto CONFIG
#blok cek kompetibel
#==============================================================

#cek akses user
echo "Cek User akses ..."
if [ $UID -ne 0 ]; then
    echo "Installasi dibatalkan, silahkan login sebagai 'root' terlebih dahulu."
    exit 1;
else
    echo "Akses root OK."
fi

#cek apache/mysql/bind/postfix/dovecot
if rpm -q php httpd mysql bind postfix dovecot; 
then
    echo "Sepertinya Anda telah menginstall apache/mysql/bind/postfix/dovecot pada OS Anda; "
    echo "Installer ini hanya berjalan pada OS yang masih kosong/bersih "
    echo ""
    echo "Silahkan install ulaang OS Anda sebelum menjalankan ARD INSTALLER."
    exit
exit 
fi

# check OS CentOs 6.4
BITS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
if [ -f /etc/centos-release ]; then
  OS="CentOs"
  VER=$(cat /etc/centos-release | sed 's/^.*release //;s/ (Fin.*$//')
else
  OS=$(uname -s)
  VER=$(uname -r)
fi
echo "OS Anda : $OS  $VER  $BITS"
#warning the last version of centos and 6.x
if [ "$OS" = "CentOs" ] && [ "$VER" = "6.0" ] || [ "$VER" = "6.1" ] || [ "$VER" = "6.2" ] || [ "$VER" = "6.3" ] || [ "$VER" = "6.4" ] || [ "$VER" = "6.5" ] || [ "$VER" = "6.6" ] || [ "$VER" = "6.7" ] || [ "$VER" = "6.8" ]  ; then
  echo "Ok."
else
  echo "Maaf, ARD INSTALLER hanya mendukung CentOS 6.x."
  exit 1;
fi

# non aktifakan SELinux.
echo "SELINUX=disabled" > /etc/selinux/config
#sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

service sendmail stop
yum -y remove bind-chroot

# non aktifakan IPTables.
service iptables save
service iptables stop
chkconfig sendmail off
chkconfig iptables off

# Cari info updates dll.
rpm --import https://fedoraproject.org/static/0608B895.txt

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
yum repolist

# bug repo untukk cetos 6.3 ke 6.5 
yum -y remove qpid-cpp-client

# Update OS 
yum -y update
yum -y upgrade

yum -y remove *httpd*
yum -y remove *php*
yum -y remove *mysql*
yum -y remove bind*

# Install utility yang dibutuhkan.
yum -y install sudo wget vim make zip unzip git chkconfig nano curl perl-libwww-perl

#dapatkan ip public
publicip=$(curl ipecho.net/plain)

#buat file log proses.
logfile=abi.$_now.log
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>$logfile 2>&1


UTAMA:
#blok konfirmasi
#==============================================================
# Tampilkan splash/user warning info..
clear
$reset
$orange
echo -e "##############################################################"
echo -e "#            ARD BASH INSTALLER Ver. $ard_version            #"
echo -e "##############################################################"
echo -e "#                                                            #"
echo -e "# Berikut paket yang akan diInstall :                        #"
echo -e "# 1. Apache > 2                  8. roundcube                #"
echo -e "# 2. MySQL 5.6                   9. Bind9                    #"
echo -e "# 3. PHP 5.4                     10. proftpd                 #"
echo -e "# 4. phpMyAdmin                  11. pearl                   #"
echo -e "# 6. postfix                     12. python                  #"
echo -e "# 7. dovecot                     13. Utility                 #"
echo -e "#                                                            #"
echo -e "# *) gunakan centOS 6.x minimal                              #"
echo -e "##############################################################"
echo -e "#                                 (C)2016 Script By Farindra #"
echo -e "##############################################################"
$reset
while true; do
read -e -p "Apakah Anda setuju untuk melanjutkan (y/t)? " yt
    case $yt in
      [Yy]* ) break;;
    [Tt]* ) exit;
  esac
jumpto UTAMA
done

#blok Installasi
#==============================================================
CONFIG:
clear
$reset
$orange
echo -e "--------------------------------------------------------------"
echo -e "| Silahkan masukkan data awal untuk installasi              |"
echo -e "--------------------------------------------------------------"
$reset
#baca settingan awal
nmhost=$(hostname)
#publicip=$(dig +short myip.opendns.com @resolver1.opendns.com)
#publicip=$(curl ipecho.net/plain)
read -e -p "| IP public (external) server : " -i $publicip publicip
read -e -p "| Nama Hostname               : " -i $nmhost nmhost
read -e -p "| Nama ns1 Hostname           : " -i "ns1.contohnya.net" nshosta
read -e -p "| Nama ns2 Hostname           : " -i "ns2.contohnya.net" nshostb
read -e -p "| Password universal          : " -i "password" passu
read -e -p "| Email Anda                  : " -i "contohnya@gmail.com" emailnya
echo -e "------------------------- php.ini ----------------------------"
read -e -p "| Mode rewrite aktif (y/t)    : " -i "y" apamode
echo -e "-------------------------- MySQL -----------------------------"
read -e -p "| Akses dari public (y/t)     : " -i "y" sqlakses
echo -e "----------------------- phpMyAdmin ---------------------------"
read -e -p "| Akses dari public (y/t)     : " -i "y" phpmaakses
echo -e "--------s----------------- Bind9 -----------------------------"
read -e -p "| Nama Domain (jika ada)      : " -i "contohnya.org" nmdomain
echo -e "--------s----------------- postfix  --------------------------"
read -e -p "| Nama User Email             : " -i "admin" nmemail
echo -e "--------------------------------------------------------------"
CONFIGNYA:
clear
$orange
echo -e "--------------------------------------------------------------"
echo -e "| Berikut ini adalah settingan yang telah Anda buat         |"
echo -e "--------------------------------------------------------------"
$green
echo -e "| IP public (external) server : " $publicip
echo -e "| Nama Hostname               : " $nmhost
echo -e "| Password universal          : " $passu
echo -e "------------------------- php.ini ----------------------------"
echo -e "| Mode rewrite aktif (y/t)    : " $apamode
echo -e "----------------------- MySQL phpMyadmin ---------------------"
echo -e "| Remote akses (y/t)          : " $sqlakses
echo -e "--------s----------------- Bind9 -----------------------------"
echo -e "| Nama Domain (jika ada)      : " $nmdomain
echo -e "| Nama ns1    (jika ada)      : " $nshosta
echo -e "| Nama ns2    (jika ada)      : " $nshostb
echo -e "| email    (jika ada)         : " $nmemail
$orange
echo -e "--------------------------------------------------------------"
echo -e "| 'y' = ya    'x' = keluar    'u' = ulang     'm'= menu utama "
echo -e "--------------------------------------------------------------"
$reset
while true; do
  read -e -p "Apakah data telah sesuai keinginan Anda (y/u/m/x) : " yt
  case $yt in
    [Yy]* ) break;;
    [Uu]* ) jumpto CONFIG;;
    [Mm]* ) jumpto UTAMA;;
    [Xx]* ) exit;
  esac
  jumpto CONFIGNYA
done

#seting akses remote mysql
if [ "$sqlakses" = "y" ] || [ "$sqlakses" = "Y" ]; then
  sqlaksesnya=n
else
  sqlaksesnya=y
fi
#  read -e -p "ZPanel is now ready to install, do you wish to continue (y/n)" yn
#  case $yn in
#    [Yy]* ) break;;
#    [Nn]* ) exit;
#  esac


#set timezone ke Asia/Jakarta
echo .
echo .
echo "Set timezone --> Asia/Jakarta (Anda bisa merubah ini nanti)"
mv /etc/localtime /etc/localtime.bak -f
ln -s /usr/share/zoneinfo/Asia/Jakarta /etc/localtime &>- 
date
echo -e "done."
echo .
echo .



# mulai merekam log.
echo -e ""
echo -e "# Membuat file log..."
uname -a
echo -e ""
rpm -qa



# Install software
# yum -y install ld-linux.so.2 libbz2.so.1 libdb-4.7.so libgd.so.2 httpd php php-suhosin php-devel php-gd php-mbstring php-mcrypt php-intl php-imap php-mysql php-xml php-xmlrpc curl curl-devel perl-libwww-perl libxml2 libxml2-devel 
# mysql-server zip webalizer gcc gcc-c++ httpd-devel at make mysql-devel bzip2-devel postfix postfix-perl-scripts bash-completion dovecot dovecot-mysql dovecot-pigeonhole mysql-server proftpd proftpd-mysql bind bind-utils bind-libs


echo -e "------------------------ Apache ----------------------------"
cd /root
yum -y update
yum -y install httpd 
#service httpd start
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/index.html
\cp index.html /var/www/html/index.html -rf
#cat > /var/www/html/index.html <<EOF
#<html> 
#  <head> 
#    <titele>Farindra</title> 
#  </head> 
#  <body><p>ARD BASH INSTALLER Ver. $ard_version</p><p>(C)2016 Farindra</p></body> 
#</html>
#EOF

echo -e "------------------------- PHP -----------------------------"
cd /root
yum -y update
yum -y install php56w php56w-opcache 
#service httpd restart

echo -e "------------------------ MySQL ----------------------------"
cd /root
yum -y update
wget -N http://repo.mysql.com/mysql-community-release-el6-4.noarch.rpm
rpm -ivh mysql-community-release-el6-4.noarch.rpm
#yum repolist enabled | grep "mysql.*-community.*"
#yum repolist all | grep mysql
yum -y install mysql-server
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/my.cnf
\cp /etc/my.cnf{,.$_now.bak} -rf
\cp my.cnf /etc/my.cnf -rf
#echo -e "Setting my.cnf:"
#echo -e "Remote Akses user root = " $sqlakses
#if [ "$sqlakses" = "y" ] || [ "$sqlakses" = "Y" ]  ; then
# sed -i "s/\[mysqld\]/\[mysqld\]\nuser            = mysql\npid-file        = \/var\/run\/mysqld\/mysqld.pid\nport            = 3306\nbasedir         = \/usr\ntmpdir          = \/tmp\nlanguage        = \/usr\/share\/mysql\/English\nbind-address    = $publicip/g" /etc/my.cnf
#fi
#echo -e "Setting OK"

service mysqld restart

mysql_secure_installation <<EOF

y
$passu
$passu
y
$sqlaksesnya
y
y
EOF

mysql_secure_installation <<EOF
$passu
n
y
$sqlaksesnya
y
y
EOF

mysql -u root -p"$passu" -e  "USE mysql;ALTER TABLE user ADD Create_tablespace_priv ENUM('N','Y') NOT NULL DEFAULT 'N' AFTER Trigger_priv;"
mysql -u root -p"$passu" -e  "USE mysql;ALTER TABLE user ADD plugin CHAR(64) NULL AFTER max_user_connections;"
mysql -u root -p"$passu" -e  "USE mysql;ALTER TABLE user ADD authentication_string TEXT NULL DEFAULT NULL AFTER plugin;"
mysql -u root -p"$passu" -e  "USE mysql;ALTER TABLE user ADD password_expired ENUM('N','Y') NOT NULL DEFAULT 'N' AFTER authentication_string;"

#service mysqld restart

echo -e "----------------------- phpMyAdmin ------------------------"
cd /root
yum -y update
yum -y install phpmyadmin
echo -e "Setting phpMyAdmin.conf:"
echo -e "Akses dari semua IP = " $phpmaakses
if [ "$phpmaakses" = "y" ] || [ "$phpmaakses" = "Y" ]  ; then
  sed -i '/<Directory \/usr\/share\/phpMyAdmin\/>/,/<\/Directory>/s/Require ip 127.0.0.1/# Require ip 127.0.0.1/' /etc/httpd/conf.d/phpMyAdmin.conf
  sed -i '/<Directory \/usr\/share\/phpMyAdmin\/>/,/<\/Directory>/s/Require ip ::1/# Require ip ::1\n       Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
  sed -i '/<Directory \/usr\/share\/phpMyAdmin\/>/,/<\/Directory>/s/Deny from All/# Deny from All/' /etc/httpd/conf.d/phpMyAdmin.conf
fi
echo -e "Setting OK"
#service httpd restart

echo -e "------------------------- BIND ----------------------------"
cd /root
yum -y update
yum -y install bind bind-utils bind-libs

echo echo -e "Setting config BIND :"

#named.conf
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/named.conf.sample
sed -i "s/%%host%%/$nmhost/g" named.conf.sample
sed -i "s/%%hostns1%%/$nshosta/g" named.conf.sample
sed -i "s/%%hostns2%%/$nshostb/g" named.conf.sample
sed -i "s/%%domain%%/$nmdomain/g" named.conf.sample
\cp /etc/named.conf /etc/named.conf.$_now.bak -rf
\cp named.conf.sample /etc/named.conf -rf
echo echo -e "named.conf ........................... Done"
#host.zone
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/host.zone.sample
sed -i "s/%%host%%/$nmhost/g" host.zone.sample
sed -i "s/%%hostns1%%/$nshosta/g" host.zone.sample
sed -i "s/%%hostns2%%/$nshostb/g" host.zone.sample
sed -i "s/%%domain%%/$nmdomain/g" host.zone.sample
sed -i "s/%%email%%/${emailnya//@/.}/g" host.zone.sample
sed -i "s/%%serial%%/$_serial/g" host.zone.sample
sed -i "s/%%ip%%/$publicip/g" host.zone.sample
#\cp /var/named/$nmhost.zone /var/named/$nmhost.zone.$_now.bak -rf
\cp host.zone.sample /var/named/$nmhost.zone -rf
echo echo -e "$nmhost.zone ........................... Done"
#ns1.host.zone
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/ns1.host.zone.sample
sed -i "s/%%host%%/$nmhost/g" ns1.host.zone.sample
sed -i "s/%%hostns1%%/$nshosta/g" ns1.host.zone.sample
sed -i "s/%%hostns2%%/$nshostb/g" ns1.host.zone.sample
sed -i "s/%%domain%%/$nmdomain/g" ns1.host.zone.sample
sed -i "s/%%email%%/${emailnya//@/.}/g" ns1.host.zone.sample
sed -i "s/%%serial%%/$_serial/g" ns1.host.zone.sample
sed -i "s/%%ip%%/192.35.51.30/g" ns1.host.zone.sample
#\cp /var/named/$nshosta.zone /var/named/$nshosta.zone.$_now.bak -rf
\cp ns1.host.zone.sample /var/named/$nshosta.zone -rf
echo echo -e "$nshosta.zone ........................... Done"
#ns2.host.zone
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/ns2.host.zone.sample
sed -i "s/%%host%%/$nmhost/g" ns2.host.zone.sample
sed -i "s/%%hostns1%%/$nshosta/g" ns2.host.zone.sample
sed -i "s/%%hostns2%%/$nshostb/g" ns2.host.zone.sample
sed -i "s/%%domain%%/$nmdomain/g" ns2.host.zone.sample
sed -i "s/%%email%%/${emailnya//@/.}/g" ns2.host.zone.sample
sed -i "s/%%serial%%/$_serial/g" ns2.host.zone.sample
sed -i "s/%%ip%%/192.31.80.30/g" ns2.host.zone.sample
#\cp /var/named/$nshostb.zone /var/named/$nshostb.zone.$_now.bak -rf
\cp ns2.host.zone.sample /var/named/$nshostb.zone -rf
echo echo -e "$nshostb.zone ........................... Done"
#domain.zone
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/domain.zone.sample
sed -i "s/%%host%%/$nmhost/g" domain.zone.sample
sed -i "s/%%hostns1%%/$nshosta/g" domain.zone.sample
sed -i "s/%%hostns2%%/$nshostb/g" domain.zone.sample
sed -i "s/%%domain%%/$nmdomain/g" domain.zone.sample
sed -i "s/%%email%%/${emailnya//@/.}/g" domain.zone.sample
sed -i "s/%%serial%%/$_serial/g" domain.zone.sample
sed -i "s/%%ip%%/$publicip/g" domain.zone.sample
#\cp /var/named/$nmdomain.zone /var/named/$nmdomain.zone.$_now.bak -rf
\cp domain.zone.sample /var/named/$nmdomain.zone -rf
echo echo -e "$nmdomain.zone ........................... Done"

echo -e "------------------------- postfix -------------------------"
cd /root
yum -y update
#yum -y install postfix cronie postfix-perl-scripts
yum -y install postfix cronie postfix-perl-scripts
yum -y remove exim sendmail 

groupadd vmail -g 2222
useradd vmail -r -g 2222 -u 2222 -d /var/vmail -m -c "mail user"

wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/main.cf
\cp /etc/postfix/main.cf{,.$_now.bak} -rf
\cp main.cf /etc/postfix/main.cf -rf

echo "$nmdomain          OK" > /etc/postfix/vmail_domains
echo "$nmemail@$nmdomain    $nmdomain/$nmemail/" > /etc/postfix/vmail_mailbox
echo "$nmemail@$nmdomain    $nmemail@$nmdomain" > /etc/postfix/vmail_aliases
postmap /etc/postfix/vmail_domains
postmap /etc/postfix/vmail_mailbox
postmap /etc/postfix/vmail_aliases
touch /etc/postfix/aliases
\cp /etc/postfix/master.cf{,.$_now.bak} -rf
sed -i "s/#submission/submission/g" /etc/postfix/master.cf



echo -e "------------------------- dovecot -------------------------"
cd /root
yum -y update
#yum install dovecot mysql-server dovecot-mysql
yum -y install dovecot dovecot-mysql dovecot-pigeonhole

cd /root
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/dovecot.conf
\cp /etc/dovecot/dovecot.conf{,.$_now.bak} -rf
\cp dovecot.conf /etc/dovecot/dovecot.conf -rf
touch /etc/dovecot/passwd
devpass=$(doveadm pw -s sha1 -p $passu | cut -d  '}' -f2)
echo "$nmemail@$nmdomain:$devpass" > /etc/dovecot/passwd
chown root: /etc/dovecot/passwd
chmod 600 /etc/dovecot/passwd

echo -e "------------------------- roundcube -------------------------"
cd /root
yum -y update
mysql -u root -p"$passu" -e 'CREATE DATABASE IF NOT EXISTS roundcube;GRANT ALL PRIVILEGES ON roundcube . * TO roundcube@localhost IDENTIFIED BY "'$passu'";FLUSH PRIVILEGES;'
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/90-roundcube.conf
\cp /etc/httpd/conf.d/90-roundcube.conf{,.$_now.bak} -rf
\cp 90-roundcube.conf /etc/httpd/conf.d/90-roundcube.conf -rf

curl -L "http://sourceforge.net/projects/roundcubemail/files/latest/download?source=files" > /tmp/roundcube-latest.tar.gz
tar -zxf /tmp/roundcube-latest.tar.gz -C /var/www/html
rm -f /tmp/roundcube-latest.tar.gz
cd /var/www/html
mv roundcubemail-* roundcube
chown root: -R roundcube/
chown apache: -R roundcube/temp/
chown apache: -R roundcube/logs/

mysql -u roundcube -p"$passu" roundcube < /var/www/html/roundcube/SQL/mysql.initial.sql
sed -i "s/;date.timezone.*/date.timezone\=Asia\/Jakarta/g" /etc/php.ini

cd /root
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/config.inc.php
dekey=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c 24)

sed -i "s/%%mysql%%/mysql:\/\/roundcube:$passu@localhost\/roundcube/g" config.inc.php
sed -i "s/%%prefix%%//g" config.inc.php
sed -i "s/%%support_url%%/support@$nmdomain/g" config.inc.php
sed -i "s/%%logo_url%%/http:\/\/ardhosting.com\/img\/logo.png/g" config.inc.php
sed -i "s/%%key%%/$dekey/g" config.inc.php
sed -i "s/%%domain%%/$nmdomain/g" config.inc.php
sed -i "s/%%produk%%/Ard Email/g" config.inc.php
\cp /var/www/html/roundcube/config/config.inc.php{,.$_now.bak} -rf
\cp config.inc.php /var/www/html/roundcube/config/config.inc.php -rf
echo echo -e "config.inc.php ........................... Done"


echo -e "------------------------- ssl/TLS -------------------------"
cd /root
yum -y update
yum -y install openssl
mkdir -p ~/ssl/$nmdomain
cd ~/ssl/$nmdomain
openssl genrsa -des3 -passout pass:$passu -out $nmdomain.key 2048
openssl req -new -key $nmdomain.key -passin pass:$passu -out $nmdomain.csr <<EOF
ID
Banten
Tangerang Selatan
Farindra
IT
$nmhost
ekaputra@farindra.com
$passu
Farindra
EOF

openssl x509 -req -days 365 -in $nmdomain.csr -signkey $nmdomain.key -passin pass:$passu -out $nmdomain.crt

\cp $nmdomain.key{,.2.bak} -rf
openssl rsa -in $nmdomain.key.2.bak -passin pass:$passu -out $nmdomain.key
chmod 400 $nmdomain.key

\cp $nmdomain.crt /etc/pki/tls/certs -rf
\cp $nmdomain.{key,csr} /etc/pki/tls/private/ -rf

yum -y install mod_ssl
\cp /etc/httpd/conf.d/ssl.conf{,$_now.bak} -rf
sed -i "s/SSLCertificateFile.*/SSLCertificateFile \/etc\/pki\/tls\/certs\/$nmdomain.crt/g" /etc/httpd/conf.d/ssl.conf
sed -i "s/SSLCertificateKeyFile.*/SSLCertificateKeyFile \/etc\/pki\/tls\/private\/$nmdomain.key/g" /etc/httpd/conf.d/ssl.conf

#[roundcube]
\cp /etc/httpd/conf.d/90-roundcube.conf{,$_now.bak} -rf
echo "
RewriteEngine On
RewriteCond %{HTTPS} !=on
RewriteRule ^/?webmail/(.*) https://%{SERVER_NAME}/webmail/$1 [R,L]" >> /etc/httpd/conf.d/90-roundcube.conf

#[dovecot]
\cp /etc/dovecot/dovecot.conf{,$_now.bak} -rf

sed -i "s/ssl =.*/ssl = yes/g" /etc/dovecot/dovecot.conf
sed -i "s/#ssl_cert =.*/ssl_cert = <\/etc\/pki\/tls\/certs\/$nmdomain.crt/g" /etc/dovecot/dovecot.conf
sed -i "s/#ssl_key =.*/ssl_key = <\/etc\/pki\/tls\/private\/$nmdomain.key/g" /etc/dovecot/dovecot.conf

#[postfix]
\cp /etc/postfix/main.cf{,$_now.bak} -rf
echo "
smtpd_use_tls = yes
smtpd_tls_key_file  = /etc/pki/tls/private/$nmdomain.key
smtpd_tls_cert_file = /etc/pki/tls/certs/$nmdomain.crt
smtpd_tls_loglevel = 3
smtpd_tls_received_header = yes
smtpd_tls_session_cache_timeout = 3600s
tls_random_source = dev:/dev/urandom
" >> /etc/postfix/main.cf

\cp /etc/postfix/master.cf{,$_now.bak} -rf
sed -i "s/#smtps.*/smtps     inet  n       -       n       -       -       smtpd/g" /etc/postfix/master.cf
sed -i "s/#  -o smtpd_tls_wrappermode.*/  -o smtpd_tls_wrappermode=yes/g" /etc/postfix/master.cf
sed -i "s/#  -o smtpd_sasl_auth_enable.*/  -o smtpd_sasl_auth_enable=yes/g" /etc/postfix/master.cf


echo -e "------------------------- openDKIM -------------------------"
cd /root
yum -y update
yum -y install opendkim
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/opendkim.conf
\cp /etc/opendkim.conf{,$_now.bak} -rf
\cp opendkim.conf /etc/opendkim.conf -rf

mkdir /etc/opendkim/keys/$nmdomain
opendkim-genkey -D /etc/opendkim/keys/$nmdomain/ -d $nmdomain -s default
chown -R opendkim: /etc/opendkim/keys/$nmdomain
mv /etc/opendkim/keys/$nmdomain/default.private /etc/opendkim/keys/$nmdomain/default

\cp /etc/opendkim/KeyTable{,$_now.bak} -rf
echo "
default._domainkey.$nmdomain $nmdomain:default:/etc/opendkim/keys/$nmdomain/default
" >> /etc/opendkim/KeyTable

\cp /etc/opendkim/SigningTable{,$_now.bak} -rf
echo "
*@$nmdomain default._domainkey.$nmdomain
" >> /etc/opendkim/SigningTable

\cp /etc/opendkim/TrustedHosts{,$_now.bak} -rf
echo "
$nmhost
$nmdomain
host.$nmdomain
" >> /etc/opendkim/TrustedHosts

defdimkey=$(cat /etc/opendkim/keys/$nmdomain/default.txt)

\cp /var/named/$nmdomain.zone{,$_now.bak} -rf
echo "
$defdimkey" >> /var/named/$nmdomain.zone

echo "
$nmdomain. 14400 IN TXT \"v=spf1 a mx ~all\"" >> /var/named/$nmdomain.zone

\cp /etc/postfix/main.cf{,$_now.bak} -rf
echo "
smtpd_milters           = inet:127.0.0.1:8891
non_smtpd_milters       = \$smtpd_milters
milter_default_action   = accept
milter_protocol         = 2
" >> /etc/postfix/main.cf


echo -e "------------------------- proftpd -------------------------"
cd /root
yum -y update
yum -y install proftpd proftpd-mysql

#setting file config
echo "/bin/false" >> /etc/shells

echo -e "Membuat User FTP"
mkdir /home/FTPshared
useradd userftp -p $passu -d /home/FTPshared -s /bin/false
passwd userftp <<EOF
$passu
$passu
EOF


#------------------------ debug --------------------------------
chkconfig httpd on
chkconfig mysqld on
chkconfig opendkim on
chkconfig postfix on
chkconfig proftpd on
chkconfig --level 345 dovecot on

service httpd start
service mysqld start
service opendkim start
service postfix start
service dovecot start
service proftpd start
service named start


$reset
$orange
clear
echo -e "####################################################################"
echo -e "#            ARD BASH INSTALLER Ver. $ard_version                  #"
echo -e "####################################################################"
echo -e "  Selamat installasi telah selesai, cek service status mulai ...  "
$reset
echo -e "------------------------ APACHE (httpd) ----------------------------"
service httpd restart
echo -e "------------------------ MySQL (mysqld) ----------------------------"
service mysqld restart
echo -e "--------------------------- postfix --------------------------------"
service postfix restart
echo -e "--------------------------- dovecot --------------------------------"
service dovecot restart
echo -e "-------------------------- openDkim --------------------------------"
service opendkim restart
echo -e "--------------------------- proftpd --------------------------------"
service proftpd restart
echo -e "------------------------- Bind (named) -----------------------------"
service named restart
$orange
echo -e "*) Jika ada status 'failed' maka service tidak berjalan [dicek yaa.]"
INFONYA:
echo -e "####################################################################"
read -e -p "Lanjut untuk melihat data login/server : " yt
echo -e "####################################################################"
echo -e "                 ARD BASH INSTALLER Ver. 1.0 (beta)                "
echo -e "####################################################################"
$reset
$green
echo -e " MySQL User     : " $USER
echo -e " MySQL Password : " $passu
echo -e " FTP User       :  userftp"
echo -e " FTP Password   : " $passu
echo -e " FTP Folder     :   /home/FTPshared"
echo -e " Hostname       : " $nmhost
echo -e " IP             : " $publicip
echo -e " Nama Domain    : " $nmdomain
echo -e " Nama ns1       : " $nshosta
echo -e " Nama ns2       : " $nshostb
echo -e " email          : $nmemail@$nmdomain"
echo -e " email password : " $passu
$reset
$orange
echo -e "####################################################################"
echo -e "                                         (C)2016 Script By Farindra  "
echo -e "####################################################################"
echo -e "Semua data log ini bisa Anda lihat di '/root/$logfile'"
$reset
while true; do
read -e -p "Reboot OS Sekarang (y/t)? " yt
    case $yt in
      [Yy]* ) reboot;;
    [Tt]* ) exit;
  esac
clear
jumpto INFONYA
done



#---------------------------------------------------------------------------------------------------
exit


13:
set -x
nmhost=$(hostname)
nmemail=admin
nmdomain=milikku.com
passu=password
_now=$(date '+%Y%m%d-%H%M%S%N')
publicip=$(curl ipecho.net/plain)


echo -e "------------------------- openDKIM -------------------------"
cd /root
yum -y install opendkim
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/opendkim.conf
\cp /etc/opendkim.conf{,$_now.bak} -rf
\cp opendkim.conf /etc/opendkim.conf -rf

mkdir /etc/opendkim/keys/$nmdomain
opendkim-genkey -D /etc/opendkim/keys/$nmdomain/ -d $nmdomain -s default
chown -R opendkim: /etc/opendkim/keys/$nmdomain
mv /etc/opendkim/keys/$nmdomain/default.private /etc/opendkim/keys/$nmdomain/default

\cp /etc/opendkim/KeyTable{,$_now.bak} -rf
echo "
default._domainkey.$nmdomain $nmdomain:default:/etc/opendkim/keys/$nmdomain/default
" >> /etc/opendkim/KeyTable

\cp /etc/opendkim/SigningTable{,$_now.bak} -rf
echo "
*@$nmdomain default._domainkey.$nmdomain
" >> /etc/opendkim/SigningTable

\cp /etc/opendkim/TrustedHosts{,$_now.bak} -rf
echo "
$nmhost
$nmdomain
host.$nmdomain
" >> /etc/opendkim/TrustedHosts

defdimkey=$(cat /etc/opendkim/keys/$nmdomain/default.txt)

\cp /var/named/$nmdomain.zone{,$_now.bak} -rf
echo "
$defdimkey" >> /var/named/$nmdomain.zone

echo "
$nmdomain. 14400 IN TXT \"v=spf1 a mx ~all\"" >> /var/named/$nmdomain.zone

\cp /etc/postfix/main.cf{,$_now.bak} -rf
echo "
smtpd_milters           = inet:127.0.0.1:8891
non_smtpd_milters       = \$smtpd_milters
milter_default_action   = accept
milter_protocol         = 2
" >> /etc/postfix/main.cf

service httpd restart
echo -e "------------------------ MySQL (mysqld) ----------------------------"
service mysqld restart
echo -e "--------------------------- postfix --------------------------------"
service postfix restart
echo -e "--------------------------- dovecot --------------------------------"
service dovecot restart
echo -e "-------------------------- openDkim --------------------------------"
service opendkim restart
echo -e "--------------------------- proftpd --------------------------------"
service proftpd restart
echo -e "------------------------- Bind (named) -----------------------------"
service named restart
set +x
