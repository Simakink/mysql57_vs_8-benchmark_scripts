#!/usr/bin/env bash

host=$1
port=3306
user="testuser"
password="BYVVfJBln05PqXE7U8hJbQ5L"
table_size=100000
tables=10
rate=20
ps_mode='disable'
threads=1
events=0
time=300
trx=100
date=`date +%F-%H_%M`
path=$date
counter=1
mkdir -p "$path"

echo "thread,cpu" > $path/${host}-cpu.csv

for i in 16 32 64 128 256 512 1024 2048; 
do 

    threads=$i

    mysql -e "SHOW GLOBAL STATUS" >> "$path"/$host-global-status.log
    tmpfile=$path/${host}-tmp${threads}
    touch $tmpfile
    /bin/bash cpu-checker.sh $tmpfile &

    /usr/share/sysbench/oltp_read_write.lua --db-driver=mysql --events=$events --threads=$threads --time=$time --mysql-host=$host --mysql-user=$user --mysql-password=$password --mysql-port=$port --report-interval=1 --skip-trx=on --tables=$tables --table-size=$table_size --rate=$rate --delete_inserts=$trx --order_ranges=$trx --range_selects=on --range-size=$trx --simple_ranges=$trx --db-ps-mode=$ps_mode --mysql-ignore-errors=all run | tee -a $path/$host-sysbench.log

    #cp ${tmpfile} ${tmpfile}-bak
    echo "${i},"`cat "${tmpfile}".stat | sort -nr | head -1` >> $path/${host}-cpu.csv
    unlink ${tmpfile}
    mysql  -e "SHOW GLOBAL STATUS" >> $path/$host-global-status.log
done

python3 innodb-ops-parser.py $host $date

mysql -e "SHOW GLOBAL VARIABLES" >> $path/$host-global-vars.log
