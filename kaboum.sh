#!/usr/bash
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
