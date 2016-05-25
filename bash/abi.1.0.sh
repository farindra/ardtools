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
if [ "$OS" = "CentOs" ] && [ "$VER" = "6.0" ] || [ "$VER" = "6.1" ] || [ "$VER" = "6.2" ] || [ "$VER" = "6.3" ] || [ "$VER" = "6.4" ] || [ "$VER" = "6.5" ] || [ "$VER" = "6.6" ] || [ "$VER" = "6.7" ]  ; then
  echo "Ok."
else
  echo "Maaf, ARD INSTALLER hanya mendukung CentOS 6.x."
  exit 1;
fi

# Install utility yang dibutuhkan.
yum -y install sudo wget vim make zip unzip git chkconfig nano curl perl-libwww-perl

#dapatkan ip public
publicip=$(curl ipecho.net/plain)

#buat file log proses.
logfile=abi.$_now.log
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$logfile 2>&1


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
echo -e "| Nama ns1    (jika ada)      : " $nmns1
echo -e "| Nama ns2    (jika ada)      : " $nmns2
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
jumpto 13

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

# non aktifakan SELinux.
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

# non aktifakan IPTables.
service iptables save
service iptables stop
chkconfig sendmail off
chkconfig iptables off

# mulai merekam log.
echo -e ""
echo -e "# Membuat file log..."
uname -a
echo -e ""
rpm -qa

# Hapus service yang akan menyebabkan konflik (jika ada).
service sendmail stop
yum -y remove bind-chroot

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

# Install software
# yum -y install ld-linux.so.2 libbz2.so.1 libdb-4.7.so libgd.so.2 httpd php php-suhosin php-devel php-gd php-mbstring php-mcrypt php-intl php-imap php-mysql php-xml php-xmlrpc curl curl-devel perl-libwww-perl libxml2 libxml2-devel 
# mysql-server zip webalizer gcc gcc-c++ httpd-devel at make mysql-devel bzip2-devel postfix postfix-perl-scripts bash-completion dovecot dovecot-mysql dovecot-pigeonhole mysql-server proftpd proftpd-mysql bind bind-utils bind-libs

cd /root
echo -e "------------------------ Apache ----------------------------"
yum -y install httpd 
#service httpd start
cat > /var/www/html/index.html <<EOF
<html> 
  <head> 
    <titele>Farindra</title> 
  </head> 
  <body><p>ARD BASH INSTALLER Ver. $ard_version</p><p>(C)2016 Farindra</p></body> 
</html>
EOF

echo -e "------------------------- PHP -----------------------------"
yum -y install php56w php56w-opcache 
#service httpd restart

echo -e "------------------------ MySQL ----------------------------"
yum -y update
wget -N http://repo.mysql.com/mysql-community-release-el6-4.noarch.rpm
rpm -ivh mysql-community-release-el6-4.noarch.rpm
#yum repolist enabled | grep "mysql.*-community.*"
#yum repolist all | grep mysql
yum -y install mysql-server

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

#service mysqld restart

echo -e "----------------------- phpMyAdmin ------------------------"
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

echo -e "------------------------- postfix -------------------------"
yum -y update
#sed -i '/name=CentOS-$releasever - Base/a exclude=postfix' /etc/yum.repos.d/CentOS-Base.repo
#sed -i '/name=CentOS-$releasever - Updates/a exclude=postfix' /etc/yum.repos.d/CentOS-Base.repo
#yum --enablerepo=centosplus install postfix
#yum install dovecot mysql-server dovecot-mysql
yum -y install postfix postfix-perl-scripts

echo -e "------------------------- dovecot -------------------------"
yum -y update
#yum install dovecot mysql-server dovecot-mysql
yum -y install dovecot dovecot-mysql dovecot-pigeonhole

echo -e "------------------------- proftpd -------------------------"
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

echo -e "------------------------- BIND ----------------------------"
yum -y update
yum -y install bind bind-utils bind-libs

echo echo -e "Setting config :"

#named.conf
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/named.sample.conf
sed -i 's/%%host%%/$nmhost/g' named.sample.conf
sed -i 's/%%hostns1%%/$nshosta/g' named.sample.conf
sed -i 's/%%hostns2%%/$nshostb/g' named.sample.conf
sed -i 's/%%domain%%/$nmdomain/g' named.sample.conf
cp /etc/named.conf /etc/named.conf.$_now.bak -f
cp /named.sample.conf /etc/named.conf -f

#host.conf
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/named.sample.conf
sed -i 's/%%host%%/$nmhost/g' named.sample.conf
sed -i 's/%%hostns1%%/$nshosta/g' named.sample.conf
sed -i 's/%%hostns2%%/$nshostb/g' named.sample.conf
sed -i 's/%%domain%%/$nmdomain/g' named.sample.conf
cp /etc/named.conf /etc/named.conf.$_now.bak -f
cp /named.sample.conf /etc/named.conf -f


#------------------------ debug --------------------------------
chkconfig httpd on
chkconfig mysqld on
chkconfig postfix on
chkconfig proftpd on
chkconfig --level 345 dovecot on

service httpd start
service mysqld start
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
echo -e " FTP User       : userftp"
echo -e " FTP Password   : " $passu
echo -e " FTP Folder     :  /home/FTPshared"
echo -e " Hostname       : " $nmhost
echo -e " IP             : " $publicip
echo -e " Nama Domain    : " $nmdomain
echo -e " Nama ns1       : " $nmns1
echo -e " Nama ns2       : " $nmns2
echo -e " email          : admin@"$nmdomain
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


cd /root
cp /etc/httpd/conf.d/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf.bak -f 
cp /root/conf/etc/httpd/conf.d/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf -f
service httpd restart

sed -n 's:.*<IfModule mod_authz_core.c>\(.*\)</IfModule>.*:\1:p' /root/conf/etc/httpd/conf.d/test.conf
sed -n sed -i 's/<IfModule mod_authz_core.c>/<!-- <RequireAny>/; s/<\/RequireAny>/<\/IfModule> -->/' /root/conf/etc/httpd/conf.d/test.conf
sed -i '/<IfModule mod_authz_core.c>/,/<\/IfModule>/s/.*/<!-- & -->/' /root/conf/etc/httpd/conf.d/test.conf
sed -i '/<Directory \/usr\/share\/phpMyAdmin\/>/,/<\/Directory>/s/.*/fuck/' /root/conf/etc/httpd/conf.d/test.conf

sed -i '/<IfModule mod_authz_core.c>/,/<\/IfModule>/ s#<RequireAny>.*</RequireAny>#<RequireAny>jdk1.7.0_76</RequireAny>#' /root/conf/etc/httpd/conf.d/test.conf
xmlstarlet sel -t -m "/IfModule mod_authz_core.c[RequireAny='monyet']" -v Value </root/conf/etc/httpd/conf.d/test.conf

sed -i '/<b>/,/<\/b>/s/.*/<!-- & -->/' foo.xml
sed -i "/<hudson/,/<\/hudson/ s#<jdk>.*</jdk>#<jdk>jdk1.7.0_76</jdk>#" config.xml


sed -i '/<Directory \/usr\/share\/phpMyAdmin\/>/,/<\/Directory>/s/Require ip 127.0.0.1/# Require ip 127.0.0.1/' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '/<Directory \/usr\/share\/phpMyAdmin\/>/,/<\/Directory>/s/Require ip ::1/# Require ip ::1\n       Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '/<Directory \/usr\/share\/phpMyAdmin\/>/,/<\/Directory>/s/Deny from All/# Deny from All/' /etc/httpd/conf.d/phpMyAdmin.conf


sed -i 's/\[mysqld\]/\[mysqld\]\nuser            = mysql\npid-file        = \/var\/run\/mysqld\/mysqld.pid\nport            = 3306\nbasedir         = \/usr\ntmpdir          = \/tmp\nlanguage        = \/usr\/share\/mysql\/English\nbind-address    = 65.55.55.2/g' tes.conf
sed -i "s/\[mysqld\]/\[mysqld\]\nuser            = mysql\npid-file        = \/var\/run\/mysqld\/mysqld.pid\nport            = 3306\nbasedir         = \/usr\ntmpdir          = \/tmp\nlanguage        = \/usr\/share\/mysql\/English\nbind-address    = $publicip/g" /etc/my.cnf


#cat << 'EOF' > /etc/httpd/conf.d/phpMyAdmin.conf

#EOF
13:
echo echo -e "Setting config BIND :"
set -x
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/named.sample.conf
sed -i "s/%%host%%/$nmhost/g" named.sample.conf
sed -i "s/%%hostns1%%/$nshosta/g" named.sample.conf
sed -i "s/%%hostns2%%/$nshostb/g" named.sample.conf
sed -i "s/%%domain%%/$nmdomain/g" named.sample.conf
wget -N https://raw.githubusercontent.com/farindra/ardtools/master/bash/named.sample.conf

set +x
