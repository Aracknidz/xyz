#!/usr/bash
#echo 'list services by level'
#cd /etc/
#for i in $(seq 1 6);do
# cd "rc$i.d"
# echo "LEVEL $i"
# ls
# cd ..
#done

function maxmemory(){
 #used memory in % MAX / MIN
 memtot=$(cat /proc/meminfo | grep 'MemTotal' | awk {'print $2'})
 memfree=$(cat /proc/meminfo | grep 'MemFree' | awk {'print $2'})
 pumem=$(($memtot / $memfree))

 #overmemory usage more 50%
 if [ $pumem -ge 50 ]; then
  sudo sysctl -w vm.drop_caches=3
  sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
 fi
 return 0
}

#test 5 first process
function checkapps(){
 ps aux | sort | awk {'print $11,$4,$3'} | head -6 | tail -n +2 | awk {'if ($4 > 50 || $3 >50) echo $11'}
}

maxmemory&
checkapps&

sleep $1
i=$2
((i++))
bash pidcrawl.sh $i &
exit 
