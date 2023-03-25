#! /bin/bash
MYSQL_ROOT_PASS='Hg)RAdjWeGB1mXt24470'
mysqldump -uroot -p${MYSQL_ROOT_PASS} --single-transaction --routines --triggers --events accu_catalog > accu_catalog.sql
mysqldump -uroot -p${MYSQL_ROOT_PASS} --single-transaction --routines --triggers --events accu_checkout > accu_checkout.sql
mysqldump -uroot -p${MYSQL_ROOT_PASS} --single-transaction --routines --triggers --events accu_sales > accu_sales.sql
