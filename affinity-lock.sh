#!/bin/bash

if [[ -z $1 ]]
then
  echo please add binary name as a parameter
  exit 1
fi
BIN=$1
ROOT_PID=`pgrep -xo $BIN`
CORE=0

function get_cpu_n_usage()  {
  echo $(grep "^cpu$1" /proc/stat|cut -d " " -f 5)
}

function cpu_last() {
  echo $(grep '^processor' /proc/cpuinfo|tail -n 1|grep -o '[0-9]')
}

function populate_cpu_usage() {
  LAST=$(cpu_last)
  for i in $(seq 0 $LAST)
  do
    CPU_FIRST[$i]=$(get_cpu_n_usage $i)
  done
  sleep 1
  for i in $(seq 0 $LAST)
  do
    CPU_SECOND[$i]=$(get_cpu_n_usage $i)
    CPU_USAGE[$i]=$((${CPU_SECOND[$i]}-${CPU_FIRST[$i]}))
    echo -e "$i\t ${CPU_USAGE[$i]}"
  done
  
}

if [[ -z $ROOT_PID ]]
then
  echo $BIN not found
  exit 1
fi

TASK_LIST=($(ls /proc/$ROOT_PID/task))
for TASK in ${TASK_LIST[*]}
do
  #CPU_USAGE=$(cut -d " " -f 14 /proc/$ROOT_PID/task/$TASK/stat)
  #echo $CPU_USAGE
  #if [[ $CPU_USAGE -gt 1000 ]]
  #then
  #  # this thread might make a dent in CPU usage, update the least busy core
    echo Analyzing CPU utilization...
    CORE=$(populate_cpu_usage|sort -n -k 2|tail -1|cut -f 1)
  #fi
  echo Locking PID $TASK to core $CORE
  taskset -c -p $CORE $TASK > /dev/null
  sleep 1
done
