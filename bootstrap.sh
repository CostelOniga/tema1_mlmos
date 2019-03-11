#!/bin/bash

logfile=/var/log/system-bootstrap.log
config_file=root/conf

#redirect ouput
exec 2>&1 >> $logfile


hostname=$(awk -F:'{if("hostname"==$1)print $2}' $config_file)
echo Se seteaza Hostname: "$hostname"
sudo hostnameclt set-hostname "$hostname"

echo Se configureaza retele
networks=($(awk -F ":" '{if("network"==$1)print $2}' $config_file))
networks=$(echo $networks | tr "," "\n")
for net in $networks; do
   Se configureaza reteaua: "$net"
   sudo ifup $net
done

update=($(awk -F ":" '{if("update"==$1 && "true"==$2) print $2 }' $config_file))
if [[ $update == true ]] then
   echo se actualizeaza programele
fi

