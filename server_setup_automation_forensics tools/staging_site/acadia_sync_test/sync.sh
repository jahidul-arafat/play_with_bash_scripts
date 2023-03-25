#!/bin/bash
# This software is developed by Jahid Arafat, DevOps Engineer, Harris Web Works,CT,USA.


###################################################################################
###                              GLOBAL VARIABLES                               ###
###################################################################################

CENTOS_VERSION=8
TOOL_VERSION=1.0
PHP_VERSION=7.3

MYSQL_HOST=localhost;
MYSQL_ROOT_USER=root;
MYSQL_ROOT_PASSWORD='Bz@?cuN)UO%utYW18533';
MYSQL_WEB_USER=acadia;
MYSQL_WEB_PASSWORD='<ZAJ%HTh}X9>$ja15040'
MYSQL_PORT=3306;
MYSQL_DB_SUFFIX='wp_';
MYSQL_CONF_FILENAME='.my.cnf';


DBNAME_STAGING=acadia_wp_dev_init;
DBNAME_PROD=prod_1_06_02_2020_14_43_37;

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
UNWANTED_STRING='//staging.acadia-pharm.com'
WANTED_STRING='//liveacadia.harriswebworks.com'
PHP_DB_TEXT_REPLACE_SCRIPT='string_to_replace_db.php'

#Sync system details 
#SYNC_SOURCE="https://staging.acadia-pharm.com"
#SYNC_DESTINATION="https://www.acadia-pharm.com"

SYNC_SOURCE="https://stagingacadia.harriswebworks.com"
SYNC_DESTINATION="https://liveacadia.harriswebworks.com"



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
###                              CHECK IF WE CAN RUN IT                         ###
###################################################################################

echo
echo
# webuser- acadia?

if [[ ${EUID} -ne ${WEBUSER_ID} ]]; then
  echo
  REDTXT "ERROR: THIS SCRIPT MUST BE RUN AS ${WEBUSER_ID}!"
  YELLOWTXT "------> USE WEB-USER PRIVILEGES."
  exit 1
else
  GREENTXT "PASS: ${WEBUSER}!"
fi


# network is up?
host1=google.com
host2=github.com

RESULT=$(((ping -w3 -c2 ${host1} || ping -w3 -c2 ${host2}) > /dev/null 2>&1) && echo "up" || (echo "down" && exit 1))
if [[ ${RESULT} == up ]]; 
then
  GREENTXT "PASS: NETWORK IS UP. GREAT, LETS START!"
else
  echo
  REDTXT "ERROR: NETWORK IS DOWN?"
  YELLOWTXT "------> PLEASE CHECK YOUR NETWORK SETTINGS."
  echo
  echo
  exit 1
fi

# do we have CentOS?
if grep "CentOS.* ${CENTOS_VERSION}\." /etc/centos-release  > /dev/null 2>&1; then
  GREENTXT "PASS: CENTOS RELEASE ${CENTOS_VERSION}"
else
  echo
  REDTXT "ERROR: UNABLE TO FIND CENTOS ${CENTOS_VERSION}"
  YELLOWTXT "------> THIS CONFIGURATION FOR CENTOS ${CENTOS_VERSION}"
  echo
  exit 1
fi


# quick sync system test
GREENTXT "PATH: ${PATH}"
echo
echo
BLUEBG "~    QUICK SYNC SYSTEM TEST    ~"
echo "-------------------------------------------------------------------------------------"
echo
now=$(date +"%m/%d/%Y/%r")
tram=$( free -m | awk 'NR==2 {print $2}' )   
PHP_VERSION_FETCHED=$(php -r "echo PHP_VERSION;" | grep --only-matching --perl-regexp "7.\d+")

WHITETXT "${BOLD}SYNC SYSTEM DETAILS"
WHITETXT "Total amount of RAM: $tram MB"

WHITETXT " ${BOLD}Sync Operation Details "
GREENTXT "SYNC SOURCE"
WHITETXT "Sync Source Site: ${SYNC_SOURCE}"
WHITETXT "Sync Source webuser: ${WEBUSER}"
WHITETXT "Sync Source DATABASE: ${DBNAME_STAGING}"
WHITETXT "Sync Source Document Root: ${DOCUMENT_ROOT_STAGING}"
echo
echo 

GREENTXT "SYNC DESTINATION"
WHITETXT "Sync Destination Site: ${SYNC_DESTINATION}"
WHITETXT "Sync Destination webuser: ${WEBUSER}"
WHITETXT "Sync Destination DATABASE: ${DBNAME_PROD}"
WHITETXT "Sync Destination Document Root: ${DOCUMENT_ROOT_LIVE}"

WHITETXT "Sync is about to Begin: Do you want to START the HWW Sync Tool Operation [yn][y]: "
read answer
if [ ! answer='y' ]; then 
  echo
  exit 1
else 
  echo "Sync Operation Starts at ${now}"
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
WHITETXT "---> Do you agree to these terms?  [y/n][y]:"
read terms_agree
if [ "${terms_agree}" == "y" ];then
  echo "Agreement Signed"
else 
  REDTXT "Going out. EXIT"
  exit 1
fi

###################################################################################
###                                  MAIN MENU                                  ###
###################################################################################
showMenu () {
printf "\033c"
    echo
      echo
        echo -e "${DGREYBG}${BOLD}  HWW UNIVERSAL SYNC TOOL v.${TOOL_VERSION}  ${RESET}"
        BLUETXT ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
        echo
        WHITETXT "-> Check SYNC Backup Directory          :  ${YELLOW}\tsyncdir"
        WHITETXT "-> Take the Database Backup             :  ${YELLOW}\tdbbackup"
        WHITETXT "-> Sync Database                        :  ${YELLOW}\tdbsync"
        WHITETXT "-> Take the Document Root Backup        :  ${YELLOW}\tdocbackup"
        WHITETXT "-> Sync Document Root                   :  ${YELLOW}\tdocsync"
        echo
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
                "syncdir")

echo
echo

###################################################################################
###                         BACKUP SYNC DIRECTORY SETUP                         ###
###################################################################################

# PART-A : #case- sdir
BLUEBG "~      SETUP THE ${BACKUP_DIR_MAIN}] DIRECTORY    ~"
if [ ! -d ${BACKUP_DIR_MAIN} ]; then 
  mkdir ${BACKUP_DIR_MAIN}
fi 

WHITETXT "Creating the Syncing dir with the current date time"
BACKUP_DIR_BEFORE_TRIMMING=$BACKUP_DIR_MAIN/${SYNC_DIR_PREFIX}_$(date +"%d-%m-%Y-%r")
BACKUP_DIR_CURRENT=${BACKUP_DIR_BEFORE_TRIMMING::-3}
mkdir $BACKUP_DIR_CURRENT
BLUEBG "~    BACKUP SYNC DIRECTORY SETUP IS COMPLETED    ~"
echo "-------------------------------------------------------------------------------------"
echo
echo
pause '------> Press [Enter] key to show the menu '
printf "\033c"
;;


###################################################################################
###                         TAKING DATABASE BACKUP                              ###
###################################################################################
#PART-B: Taking the db backup with the current date time in the SYNC BACKUP Directory
"dbbackup")
echo 
echo 
BLUEBG "~ CHECKING IF ${BACKUP_DIR_MAIN} EXISTS OR NOT"
if [ ! -d ${BACKUP_DIR_MAIN} ]; then 
  REDTXT "BACKUP SYNC DIRECTORY SETUP IS NOT DONE "
  echo "Exiting ..."
  exit 1
fi 

BLUEBG "~ CHECKING IF ${MYSQL_CONF_FILENAME} EXISTS OR NOT"
if [ ! -f ${MYSQL_CONF_FILENAME} ];  then 
  REDTXT "${MYSQL_CONF_FILENAME} file missing in /home/${WEBUSER}"
  WHITETXT "Create the ${MYSQL_CONF_FILENAME} file in /home/${WEBUSER}"
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
WHITETXT "${BOLD}PRILIMINARY DATABASE INFORMATION"
WHITETXT "Production Site DB: $DBNAME_PROD"
WHITETXT "Staging Site DB: $DBNAME_STAGING"
WHITETXT "DO YOU WANT TO TAKE DATABASE BACKUP [yn][y]"
read answer
#read -p "Do you want to take DB Backup? [yn]" answer
if [[ "${answer}" == "y" ]] ; then
  echo "Dumping STAGING DB: ${DBNAME_STAGING} to ${BACKUP_DIR_CURRENT}"

  mysqldump -u $MYSQL_WEB_USER $DBNAME_STAGING > ${BACKUP_DIR_CURRENT}/${DBNAME_STAGING}_$(date +"%d-%m-%Y").sql

  echo "Dumping PRODUCTION DB: ${DBNAME_PROD} to ${BACKUP_DIR_CURRENT}"
  mysqldump -u $MYSQL_WEB_USER $DBNAME_PROD > ${BACKUP_DIR_CURRENT}/${DBNAME_PROD}_$(date +"%d-%m-%Y").sql
  
  BLUEBG "~   TAKING DATABASE BACKUP IS COMPLETED    ~"
  echo "--------------------------------------------------------"
  echo
else
  YELLOWTXT " Database backup was skipped by the user. Next Step"
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
#PART-3
"dbsync")
echo 
echo 

BLUEBG "~    SYNC DATABASES    ~"

#PART-3.1: Check if php version match
WHITETXT " CHECK IF THE PHP VERSION MEET"
if [[ ! $PHP_VERSION_FETCHED = $PHP_VERSION ]]; then 
  REDTXT "PHP VERSION MISMATCHED. EXITING ..."
  echo 
  exit 1
fi

#PART-3.2: List all Database tables 
WHITETXT " ${BOLD}LIST ALL DATABASE TABLES"
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
read answer
#read -p "Do you want to print the Database Tables? [yn]" answer
if [[ "${answer}" == "y" ]]; then
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
  YELLOWTXT "Database table listing is skipped by user."
fi

#PART-3.3: Table Sync
WHITETXT " Syncting tables of $SOURCE_DB --> TO --> $DESTINATION_DB"
declare -a sourceDBTableList
sourceDBTableList=() # this will transform the array into an empty array
counter=0
progressCounter=0

for i in $(mysql -u $MYSQL_WEB_USER $SOURCE_DB -e 'SHOW TABLES' | grep -v "Tables_in" | awk '{print $1}'); do
  ((counter++))
  sourceDBTableList+=($i)
done

for tab in "${sourceDBTableList[@]}";do
  ((progressCounter++))
  echo -e "Syncing $tab\t [Sync Progress: calc $progressCounter/$counter]\n"
  pt-table-sync h=$MYSQL_HOST,P=$MYSQL_PORT,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,D=$SOURCE_DB,t=$tab h=$MYSQL_HOST,P=$MYSQL_PORT,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,D=$DESTINATION_DB --execute --verbose
  sleep 1
  echo ""
done

#PART-3.4: # list all the tables having no primary key
WHITETXT " Listing all the tables having no primary key"

listAllDB_TablesHavingNoPK_strFormat=$(mysql -u $WEBUSER <<EOF
pager grep -w "acadia_live"
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
echo $listAllTablesHavingNoPK_strFormat
read -ra listAllTablesHavingNoPK<<<$(printf '%s\n' "$(echo $listAllTablesHavingNoPK_strFormat)" | awk -v RS='[[:space:]]+' '!a[$0]++{printf "%s%s", $0, RT}')
printf "%s\n"  "${listAllTablesHavingNoPK[@]}"


#PART-3.5: Search and Replace the old string with new string 
WHITETXT "Search and Replace the ${UNWANTED_STRING} with ${WANTED_STRING}"
YELLOWTXT "Precondition: ${PHP_DB_TEXT_REPLACE_SCRIPT} must be present at /home/${WEBUSER}"
if [[ ! -f '/home/${WEBUSER}/${PHP_DB_TEXT_REPLACE_SCRIPT}' ]]; then 
  REDTXT "${PHP_DB_TEXT_REPLACE_SCRIPT} doesnot exists in /home/${WEBUSER}"
  WHITETXT "Creating the ${PHP_DB_TEXT_REPLACE_SCRIPT} "

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

#PART-3.6: Verify whether the DB strings are replaced 
read -p "Have you replaced ${UNWANTED_STRING} with ${WANTED_STRING} ? [yn][y]" hasReplaced
read -p "Have you varified that the replacement is happened ? [yn][n]" hasVerified
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

  echo -e "(3) In the ${bold}SearchRepla${normal}: Enter below: "
  echo -e "     -> replace: $UNWANTED_STRING"
  echo -e "     -> with   : $WANTED_STRING"
  echo -e "Now press Button: ${BOLD}Do a safe test run"
  echo -e "Check if you could find any string with $UNWANTED_STRING, if not, then confirm"

  read -p "Have you varified that the replacement is happened ? [yn][n]" hasVerified
done 

BLUEBG "~    DATABASE SYNC & REPLACE OPERATION IS COMPLETED    ~"
echo "=================================================================================="
echo
echo
pause '------> Press [Enter] key to show the menu'
printf "\033c"
;;

#PART-4: Document Root Sync
"docbackup")
echo 
echo 

BLUEBG "~    BACKUP DOCUMENTS ROOTS    ~"

#4.1: Check if the documeBACKUP_MAIN_DIR exists or not
WHITETXT"~ CHECKING IF ${BACKUP_DIR_MAIN} EXISTS OR NOT"
if [ ! -d ${BACKUP_DIR_MAIN} ]; then 
  REDTXT "BACKUP SYNC DIRECTORY SETUP IS NOT DONE. EXECUTE STEP-1 FIRST"
  REDTXT "Exiting ..."
  echo
  exit 1
fi 

#4.2: Document Root Backup in the SYNC BACKUP Directory
WHITETXT "Do you want to take Document Root Backup [$SYNC_DESTINATION]? [yn][y]"
read answer
if [[ $answer == "y" ]] ; then
  WHITETXT "Dumping Document Root Live: ${DOCUMENT_ROOT_LIVE} to ${BACKUP_DIR_CURRENT}"
  cd $DOCUMENT_ROOT_MAIN
  zip -r $BACKUP_DIR_CURRENT/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}.zip ${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY} #> /dev/null 2>&1
  cd ~
else
  YELLOWTXT "Skipping the Live Site Document Root Backup "
fi


BLUEBG "~    DOCUMENT ROOT BACKUP OPERATION IS COMPLETED    ~"
echo "=================================================================================="
echo
echo
pause '------> Press [Enter] key to show the menu'
printf "\033c"
;;

"docsync")
echo 
echo 
BLUEBG "~ SYNC DOCUMENT ROOTS [STAGING--->TO--->LIVE] "
WHITETXT "Select what types of server you want to sync : Magento[m] Wordpress[w] Drupal[d] Others[o]: "
read serverType
if [[ $serverType == "w" ]]; then 
  WP_UPLOADS="wp-content/uploads"
  WP_THEMES="wp-content/themes"
  WP_PLUGINS="wp-content/plugins"

  echo -e "Document Root Sync: Wordpress"
  echo -e "Sync the following: "
  echo -e "   -> $WP_UPLOADS"
  echo -e "   -> $WP_THEMES"
  echo -e "   -> $WP_PLUGINS"
  
  WHITETXT "Syncing the $WP_UPLOADS"
  #/home/${WEBUSER}/public_html/corporate/acadia_wp_dev_init/
  rsync -zavh ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY}/${WP_UPLOADS} ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}/${WP_UPLOADS}
  echo 
  echo 

  WHITETXT "Syncing the $WP_THEMES"
  rsync -zavh ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY}/${WP_THEMES} ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}/${WP_THEMES}
  echo 
  echo 
  
  WHITETXT "Syncing the $WP_PLUGINS"
  rsync -zavh ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY}/${WP_PLUGINS} ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}/${WP_PLUGINS}
  echo 
  echo 

elif [[ $serverType == "m" ]]; then 
  echo -e "Docuement Root Sync: Magento"
elif [[ $serverType == "d" ]]; then 
  echo -e "Document Root Sync: Drupal"
else 
  echo -e "Other options choosen"
fi 

BLUEBG "~    DOCUMENT ROOT SYNC OPERATION IS COMPLETED    ~"
echo "=================================================================================="
echo
echo
pause '------> Press [Enter] key to show the menu'
printf "\033c"
;;

"exit")
echo
REDTXT "------> EXIT"
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

