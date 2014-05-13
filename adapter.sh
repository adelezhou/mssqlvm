#!/usr/bin/env bash

#IP for the network adapter
ip="192.168.56.1"

adapter=`VBoxManage list hostonlyifs | awk -v _ip=$ip 'BEGIN { RS = "" } $8==_ip { print $2 }'`
if [ "$adapter" == "" ];
then
  result=`VBoxManage hostonlyif create`
  if [[ "$result" =~ .*"successfully created".* ]]
  then
    adapter=`echo $result | grep -o "vboxnet[0-9]*"`
    # adapter=`VBoxManage list hostonlyifs | awk 'BEGIN { RS = "" } { print $2 }' | tail -n1`
    VBoxManage hostonlyif ipconfig "$adapter" --ip $ip
    echo "created adapter $adapter and set its IP to $ip"
  else
    echo $result
    exit 1
  fi
else
  echo "found adapter $adapter with IP $ip"
fi
