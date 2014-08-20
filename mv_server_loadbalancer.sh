#!/bin/bash

# This script will drain a server from haproxy cluster
# Author: James Attard [james.attard@cherrygroup.com]
# Date: 07-01-2014

HAPROXY_CFG="/etc/haproxy/haproxy.cfg"
HAPROXY_PID=`ps -ef | grep haproxy | grep -v grep | awk -F" " {'print $2'}`

if [ $# -eq 0 ]
then
	echo "Usage mv_server_loadbalancer.sh [server] [in|out]"
	exit 1
elif [ $# -gt 2 ]
then
	echo "Usage mv_server_loadbalancer.sh [server] [in|out]"
	exit 1
fi

if [ $2 == "out" ]
then
	DRAIN_EXEC=`sed -i 's/server '$1'/#server '$1'/g' $HAPROXY_CFG`
	echo -n "Moving server $1 outside loadbalancer. Please wait..."
elif [ $2 == "in" ]
then
	DRAIN_EXEC=`sed -i 's/#server '$1'/server '$1'/g' $HAPROXY_CFG`
	echo -n "Moving server $1 inside loadbalancer. Please wait..."
else
	echo "Usage mv_server_loadbalancer.sh [server] [in|out]"
        exit 1
fi

nohup haproxy -p /var/run/haproxy.pid -f /etc/haproxy/haproxy.cfg -sf $HAPROXY_PID > /dev/null 2>&1 &

while :
	do
	echo -n "."
	sleep 1
	HAPROXY_PROCS=`ps -ef | grep haproxy | grep -v grep | wc -l`
	if [ $HAPROXY_PROCS -eq 1 ]
	then
		break
	fi
done

echo
echo "Server $1 was successfully moved"
exit 0
