#!/usr/bin/bash

export MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
export MYSQL_USER="${MYSQL_USER:-quarkus}"
export MYSQL_PASSWORD="${MYSQL_PASSWORD:-quarkus}"
export MYSQL_DB="${MYSQL_DB:-mysql}"
export MYSQL_INNODB_STATUS_INTERVAL="${MYSQL_INNODB_STATUS_INTERVAL:-1}" #interval retrieving SHOW ENGINE INNODB STATUS
export START_WAIT="${START_WAIT:-1}" #wait in seconds before starting command

/usr/bin/expect -c '
set host "$env(MYSQL_HOST)"
set user "$env(MYSQL_USER)"
set passwd "$env(MYSQL_PASSWORD)"
set database "$env(MYSQL_DB)"
set interval "$env(MYSQL_INNODB_STATUS_INTERVAL)"
set start_wait "$env(START_WAIT)"
set current_date [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
set timeout -1
log_user 1
log_file -a /usr/src/app/logs/deadlock-logger.log
puts "STARTING - $current_date"
sleep $start_wait
spawn -noecho -ignore HUP pt-deadlock-logger h=$host,D=$database,u=$user,p=$passwd --interval=$interval --tab
expect eof
log_file'
