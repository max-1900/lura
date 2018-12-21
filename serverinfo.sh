#!/bin/bash


memTotal_b=`free -b |grep Mem |awk '{print $2}'`
memFree_b=`free -b |grep Mem |awk '{print $4}'`
memTotal_m=`free -m |grep Mem |awk '{print $2}'`
memTotal_x=`free -m |grep Mem |awk '{print $3}'`
memTotal_k=`free -m |grep Mem |awk '{print $7}'`
CPUPer=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
hdd=`df -lh | awk '{if ($6 == "/") { print $5 }}' | head -1 | cut -d'%' -f1`
uptime=`uptime`
time=`date` 
ProcessCnt=`ps -A | wc -l`
memUsed_b=$(($memTotal_b-$memFree_b))
memUsedPrc=$((($memTotal_x*100)/$memTotal_m))

echo '■ درصد مصرف حافظه : '"$hdd"'%\n'
echo "□ فرایند ها : ""$ProcessCnt\n"
echo "■ درصد Cpu مصرف شده : ""$CPUPer""%\n"
echo "□ حجم کلی رم : $memTotal_m MB\n"
echo "■ حجم آزاد رم : $memTotal_k MB\n"
echo "□ رم مصرفی : $memTotal_x MB\n"
echo "■ درصد رم مصرفی : $memUsedPrc%\n"



