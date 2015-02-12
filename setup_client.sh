# client setup
ifconfig em1 down
ifconfig p3p1 192.168.1.6 up
route add -net default gw 192.168.1.5
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
