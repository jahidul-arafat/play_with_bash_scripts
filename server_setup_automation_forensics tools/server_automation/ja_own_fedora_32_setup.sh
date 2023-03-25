yum remove -y mariadb* mariadb-libs ftp
mkdir -p /root/mage
echo "yes" > /root/mage/.prepared


#PART-A: Defining the Global varibales
#------------------------------------------

#A1. Global Varaibles - For System [user creation, DB and DB host]
#------------------------------------------------------------------
SYS_HOSTNAME=developer.harriswebwokrs.com 
SYS_USER_NAME=jahidularafat
SYS_DB_HOST=localhost 
SYS_DB_PORT=3306
SYS_LOCALE_LAN=en_US 
SYS_PHP_VERSION=7.3 
SYS_SSH_PORT=7575
SYS_ES_VER="7.10.0"
SYS_ES_REPO="7.x"
SYS_EMAIL_NOTIFIER="jahidapon@gmail.com"

NULLIFY_ME=">/dev/null 2>&1"

#A2. Repositories will be using 
#-----------------------------------
REPO_HWW_NON_RPM="http://m2testbox.harriswebworks.com"
REPO_CODEIT_NON_RPM="https://repo.codeit.guru/codeit.el"
REPO_PERCONA_RPM="https://repo.percona.com/yum/percona-release-latest.noarch.rpm"
REPO_MYSQL_RPM="https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm"
REPO_REMI_RPM="http://rpms.famillecollet.com/enterprise/remi-release-${CENTOS_VERSION}.rpm" ## this has to be changed
REPO_CITYFAN_RPM="http://www.city-fan.org/ftp/contrib/yum-repo/city-fan.org-release-2-1.fc33.noarch.rpm"

REPO_MAGE_TMP="https://raw.githubusercontent.com/emirajbbd/Magento-2-server-installation-1/master/"

SPHINX="http://sphinxsearch.com/files/sphinx-2.2.11-1.rhel7.x86_64.rpm"

#MYSQL
REPO_MYSQL_JEMALLOC_RPM="https://cbs.centos.org/kojifiles/packages/jemalloc/5.2.1/2.el8/x86_64/jemalloc-5.2.1-2.el8.x86_64.rpm"
REPO_MYSQL_INSTALLATION_RPM="https://dev.mysql.com/get/mysql80-community-release-fc32-1.noarch.rpm"
REPO_MYSQL_TUNER_NON_RPM="https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl"
REPO_MYSQL_TOP_NON_RPM="https://raw.githubusercontent.com/magenx/Magento-mysql/master/mytop"


#A3. System Level Extra Packages Required
#-------------------------------------------
SYS_EXTRA_PACKAGE_1="autoconf automake dejavu-sans-fonts"
SYS_EXTRA_PACKAGE_2="libtidy libpcap gettext-devel recode boost boost-build boost-jam double-conversion fastlz fribidi gflags glog oniguruma tbb ed lz4 libyaml libdwarf bind-utils"
SYS_EXTRA_PACKAGE_3="e2fsprogs svn screen gcc iptraf inotify-tools iptables smartmontools net-tools mlocate unzip vim wget curl sudo bc mailx  proftpd logrotate git patch ipset strace"
SYS_EXTRA_PACKAGE_4="rsyslog ncurses-devel GeoIP GeoIP-devel geoipupdate openssl-devel ImageMagick libjpeg-turbo-utils pngcrush jpegoptim moreutils lsof net-snmp net-snmp-utils xinetd"
SYS_EXTRA_PACKAGE_5="python3-virtualenv python3-pip python3-devel ncftp postfix augeas-libs libffi-devel mod_ssl dnf-automatic yum-plugin-versionlock sysstat libuuid-devel"
SYS_EXTRA_PACKAGE_6="uuid-devel attr iotop expect postgresql-libs unixODBC gcc-c++ telnet  sendmail sendmail-devel lrzsz sendmail-cf rsyslog rsync cronie which zip unzip wget man"
SYS_EXTRA_PACKAGE_7="cyrus-sasl-plain cppunit mod_proxy_html screen"
SYS_EXTRA_PACKAGE_8="pwgen time bzip2 tar vnstat vim"
SYS_EXTRA_PACKAGE_9="openssl httpd httpd-devel file git-core gcc jpegoptim optipng zlib-devel gcc make expat-devel pcre-devel htop"
SYS_EXTRA_PACKAGE_10="apcu bcmath curl fpm intl mysql xml zip exif imagick cli opcache zip mbstring memcached" ## this is for Akeneo PIM 4

#A4. System PHP_PACKAGES_REQUIRED
#----------------------------
SYS_PHP_PACKAGES=(cli common fpm opcache gd curl mbstring bcmath soap mcrypt mysqlnd pdo xml xmlrpc intl gmp gettext-gettext phpseclib recode symfony-class-loader symfony-common tcpdf tcpdf-dejavu-sans-fonts tidy snappy lz4 maxminddb phpiredis sodium )
SYS_PHP_PECL_PACKAGES=(pecl-redis pecl-lzf pecl-geoip pecl-zip pecl-memcache pecl-oauth pecl-imagick pecl-igbinary pecl-apcu)

#A5. System PERL MODULES REQUIRED
#---------------------------
SYS_PERL_MODULES=(LWP-Protocol-https Config-IniFiles libwww-perl CPAN Template-Toolkit Time-HiRes ExtUtils-CBuilder ExtUtils-Embed ExtUtils-MakeMaker TermReadKey DBI DBD-MySQL Digest-HMAC Digest-SHA1 Test-Simple Moose Net-SSLeay devel)

#A6. GLobal varibales for File Server: fileserver.harriswebworks.com
#-------------------------------------------------------------------
FILE_SERVER_DOMAIN=fileserver.harriswebworks.com
FILE_SERVER_ROOT_PATH="/var/www/fileserver/public_html"
FILE_SERVER_DOCUMENT_ROOT=${FILE_SERVER_ROOT_PATH}/public_html
FILE_SERVER_LOG=${FILE_SERVER_ROOT_PATH}/logs
FILE_SERVER_DB_NAME=fileserver 


#PART_B: Things to do after fresh installation of Fedora 33
#-----------------------------------------------------------
<< 'MLC'
    -- Update the system
    -- Install RPM Fusion Repository
    -- Install GNOME Tweak Tools
    -- Install Dash to Dock: https://www.debugpoint.com/2020/10/10-things-to-do-fedora-33-after-install/
    -- Install additional multimedia codecs
    -- TLP for Battery health management


    Reference Links
    ---------------
    [1]
    [2]
    [3] https://mutschler.eu/linux/install-guides/fedora-post-install/
    [4] https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file
MLC


# PAsswordless sudo privileges
<< 'MLC'
    -- sudo visudo
    -- then add the following lines 
    ---------------------------------------------
    developer ALL=(root) NOPASSWD: /usr/bin/systemctl * *
    developer ALL=(ALL:ALL) NOPASSWD: ALL
    ---------------------------------------------

    How does it works
    ++++++++++++++++++
    1      2    3   4    5
    root   ALL=(ALL:ALL) ALL
    1. The first field indicates the username that the rule will apply to (root).
    2. The first “ALL” indicates that this rule applies to all hosts.
    3. This “ALL” indicates that the root user can run commands as all users.
    4. This “ALL” indicates that the root user can run commands as all groups.
    5. The last “ALL” indicates these rules apply to all commands.
MLC

sudo usermod -aG wheel username  # giving root privileges to user


#DNF update and reboot
sudo dnf upgrade --refresh
sudo dnf check
sudo dnf autoremove
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update
sudo reboot now

# Fish - A friendly Interactive shell   -- 
sudo dnf install -y fish util-linux-user
chsh -s /usr/bin/fish  # must logout
#chsh -s /usr/bin/bash #must logout after this

#RPM Fusion
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm  #RPM FUSION
sudo dnf upgrade --refresh
sudo dnf groupupdate core
sudo dnf install -y rpmfusion-free-release-tainted
sudo dnf install -y dnf-plugins-core
sudo dnf grouplist -v

# Flatpak
<< 'MLC'
    Ref: https://flatpak.org/setup/Fedora/

MLC
dnf config-manager --add-repo https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update


#Gnome Extensions app
sudo dnf install gnome-extensions-app
sudo dnf install gnome-tweak-tool 
# --- gnome extensions must use 
#https://eftalor.medium.com/12-must-have-gnome-shell-extensions-1f04f09c4466
# extension: dash to dock: https://extensions.gnome.org/extension/307/dash-to-dock/


# Install Dash to Dock (for GNOME edition)

# Install fedy
sudo dnf copr enable kwizart/fedy
sudo dnf install fedy -y

#DNF Tweaks 
cat >>  /etc/dnf/dnf.conf << END
fastestmirror=true
deltarpm=true
max_parallel_downloads=6
END

# Install additional multimedia codecs
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate sound-and-video

# TLP For battery Health 
dnf install tlp tlp-rdw
sudo tlp-stat -b # this will not work in VM

#  Always use location entry in Nautilus
#Press CTRL+l

#MS COre Fonts
#sudo dnf install lpf-mscore-fonts lpf-cleartype-fonts
sudo dnf copr enable dawid/better_fonts
sudo dnf install -y fontconfig-enhanced-defaults fontconfig-font-replacements

#Mail
sudo dnf install geary

#HOSTNAME
sudo hostnamectl set-hostname $SYS_HOSTNAME

# Tweaking web camera
sudo dnf install guvcview


# CHeck locales 
localectl status
timedatectl

#Dropbox
<< 'MLC'
    -- Download dropbox rpm from https://elearning.wsldp.com/fedora-linux/install-dropbox-fedora/
    -- then run the below command
    dnf install nautilus-dropbox-2015.10.28-1.fedora.x86_64.rpm
MLC

#git from flatpak
    







yum remove -y mariadb* mariadb-libs ftp


mkdir -p /root/mage
echo "yes" > /root/mage/.prepared




#PART_B: Updating the System and Installing extra packages 
#------------------------------------------------------------
#B1. sysupdate
dnf -y upgrade
dnf -y update
dnf install -y dnf-utils
yum --allowerasing install perl
perl -V:version ## checking the perl version
dnf repolist  ## checking the repolist 

#B2. RPM installation 
#B21. RPM_CODEIT
cd /etc/yum.repos.d && wget ${REPO_CODEIT_NON_RPM}`rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release)`.repo  ## check whether this is working or not 
cd ~
#B22. RPM_CITYFAN
yum -y install ${REPO_CITYFAN_RPM}
sed -i '0,/gpgkey/s//includepkgs=curl libmetalink libpsl libcurl libssh2\n&/' /etc/yum.repos.d/city-fan.org.repo
yum install -y yum-utils
yum-config-manager --enable city-fan.org
yum repolist

#PART-C: Installing the System Packages
#------------------------------------------------
<< 'MLC'
    -- installing all 10 sys_extra_packages 
    -- installing perl_modules 
MLC

#C1. Installing Extra Packages
dnf  -y install ${SYS_EXTRA_PACKAGE_1}
dnf  -y install ${SYS_EXTRA_PACKAGE_2}
dnf  -y install ${SYS_EXTRA_PACKAGE_3}
dnf  -y install ${SYS_EXTRA_PACKAGE_4}
dnf  -y install ${SYS_EXTRA_PACKAGE_5}
dnf  -y install ${SYS_EXTRA_PACKAGE_6}
dnf  -y install ${SYS_EXTRA_PACKAGE_7}
dnf  -y install ${SYS_EXTRA_PACKAGE_8}
dnf  -y install ${SYS_EXTRA_PACKAGE_9}
dnf  -y install ${SYS_EXTRA_PACKAGE_10}

#C2. Installing Perl Modules 


#PART-B: Network Traffic Monitor
#---------------------------------
<< 'MLC'
    -- vnstat is a console-based network traffic monitoring for LINUX
    -- for selected interface 
    -- several vnstat commands 
    -- ref: https://humdi.net/vnstat/
    -- vnstat -h # get hourly report 
MLC

ifconfig
sed -i 's/Interface \"eth0\"/Interface \"venet0\"/' /etc/vnstat.conf
echo "N/A" > /root/mage/.systest

#iptable and firewalld
service iptables stop
service firewalld stop
systemctl disable firewall
systemctl mask --now firewalld
echo "Off" > /root/mage/.firewall

#disable selinux
sestatus
vim /etc/selinux/config # disabled
#restart the pc
sestatus


#SSH
grep "Port 22" /etc/ssh/sshd_config
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
sed -i "s/.*Port 22/Port ${SSH_PORT}/g" /etc/ssh/sshd_config

sshd -t
echo $?
semanage port -a -t ssh_port_t -p tcp 7575
semanage port -l | grep ssh

curl -o /etc/motd -s ${REPO_HWW}/motd
systemctl restart sshd.service
ss -tlp | grep sshd


#sysupdate
dnf -y upgrade
dnf -y update
dnf install -y dnf-utils
yum --allowerasing install perl
perl -V:version

dnf repolist
dnf -y install openssl httpd httpd-devel file git-core gcc jpegoptim optipng zlib-devel gcc make expat-devel pcre-devel htop

yum -y install ${REPO_FAN}
sed -i '0,/gpgkey/s//includepkgs=curl libmetalink libpsl libcurl libssh2\n&/' /etc/yum.repos.d/city-fan.org.repo
yum install -y yum-utils
yum-config-manager --enable city-fan.org
yum repolist


#Extra packages
dnf install -y autoconf automake dejavu-sans-fonts
dnf install -y libtidy libpcap gettext-devel recode boost boost-build boost-jam double-conversion fastlz fribidi gflags glog oniguruma tbb ed lz4 libyaml libdwarf bind-utils
dnf install -y e2fsprogs svn screen gcc iptraf inotify-tools iptables smartmontools net-tools mlocate unzip vim wget curl sudo bc mailx  proftpd logrotate git patch ipset strace
dnf install -y rsyslog ncurses-devel GeoIP GeoIP-devel geoipupdate openssl-devel ImageMagick libjpeg-turbo-utils pngcrush jpegoptim moreutils lsof net-snmp net-snmp-utils xinetd
dnf install -y python3-virtualenv python3-pip python3-devel ncftp postfix augeas-libs libffi-devel mod_ssl dnf-automatic yum-plugin-versionlock sysstat libuuid-devel
dnf install -y uuid-devel attr iotop expect postgresql-libs unixODBC gcc-c++ telnet  sendmail sendmail-devel lrzsz sendmail-cf rsyslog rsync cronie which zip unzip wget man
dnf install -y cyrus-sasl-plain cppunit mod_proxy_html screen
dnf  -y install ${EXTRA_PACKAGES} >/dev/null 2>&1
dnf  -y install ${PERL_MODULES[@]/#/perl-} >/dev/null 2>&1
dnf install -y http://repo.okay.com.mx/centos/8/x86_64/release/libwebp-tools-1.0.0-1.el8.x86_64.rpm >/dev/null 2>&1

#vnstat
systemctl enable vnstat
service vnstat start
netstat -i
vnstat -i enp1s0

#saslauthd
chkconfig saslauthd on
service saslauthd start
saslauthd -v

systemctl is-enabled httpd
systemctl is-active httpd
chkconfig httpd on
which htpasswd
echo "yes" > /root/mage/.sysupdate

#PerconaMySQL-8
dnf install -y https://cbs.centos.org/kojifiles/packages/jemalloc/5.2.1/2.el8/x86_64/jemalloc-5.2.1-2.el8.x86_64.rpm

#mysql8 on fedora
------------------
dnf -y install https://dev.mysql.com/get/mysql80-community-release-fc32-1.noarch.rpm
dnf -y install mysql-community-server
systemctl restart mysqld
grep 'A temporary password' /var/log/mysqld.log |tail -1
mysql_secure_installation
mysql -u root -p
mysql > SET GLOBAL validate_password.policy = 0;
mysql > SET GLOBAL validate_password.length = 4;
mysql > SHOW VARIABLES LIKE 'validate_password.%';
mysql > ALTER USER 'root'@'localhost' IDENTIFIED BY 'magento';
mysql > flush privileges;


#mysqld-01
---------------
vim /etc/systemd/system/multi-user.target.wants/mysqld.service
> RestartSec=5
systemctl disable mysqld # added by me, it will disable the exisiting mysqld and help me to connect to the modified mysqld
systemctl daemon-reload
systemctl enable mysqld
ll /etc/systemd/system

wget -O /etc/my.cnf https://raw.githubusercontent.com/magenx/magento-mysql/master/my.cnf/my.cnf
rpm -qa | grep -w bc || dnf -y install bc
IBPS=$(echo "0.5*$(awk '/MemTotal/ { print $2 / (1024*1024)}' /proc/meminfo | cut -d'.' -f1)" | bc | xargs printf "%1.0f")
sed -i "s/innodb = force/#innodb = force/" /etc/my.cnf
sed -i "s/#query_cache_type = 2/query_cache_type = 0/" /etc/my.cnf
sed -i "s/#query_cache_size = 128M/query_cache_size = 0\nquery_cache_limit = 2M/" /etc/my.cnf
sed -i "s/#skip-character-set-client-handshake/#skip-character-set-client-handshake\nexplicit_defaults_for_timestamp=1/" /etc/my.cnf
sed -i "s/innodb_buffer_pool_instances = 4/innodb_buffer_pool_instances = ${IBPS}/" /etc/my.cnf
sed -i "s/innodb_buffer_pool_size = 4G/innodb_buffer_pool_size = ${IBPS}G/" /etc/my.cnf
sed -i "s/innodb_buffer_pool_size = ${IBPS}G/innodb_buffer_pool_size = ${IBPS}G\ninnodb_ft_min_token_size=2\nft_min_word_len=2/" /etc/my.cnf


wget -O /usr/local/bin/mysqltuner ${MYSQL_TUNER}
wget -O /usr/local/bin/mytop ${MYSQL_TOP}
chmod +x /usr/local/bin/mytop
mytop --prompt

cat > /etc/sysconfig/mysql <<EOF
LD_PRELOAD=/usr/lib64/libjemalloc.so.2
EOF

cat > /root/.mytop <<END
user=root
pass=magento
db=mysql
END
cat > /root/.my.cnf <<END
[client]
user=root
password="magento"
END


##DB_User
mysql>
SET GLOBAL validate_password.policy = 0;
SET GLOBAL validate_password.length = 4;
SHOW VARIABLES LIKE 'validate_password.%';

CREATE USER 'magento'@'localhost' IDENTIFIED BY 'magento';
CREATE DATABASE m2d_boundless;
CREATE DATABASE m2d_checkout;
CREATE DATABASE m2d_sales;

grant all privileges on m2d_boundless.* TO magento@'localhost' with grant option;
grant all privileges on m2d_checkout.* TO magento@'localhost' with grant option;
grant all privileges on m2d_sales.* TO magento@'localhost' with grant option;

SHOW GRANTS FOR 'root'@'localhost';
SHOW GRANTS FOR 'magento'@'localhost';

show variables like 'have_ssl';
status;
exit

@as user:developer
-------------------
cat > ~/.mytop <<END
user=magento
pass=magento
db=mysql
END
cat > ~/.my.cnf <<END
[client]
user=magento
password="magento"
END

mytop
echo "yes" > /root/mage/.mysql8

#PHP
#dnf install -y ${REPO_REMI}
dnf install https://rpms.remirepo.net/fedora/remi-release-33.rpm
dnf repolist
dnf module enable php:remi-${PHP_VERSION} -y
dnf module list --enabled
dnf config-manager --set-enabled remi
dnf help config-manager
rpm -q remi-release
dnf -y  install php ${PHP_PACKAGES[@]/#/php-} ${PHP_PECL_PACKAGES[@]/#/php-}
dnf -y  install php ${PHP_AKENEO_PACKAGES[@]/#/php-}
rpm -q php
cp /usr/lib/systemd/system/php-fpm.service /etc/systemd/system/php-fpm.service
sed -i "s/PrivateTmp=true/PrivateTmp=false/" /etc/systemd/system/php-fpm.service
sed -i "/^After.*/a OnFailure=service-status-mail@%n.service" /etc/systemd/system/php-fpm.service
sed -i "/\[Install\]/i Restart=on-failure\nRestartSec=5\n" /etc/systemd/system/php-fpm.service
sed -i "/^OnFailure.*/a StartLimitBurst=5" /etc/systemd/system/php-fpm.service
sed -i "/^StartLimitBurst.*/a StartLimitIntervalSec=33" /etc/systemd/system/php-fpm.service
systemctl daemon-reload
systemctl enable php-fpm
systemctl enable httpd
rpm -qa 'php*' | awk '{print "  Installed: ",$1}'
php -m
php -m|wc -l
echo "yes" > /root/mage/.php

#Redis
yum install -y redis pcre-devel
systemctl enable redis
systemctl start redis && redis-cli config set save "" && redis-cli config set appendonly no && redis-cli config set maxmemory 256mb && redis-cli config set maxmemory-policy allkeys-lru && redis-cli config rewrite && redis-cli shutdown  && systemctl start redis && redis-cli config get save

echo "yes" > /root/mage/.redis

#JAVA
dnf install -y java
java --version
which java

#ES--. RPM CHEATSHETT https://guides.library.illinois.edu/data_encryption/gpgcheatsheet
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
ls /etc/pki/rpm-gpg/
rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n'
rpm -qi gpg-pubkey-\* | grep -E ^Packager


cat > /etc/yum.repos.d/elastic.repo << EOF
[elasticsearch-${ELKREPO}]
name=Elasticsearch repository for ${ELKREPO} packages
baseurl=https://artifacts.elastic.co/packages/${ELKREPO}/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
dnf -y install --enablerepo=elasticsearch-${ELKREPO} elasticsearch-${ELKVER}
dnf module list --enabled
rpm  -q elasticsearch

sed -i "s/.*network.host.*/network.host: 127.0.0.1/" /etc/elasticsearch/elasticsearch.yml
sed -i "s/.*http.port.*/http.port: 9200/" /etc/elasticsearch/elasticsearch.yml
cat >> /etc/elasticsearch/elasticsearch.yml <<END
indices.query.bool.max_clause_count: 10024
END

sed -i "s/-Xms.*/-Xms1g/" /etc/elasticsearch/jvm.options
sed -i "s/-Xmx.*/-Xmx1g/" /etc/elasticsearch/jvm.options
chown -R :elasticsearch /etc/elasticsearch/*

cd /usr/share/elasticsearch
bin/elasticsearch-plugin install analysis-phonetic
bin/elasticsearch-plugin install analysis-icu

systemctl daemon-reload
systemctl status elasticsearch
systemctl enable elasticsearch.service
systemctl restart elasticsearch.service
curl -XGET http://localhost:9200
curl localhost:9200/_cat/health
curl -XGET localhost:9200/_cat/indices

#PHP-Tweaking
--------------
#php-opcache
-------------
cp /etc/php.d/10-opcache.ini /etc/php.d/10-opcache.ini.bak
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


#php.ini
--------
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

echo "Yes" > /root/mage/.php-tweaking


#WebUser Creation

#httpd
#------


mkdir -p /home/${MAGE_WEB_USER}/logs


sed -i "s/User apache/User ${MAGE_WEB_USER}/" /etc/httpd/conf/httpd.conf
sed -i "s/Group apache/Group ${MAGE_WEB_USER}/" /etc/httpd/conf/httpd.conf


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


<I