#!/bin/bash
contig=$1
node=$2
base=$3
mark_name=$(echo $contig | sed 's/:/_/g')
random=$(shuf -i 10-50 -n 1)

touch ${base}/nodes/${node}/${mark_name}.start
sleep $((10+random))
touch ${base}/nodes/${node}/${mark_name}.end
