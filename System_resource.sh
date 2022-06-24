#!/bin/bash
#System resource
#by pengwei 2025/5/25
PS3="Your chois is[10 for quit]: "
##########################cpu的使用率和负载##############################
load () {
for i in {1..3}
do
	echo -e "\033[31m参考值${i}\033[0m"
	used=`vmstat | awk '{if(NR==3){print 100-$15"%"}}'`
	us=`vmstat | awk '{if(NR==3){print $13"%"}}'`
	sy=`vmstat | awk '{if(NR==3){print $14"%"}}'`
	echo "util: $used"
	echo "user use: $us"
	echo "system use: $sy"
	echo --------------------------------------
	sleep 1 
done
}
##########################################################################


##########################磁盘的使用和读写################################
disk_load () {
for i in {1..3}
do
	echo -e "\033[31m参考值${i}\033[0m"
	util=`iostat -x -k | awk 'BEGIN{OFS=": "}/^[s|v]/{print $1,$NF"%"}'`
	READ=`iostat -x -k | awk 'BEGIN{OFS=": "}/^[s|v]/{print $1,$6"KB"}'`
	WRITE=`iostat -x -k | awk 'BEGIN{OFS=": "}/^[s|v]/{print $1,$7"KB"}'`
	IOWAIT=`vmstat | awk '{if(NR==3){print $(NF-1)"%"}}'`
	echo $util
	echo -e "I/O: $IOWAIT"
	echo -e "Read/s: \n$READ"
	echo -e "Write/s:\n$WRITE"
	echo --------------------------------------
	sleep 1	
done
}
##########################################################################



#################################磁盘的大小###############################
disk_use () {
disk_total=`fdisk -l |awk '/^Disk.*bytes/ && /\/dev/{printf $2" ";printf "%d",$3;print "GB"}'`
use_rate=`df -Th |awk '/^\/dev/{print int($6)}'`
	for i in $use_rate
	do
		if [ $i -gt 90 ];then
			PART=`df -Th |awk '{if(int($5)=='''$i''') {print $6}}'`
			echo "$PART = ${i}% " >> disk_total
		fi
	done
	echo --------------------------------------
	echo -e "Disk total:\n$disk_total"
	echo --------------------------------------
	if [ -f disk_total ];then
		echo --------------------------------------
		cat disk_total
		echo --------------------------------------
		rm -rf disk_total
	else
		echo "Disk use rate no than 90% of the partition"
		echo --------------------------------------
		
	fi
}
##########################################################################


##########################indoe的使用率###################################
disk_indoe () {
indoe_log=disk_indoe.log
indoe_use=`df -i | awk '/^\/dev/{print int($5)}'`
for i in $indoe_use
do
	if [ $i -gt 90 ];then
		indoe_disk=`df -i | awk '/^\/dev/{if (int($5)=='''$i''') {print $6}}'`
		echo "$indoe_disk = ${i}% " >>$indoe_log
	fi
	if [ -f $indoe_log ];then
		echo --------------------------------------
		cat $indoe_log
		echo --------------------------------------
		rm -f $indoe_log
	else
		echo --------------------------------------
		echo "Disk use rate no than 90% of the partition"
		echo --------------------------------------
	fi
done
}
##########################################################################


################################内存使用情况##############################
men_use () {
men_total=`free -m | awk 'NR==2{printf "%.1f",$2/1024;print "G"}'`
men_used=`free -m | awk 'NR==2{printf "%.1f",$3/1024;print "G"}'`
men_free=`free -m | awk 'NR==2{printf "%.1f",$4/1024;print "G"}'`
men_cache=`free -m | awk 'NR==2{printf "%.1f",$6/1024;print "G"}'`
echo --------------------------------------
echo "total: $men_total"
echo "used: $men_used"
echo "free: $men_free"
echo "cache: $men_cache"
echo --------------------------------------
}
##########################################################################


###############################TCP监听状态################################
tcp_status () {
echo --------------------------------------
echo -e "tcp connection status:\n `ss -anltp | awk '!/^State/{statu[$1]++}END{for (i in statu){print i,statu[i]} }'`"
echo --------------------------------------
}
##########################################################################


###############################CPU TOP 10#################################
cpu_top () {
cpu_top10=`ps aux |awk '!/^USER/{if($3>0.1){{printf "PID: "$2" CPU: "$3 " --> "}for (i=11;i<=NF;i++)if(i=NF)printf $i"\n" ;else print $i } }' |sort -k4 -rn |head`
echo --------------------------------------
	echo -e "cpu top 10: \n$cpu_top10"
echo --------------------------------------
}
##########################################################################

###############################MEN TOP 10#################################
men_top () {
men_top10=`ps aux |awk '!/^USER/{if($4>0.1){{printf "PID: "$2"\t"" men: "$4"\t" " --> "}for (i=11;i<=NF;i++)if(i=NF)printf $i"\n" ;else printf $i} }' |sort -k4 -rn |head`
echo --------------------------------------
	echo -e "men top 10:\n$men_top10"
echo --------------------------------------
}
##########################################################################

network() {
while :
do
	read -p "please enter network name eth[0-9] ens[0-9]" eth
	if [ `ifconfig |grep -c "\<$eth\>"` -eq 1 ];then
		break
	else
		echo "network name errot "
	fi
done
echo --------------------------------------
echo "IN------OUT"
for i in {1..3}
do
	old_OUT=`ifconfig eth0|awk '/RX.*bytes/{print $5}'`
	old_IN=`ifconfig eth0|awk '/TX.*bytes/{print $5}'`
	sleep=1
	new_OUT=`ifconfig eth0|awk '/RX.*bytes/{print $5}'`
	new_IN=`ifconfig eth0|awk '/TX.*bytes/{print $5}'`
	OUT=`awk 'BEGIN{printf "%.1f\n", '$((${new_OUT}-${old_OUT}))'/1024/128}'`
	IN=`awk 'BEGIN{printf "%.1f\n", '$((${new_IN}-${old_IN}))'/1024/128}'`
	echo "${OUT}MB/s ${IN}MB/s "
done
echo --------------------------------------
}


while :
do
	select chois in cpu_load disk_load disk_use disk_indoe men_use tcp cpu_top men_top network_flow quit
	do
		case $chois in
		cpu_load)	
			load
			break
			;;
		disk_load)
			disk_load
			break
			;;
		disk_use)
			disk_use
			break
			;;
		disk_indoe)
			disk_indoe
			break
			;;
		men_use)
			men_use
			break
			;;
		tcp)
			tcp_status
			break
			;;
		cpu_top)
			 cpu_top
			break
			;;
		men_top)
			 men_top
			break
			;;
		network_flow)
			 network
			break
			;;
		quit)
			exit
			;;
		*)
			echo "please input number"	
			break
		esac
	done
done
