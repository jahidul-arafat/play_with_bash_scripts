					##############################################################
					#                hwwsysmon.sh                                #
					# Written for harriswebworks.com by Jahid Arafat             #
					# If any bug, please report me to the following emails       #
					# email: jahidapon@gmail.com, jarafat@harriswebworks.com     #
					##############################################################

#! /bin/bash

#----This portion will have all the user defined functions--------------------------

kernel_def_counter=0
usr_def_counter=0

function whoLoggedLast(){
	lastLogged=$(lastlog|grep root)
	echo "Account logged last is: $lastLogged"
	#echo -e "Account logged last is \n $lastLogged"|mail -s "last loggin notification from node2" "jahidapon@gmail.com"
}

function statOfFile(){
	stat $1
}

function kernelRoute(){
	
	routeEntry=$(route|wc -l)
	((routeEntry = $routeEntry - 2))
	echo "Kernel route table has $rounteEntry route table entries"
	route
}

#function psMemEmailAlert(){ #this code has been shifted to psMemEmailAlert.sh file
#	reportFile="/tmp/top_ps_util_report"
#	touch $reportFile
#	mem_upper_threshold=20 #this is 20%, we could also have the provision to track the ps consuming more than 1000MB memory space
#	psString=""
#	top -b -n 1|sed -e "1,7d"|while read line;
#	do
#		mem_utilization=$(echo $line|awk '{print $10}'|cut -d"." -f 1)
#		ps_name=$(echo $line|awk '{print $12}')
#		user_name=$(echo $line|awk '{print $2}')
#		if [ ! -z "$mem_utilization" ];then
#		if [ "$mem_utilization" -ge "$mem_upper_threshold" ];
#		then
#			echo "$ps_name($user_name) --> $mem_utilization"|tee -a $reportFile
#			psString=$psString$ps_name
#		fi
#		fi
#	done
	#if [ -n $psString ]
	#then
	#	echo -e "Memory Usgae Alert --> CAUSE --> $psString\n For details please find the attachment"|mail -a $reportFile -s "Process Memory Alert" -c "jarafat@harriswebworks.com" "jahidapon@gmail.com"
	#else
	#	echo "No per process memory usage alert"|mail -s "Safety Msg on PS Memory Usage" -c "jarafat@harriswebworks.com" "jahidapon@gmail.com"
	#fi

#	rm -f $reportFile	
	
#}

function containerMon(){
	echo -e "The following informations of a container will be shown:\n1.hostname\n2.Uptime\n3.Number of existing templates available"
	echo "Printing the existing templates available"
	ls /vz/template/cache/
	containerNumber=$(vzlist|wc -l) #test
	echo "The Node has $containerNumber containers"
	echo ""
	ctCount=0
	echo "*********Printing the basic informaions of all containers*******"
	echo "** PART-1: A Tabular View of all Basic Info **"
	echo -e "Usage Guideline\n--------------------"
	echo -e "veid --> container ID\n
			hostname --> Container hostname\n
			ip --> Container IP address\n
			numproc--> The number of processes and threads allowed.\n
			laverage --> The average number of processes ready to run during the last 1, 5 and 15 minutes.\n
			status --> Specifies whether the Container is running or stopped.\n
			uptime --> \n
			ostempltae --> Specifies the name of the OS template your Container is based on ( e.g. redhat-el5-x86).\n 
			diskspace --> The total size of disk space consumed by the Container \n 
			physpages --> The total size of RAM used by processes. \n
			numtcpsock --> The number of TCP sockets (PF_INET family, SOCK_STREAM type). This parameter limits the number of TCP connections and, thus, the number of clients the server application can handle in parallel. \n 
			numpty --> The number of pseudo-terminals. \n 
			numfile --> The number of files opened by all Container processes."
	vzlist -o veid,hostname,ip,numproc,laverage,status,uptime,ostemplate,diskspace,physpages,numtcpsock,numpty,numfile
	echo " "
	
	echo "** PART-2: The OS Templates available in the cache"
	# Contains all the OS template 
	osTemplate=$(ls /vz/template/cache|wc -l)
	ls /vz/template/cache/
	
	defConfFile=/etc/vz/vz.conf
	echo -e "PART-3: The Default OpenVZ configuration File ($defConfFile)\n---------------------------"
	cat -n $defConfFile|sed -n '42,48p'
	echo -e "*****Some important notes here****** \n"
	vSwap=$(cat $defConfFile |grep "CONFIGFILE"|cut -d"=" -f2)
	if [[ $vSwap = \"vswap* ]]
	then
		echo "For vswap-enabled containers, one cause is the lack of RAM. Whenever a RAM shortage 
		occurs, system will start doing virtual swapping, delaying a given container to emulate the effect
		of a real swap out."
		echo ""
	fi
	
	nServer=$(cat $defConfFile|grep "NAMESERVER"|cut -d"=" -f2)
	if [[ $nServer = \"inherit* ]]
	then
		cat /etc/resolv.conf
	else
		cat $nServer
	fi
	echo ""
	
	echo "********** NOTE ENDS HERE **************"
	
	
	read -p "Do you want to see the details container information: " seeConDetInfo
	if [[ $seeConDetInfo = yes ]]
	then
		echo "*****Printing the details information of individual containers******** "
		for CT in $(vzlist -H -o ctid)
		do	
			echo "== CT $CT : Count ($ctCount)=="
			#vzctl exec $CT uptime
			#vzctl exec $CT hostname
			#echo -e -n '\E[32m'"Container OS: "
			#vzctl exec $CT cat /etc/os-release|grep ^PRETTY|cut -d= -f2
			
			echo "PART-4(a): Checking the category of the containers (openvz/xen)"
			echo -n "Container Category: "
			vzFile=/proc/user_beancounters
			xenDir=/proc/xen/
			if [ -f $ vzFile ]
			then
				echo "openVZ container"
			elif [ $(ls $xenDir|wc -l) -gt 0 ]
			then
				echo "xen Container"
			else
				echo "Undefined Container"
			fi
				
			
			echo "PART-4(b): The disk usage percentage of each containers"
			vzctl exec $CT df -h|grep simfs
			
			
			#echo "========================================================================"
			#allVPSCont=/proc/vz/veinfo
			#echo "---Show all the VPS containers along with assigned dedicated IP's ($allVPSCont)---"
			#cat $allVPSCont
			
			echo "PART-4(c): The Network Traffic Monitor (console-based)"
			echo "Tool will be used: vnstat --> it keeps a log of hourly, daily and monthly network traffic for the 
			selected interface but is not a packet sniffer."
			
			echo "Cont    Date           rx           tx       Total (rx+tx)     persecond"
			echo "--------------------------------------------------------------------------"
			vzctl exec $CT vnstat -m|grep 'kbit\|Mbit'
			
			echo "PART-4(d): The container: $CT configuration file (/etc/vz/conf/$CT.conf)"
			cat -n /etc/vz/conf/$CT.conf|sed -n '18,30p'
			
			echo "PART-4(e): Finding the description of each container"
			vzlist -o description $CT
			
			
			
			#echo "Container Alerming Processes: "
			#cp psMemEmailAlert.sh /vzmount/vz/private/$CT/
			#echo $CT >> /tmp/ps_mem_container
			#vzctl exec $CT ./psMemEmailAlert.sh >> /tmp/ps_mem_container
			#echo "">> /tmp/ps_mem_container
			#vzctl enter $CT
			#psMemEmailAlert
			#echo " "
			(( ctCount++ ))
		done
	fi
	#echo "Container ($containerNumber) Memory Alert Report , Please find the attchment"|mail -a /tmp/ps_mem_container -s "Container Memory Alert Report" -c "jarafat@harriswebworks.com" "jahidapon@gmail.com"
}

function hwwAllMemoryUsageAlert(){
	nodeFile=$1 # this file will be generated from hwwNodeMemUsage() function
	conFile="/tmp/ps_mem_container"
	nodeReport=""
	conReport=""
	free_mem=$(free -mt|grep Total|awk '{print $4}')
	if [[ "$free" -le 1000 ]]
	then
		nodeReport="Warning, Server(Main Node 2) memory is running low!\n\n Free Memory: $free_mem MB"	
	else
		nodeReport="Server(Main Node2) is OK.\n\n Free Memory: $free_mem MB"
	fi
	# This is the container portion
	for CT in $(vzlist -H -o ctid)
	do	
		cp psMemEmailAlert.sh /vzmount/vz/private/$CT/
		echo $CT >> $conFile
		vzctl exec $CT ./psMemEmailAlert.sh >> $conFile
		echo "">> $conFile
		echo " "
	done
	conReport="Container($containerNumber) Memory Alert Report. Please find attahment(s)."
	emailReport=$nodeReport"\n"$conReport
	echo -e "$emailReport"|mail -a $nodeFile -a $conFile -s "Node2 Memory Usage Report_Alert (Both Node2 and Containers)" -c "jarafat@harriswebworks.com" "jahidapon@gmail.com"
	rm -f $conFile		 
}

#function hwwMemoryEmailAlert(){ # this function has become obsolate 
#	#hwwMemoryUsage|sort -bnr -k3|head -n 10 > /tmp/top_processes_memory_usage
#	file=$1
#	free =$(free -mt|grep Total|awk '{print $4}')
#	if [[ "$free" -le 1000  ]]
#	then
#		#file=/tmp/top_processes_memory_usage
#		echo -e "Warning, server memory is running low!\n\n Free Memory: $free MB"| mail -a "$file" -s "Server memory Status Alert" -c "jahidapon@gmail.com" "jarafat@harriswebworks.com"		
#	else
#		echo -e "Server Memory Status is OK. \n\n Free Memory: $free MB"|mail -a "$file" -s "Server Memory Status Alert" -c "jahidapon@gmail.com" "jarafat@harriswebworks.com"
#	fi
#}
function hwwNodeMemoryUsage(){
	#printf "%-10s%-15s%-15s%-15s%-15s%-60s%s\n" "PID" "OWNER" "MEMORY(MB)" "MEMORY(%) " "CPU(%)" "COMMAND" "CATEGORY"
	RAWIN=$(ps -o pid,user,%mem,%cpu,command ax|grep -v PID|awk '/[0-9]*/{print $1 ":" $2 ":" $3 ":" $4 ":" $5}')
	for i in $RAWIN
	do
		PID=$(echo $i|cut -d: -f1)
		OWNER=$(echo $i|cut -d: -f2)
		COMMAND=$(echo $i|cut -d: -f5)
		MEMORY_PC=$(echo $i|cut -d: -f3)
		MEMORY_KB=$(pmap $PID|tail -n 1|awk '/[0-9]K/{print $2}')
		CPU_USAGE=$(echo $i|cut -d: -f4)
		
		if echo $i|grep ']'$
		then
			((kernel_def_counter++))
			CMD_CAT="Kernel Thread(Sys)_$kernel_def_counter"
		else
			((usr_def_counter++))
			CMD_CAT="User Def_$usr_def_counter"
		fi

		if [ ! -z "$MEMORY_KB" ] #checking whether the returned string is empty or not
		then
			#MEMORY_KB=${MEMORY_KB:$(expr ${#MEMORY_KB}-1)}
			MEMORY_KB=$(echo -n $MEMORY_KB | head -c -1)
			MEMORY_MB=$(bc <<<"scale=2;$MEMORY_KB/1024")
		else
			MEMORY_MB=0.0
		fi

		printf "%-10s%-15s%-15s%-15s%-15s%-60s%s\n" "$PID" "$OWNER" "$MEMORY_MB" "$MEMORY_PC" "$CPU_USAGE" "$COMMAND" "$CMD_CAT"
	done
}

echo "###########    Welcome to the HWWSYSMONITOR SYSTEM (version 1.0) ################"
# PART-1: clear the screen
clear

# PART-2: unset the following varibales which the program going to use for the information manupulation
unset hwwreset os architecture kernelrelease internalip externalip nameservers loadaverage

# PART-3:install the system as root user using the following command and check the version
# ./hwwsysmon.sh -i (This can only be installed as root user)
# ./hwwsysmon.sh -v (For chechking the version, can be checked by any user)
while getopts iv name
do
	case $name in
		i)iopt=1;;
		v)vopt=1;;
		*)echo "Invalid arguments, Usage ./hwwsysmon.sh -i or ./hwwsysmon.sh -v"
	esac
done
# PART-3(a): Writing the installation code, remember the shell you are using is bourne (bash)
# Purpose: I am going to copy the file named hwwsysmon.sh into /usr/bin/hwwsysmon to make is executable for everyone
if [[ ! -z $iopt ]]
then
	wd=$(pwd)
	basename "$(test -L "$0" && readlink "$0" || echo "$0")" > /tmp/scriptname
	scriptname=$(echo -e -n $wd/ && cat /tmp/scriptname)
	su -c "cp $scriptname /usr/bin/hwwsysmon" root && echo "Congratulations! Script Installed, mow run the hwwsysmon Command from any user" || echo "Installation failed"
fi

#PART-3(b): Writing code for checking the installation version
#Usage : ./hwwsysmon.sh -v
if [[ ! -z $vopt ]]
then
	echo -e "Harris Web Works System Monitor Version 1.0\nDesigned by Jahid Arafat, Assistant Professor, Army University, Cumilla Cantonemnt, Bangladesh\nReleased Under Apache 2.0 License (yet to, better not to release it publicly)"
fi

if [[ $# -eq 0 ]]
then
{

# PART-4: Defining the Variable hwwreset, remember this varibale will be used for a better visual effects of the generated output at the shell
hwwreset=$(tput sgr0)

# PART-5: Check if the system connected to Interenet or not
ping -c 1 google.com &> /dev/null && echo -e '\E[32m'"Internet: $hwwreset Connected" || echo -e '\E[32m'"Internet: $hwwreset Not Connected"

# PART-6: Check the OS Type
echo -e "\e[31;43m**** OS INFORMATION ****\e[0m"
os=$(uname -o)
echo -e '\E[32m'"Operating System Type:" $hwwreset $os

# PART-7: Check OS Release Version and Name
#This portion of code will not be supported by Centos 7+, Only supported at Centos 6

cat /etc/centos-release > /tmp/osrelease
echo -n -e '\E[32m'"OS Name: " $hwwreset && cat /tmp/osrelease|awk '{print $1}'
echo -n -e '\E[32m'"OS Version :" $hwwreset && cat /tmp/osrelease|awk '{print $3$4}'
echo " "

# PART-8: Check the Architecture
echo -e "\e[31;43m**** SYSTEM ARCHITECTURE ****\e[0m"
architecture=$(uname -m)
echo -e '\E[32m'"Architecture :" $hwwreset $architecture

# PART-9: Check Kernel Release
kernelrelease=$(uname -r)
echo -e '\E[32m'"Kernel Release :" $hwwreset $kernelrelease
echo " "

echo -e "\e[31;43m**** HOSTNAME INFORMATION ****\e[0m"
# PART-10: Check hostname
echo -e '\E[32m'"Hostname :" $hwwreset $HOSTNAME
echo " "

# PART-11: Check Internal IP
echo -e "\e[31;43m**** IP INFORMATION ****\e[0m"
internalip=$(hostname -I)
echo -e '\E[32m'"Internal IP :" $hwwreset $internalip

# PART-12: Check the public ip
externalip=$(curl -s ipecho.net/plain;echo)
echo -e '\E[32m'"External IP :" $hwwreset $externalip
echo " "

# PART-13: Check DNS
echo -e "\e[31;43m**** NAME SERVER INFORMATION ****\e[0m"
nameservers=$(cat /etc/resolv.conf| sed '1d' |awk '{print $2}')
echo -e '\E[32m'"Name Servers :" $hwwreset $nameservers
echo " "

# PART-14: Check Logged In Users
echo -e "\e[31;43m**** USER LOGGED IN INFORMATION ****\e[0m"
who>/tmp/who
echo -e '\E[32m'"Logged In Users :" $hwwreset && cat /tmp/who
echo " "

# PART-15: Check RAM and SWAP Usages
echo -e "\e[31;43m**** RAM AND SWAP INFORMATION ****\e[0m"
free -h|grep -v + > /tmp/ramcache
echo -e '\E[32m'"RAM Usages :" $hwwreset 
cat /tmp/ramcache | grep -v "Swap"
echo -e '\E[32m'"Swaap Usages :" $hwwreset
cat /tmp/ramcache |grep -v "Mem"
echo " "

# PART-16: Check Disk Usages
echo -e "\e[31;43m**** DISK USAGE INFORMATION ****\e[0m"
df -h|grep 'Filesystem\|/dev/xvd*' > /tmp/diskusage
echo -e '\E[32m'"Disk Usages :" $hwwreset
cat /tmp/diskusage

# PART-17: Check Load Average
echo -e "\e[31;43m**** SYSTEM LOAD AVERAGE INFORMATION ****\e[0m"
loadaverage=$(top -n 1 -b| grep "load average:"| awk '{print $12 $13 $14}')
echo -e '\E[32m'"Load Average :" $hwwreset $loadaverage
echo " "

# PART-18: Check System Uptime
echo -e "\e[31;43m**** SYSTEM UPTIME INFO ****\e[0m"
hwwuptime=$(uptime |awk '{print $3,$4}'|cut -d, -f1)
echo -e '\E[32m'"System Uptime Days/(HH:MM) :" $hwwreset $hwwuptime
echo " "


#Part-19:
echo -e "\e[31;43m**** SELINUX INFORMATION ****\e[0m"
echo -e '\E[32m'"Checking the SELinux Status: " $hwwreset
sestatus
echo " "

# PART -20: Showing the Kernel Route Information
echo -e "\e[31;43m*** KERNEL ROUTE INFORMATION ***\e[0m"
kernelRoute
echo " "

#Part-21:
echo -e "\e[31;43m**** RAM USAGE INFORMATION ****\e[0m"
TOTALMEM_STR=$(vmstat -s|grep "total memory")
TOTALMEM=$(echo $TOTALMEM_STR|cut -d ' ' -f1)
TOTALMEM_MB=$(bc <<<"scale=2;$TOTALMEM/1024")
TOTALMEM_GB=$(bc <<<"scale=2;$TOTALMEM_MB/1024")
TOTALCPUS=$(grep "model name" /proc/cpuinfo |wc -l)
echo -e '\E[32m'"Memory Summary info of Node 2" $hwwreset $TOTALMEL_GB 
swapon -s

echo -e '\E[32m'"Total CPUs available in the EC2 instance :" $hwwreset $TOTALCPUS
echo " "

# PART -21: Process Details info
echo -e "\e[31;43m**** PROCESS DETAILS INFORMATION ****\e[0m"
read -p "Enter the total number of top processes you want to view (prefereable : 10) : " psCount

memUsageFile="/tmp/top_memory_usage_pss"
touch $memUsageFile
printf "%-10s%-15s%-15s%-15s%-15s%-60s%s\n" "PID" "OWNER" "MEMORY(MB)" "MEMORY(%) " "CPU(%)" "COMMAND" "CATEGORY"
hwwNodeMemoryUsage|sort -bnr -k3|head -n $psCount|tee $memUsageFile 
hwwAllMemoryUsageAlert $memUsageFile

# PART-22: Container Details information
echo -e "\e[31;43m*** CONTAINER DETAILS INFORMATION ***\e[0m"
containerMon

# PART-23: Stat of the own file information
echo -e "\e[31;43m*** STAT OF HWWSYSMON.SH ***\e[0m"
statOfFile /root/hwwsysmon.sh

# PART-24: Last logged in email notification to system administrator
echo -e "\e[31;43m*** SENDING THE LOGIN EMAIL NOTIFICATION ***\e[0m"
whoLoggedLast

# PART-25: Unset Variables
unset hwwreset os architecture kernelrelease internalip externalip nameservers loadaverage

# PART-26: Remove Temporary Files
rm /tmp/osrelease /tmp/who /tmp/ramcache /tmp/diskusage $memUsageFile


}
fi
shift $((OPTIND - 1))

# Lots of parts are under construction.... so please wait to have more features
#This app will be a wholistic system health monitoring tools for the special benefits of Harris Web Works
