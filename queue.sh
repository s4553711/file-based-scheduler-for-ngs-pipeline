#!/bin/bash
list=$1
base=$2
totalSlots=20
slots=4
IFS=$'\n' read -d '' -r -a nodes_ar < nodes.config

findRunningJobs() {
	node=$1
	NumOfStart=$(ls $base/nodes/$node/*.start 2>/dev/null | wc -l)
	NumOfEnd=$(ls $base/nodes/$node/*.end 2>/dev/null | wc -l)
	echo $((NumOfStart-NumOfEnd))
}

findNodes() {
	#echo "1> "${nodes_ar[@]}
	#echo ">"${nodes_ar[0]}

	#echo "request new node------"
	lastAssignNode=`cat $base/lastNode`
	getNode=
	i=0
	if [ $lastAssignNode -ne 999 ]; then
		i=$((lastAssignNode))
		#echo "assign> i: $i, last: $lastAssignNode"
	fi
	while [ -z $getNode ]; do
		if [ $i -ge ${#nodes_ar[@]} ]; then
			i=0
			#echo "reset> i: $i, last: $lastAssignNode"
		fi
		RunningJobs=$(findRunningJobs ${nodes_ar[$i]})
		#echo "${i}: ${nodes_ar[$i]}: Running jobs: $RunningJobs"

		if [ $RunningJobs -lt $slots ]; then
			getNode=${nodes_ar[$i]}
			lastAssignNode=$((i+1))
			echo $lastAssignNode > $base/lastNode
			#echo "getNode: ${getNode}, index: $i, last: ${lastAssignNode}"
			echo $getNode
			return
		fi
		#sleep 1
		i=$((i+1))
	done
}

export -f findNodes
#findNodes
#(cat $list | parallel -a - --joblog joblog.log --no-notice --halt-on-error 0 -k -j "3" "echo {= 's/:/_/g' =}; echo {}; findNodes")

totalRunning=$(findRunningJobs "**")
while read contig; do
	if [ $totalRunning -ge $totalSlots ]; then
		echo "Wait until $totalRunning < $totalSlots"
		while [ $totalRunning -ge $totalSlots ]; do
			echo "> r: $totalRunning max: $totalSlots"
			totalRunning=$(findRunningJobs "**")
			sleep 5
		done
	fi
	assignNode=$(findNodes)
	echo "Submit .."$contig" in $assignNode with base $base / $totalRunning"
	$base/entry.sh $base $contig $assignNode
	#ssh ${assignNode} -f "$base/freebayes.sh $contig /gfs/repo2_11/pool-bam/NGS20150311F.hs38DH.dedup.postalt.sorted.bam $base $assignNode &"
	#sleep 1
	totalRunning=$(findRunningJobs "**")
done<$list
