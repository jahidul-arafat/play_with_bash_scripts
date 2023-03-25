#!/bin/bash

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
SOURCE_DIR="/home/acadia/usync/public_html"
BACKUP_DIR_MAIN="/home/acadia/usync/public_html/SYNC_BACKUP"
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


# # Extract files from .gz archives:
# function gzip_extract {

#   for filename in *.gz
#     do
#       echo "extracting $filename"
#       gzip -d $filename
#     done
# }

# #restoring the database
# function dbcreate_restore {
#   # $1->$dbname $2-> $ROOT_USER $3-> $ROOT_PASS $4-> $USER $5->$HOST $6-> $filename $7->$PASS
#   echo -e "Creating DB: $1"
#   mysqladmin create $1 -u $2 -p$3
#   mysql -Bse "GRANT ALL PRIVILEGES ON $1.* TO $4@'$5' with GRANT OPTION" -u $2 -p$3
#   echo "Importing DB: $1 from $6"
#   mysql $1 < $6 -u $4 -p$7
  
#   #mysqladmin create $dbname -u $ROOT_USER -p$ROOT_PASS
#   #mysql -Bse "GRANT ALL PRIVILEGES ON $dbname.* TO $USER@'$HOST' with GRANT OPTION" -u $ROOT_USER -p$ROOT_PASS
#   #echo "Importing DB: $dbname from $filename"
#   #mysql $dbname < $filename -u $USER -p$PASS
# }



###################################################################################
###                 SETTING UP THE BACKUP DIRECTORY                             ###
###################################################################################

if [ ! -d ${BACKUP_DIR_MAIN} ]; then 
  mkdir ${BACKUP_DIR_MAIN}
fi 

cd $DOCUMENT_ROOT_MAIN
zip -r $BACKUP_DIR_MAIN/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}${delimiter}$(date +"%Y-%m-%d-%H.%M.%S").zip ${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY} > /dev/null 2>&1
cd $SOURCE_DIR
  

WP_UPLOADS="wp-content/uploads"
WP_THEMES="wp-content/themes"
WP_PLUGINS="wp-content/plugins"

#/home/${WEBUSER}/public_html/corporate/acadia_wp_dev_init/
rsync -avpP --progress ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY}/${WP_UPLOADS}/ ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}/${WP_UPLOADS}/  

rsync -avpP --progress ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY}/${WP_THEMES}/ ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}/${WP_THEMES}/

rsync -avpP --progress ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_STAGING_MAIN_DIRECTORY}/${WP_PLUGINS}/ ${DOCUMENT_ROOT_MAIN}/${DOCUMENT_ROOT_LIVE_MAIN_DIRECTORY}/${WP_PLUGINS}/


mysqldump $DBNAME_PROD > ${BACKUP_DIR_MAIN}/${DBNAME_PROD}${delimiter}$(date +"%Y-%m-%d-%H.%M.%S").sql
  
mysql -Bse "SET SESSION sql_mode='ALLOW_INVALID_DATES'"

declare -A dbMainList
declare -a dbList=($DBNAME_STAGING $DBNAME_PROD)
for db in ${dbList[@]};do
  declare -a dbTableList=()
  for i in $(mysql -u $MYSQL_WEB_USER $db -e 'SHOW TABLES' | grep -v "Tables_in" | awk '{print $1}'); do
    dbTableList+=($i)
  done
  dbMainList["$db"]=${dbTableList[@]}
done

declare -a sourceDBTableList
sourceDBTableList=() # this will transform the array into an empty array
counter=0
progressCounter=0  #reinitialize later

for i in $(mysql -u $MYSQL_WEB_USER $SOURCE_DB -e 'SHOW TABLES' | grep -v "Tables_in" | awk '{print $1}'); do
  ((counter++))
  sourceDBTableList+=($i)
done

#PART-4.3- Check if databases having table differences
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

nonExistingTableCounter=1
for tab in "${tableNotExistsInDestinationDB[@]}";do 
  #YELLOWTXT "--> Table [$nonExistingTableCounter]: $tab --> Creating --> Importing Schema"
  #mysql -Bse "CREATE TABLE $DESTINATION_DB.$tab LIKE $SOURCE_DB.$tab"
  #mysql -Bse "INSERT INTO $DESTINATION_DB.$tab SELECT * from $SOURCE_DB.$tab"
  mysql -Bse "set @@SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';CREATE TABLE $DESTINATION_DB.$tab LIKE $SOURCE_DB.$tab;INSERT INTO $DESTINATION_DB.$tab SELECT * from $SOURCE_DB.$tab"
  ((nonExistingTableCounter++))
done

mysql -Bse "SELECT * FROM ${SOURCE_DB}.${ERRONOUS_DB_TABLE} WHERE ${ERRONOUS_DB_TABLE_COLUMN} LIKE '0000-00-00 00:00:00'"

mysql -Bse "UPDATE ${SOURCE_DB}.${ERRONOUS_DB_TABLE} SET ${ERRONOUS_DB_TABLE_COLUMN} = CURRENT_TIMESTAMP() WHERE ${ERRONOUS_DB_TABLE_COLUMN} LIKE '0000-00-00 00:00:00'"

for tab in "${sourceDBTableList[@]}";do
    ((progressCounter++))
    checksumOutput=$(pt-table-checksum h=$MYSQL_HOST,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,P=$MYSQL_PORT --set-vars innodb_lock_wait_timeout=30 --databases=$SOURCE_DB,$DESTINATION_DB --tables=$tab 2>&1)
    rows=$(echo "$checksumOutput"|grep -i $tab|awk '{print $4}')
    #rows=$(pt-table-checksum h=$MYSQL_HOST,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,P=$MYSQL_PORT --set-vars innodb_lock_wait_timeout=30 --databases=$SOURCE_DB,$DESTINATION_DB --tables=$tab 2>&1|grep -i $tab|awk '{print $4}')
    read -ra rows_as_arr -d ' '<<<"$rows"
    diffStatus="NO"
    if [[ $((rows_as_arr[0]-rows_as_arr[1])) -ne 0 ]];then 
        diffStatus="YES"
    fi
    echo "${tab},${rows_as_arr[0]},${rows_as_arr[1]},$diffStatus" >> $SYNC_CHECKSUM_TMP_FILE
    #sleep 1
done

progressCounter=0     #reinitialize
for tab in "${sourceDBTableList[@]}";do
  ((progressCounter++))
  pt-table-sync h=$MYSQL_HOST,P=$MYSQL_PORT,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,D=$SOURCE_DB,t=$tab h=$MYSQL_HOST,P=$MYSQL_PORT,u=$MYSQL_ROOT_USER,p=$MYSQL_ROOT_PASSWORD,D=$DESTINATION_DB --execute --verbose
done

#PART-4.8: Search and Replace the old string with new string 

cat > ${SOURCE_DIR}/${PHP_DB_TEXT_REPLACE_SCRIPT} <<EOF
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

chmod +x ${SOURCE_DIR}/${PHP_DB_TEXT_REPLACE_SCRIPT} # execution permission
php ${SOURCE_DIR}/${PHP_DB_TEXT_REPLACE_SCRIPT}      # run the php script and see the magic 