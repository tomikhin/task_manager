#!/bin/bash

# To load variables containing user, password and database name for database connection
source config/db_params.sh

echo "Content-type: text/html"
echo ''

echo "<!DOCTYPE html>"
echo "<html>"
echo "<head>"
echo "<title>Task Manager</title>"
echo "</head>"
echo "<body>"
echo "<h3><a href='/index.html'>Task Manager</a></h3>"
echo "<hr>"
echo "<h2>The list of tasks</h2>"
echo "<a href='/cgi-bin/task.sh'>Add task</a>"

# SQL-query to show tasks
tasks=$(mariadb -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT id, description, deadline, priority, status FROM tasks;") #2>/dev/null

# If the previous command was not successful, display an error message
if [ $? -ne 0 ]; then
    echo "<p><font color='red'>Database connection error.</font></p>"
    echo "</body>"
    echo "</html>"
    exit 1
fi

# If variable $tasks is empty, there are no tasks
if [[ -z "$tasks" ]]; then
    echo "<p>Tasks missing.</p>"
else
	# Otherwise, create a table containing all tasks
	echo "<table border='1'>"
    echo "<tr>"
    echo "<th>Task ID</th>"
    echo "<th>Description</th>"
    echo "<th>Deadline</th>"
    echo "<th>Priority</th>"
    echo "<th>Status</th>"
    echo "</tr>"
	
	# Split the task details into tab-delimited fields and iterate through each task (skipping the header row).
	# For each task, read the columns into variables: id, description, deadline, priority and status.

	IFS=$'\t'
	echo "$tasks" | tail -n +2 | while read -r id description deadline priority status; do
			
			# Fill in the row with all the details of the task
			echo "<tr>"
			echo "<td align='center'><a href='/cgi-bin/task.sh?task_id=$id'>$id</a></td>"
			echo "<td>$description</td>"
			echo "<td>$deadline</td>"
			
			# Paint the value of the variable $priority yellow/orange/red
			if [ "$priority" == "low" ]; then
				echo "<td><font color='#DAA520'>$priority</font></td>"
				
			elif [ "$priority" == "medium" ]; then
				echo "<td><font color='#FF8C00'>$priority</font></td>"
			
			else
				echo "<td><font color='red'>$priority</font></td>"
			fi
			
			# Paint the value of the variable $status green if the task is completed
			if [ "$status" == "completed" ]; then
				echo "<td><font color='green'>$status</font></td>"
			else 
				echo "<td>$status</td>"
			fi
			echo "</tr>"

    done

    echo "</table>"
fi

echo "</body>"
echo "</html>"
