#!/bin/bash

logfile=/var/log/system-bootstrap.log
config_file="$(dirname $0)/conf/file.conf

exec 2>&1 >> $logfile

echo "am reusit"
