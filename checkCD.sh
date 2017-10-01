#!/bin/bash

DVDDRIVE=/dev/sr0
BYTES=2048
tmpcdhash=$(mktemp /tmp/check-cd.XXXX)
tmpisohash=$(mktemp /tmp/check-cd.XXXX)
echo $tmpcdhash
if [ -e $1 ] ; then 
	ISOFILE=$1
else
	echo "Enter the complete path to the iso you want to use as a reference"
	read -e ISOFILE
	echo
	if  ! -e $ISOFILE ; then
		echo -e "Path or file doesn't exist, please try again \n" 
	fi
fi 

NROFEXTENDS=$(($(ls -l $ISOFILE | awk '{ print $5 }') / $BYTES ))

echo "Isofile: " $ISOFILE
echo "Nr of extends: " $NROFEXTENDS

sha256sum $ISOFILE > $tmpcdhash &
SHAID=$!

dd if=$DVDDRIVE bs=$BYTES count=$NROFEXTENDS | sha256sum > $tmpisohash 2>/dev/null &
ISOID=$!

echo -e "Calculating sha256 hash..." | tr -d '\n'
while [[ -e /proc/$ISOID/cmdline ]]  ; do echo . | tr -d '\n' && sleep 1 ; done &

wait $SHAID && CDHASH=$(cat $tmpcdhash | cut -f1 -d' ') && echo "Hash cd ----> " $CDHASH
wait $ISOID && ISOHASH=$( cat $tmpisohash | cut -f1 -d' ' ) && echo "Hashiso ----> " $ISOHASH

[[ $CDHASH == $ISOHASH ]] && echo "Hash MATCH!" || echo "Hash NOT match!"
