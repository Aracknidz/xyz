#!usr/bin/env python2

import logging
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)
from scapy.all import *
import netifaces
import os
import ipgetter
import math
from netaddr import *

conf.verb = 0
conf.iface = "wlan0"

bin8 = lambda x : ''.join(reversed( [str((int(x) >> i) & 1) for i in range(8)]))

ifs 	= netifaces.interfaces()
gws 	= netifaces.gateways()['default'][netifaces.AF_INET]
iface 	= gws[1]
addrs 	= netifaces.ifaddresses(iface)
ntw 	= addrs[netifaces.AF_INET][0]
ip6	 	= addrs[netifaces.AF_INET6][0]['addr']
mask    = ntw['netmask']
subm    = 32
nhost   = 0

subm -= sum([bin8(x).count('0') for x in mask.split('.')[::-1]])
nhost = 2**(32-(subm))-2 #gateway + router
print str(nhost)

dspecs = { 
		   0:['extip',  ipgetter.myip()],  1:['ip',   ntw['addr']],
	       2:['ifs' ,   gws[1]],   		   3:['gws',  gws[0]],
	       4:['broad',  ntw['broadcast']], 5:['mask', mask],
	       6:['mac',    addrs[netifaces.AF_LINK][0]['addr']],
	       7:['lo',		socket.gethostbyname(socket.gethostname())],
	       8:['ip6',    ip6[:ip6.find('%')]]
	     }


for k, v in dspecs.iteritems():
	print v[0] + " | " + v[1]

pool = []

ports = ({20:'ftp',   21:'ftp',    22:'ssh',   23:'telnet',      25:'smtp',   53:'dns',
		 69:'tftp',   80:'http',  110:'pop3', 115:'sftp',       137:'nbios', 138:'nbios',
		 139:'nbios', 156:'sql',  179:'bgo',  190:'gacp',       443:'https', 445:'nbios',
		 449:'bdoor', 546:'dhcp', 547:'dhcp', 548:'appleshare', 1023:'vpn',
		 1024:'vpn',  3306:'sql', 8080:'webserver'})

def scanall():
	global pool
	pkt = Ether(dst="ff:ff:ff:ff:ff:ff")/ARP(pdst="192.168.2.0/24")
	a, u = srp(pkt, timeout=2)
	for s, r in a: pool.append([r[ARP].psrc, r[Ether].src])
	print "scan finished"

def portscan(no):
	a, u = sr(IP(dst=pool[no][0])/TCP(dport=(0,1023)), timeout=1)
	for s, r in a:
		print str(r[TCP].sport) + " | ",

def main(args):
	global pool
	print "NetTool started!"
	toread = None
	os.system('echo 1 > /proc/sys/net/ipv4/ip_forward')
	while toread != "quit":
		toread = raw_input("")
		if toread == "swipe":
			scanall()
		elif toread[0:4] == "scan":
			portscan(int(toread[4:]))
		elif toread == "show":
			i = 1
			for ip, mac in pool: 
				print str(i) + ")", ip, mac
				i+=1
	os.system('echo 0 > /proc/sys/net/ipv4/ip_forward')

#def arppoison(self, ip):
	
#def stoppoison(self, ip):


			

if __name__ == "__main__":
	main(sys.argv[1:])


