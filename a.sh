#!/bin/bash

hostname=$(awk -F ":" '{if("hostname"==$1)print $2}' /root/conf)
echo $hostname

networks=($(awk -F ":" '{if("network"==$1)print $2}' /root/conf))
networks=$(echo $networks | tr "," "\n")
for net in $networks; do
   ifup $net > echo $?
done
