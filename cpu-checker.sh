#!/usr/bin/env bash
tmpfile=$1

while [ -f $tmpfile ];
do
    sleep 1; top -p $(pidof mysqld) -b -n1|grep '%CPU' -A1|awk 'NR>1{print $9}' >> "$tmpfile".stat
done

