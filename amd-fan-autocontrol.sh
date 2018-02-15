#!/bin/bash
TARGET_T=$1
echo Target temperature is: $TARGET_T C

SPEED=(50 50 50 50 50 50)

for i in `seq 0 5`
do
	SPEED[$i]=`~/repo/amdcovc/amdcovc -a $i | grep -o "Fan: [0-9]\+" | grep -o "[0-9]\+"`
    echo "speed[$i] = ${SPEED[$i]}"
done

function adjust {
	local TEMP=`~/repo/amdcovc/amdcovc -a $1 | grep -o "Temp: [0-9]\+" | grep -o "[0-9]\+"`
	#echo TEMP=$TEMP SPEED=${SPEED[$1]}
	if [ $TEMP -gt $TARGET_T ]
	then
		local NEW_SPEED=$((${SPEED[$1]}+1))
        if [ $NEW_SPEED -le 100 ]
        then
    		~/repo/amdcovc/amdcovc fanspeed:$1=$NEW_SPEED > /dev/null
	    	echo "Set fanspeed $NEW_SPEED for adapater $1 (+1) $TEMP C"
            SPEED[$1]=$NEW_SPEED
        fi
	elif [ $TEMP -lt $TARGET_T ]
	then
		local NEW_SPEED=$((${SPEED[$1]}-1))
        if [ $NEW_SPEED -ge 0 ]
        then
    		~/repo/amdcovc/amdcovc fanspeed:$1=$NEW_SPEED > /dev/null
	    	echo "Set fanspeed $NEW_SPEED for adapater $1 (-1) $TEMP C"
            SPEED[$1]=$NEW_SPEED
        fi
	fi
}

while :
do
	for i in `seq 0 5`; do adjust $i; done
    echo
	sleep 10 
done

