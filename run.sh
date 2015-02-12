#########################################
###          Firewall Execution       ###
#########################################

#########################################
###   !!!!     DO NOT EDIT    !!!!    ###
#########################################

# import user defined variables
source settings.sh

# Upper limit of service ports
SRV=1024
MAX=65535

# Clear out existing firewall rules
$FW_PATH -F
$FW_PATH -t nat -F
$FW_PATH -t mangle -F
$FW_PATH -Z

# Set default rules
$FW_PATH -P INPUT DROP
$FW_PATH -P OUTPUT DROP
$FW_PATH -P FORWARD DROP

$FW_PATH -X TCP
$FW_PATH -X UDP
$FW_PATH -X ICMP

$FW_PATH -N TCP
$FW_PATH -N UDP
$FW_PATH -N ICMP

# Set up outbound NAT
$FW_PATH -t nat -A POSTROUTING -o $EXT_NET_DEV -j MASQUERADE

# Set up inbound NAT for port forwarding
$FW_PATH -t nat -A PREROUTING -i $EXT_NET_DEV -p tcp -m multiport --dports $TCP_IN -j DNAT --to-destination $FWRD_AD
$FW_PATH -t nat -A PREROUTING -i $EXT_NET_DEV -p udp -m multiport --dports $UDP_IN -j DNAT --to-destination $FWRD_AD
$FW_PATH -t nat -A PREROUTING -i $EXT_NET_DEV -p icmp --icmp-type $ICMP_IN -j DNAT --to-destination $FWRD_AD


# Drop things that could be suspect
########################################

# Drop anything that appears to be from the internal network
$FW_PATH -A FORWARD -i $EXT_NET_DEV -s $INT_NET_ADR -j DROP

# Drop any SYN's targeting high ports
$FW_PATH -A FORWARD -p tcp --syn -m multiport --dports $(($SRV+1)):$MAX -j DROP

# Drop target port 0
$FW_PATH -A FORWARD -p tcp --dport 0 -j DROP
$FW_PATH -A FORWARD -p udp --dport 0 -j DROP

# Drop source port 0
$FW_PATH -A FORWARD -p tcp --sport 0 -j DROP
$FW_PATH -A FORWARD -p udp --sport 0 -j DROP

# Drop service -> service
$FW_PATH -A FORWARD -p tcp --sport 0:$SRV --dport 0:$SRV -j DROP
$FW_PATH -A FORWARD -p udp --sport 0:$SRV --dport 0:$SRV -j DROP

# Drop SYN/FIN
$FW_PATH -A FORWARD -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

# Drop telnet in and out
$FW_PATH -A FORWARD -p tcp --sport 23 -j DROP

# Drop traffic to 32758-32775
$FW_PATH -A FORWARD -i $EXT_NET_DEV -p tcp -m multiport --dports 32758:32775 -j DROP
$FW_PATH -A FORWARD -i $EXT_NET_DEV -p udp -m multiport --dports 32758:32775 -j DROP

# Drop traffic to 137-139
$FW_PATH -A FORWARD -i $EXT_NET_DEV -p tcp -m multiport --dports 137:139 -j DROP
$FW_PATH -A FORWARD -i $EXT_NET_DEV -p udp -m multiport --dports 137:139 -j DROP

# Drop connections to 111,515
$FW_PATH -A FORWARD -i $EXT_NET_DEV -p tcp -m multiport --dports 111,515 -j DROP

# Set min delay
$FW_PATH -A FORWARD -t mangle -p tcp -m multiport --dports $LOW_DLY -j TOS --set-tos Minimize-Delay

# Set ftp data to max throughput
$FW_PATH -A FORWARD -t mangle -p tcp -m multiport --dports $MAX_TPT -j TOS --set-tos Maximize-Throughput

# Forward connectinos that passed tests into state filters
$FW_PATH -A FORWARD -p tcp -j TCP
$FW_PATH -A FORWARD -p udp -j UDP
$FW_PATH -A FORWARD -p icmp -j ICMP



# TCP
########################################

# Allow outbound
$FW_PATH -A TCP -i $INT_NET_DEV -j ACCEPT

# Allow existing TCP connections
$FW_PATH -A TCP -i $EXT_NET_DEV -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow incoming connections to specific ports
$FW_PATH -A TCP -i $EXT_NET_DEV -p tcp -m multiport -m state --dports $TCP_IN --state NEW -j ACCEPT

# Drop rest
$FW_PATH -A TCP -j DROP



# UDP
########################################

# Allow outbound
$FW_PATH -A UDP -i $INT_NET_DEV -j ACCEPT

# Allow UDP "connections"
$FW_PATH -A UDP -i $EXT_NET_DEV -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow incoming connections to specific ports
$FW_PATH -A UDP -i $EXT_NET_DEV -p udp -m multiport -m state --dports $UDP_IN --state NEW -j ACCEPT

# Drop rest
$FW_PATH -A UDP -j DROP


# ICMP
########################################

# Allow outbound
$FW_PATH -A ICMP -i $INT_NET_DEV -j ACCEPT

# Allow incoming ICMP types
$FW_PATH -A ICMP -i $EXT_NET_DEV -p icmp --icmp-type $ICMP_IN -j ACCEPT

# Allow icmp responses
$FW_PATH -A ICMP -i $EXT_NET_DEV -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT
$FW_PATH -A ICMP -j DROP
