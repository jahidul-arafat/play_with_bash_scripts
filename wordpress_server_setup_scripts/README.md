 EC2 Node for X,Y and Z
==============================
Prepared By: Jahidul Arafat


PART_A: Node Information
========================
Instance ID: i-sdsdsd
Instance Type: t3a.xlarge [RAM/16GB vCPU/4  EBS only GP]
Availability Zone: us-east-1a
Private-Public IP Association:
172.31.1.54   --> X.X.X.X

PART-B: fstab setup for the node
================================
> hostnamectl set-hostname wordpress_sites.harriswebworks.com
> lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0         7:0    0  1.5G  1 loop /mnt/disk
nvme0n1     259:0    0   80G  0 disk
└─nvme0n1p1 259:1    0   80G  0 part /
nvme1n1     259:2    0  500G  0 disk
└─nvme1n1p1 259:3    0  500G  0 part /vzdata
nvme2n1     259:4    0   40G  0 disk
└─nvme2n1p1 259:6    0   40G  0 part [SWAP]
nvme3n1     259:5    0  500G  0 disk
└─nvme3n1p1 259:7    0  500G  0 part /backup

> cat /etc/fstab
# Created by anaconda on Sat Feb 29 12:05:47 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=388a99ed-9486-4a46-aeb6-06eaf6c47675 /                       xfs     defaults        0 0
UUID="d255312d-0983-466a-9d20-de07cb3042ef" /vzdata		           ext4	  defaults	  0 0
UUID="b991d4e1-a842-4ede-8fc0-f319e7614846" /backup 		         ext4    defaults 	  0 0
UUID="6b311dea-42a8-4c91-8777-f62e0e770a94" swap 		             swap	  defaults	  0 0

PART-C: Setup Tool used to setup the Main Container
===================================================
** Please read Setup.txt

PART-D: Container Lists and Os Version
=======================================
> vzlist -a
CTID      NPROC STATUS    IP_ADDR         HOSTNAME
101        324 running   172.31.4.91     
102        324 running   172.31.5.182    
103        324 running   172.31.9.33     

*** ssl certs {ssl.crt,ssl.pk,bundle.crt} are loaded from respective aws2 sites

PART-E: Setup tools used
=========================
@container
> cd /home
> ls -l

-rwxr--r--  1 root          root          10961 May 19 17:56 wp_1_function.sh   
-rwxr--r--  1 root          root          35239 May 19 17:56 wp_2.sh

** I have modified the structure of this setup tools and removed redundents

PART-F: Installation Logs
=====================================
101- ideraclinical.harriswebworks.com
---------------------------------------
[shop domain]: xyz.test.com
[webroot path]: /home/test/public_html
[phpmyadmin url]: ideraclinical.harriswebworks.com/phpMyAdmin  (wu_ideraclinical/8xUyB-TrG^mL2N}19045)
[phpmyadmin http auth name]: mysql
[phpmyadmin http auth pass]: 
[mysql host]: localhost
[mysql user]: 
[mysql pass]: 
[mysql database]: 
[mysql root pass]: ]
[ftp port]: 
[ftp user]: test
[ftp password]: 
[ftp allowed geoip]:
[ftp allowed ip]:
[percona toolkit]: https://www.percona.com/doc/percona-toolkit/LATEST/index.html
[database monitor]: /usr/local/bin/mytop
[mysql tuner]: /usr/local/bin/mysqltuner
[service alert]: /usr/local/bin/service-status-mail.sh
[opcache visu]:  ideraclinical.harriswebworks.com/opcache
[opcache tools {su - ideraclinical}]: php-c-status php-cc php-cc-file

102- iderapharma.harriswebworks.com
===================================
[shop domain]: xyz.com
[webroot path]: /home/test/public_html
[phpmyadmin url]: iderapharma.harriswebworks.com/phpMyAdmin (wu_iderapharma/8+u0wBgvSh4i7f$1187)
[phpmyadmin http auth name]: 
[phpmyadmin http auth pass]: 
[mysql host]: localhost
[mysql user]: 
[mysql pass]: 
[mysql database]: 
[mysql root pass]: 
[ftp port]: 7575
[ftp user]: 
[ftp password]: 
[ftp allowed geoip]:
[ftp allowed ip]:
[percona toolkit]: https://www.percona.com/doc/percona-toolkit/LATEST/index.html
[database monitor]: /usr/local/bin/mytop
[mysql tuner]: /usr/local/bin/mysqltuner
[service alert]: /usr/local/bin/service-status-mail.sh
[opcache visu]:  ..../opcache
[opcache tools {su - iderapharma}]: php-c-status php-cc php-cc-file

103- acadia.harriswebworks.com
================================
[shop domain]: 
[webroot path]: 
[phpmyadmin url]: acadia.harriswebworks.com/phpMyAdmin (wu_acadia/at-5gOE07%2T)D>23367)
[phpmyadmin http auth name]: 
[phpmyadmin http auth pass]: 
[mysql host]: localhost
[mysql user]: 
[mysql pass]: 
[mysql database]: acadia_live
[mysql root pass]: 
[ftp port]: 
[ftp user]: 
[ftp password]: 
[ftp allowed geoip]:
[ftp allowed ip]:
[percona toolkit]: https://www.percona.com/doc/percona-toolkit/LATEST/index.html
[database monitor]: /usr/local/bin/mytop
[mysql tuner]: /usr/local/bin/mysqltuner
[service alert]: /usr/local/bin/service-status-mail.sh
[opcache visu]:  ...../opcache
[opcache tools {su - acadia}]: php-c-status php-cc php-cc-file
