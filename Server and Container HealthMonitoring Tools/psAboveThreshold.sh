#!/bin/bash

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

function redisChecker(){
    localhost="127.0.0.1"
    declare -A redisInstances
    redisInstances=([6379]="cache" [6380]="session" [6381]="page cache")
    pattern="*-11*"
    
    #Step-1: Check your php version and check whether the phpRedis Module is loaded
    echo -e "${bold}Part-1: PHP Version and the phpRedis Module: (OK/NOT)${nf}"
    echo -e "\t${dash}<1a> Checking the PHP Version"
    echo -e "\t${dash}$(php -v|head -n 1)"
    echo -e "\t${dash}<1b> Checking the phpRedis Module: "
    echo -e "\t${dash}$(php -m|grep redis)"
    
    #Step-2: Execute the following redis cli tools for all the redis instances
    for instance in "${!redisInstances[@]}"
    do
        echo -e "$bold Redis@$instance/${redisInstances[$instance]}${nf}
                ---------------------------------------------------------
                <2a> Check redis@$instance version:
                > redis-cli --version $nc
                
                <2b> Check the connections and memory used by redis@$instance at the current state:
                > redis-cli -h $localhost -p $instance --stat
                
                <2c> Get the redis@$instance server information: process_id|tcp_port|config_file
                > redis-cli -h $localhost -p $instance info server | egrep 'process_id|tcp_port|config_file\n'
        
                <2d> Get redis@$instance basic information: role|used_memory_peak|maxmemory|evicted_keys|uptime_in_days
                > redis-cli -h $localhost -p $instance info | egrep --color '(role|used_memory_peak|maxmemory|evicted_keys|uptime_in_days)\n'
        
                <2e> Print all the commands received by a Redis instance (Be careful in using it)
                > redis-cli -h $localhost -p $instance monitor
        
                <2f> Check the keys in the redis server now (Top 10 Keys)/with pattern matching
                > redis-cli -h $localhost -p $instance --scan|head -10
                > redis-cli -h $localhost -p $instance --scan --pattern '$pattern'|wc -l
        
                <2g> Check the redis@$instance bigkey/#numberofkeys/keyspace
                > redis-cli -h $localhost -p $instance --bigkeys"
    done
    
    
}

function checkIfMultiplePersonLoggedinToTheSystem(){
    multiLoginCount=$(last|grep "still logged in"|wc -l)
    multiLoginMsg=$(last|grep "still logged in")
    if [[ $multiLogin -gt 1 ]]
    then
        echo    "Multiple Login Detected
                $multiLoginMsg"
    else
        echo "Login count $multiLoginCount"
    fi
    
}

function checkMajorServiceLoad(){
    #Part-1: Setting the directories
	tmpUnitFile=$1
    envPhpFile=$2 # This is an important setting for Magento 2, magento 1 doesnt have it (init.xml)
    
    #Part-2: Flag and Array Declaration
	allServiceFlag=1 # This will help to check whether all the core services loaded successfully
	declare -A processIpPort # an associative array for the service port keypair
	declare -A serviceInstances # an associative array to track the number of instances a core service has
    declare -a failedServiceModule
	
    # Part-3: List of Major Services to be loaded
	majorServices=(elasticsearch httpd mysqld php-fpm proftpd redis sendmail sshd abc)
	systemctl list-units --type=service --state=active > $tmpUnitFile
	for service in "${majorServices[@]}"
	do
		instanceCounter=$(cat $tmpUnitFile|grep $service|wc -l)
		serviceInstances["$service"]=$instanceCounter
		if [[ $instanceCounter -eq 0 ]]
		then
			allServiceFlag=0
			#echo "Failed: $service"
            failedServiceModule+=($service)
		else
			while read line;
			do
				portIP=$(echo $line|awk '{print $4}'|xargs)
				processService=$(echo $line|awk '{print $7}')
				
                #IFS='/' # Better not to use IFS here
				#read -ra TMP <<< "$processService" # related to IFS, thats why commented
                
				arrIN=(${processService//// })
				processIpPort["${arrIN[1]}"]+="$portIP "
				
			done < <(netstat -tulpn|grep "$service") #While ENDS
		fi
	done # for ENDS

	# Part-4: Printing the service load report #Report-1
    echo ""
    echo -e "${bold}${blue}Report-01: Core Service Load Report ${nc}${nf}"
    printf "${bold}Module%10sInstances${normal}\n-------------------------\n${nf}"
	for key in "${!serviceInstances[@]}"
	do
		#printf "$key%10s${serviceInstances[$key]}\n"
        printf "%-20s %-10d\n" $key ${serviceInstances[$key]}
	done
    if [[ $allServiceFlag -eq 0 ]]
    then
        failCounter=1
        echo -e "\n${red}***Note: Following Service Module Failed to Start:${nc}"
        for item in "$failedServiceModule[@]"
        do
          echo -e "<$failCounter> $item\n"
          ((failCounter+=1))
        done
    else
        echo -e "\n${bold}${red}***Note: All Core Modules started successfully${nc}${nf}"
    fi

	# Part-5: Printing the Service and IPPort Pair Information #Report-2
    echo ""
    echo -e "${bold}${blue}Report-02: On Process/IP/Port Pair Information${nc}${nf}"
    printf "${bold}Service%20sIP/Port${nf}\n------------------------------------------\n"
    for key in "${!processIpPort[@]}"
    do
        #printf "$key%10s${processIpPort[$key]}\n"
        printf "%-20s %20s\n" $key ${processIpPort[$key]}
    done

}

function checkFileExists(){
	if [[ ! -f "$1" ]]
	then
		touch $1
	fi
}
function psAboveThreshold(){
	#topMostProcessFile="~/topMostProcesses.txt"
	#touch $topMostProcessFile
	#declare -A processPortList
	
	ramThreshold=0.5
	maxmemUsedLimit=25.0
	memUsed=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
	memFree=$(free | grep Mem | awk '{print $4/$2 * 100.0}')

	psString=""
	NOW=$(date +"%e/%b/%Y,%r")
	psString+="${bold}${blue}Report-03: TOP RAM KILLER @${NOW}${nc}${nf}\n"	
	#top -b -n 1|sed -e "1,7d"|while read line;
	header="${bold}Process\tRAM\tDayStarted\tCommand${nf}\n--------------------------------------------------------------------\n"
	psString+="${header}"
	
	if (( $(echo "$memUsed > $maxmemUsedLimit"|bc -l) ))
        then
		while read line;
		do
			psName=$(echo $line|awk '{print $1}'|xargs)
			psName="${psName//+}"	
			ramUsage=$(echo $line|awk '{print $4}'|xargs)
			dayNo=$(echo $line|awk '{print $9}'|xargs)
			cmdName_pt1=$(echo $line|awk '{print $11}'|xargs)
			cmdName_pt2=$(echo $line|awk '{print $12}'|xargs)
			cmdName="$cmdName_pt1 $cmdName_pt2"
	
			if (( $(echo "$ramUsage > $ramThreshold"|bc -l) ));
			then
				data="${psName}\t$ramUsage\t$dayNo\t\t$cmdName"
				psString+="${data}\n"
			fi
		done < <(ps aux --sort=-%mem | awk 'NR<=15{print $0}'|sed -e "1d")
	else
		echo "Normal: MemUsage: $memUsed, MemFree: $memFree "
	fi
	echo -e "$psString\n" >> $1
}

function main(){
    #Part-0: Load front and color attributes
    loadFrontColorAttributes
    
    # Part-1
    homeDir="/home/accustandard"
    tmpUnitFile="${homeDir}/tmpUnitServices.txt"
    m2EnvPhpFile="${homeDir}/public_html/app/etc/env.php"
    storePSIntoFile="${homeDir}/psAboveThresholdReport.txt"
    
    
    # Part-2
    checkFileExists $storePSIntoFile
    
    #Part-3: Check the major services are loaded or not
    checkMajorServiceLoad  $tmpUnitFile $m2EnvPhpFile
    
    #Part-4:Process above the threshold
    psAboveThreshold $storePSIntoFile
    echo ""
    echo -e "$psString"
    
    #Part-5: Redis Checker
    redisChecker
    
    #Part-6: Check if  multiple person logged into the system
    checkIfMultiplePersonLoggedinToTheSystem
    
}

main 

