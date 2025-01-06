#!/bin/bash

# To load variables containing user, password and database name for database connection
source config/db_params.sh

task_id=$1

# Check if task_id is a number 
if ! [[ "$task_id" =~ ^[0-9]+$ ]]; then
    echo "Task ID must be a number."
    exit 1
else
	# SQL-query to extract a row in table by task ID 
	result=$(mariadb -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT * FROM tasks WHERE id='$task_id';")
	
	# Check if the task with the given ID exists
	if [ -n "$result" ]; then
	
		# Send task name via port 50001
		echo "TASK-$task_id" | nc -q 1 127.0.0.1 50001
		if [ $? -eq 0 ]; then
			sleep 0.5
			
			# Send task details via port 50001
			echo "$result" | nc -q 1 127.0.0.1 50002
			if [ $? -eq 0 ]; then
				echo "Task transfer to archive has been successful."
			else 
				echo "Transfer error TASK DETAILS"
				exit 2
			fi
		else	
			echo "Transfer error TASK NAME"
			exit 3
		fi
	else 
		echo "There is no task with such ID. Check ID."
		exit 4
	fi
fi
