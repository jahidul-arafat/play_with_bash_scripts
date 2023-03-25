#!/bin/bash

# The below portion is developed by JA,DevOps Engineer, HWW to trace the system login and activity hours
function pythonVersionDectector(){
    declare -a pythonList=(python python2 python3)
}

function hostVsContainerID(){
    PYTHON=$(which python2)
    targetHost=$(echo $1|cut -f1 -d ".") #$1=hostname
    hostCIDInfo=$($PYTHON ~/loginNotificationPackage/loginNoti_hostVsCID.py $targetHost 2&>1)
}

function ipEqualityScore(){
    PHP=$(which php)
    targetIP=$1
    $PHP ~/loginNotificationPackage/ipAddressDetection.php $targetIP 2&>1
}

function ipSetupAndSearch(){
	declare -A ipNameList
    
    # IP Lists- Bangladesh
	declare -a mirajIPList=(45.125.222.80)
	declare -a arafatIPList=(103.148.114.9 103.148.114.7)
	declare -a sazzadIPList=(103.143.139.18 103.143.139.23 103.143.139.17)
	declare -a rafiqIPList=(37.111.192.0 37.111.192.255)
	declare -a sadekulIPList=(37.111.192.0 37.111.192.255)
	declare -a muhaiminIPList=(103.102.43.250)
	declare -a foysalIPList=(103.127.59.218)
	declare -a shakwatIPList=(103.87.214.218)
	
    #IP Lists- USA
    declare -a amandaIPList=(98.217.171.160)
    
    #IP Lists - Other
    declare -a i95IPList=(103.44.1.131)
    
    #IP Lists- Unknown IPs from BD
    #31.111.248.205 - mobile net
    declare -a unknownIPList=()
    
    #IP List: Dictionary -BD
	ipNameList["Enamul Miraj"]=${mirajIPList[@]}
	ipNameList["Jahidul Arafat"]=${arafatIPList[@]}
	ipNameList["Sazzad Hossain Khan"]=${sazzadIPList[@]}
	ipNameList["Rafiqul Islam"]=${rafiqIPList[@]}
	ipNameList["Sadekul Islam"]=${sadekulIPList[@]}
	ipNameList["Muhaminul Islam"]=${muhaiminIPList[@]}
	ipNameList["Ariful Foysal"]=${foysalIPList[@]}
	ipNameList["Shakwat Hossain"]=${shakwatIPList[@]}
	ipNameList["ZZZZ"]=${unknownIPList[@]}
    
    #IP List: Dictionary - USA
    ipNameList["Amanda"]=${amandaIPList[@]}
    
    #IP List: Dictionary - Others
    ipNameList["i95_India"]=${i95IPList[@]}

	myIP=$1
	ipCounter=0
	outerLoopBreakState=0

	declare -a unsortedNameList
	for name in "${!ipNameList[@]}"
	do
		unsortedNameList+=("${name}")
	done

	readarray -t sortedNameList < <(printf '%s\0' "${unsortedNameList[@]}" | sort -z | xargs -0n1)

	#for key in "${!ipNameList[@]}"
	for key in "${sortedNameList[@]}"
	do
		ipCounter=0
		#echo "Key: $key"
		
		IFS=' '
		read -r -a ipList <<< "${ipNameList[${key}]}"

		for gip in "${ipList[@]}"
		do
			((ipCounter++))
			if [[ "$gip" == "$myIP" ]]
			then
				outerLoopBreakState=1
				break
			fi
			#echo "IP: $gip [$ipCounter]"
		done
		if [[ "$outerLoopBreakState" -eq 1 ]]
		then
			break
		fi
	done
	unset IFS
}

function getLogoutInfo(){
	logoutString_current=$(last|grep $1|head -n 1)
	logoutString_previous=$(last|grep $1|head -n 2|tail -n 1)
	IFS=' '
	read -ra strArray_current<<< "$logoutString_current"
	read -ra strArray_previous <<< "$logoutString_previous"
	logoutTime_current="${strArray_current[8]}-${strArray_current[9]}"
	logoutTime_previous="${strArray_previous[8]}-${strArray_previous[9]}"
	unset IFS # good practice
}


function systemLoginNotification(){
	WEBUSER= $1
	reportingPerson=$2
	lastLogged=$(lastlog|grep ${WEBUSER})
	IP="$(echo $SSH_CONNECTION | cut -d " " -f 1)" #$SSH_CONNECT returns 103.148.114.5 44850 172.31.2.44 7575
	HOST_NAME=$(hostname)
	NOW=$(date +"%e %b %Y, %a %r")
	TIME_ZONE=$3
    privateIP=
	NOTE="Check ~/loginNotification.txt for the details login summary"
	
	#Step-1: Search the existance of the ssh ip
	ipSetupAndSearch "$IP"  # return $key
    unknownIPAlertMsg=""
	unknownIPAction=""
	emailHeader=""
	color="Green"
	if [[ $key == "ZZZZ" ]]
	then
		unknownIPAlertMsg="*******Unknown IP ($IP) Access Detected**********"
		color="Red"
		key="Unknown Person"
		unknownIPAction="***Whitelist the IP access to this domain. Contact to jarafat@harriswebworks.com"
	fi

    #Step-2: Get the webuser logout information
	getLogoutInfo "$1" #$1-->$WEBUSER
	sed -i "s/logged-in/${logoutTime_previous}/g" $6
    
    #Step-3: Get the container info details of the webuser
    hostVsContainerID "$HOST_NAME" #this is return a message on varibale "hostCIDInfo"
    hostCIDInfo="Information on Accessed Container($5):\n-----------------------------\n""$hostCIDInfo"

    #Step-4: Get The Container Private IP
    IFS=' '
    pvtIPString=$(hostname -I)
    read -ra containerPvtIP<<< "$pvtIPString"
    pvtIP=${containerPvtIP[1]}
    unset IFS
    
    
    #Step-5: Prepare the EMail (Header/Body)
	emailHeader="$color Access: Container Login Notification"
	msgBody="$unknownIPAlertMsg\n\n$key with webuser id '$WEBUSER' from '$IP' logged into '$HOST_NAME' on '$NOW' at TimeZone($TIME_ZONE)\n\nCheck LastLog report:\n-----------------------\n $lastLogged\n\nUnder AWS Node: $4 \n$5\n\n\n$hostCIDInfo\n****Note: $NOTE\n$unknownIPAction"
	
	echo -e "$msgBody"|mail -s "${emailHeader}:[${WEBUSER}]" "${reportingPerson[0]}" "${reportingPerson[1]}"
    
    #Step-6: Record the info into LogFile $6-->LogFileName
	echo -e "$WEBUSER\t$IP\t$key\t\t\t$HOST_NAME\t$NOW\t$4($5)\t$logoutTime_current" >> $6
}

WEBUSER="cndev" #<----- change this webuser for each of the container
containerID="161" #<----- Change this for each of the container

storeInfoIntoFile="/home/cndev/loginNotification.txt"
reportingPerson=("jarafat@harriswebworks.com" "emirajbbd@gmail.com")
awsHostingZone="us-east-1a"
awsNode="Corporate_Magento_S1"
osRelease=$(cat /etc/centos-release|head -n 1)
systemLoginNotification "$WEBUSER" "$reportingPerson" "$awsHostingZone" "$awsNode" "$containerID" $storeInfoIntoFile
