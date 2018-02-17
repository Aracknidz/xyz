#!/bin/bash
RANGE=255
#set integer ceiling

number=$RANDOM
numbera=$RANDOM
numberb=$RANDOM
#generate random numbers

let "number %= $RANGE"
let "numbera %= $RANGE"
let "numberb %= $RANGE"
#ensure they are less than ceiling

#octets='00:60:2f'
octets='00:26:c6'
#set mac stem

octeta=`echo "obase=16;$number" | bc | tr '[A-Z]' '[a-z]' `
octetb=`echo "obase=16;$numbera" | bc | tr '[A-Z]' '[a-z]'`
octetc=`echo "obase=16;$numberb" | bc | tr '[A-Z]' '[a-z]'`
#use a command line tool to change int to hex(bc is pretty standard)
#they're not really octets.  just sections.
mac="${octets}:${octeta}:${octetb}:${octetc}"

sudo ifconfig wlan0 down hw ether $mac
sudo ifconfig wlan0 up
#concatenate values and add dashes

echo "mac changed for $mac"
