color a
FOR /L %%i IN (1,1,254) DO (
	ping -n 1 192.168.2.%%i > nul && ( echo "192.168.2.%%i" >> ipaddresses.txt )
)