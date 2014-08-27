#!/bin/sh
set -eu

DROPLIST="droplist.txt"

head() {
  echo "*mangle"
  echo ":PREROUTING ACCEPT"
  echo ":INPUT ACCEPT"
  echo ":FORWARD ACCEPT"
  echo ":OUTPUT ACCEPT"
  echo ":POSTROUTING ACCEPT"
  echo "COMMIT"
  echo ""
  echo "*nat"
  echo ":PREROUTING ACCEPT"
  echo ":POSTROUTING ACCEPT"
  echo ":OUTPUT ACCEPT"
  echo "COMMIT"
  echo ""
  echo "*filter"
  echo ":INPUT ACCEPT"
  echo ":FORWARD ACCEPT"
  echo ":OUTPUT ACCEPT"
}
body() {
  cat ${DROPLIST} | while read line
  do
    STRCHECK=$(echo ${line} | cut -c 1)
    if [ $STRCHECK != "#" ];then
      echo "-A INPUT -s ${line} -j DROP"
    fi
  done
}
foot() {
  echo "-A INPUT -j ACCEPT"
  echo "COMMIT"
}


head > rule
body >> rule
foot >> rule

for target in mangle nat filter
do
  iptables -F -t $target
done

iptables-restore < rule

for target in mangle nat filter
do
  echo
  echo "## $target"
  iptables -nL -t $target
done
