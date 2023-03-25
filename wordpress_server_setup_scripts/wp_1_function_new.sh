#!/bin/sh
#Define the project type

# PART-A: Load font and Readme file
#1.1
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

#1.2
function readME(){
  echo -e "\n
  ----------------------------------------------------------------
    ${bold}Tool Name: WordPress/Drupal SetupTool- Part-1${nf}
    Version: v.1.0
    Copyright: JahidulArafat@2020
  ----------------------------------------------------------------"
}

#PART-B: Define GLobal Variables, load basic packages and warming up the script
#2.1
function defineGlobalVariables(){
  echo -e "\n${bold}This Global Variable Definition Includes${nf}:
    (a) Definting the Project Type (PT)
    (b) Defining the Web User Name
  "
  Static_PT="wordpress"
  Static_MAGE_WEB_USER=ideraclinical

  read -e -p "---> Enter Project Type (PT) : " -i "${Static_PT}" PT
  read -e -p "---> Enter ${PT}_WEB_USER: " -i "${Static_MAGE_WEB_USER}" MAGE_WEB_USER

  ptRoot="/root/$PT"
}

#2.2
function loadBasicPackages(){
  BASIC_PACKAGE="ntp chrony epel-release pwgen time bzip2 tar vnstat"
  SERVICE_PACKAGE="ntpd chronyd vnstat"
}

#2.3
function loadBasicRepos(){
  REPO_CODEIT="https://repo.codeit.guru/codeit.el" #<-- not for Centos 8
}

#2.4
function warmingUpTheScript(){
  if ! grep -q "yes" $ptRoot/.prepared >/dev/null 2>&1 ; then
    echo -e "\n${bold}PART-B: Preparing script, Please wait ....($ptRoot/.prepared)${nf}
    (a) Nameserver @ \etc\resolv.conf --> 172.31.0.2
    (b) installing dnf
    (c) removing mariadb*, mariadv-libs, ftp
    (d) changing SELINUX status <-- Not reqired as it is already in disabled mode, check 'sestatus'
    (d) creating $ptRoot directory
    "
cat >> /etc/resolv.conf <<END
nameserver 172.31.0.2
END

    yum install -y dnf > /dev/null 2>&1
    dnf install 'dnf-command(config-manager)' -y > /dev/null 2>&1
    yum remove -y mariadb* mariadb-libs ftp	> /dev/null 2>&1
    #sed -i "s/^SELINUX=enforcing.*/SELINUX=disabled/" /etc/selinux/config
    #sed -i "s/^SELINUXTYPE=targeted.*/#SELINUXTYPE=targeted/" /etc/selinux/config
    mkdir -p $ptRoot

    echo "yes" > $ptRoot/.prepared
  else
    echo -e "\n${bold}Script Warming Up and Preparation was earlier done.... SKIPPING........${nf}"
  fi #Script Preparation Completes
}

#PART-C: sshd_conf reconfiguration on user defined port/paramteres and masking the firewalld
#3.1
function disableFirewalld(){
  echo -e "\n${bold}Disabling/Masking the Firewall${nf}"
	service firewalld stop
	systemctl disable firewalld
	systemctl mask --now firewalld
	chkconfig firewalld off
}

#3.2
function alterSSHDconfig(){
  echo -e "\n${bold}PART-D: Alterign the following sshd_config parameters and writing into $ptRoot/.sshport${nf}
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

  #SFTP_PORT=$1 # $1--> 7575 or any other ssh port
  read -e -p "---> Enter the new ssh port : " NEW_SSH_PORT
  sed -i "s/.*Port 22/Port ${NEW_SSH_PORT}/g" /etc/ssh/sshd_config

  echo -e "${bold}SSH PORT AND SETTINGS WERE UPDATED  -  OK${nf}"
  systemctl restart sshd.service > /dev/null 2>&1
  ss -tlp | grep sshd

  echo "yes" > $ptRoot/.sshport
  echo "SSH ${NEW_SSH_PORT}" >> $ptRoot/.sshport
  echo "SFTP ${NEW_SSH_PORT}" >> $ptRoot/.sshport
}

#PART-D: Installing Basic Packages and Upgrading Modules
#4.1
function installingBasicPackages(){
  echo -e "\n${bold}PART-C: Installing the following basic Packages:${nf}
    (a) ntp, ntpd  <-- ntp will not work in Centos 8, use chrony,chronyd, /etc/chrony.conf
    (b) Loading {$BASIC_PACKAGE}
    (g) vnstat << change the Interface from {eth0-->venet0}
  "
  yum -y install ${BASIC_PACKAGE} >/dev/null 2>&1

  for serviceName in "${SERVICE_PACKAGE[@]}"
  do
    chkconfig $serviceName on > /dev/null 2>&1
    service $serviceName start > /dev/null 2>&1
  done

  sed -i 's/Interface \"eth0\"/Interface \"venet0\"/' /etc/vnstat.conf

}

#4.2
function dnf_updateUpgradeEnableModules(){
  echo -e "\n${bold}PART-E: Update and upgrade, enable modules and config-manager${nf}
    (a) dnf: update/upgrade
    (b) install dnf-utils <-- alternative is--> dnf-plugins-core
    (c) module enable: perl 5.26
    (d) config-magaer: enable repository: PowerTools <-- bcoz epel-release packaages may depends on it
    (e) wget $REPO_CODEIT
  "
  dnf -q -y upgrade >/dev/null 2>&1
  dnf -q -y update >/dev/null 2>&1
  dnf install -y dnf-utils >/dev/null 2>&1
  dnf module enable -y perl:5.26 >/dev/null 2>&1
  dnf config-manager --set-enabled PowerTools >/dev/null 2>&1
  cd /etc/yum.repos.d && wget ${REPO_CODEIT}`rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release)`.repo >/dev/null 2>&1 # not for Centos 8
}


#PART-E: Package and Module summary (optional)
#5.1
function packMod_Summary(){
  echo -e "\n${bold}Printing the Packages and Modules Statistics${nf}
    (a) DNF repolist
    (b) DNF Modules {enabled/disabled/installed}
    (c) DNF Installed Package history + Count
  "

  #a
  echo -e "\n${bold}Checking the STAGE-1: dnf repolist${nf}"
  dnf repolist

  #b
  echo -e "\n${bold}Print DNF Modules {enabled/disabled/installed}\n--------------------------------------------${nf}"
  echo -e "\n${bold}ENABLED${nf}"
  dnf module list --enabled
  echo -e "\n${bold}DISABLED${nf}"
  dnf module list --disabled
  echo -e "\n${bold}INSTALLED${nf}"
  dnf module list --installed

  #c
  echo -e "\n${bold}Get the History of Installed Packages with DNF${nf}"
  dnf history list
  echo -e "\n${bold}List the DNF installed Packages${nf}"
  dnf list installed|wc -l
}

#5.2
function packageStatusChecker(){
  IFS=' '
  pkgName=$1
  category=$3
  PKG_STATUS=true
  PKG_INSTALLED_FILE=$ptRoot/.pkg_installed
  PKG_FAILED_FILE=$ptRoot/.pkg_failed

  counter_ins=0
  counter_failed=0

  if [ "$category" == "str" ]
  then
    read -ra pkgNameList <<< $2
  else
    pkgNameList=("${!2}") #<--- have some bug , better convert every list () into string ""
  fi

  for pkgItem in "${pkgNameList[@]}"
  do
    item=$(yum list --installed|grep $pkgItem|tee -a $PKG_INSTALLED_FILE)
    if [[ -z $item ]]
    then
      item=$(dnf list --installed|grep $pkgItem|tee -a $PKG_INSTALLED_FILE)
      if [[ -z $item ]]
      then
        PKG_STATUS=false
        ((counter_failed++))
        echo "$pkgItem" >> $PKG_FAILED_FILE
      fi
    else
      ((counter_ins++))
    fi
  done

  echo -e "[$pkgName] \t\t $PKG_STATUS \t [installed]: $counter_ins \t [failed]: $counter_failed" >> $ptRoot/.pkg_summary
  unset IFS
}

#5.3 Service status checker
function serviceStatusChecker(){
  echo -e ""
  IFS=' '
  servicePackage=$1

  for serviceName in "${servicePackage[@]}"
  do
    status=`systemctl is-active $serviceName` #<-- bug, it takes all the services at a time, results in serviceCount=1, doesnt increment the count.
    echo -e "$serviceName:\t $status" >> $ptRoot/.service_status
  done
  unset IFS
}

#PART-F: Future Instructions
function futureInstructions(){
  mkdir -p /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}
  echo -e "${bold}Please upload ssl files from /etc/httpd/conf.d/ssl/${MAGE_WEB_USER}/{ssl.crt,ssl.pk,bundle.crt}${nf}"
}

def main(){
  echo -e "Initializaing the setup tool....."

  #PART-A: Load Font and Readme file
  loadFrontColorAttributes
  readME

  #PART-B: Define some (not all) Global Variable and Warming up the Script
  #{NameServer,dnf, remove mariadb*, disable SELinux, $ptRoot dir} @$ptRoot/.prepared
  defineGlobalVariables
  loadBasicPackages
  loadBasicRepos
  warmingUpTheScript

  #PART-C: sshd_conf reconfiguration on user defined port/paramteres and masking the firewalld
  disableFirewalld
  alterSSHDconfig

  #PART-D: Installing Basic Packages and Upgrading Modules
  installingBasicPackages
  dnf_updateUpgradeEnableModules

  #PART-E: Package and Module Summary
  packMod_Summary
  packageStatusChecker "BASIC_PACKAGE" "$BASIC_PACKAGE" "str"
  serviceStatusChecker "$SERVICE_PACKAGE"

  #PART-F: Future Instuctions
  futureInstructions

}

exit;
