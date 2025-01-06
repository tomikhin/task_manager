#!/bin/bash

# To load variables containing user, password and database name for database connection
source config/db_params.sh

echo "Content-type: text/html"
echo ""

# Receive the passed argument (task ID)
read input
task_id=$(echo "$input" | grep -oP 'task_id=\K[^&]*')

# Check if task_id is a number (to prevent any attempts of SQL-injections)
if ! [[ "$task_id" =~ ^[0-9]+$ ]]; then
    echo "<html>"
    echo "<head><title>Completing task</title></head>"
    echo "<body>"
	echo "<h3><a href='/index.html'>Task Manager</a></h3>"
    echo "<hr>"
    echo "<h2>Completing task</h2>"
    echo "<p><font color='red'>Error: Task ID must be a number.</font></p>"
    echo "<a href='/cgi-bin/show_tasks.sh'>Return to the list of tasks</a>"
    echo "</body>"
    echo "</html>"
    exit 1
fi

echo "<html>"
echo "<head><title>Completing task</title></head>"
echo "<body>"
echo "<h3><a href='/index.html'>Task Manager</a></h3>"
echo "<hr>"
echo "<h2>Completing task</h2>"

# SQL-query to complete a task
row_count=$(mariadb -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "UPDATE tasks SET status='completed', finished_at = NOW() WHERE id = $task_id; select row_count();") #2>/dev/null

# Check if previous command was successful
if [ $? -eq 0 ]; then
	
	# Extract the number of modified rows in the table
	row_count1=$(echo "$row_count" | tail -n 1)
	if [ "$row_count1" -eq 1 ]; then
		
		# If it equals 1 then the task has been completed
		echo "<p>Task with ID $task_id has been successfully completed.</p>"
		
		# Execute the transfer_task.sh script with the given task ID, 
		# redirecting both standard output and standard error to capture any errors or output in the variable 'result'.
		result=$( ./transfer_task.sh "$task_id" 2>&1 )
		
		# Check if previous command was successful
		if [ $? -eq 0 ]; then
			echo "<p>Transfer - OK.</p>"
			echo "<p>$result</p>"
		
		else
			echo "<p><font color='red'>Transfer - ERROR ($? - $result)</font></p>"
		fi
		echo "<a href='/cgi-bin/show_tasks.sh'>Return to the list of tasks</a>"
	
	else
		# Otherwise, the task with the given ID does not exist in the table
	    echo "<p><font color='red'>Task completion error. Check ID.</font></p>"
		echo "<a href='/cgi-bin/show_tasks.sh'>Return to the list of tasks</a>"
	fi

else
    echo "<p><font color='red'>Task completion error. Check database connection.</font></p>"
    echo "<a href='/cgi-bin/show_tasks.sh'>Return to the list of tasks</a>"
fi

echo "</body>"
echo "</html>"
