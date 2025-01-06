#!/bin/bash

#Infinite loop in order for server to always remain active

while true; do
	# Receive task name
	TASK_NAME=$(nc -l -p 50001)
	
	# Receive task details 
	TASK_DETAILS=$(nc -l -p 50002)

	echo $TASK_DETAILS > archive/$TASK_NAME.txt
	echo "$TASK_NAME has been successfully received"
	
	sleep 1
done
