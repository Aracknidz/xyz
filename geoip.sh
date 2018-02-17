#!/usr/bash

declare -r localhost=$(hostname -i)
declare filemv=/usr/local/share/arp-scan/mac-vendor.txt

internmips=()
externalips=()
baseip=$localhost
ip=$localhost
ip6="ff::02"
externip=$localhost
gateway=$localhost
gtwmac="ff:ff:ff:ff:ff:ff"
broadcast=$localhost
mask="255.255.255.0"
hwrd="ff:ff:ff:ff:ff:ff"
interface="eth0"
netmask="/24"
username=`echo $USER`
nspecs=("extip" "iface" "ip" "hwrd" "gtw" "gtwmac" "broad" "mask" "netmask" "bip" "ip6")
specs=($externip $interface $ip $hwrd $gateway $gtwmac $broadcast $mask $netmask $baseip $ip6)
uspecs=()

#nslookup google.com | tr -s ' ' ' ' | grep -n "Address:" | sed 's/[a-zA-Z:]//g' | grep -e "(([0-9]{1,3}\.){3}[0-9]{1,3})" &

#curl http://api.hackertarget.com/geoip/?q=1.1.1.1
#dig +short stackoverflow.com

#file="somefileondisk"
#lines=`cat $file`
#for line in $lines; do
#        echo "$line"
#done

ip2dec()
{
	local dec=$(awk '{ split($1, a, "."); print a[1]*16777216 + a[2]*65536 + a[3]*256 + a[4] }')
	echo $dec
}

ip2four()
{
	IP="$1"
	set ${IP//./ } 
	echo $((((((($1 << 8) | $2) << 8) | $3) << 8) | $4))
}

dec2ip()
{
    local ip=$(awk ‘{ print int($1 / 16777216) “.” int($1 % 16777216 / 65536) “.” int($1 % 65536 / 256) “.” int($1 % 256) }’)
    echo "$ip"
}

ip2int()
{
    local a b c d
    { IFS=. read a b c d; } <<< $1
    echo "$a $b $c $d"
}

int2ip()
{
    local ui32=$1; shift
    local ip n
    for n in 1 2 3 4; do
        ip=$((ui32 & 0xff))${ip:+.}$ip
        ui32=$((ui32 >> 8))
    done
    echo "$ip"
}


function log2 {
    local x=0
    for (( y=$1-1 ; $y > 0; y >>= 1 )) ; do
        let x=$x+1
    done
    echo $x
}

getnetmask()
{
    local a b c d
    local lg
    { IFS=. read a b c d; } <<< $1
    local one=$((0xffffffff & (255-a+255-b+255-c+255-d)))
    lg=$(log2 "$one")
    echo "/"$((32-$lg))
}

getspecs()
{
 interface=$(getif)
 baseip=$(getbaseip)
 ip=$(getip)
 externip=$(getextip)
 gateway=$(getgtw)
 broadcast=$(getbroad)
 hwrd=$(gethwrd)
 mask=$(getmask "$interface")
 wait
 netmask=$(getnetmask "$mask")
 ip6=$(getip6)
 gtwmac=$(getgtwhwrd)
}

getip()
{
 local tip=$(/sbin/ip -o -4 addr list wlan0 | awk '{print $4}' | cut -d/ -f1)
 echo "$tip"
}

getip6()
{
 local tip6=$(ip addr show |grep -w inet6 |grep -v ::1|awk '{ print $2}'| cut -d "/" -f 1)
 echo "$tip6"
}

getbaseip()
{
 local tbip=$(netstat -rn | grep -e '255.255.255.0' | awk '{print $1}')
 echo "$tbip"
}

gethwrd()
{
 local thwrd=$(cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address)
 echo "$thwrd"
}

getgtwhwrd()
{
  local tgtwhwrd=$(iwconfig wlan0 | grep -oP '.[0-9|A-Z]{2}:[0-9|A-Z]{2}' | tr -s '\n' ':' | sed -r 's/.{1}$//')
  echo "$tgtwhwrd"
}

getbroad()
{
 local tbroad=$(ip addr show |grep -w inet |grep -v 127.0.0.1|awk '{ print $4}')
 echo "$tbroad"
}

getif()
{
 local tiface=$(nmcli dev status | grep 'connected' | awk '{ print $1}')
 echo "$tiface"
}

getextip()
{
 local texternip=$(curl -s http://whatismijnip.nl |cut -d " " -f 5) 
 echo "$texternip"
}

getmask()
{
 #param1: iface
 local netmsk=$(/sbin/ifconfig "$1" | grep Mask | cut -d":" -f4)
 echo "$netmsk"
}

getgtw()
{
    local tgtw=$(route -n | grep 'UG[ \t]' | awk '{print $2}')
    echo "$tgtw"
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

refreshspecs()
{
 local i=0
 specs=($externip $interface $ip $hwrd $gateway $gtwmac $broadcast $mask $netmask $baseip $ip6)
 
 for each in "${specs[@]}"
 do
  uspecs=("${uspecs[@]}" "${nspecs[$i]} $each")
  i=$i+1
 done
}

printspecs()
{
 for each in "${uspecs[@]}"
 do
  echo $each
 done
}

needonearg()
{
[ -n "$1" ] && echo 'Welcome' || ( echo 'Invoke this script with 1 param at least'; exit 1 )
echo "$PWD/`basename $0`"
}

searchsystem()
{
  local nmac=`echo "$1" | tr '[:lower:]' '[:upper:]'`
  nmac2="${nmac:0:8}"
  local endless="y"
  while read line; do
    nip=${line:0:8}
  	if [ "$nmac2" ==  "$nip" ]; then
     syst=`echo $line | awk '{print $2}'`
     echo "$syst" & break
    fi
  done < "$filemv"
  if [ "endless" == "y" ]; then
  	echo "no system found on db"
  fi
}

scanlan()
{
  local sys nip nmac
  [ -e tscan.txt ] && rm tscan.txt
  sudo arp-scan --quiet --numeric --interface=wlan0 "$baseip$netmask" | awk '{print $1"-"$2}' | tail -n+3 | head -n -3 &> tscan.txt
  wait
  lines=`cat tscan.txt`
  for line in $lines; do
    internmips=("${internmips[@]}" "$line")
    { IFS='-' read nip nmac; } <<< $line
    echo -e "$nip $nmac \c"
    sys=$(searchsystem "$nmac")
    echo "$sys"
  done
}

main ()
{
 mustroot
 getspecs
 wait
 refreshspecs
 printspecs
 #echo "Welcome to `basename $0` the psychologic hacktool"
 #while [ "$reader" != "quit" ]; do
  #echo -n "hack>>"
  #read reader
  #${reader}
 #done
 scanlan
 exit 0
}

################## PROGRAM STARTS #######################
main
exit 0
 
