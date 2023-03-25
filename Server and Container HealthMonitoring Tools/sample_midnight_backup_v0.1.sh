#!/bin/bash
# This script is designed by Jahid Arafat, DevOps Engineer, HWW

###################################################################################
###                              GLOBAL VARIABLES                               ###
###################################################################################
ROOT_SERVER='Magento-S1'
SERVER_ROOT_DIR="/root"
CENTRAL_VZLIST_CMD='vzlist -o veid,hostname,ip,numproc,laverage,status,uptime,ostemplate,diskspace,physpages,numtcpsock,numpty,numfile'
DEFAULT_VZ="vzdata"         # this will be either vzdata[Default] or vzdata_b
TARGET_CT_DIR="/$DEFAULT_VZ/vz/root"
BACKUP_DIR_MAIN="/backup"
EXCLUDE_FILE_ONLY_NAME="backup_exclude_files.txt"
FILE_TO_BE_EXCLUDED="/root/$EXCLUDE_FILE_ONLY_NAME"
DB_BACKUP_SCRIPT_NAME="mysql_db_backup.sh"
BACKUP_DAYS=3

vzdata_tmp=$(vzlist -H -o ctid)
VZDATA_LIST=($vzdata_tmp) # this will generate the list of all containers into the server

declare -A ctToHostMapper
ctToHostMapper[103]=florabella
ctToHostMapper[105]=broken
ctToHostMapper[109]=boundless
ctToHostMapper[112]=training
ctToHostMapper[116]=polylokdoc
ctToHostMapper[117]=zabel
ctToHostMapper[120]=florabella
ctToHostMapper[123]=polylok
ctToHostMapper[144]=edco
ctToHostMapper[145]=provence
ctToHostMapper[159]=thecnstore
ctToHostMapper[160]=cn
ctToHostMapper[161]=cndev
ctToHostMapper[170]=darterpim


declare -A ctValidityChecker

###################################################################################
###                            DATABASE MAPPING                                 ###
###################################################################################
declare -A dbToHostMapper
dbToHostMapper[103]="florabel_db"
dbToHostMapper[105]="md_catalog"
dbToHostMapper[109]="m2d_boundless,m2d_checkout,m2d_sales"
dbToHostMapper[112]="md_checkout,md_sales,md_training"
dbToHostMapper[117]="zabel"
dbToHostMapper[120]="florabella_catalog"
dbToHostMapper[123]="md_polylok"
dbToHostMapper[144]="edco"
dbToHostMapper[145]="md_provence"
dbToHostMapper[159]="cn_catalog,cn_catalog,cn_sales"
dbToHostMapper[160]="cn_catalog,cn_catalog,cn_sales"
dbToHostMapper[161]="cn_catalog,cn_catalog,cn_sales"
dbToHostMapper[170]="akeneo_pim_darter,akeneo_pim_new,akeneo_pim_training"


declare -A dbToHostRootPasswordMapper
dbToHostRootPasswordMapper[103]=""
dbToHostRootPasswordMapper[105]=""
dbToHostRootPasswordMapper[109]=""
dbToHostRootPasswordMapper[112]=""
dbToHostRootPasswordMapper[117]=""
dbToHostRootPasswordMapper[120]=""
dbToHostRootPasswordMapper[123]=""
dbToHostRootPasswordMapper[144]=""
dbToHostRootPasswordMapper[145]=""
dbToHostRootPasswordMapper[159]=""
dbToHostRootPasswordMapper[160]=""
dbToHostRootPasswordMapper[161]=""
dbToHostRootPasswordMapper[170]=""





###################################################################################
###                            PROGRESS BAR AND PAUSE                           ###
###################################################################################

function pause() {
   read -p "$*"
}

###################################################################################
###                              FUNCTIONS                                      ###
###################################################################################
function in_array () {
    local array="$1[@]"
    local seeking=$2
    local in=0
    for element in "${!array}"; do
        if [[ $element == "$seeking" ]]; then
            in=1
            break
        fi
    done
    return $in
}

function checkSubString(){
  STR="VEID 1187 deleted unmounted down"
  SUB="down"
  STATUS="UP"

  if [[ "$STR" == *"$SUB"* ]]; then
    STATUS="DOWN"
  fi

  echo $STATUS
}

#remove files older than N days for each container
function removeFilesOlderThanNDays(){
  #$BACKUP_DIR_MAIN $DEFAULT_VZ $CT
  pause "Removing *.zip files from $1/$2/$3 older than $BACKUP_DAYS ... Enter to Continue"
  find $1/$2/$3 -name "*.zip" -type f -mtime +$BACKUP_DAYS -exec rm -f {} \;
  echo ""
}


#settingUpTheVZBackupDir $BACKUP_DIR_MAIN $DEFAULT_VZ
function settingUpTheVZBackupDir(){
  # $1-> $BACKUP_DIR_MAIN
  # $2-> $DEFAULT_VZ
  BACKUPDIR_VZ="$1/$2"
  #BACKUPDIR_VZ="$BACKUP_DIR_MAIN/$DEFAULT_VZ"
  if [[ ! -d ${BACKUPDIR_VZ} ]] ;then
    mkdir ${BACKUPDIR_VZ}
  else
    echo -e "DIR: [$BACKUPDIR_VZ] is already exists... Skipping..."
  fi
}


#settingUpTheContainerBackupDir $BACKUP_DIR_MAIN $DEFAULT_VZ $CT
# this function cant be 
function settingUpTheContainerBackupDir(){
  # $1-> $BACKUP_DIR_MAIN
  # $2-> $DEFAULT_VZ
  # $3-> $CT
  #BACKUPDIR_VZ_CT="$BACKUP_DIR_MAIN/$DEFAULT_VZ/$CT"
  BACKUPDIR_VZ_CT="$1/$2/$3"
  if ([ ! -d ${BACKUPDIR_VZ_CT} ] && [ ! -z ${ctValidityChecker[$3]} ]) ;then
    mkdir ${BACKUPDIR_VZ_CT}
  else
    echo -e "DIR: [$BACKUPDIR_VZ_CT] is already exits or you may have passed invalid container ID ... Skipping..."
  fi

}

function availableContainers() {
  echo -e "This function will list all the available containers in ${ROOT_SERVER}"
  containerCount=$(vzlist|wc -l)
  echo -e "Server/ContainerCount: ${ROOT_SERVER}/${containerCount}"
  read -p "---> Do you want to see the ${ROOT_SERVER} container list? [y/n][y]: " response
  if [ "${response}" == "y" ];then
    $CENTRAL_VZLIST_CMD
  else
    echo -e "Container Details Listing .. Skipped...!!!"
  fi
  pause "----> Press [Enter] key to proceed ..."
}

#  isContainerValid $passedCTList
#
function isContainerValid(){
  invalidCTCount=0
  for item in ${passedCTList[@]};do
    #[ ! ${ctToHostMapper[$item]+_} ];                                                  <--- FLAG 01
    ctValidityChecker[$item]=${ctToHostMapper[$item]+true}
  done

  for key in ${!ctValidityChecker[@]};do
    if [ -z ${ctValidityChecker[$key]} ];then
      pause "Invalid Container: [$key]---> Press [Enter] key to proceed ..."
      ((invalidCTCount++))
    else
      echo "$key -->${ctValidityChecker[$key]} "
    fi
  done
  if [[ $invalidCTCount -gt 0 ]];then
    pause "${invalidCTCount}X detected and system will not proceed with backup untill all valid --> Press Enter to Exit"
    #exit 1
  fi
}

function readFileContent(){
  cat $1
}

function createContainerSpecificBackupExcludeFile(){
  # $1 --> goToTheTopOfPublic_html # /vadata_b/vz/root/103/home/boundless
  if [[ ! -f "$1/$EXCLUDE_FILE_ONLY_NAME" ]]; then 
    echo "$1/$EXCLUDE_FILE_ONLY_NAME doesn't exists, we are creating this for you .."
    cp $FILE_TO_BE_EXCLUDED $1

    pause "Backup Exclude File Creation Successful .. Do you want to check the file .. Enter to Continue"
    read -p 'Your Choice: [Y/n] ' choice

    if ([ $choice == "Y" ] || [ $choice == "y" ]); then 
      readFileContent $1/$EXCLUDE_FILE_ONLY_NAME #<<<<<---T
    fi

    pause "Do you want to modify the Backup Exclude File: $1/$EXCLUDE_FILE_ONLY_NAME .. Enter to Continue "

    read -p 'Enter Your Choice: [Y/n]: ' choice
    if ([ $choice == "Y" ] || [ $choice == "y" ]); then 
      pause "Instructions
      --------------------
      1. Open another terminal (Terminal 2)
      2. Go to $1/$EXCLUDE_FILE_ONLY_NAME
      3. Edit the file
      4. Close Terminal 2
      5. Return back to Main Terminal

      If You are Done .. Press Enter 
      "
    fi
  fi
}


function createDBBackupScript(){

  #$1--> $CT
  #$BACKUPDIR_VZ_CT $TARGET_CT_DIR $CT
  goToTheTopOfPublic_html="$2/$3/home/${ctToHostMapper[$3]}"
  IFS=',' read -r -a tmpArray <<< "${dbToHostMapper[$3]}"

  cat > $goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME <<EOF
#! /bin/bash
MYSQL_ROOT_PASS="${dbToHostRootPasswordMapper[$3]}"

EOF
  for dbName in ${tmpArray[@]};do
    echo "mysqldump -uroot -p\${MYSQL_ROOT_PASS} --single-transaction --routines --triggers --events ${dbName} >> ${dbName}.sql" >> $goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME
  done

  chmod +x $goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME

  pause "Database Backup Script Creation Completed ... Press Enter to See"
  readFileContent $goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME
  pause "If Correct, Enter to Continue ..."

  unset IFS

  vzctl exec ${CT} $goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME
  zip $goToTheTopOfPublic_html/${ctToHostMapper[$3]}_db.zip  $goToTheTopOfPublic_html/*.sql
  mv $goToTheTopOfPublic_html/${ctToHostMapper[$3]}_db.zip $BACKUPDIR_VZ_CT
  mv $BACKUPDIR_VZ_CT/${ctToHostMapper[$3]}_db.zip $BACKUPDIR_VZ_CT/${ctToHostMapper[$3]}_db-$(date +"%Y-%m-%d").zip
}

#gzipTheDocumentRoot $BACKUPDIR_VZ_CT $TARGET_CT_DIR $CT
function gzipTheDocumentRoot(){
  pause "---> Are you sure you want to continue ---> Press [ENTER]"
  pause "---> Are you sure you want to continue ---> Press [ENTER]"

  # $1 -> $BACKUPDIR_VZ_CT = /backup/vzdata_b/103
  # $2 -> $TARGET_CT_DIR   = /vadata_b/vz/root
  # $3 -> $CT

  goToTheTopOfPublic_html="$2/$3/home/${ctToHostMapper[$3]}" #/vadata_b/vz/root/103/home/boundless
  createContainerSpecificBackupExcludeFile $goToTheTopOfPublic_html
  getTheContainerSpecificBackupExcludeFile="$goToTheTopOfPublic_html/$EXCLUDE_FILE_ONLY_NAME" # this time file is must available
  
  ctDocRootDir="$2/$3/home/${ctToHostMapper[$3]}/public_html"
  #ctDocRootDir="$TARGET_CT_DIR/$CT/home/${ctToHostMapper[$CT]}/public_html"  #c
  #BACKUPDIR_VZ_CT="/backup/vzdata_b/120"    #c
  #tarFile_tmp="$BACKUPDIR_VZ_CT/public_html.tar" #c
  tarFile_tmp="$1/public_html.tar"

  cd $ctDocRootDir
  


  tar -cvf $tarFile_tmp -X $getTheContainerSpecificBackupExcludeFile .

  if [ -d ./vendor/harriswebworks ];then
    tar -rvf $tarFile_tmp ./vendor/harriswebworks
  fi
  if [ -d ./vendor/magento ];then
    tar -rvf $tarFile_tmp ./vendor/magento
  fi

  #gzip -c $tarFile_tmp > $BACKUPDIR_VZ_CT/public_html-$(date +"%Y-%m-%d").tar.gz
  gzip -c $tarFile_tmp > $1/public_html-$(date +"%Y-%m-%d").tar.gz
  rm -rf $tarFile_tmp
  cd $SERVER_ROOT_DIR
  pause "---> GZIPPING FINISHED [$3: ${ctToHostMapper[$3]}] ---> Press [Enter] to continue ..."
}

#checkIfContainerInVzdataOrVzdataB $CT
function checkIfContainerInVzdataOrVzdataB(){
    DEFAULT_VZ="vzdata"                     #resetting
    TARGET_CT_DIR="/$DEFAULT_VZ/vz/root"    #resetting
    is_ct_in_vzdata=$(test -d "$TARGET_CT_DIR/$1" && echo "yes"|| echo "no")
    if [[ $is_ct_in_vzdata == "no" ]];then
      DEFAULT_VZ="vzdata_b"
    fi
    TARGET_CT_DIR="/$DEFAULT_VZ/vz/root"
    BACKUPDIR_VZ="$BACKUP_DIR_MAIN/$DEFAULT_VZ"
    BACKUPDIR_VZ_CT="$BACKUP_DIR_MAIN/$DEFAULT_VZ/$CT"

    echo $TARGET_CT_DIR
    echo $BACKUPDIR_VZ
    echo $BACKUPDIR_VZ_CT
    echo ""
}

function traversingAndDocrootBackup_UserDependent(){
  availableContainers

  passedCTList=("$@")
  echo -e "Number of Container Enlisted for backup: $#"
  pause "---> Press [Enter]"
  isContainerValid    #isContainerValid $passedCTList

  for CT in ${passedCTList[@]};do
    checkIfContainerInVzdataOrVzdataB $CT
    settingUpTheVZBackupDir $BACKUP_DIR_MAIN $DEFAULT_VZ
    settingUpTheContainerBackupDir $BACKUP_DIR_MAIN $DEFAULT_VZ $CT

    #removing files older than N days
    removeFilesOlderThanNDays $BACKUP_DIR_MAIN $DEFAULT_VZ $CT
    
    #gzip the document root
    gzipTheDocumentRoot $BACKUPDIR_VZ_CT $TARGET_CT_DIR $CT

    #createDBBackupScript()
    createDBBackupScript $BACKUPDIR_VZ_CT $TARGET_CT_DIR $CT

    # Executing the DB backup script

  done
}


#----------------------- DRAFT DRAFT DRAFT [STARTS]---------------------------------------------------#
#tested dummy solution
#tar cvf test.tar --exclude=test/vendor test
#tar rvf test.tar test/vendor/harriswebworks
#tar rvf test.tar test/vendor/magento
#gzip test.tar
#tar -tf test.tar.gz

# exclude the following files while backup
#https://www.cyberciti.biz/faq/exclude-certain-files-when-creating-a-tarball-using-tar-command/
# hints
#public_html- exclude
#-------------------------------------------------------------------
#.git
#var/
#pub/static
#pub/media/catalog/product/cache
#exclude everything otherthen vendor/harriswebworks and vendor/magento
#generated

#cm_redis_tools
#dev
#lib
#node_modules
#opcache
#phpserver
#setup
#update



#function traversingIntoTheContainer_BackupAutomation(){
#  for CT in ${VZDATA_LIST[@]};do
#    echo -e "Into the Container: $CT"
#    is_ct_in_skipped_list=$(in_array containersToBeSkipped $CT && echo "yes" || echo "no" )
#    if [[ $ct_in_skipped_list == "yes" ]];then
#      echo -e "    >>>> Container ID : $CT is skipping ..."
#      continue
#    fi
#    # check if a folder name with $CT is found in vzdata or vzdata_b
#    checkIfContainerInVzdataOrVzdataB

#    settingUpTheVZBackupDir $BACKUP_DIR_MAIN $DEFAULT_VZ
#    settingUpTheContainerBackupDir $BACKUP_DIR_MAIN $DEFAULT_VZ $CT

#    #gzip the document root
#    gzipTheDocumentRoot $BACKUPDIR_VZ_CT $TARGET_CT_DIR $CT

#    # entering into the container and taking database backup at /home/$CT/ and moving the dbbackup to /backup dir
#  done
#}

#----------------------- DRAFT DRAFT DRAFT [ENDS]---------------------------------------------------#
