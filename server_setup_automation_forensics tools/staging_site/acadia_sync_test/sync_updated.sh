#!/bin/bash
# This software is developed by Jahid Arafat, DevOps Engineer, Harris Web Works,CT,USA.


###################################################################################
###                              GLOBAL VARIABLES                               ###
###################################################################################

#OS
CENTOS_VERSION=8

#TOOL
TOOL_VERSION=1.0

#PHP
PHP_VERSION=7.3

MYSQL_HOST='localhost';
MYSQL_ROOT_USER='root';
MYSQL_ROOT_PASSWORD='Bz@?cuN)UO%utYW18533';
MYSQL_WEB_USER='acadia';
MYSQL_WEB_PASSWORD='<ZAJ%HTh}X9>$ja15040'
MYSQL_PORT=3306;
MYSQL_DB_SUFFIX='wp_';
MYSQL_CONF_FILENAME='.my.cnf';

DBNAME_STAGING='acadia_wp_dev_init';
DBNAME_PROD='prod_1_06_02_2020_14_43_37';

#DBNAME_PROD=acadia_live;
#DBNAME_STAGING=acadia_staging;


SOURCE_DB=$DBNAME_STAGING
DESTINATION_DB=$DBNAME_PROD


WEBUSER=acadia
WEBUSER_ID=$(getent passwd $(grep -oP '^Uid:\s*\K\d+' /proc/$$/status) | cut -d: -f3)
BACKUP_DIR_MAIN="/home/${WEBUSER}/SYNC_BACKUP"
SYNC_DIR_PREFIX=SYNC

#Document root for Zipping 
DOCUMENT_ROOT_MAIN=/home/${WEBUSER}/public_html/corporate
DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY=prod_1_06_02_2020_14_43_37
DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY=acadia_wp_dev_init
DOCUMENT_ROOT_LIVE=${DOCUMENT_ROOT_MAIN}/$DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY
DOCUMENT_ROOT_STAGING=$DOCUMENT_ROOT_MAIN/$DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY

#Update Database after Sync 
#UNWANTED_STRING='//staging.acadia-pharm.com'
UNWANTED_STRING='//stagingacadia.harriswebworks.com'
WANTED_STRING='//liveacadia.harriswebworks.com'
PHP_DB_TEXT_REPLACE_SCRIPT='string_to_replace_db.php'
delimiter=':'

#Sync system details 
#SYNC_SOURCE="https://staging.acadia-pharm.com"
#SYNC_DESTINATION="https://www.acadia-pharm.com"

SYNC_SOURCE="https://stagingacadia.harriswebworks.com"
SYNC_DESTINATION="https://liveacadia.harriswebworks.com"

#logger
SCRIPT_LOG=/home/${WEBUSER}/sync_out.log
SPACE_2_ARROW="--"
SPACE_4_ARROW="----"

#sync system test temporary files
SYNC_SYS_TEST_TMP_FILE="sync_sys_test_tmp_file.txt"
SYNC_SYS_HEADER="SYSTEM REQUIREMENT,DETAILS"
SYNC_CHECKSUM_TMP_FILE="sync_checksum_tmp_file.txt"
SYNC_CHECKSUM_HEADER="TABLE_NAME,${DBNAME_STAGING},${DBNAME_PROD},Status"

#for table exists report
SYNC_TABLE_EXISTS_TMP_FILE="sync_check_table_exists.txt"
SYNC_TABLE_EXISTS_HEADER="TABLE_NAME,[SOURCE_DB]: $SOURCE_DB,[DESTINATION_DB]: $DESTINATION_DB"

ERRONOUS_DB_TABLE='wp_posts'
ERRONOUS_DB_TABLE_COLUMN='post_date_gmt'

touch ${SYNC_SYS_TEST_TMP_FILE}
echo $SYNC_SYS_HEADER > ${SYNC_SYS_TEST_TMP_FILE}

touch $SYNC_CHECKSUM_TMP_FILE
echo $SYNC_CHECKSUM_HEADER > $SYNC_CHECKSUM_TMP_FILE

touch $SYNC_TABLE_EXISTS_TMP_FILE
echo $SYNC_TABLE_EXISTS_HEADER > $SYNC_TABLE_EXISTS_TMP_FILE

#Percona
PERCONA_SERVER="percona-server-server"
PERCONA_CLIENT="percona-server-client"
PERCONA_TOOLKIT="percona-toolkit"
PERCONA_XTRABACKUP="percona-xtrabackup-80"

###################################################################################
###                                    MY NOTES                                 ###
###################################################################################
# Note 01: rsync -avpP # this rsync options solved the major sync problem which was earlier failed of -avu and -zavh options.
# Note 02: Creating a post might create a draft having invalid date time format. So clean these entries before sync.


###################################################################################
###                                    COLORS                                   ###
###################################################################################

RED="\e[31;40m"
GREEN="\e[32;40m"
YELLOW="\e[33;40m"
WHITE="\e[37;40m"
BLUE="\e[0;34m"
### Background
DGREYBG="\t\t\e[100m"
BLUEBG="\e[1;44m"
REDBG="\t\t\e[41m"
### Styles
BOLD="\e[1m"
### Reset
RESET="\e[0m"


#Text Formatting 
bold=$(tput bold)
normal=$(tput sgr0)

###################################################################################
###                            ECHO MESSAGES DESIGN                             ###
###################################################################################

function WHITETXT() {
        MESSAGE=${@:-"${RESET}Error: No message passed"}
        echo -e "\t\t${WHITE}${MESSAGE}${RESET}"
}
function BLUETXT() {
        MESSAGE=${@:-"${RESET}Error: No message passed"}
        echo -e "\t\t${BLUE}${MESSAGE}${RESET}"
}
function REDTXT() {
        MESSAGE=${@:-"${RESET}Error: No message passed"}
        echo -e "\t\t${RED}${MESSAGE}${RESET}"
}
function GREENTXT() {
        MESSAGE=${@:-"${RESET}Error: No message passed"}
        echo -e "\t\t${GREEN}${MESSAGE}${RESET}"
}
function YELLOWTXT() {
        MESSAGE=${@:-"${RESET}Error: No message passed"}
        echo -e "\t\t${YELLOW}${MESSAGE}${RESET}"
}
function BLUEBG() {
        MESSAGE=${@:-"${RESET}Error: No message passed"}
        echo -e "${BLUEBG}${MESSAGE}${RESET}"
}


###################################################################################
###                            PROGRESS BAR AND PAUSE                           ###
###################################################################################

function pause() {
   read -p "$*"
}
function start_progress {
  while true
  do
    echo -ne "#"
    sleep 1
  done
}
function quick_progress {
  while true
  do
    echo -ne "#"
    sleep 0.05
  done
}
function long_progress {
  while true
  do
    echo -ne "#"
    sleep 3
  done
}
function stop_progress {
kill $1
wait $1 2>/dev/null
echo -en "\n"
}



###################################################################################
###                            ARROW KEYS UP/DOWN MENU                          ###
###################################################################################

updown_menu () {
i=1;for items in $(echo $1); do item[$i]="${items}"; let i=$i+1; done
i=1
echo
echo -e "\n---> Use up/down arrow keys then press Enter to select $2"
while [ 0 ]; do
  if [ "$i" -eq 0 ]; then i=1; fi
  if [ ! "${item[$i]}" ]; then let i=i-1; fi
  echo -en "\r                                 " 
  echo -en "\r${item[$i]}"
  read -sn 1 selector
  case "${selector}" in
    "B") let i=i+1;;
    "A") let i=i-1;;
    "") echo; read -sn 1 -p "To confirm [ ${item[$i]} ] press y or n for new selection" confirm
      if [[ "${confirm}" =~ ^[Yy]$  ]]; then
        printf -v "$2" '%s' "${item[$i]}"
        break
      else
        echo
        echo -e "\n---> Use up/down arrow keys then press Enter to select $2"
      fi
      ;;
  esac
done }

clear


###################################################################################
###                            Logger Setup                                     ###
###################################################################################
touch $SCRIPT_LOG

function SCRIPTENTRY(){
 timeAndDate=`date`
 script_name=`basename "$0"`
 script_name="${script_name%.*}"
 echo "[$timeAndDate] [DEBUG]  > $script_name $FUNCNAME" >> $SCRIPT_LOG
}

function SCRIPTEXIT(){
 script_name=`basename "$0"`
 script_name="${script_name%.*}"
 echo "[$timeAndDate] [DEBUG ]  < $script_name $FUNCNAME" >> $SCRIPT_LOG
}

function ENTRY(){
 local cfn="${FUNCNAME[1]}"
 timeAndDate=`date`
 echo "[$timeAndDate] [DEBUG ]  > $cfn $FUNCNAME" >> $SCRIPT_LOG
}

function EXIT(){
 local cfn="${FUNCNAME[1]}"
 timeAndDate=`date`
 echo "[$timeAndDate] [DEBUG ]  < $cfn $FUNCNAME" >> $SCRIPT_LOG
}

function INFO(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [INFO  ]  $msg" >> $SCRIPT_LOG
}

function PASSED(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [PASSED]  $msg" >> $SCRIPT_LOG
}

function DEBUG(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
 echo "[$timeAndDate] [DEBUG ]  $msg" >> $SCRIPT_LOG
}

function ERROR(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [ERROR ]  $msg" >> $SCRIPT_LOG
}

###################################################################################
###                             LOGGER: START                                   ###
###################################################################################
#logger starts
SCRIPTENTRY
ENTRY
INFO "WELCOME TO HWW SCRIPT LOGGER V.$TOOL_VERSION"


###################################################################################
###                            PRINT TABLE FORMATTED DATA                       ###
###################################################################################

function printTable()
{
    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                # Add Header Or Body

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines()
{
    local -r content="${1}"

    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString()
{
    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString()
{
    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString()
{
    local -r string="${1}"

    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}


###################################################################################
###                              Functions for Database Restore                 ###
###################################################################################

# Extract files from .gz archives:
function gzip_extract {

  for filename in *.gz
    do
      echo "extracting $filename"
      gzip -d $filename
    done
}

#restoring the database
function dbcreate_restore {
  # $1->$dbname $2-> $ROOT_USER $3-> $ROOT_PASS $4-> $USER $5->$HOST $6-> $filename $7->$PASS
  echo -e "Creating DB: $1"
  mysqladmin create $1 -u $2 -p$3
  mysql -Bse "GRANT ALL PRIVILEGES ON $1.* TO $4@'$5' with GRANT OPTION" -u $2 -p$3
  echo "Importing DB: $1 from $6"
  mysql $1 < $6 -u $4 -p$7
  
  #mysqladmin create $dbname -u $ROOT_USER -p$ROOT_PASS
  #mysql -Bse "GRANT ALL PRIVILEGES ON $dbname.* TO $USER@'$HOST' with GRANT OPTION" -u $ROOT_USER -p$ROOT_PASS
  #echo "Importing DB: $dbname from $filename"
  #mysql $dbname < $filename -u $USER -p$PASS
}


###################################################################################
###                              CHECK IF WE CAN RUN IT                         ###
###################################################################################
INFO "SYSTEM REQUIREMENT TEST" #logger
DEBUG "${SPACE_2_ARROW}Web User: ${WEBUSER}, EUID: ${EUID}" #logger
echo "Webuser,${WEBUSER}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo "Webuser ID,${EUID}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo
echo
# webuser- acadia?

if [[ ${EUID} -ne ${WEBUSER_ID} ]]; then
  echo
  REDTXT "ERROR: THIS SCRIPT MUST BE RUN AS ${WEBUSER_ID}!"
  YELLOWTXT "------> USE WEB-USER PRIVILEGES."
  ERROR "${SPACE_4_ARROW}This script must run as ${WEBUSER}:${WEBUSER_ID}" #logger
  exit 1
else
  GREENTXT "PASS: ${WEBUSER}!"
  PASSED "${SPACE_4_ARROW}PASS: ${WEBUSER}!" #logger
fi


# network is up?
INFO "${SPACE_2_ARROW}Checking network status" #logger
host1=google.com
host2=github.com

RESULT=$(((ping -w3 -c2 ${host1} || ping -w3 -c2 ${host2}) > /dev/null 2>&1) && echo "up" || (echo "down" && exit 1))
echo "Network Status,${RESULT}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile

if [[ ${RESULT} == up ]]; 
then
  GREENTXT "PASS: NETWORK IS UP. GREAT, LETS START!"
  PASSED "${SPACE_4_ARROW}PASS: NETWORK IS UP. GREAT, LETS START!" #logger
else
  echo
  REDTXT "ERROR: NETWORK IS DOWN?"
  YELLOWTXT "------> PLEASE CHECK YOUR NETWORK SETTINGS."
  ERROR "${SPACE_4_ARROW}NETWORK IS DOWN" #logger
  echo
  echo
  exit 1
fi


# do we have CentOS?
echo "OS Version,CentOS ${CENTOS_VERSION}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
INFO "${SPACE_2_ARROW}OS Version Check" #logger
if grep "CentOS.* ${CENTOS_VERSION}\." /etc/centos-release  > /dev/null 2>&1; then
  GREENTXT "PASS: CENTOS RELEASE ${CENTOS_VERSION}"
  PASSED "${SPACE_4_ARROW}PASS: CENTOS RELEASE ${CENTOS_VERSION}" #logger
else
  echo
  REDTXT "ERROR: UNABLE TO FIND CENTOS ${CENTOS_VERSION}"
  YELLOWTXT "------> THIS CONFIGURATION FOR CENTOS ${CENTOS_VERSION}"
  ERROR "${SPACE_4_ARROW}UNABLE TO FIND CENTOS ${CENTOS_VERSION}" #logger
  echo
  exit 1
fi


# quick sync system test
INFO "${SPACE_2_ARROW}QUICK SYNC SYSTEM TEST" #logger
GREENTXT "PATH: ${PATH}"
echo "PATH,${PATH}">> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo
echo
BLUEBG "~    QUICK SYNC SYSTEM TEST    ~"
echo "-------------------------------------------------------------------------------------"
echo
now=$(date +"%m/%d/%Y/%r")
tram=$( free -m | awk 'NR==2 {print $2}' )   

#check php version
PHP_VERSION_FETCHED=$(php -r "echo PHP_VERSION;" | grep --only-matching --perl-regexp "7.\d+")
echo "PHP,$PHP_VERSION_FETCHED">> $SYNC_SYS_TEST_TMP_FILE #tmpfile

#check percona version
PERCONA_SERVER_VERSION=$(rpm -qi $PERCONA_SERVER|grep -i version|cut -d':' -f2)
PERCONA_CLIENT_VERSION=$(rpm -qi $PERCONA_CLIENT|grep -i version|cut -d':' -f2)
echo "PERCONA SERVER,$PERCONA_SERVER_VERSION" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo "PERCONA CLIENT,$PERCONA_CLIENT_VERSION" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile

#check if percona toolkit 
PERCONA_TOOLKIT_VERSION=$(rpm -qi $PERCONA_TOOLKIT|grep -i version|cut -d':' -f2)
echo "PERCONA TOOLKIT,$PERCONA_TOOLKIT_VERSION" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile

#check if percona xtradbback
PERCONA_XTRABACKUP_VERSION=$(rpm -qi $PERCONA_XTRABACKUP|grep Version|cut -d':' -f 2)
echo "PERCONA XTRADB,$PERCONA_XTRABACKUP_VERSION" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile

#check if mysqld is installed
MYSQL_VERSION=$(mysql --version|cut -d' ' -f4)
MYSQL_STATUS=$(systemctl status mysqld|grep -i active|cut -d' ' -f5) #active
echo "MYSQL,$MYSQL_VERSION" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo "mysqld STATUS,$MYSQL_STATUS" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile



#WHITETXT "${BOLD}SYNC SYSTEM DETAILS"
#WHITETXT "Total amount of RAM: $tram MB"
echo "RAM,$tram" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile

#WHITETXT " ${BOLD}Sync Operation Details "
#GREENTXT "SYNC SOURCE"
#WHITETXT "Sync Source Site: ${SYNC_SOURCE}"
#WHITETXT "Sync Source webuser: ${WEBUSER}"
#WHITETXT "Sync Source DATABASE: ${DBNAME_STAGING}"
#WHITETXT "Sync Source Document Root: ${DOCUMENT_ROOT_STAGING}"
DEBUG "SYNC SOURCE: ${SYNC_SOURCE}/${WEBUSER}/${DBNAME_STAGING}/${DOCUMENT_ROOT_STAGING}" #logger
echo "Sync Source Site,${SYNC_SOURCE}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo "Sync Source webuser,${WEBUSER}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo "Sync Source DATABASE,${DBNAME_STAGING}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo "Sync Source Document Root,${DOCUMENT_ROOT_STAGING}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo
echo 

#GREENTXT "SYNC DESTINATION"
#WHITETXT "Sync Destination Site: ${SYNC_DESTINATION}"
#WHITETXT "Sync Destination webuser: ${WEBUSER}"
#WHITETXT "Sync Destination DATABASE: ${DBNAME_PROD}"
#WHITETXT "Sync Destination Document Root: ${DOCUMENT_ROOT_LIVE}"
DEBUG "SYNC DESTINATION: ${SYNC_DESTINATION}/${WEBUSER}/${DBNAME_PROD}/${DOCUMENT_ROOT_LIVE}" #logger
echo "Sync Destination Site,${SYNC_DESTINATION}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo "Sync Destination webuser,${WEBUSER}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo "Sync Destination DATABASE,${DBNAME_PROD}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo "Sync Destination Document Root,${DOCUMENT_ROOT_LIVE}" >> $SYNC_SYS_TEST_TMP_FILE #tmpfile
echo 
echo 

#print the System Details in Tabular Format
printTable ',' "$(cat $SYNC_SYS_TEST_TMP_FILE)"
rm -rf $SYNC_SYS_TEST_TMP_FILE

if [[ ( -z $PHP_VERSION_FETCHED ) || ( -z $PERCONA_SERVER_VERSION ) || \
      ( -z $PERCONA_CLIENT_VERSION ) || ( -z $PERCONA_TOOLKIT_VERSION ) || \
      ( -z $PERCONA_XTRABACKUP_VERSION ) || ( -z $MYSQL_VERSION ) || \
      ( $MYSQL_STATUS != "active" )  ]];then
      REDTXT "Requirement Meet Failed. Exiting ..."
      exit 1
fi


WHITETXT "Sync is about to Begin: Do you want to START the HWW Sync Tool Operation [yn][y]: "
read -p "Sync is about to Begin: Do you want to START the HWW Sync Tool Operation [yn][y]: " answer
if [ ! answer='y' ]; then 
  echo
  exit 1
else 
  echo "Sync Operation Starts at ${now}"
  INFO "Sync Operation Starts at ${now}" #logger
  pause "---> Press [Enter] key to proceed ..."
fi


###################################################################################
###                                  AGREEMENT                                  ###
###################################################################################

echo
YELLOWTXT "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
YELLOWTXT "BY INSTALLING THIS SOFTWARE AND BY USING ANY AND ALL SOFTWARE"
YELLOWTXT "YOU ACKNOWLEDGE AND AGREE:"
echo
YELLOWTXT "THIS SOFTWARE AND ALL SOFTWARE PROVIDED IS PROVIDED AS IS"
YELLOWTXT "UNSUPPORTED AND WE ARE NOT RESPONSIBLE FOR ANY DAMAGE"
echo
YELLOWTXT "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo
YELLOWTXT "---> Do you agree to these terms?  [y/n][y]:"
read -p "---> Do you agree to these terms?  [y/n][y]:" terms_agree
INFO "User Agreement Signed: ${terms_agree}" #logger

if [ "${terms_agree}" == "y" ];then
  echo "Agreement Signed"
else 
  REDTXT "Going out. EXIT"
  exit 1
fi


###################################################################################
###                 SETTING UP THE BACKUP DIRECTORY                             ###
###################################################################################

BLUEBG "~      SETUP THE ${BACKUP_DIR_MAIN}] DIRECTORY    ~"
INFO "SETUP THE ${BACKUP_DIR_MAIN} DIRECTORY" #logger

if [ ! -d ${BACKUP_DIR_MAIN} ]; then 
  mkdir ${BACKUP_DIR_MAIN}
else 
  YELLOWTXT "${BACKUP_DIR_MAIN} Directory already exists. Skipping..."
fi 

#BACKUP_DIR_MAIN=${BACKUP_DIR_MAIN}

BLUEBG "~    BACKUP SYNC DIRECTORY SETUP IS COMPLETED    ~"
INFO "${SPACE_2_ARROW}BACKUP SYNC DIRECTORY SETUP IS COMPLETED" #logger

BLUEBG "~    REMOVING BACKUP FILES OLDER THAN 5 days    ~"
INFO "${SPACE_2_ARROW}Removing Backup files older than 5 days"
find $BACKUP_DIR_MAIN/* -mtime +5 -exec rm {} \;> /dev/null 2>&1
echo 
pause '------> Press [Enter] key to show the menu '
printf "\033c"


###################################################################################
###                                  MAIN MENU                                  ###
###################################################################################
showMenu () {
printf "\033c"
    echo
      echo
        echo -e "${DGREYBG}${BOLD}  HWW UNIVERSAL SYNC TOOL v.${TOOL_VERSION}  ${RESET}"
        BLUETXT "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        echo
        WHITETXT "-> Take the Document Root Backup        :  ${YELLOW}\tdocbackup"
        WHITETXT "-> Sync Document Root                   :  ${YELLOW}\tdocsync"
        WHITETXT "-> Take the Database Backup             :  ${YELLOW}\tdbbackup"
        WHITETXT "-> Sync Database                        :  ${YELLOW}\tdbsync"

        echo
        BLUETXT ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        echo
        WHITETXT "-> Restore Databases                    :  ${YELLOW}\tdbrestore"
        BLUETXT ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        echo
        WHITETXT "-> To quit and exit                     :  ${RED}\t\t\t\texit"
        echo
    echo
}
while [ 1 ]
do
        showMenu
        read CHOICE
        case "${CHOICE}" in
                "docbackup")

#PART-1: Document Root Backup
echo 
echo 

BLUEBG "~    BACKUP DOCUMENTS ROOTS    ~"
INFO "BACKUP THE DOCUMENT ROOTS" #logger

#1.1: Check if the BACKUP_MAIN_DIR exists or not
WHITETXT "~ CHECKING IF ${BACKUP_DIR_MAIN} EXISTS OR NOT"
if [ ! -d ${BACKUP_DIR_MAIN} ]; then 
  REDTXT "BACKUP SYNC DIRECTORY SETUP IS NOT DONE. EXECUTE STEP-1 FIRST"
  REDTXT "Exiting ..."
  ERROR "${SPACE_2_ARROW}${BACKUP_DIR_MAIN} Doesn't exists. Exiting ..." #logger
  echo
  exit 1
fi 

#1.2: Check if Enough Space exists in the system 
WHITETXT "~ CHECKING IF ENOUGH SPACE EXISTS FOR BACKUP ~"
SPACE_AVAILABLE=$(df |grep -i '/dev/ploop*'|awk '{print $4}')
#SPACE_AVAILABLE=${SPACE_AVAILABLE::-1}
SPACE_REQUIRED=$(du -s /home/acadia/public_html/corporate/prod_1_06_02_2020_14_43_37|awk '{print $1}')
#SPACE_REQUIRED=${SPACE_REQUIRED::-1}
if [[ ( $SPACE_REQUIRED -ge $SPACE_AVAILABLE ) || ( $SPACE_AVAILABLE -le 500000 ) ]];then 
  echo -e "SPACE REQUIREMENT NOT MET"; 
  ERROR "${SPACE_2_ARROW}SPACE REQUIREMENT NOT MET"; 
else 
  #1.3: Document Root Backup in the SYNC BACKUP Directory
  pause '------> Space Requirement Meet. Press [Enter] key to continue'
  WHITETXT "Do you want to take Document Root Backup [$SYNC_DESTINATION]? [yn][y]"
  read -p "Do you want to take Document Root Backup [$SYNC_DESTINATION]? [yn][y]" answer
  if [[ $answer == "y" ]] ; then
    WHITETXT "Dumping Document Root Live: ${DOCUMENT_ROOT_LIVE} to ${BACKUP_DIR_MAIN}"
    DEBUG "${SPACE_2_ARROW}Dumping Document Root Live: ${DOCUMENT_ROOT_LIVE} to ${BACKUP_DIR_MAIN}" #logger
    cd $DOCUMENT_ROOT_MAIN
    zip -r $BACKUP_DIR_MAIN/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}${delimiter}$(date +"%Y-%m-%d-%H.%M.%S").zip ${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY} #> /dev/null 2>&1
    cd ~
  else
    YELLOWTXT "Skipping the Live Site Document Root Backup "
    INFO "${SPACE_2_ARROW}Skipping the Live Site Document Root Backup " #logger
  fi
    echo 
    echo 
fi


BLUEBG "~    DOCUMENT ROOT BACKUP OPERATION IS COMPLETED    ~"
INFO "DOCUMENT ROOT BACKUP OPERATION IS COMPLETED" #logger
echo "=================================================================================="
echo
echo
pause '------> Press [Enter] key to show the menu'
printf "\033c"
;;

#PART-2: Document Root Sync
"docsync")
echo 
echo 
INFO "SYNC DOCUMENT ROOTS [STAGING--->TO--->LIVE]" #logger
BLUEBG "~ SYNC DOCUMENT ROOTS [STAGING--->TO--->LIVE] "
WHITETXT "Select what types of server you want to sync : Magento[m] Wordpress[w] Drupal[d] Others[o]: "
read serverType
if [[ $serverType == "w" ]]; then 
  INFO "${SPACE_2_ARROW}Server Type: WordPress" #logger
  WP_UPLOADS="wp-content/uploads"
  WP_THEMES="wp-content/themes"
  WP_PLUGINS="wp-content/plugins"

  GREENTXT "Document Root Sync: Wordpress"
  WHITETXT "Sync the following: $WP_UPLOADS :: $WP_THEMES :: $WP_PLUGINS "
  
  WHITETXT "Syncing the $WP_UPLOADS"
  DEBUG "${SPACE_4_ARROW}Syncing the $WP_UPLOADS" #logger

  #/home/${WEBUSER}/public_html/corporate/acadia_wp_dev_init/
  rsync -avpP --progress ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY}/${WP_UPLOADS}/ ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}/${WP_UPLOADS}/
  echo 
  echo 

  WHITETXT "Syncing the $WP_THEMES"
  DEBUG "${SPACE_4_ARROW}Syncing the $WP_THEMES" #logger
  #rsync -avu
  rsync -avpP --progress ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY}/${WP_THEMES}/ ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}/${WP_THEMES}/
  echo 
  echo 
  
  WHITETXT "Syncing the $WP_PLUGINS"
  DEBUG "${SPACE_4_ARROW}Syncing the $WP_PLUGINS" #logger
  rsync -avpP --progress ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY}/${WP_PLUGINS}/ ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}/${WP_PLUGINS}/
  echo 
  echo 

elif [[ $serverType == "m" ]]; then 
  echo -e "Docuement Root Sync: Magento"
  INFO "${SPACE_2_ARROW}Server Type: Magento" #logger
elif [[ $serverType == "d" ]]; then 
  echo -e "Document Root Sync: Drupal"
  INFO "${SPACE_2_ARROW}Server Type: Drupal" #logger

else 
  echo -e "Other options choosen"
  INFO "${SPACE_2_ARROW}Server Type: Other" #logger
fi 

INFO "DOCUMENT ROOT SYNC OPERATION IS COMPLETED"
BLUEBG "~    DOCUMENT ROOT SYNC OPERATION IS COMPLETED    ~"
echo "=================================================================================="
echo
echo
pause '------> Press [Enter] key to show the menu'
printf "\033c"
;;


###################################################################################
###                         TAKING DATABASE BACKUP                              ###
###################################################################################
#PART-3: Taking the db backup with the current date time in the SYNC BACKUP Directory
"dbbackup")
echo 
echo 
INFO "DATABASE BACKUP OPERATION BEGINS ..." #logger
BLUEBG "~ CHECKING IF ${BACKUP_DIR_MAIN} EXISTS OR NOT"
DEBUG "${SPACE_2_ARROW}CHECKING IF ${BACKUP_DIR_MAIN} EXISTS OR NOT" #logger

if [ ! -d ${BACKUP_DIR_MAIN} ]; then 
  REDTXT "BACKUP SYNC DIRECTORY SETUP IS NOT DONE "
  ERROR "${SPACE_4_ARROW}BACKUP SYNC DIRECTORY SETUP IS NOT DONE, Exiting ... " #logger
  echo "Exiting ..."
  exit 1
fi 

BLUEBG "~ CHECKING IF ${MYSQL_CONF_FILENAME} EXISTS OR NOT"
DEBUG "${SPACE_2_ARROW}CHECKING IF ${MYSQL_CONF_FILENAME} EXISTS OR NOT"
if [ ! -f ${MYSQL_CONF_FILENAME} ];  then 
  REDTXT "${MYSQL_CONF_FILENAME} file missing in /home/${WEBUSER}"
  WHITETXT "Create the ${MYSQL_CONF_FILENAME} file in /home/${WEBUSER}"
  ERROR "${SPACE_4_ARROW}${MYSQL_CONF_FILENAME} file missing in /home/${WEBUSER}" #logger
  INFO "${SPACE_2_ARROW}Creating the ${MYSQL_CONF_FILENAME} file in /home/${WEBUSER}" #logger

cat > /home/${WEBUSER}/${MYSQL_CONF_FILENAME} <<EOF
[mysqldump]
user=acadia
password=${MYSQL_WEB_PASSWORD}

[mysql]
user=acadia
password=${MYSQL_WEB_PASSWORD}
EOF
fi

BLUEBG "~    TAKING DATABASE BACKUP    ~"
INFO "${SPACE_2_ARROW}TAKING DATABASE BACKUP" #logger

WHITETXT "${BOLD}PRILIMINARY DATABASE INFORMATION"
WHITETXT "Production Site DB: $DBNAME_PROD"
WHITETXT "Staging Site DB: $DBNAME_STAGING"
WHITETXT "DO YOU WANT TO TAKE DATABASE BACKUP [yn][y]"
read -p "DO YOU WANT TO TAKE DATABASE BACKUP [yn][y]: " answer
#read -p "Do you want to take DB Backup? [yn]" answer
if [[ "${answer}" == "y" ]] ; then
  #echo "Dumping STAGING DB: ${DBNAME_STAGING} to ${BACKUP_DIR_MAIN}"
  #INFO "${SPACE_4_ARROW}Dumping STAGING DB: ${DBNAME_STAGING} to ${BACKUP_DIR_MAIN}" #logger

  #mysqldump -u $MYSQL_WEB_USER $DBNAME_STAGING > ${BACKUP_DIR_MAIN}/${DBNAME_STAGING}${delimiter}$(date +"%Y-%m-%d-%H.%M.%S").sql

  echo "Dumping PRODUCTION DB: ${DBNAME_PROD} to ${BACKUP_DIR_MAIN}"
  INFO "${SPACE_4_ARROW}Dumping PRODUCTION DB: ${DBNAME_PROD} to ${BACKUP_DIR_MAIN}" #logger

  mysqldump -u $MYSQL_WEB_USER $DBNAME_PROD > ${BACKUP_DIR_MAIN}/${DBNAME_PROD}${delimiter}$(date +"%Y-%m-%d-%H.%M.%S").sql
  
  BLUEBG "~   TAKING DATABASE BACKUP IS COMPLETED    ~"
  echo "--------------------------------------------------------"
  INFO "${SPACE_4_ARROW}Taking Database Backup is Completed" #logger
  echo
else
  YELLOWTXT " Database backup was skipped by the user. Next Step"
  DEBUG "${SPACE_4_ARROW}Database backup was skipped by the user. Next Step" #logger
fi

echo "=================================================================================="
echo
echo
pause '------> Press [Enter] key to show the menu '
printf "\033c"
;;

###################################################################################
###                               SYNC DATABASES                                ###
###################################################################################
#PART-4
"dbsync")
echo 
echo 

INFO "SYNCING DATABASES" #logger
BLUEBG "~    SYNC DATABASES    ~"

#PART-4.0: Allow the session to take invalid date time
mysql -Bse "SET SESSION sql_mode='ALLOW_INVALID_DATES'"

#PART-4.1: List all Database tables 
WHITETXT " ${BOLD}LISTING ALL DATABASE TABLES"

declare -A dbMainList
declare -a dbList=($DBNAME_STAGING $DBNAME_PROD)

for db in ${dbList[@]};do
  declare -a dbTableList=()
  for i in $(mysql -u $MYSQL_WEB_USER $db -e 'SHOW TABLES' | grep -v "Tables_in" | awk '{print $1}'); do
    dbTableList+=($i)
  done
  dbMainList["$db"]=${dbTableList[@]}
done

WHITETXT "Do you want to print the Database Tables? [yn][y]"
read -p "Do you want to print the Database Tables? [yn]: " answer

if [[ "${answer}" == "y" ]]; then
  INFO "${SPACE_2_ARROW}Listing all Database Tables" #logger
  for key in "${!dbMainList[@]}";do
    echo -e "${BOLD}DATABASE: {$key}\n-----------------------------------"
    tableCounter=0
    read -r -a tableList <<< "${dbMainList[${key}]}"
    for tab in "${tableList[@]}";do
      ((tableCounter++))
      echo "[$tableCounter]. $tab"
    done
    echo
    echo
  done
else
  YELLOWTXT "Database table listing is skipped by user"
  DEBUG "${SPACE_2_ARROW}Database table listing is skipped by user" #logger
fi


#PART-4.2: Creating Source Database Table List -- will be used in 4.2b and 4.2c
WHITETXT "Creating Source Database Table Array"
declare -a sourceDBTableList
sourceDBTableList=() # this will transform the array into an empty array
counter=0
progressCounter=0  #reinitialize later

for i in $(mysql -u $MYSQL_WEB_USER $SOURCE_DB -e 'SHOW TABLES' | grep -v "Tables_in" | awk '{print $1}'); do
  ((counter++))
  sourceDBTableList+=($i)
done

#PART-4.3- Check if databases having table differences
WHITETXT "Check if [source db]: $SOURCE_DB and [destination db]:$DESTINATION_DB having table differences"
declare -a tableNotExistsInDestinationDB
tableNotExistsInDestinationDB=()
#check if the table exists in destination database and store it into an array

tableInSourceDBStatus="yes"
tableInDestinationDBStatus="yes"

for tab in "${sourceDBTableList[@]}";do
  table_exists_status=$(mysql -Bse "SELECT count(*) FROM information_schema.TABLES where (TABLE_SCHEMA='$DESTINATION_DB') AND (TABLE_NAME='$tab')")
  if [[ $table_exists_status -eq 0 ]];then 
    tableNotExistsInDestinationDB+=($tab)
    tableInDestinationDBStatus="no"
    echo "$tab,$tableInSourceDBStatus,$tableInDestinationDBStatus" >> $SYNC_TABLE_EXISTS_TMP_FILE
  fi
done

REDTXT "The following table doesnt exists in the [Destination DB]: $DESTINATION_DB"
printTable ',' "$(cat $SYNC_TABLE_EXISTS_TMP_FILE)"
rm -rf $SYNC_TABLE_EXISTS_TMP_FILE
echo 
echo 
pause '------> Press [Enter] to Continue to create non existing tables in DESTINATION_DB'
printf "\033c"

nonExistingTableCounter=1
WHITETXT "Creating non-existing tables in $DESTINATION_DB and importing table schema and rows"
for tab in "${tableNotExistsInDestinationDB[@]}";do 
  YELLOWTXT "--> Table [$nonExistingTableCounter]: $tab --> Creating --> Importing Schema"
  #mysql -Bse "CREATE TABLE $DESTINATION_DB.$tab LIKE $SOURCE_DB.$tab"
  #mysql -Bse "INSERT INTO $DESTINATION_DB.$tab SELECT * from $SOURCE_DB.$tab"
  mysql -Bse "set @@SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';CREATE TABLE $DESTINATION_DB.$tab LIKE $SOURCE_DB.$tab;INSERT INTO $DESTINATION_DB.$tab SELECT * from $SOURCE_DB.$tab"

  ((nonExistingTableCounter++))
done

#PART-4.4: Delete data from table wp_posts where post_date_gmt having invalid date-time format -- under construction
YELLOWTXT "List all the table entries having invalid date time format and clean it from ${SOURCE_DB}"
#WHITETXT "Do you want to clean the [yN][y]"
mysql -Bse "SELECT * FROM ${SOURCE_DB}.${ERRONOUS_DB_TABLE} WHERE ${ERRONOUS_DB_TABLE_COLUMN} LIKE '0000-00-00 00:00:00'"
#mysql -Bse "DELETE FROM ${SOURCE_DB}.${ERRONOUS_DB_TABLE} WHERE ${ERRONOUS_DB_TABLE_COLUMN} LIKE '0000-00-00 00:00:00'"
mysql -Bse "UPDATE ${SOURCE_DB}.${ERRONOUS_DB_TABLE} SET ${ERRONOUS_DB_TABLE_COLUMN} = CURRENT_TIMESTAMP() WHERE ${ERRONOUS_DB_TABLE_COLUMN} LIKE '0000-00-00 00:00:00'"

pause '------> Press [Enter] to Continue to Table Sync'
printf "\033c"

#PART-4.5: Check Table Inconsistencies/Checksums
WHITETXT "Do you want to check the Database inconsistencies between $SOURCE_DB and $DESTINATION_DB? [yn][y]"
read -p "Do you want to check the Database inconsistencies between $SOURCE_DB and $DESTINATION_DB? [yn][y]: " answer
if [[ "${answer}" == "y" ]];then 
  INFO "${SPACE_2_ARROW}Checking table inconsistencies between $SOURCE_DB <----> $DESTINATION_DB"
  WHITETXT "Checking table inconsistencies between $SOURCE_DB <----> $DESTINATION_DB"
  
  for tab in "${sourceDBTableList[@]}";do
    ((progressCounter++))
    echo -e "Checking Database Incosistencies  $tab\t [Progress: calc $progressCounter/$counter]\n"
    checksumOutput=$(pt-table-checksum h=$MYSQL_HOST,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,P=$MYSQL_PORT --set-vars innodb_lock_wait_timeout=30 --databases=$SOURCE_DB,$DESTINATION_DB --tables=$tab 2>&1)
    echo "$checksumOutput" # this quote is for formatted output
    rows=$(echo "$checksumOutput"|grep -i $tab|awk '{print $4}')
    #rows=$(pt-table-checksum h=$MYSQL_HOST,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,P=$MYSQL_PORT --set-vars innodb_lock_wait_timeout=30 --databases=$SOURCE_DB,$DESTINATION_DB --tables=$tab 2>&1|grep -i $tab|awk '{print $4}')
    read -ra rows_as_arr -d ' '<<<"$rows"
    diffStatus="NO"
    if [[ $((rows_as_arr[0]-rows_as_arr[1])) -ne 0 ]];then 
      diffStatus="YES"
    fi

    echo "${tab},${rows_as_arr[0]},${rows_as_arr[1]},$diffStatus" >> $SYNC_CHECKSUM_TMP_FILE
    #sleep 1
    echo
  done

  INFO "${SPACE_4_ARROW} Status: $progressCounter/$counter" #logger
  WHITETXT "PRINTING THR DB CHECKSUM FILE"
  printTable ',' "$(cat $SYNC_CHECKSUM_TMP_FILE)"
  rm -rf $SYNC_CHECKSUM_TMP_FILE
  echo 
  echo 
fi


pause '------> Press [Enter] to Continue to Table Sync'
printf "\033c"


#PART-4.6: Table Sync
WHITETXT " Syncing tables of $SOURCE_DB --> TO --> $DESTINATION_DB"
INFO "${SPACE_2_ARROW}Syncing tables of $SOURCE_DB --> TO --> $DESTINATION_DB" #logger
progressCounter=0     #reinitialize

for tab in "${sourceDBTableList[@]}";do
  ((progressCounter++))
  echo -e "Syncing $tab\t [Sync Progress: calc $progressCounter/$counter]\n"
  pt-table-sync h=$MYSQL_HOST,P=$MYSQL_PORT,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,D=$SOURCE_DB,t=$tab h=$MYSQL_HOST,P=$MYSQL_PORT,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,D=$DESTINATION_DB --execute --verbose
  sleep 1
  echo ""
done
INFO "${SPACE_4_ARROW}Sync Status: $progressCounter/$counter" #logger

pause '------> Press [Enter] to Continue to linisting tables with no PK'
printf "\033c"

#PART-4.7: # list all the tables having no primary key
WHITETXT " Listing all the tables having no primary key"

listAllDB_TablesHavingNoPK_strFormat=$(mysql -u $WEBUSER <<EOF
pager grep -w "prod_1_06_02_2020_14_43_37"
select tables.table_schema
, tables.table_name
, tables.engine
from information_schema.tables
left join (
select table_schema
, table_name
from information_schema.statistics
group by table_schema
, table_name
, index_name
having 
sum(
case 
when non_unique = 0 
and nullable != 'YES' then 1 
else 0 
end
) = count(*)
) puks
on tables.table_schema = puks.table_schema
and tables.table_name = puks.table_name
where puks.table_name is null
and tables.table_type = 'BASE TABLE'
and tables.table_schema not in ('performance_schema', 
'information_schema', 'mysql') \G
EOF
)

#printf '%s\n' "$output"|awk -v RS=' ' '/^${MYSQL_DB_SUFFIX}/'|sort|uniq  # printing the list of tables having no primary key
#printf '%s\n' "$output"|perl -ne 'if (!defined $x{$_}) { print $_; $x{$_} = 1; }' # a better alternative
listAllTablesHavingNoPK_strFormat=$(printf '%s\n' "$listAllDB_TablesHavingNoPK_strFormat"|awk -v RS=' ' '/^wp_/')
#echo $listAllTablesHavingNoPK_strFormat
read -ra listAllTablesHavingNoPK<<<$(printf '%s\n' "$(echo $listAllTablesHavingNoPK_strFormat)" | awk -v RS='[[:space:]]+' '!a[$0]++{printf "%s%s", $0, RT}')
printf "Table with no Primary Key: %s\n"  "${listAllTablesHavingNoPK[@]}"
INFO "${SPACE_2_ARROW}Listing all the tables having no primary key : ${listAllTablesHavingNoPK[@]}" #logger

pause '------> Press [Enter] to Search and Replace old string with new string'
printf "\033c"


#PART-4.8: Search and Replace the old string with new string 
WHITETXT "Search and Replace the ${UNWANTED_STRING} with ${WANTED_STRING}"
DEBUG "${SPACE_2_ARROW}Search and Replace the ${UNWANTED_STRING} with ${WANTED_STRING}" #logger
YELLOWTXT "Precondition: ${PHP_DB_TEXT_REPLACE_SCRIPT} must be present at /home/${WEBUSER}"
if [[ ! -f '/home/${WEBUSER}/${PHP_DB_TEXT_REPLACE_SCRIPT}' ]]; then 
  REDTXT "${PHP_DB_TEXT_REPLACE_SCRIPT} doesnot exists in /home/${WEBUSER}"
  WHITETXT "Creating the ${PHP_DB_TEXT_REPLACE_SCRIPT} "
  ERROR "${SPACE_4_ARROW}${PHP_DB_TEXT_REPLACE_SCRIPT} doesnot exists in /home/${WEBUSER}" #logger
  INFO "${SPACE_4_ARROW}Creating the ${PHP_DB_TEXT_REPLACE_SCRIPT}" #logger

cat > /home/${WEBUSER}/${PHP_DB_TEXT_REPLACE_SCRIPT} <<EOF
<?php  
  header("Content-Type: text/plain");

  \$host = $MYSQL_HOST;
  \$username = $MYSQL_WEB_USER;
  \$password = '$MYSQL_WEB_PASSWORD';
  \$database = $DBNAME_PROD;
  \$string_to_replace  = '$UNWANTED_STRING';
  \$new_string = '$WANTED_STRING';

  // Connect to database server
  mysql_connect(\$host, \$username, \$password);

  // Select database
  mysql_select_db(\$database);

  // List all tables in database
  \$sql = "SHOW TABLES FROM ".\$database;
  \$tables_result = mysql_query(\$sql);

  if (!\$tables_result) {
    echo "Database error, could not list tables\nMySQL error: " . mysql_error();
    exit;
  }

  echo "In these fields '\$string_to_replace' have been replaced with '\$new_string'\n\n";
  while (\$table = mysql_fetch_row(\$tables_result)) {
    echo "Table: {\$table[0]}\n";
    \$fields_result = mysql_query("SHOW COLUMNS FROM ".\$table[0]);
    if (!\$fields_result) {
      echo 'Could not run query: ' . mysql_error();
      exit;
    }
    if (mysql_num_rows(\$fields_result) > 0) {
      while (\$field = mysql_fetch_assoc(\$fields_result)) {
        if (stripos(\$field['Type'], "VARCHAR") !== false || stripos(\$field['Type'], "TEXT") !== false) {
          echo "  ".\$field['Field']."\n";
          \$sql = "UPDATE ".\$table[0]." SET ".\$field['Field']." = replace(".\$field['Field'].", '\$string_to_replace', '\$new_string')";
          mysql_query(\$sql);
        }
      }
      echo "\n";
    }
  }

  mysql_free_result(\$tables_result);  
?>
EOF
fi 

chmod +x /home/${WEBUSER}/${PHP_DB_TEXT_REPLACE_SCRIPT} # execution permission
php /home/${WEBUSER}/${PHP_DB_TEXT_REPLACE_SCRIPT}      # run the php script and see the magic 
rm -rf /home/${WEBUSER}/${PHP_DB_TEXT_REPLACE_SCRIPT}
echo 
pause '------> Press [Enter] to Search and Replace old string with new string'
printf "\033c"

#PART-4.9: Verify whether the DB strings are replaced 
INFO "${SPACE_2_ARROW}Verifying if the ${UNWANTED_STRING} is replaced with ${WANTED_STRING}"
read -p "Have you replaced ${UNWANTED_STRING} with ${WANTED_STRING} ? [yn][y]: " hasReplaced
read -p "Have you varified that the replacement is happened ? [yn][n]: " hasVerified
while [[ ! $hasVerified = "y" ]]; do 
  echo -e "${BOLD}Note:\n------------------------------------------------------"
  echo -e "(1) Use the ${SYNC_DESTINATION}/Search-Replace-DB/ in your browser"
  echo -e "(2) In the ${bold}Database Details${normal}: Enter below: "
  echo -e "     -> database name : $DBNAME_PROD"
  echo -e "     -> username      : $MYSQL_WEB_USER"
  echo -e "     -> pass          : $MYSQL_WEB_PASSWORD"
  echo -e "     -> host          : $MYSQL_HOST"
  echo -e "     -> port          : $MYSQL_PORT"
  echo -e "Now press Button: ${BOLD}Test Connection"


  echo 
  echo 

  echo -e "(3) In the ${bold}SearchReplace URL ${normal}: Enter below: "
  echo -e "     -> replace: $UNWANTED_STRING"
  echo -e "     -> with   : $WANTED_STRING"
  echo -e "Now press Button: ${BOLD}Do a safe test run"
  echo -e "Check if you could find any string with $UNWANTED_STRING, if not, then confirm"

  read -p "Have you varified that the replacement is happened ? [yn][n]: " hasVerified
done 

INFO "${SPACE_4_ARROW}Verification status: $hasVerified" #logger

BLUEBG "~    DATABASE SYNC & REPLACE OPERATION IS COMPLETED    ~"
echo "=================================================================================="
echo
echo
pause '------> Press [Enter] key to show the menu'
printf "\033c"
;;

###################################################################################
###                             RESTORE DATABASES                               ###
###################################################################################
#PART-5: Restore Database
"dbrestore")
echo 
echo 

BLUEBG "   ~ DATABASE RESTORE OPERATION BEGINS   ~ "
INFO "DATABASE RESTORE OPERATION BEGINS ..." #logger
DEBUG "${SPACE_2_ARROW} CHECKING IF ${BACKUP_DIR_MAIN} EXISTS OR NOT" #logger
BLUEBG "   ~ CHECKING IF ${BACKUP_DIR_MAIN} EXISTS OR NOT   ~ "
if [ ! -d ${BACKUP_DIR_MAIN} ]; then 
  REDTXT "BACKUP SYNC DIRECTORY SETUP IS NOT DONE "
  echo "Exiting ..."
  ERROR "${SPACE_4_ARROW}BACKUP SYNC DIRECTORY SETUP IS NOT DONE. Exiting ..." #logger
  exit 1
fi 

#listing all .sql files in the BACKUP_DIR_MAIN
cd $BACKUP_DIR_MAIN # must return to cd ~
#files_in_backup_dir=(*.sql)

#db restore operation
USER=$MYSQL_WEB_USER
HOST=$MYSQL_HOST
PASS=$MYSQL_WEB_PASSWORD

ROOT_USER=$MYSQL_ROOT_USER
ROOT_PASS=$MYSQL_ROOT_PASSWORD

# Look for .sql files and Exit when folder doesn't have .sql files:
if [ "$(ls -A *.sql 2> /dev/null)" ]  ; then
  GREENTXT ".sql files found"
  DEBUG "${SPACE_2_ARROW}.sql files found"
  files_in_backup_dir=(*.sql) #an array
else
  REDTXT "No .sql files found"
  DEBUG "${SPACE_2_ARROW} No .sql files found"
  exit 0
fi

#Get all databsae list first
DBS="$(mysql -u $USER -h $HOST -p$PASS -Bse 'show databases')"
WHITETXT "These are the current existing Databases:"
echo $DBS

# Ignore list, won't restore the following list of DB:
IGGY="test information_schema mysql acadia_live acadia_live_test acadia_staging acadia_staging_test usync"

WHITETXT "Following DB Backup files found in $BACKUP_DIR_MAIN"

# set the prompt used by select, replacing "#?"
PS3="Use number to select a file or 'stop' to cancel: "
# allow the user to choose a file
select filename in ${files_in_backup_dir[@]}
do
  # leave the loop if the user says 'stop'
  if [[ "$REPLY" == stop ]]; then break; fi

  # complain if no file was selected, and loop to ask again
  if [[ "$filename" == "" ]]
  then
      echo "'$REPLY' is not a valid number"
      continue
  fi

  # now we can use the selected file
  WHITETXT "$filename is restoring ... "
  dbname=${filename%.sql} #removing the .sql extension and only having the filename, not filename.sql
  dbname=$(echo $dbname|cut -d':' -f1) #files are mostly in format text:2020-10-15-16.40.44.sql, we just need 'text'
  YELLOWTXT $dbname

  skipdb=-1 # -1 -> (dont skip db creation), 1-> (db already exists, skip)
  if [ "$IGGY" != "" ]; then
    for ignore in $IGGY
    do
        [ "$dbname" == "$ignore" ] && skipdb=1 || :
        
    done
  fi      

  # If not in ignore list, restore:
  if [ "$skipdb" == "-1" ] ; then
    skip_create=-1 #1-> Skip the creation, -1 -> dont skip the db creation
    for existing in $DBS
    do      
      #echo "Checking database: $dbname to $existing"
      [ "$dbname" == "$existing" ] && skip_create=1 || :
    done
    if [ "$skip_create" ==  "1" ] ; then 
      YELLOWTXT "Database: $dbname already exist, skiping create"
      read -p "Do you want to [FORCE] drop database to recreate and restore:[yn][y] " forceRestore
      if [[ $forceRestore == 'y' ]];then 
        REDTXT "**********WEBSITE [$SYNC_DESTINATION] WILL BE TEMPORARILY UNAVAILBALE DUE TO DB RESTORE OPERATION *****************"
        mysqladmin drop $dbname -u $ROOT_USER -p$ROOT_PASS
        dbcreate_restore $dbname $ROOT_USER $ROOT_PASS $USER $HOST $filename $PASS
      fi 
    else
      dbcreate_restore $dbname $ROOT_USER $ROOT_PASS $USER $HOST $filename $PASS
    fi
  fi    

  # it'll ask for another unless we leave the loop
  break
done #select
#db restore operation ends --------------------------

cd ~

INFO "DATABASE RESTORE OPERATION COMPLETED"
BLUEBG "   ~ DATABASE RESTORE OPERATION COMPLETED   ~ "
echo "=================================================================================="
echo
echo
pause '------> Press [Enter] key to show the menu'
printf "\033c"
;;


###################################################################################
###                             EXIT                                            ###
###################################################################################
#PART-6: EXIT
"exit")
echo
REDTXT "------> EXIT"
INFO "EXITING THE HWW SYNC TOOL" #logger
exit
;;



###################################################################################
###                             CATCH ALL MENU - THE END                        ###
###################################################################################

*)
printf "\033c"
;;
esac
done


EXIT
SCRIPTENTRY
INFO "HWW SCRIPT LOGGER V.$TOOL_VERSION EXECUTION ENDS"