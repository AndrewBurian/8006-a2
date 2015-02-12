# setup firewall
ifconfig p3p1 192.168.1.5 up
echo "1" >> /proc/sys/net/ipv4/ip_forward
