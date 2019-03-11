#!/bin/bash

logfile=/var/log/system-bootstrap.log
config_file=root/conf

#redirect ouput
exec 2>&1 > $logfile


hostname=($(awk -F ":" '{if("hostname"==$1)print $2}' $config_file))
echo Se seteaza Hostname: "$hostname"
sudo hostnameclt set-hostname $hostname
echo $?
echo Se configureaza retele
networks=($(awk -F ":" '{if("network"==$1)print $2}' $config_file))
networks=$(echo $networks | tr "," "\n")
for net in $networks
do
   echo Se configureaza reteaua: "$net"
   sudo ifup $net
   echo $?
done

update=($(awk -F ":" '{if("updates"==$1 && "true"==$2) print $2 }' $config_file))
if [[ $update == true ]] 
then
   echo se actualizeaza programele
fi

programs=($(awk -F ":" '{if("install"==$1)print $2}' $config_file))
programs=$(echo $programs | tr "," "\n")
for prog in $programs
do
   echo Se instaleaza : "$prog"
   sudo yum install $prog
   echo $?
done

echo se configureaza o cheie de tip rsa

ssh-keygen -t rsa
chmod 700 /root/.ssh
chmod 600 /root/id_rsa
cat /root/id_rsa.pub >> root/.ssh/authorized_keys
restorecon -Rv /.ssh
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config


