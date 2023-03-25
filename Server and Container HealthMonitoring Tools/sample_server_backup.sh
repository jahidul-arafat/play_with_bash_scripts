#! /bin/bash
function settingUpTheVZBackupDir(){
  # $1-> $BACKUP_DIR_MAIN
  # $2-> $DEFAULT_VZ
  BACKUPDIR_VZ="/vz/backup"
  if [ ! -d ${BACKUPDIR_VZ} ];then
    mkdir ${BACKUPDIR_VZ}
  fi
}

function settingUpTheContainerBackupDir(){
  BACKUPDIR_CT_101="/vz/backup/101"
  BACKUPDIR_CT_102="/vz/backup/102"
  if [ ! -d ${BACKUPDIR_CT_101} ];then
    mkdir ${BACKUPDIR_CT_101}
  fi

  if [ ! -d ${BACKUPDIR_CT_102} ];then
    mkdir ${BACKUPDIR_CT_102}
  fi
}

function removeFilesOlderThan3Days(){
  find /vz/backup/101 -name "*.sql" -type f -mtime +3 -exec rm -f {} \;
  find /vz/backup/101 -name "*.zip" -type f -mtime +3 -exec rm -f {} \;
  find /vz/backup/102 -name "*.sql" -type f -mtime +3 -exec rm -f {} \;
  find /vz/backup/102 -name "*.zip" -type f -mtime +3 -exec rm -f {} \;
}

function accuDBBackup_101(){
  mv /vz/root/101/accu_catalog.sql /vz/backup/101
  mv /vz/root/101/accu_checkout.sql /vz/backup/101
  mv /vz/root/101/accu_sales.sql /vz/backup/101

  rm -rf /vz/root/101/accu_catalog.sql >/dev/null 2>&1
  rm -rf /vz/root/101/accu_checkout.sql >/dev/null 2>&1
  rm -rf /vz/root/101/accu_sales.sql >/dev/null 2>&1

  cd /vz/backup/101
  zip accu_db_live-$(date +"%Y-%m-%d").zip *.sql
  cd /root
}

function accuDBBackup_102(){
  mv /vz/root/102/accu_catalog.sql /vz/backup/102
  mv /vz/root/102/accu_checkout.sql /vz/backup/102
  mv /vz/root/102/accu_sales.sql /vz/backup/102

  rm -rf /vz/root/102/accu_catalog.sql >/dev/null 2>&1
  rm -rf /vz/root/102/accu_checkout.sql >/dev/null 2>&1
  rm -rf /vz/root/102/accu_sales.sql >/dev/null 2>&1

  cd /vz/backup/102
  zip accu_db_dev-$(date +"%Y-%m-%d").zip *.sql
  cd /root
}

settingUpTheVZBackupDir
settingUpTheContainerBackupDir
removeFilesOlderThan3Days
accuDBBackup_101
accuDBBackup_102


