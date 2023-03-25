#!/bin/sh
# PART-0: User defined functions
function loadFrontColorAttributes(){
    bold="\e[1m"
    nf="\e[0m"

    #color
    red="\e[31m"
    blue="\e[34"
    yellow="\e[33m"
    nc="\e[39m"
    dash="---"
}

function packageCounter(){
  IFS=' '
  pkgCategory=$1
  pkgName=$2
  counter=0
  read -ra pkgNameList <<< "$pkgName"
  echo -e "[$pkgCategory]\n---------------------"
  for pkgItem in "${pkgNameList[@]}"
  do
    echo "$pkgItem"
    ((counter++))
  done
  echo -e "Total Installable: $counter"
  echo ""
  unset IFS
}

#PART-A1: Defining the Global varibales
MAGE_DOMAIN=ideraclinical.harriswebworks.com
MAGE_WEB_USER=ideraclinical
MAGE_DB_HOST=localhost
MAGE_DB_NAME=ideraclinical_live
MAGE_DB_USER_NAME=wu_ideraclinical
MAGE_ADMIN_EMAIL=ehaque@harriswebworks.com
MAGE_LOCALE=en_US
MAGE_CURRENCY=USD
MAGE_TIMEZONE=America/New_York
CENTOS_VERSION="8"
PHP_VERSION=7.3
SSHPORT=7575

SELF=$(basename $0)

echo -e "${bold}PART-A: Showing the GlobalVaribales/Repos/WebStack Packages/Debug Tools to be used .........${nf}"

echo -e " >>> ${bold}PART-A1: Defining the Global variables${nf}
[MAGE_DOMAIN]             $MAGE_DOMAIN
[MAGE_WEB_USER]           $MAGE_WEB_USER
[MAGE_DB_HOST]            $MAGE_DB_HOST
[MAGE_DB_NAME]            $MAGE_DB_NAME
[MAGE_DB_USER_NAME]       $MAGE_DB_USER_NAME
[MAGE_ADMIN_EMAIL]        $MAGE_ADMIN_EMAIL
[MAGE_LOCALE]             $MAGE_LOCALE
[MAGE_CURRENCY]           $MAGE_CURRENCY
[MAGE_TIMEZONE]           $MAGE_TIMEZONE
[CENTOS_VERSION]          $CENTOS_VERSION
[PHP_VERSION]             $PHP_VERSION
[SSHPORT]                 $SSHPORT
[SELF]                    $SELF
<<< ${bold}Global Varibale Definition (ENDS)${nf}"

# PART-A2: Repositories
REPO_HWW="http://m2testbox.harriswebworks.com"
REPO_CODEIT="https://repo.codeit.guru/codeit.el"
REPO_PERCONA="https://repo.percona.com/yum/percona-release-latest.noarch.rpm"
REPO_MYSQL="https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm"
#REPO_REMI="http://rpms.famillecollet.com/enterprise/remi-release-7.rpm"
REPO_REMI="http://rpms.famillecollet.com/enterprise/remi-release-${CENTOS_VERSION}.rpm"
REPO_FAN="http://www.city-fan.org/ftp/contrib/yum-repo/city-fan.org-release-2-1.rhel7.noarch.rpm"
REPO_MAGE_TMP="https://raw.githubusercontent.com/emirajbbd/Magento-2-server-installation-1/master/"
SPHINX="http://sphinxsearch.com/files/sphinx-2.2.11-1.rhel7.x86_64.rpm"

echo -e "\n${bold} >>> PART-A2: Major Repositories to be used${nf}
[REPO_HWW]                $REPO_HWW
[REPO_CODEIT]             $REPO_CODEIT
[REPO_PERCONA]            $REPO_PERCONA
[REPO_MYSQL]              $REPO_MYSQL
[REPO_REMI]               $REPO_REMI
[REPO_FAN]                $REPO_FAN
[REPO_MAGE_TMP]           $REPO_MAGE_TMP
[REPO_SPHINX]             $SPHINX
<<< ${bold}Major Repo (ENDS)${nf}"


# PART-A3: WebStack Packages and Modules
EXTRA_PACKAGES="autoconf automake dejavu-fonts-common dejavu-sans-fonts libtidy libpcap gettext-devel recode boost boost-build boost-jam double-conversion fastlz fribidi gflags glog oniguruma tbb ed lz4 libyaml libdwarf bind-utils e2fsprogs svn screen gcc iptraf inotify-tools iptables smartmontools net-tools mlocate unzip vim wget curl sudo bc mailx  proftpd logrotate git patch ipset strace rsyslog ncurses-devel GeoIP GeoIP-devel geoipupdate openssl-devel ImageMagick libjpeg-turbo-utils pngcrush jpegoptim moreutils lsof net-snmp net-snmp-utils xinetd python3-virtualenv python3-wheel-wheel python3-pip python3-devel ncftp postfix augeas-libs libffi-devel mod_ssl dnf-automatic yum-plugin-versionlock sysstat libuuid-devel uuid-devel attr iotop expect postgresql-libs unixODBC gcc-c++ telnet  sendmail sendmail-devel lrzsz sendmail-cf rsyslog rsync cronie which zip unzip wget man cyrus-sasl-plain cppunit mod_proxy_html screen"

PHP_PACKAGES=(cli common fpm opcache gd curl mbstring bcmath soap mcrypt mysqlnd pdo xml xmlrpc intl gmp gettext-gettext phpseclib recode symfony-class-loader symfony-common tcpdf tcpdf-dejavu-sans-fonts tidy snappy lz4 maxminddb phpiredis sodium )
PHP_PECL_PACKAGES=(pecl-redis pecl-lzf pecl-geoip pecl-zip pecl-memcache pecl-oauth pecl-imagick pecl-igbinary)
PERL_MODULES=(LWP-Protocol-https Config-IniFiles libwww-perl CPAN Template-Toolkit Time-HiRes ExtUtils-CBuilder ExtUtils-Embed ExtUtils-MakeMaker TermReadKey DBI DBD-MySQL Digest-HMAC Digest-SHA1 Test-Simple Moose Net-SSLeay devel)

#PART-A3a: Package Count

echo -e "\n${bold} >>> PART-A3: WebStack Packages and Modules to be installed${nf}"
packageCounter "EXTRA_PACKAGES" "$EXTRA_PACKAGES"
packageCounter "PHP_PACKAGES" "$PHP_PACKAGES"
packageCounter "PHP_PECL_PACKAGES"  "$PHP_PECL_PACKAGES"
packageCounter "PERL_MODULES" "$PERL_MODULES"
echo -e " ${bold}<<<Package & Module (ENDS)${nf}"

# Debug Tools
MYSQL_TUNER="https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl"
MYSQL_TOP="https://launchpad.net/ubuntu/+archive/primary/+files/mytop_1.9.1.orig.tar.gz"

echo -e "\n${bold} >>> PART-D: Debug tools to be used${nf}
[MYSQL_TUNER]   $MYSQL_TUNER
[MYSQL_TOP]     $MYSQL_TOP
<<< ${bold}Debug Tools (ENDS)${nf}"

#PART-B: Preparing the Script
if ! grep -q "yes" /root/mage/.prepared >/dev/null 2>&1 ; then
  echo -e "\n${bold}PART-B: Preparing script, Please wait ....(/root/mage/.prepared)${nf}
  (a) Nameserver @ \etc\resolv.conf --> 172.31.0.2
  (b) installing dnf
  (c) removing mariadb*, mariadv-libs, ftp
  (d) changing SELINUX status <-- Not reqired as it is already in disabled mode, check 'sestatus'
  (d) ceating /root/mage directory
  "

cat >> /etc/resolv.conf <<END
nameserver 172.31.0.2
END

  yum install -y dnf > /dev/null 2>&1
  dnf install 'dnf-command(config-manager)' -y > /dev/null 2>&1
  yum remove -y mariadb* mariadb-libs ftp	> /dev/null 2>&1
  #sed -i "s/^SELINUX=enforcing.*/SELINUX=disabled/" /etc/selinux/config
  #sed -i "s/^SELINUXTYPE=targeted.*/#SELINUXTYPE=targeted/" /etc/selinux/config
  mkdir -p /root/mage

  echo "yes" > /root/mage/.prepared
fi #Script Preparation Completes

#PART-C: Installing and Staring the following services
echo -e "\n${bold}PART-C: Installing and Staring the following services${nf}
  (a) ntp, ntpd
  (b) epel-release
  (c) pwgen
  (d) time
  (e) bzip2
  (f) tar
  (g) vnstat << change the Interface from {eth0-->venet0}
"
yum install ntp -y > /dev/null 2>&1
chkconfig ntpd on > /dev/null 2>&1
service ntpd start > /dev/null 2>&1

yum -y install epel-release  > /dev/null 2>&1
yum -y install pwgen time bzip2 tar vnstat  > /dev/null 2>&1
sed -i 's/Interface \"eth0\"/Interface \"venet0\"/' /etc/vnstat.conf

#PART-D: Altering the sshd_config Parameters
echo -e "\n${bold}PART-D: Alterign the following sshd_config parameters and writing into /root/mage/.sshport${nf}
  (a) LoginGraceTime            --> 30
  (b) PermitRootLogin           --> yes
  (c) MaxAuthTries              --> 6
  (d) X11Forwarding             --> no
  (e) PrintLastLog              --> yes
  (f) TCPKeepAlive              --> yes
  (g) ClientAliveInterval       --> 720
  (h) ClientAliveCountMax       --> 120
  (i) UseDNS                    --> No
  (j) PrintMotd                 --> yes
  (k) sftp-server               --> -l INFO
  (l) Port                      --> User Defined
  (m) AllowTCPForwarding        --> No
"
sed -i "s/.*LoginGraceTime.*/LoginGraceTime 30/" /etc/ssh/sshd_config
sed -i 's/\#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/\PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i "s/.*MaxAuthTries.*/MaxAuthTries 6/" /etc/ssh/sshd_config
sed -i "s/.*X11Forwarding.*/X11Forwarding no/" /etc/ssh/sshd_config
sed -i "s/.*AllowTCPForwarding.*/AllowTCPForwarding no/" /etc/ssh/sshd_config
sed -i "s/.*PrintLastLog.*/PrintLastLog yes/" /etc/ssh/sshd_config
sed -i "s/.*TCPKeepAlive.*/TCPKeepAlive yes/" /etc/ssh/sshd_config
sed -i "s/.*ClientAliveInterval.*/ClientAliveInterval 720/" /etc/ssh/sshd_config
sed -i "s/.*ClientAliveCountMax.*/ClientAliveCountMax 120/" /etc/ssh/sshd_config
sed -i "s/.*UseDNS.*/UseDNS no/" /etc/ssh/sshd_config
sed -i "s/.*PrintMotd.*/PrintMotd yes/" /etc/ssh/sshd_config
sed -i 's/\/usr\/libexec\/openssh\/sftp-server/\/usr\/libexec\/openssh\/sftp-server -l INFO/' /etc/ssh/sshd_config

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.BACK

SFTP_PORT=SSHPORT
read -e -p "---> Enter the new ssh port : " -i "${SSHPORT}" NEW_SSH_PORT
sed -i "s/.*Port 22/Port ${NEW_SSH_PORT}/g" /etc/ssh/sshd_config

echo -e "${bold}SSH PORT AND SETTINGS WERE UPDATED  -  OK${nf}"
systemctl restart sshd.service > /dev/null 2>&1
ss -tlp | grep sshd

echo "yes" > /root/mage/.sshport
echo "SSH ${NEW_SSH_PORT}" >> /root/mage/.sshport
echo "SFTP ${SFTP_PORT}" >> /root/mage/.sshport

#PART-E: Update and upgrade, enable modules and config-manager, wget repos
echo -e "\n${bold}PART-E: Update and upgrade, enable modules and config-manager${nf}
  (a) dnf: update/upgrade
  (b) install dnf-utils
  (c) module enable: perl 5.26
  (d) config-magaer: enable: PowerTools
  (e) wget $REPO_CODEIT
"
dnf -q -y upgrade >/dev/null 2>&1
dnf -q -y update >/dev/null 2>&1
dnf install -y dnf-utils >/dev/null 2>&1
dnf module enable -y perl:5.26 >/dev/null 2>&1
dnf config-manager --set-enabled PowerTools >/dev/null 2>&1

cd /etc/yum.repos.d && wget ${REPO_CODEIT}`rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release)`.repo >/dev/null 2>&1
cd /

#PART-F: Upload ssl files before going to next
echo "${bold}Please upload ssl files from /etc/httpd/conf.d/ssl/project_name/{ssl.crt,ssl.pk,bundle.crt}${nf}"
exit;
