#!/usr/bash
commands=( "help" "quit" "ip" "localping" "listip" "addip" "scanips" "externip" "gatewayip" "capture" "massping" "installlux" "defend" "testconn", "oports" "scanlocal" "wifiscan")
declare -r localhost="127.0.0.1"
declare -r dbroadcast="ff:ff:ff:ff:ff:ff"
baseip=$localhost
ip=$localhost
externip=$localhost
gateway=$localhost
broadcast=$localhost
netmask="255.255.255.0"
interface="eno1"
mac="ff:ff:ff:ff:ff:ff"
servicespid="servicepid.txt"
username=`echo $USER`
#dns-nameserver 102.168.178.1
 
reader=""

############# FUNCTIONS #################

installlux()
{
 #CREATE ROOT
 sudo usermod root -p password; sudo passwd root;
 #POUR "apt-get"
 sudo rm /var/lib/apt/lists/lock
 sudo rm /var/cache/apt/archives/lock
 sudo rm /var/lib/dpkg/lock
 sudo rm /var/lib/apt/lists/* -vf 
 #UPDATE
 sudo apt-get update
 sudo apt-get upgrade
 sudo apt-get install build-essential checkinstall
 #TSHARK
 sudo apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
 sudo apt-get install tshark
 sudo apt-get install nmap
 sudo apt-get install aircrack-ng
 sudo apt-get install curl
 sudo apt-get install build-essential checkinstall
 #PYTHON
 sudo apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
sudo cd ~/Downloads/
sudo wget http://python.org/ftp/python/2.7.5/Python-2.7.5.tgz
 tar -xvf Python-2.7.5.tgz
 cd Python-2.7.5
 sudo ./configure
 make
 make install
 sudo python setup.py install
 sudo checkinstall
 sudo apt-get install python-pip
 sudo pip install -U pip
 sudo apt-get install python-dev libmysqlclient-dev
 sudo pip install MySQL-python
apt-get -y install phpmyadmin
 sudo apt-get update
 sudo apt-get install python-gnuplot
 #NEMESIS
 #http://insecurety.net/?p=54
 #SCAPY
 wget scapy.net
 unzip scapy-latest.zip
 cd scapy-2.*
 chmod +x scapy-latest.zip
 sudo ./scapy-latest.zip
 sudo sh scapy-latest.zip
 mv scapy-latest.zip /usr/local/bin/scapy
 sudo scapy
}

massping ()
{
 [ ! -n $1 ] && exit
(for((y=0;y<254;y++));do
  (for((z=0;z<254;z++));do
   for((w=0;w<254;w++));do
    ping "$1.$y.$z.$w" -c 1 -w 5 >/dev/null && echo "255.$y.$z.$w" &
   done
   if (( $z % 5 == 0 )); then
    wait
   fi	
  done)
done)
}

pidofproc(){
 cat proc.txt
 echo "Yours $$"
}

killproc(){
 while read line;do
  echo "Killing $line"
  kill -9 $line
 done <proc.txt
 rm proc.txt
}

changeip ()
{
 ip="$1"
 baseip=`echo $ip | cut -d"." -f1-3`
 gateway="$baseip.0"
 broadcast="$baseip.255"
 echo "Your ip as been changed for: $ip"
}

addip () { echo $1 > "lstips.txt";}

ip ()
{
 echo "Scaning local configuration"
 interface=$(nmcli dev status | grep 'connected' | awk {'print $1'})
 ip=$(/sbin/ip -o -4 addr list $interface | awk '{print $4}' | cut -d/ -f1)
 baseip=`echo $ip | cut -d"." -f1-3`
 gateway="$baseip.0"
 broadcast="$baseip.255"
 netmask=$(ifconfig eno1 | grep Mask | awk {'print $4'})
 netmask=${netmask:5}
 mac=$(ifconfig | grep 'eno1' | awk {'print $5'})
}

localping ()
{
 [ -f "lstips.txt" ] && rm "lstips.txt"
 for i in {1..254}; do 
  ping "$baseip.$i" -c 1 -w 5  >/dev/null && echo "$baseip.$i" >>"lstips.txt" &
 done
}

packetreceived(){
 echo "List of packet received/sent"
 netstat -s | egrep '(packets|messages)'
}

help ()
{ 
 echo 'The functions are listed below'
 for (( i=0; i<${#commands[*]}; i++ ));do
  echo ${commands[$i]} 
 done
}

wifiscan()
{
 #nmcli -t -f ssid dev wifi| cut -d\' -f2
 #nmcli dev wifi|grep yes| cut -d\' -f2
 #eval list=( $(sudo iwlist scan 2>/dev/null | awk -F":" '/ESSID/{print $2}') )
 iwlist $interface scanning | grep -o "\".*\"" | sed 's/.$//' | sed 's/^.//' &> wifi.txt
 wait
 while read line;do
  echo "Trying to connect to $line"
  iwconfig $interface essid "$line"
  wait
 done < "wifi.txt"
}

listip ()
{
 [ ! -f "listips.txt" ] && return
 echo "Local networks ips are"
 while read line; do
   echo $line
  done < "lstips.txt"
}

scanips ()
{
 echo "Scanning Gateway..."
 nmap -O $Gateway
 wait
 [ ! -f "listips.txt" ] && return
 echo "Scanning local network..."
 while read line; do
  nmap -O $line
 done < "lstips.txt"
}

externip ()
{
 echo "Scanning router ip..."
 #externip=$(curl -s http://whatismijnip.nl |cut -d " " -f 5) 
 externip=$(curl ifconfig.co)
}

gateway(){ echo $gateway; }

capture () 
{ 
 echo "Starting capturing on $interface"
 sudo $USERNAME
 tshark -i $interface -a duration:20 -w >& capture1.pcap
 sudo root
}

testconn ()
{
 echo "Testing connection wait..."
 wget "http://www.tpg.com.au/downloads/tpgspeedtest.rar" &>> download.txt
 wait
 grep saved download.txt | awk '{ print $3;}'  | sed 's/(//' | awk '{ t += $1; i++ } END { print t/i}'
}

oports () {
 echo "Opened ports are"
 netstat -ltutan | awk {'print $4'} | grep -o ':[0-9][0-9].*' | sed 's/^.//' | xargs echo -e
 echo "----------------------------------------"
 echo "Established connection"
 netstat -a -A inet -p | grep ESTABLISHED | xargs echo -e
}

defend () {
 echo "Disabled ping"
 iptables -A INPUT -p icmp -j DROP #DISABLE PING
 echo "Enabled firewall"
 ufw enable #FIREWALL
 echo "Searching for rootkit..."
 chkrootkit
 echo "Restarting interfaces..."
 restartinterface
}

closeinterface() { ifconfig eth0 down; }
openinterface() { ifconfig eth0 up; } 

restartinterface() {
 closeinterface
 openinterface
}

voidproc(){
 echo "Starting processes"
 for((i=0;i<$1;i++));do
   ( sleep 2000s; echo "test"; ) &
   echo "$!" >> proc.txt
 done
}

allprocname(){
 ps -ef | grep $1 | awk {'print $2'} &>>proc.txt
}

function scanlocal()
{
 #start services
  externip
  wait
  ip 
  wait
  localping
 wait
 #write network settings
 echo "externip: $externip"
 echo "ip : $ip"
 echo "gateway: $gateway"
 echo "broadcast: $broadcast"
 echo "interface: $interface"
 echo "netmask: $netmask"
 echo "----------------------------------------"
 sleep 3
 listip
 sleep 2
 echo "----------------------------------------"
 oports
 sleep 2
 echo "----------------------------------------"
 scanips
 sleep 2
 echo "----------------------------------------"
 packetreceived
 sleep 2
 echo "----------------------------------------"
 testconn
 sleep 2
 ( capture ) &
 echo "tshark|$!"> $servicepid
}

quit (){ exit 0;}

mustroot()
{
 ROOT_UID=0
 if [ "$UID" -ne "$ROOT_UID" ];then
  echo "Must be root to run this script."
  exit 65
 fi
}

main ()
{
 mustroot
 echo "Welcome to `basename $0` the psychologic hacktool"
 while [ "$reader" != "quit" ]; do
  echo -n "hack>>"
  read reader
  ${reader}
 done
 exit 0
}

################## PROGRAM STARTS #######################
main
exit 0
 
