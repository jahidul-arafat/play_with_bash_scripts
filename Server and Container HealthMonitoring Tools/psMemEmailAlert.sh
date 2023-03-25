#! /bin/bash
function psMemEmailAlert(){
	echo "Into foundation machine"
	reportFile="/tmp/top_ps_util_report"
	touch $reportFile
	mem_upper_threshold=10 #this is 20%, we could also have the provision to track the ps consuming more than 1000MB memory space
	psString=""
	top -b -n 1|sed -e "1,7d"|while read line;
	do
		mem_utilization=$(echo $line|awk '{print $10}'|cut -d"." -f 1)
		user_name=$(echo $line|awk '{print $2}')
		ps_name=$(echo $line|awk '{print $12}')
		if [ ! -z "$mem_utilization" ];then
		if [ "$mem_utilization" -ge "$mem_upper_threshold" ];
		then
			echo "$ps_name($user_name) --> $mem_utilization"
			psString=$psString$ps_name
		fi
		fi
	done
	if [ -n $psString ]
	then
		echo -e "Memory Usgae Alert --> CAUSE --> $psString\n For details please find the attachment"|mail -a $reportFile -s "Process Memory Alert" -c "jarafat@harriswebworks.com" "jahidapon@gmail.com"
	else
		echo "No per process memory usage alert"|mail -s "Safety Msg on PS Memory Usage" -c "jarafat@harriswebworks.com" "jahidapon@gmail.com"
	fi

	#rm -f $reportFile	
	
}

psMemEmailAlert

