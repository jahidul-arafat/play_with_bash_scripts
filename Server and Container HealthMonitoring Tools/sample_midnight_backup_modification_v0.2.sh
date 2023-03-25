#!/bin/bash
# This script is designed by Jahid Arafat, DevOps Engineer, HWW

###################################################################################
###                              GLOBAL VARIABLES                               ###
###################################################################################
SERVER_ROOT_DIR="/root"
#CENTRAL_VZLIST_CMD='vzlist -o veid,hostname,ip,numproc,laverage,status,uptime,ostemplate,diskspace,physpages,numtcpsock,numpty,numfile'
CENTRAL_VZLIST_CMD='vzlist -o veid,hostname,ip,status,uptime,ostemplate'

BACKUP_DIR_MAIN="/backup"
EXCLUDE_FILE_ONLY_NAME="backup_exclude_files.txt"
FILE_TO_BE_EXCLUDED="/root/$EXCLUDE_FILE_ONLY_NAME"
DB_BACKUP_SCRIPT_NAME="mysql_db_backup.sh"
BACKUP_DAYS=3

#vzdata_tmp=$(vzlist -H -o ctid)
#VZDATA_LIST=($vzdata_tmp) # this will generate the list of all containers into the server

declare -A ctToHostMapper
declare -A ctValidityChecker
declare -A dbToHostMapper
declare -A dbToHostRootPasswordMapper 

declare -A ctToAbstractionMapper


###################################################################################
###                            SERVER: MAGENTO-S1                               ###
###################################################################################
function Magento_S1(){
  ROOT_SERVER='Magento-S1'
  DEFAULT_VZ="vzdata"         # this will be either vzdata[Default] or vzdata_b
  TARGET_CT_DIR="/$DEFAULT_VZ/vz/root"

  #Defining the container and hosts
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

  # Database Mapper
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

  # Database Password Mapper
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

}

###################################################################################
###                            SERVER: AccuStandard                             ###
###################################################################################
function Accustandard(){
  ROOT_SERVER='Accustandard'
  DEFAULT_VZ="vz"         # this will be either vzdata[Default] or vzdata_b
  TARGET_CT_DIR="/$DEFAULT_VZ/root"

  #Defining the container and hosts
  ctToHostMapper[101]=accustandard #accunv.harriswebworks.com 
  ctToHostMapper[102]=accustandard #accudev.harriswebworks.com

  # Database Mapper
  dbToHostMapper[101]="accu_catalog,accu_checkout,accu_sales"
  dbToHostMapper[102]="accu_catalog,accu_checkout,accu_sales"
  

  # Database Password Mapper
  dbToHostRootPasswordMapper[101]="" #<---- Problematic Password
  dbToHostRootPasswordMapper[102]=""
}

###################################################################################
###                            SERVER: DARTER                                   ###
###################################################################################
function Darter(){
  ROOT_SERVER='Darter'
  DEFAULT_VZ="vz"         # this will be either vzdata[Default] or vzdata_b
  TARGET_CT_DIR="/$DEFAULT_VZ/root"

  #Defining the container and hosts
  ctToHostMapper[101]=dartergroup #b8ac8c6e-f388-4bc3-9e97-145bcf2eea22 #dartergroup.harriswebworks.com 
  ctToHostMapper[102]=devdarter   #18cee4aa-93d0-44e3-a855-970dd6873066 #devdarter.harriswebworks.com

  #Defining the container and their path abstractions
  ctToAbstractionMapper[101]="b8ac8c6e-f388-4bc3-9e97-145bcf2eea22"
  ctToAbstractionMapper[102]="18cee4aa-93d0-44e3-a855-970dd6873066"

  # Database Mapper
  dbToHostMapper[101]="mage_darter"
  dbToHostMapper[102]="mage_darter"
  

  # Database Password Mapper
  dbToHostRootPasswordMapper[101]=""
  dbToHostRootPasswordMapper[102]=""
}

###################################################################################
###                            SERVER: SCANPAN                                  ###
###################################################################################
function Scanpan(){
  ROOT_SERVER='Scanpan'
  DEFAULT_VZ="vz"         # this will be either vzdata[Default] or vzdata_b
  TARGET_CT_DIR="/$DEFAULT_VZ/root"

  #Defining the container and hosts
  ctToHostMapper[101]=scanpan           #c1e19c3f-2f96-4e24-acc9-e2554ce4a223 #scanpan.harriswebworks.com 
  ctToHostMapper[102]=brundbyscanpan    #037768dd-5b39-4e28-b140-069f6d1b3c4d #brundbyscanpan.harriswebworks.com
  ctToHostMapper[103]=scanpansg         #c87d599d-6a24-4b52-8def-48ac48106dda #scanpansg.harriswebworks.com


  #Defining the container and their path abstractions
  ctToAbstractionMapper[101]="c1e19c3f-2f96-4e24-acc9-e2554ce4a223"
  ctToAbstractionMapper[102]="037768dd-5b39-4e28-b140-069f6d1b3c4d"
  ctToAbstractionMapper[103]="c87d599d-6a24-4b52-8def-48ac48106dda"

  # Database Mapper
  dbToHostMapper[101]="m2d_scanpan"
  dbToHostMapper[102]="m2d_brundbyscanpan"
  dbToHostMapper[103]="m2d_scanpansg"
  

  # Database Password Mapper
  dbToHostRootPasswordMapper[101]="" #<---- Problematic Password
  dbToHostRootPasswordMapper[102]=""
  dbToHostRootPasswordMapper[103]=""
}


###################################################################################
###                            SERVER: RUBITRUX                                 ###
###################################################################################
function Rubitrux(){
  ROOT_SERVER='Rubitrux'
  DEFAULT_VZ="vz"         # this will be either vzdata[Default] or vzdata_b
  TARGET_CT_DIR="/$DEFAULT_VZ/root"

  #Defining the container and hosts
  ctToHostMapper[101]=rubitrux        #b7313faa-a52b-4cef-ace5-32972170cf30 #rubi.harriswebworks.com
  ctToHostMapper[104]=rubitrux        #845d3b06-30f8-43e3-be16-5cbeeb71fa8b #rubidev.harriswebworks.com 

  #Defining the container and their path abstractions
  ctToAbstractionMapper[101]="b7313faa-a52b-4cef-ace5-32972170cf30"
  ctToAbstractionMapper[104]="845d3b06-30f8-43e3-be16-5cbeeb71fa8b"

  # Database Mapper
  dbToHostMapper[101]="m2d_rubitrux"
  dbToHostMapper[104]="m2d_rubitrux"
  

  # Database Password Mapper
  dbToHostRootPasswordMapper[101]=""
  dbToHostRootPasswordMapper[104]=""
}



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

#Unutilized Function
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
  pause "Removing *.zip files from $1/$2/$3 older than $BACKUP_DAYS Days... Enter to Continue"
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
    mkdir -p ${BACKUPDIR_VZ}
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
    mkdir -p ${BACKUPDIR_VZ_CT}
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
  #$BACKUPDIR_VZ_CT $TARGET_CT_DIR $CT
  if ([ $detectTheServer == "magento-s1" ] || [ $detectTheServer == "accu" ]);then
    goToTheTopOfPublic_html="$2/$3/home/${ctToHostMapper[$3]}"
  elif ([ $detectTheServer == "darter" ] || [ $detectTheServer == "rubi" ] || [ $detectTheServer == "scanpan" ]);then 
    goToTheTopOfPublic_html="$2/${ctToAbstractionMapper[$3]}/home/${ctToHostMapper[$3]}"
  fi

  IFS=',' read -r -a tmpArray <<< "${dbToHostMapper[$3]}"

  if [[ ! -f "$goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME" ]]; then
  cat > $goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME <<EOF
#! /bin/bash
MYSQL_ROOT_PASS="${dbToHostRootPasswordMapper[$3]}"

EOF
  for dbName in ${tmpArray[@]};do
    echo "mysqldump -uroot -p\${MYSQL_ROOT_PASS} --single-transaction --routines --triggers --events ${dbName} >> /home/${ctToHostMapper[$3]}/${dbName}.sql" >> $goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME
  done
  fi

  chmod +x $goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME

  pause "Database Backup Script Creation Completed ... Press Enter to See"
  readFileContent $goToTheTopOfPublic_html/$DB_BACKUP_SCRIPT_NAME
  pause "If Correct, Enter to Continue ..."

  unset IFS


  vzctl exec ${CT} /home/${ctToHostMapper[$3]}/$DB_BACKUP_SCRIPT_NAME #<<----- Error Solved
  zip $goToTheTopOfPublic_html/${ctToHostMapper[$3]}_db.zip  $goToTheTopOfPublic_html/*.sql # you can improve this with a regex
  rm -rf $goToTheTopOfPublic_html/*.sql
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

  if ([ $detectTheServer == "magento-s1" ] || [ $detectTheServer == "accu" ]);then
    goToTheTopOfPublic_html="$2/$3/home/${ctToHostMapper[$3]}" #/vadata_b/vz/root/103/home/boundless
  elif ([ $detectTheServer == "darter" ] || [ $detectTheServer == "rubi" ] || [ $detectTheServer == "scanpan" ]);then
    goToTheTopOfPublic_html="$2/${ctToAbstractionMapper[$3]}/home/${ctToHostMapper[$3]}"
  fi


  createContainerSpecificBackupExcludeFile $goToTheTopOfPublic_html
  getTheContainerSpecificBackupExcludeFile="$goToTheTopOfPublic_html/$EXCLUDE_FILE_ONLY_NAME" # this time file is must available
  
  ctDocRootDir="$goToTheTopOfPublic_html/public_html"
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
  #rm -rf $tarFile_tmp
  cd $SERVER_ROOT_DIR
  pause "---> GZIPPING FINISHED [$3: ${ctToHostMapper[$3]}] ---> Press [Enter] to continue ..."
}

#checkIfContainerInVzdataOrVzdataB $CT
function checkIfContainerInVzdataOrVzdataBOrVZ(){
  #$detectTheServer $CT
  if [[ $1 == "magento-s1" ]];then
    DEFAULT_VZ="vzdata"                     #resetting
    TARGET_CT_DIR="/$DEFAULT_VZ/vz/root"    #resetting
    is_ct_in_vzdata=$(test -d "$TARGET_CT_DIR/$2" && echo "yes"|| echo "no")
    if [[ $is_ct_in_vzdata == "no" ]];then
      DEFAULT_VZ="vzdata_b"
    fi
    TARGET_CT_DIR="/$DEFAULT_VZ/vz/root"
    
    
  else
    DEFAULT_VZ="vz"                     #resetting
    TARGET_CT_DIR="/$DEFAULT_VZ/root"    #resetting
    is_ct_in_vz=$(test -d "$TARGET_CT_DIR/$2" && echo "yes"|| echo "no")
    if [[ $is_ct_in_vzdata == "no" ]];then
      pause "---> Container $2 Doesn't exists... System will not continue with this... Press to Exit"
      exit 1
    fi

  BACKUPDIR_VZ="$BACKUP_DIR_MAIN/$DEFAULT_VZ"
  BACKUPDIR_VZ_CT="$BACKUP_DIR_MAIN/$DEFAULT_VZ/$CT" 

  fi 
  

  echo $TARGET_CT_DIR
  echo $BACKUPDIR_VZ
  echo $BACKUPDIR_VZ_CT
  echo ""
}


function loadingTheServerSpecificGlobalVariables(){
  # $1--> detectTheServer
  ##Loading the Server Specific Global Variables
  serverName="$1"
  if [[ $serverName == "magento-s1" ]];then 
    Magento_S1
  elif [[ $serverName == "accu" ]];then 
    Accustandard
  elif [[ $serverName == "darter" ]];then
    Darter
  elif [[ $serverName == "rubi" ]];then
    Rubitrux
  elif [[ $serverName == "scanpan" ]];then
    Scanpan   
  fi
}

#. ./test.sh && traversingAndDocrootBackup_UserDependent magento-s1 109 103
function traversingAndDocrootBackup_UserDependent(){
  availableContainers

  declare -a passedCTList
  passedArgumentList=("$@")
  argLength=${#passedArgumentList[@]}
  passedCTList=("${passedArgumentList[@]:1:$argLength}")
  detectTheServer=${passedArgumentList[0]}

  loadingTheServerSpecificGlobalVariables $detectTheServer
  
  echo -e "Number of Containers Enlisted for Backup: ${#passedCTList[@]}"
  pause "---> Press [Enter]"
  isContainerValid    #isContainerValid $passedCTList

  for CT in ${passedCTList[@]};do
    checkIfContainerInVzdataOrVzdataBOrVZ $detectTheServer $CT
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