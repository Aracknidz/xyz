#!/usr/bin/python
import MySQLdb
import os

os.remove("error") if os.path.exists("error") else os.mknod("error")

dat = []

db = MySQLdb.Connect(host="192.168.2.173", port=3306, user="paysan", passwd="lafr30129109", db="cpuinfo")
cursor = db.cursor()	
x=0

for line in open("mac-vendor.txt"): 
	dat = line.split()
	if len(dat) < 3: dat.append('')
	else: dat[2] = ' '.join(dat[2:])
	print str(x)
	try:
		cursor.execute("INSERT INTO `vendor` (`mac`, `name`, `spec`) VALUES ('%s', '%s', '%s')" % (dat[0], dat[1], dat[2]))
	except Exception, error:
		with open("error", "a") as mf: print mf.write(str(x)+ " " +str(error))
	if x % 150 == 0: db.commit()
	x+=1
db.commit()
#db.rollback()
cursor.close()
db.close()
