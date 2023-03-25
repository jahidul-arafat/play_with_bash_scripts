#!/bin/bash
# This software is developed by Jahid Arafat, DevOps Engineer, Harris WEb Works, CT, USA

## PART-A: GLOBAL VARIABLES
#A1- OS and Service Level Global Variables
OS_NAME=fedora
OS_VERSION=33_32
PHP_VERSION=7.4
SSH_PORT=7575

#A2- Company related information
COMPANY_NAME=harriswebworks

#getting the username to setup the hostname
read -p "Enter Your Own Name: " username
HOSTNAME=$USERNAME.$COMPANY_NAME.com
DEFAULT_DOMAIN_NAME_EXTENSION=harriswebworks.com

#Magento Related info
MAGE_WEB_USER=developer #this user will have the apache(www-data) permission

#GLOBAL VARIABLES- DB - BASIC
MAGE_DB_USER=magento
MAGE_DB_HOST=localhost
MAGE_DB_NAME=developer

#A3- Global Variables- BOUNDLESS SETUP
MAGE_DB_NAME_BOUNDLESS=(m2d_boundless m2d_category m2d_sales)

#A4- Global Variable- Any Magento Site Setup
function MagentoSiteCreation(){
  printf "Entering into the Magento Site Creation Wizard\n--------------------------------------------\n"

  #1. web domain name
  read -p "Enter Project Name: [i.e. BOUNDLESS/DARTERGROUP]:" projectName
  domainName="${projectName,,}.$DEFAULT_DOMAIN_NAME_EXTENSION"

  #2 Database- Cluster/Singular
  read -p "Do you want to create Database [yN]: " dbExistsStatus
  if [[ "${dbExistsStatus},," != "n"  ]]
  then
    read -p "Do you need a Cluster/Singular Database [cS]: " databaseType
    if [[ "${databaseType,,}" == "c" ]]
    then
      read -p "Enter Database Numbers [2...4]: " databaseNumber
    else
      databaseNumber=1
    fi
  else
    echo -e "::: DATABASE CREATION SKIPPING :::"
  fi

  declare -a dbNameList=()

  for ((dbCount=1;dbCount<=$databaseNumber;dbCount=dbCount+1 ))
  do
    read -p "Enter Database Name_$dbCount: " dbName
    dbNameList+=($dbName)
  done

  for dbName in "${dbNameList[@]}";do
    DBCreation $dbName "magento";
  done

  #3 Project Directory creation
  MAGE_PROJECT_WEB_ROOT_PATH=/var/www/${projectName,,}
  if [ ! -d "${MAGE_PROJECT_WEB_ROOT_PATH}" ];then
    mkdir ${MAGE_PROJECT_WEB_ROOT_PATH}
  else
    echo -e "${MAGE_PROJECT_WEB_ROOT_PATH} already exists, SKIPPING ..."
  fi

  mkdir ${MAGE_PROJECT_WEB_ROOT_PATH}/public_html
  mkdir ${MAGE_PROJECT_WEB_ROOT_PATH}/logs
  chown -R ${MAGE_WEB_USER}:${MAGE_WEB_USER} ${MAGE_PROJECT_WEB_ROOT_PATH%/*}
  chmod 2777 ${MAGE_WEB_ROOT_PATH}
  setfacl -Rdm u:${MAGE_WEB_USER}:rwx,g:${MAGE_WEB_USER}:rwx,g::rw-,o::- ${MAGE_PROJECT_WEB_ROOT_PATH}

  #4 Git clone /or basic luma
  read -p "Do you want to use git to setup your project [yN]: " gitStatus
  if [[ "${gitStatus,,}" != "n" ]];then
    cd ${MAGE_PROJECT_WEB_ROOT_PATH}/public_html
    read -p "Enter your git repositoy in format [companyName/gitrepo.git]: " gitRepo
    git clone git@github.com:$gitRepo .
  else
    echo -e "Current Version only Supporting Magento setup using git"
    exit 1
  fi

  # Setup file permissions
  fixingFilePermission $MAGE_PROJECT_WEB_ROOT_PATH

}

function DBCreation(){
  tmpDBName=$1
  tmpDBUserName=$2
  echo -e "Creating Database: $1"
mysql <<EOMSQL
CREATE DATABASE $tmpDBName;
GRANT ALL PRIVILEGES ON $tmpDBName.* TO $tmpDBUserName@'localhost' with GRANT OPTION;
exit
EOMSQL
}

function fixingFilePermission(){
  echo -e "Fixing the file permissions\n"
  tmp_MAGE_PROJECT_WEB_ROOT_PATH=$1
  cd ${tmp_MAGE_PROJECT_WEB_ROOT_PATH}
  find . -type f -exec chmod 666 {} \;
  find . -type d -exec chmod 2777 {} \;
  setfacl -Rdm u:${MAGE_WEB_USER}:rwx,g:${MAGE_WEB_USER}:r-x,o::- ${tmp_MAGE_PROJECT_WEB_ROOT_PATH%/*}
  setfacl -Rm u:${MAGE_WEB_USER}:rwx ${tmp_MAGE_PROJECT_WEB_ROOT_PATH%/*}
  cd ${tmp_MAGE_PROJECT_WEB_ROOT_PATH}/public_html
  find . -type d -print0 | xargs -r0 chmod 777 && find . -type f -print0 | xargs -r0 chmod 666 && chmod u+x bin/magento
}



#Monitoring tools
function NetData(){
  bash <(curl -Ss https://my-netdata.io/kickstart.sh)
  systemctl restart netdata

}


#bashrc tool list
fixingFilePermission_bashrc(){
  read -p "Enter your web user name [i.e. developer]: " MAGE_WEB_USER
  read -p "Enter your magento root path [i.e. /var/www/your_project_name]: " MAGE_PROJECT_WEB_ROOT_PATH

  echo -e "checking if the requesting username and root path exists\n"

  if id "$MAGE_WEB_USER" >/dev/null 2>&1; then
        echo "user exists"
  else
        echo "user does not exist"
        exit 1
  fi

  if [[ ! -d $MAGE_PROJECT_WEB_ROOT_PATH/public_html && ! -d $$MAGE_PROJECT_WEB_ROOT_PATH/logs ]];then
    echo -e "The two basic directory is missing:\n
      (1) $MAGE_PROJECT_WEB_ROOT_PATH/public_html
      (2) $MAGE_PROJECT_WEB_ROOT_PATH/logs
    "
    exit 1
  fi

  cd $MAGE_PROJECT_WEB_ROOT_PATH
  find . -type f -exec chmod 666 {} \;
  find . -type d -exec chmod 2777 {} \;
  setfacl -Rdm u:${MAGE_WEB_USER}:rwx,g:${MAGE_WEB_USER}:r-x,o::- ${MAGE_PROJECT_WEB_ROOT_PATH%/*}
  setfacl -Rm u:${MAGE_WEB_USER}:rwx ${MAGE_PROJECT_WEB_ROOT_PATH%/*}
  cd ${MAGE_PROJECT_WEB_ROOT_PATH}/public_html
  find . -type d -print0 | xargs -r0 chmod 777 && find . -type f -print0 | xargs -r0 chmod 666

  read -p "Giving execute permission to following directories and files \n
    (1) bin/magento
    (2) cm_redis_tools/rediscli.php
    (3) webp-watchers.sh

    Do you want to proceed [yN]:
  " executePermission

  if [[ ${executePermission} == "y" ]];then
    if [[ -d ${MAGE_PROJECT_WEB_ROOT_PATH}/public_html/bin/magento ]];then
      chmod u+x bin/magento
    fi

    if [[ -d ${MAGE_PROJECT_WEB_ROOT_PATH}/public_html/cm_redis_tools ]];then
      chmod u+x cm_redis_tools/rediscli.php
    fi

    if [[ -f ${MAGE_PROJECT_WEB_ROOT_PATH}/public_html/webp-watchers.sh ]];then
      chmod u+x webp-watchers.sh
    fi
  else
    echo -e "*******WARNING: Skipping the execute Permissions and Might results in Site Interruption....."
  fi

}


function getBrowserActivityOfUser(){
  read -p "What is your OS: \n[1]. Ubuntu\n[2].Fedora\nChoose[1 or 2]: " osDetected
  if [[ $osDetected == 1 ]];then
    sudo apt-get install sqlite3
  elif [[ $osDetected == 2 ]]; then
    sudo dnf install sqlite3
  fi

  echo -e "Generating the browser activity for both the Chrome and Mozilla FIrefox"

}



