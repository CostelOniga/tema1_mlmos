#!/bin/bash

logfile=/var/log/system-bootstrap.log
config_file=/root/conf

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

conf_memory=($(awk -F ":" '{if("memory"==$1) print $2}' $config_file))
machine_memory=($(awk -F ":" '{if("MemTotal"==$1) print $2}' /proc/meminfo))
conf_memory=conf_memory*1024^2
if [[ $conf_memory==$machine_memory ]]
then
   echo Memoria masinii este configurata corect
else 
   echo Memoria masinii nu este configurata corect
fi

machine_cpu=($(awk -F ":" '{if("processor"==$1) print $2}' /proc/cpuinfo))
conf_cpu=($(awk -F ":" '{if("cpu"==$1) print $2}' $config_file))
if [[ $machine_cpu==$conf_cpu ]]
then
   echo Procesorul este configurat corect
else
   echo Procesorul nu este confugurat corect
fi


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
mkdir /root/.ssh
ssh-keygen -t rsa
cp /$(dirname $0)/id_root.pub /root/.ssh/
cat /root/id_rsa.pub >> root/.ssh/authorized_keys
restorecon -Rv /.ssh
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config


