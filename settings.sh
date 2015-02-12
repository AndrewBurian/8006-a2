#########################################
###        Firewall User Config       ###
#########################################


# Firewall tool
##########################################
# the complete path of the tool used to manipulate the firewall
# if it's not pointing to iptables, it won't work
FW_PATH=/sbin/iptables

# Internal address to forward to
FWRD_AD=192.168.1.6

# TCP
##########################################
# Comma seperated list of tcp ports
# Connections destined for services on these ports will be allowed as will
# responses from these be allowed out
TCP_IN=80,443,22,21,20

# Ports that should be reachable from the internal network
TCP_OUT=$TCP_IN

# UDP
##########################################
# Comma seperated list of udp ports
# Connections destined for services on these ports will be allowed as will
# responses from these be allowed out
UDP_IN=53

# ICMP
##########################################
# Incoming ICMP type
# ICMP packets of this type will be allowed
ICMP_IN=echo-request


# External Network Settings
##########################################

# Network address for your external ip
# ex: 10.1.1.0/24
EXT_NET_ADR=192.168.0.0/24

# Network device used on external network
EXT_NET_DEV=em1



# Internal Network Settings
##########################################

# Network address for your internal ip
# ex: 10.1.1.0/24
INT_NET_ADR=192.168.1.0/24

# Network device used on external network
INT_NET_DEV=p3p1



# TOS Settings
##########################################

# TCP connections on these ports will have max throughput flags set on them
MAX_TPT=20

# TCP connections on these ports will have low delay flags set on them
LOW_DLY=22,21
