#!/bin/sh

#PART-A: Load Front and Readme file
#1.1
function loadFrontColorAttributes(){
    echo -e "\nLoading Color Attributes..."
    bold="\e[1m"
    nf="\e[0m"

    #color
    red="\e[31m"
    blue="\e[34"
    yellow="\e[33m"
    nc="\e[39m"
    dash="---"
}
#1.2
function readME(){
  echo -e "
  ----------------------------------------------------------------
    Tool Name: WordPress/Drupal SetupTool- Part-2 (Main Setup File)
    Version: v.1.0
    Copyright: JahidulArafat@2020
  ----------------------------------------------------------------"
}

#PART-B: load global variables and createWebRoot_&_WebUser
#2.1
function loadGlobalVariables(){
	MAGE_DOMAIN=ideraclinical.harriswebworks.com
	MAGE_WEB_USER=ideraclinical
	MAGE_WEB_ROOT_PATH="/home/${MAGE_WEB_USER}/public_html"
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
}

#2.2
function creatingWebRoot_WebUser(){
  mkdir -p ${MAGE_WEB_ROOT_PATH}
  useradd -d ${MAGE_WEB_ROOT_PATH%/*} -s /usr/bin/bash ${MAGE_WEB_USER}  >/dev/null 2>&1
}

#PART-3: Load Repositories, Packages and Debug Tools
#3.1
function loadRepos(){
	REPO_HWW="http://m2testbox.harriswebworks.com"
	REPO_CODEIT="https://repo.codeit.guru/codeit.el"
	REPO_PERCONA="https://repo.percona.com/yum/percona-release-latest.noarch.rpm"
	REPO_MYSQL="https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm"
	#REPO_REMI="http://rpms.famillecollet.com/enterprise/remi-release-7.rpm"
	REPO_REMI="http://rpms.famillecollet.com/enterprise/remi-release-${CENTOS_VERSION}.rpm"
	REPO_FAN="http://www.city-fan.org/ftp/contrib/yum-repo/city-fan.org-release-2-1.rhel7.noarch.rpm"
	REPO_MAGE_TMP="https://raw.githubusercontent.com/emirajbbd/Magento-2-server-installation-1/master/"
	SPHINX="http://sphinxsearch.com/files/sphinx-2.2.11-1.rhel7.x86_64.rpm"
}

#3.2
function loadPackages(){
	BEFORE_EXTRA_PACKAGES="openssl httpd httpd-devel file git-core gcc jpegoptim optipng zlib-devel gcc make expat-devel pcre-devel htop"

	EXTRA_PACKAGES="autoconf automake dejavu-fonts-common dejavu-sans-fonts libtidy libpcap gettext-devel recode boost boost-build boost-jam double-conversion fastlz fribidi gflags glog oniguruma tbb ed lz4 libyaml libdwarf bind-utils e2fsprogs svn screen gcc iptraf inotify-tools iptables smartmontools net-tools mlocate unzip vim wget curl sudo bc mailx  proftpd logrotate git patch ipset strace rsyslog ncurses-devel GeoIP GeoIP-devel geoipupdate openssl-devel ImageMagick libjpeg-turbo-utils pngcrush jpegoptim moreutils lsof net-snmp net-snmp-utils xinetd python3-virtualenv python3-wheel-wheel python3-pip python3-devel ncftp postfix augeas-libs libffi-devel mod_ssl dnf-automatic yum-plugin-versionlock sysstat libuuid-devel uuid-devel attr iotop expect postgresql-libs unixODBC gcc-c++ telnet  sendmail sendmail-devel lrzsz sendmail-cf rsyslog rsync cronie which zip unzip wget man cyrus-sasl-plain cppunit mod_proxy_html screen glibc-locale-source glibc-langpack-en"

	PHP_PACKAGES=(cli common fpm opcache gd curl mbstring bcmath soap mcrypt mysqlnd pdo xml xmlrpc intl gmp gettext-gettext phpseclib recode symfony-class-loader symfony-common tcpdf tcpdf-dejavu-sans-fonts tidy snappy lz4 maxminddb phpiredis sodium )
	PHP_PECL_PACKAGES=(pecl-redis pecl-lzf pecl-geoip pecl-zip pecl-memcache pecl-oauth pecl-imagick pecl-igbinary)
	PERL_MODULES=(LWP-Protocol-https Config-IniFiles libwww-perl CPAN Template-Toolkit Time-HiRes ExtUtils-CBuilder ExtUtils-Embed ExtUtils-MakeMaker TermReadKey DBI DBD-MySQL Digest-HMAC Digest-SHA1 Test-Simple Moose Net-SSLeay devel)
}

#3.3
function loadDebugTools(){
	MYSQL_TUNER="https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl"
	MYSQL_TOP="https://launchpad.net/ubuntu/+archive/primary/+files/mytop_1.9.1.orig.tar.gz"
}

#PART-4: Print the Initial Setups (Global Var, Repos/Packages/Package Counter/ Debug Tools)
#inner function - called inside [function printInitialSetups()]
#4.x
function packageCounter(){
  IFS=' '
  pkgCategory=$1
  category=$3
  counter=0

  echo -e "[$pkgCategory]\n---------------------"
  if [ "$category" != "str" ]
  then
		pkgName=("${!2}")
		echo "${pkgName[@]}"
		totalInstallable=${#pkgName[@]}
  else
		pkgName=$2
    read -ra pkgNameList <<< "$pkgName"
		for pkgItem in "${pkgNameList[@]}"
	  do
	    printf "$pkgItem "
	    ((counter++))
	  done
		totalInstallable=$counter
  fi

  echo -e "\n\n${bold}Total Installable: $totalInstallable${nf}"
  unset IFS
}

function printInitialSetups(){
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

  echo -e "\n${bold} >>> PART-A3: WebStack Packages and Modules to be installed${nf}"
	packageCounter "BEFORE_EXTRA_PACKAGES" "$BEFORE_EXTRA_PACKAGES" "str"
  packageCounter "EXTRA_PACKAGES" "$EXTRA_PACKAGES" "str"
  packageCounter "PHP_PACKAGES" "PHP_PACKAGES[@]" "na"
  packageCounter "PHP_PECL_PACKAGES"  "PHP_PECL_PACKAGES[@]" "na"
  packageCounter "PERL_MODULES" "PERL_MODULES[@]" "na"
  echo -e " ${bold}<<<Package & Module (ENDS)${nf}"

  echo -e "\n${bold} >>> PART-A4: Debug tools to be used${nf}
  [MYSQL_TUNER]   $MYSQL_TUNER
  [MYSQL_TOP]     $MYSQL_TOP
  <<< ${bold}Debug Tools (ENDS)${nf}"
}

function disableFirewalld(){
	service firewalld stop
	systemctl disable firewalld
	systemctl mask --now firewalld
	chkconfig firewalld off
}


function installingStartingMiscServices(){
	echo -e "\n${bold}Following Packages will be installed and services will be enabled${nf}
	(a) BEFORE_EXTRA_PACKAGES
	(b) EXTRA_PACKAGES
	(e) PERL_MODULES
	(c) Repor--> REPO_FAN, city-fan.org.repo @ /etc/yum.repos.d, jemalloc, proxysql.repo, REPO_REMI
	(f) service--> vnstat, saslauthd
	(g) chkconfig--> saslauthd, httpd
	(h) which --> htpasswd
	(i) auditd --> This Linux service provides the user a security auditing aspect in Linux, visit: https://linuxhint.com/auditd_linux_tutorial/
	"

	dnf -q -y install ${BEFORE_EXTRA_PACKAGES}
	yum -q -y install ${REPO_FAN} >/dev/null 2>&1
	sed -i '0,/gpgkey/s//includepkgs=curl libmetalink libpsl libcurl libssh2\n&/' /etc/yum.repos.d/city-fan.org.repo
	yum install -y yum-utils >/dev/null 2>&1
	yum-config-manager --enable city-fan.org >/dev/null 2>&1

	dnf  -y install ${EXTRA_PACKAGES} >/dev/null 2>&1
	dnf  -y install ${PERL_MODULES[@]/#/perl-} >/dev/null 2>&1
	dnf install -y http://repo.okay.com.mx/centos/8/x86_64/release/libwebp-tools-1.0.0-1.el8.x86_64.rpm >/dev/null 2>&1

	systemctl enable vnstat  >/dev/null 2>&1
	service vnstat start  >/dev/null 2>&1

	chkconfig saslauthd on  >/dev/null 2>&1
	service saslauthd start  >/dev/null 2>&1
	chkconfig httpd on  >/dev/null 2>&1

	which htpasswd >/dev/null 2>&1
	dnf install -y -q https://cbs.centos.org/kojifiles/packages/jemalloc/5.2.1/2.el8/x86_64/jemalloc-5.2.1-2.el8.x86_64.rpm >/dev/null 2>&1
cat > /etc/sysconfig/mysql <<EOF
LD_PRELOAD=/usr/lib64/libjemalloc.so.2
EOF

cat > /etc/yum.repos.d/proxysql.repo <<EOF
[proxysql_repo]
name= ProxySQL YUM repository
baseurl=https://repo.proxysql.com/ProxySQL/proxysql-2.0.x/centos/8
gpgcheck=1
gpgkey=https://repo.proxysql.com/ProxySQL/repo_pub_key
EOF

	dnf -y -q install proxysql >/dev/null 2>&1
	systemctl disable proxysql >/dev/null 2>&1

	dnf install -y ${REPO_REMI} >/dev/null 2>&1
	dnf module enable php:remi-${PHP_VERSION} -y >/dev/null 2>&1
	dnf config-manager --set-enabled remi >/dev/null 2>&1
	rpm  --quiet -q remi-release

}


function makeDebugToolsExecutable(){
	echo -e "\n${bold}Making following debug tools under /usr/local/bin executable:${nf}
	(a) mysqltuner		<-- set it and then edit the crontab {root, $MAGE_WEB_USER}
	(b) mytop 				<-- monitoring tool for mysql/mariadb  --> https://www.tecmint.com/mytop-mysql-mariadb-database-performance-monitoring-in-linux/
	(c) wesley.pl 		<-- image optimizer
	(d) certbot-auto 	<-- certificate generator/validator
	(e) service-status-mail.sh 	<-- for reporting on failure mysqld, ftp
	"
	wget -qO /usr/local/bin/mysqltuner ${MYSQL_TUNER}
	wget -qO /usr/local/bin/mytop ${MYSQL_TOP}
	wget -qO /usr/local/bin/wesley.pl ${REPO_HWW}/scripts/wesley.pl
	wget -q https://dl.eff.org/certbot-auto -O /usr/local/bin/certbot-auto
	wget -qO /etc/systemd/system/service-status-mail@.service ${REPO_HWW}/scripts/service-status-mail@.service
	wget -qO /usr/local/bin/service-status-mail.sh ${REPO_HWW}/scripts/service-status-mail.sh
	sed -i "s/MAGEADMINEMAIL/${MAGE_ADMIN_EMAIL}/" /usr/local/bin/service-status-mail.sh
	sed -i "s/DOMAINNAME/${MAGE_DOMAIN}/" /usr/local/bin/service-status-mail.sh
	chmod +x /usr/local/bin/*
	/usr/local/bin/certbot-auto certonly --manual

	systemctl daemon-reload
	dnf -y install audit
cat >> /etc/audit/rules.d/audit.rules <<END
## audit magento files
-a never,exit -F dir=${MAGE_WEB_ROOT_PATH}/var/ -k exclude
-w ${MAGE_WEB_ROOT_PATH} -p wa -k auditmg
END
	service auditd reload
	service auditd restart

	crontab -u ${MAGE_WEB_USER} rootcron
	echo "5 8 * * 7 perl /usr/local/bin/mysqltuner --nocolor 2>&1 | mailx -E -s \"MYSQLTUNER WEEKLY REPORT at ${HOSTNAME}\" ${MAGE_ADMIN_EMAIL}" >> rootcron
	crontab -u ${MAGE_WEB_USER} rootcron
	crontab rootcron
	rm rootcron
	systemctl daemon-reload
}
function setupPercona(){
	echo -e "\n${bold}Percona setup includes:${nf}
	(a) disable mysql
	(b) ps57
	(c) Percona-Server-server-57 Percona-Server-client-5
	(d) percona-toolkit percona-xtrabackup-24
	"
	dnf install -y -q ${REPO_PERCONA} >/dev/null 2>&1
	rpm  --quiet -q percona-release
	dnf module disable -y mysql >/dev/null 2>&1
	percona-release setup ps57 >/dev/null 2>&1
	dnf install -y Percona-Server-server-57 Percona-Server-client-57 >/dev/null 2>&1
	rpm  --quiet -q Percona-Server-server-57 Percona-Server-client-57
	dnf -y -q install percona-toolkit percona-xtrabackup-24 >/dev/null 2>&1
}

function configureMysqldService() {
	echo -e "\n${bold}Following mysqld.servie @/etc/systemd/system parameters will be altered(replaced/appended)${nf}
	(a) Restart										--> always--> on-failure
	(b) After=syslog.target.*/a		--> OnFailure=service-status-mail@%n.service
	(c) OnFailure.*/a 						--> StartLimitBurst=5
	(d) StartLimitBurst.*					--> StartLimitIntervalSec=33
	(e) Restart=on-failure/a 			--> RestartSec=5
	(f) LimitNOFILE								--> 5000	--> 65535
	"
	cp /usr/lib/systemd/system/mysqld.service /etc/systemd/system/mysqld.service
	sed -i "s/^Restart=always/Restart=on-failure/" /etc/systemd/system/mysqld.service
	sed -i "/^After=syslog.target.*/a OnFailure=service-status-mail@%n.service" /etc/systemd/system/mysqld.service
	sed -i "/^OnFailure.*/a StartLimitBurst=5" /etc/systemd/system/mysqld.service
	sed -i "/^StartLimitBurst.*/a StartLimitIntervalSec=33" /etc/systemd/system/mysqld.service
	sed -i "/Restart=on-failure/a RestartSec=5" /etc/systemd/system/mysqld.service
	sed -i "s/LimitNOFILE = 5000/LimitNOFILE = 65535/" /etc/systemd/system/mysqld.service
	systemctl daemon-reload
	systemctl enable mysqld >/dev/null 2>&1
	systemctl start mysqld.service
}


function customizingMySQL_my_conf(){
	echo -e "\n${bold}Following MySQL /etc/my.conf parameters will be altered
	** wget the my.cnf from https://raw.githubusercontent.com/magenx/magento-mysql/master/my.cnf/my.cnf ${nf}
	(a) innodb																				--> force
	(b) query_cache_type															--> 0
	(c)	query_cache_size															--> 0
	(d) nquery_cache_limit														--> 2MB
	(e) skip-character-set-client-handshake
	(f) explicit_defaults_for_timestamp								--> 1
	(g) innodb_buffer_pool_instances									--> ${IBPS}
	(h) ninnodb_ft_min_token_size											--> 2
	(i) nft_min_word_len															--> 2
	"

	wget -qO /etc/my.cnf https://raw.githubusercontent.com/magenx/magento-mysql/master/my.cnf/my.cnf
	rpm -qa | grep -qw bc || dnf -q -y install bc >/dev/null 2>&1
	IBPS=$(echo "0.5*$(awk '/MemTotal/ { print $2 / (1024*1024)}' /proc/meminfo | cut -d'.' -f1)" | bc | xargs printf "%1.0f")
	sed -i "s/innodb = force/#innodb = force/" /etc/my.cnf
	sed -i "s/#query_cache_type = 2/query_cache_type = 0/" /etc/my.cnf
	sed -i "s/#query_cache_size = 128M/query_cache_size = 0\nquery_cache_limit = 2M/" /etc/my.cnf
	sed -i "s/#skip-character-set-client-handshake/#skip-character-set-client-handshake\nexplicit_defaults_for_timestamp=1/" /etc/my.cnf
	sed -i "s/innodb_buffer_pool_instances = 4/innodb_buffer_pool_instances = ${IBPS}/" /etc/my.cnf
	sed -i "s/innodb_buffer_pool_size = 4G/innodb_buffer_pool_size = ${IBPS}G/" /etc/my.cnf
	sed -i "s/innodb_buffer_pool_size = ${IBPS}G/innodb_buffer_pool_size = ${IBPS}G\ninnodb_ft_min_token_size=2\nft_min_word_len=2/" /etc/my.cnf
	systemctl restart mysqld.service
}


function setup_TimeZone(){
	hostnamectl set-hostname ${MAGE_DOMAIN} --static
	timedatectl set-timezone ${MAGE_TIMEZONE}
	ln  -sf /usr/share/zoneinfo/America/New_York /etc/localtime
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
	touch /etc/default/locale
cat /etc/default/locale <<EOF
LANG="en_US.utf8"
LANGUAGE="en_US:"
EOF
echo
env LC_ALL=en_US.UTF-8 >/dev/null 2>&1
export LC_ALL
localectl set-locale LANG=en_US.utf8
}

function setupPHP_PHPFPM(){
	echo -e "\n${bold}Installing php-$PHP_VERSION ${nf}"
	dnf -y  install php ${PHP_PACKAGES[@]/#/php-} ${PHP_PECL_PACKAGES[@]/#/php-}
	rpm  --quiet -q php

	echo -e "\n${bold}Following php-fpm parameters will be altered [/etc/systemd/system/php-fpm.service]:${nf}
	(a) PrivateTmp										-->true 			--> false
	(b) After.*/a																		--> OnFailure=service-status-mail@%n.service
	(c) Restart																			--> on-faiure
	(d) RestartSec																	--> 5
	(e) OnFailure.*/a																--> StartLimitBurst=5
	(f) StartLimitBurst.*/a													--> StartLimitIntervalSec=33
	"
	cp /usr/lib/systemd/system/php-fpm.service /etc/systemd/system/php-fpm.service
	sed -i "s/PrivateTmp=true/PrivateTmp=false/" /etc/systemd/system/php-fpm.service
	sed -i "/^After.*/a OnFailure=service-status-mail@%n.service" /etc/systemd/system/php-fpm.service
	sed -i "/\[Install\]/i Restart=on-failure\nRestartSec=5\n" /etc/systemd/system/php-fpm.service
	sed -i "/^OnFailure.*/a StartLimitBurst=5" /etc/systemd/system/php-fpm.service
	sed -i "/^StartLimitBurst.*/a StartLimitIntervalSec=33" /etc/systemd/system/php-fpm.service
	systemctl daemon-reload
	systemctl enable php-fpm >/dev/null 2>&1

	systemctl enable httpd >/dev/null 2>&1

	#printing the php packages installed
	rpm -qa 'php*' | awk '{print "  Installed: ",$1}'

	echo -e "\n${bold}Following php.ini paramteres will be modified:${nf}
	(a) max_execution_time												--> 7200
	(b) max_input_time														--> 7200
	(c) memory_limit 															--> 2048M
	(d) post_max_size															--> 64M
	(e) upload_max_filesize												--> 64M
	(f) expose_php																--> Off
	(g) realpath_cache_size												--> 512k
	(h) realpath_cache_ttl												--> 86400
	(i) short_open_tag														--> On
	(j)	max_input_vars														--> 50000
	(k) session.gc_maxlifetime										--> 28800
	(l) mysql.allow_persistent										--> Off
	(m)	mysqli.allow_persistent										--> Off
	(n) pm																				--> ondemand
	(o) pm.max_requests														--> 10000
	(p) pm.max_children														--> 1000
	"

	echo -e "\n${bold}Altering /etc/php.d/40-igbinary.ini and  /etc/security/limits.conf${nf}
	(a)	session.serialize_handler									--> igbinary [/etc/php.d/40-igbinary.ini]
	(b)	*         soft    nofile          700000	--> /etc/security/limits.conf
	(c) *         hard    nofile          1000000 --> /etc/security/limits.conf
	"
	cp /etc/php.ini /etc/php.ini.BACK
	sed -i 's/^\(max_execution_time = \)[0-9]*/\17200/' /etc/php.ini
	sed -i 's/^\(max_input_time = \)[0-9]*/\17200/' /etc/php.ini
	sed -i 's/^\(memory_limit = \)[0-9]*M/\12048M/' /etc/php.ini
	sed -i 's/^\(post_max_size = \)[0-9]*M/\164M/' /etc/php.ini
	sed -i 's/^\(upload_max_filesize = \)[0-9]*M/\164M/' /etc/php.ini
	sed -i 's/expose_php = On/expose_php = Off/' /etc/php.ini
	sed -i 's/;realpath_cache_size = 16k/realpath_cache_size = 512k/' /etc/php.ini
	sed -i 's/;realpath_cache_ttl = 120/realpath_cache_ttl = 86400/' /etc/php.ini
	sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php.ini
	sed -i 's/; max_input_vars = 1000/max_input_vars = 50000/' /etc/php.ini
	sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 28800/' /etc/php.ini
	sed -i 's/mysql.allow_persistent = On/mysql.allow_persistent = Off/' /etc/php.ini
	sed -i 's/mysqli.allow_persistent = On/mysqli.allow_persistent = Off/' /etc/php.ini
	sed -i 's/pm = dynamic/pm = ondemand/' /etc/php-fpm.d/www.conf
	sed -i 's/;pm.max_requests = 500/pm.max_requests = 10000/' /etc/php-fpm.d/www.conf
	sed -i 's/pm.max_children = 50/pm.max_children = 1000/' /etc/php-fpm.d/www.conf
	sed -i 's/;session.serialize_handler=igbinary/session.serialize_handler=igbinary/' /etc/php.d/40-igbinary.ini
	echo "*         soft    nofile          700000" >> /etc/security/limits.conf
	echo "*         hard    nofile          1000000" >> /etc/security/limits.conf

	#----
	mkdir -p /var/php-fpm/ && chown -R ${MAGE_WEB_USER}:${MAGE_WEB_USER} /var/php-fpm
	sed -i "s/\[www\]/\[${MAGE_WEB_USER}\]/" /etc/php-fpm.d/www.conf
	sed -i "s/user = apache/user = ${MAGE_WEB_USER}/" /etc/php-fpm.d/www.conf
	sed -i "s/group = apache/group = ${MAGE_WEB_USER}/" /etc/php-fpm.d/www.conf
	sed -i "s/;listen.owner = nobody/listen.owner = ${MAGE_WEB_USER}/" /etc/php-fpm.d/www.conf
	sed -i "s/;listen.group = nobody/listen.group = ${MAGE_WEB_USER}/" /etc/php-fpm.d/www.conf
	sed -i "s/;listen.mode = 0660/listen.mode = 0666/" /etc/php-fpm.d/www.conf
	sed -i '/PHPSESSID/d' /etc/php.ini
	sed -i "s,.*date.timezone.*,date.timezone = ${MAGE_TIMEZONE}," /etc/php.ini
	sed -i "s/session.save_handler = files/session.save_handler = redis/" /etc/php.ini
	sed -i "s/session.serialize_handler = php/session.serialize_handler = igbinary/" /etc/php.ini
	sed -i "s/listen = \/run\/php-fpm\/www.sock/listen = \/var\/php-fpm\/www.sock/" /etc/php-fpm.d/www.conf
	sed -i "s/listen.acl_users = apache,nginx/listen.acl_users = apache,nginx,${MAGE_WEB_USER}/" /etc/php-fpm.d/www.conf

cat >> /etc/php-fpm.d/www.conf <<END
;;
;; Custom pool settings
php_value[soap.wsdl_cache_dir] = /var/lib/php/wsdlcache
php_flag[display_errors] = off
php_admin_flag[log_errors] = on
php_admin_value[error_log] = /home/idera/logs/php-fpm-error.log
php_admin_value[memory_limit] = 1024M
php_admin_value[date.timezone] = ${MAGE_TIMEZONE}
END

}

function setupPHP_Opcache(){
	echo -e "\n${bold}Setting up php-opcache ${nf}
	(a) [/etc/php.d/10-opcache.ini]
	(b) setup opcache GUI viewing tool
	"
cat > /etc/php.d/10-opcache.ini <<END
zend_extension=opcache.so
opcache.enable = 1
opcache.enable_cli = 1
opcache.memory_consumption = 512
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 100000
opcache.max_wasted_percentage = 5
;opcache.use_cwd = 1
opcache.validate_timestamps = 0
;opcache.revalidate_freq = 2
;opcache.validate_permission= 1
;opcache.validate_root= 1
opcache.file_update_protection = 2
opcache.revalidate_path = 0
opcache.save_comments = 1
opcache.load_comments = 1
opcache.fast_shutdown = 1
opcache.enable_file_override = 0
opcache.optimization_level = 0xffffffff
opcache.inherited_hack = 1
opcache.blacklist_filename=/etc/php.d/opcache-default.blacklist
opcache.max_file_size = 0
opcache.consistency_checks = 0
opcache.force_restart_timeout = 60
opcache.error_log = "/var/log/php-fpm/opcache.log"
opcache.log_verbosity_level = 1
opcache.preferred_memory_model = ""
opcache.protect_memory = 0
;opcache.mmap_base = ""
;opcache.validate_root=0
;opcache.restrict_api=
;opcache.file_cache=
;opcache.file_cache_only=0
;opcache.file_cache_consistency_checks=1
;opcache.file_cache_fallback=1
;opcache.validate_permission=0
opcache.huge_code_pages=1
END

	curl -s -o /usr/local/bin/phpcachetool http://gordalina.github.io/cachetool/downloads/cachetool.phar
	chmod +x /usr/local/bin/phpcachetool

	#opcache viewing tool
	cd ${MAGE_WEB_ROOT_PATH}
	wget ${REPO_HWW}/opcache.zip
	unzip opcache.zip
	rm -rf opcache.zip
}


function webserverDocumentRootSetup(){
	mkdir -p ${MAGE_WEB_ROOT_PATH} && cd $_
	#useradd -d ${MAGE_WEB_ROOT_PATH%/*} -s /usr/bin/bash ${MAGE_WEB_USER}  >/dev/null 2>&1
	MAGE_WEB_USER_PASS=$(head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&?=+_[]{}()<>-' | fold -w 15 | head -n 1)
	echo "${MAGE_WEB_USER}:${MAGE_WEB_USER_PASS}"  | chpasswd  >/dev/null 2>&1
	chmod 755 /home/${MAGE_WEB_USER}
	chown -R ${MAGE_WEB_USER}:${MAGE_WEB_USER} ${MAGE_WEB_ROOT_PATH%/*}
	chmod 2777 ${MAGE_WEB_ROOT_PATH}
	setfacl -Rdm u:${MAGE_WEB_USER}:rwx,g:${MAGE_WEB_USER}:rwx,g::rw-,o::- ${MAGE_WEB_ROOT_PATH}
	echo "alias dir='ls -al'
	export PS1='root@${MAGE_WEB_USER}] \$PWD> '
	alias quota='quota -s'
	HISTFILE=~/.bash_history
	" >> /root/.bash_profile
	source /root/.bash_profile
cat >> /root/mage/.mage_index <<END
webshop ${MAGE_DOMAIN}    ${MAGE_WEB_ROOT_PATH}    ${MAGE_WEB_USER}   ${MAGE_WEB_USER_PASS}
END

	cd ${MAGE_WEB_ROOT_PATH}
	chown -R ${MAGE_WEB_USER}:${MAGE_WEB_USER} ${MAGE_WEB_ROOT_PATH%/*}
	chown -R ${MAGE_WEB_USER}:${MAGE_WEB_USER} ${MAGE_WEB_ROOT_PATH}
	find . -type f -exec chmod 666 {} \;
	find . -type d -exec chmod 2777 {} \;
	setfacl -Rdm u:${MAGE_WEB_USER}:rwx,g:${MAGE_WEB_USER}:r-x,o::- ${MAGE_WEB_ROOT_PATH%/*}
	setfacl -Rm u:${MAGE_WEB_USER}:rwx ${MAGE_WEB_ROOT_PATH%/*}
	usermod -G apache ${MAGE_WEB_USER}
}

function dbserverRootSetup(){
	systemctl restart mysqld.service
	echo -e "\n${bold}Database Server Root Configuration ${nf}"
	MYSQL_ROOT_PASS_GEN=$(head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&?=+_[]{}()<>-' | fold -w 15 | head -n 1)
	MYSQL_ROOT_PASS="${MYSQL_ROOT_PASS_GEN}${RANDOM}"
	MYSQL_ROOT_TMP_PASS=$(grep 'temporary password is generated for' /var/log/mysqld.log | awk '{print $NF}')
mysql --connect-expired-password -u root -p${MYSQL_ROOT_TMP_PASS}  <<EOMYSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY "${MYSQL_ROOT_PASS}";
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
exit
EOMYSQL

cat > /root/.mytop <<END
user=root
pass=${MYSQL_ROOT_PASS}
db=mysql
END

cat > /root/.my.cnf <<END
[client]
user=root
password="${MYSQL_ROOT_PASS}"
END

	MAGE_DB_PASS_GEN=$(head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&?=+_{}()<>-' | fold -w 15 | head -n 1)
	MAGE_DB_PASS="${MAGE_DB_PASS_GEN}${RANDOM}"

mysql <<EOMYSQL
CREATE USER '${MAGE_DB_USER_NAME}'@'${MAGE_DB_HOST}' IDENTIFIED BY '${MAGE_DB_PASS}';
CREATE DATABASE ${MAGE_DB_NAME};
GRANT ALL PRIVILEGES ON ${MAGE_DB_NAME}.* TO '${MAGE_DB_USER_NAME}'@'${MAGE_DB_HOST}' WITH GRANT OPTION;
exit
EOMYSQL

cat >> /root/mage/.mage_index <<END
database   ${MAGE_DB_HOST}   ${MAGE_DB_NAME}   ${MAGE_DB_USER_NAME}   ${MAGE_DB_PASS}  ${MYSQL_ROOT_PASS}
END
echo
}

function setup_phpMyAdmin(){
	PMA_FOLDER=$(head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)
	PMA_PASSWD=$(head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&?=+_[]{}()<>-' | fold -w 6 | head -n 1)
	BLOWFISHCODE=$(head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9=+_[]{}()<>-' | fold -w 64 | head -n 1)

	dnf -y install phpMyAdmin
	mv /etc/phpMyAdmin/config.inc.php /etc/phpMyAdmin/config.inc.php.back
	wget -O /etc/phpMyAdmin/config.inc.php ${REPO_HWW}/config.inc
	REPO_HWW="http://m2testbox.harriswebworks.com"
	wget -O /etc/phpMyAdmin/config.inc.php ${REPO_HWW}/config.inc
	wget -O /usr/share/phpMyAdmin/.htaccess ${REPO_HWW}/mydb/htaccess
	USER_IP=${SSH_CLIENT%% *}
	sed -i "s/.*blowfish_secret.*/\$cfg['blowfish_secret'] = '${BLOWFISHCODE}';/" /etc/phpMyAdmin/config.inc
	sed -i "s/Require local/\<IfModule mod_authz_core.c\>\nRequire all granted\n\<\/IfModule\>\n\<IfModule \!mod_authz_core.c\>\nOrder Deny,Allow\nDeny from All\n Allow from ${SERVER_IP_ADDR}\nAllow from 127.0.0.1\nAllow from ::1\n\<\/IfModule\>/" /etc/httpd/conf.d/phpMyAdmin.conf
cat >> /root/mage/.mage_index <<END
pma   mysql_${PMA_FOLDER}   mysql   ${PMA_PASSWD}
END
}

function customizeHttpdConf_importingModules(){
cat >> /etc/httpd/conf/httpd.conf <<END
#Custom httpd settings
IncludeOptional  customcnf/src/cross-origin/images.conf
IncludeOptional  customcnf/src/cross-origin/web_fonts.conf
IncludeOptional  customcnf/src/cross-origin/resource_timing.conf
IncludeOptional  customcnf/src/media_types/media_types.conf
IncludeOptional  customcnf/src/media_types/character_encodings.conf
IncludeOptional  customcnf/src/security/x-powered-by.conf
IncludeOptional  customcnf/src/security/server_software_information.conf
#IncludeOptional  customcnf/src/web_performance/compression.conf
IncludeOptional  customcnf/src/web_performance/etags.conf
IncludeOptional  customcnf/src/web_performance/cache_expiration.conf


<IfModule mod_brotli.c>
	AddOutputFilterByType BROTLI_COMPRESS text/html text/plain text/xml text/css text/javascript application/x-javascript application/javascript application/json application/x-font-ttf application/vnd.ms-fontobject image/x-icon
	BrotliFilterNote Input brotli_input_info
	BrotliFilterNote Output brotli_output_info
	BrotliFilterNote Ratio brotli_ratio_info

	#LogFormat '"%r" %{brotli_output_info}n/%{brotli_input_info}n (%{brotli_ratio_info}n%%)' brotli
	#CustomLog "|/usr/sbin/rotatelogs /home/${MAGE_WEB_USER}/logs/brotli_log.%Y%m%d 86400" brotli
	#Don't compress content which is already compressed
	SetEnvIfNoCase Request_URI 	\.(gif|jpe?g|png|swf|woff|woff2) no-brotli dont-vary
	# Make sure proxies don't deliver the wrong content
	Header append Vary User-Agent env=!dont-vary
</IfModule>
<IfModule mod_deflate.c>
	AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/x-javascript application/javascript application/json application/x-font-ttf application/vnd.ms-fontobject image/x-icon
#
#	DeflateFilterNote Input input_info
#	DeflateFilterNote Output output_info
#	DeflateFilterNote Ratio ratio_info
#	LogFormat '"%r" %{output_info}n/%{input_info}n (%{ratio_info}n%%)' deflate
#	CustomLog "|/usr/sbin/rotatelogs /home/${MAGE_WEB_USER}/logs/deflate_log.%Y%m%d 86400" deflate
#	#Don't compress content which is already compressed
#	SetEnvIfNoCase Request_URI \ \.(gif|jpe?g|png|swf|woff|woff2) no-gzip dont-vary
#	# Make sure proxies don't deliver the wrong content
#	Header append Vary User-Agent env=!dont-vary
</IfModule>

KeepAlive On
#ErrorLogFormat "[%t] [%{X-Forwarded-For}i] [%l] [pid %P] %F: %E: [client %a] %M"
Protocols h2 h2c http/1.1

<IfModule mod_headers.c>
	ServerSignature Off
	ServerTokens Prod
</IfModule>
END

	sed -i "s/LoadModule dav_module modules\/mod_dav.so/#LoadModule dav_module modules\/mod_dav.so/" /etc/httpd/conf.modules.d/00-dav.conf
	sed -i "s/LoadModule dav_fs_module modules\/mod_dav_fs.so/#LoadModule dav_fs_module modules\/mod_dav_fs.so/" /etc/httpd/conf.modules.d/00-dav.conf
	sed -i "s/LoadModule dav_lock_module modules\/mod_dav_lock.so/#LoadModule dav_lock_module modules\/mod_dav_lock.so/" /etc/httpd/conf.modules.d/00-dav.conf

	sed -i "s/LoadModule actions_module modules\/mod_actions.so/#LoadModule actions_module modules\/mod_actions.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule allowmethods_module modules\/mod_allowmethods.so/#LoadModule allowmethods_module modules\/mod_allowmethods.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule auth_digest_module modules\/mod_auth_digest.so/#LoadModule auth_digest_module modules\/mod_auth_digest.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule authn_anon_module modules\/mod_authn_anon.so/#LoadModule authn_anon_module modules\/mod_authn_anon.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule authn_dbd_module modules\/mod_authn_dbd.so/#LoadModule authn_dbd_module modules\/mod_authn_dbd.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule authn_dbm_module modules\/mod_authn_dbm.so/#LoadModule authn_dbm_module modules\/mod_authn_dbm.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule authn_socache_module modules\/mod_authn_socache.so/#LoadModule authn_socache_module modules\/mod_authn_socache.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule authz_dbd_module modules\/mod_authz_dbd.so/#LoadModule authz_dbd_module modules\/mod_authz_dbd.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule authz_dbm_module modules\/mod_authz_dbm.so/#LoadModule authz_dbm_module modules\/mod_authz_dbm.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule authz_owner_module modules\/mod_authz_owner.so/#LoadModule authz_owner_module modules\/mod_authz_owner.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule cache_module modules\/mod_cache.so/#LoadModule cache_module modules\/mod_cache.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule cache_disk_module modules\/mod_cache_disk.so/#LoadModule cache_disk_module modules\/mod_cache_disk.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule cache_socache_module modules\/mod_cache_socache.so/#LoadModule cache_socache_module modules\/mod_cache_socache.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule dbd_module modules\/mod_dbd.so/#LoadModule dbd_module modules\/mod_dbd.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule dumpio_module modules\/mod_dumpio.so/#LoadModule dumpio_module modules\/mod_dumpio.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule ext_filter_module modules\/mod_ext_filter.so/#LoadModule ext_filter_module modules\/mod_ext_filter.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule include_module modules\/mod_include.so/#LoadModule include_module modules\/mod_include.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule info_module modules\/mod_info.so/#LoadModule info_module modules\/mod_info.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule logio_module modules\/mod_logio.so/#LoadModule logio_module modules\/mod_logio.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule macro_module modules\/mod_macro.so/#LoadModule macro_module modules\/mod_macro.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule negotiation_module modules\/mod_negotiation.so/#LoadModule negotiation_module modules\/mod_negotiation.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule request_module modules\/mod_request.so/#LoadModule request_module modules\/mod_request.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule socache_dbm_module modules\/mod_socache_dbm.so/#LoadModule socache_dbm_module modules\/mod_socache_dbm.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule socache_memcache_module modules\/mod_socache_memcache.so/#LoadModule socache_memcache_module modules\/mod_socache_memcache.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule substitute_module modules\/mod_substitute.so/#LoadModule substitute_module modules\/mod_substitute.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule unique_id_module modules\/mod_unique_id.so/#LoadModule unique_id_module modules\/mod_unique_id.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule userdir_module modules\/mod_userdir.so/#LoadModule userdir_module modules\/mod_userdir.so/" /etc/httpd/conf.modules.d/00-base.conf
	sed -i "s/LoadModule vhost_alias_module modules\/mod_vhost_alias.so/#LoadModule vhost_alias_module modules\/mod_vhost_alias.so/" /etc/httpd/conf.modules.d/00-base.conf


	sed -i "s/LoadModule lbmethod_byrequests_module modules\/mod_lbmethod_byrequests.so/#LoadModule lbmethod_byrequests_module modules\/mod_lbmethod_byrequests.so/" /etc/httpd/conf.modules.d/00-proxy.conf
	sed -i "s/LoadModule lbmethod_bytraffic_module modules\/mod_lbmethod_bytraffic.so/#LoadModule lbmethod_bytraffic_module modules\/mod_lbmethod_bytraffic.so/" /etc/httpd/conf.modules.d/00-proxy.conf
	sed -i "s/LoadModule lbmethod_heartbeat_module modules\/mod_lbmethod_heartbeat.so/#LoadModule lbmethod_heartbeat_module modules\/mod_lbmethod_heartbeat.so/" /etc/httpd/conf.modules.d/00-proxy.conf
	sed -i "s/LoadModule proxy_ajp_module modules\/mod_proxy_ajp.so/#LoadModule proxy_ajp_module modules\/mod_proxy_ajp.so/" /etc/httpd/conf.modules.d/00-proxy.conf
	sed -i "s/LoadModule proxy_express_module modules\/mod_proxy_express.so/#LoadModule proxy_express_module modules\/mod_proxy_express.so/" /etc/httpd/conf.modules.d/00-proxy.conf
	sed -i "s/LoadModule proxy_fdpass_module modules\/mod_proxy_fdpass.so/#LoadModule proxy_fdpass_module modules\/mod_proxy_fdpass.so/" /etc/httpd/conf.modules.d/00-proxy.conf
	sed -i "s/LoadModule proxy_ftp_module modules\/mod_proxy_ftp.so/#LoadModule proxy_ftp_module modules\/mod_proxy_ftp.so/" /etc/httpd/conf.modules.d/00-proxy.conf
	sed -i "s/LoadModule proxy_hcheck_module modules\/mod_proxy_hcheck.so/#LoadModule proxy_hcheck_module modules\/mod_proxy_hcheck.so/" /etc/httpd/conf.modules.d/00-proxy.conf
	sed -i "s/LoadModule proxy_scgi_module modules\/mod_proxy_scgi.so/#LoadModule proxy_scgi_module modules\/mod_proxy_scgi.so/" /etc/httpd/conf.modules.d/00-proxy.conf
	sed -i "s/LoadModule proxy_uwsgi_module modules\/mod_proxy_uwsgi.so/#LoadModule proxy_uwsgi_module modules\/mod_proxy_uwsgi.so/" /etc/httpd/conf.modules.d/00-proxy.conf

	sed -i "s/LoadModule cgi_module modules\/mod_cgi.so/#LoadModule cgi_module modules\/mod_cgi.so/" /etc/httpd/conf.modules.d/01-cgi.conf

}

function customizeHttpdConf_creatingVirtualHosts(){
	echo -e "\n${bold}Inside thread of customizeHttpdConf: Creating Virtual Host${nf}
	(a) vhost											--> ${SERVER_IP_ADDR}:80
	(b) DocumentRoot							--> /home/${MAGE_WEB_USER}/public_html
	(c) Proxy
	"
cat >> /etc/httpd/conf/httpd.conf <<END

<VirtualHost ${SERVER_IP_ADDR}:80>
	ServerName ${MAGE_DOMAIN}
	ServerAlias ${MAGE_DOMAIN}
	DocumentRoot /home/${MAGE_WEB_USER}/public_html
	ErrorLog /home/${MAGE_WEB_USER}/logs/error_log
	CustomLog /home/${MAGE_WEB_USER}/logs/access_log combined

	ProxyFCGIBackendType FPM
	<Location />
	DirectoryIndex index.php index.html
</Location>
	#SetOutputFilter DEFLATE
    AddHandler "proxy:unix:/var/php-fpm/www.sock|fcgi://localhost/" php
	#AddHandler "proxy:fcgi://127.0.0.1:9000" php
<FilesMatch "\.php$">
    SetHandler "proxy:unix:/var/php-fpm/www.sock|fcgi://localhost/"
    #SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
<Directory /home/${MAGE_WEB_USER}/public_html>
  Options IncludesNOEXEC FollowSymLinks
  Require all granted
  AllowOverride All
</Directory>

</Virtualhost>
END
}

function customizeHttpdConf_exportingSSLCertificastesForHttp_Mysql(){
	echo -e "\n${bold}Inside thread of: customizeHttpdConf: Exporting SSL Certificates for {http,mysql}${nf}
	(a) /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}/ssl.cert 	--> /var/lib/mysql/ca.pem
	(b) /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}/ssl.pk			--> /var/lib/mysql/ca-key.pem
	"
	mkdir -p /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}
	mv /var/lib/mysql/ca.pem /var/lib/mysql/ca.pem.back
	mv /var/lib/mysql/ca-key.pem /var/lib/mysql/ca-key.pem.back
	cp /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}/ssl.cert /var/lib/mysql/ca.pem && cp /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}/ssl.pk /var/lib/mysql/ca-key.pem
	service mysqld restart
}

function customizeHttpdConf_SSLEngine(){
	echo -e "\n${bold}Inside Thread of: customizeHttpdConf, Customizing SSL Engine ${nf}
	(a) Setup SSLEngine for ${SERVER_IP_ADDR}:443			--> {VirtualHost, Protocols, Server Certificate, .htaccess, Directory, CustomLog,ErrorLog}
	(b) ProxyFCGIBackendType 													--> adding unix:php-fpm handler
	"

cat >> /etc/httpd/conf.d/ssl.conf <<END

<VirtualHost ${SERVER_IP_ADDR}:443>
	SSLEngine on
	SSLHonorCipherOrder on
	SSLProxyVerify none
	SSLProxyEngine On
	SSLProxyCheckPeerCN off
	SSLProxyCheckPeerName off
	SSLProxyCheckPeerExpire off
	SSLProtocol all -SSLv2 -SSLv3 -TLSv1
	SSLCipherSuite "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA 3DES !RC4 !aNULL!eNULL !LOW !MD5 !EXP !PSK !SRP !DSS !3DES !DES"

	Protocols h2 h2c http/1.1
	#Protocols h2 http/1.1
	#Protocols h2
	#Protocols http/1.1
	H2TLSWarmUpSize     0
	H2TLSCoolDownSecs   0


	#   Server Certificate:
	SSLCertificateFile /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}/ssl.cert
	#   Server Private Key:
	SSLCertificateKeyFile /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}/ssl.pk
	#   Server Certificate Chain:
	SSLCACertificatePath /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}/
	SSLCertificateChainFile /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}/bundle.crt

	ServerName ${MAGE_DOMAIN}
	ServerAlias ${MAGE_DOMAIN}
	ServerPath /home/${MAGE_WEB_USER}/public_html
	DocumentRoot /home/${MAGE_WEB_USER}/public_html

	AccessFileName .htaccess

	<Directory "/home/${MAGE_WEB_USER}/public_html">
		Options IncludesNOEXEC FollowSymLinks Indexes
		AllowOverride All
		Require all granted

      <IfModule sapi_apache2.c>
              php_admin_flag engine on
      </IfModule>

	</Directory>

	CustomLog /home/${MAGE_WEB_USER}/logs/access_log "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"
	ErrorLog /home/${MAGE_WEB_USER}/logs/error_log

	ProxyFCGIBackendType FPM
	<Location />
		DirectoryIndex index.php index.html
	</Location>
	#SetOutputFilter DEFLATE

    AddHandler "proxy:unix:/var/php-fpm/www.sock|fcgi://localhost/" php
	#AddHandler "proxy:fcgi://127.0.0.1:9000" php
	<FilesMatch "\.php$">
		SetHandler "proxy:unix:/var/php-fpm/www.sock|fcgi://localhost/"
        #SetHandler "proxy:fcgi://127.0.0.1:9000"
	</FilesMatch>
	<IfModule mod_rewrite.c>
		RewriteEngine on
		RewriteCond %{REQUEST_METHOD} ^TRACE
		RewriteRule .* - [F]
	</IfModule>

</VirtualHost>
END
}

function customizeHttpdConf(){
	echo -e "\n${bold}Customizing httpd conf using server-configs-apache.git${nf}
	** Note: this function is inheriting 4x different function, calling sequence of these function is important
	(a) server-configs-apache					--> for etc/httpd/customcnf
	(b) customizeHttpdConf_importingModules
	(c) customizeHttpdConf_creatingVirtualHosts
	(d) localdef 											--> UTF-8 Character set
	(e) customizeHttpdConf_exportingSSLCertificastesForHttp_Mysql
	(f) customizeHttpdConf_SSLEngine
	"
	cd /
	git clone https://github.com/h5bp/server-configs-apache.git >/dev/null 2>&1
	mkdir /etc/httpd/customcnf && mv server-configs-apache/* /etc/httpd/customcnf/
	mkdir -p /home/${MAGE_WEB_USER}/logs
	sed -i "s/User apache/User ${MAGE_WEB_USER}/" /etc/httpd/conf/httpd.conf
	sed -i "s/Group apache/Group ${MAGE_WEB_USER}/" /etc/httpd/conf/httpd.conf
	SERVER_IP_ADDR=$(hostname -i)

	customizeHttpdConf_importingModules
	customizeHttpdConf_creatingVirtualHosts

	localedef -c -f UTF-8 -i en_US en_US.UTF-8
	export LC_ALL=en_US.UTF-8

	customizeHttpdConf_exportingSSLCertificastesForHttp_Mysql
	sed -i "s/AddLanguage es-ES .es-ES/#AddLanguage es-ES .es-ES/" /etc/httpd/conf.d/welcome.conf
	sed -i "s/AddLanguage zh-CN .zh-CN/#AddLanguage zh-CN .zh-CN/" /etc/httpd/conf.d/welcome.conf
	sed -i "s/AddLanguage zh-HK .zh-HK/#AddLanguage zh-HK .zh-HK/" /etc/httpd/conf.d/welcome.conf
	sed -i "s/AddLanguage zh-TW .zh-TW/#AddLanguage zh-TW .zh-TW/" /etc/httpd/conf.d/welcome.conf
	sed -i "s/LanguagePriority en/#LanguagePriority en/" /etc/httpd/conf.d/welcome.conf
	sed -i "s/ForceLanguagePriority Fallback/#ForceLanguagePriority Fallback/" /etc/httpd/conf.d/welcome.conf

	customizeHttpdConf_SSLEngine
}

function dnfAutomation(){
	echo -e "\n${bold}Automating the DNF repo manager${nf}
	(a) apply_updates									--> yes
	(b) emit_via											--> email
	(c) email_from 										--> dnf-automatic@${MAGE_DOMAIN}
	(d) email_to											--> ${MAGE_ADMIN_EMAIL}
	"

	sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
	sed -i 's/emit_via = stdio/emit_via = email/' /etc/dnf/automatic.conf
	sed -i "s/email_from =.*/email_from = dnf-automatic@${MAGE_DOMAIN}/" /etc/dnf/automatic.conf
	sed -i "s/email_to = root/email_to = ${MAGE_ADMIN_EMAIL}/" /etc/dnf/automatic.conf
	systemctl enable --now dnf-automatic.timer
	SERVER_IP_ADDR=$(ip route get 1 | awk '{print $NF;exit}')
	USER_IP=${SSH_CLIENT%% *}
	USER_GEOIP=$(geoiplookup ${USER_IP} | awk 'NR==1{print substr($4,1,2)}')
}

function ftpSetup(){
	echo -e "\n${bold}Setting up FTP Server using [proftpd]${nf}
	(a) OnFailure									--> service-status-mail@%n.service
	(b) Restart										--> on-failure
	(c) RestartSec								--> 10
	(d) Checkout /root/mage/.mage
	"
	FTP_PORT=$(shuf -i 7575-7576 -n 1)
	sed -i "s/server_sftp_port/${FTP_PORT}/" /etc/proftpd.conf
	sed -i "s/server_ip_address/${SERVER_IP_ADDR}/" /etc/proftpd.conf
	sed -i "s/sftp_domain/${MAGE_DOMAIN}/" /etc/proftpd.conf
	cp /usr/lib/systemd/system/proftpd.service /etc/systemd/system/proftpd.service
	sed -i "/^After.*/a OnFailure=service-status-mail@%n.service" /etc/systemd/system/proftpd.service
	sed -i "/\[Install\]/i Restart=on-failure\nRestartSec=10\n" /etc/systemd/system/proftpd.service
	systemctl daemon-reload
	systemctl enable proftpd.service
	systemctl restart proftpd.service
cat >> /root/mage/.mage_index <<END
proftpd   ${USER_GEOIP}   ${FTP_PORT}   ${MAGE_WEB_USER_PASS}
END
}

function configureLogRotate(){
	#logrotate
	echo -e "\n${bold}Configuring Log Rotation${nf}"
cat > /etc/logrotate.d/magento <<END
${MAGE_WEB_ROOT_PATH}/var/log/*.log
{
su root root
create 660 ${MAGE_WEB_USER} ${MAGE_WEB_USER}
weekly
rotate 2
notifempty
missingok
compress
}
END
}

function logAnalysisUsingGOACCESS(){
	echo "\n${bold}Setting up goaccess for log analysis${nf}:
	** You can use it either in commandline or docker for real time log analysis
	*** Visit: https://github.com/allinurl/goaccess
	(a) in /usr/local/src
	"
	cd /usr/local/src
	git clone https://github.com/allinurl/goaccess.git >/dev/null 2>&1
	cd goaccess
	autoreconf -fi
	./configure --enable-utf8 --enable-geoip=legacy --with-openssl
	make > goaccess-make-log-file
	make install > goaccess-make-log-file
	sed -i '13s/#//' /usr/local/etc/goaccess/goaccess.conf
	sed -i '36s/#//' /usr/local/etc/goaccess/goaccess.conf
	sed -i '70s/#//' /usr/local/etc/goaccess/goaccess.conf
	sed -i "s,#ssl-cert.*,ssl-cert /etc/letsencrypt/live/${MAGE_DOMAIN}/fullchain.pem," /usr/local/etc/goaccess/goaccess.conf
	sed -i "s,#ssl-key.*,ssl-key /etc/letsencrypt/live/${MAGE_DOMAIN}/privkey.pem," /usr/local/etc/goaccess/goaccess.conf

}

function setupSendmail(){
	echo -e "\n${bold}Setting up the Sendmail${nf}
	"
	wget -qO /etc/mail/sendmail.zip ${REPO_HWW}/scripts/sendmail.zip
	unzip /etc/mail/sendmail.zip -d /etc/mail
	mv /etc/mail/sendmail/* /etc/mail/
	rm -rf /etc/mail/sendmail.zip
	sudo makemap hash /etc/mail/authinfo.db < /etc/mail/authinfo
	sudo makemap hash /etc/mail/access.db < /etc/mail/access
	sudo chmod 666 /etc/mail/sendmail.cf
	sudo m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
	sudo chmod 644 /etc/mail/sendmail.cf
	sudo makemap hash /etc/mail/virtusertable < /etc/mail/virtusertable
	systemctl daemon-reload
	systemctl restart sendmail.service
}

function setupBashProfileRC(){
	echo -e "\n${bold}Setting up the .bash_profile and .bash_rc under [$MAGE_WEB_ROOT_PATH]${nf}"
	cd ${MAGE_WEB_ROOT_PATH}
	wget ${REPO_HWW}/bash_profile.zip
	unzip bash_profile.zip
	sed -i "s/MAGEWEBUESR/${MAGE_WEB_USER}/" .bash_profile
	rm -rf bash_profile.zip


	echo "PS1='\[\e[37m\][\[\e[m\]\[\e[32m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[35m\]\h\[\e[m\]\[\e[37m\]:\[\e[m\]\[\e[36m\]\W\[\e[m\]\[\e[37m\]]\[\e[m\]$ '" >> /etc/bashrc

	mv .bash_profile ../.
	mv .bashrc ../.
	cd ../.
	source .bashrc
	source .bash_profile
}
#A.
#load font


loadFrontColorAttributes
echo -e "${bold}Initializaing the setup tool.....${nf} "
readME
#load global variables
loadGlobalVariables

mkdir -p ${MAGE_WEB_ROOT_PATH}
useradd -d ${MAGE_WEB_ROOT_PATH%/*} -s /usr/bin/bash ${MAGE_WEB_USER}  >/dev/null 2>&1

#Load Repositories
loadRepos
#WebStack Packages
loadPackages
# Debug Tools
loadDebugTools
#Print initial setups: A1/A2/A3/A4
printInitialSetups
# making the debug tools executable
makeDebugToolsExecutable
#setup time zone
setup_TimeZone
disableFirewalld

#B
installingStartingMiscServices
#setting up Percona DB
setupPercona
#configure and start mysqld service
configureMysqldService
#customize MySQL my.cnf file
customizingMySQL_my_conf

#setup PHP, PHP_FPM and checking the php installed packages
setupPHP_PHPFPM
#setup php-opcache
setupPHP_Opcache

#setup webserver document root
webserverDocumentRootSetup
#setup dbservre Root
dbserverRootSetup
#customize httpd.conf
customizeHttpdConf

systemctl daemon-reload
systemctl restart httpd.service

#setup phpMyAdmin
setup_phpMyAdmin

dnfAutomation
ftpSetup

configureLogRotate
logAnalysisUsingGOACCESS

systemctl restart httpd.service
systemctl restart php-fpm.service

setupSendmail
setupBashProfileRC


echo -e "\n${bold}>>> ===========================  INSTALLATION LOG (/root/mage/.install.log) ======================================${nf}
[shop domain]: ${MAGE_DOMAIN}
[webroot path]: ${MAGE_WEB_ROOT_PATH}
[phpmyadmin url]: ${MAGE_DOMAIN}/mysql_${PMA_FOLDER}
[phpmyadmin http auth name]: mysql
[phpmyadmin http auth pass]: ${PMA_PASSWD}
[mysql host]: ${MAGE_DB_HOST}
[mysql user]: ${MAGE_DB_USER_NAME}
[mysql pass]: ${MAGE_DB_PASS}
[mysql database]: ${MAGE_DB_NAME}
[mysql root pass]: ${MYSQL_ROOT_PASS}
[ftp port]: ${FTP_PORT}
[ftp user]: ${MAGE_WEB_USER}
[ftp password]: ${MAGE_WEB_USER_PASS}
[ftp allowed geoip]: ${USER_GEOIP}
[ftp allowed ip]: ${USER_IP}
[percona toolkit]: https://www.percona.com/doc/percona-toolkit/LATEST/index.html
[database monitor]: /usr/local/bin/mytop
[mysql tuner]: /usr/local/bin/mysqltuner
[service alert]: /usr/local/bin/service-status-mail.sh

${bold}<<< ===========================  INSTALLATION LOG (ENDS)  ======================================${nf}" | tee /root/mage/.install.log
