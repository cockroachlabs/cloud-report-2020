#!/bin/bash

# This file is meant to be invoked by parse-dir.sh.

DIR=$1
if [ -z "$DIR" ]
then
      echo "error: please specify directory to parse"
      exit
fi

OP=$2
if [ "$OP" == "R" ]; then
    FILE="io-rd-results"
elif [ "$OP" == "W" ]; then
    FILE="io-wr-results"
else
    echo "error: ivalid OP option; specify R for read or W for write"
      exit
fi

IOOPLOGPATH="${DIR}/${FILE}.log"
IOOPCSVPATH="${DIR}/${FILE}.csv"

if ! [ -f "$IOOPLOGPATH" ]; then
    echo "$IOOPLOGPATH does not exist"
    exit
fi

echo "uuid,cloud,machine type,date,runID,Threads,Read Throughput,Write Througput,Total Time,Latency Min,Latency Avg,Latency Max,Latency 95th Percentile,Latency Sum" > ${IOOPCSVPATH}

UUID=$(cat "${DIR}/uuid.txt")
DATA=$(pcregrep -M -o1 -o2 -o3 -o4 -o5 -o6 -o7 -o8 -o9 --om-separator="," 'Number of threads:\s+(\d+)[\s\S]+?read, MiB/s:\s+(.+?)\n\s+written, MiB/s:\s+(.+?)\n[\s\S]+?total time:\s+(.+?)s\n[\s\S]+?min:\s+(.+?)\n\s+avg:\s+(.+?)\s+max:\s+(.+?)\s+95th percentile:\s+(.+?)\s+sum:\s+(.+?)\n' ${IOOPLOGPATH})
RUNDATAPATH="${DIR}/run-data.csv"
DIRASSTRING=${DIR//\// }
MACHINE_INFO=$(echo "${DIRASSTRING}" | pcregrep --om-separator="," -o1 -o2 -o3 -o4 'results (.+?) (.+?) (.+?) (.+?)' -)

while read -r line; do
    echo "${UUID},${MACHINE_INFO},${line}" >> ${IOOPCSVPATH}
done <<< "$DATA"

echo "${UUID},${MACHINE_INFO},${DATA}" >> ${RUNDATAPATH}
