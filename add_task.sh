#!/bin/bash

# To load variables containing user, password and database name for database connection
source config/db_params.sh

echo "Content-type: text/html"
echo ""

# Receive the passed arguments
read input
description=$(echo "$input" | grep -oP 'description=\K[^&]*' | sed 's/+/ /g' | sed 's/%20/ /g')
deadline=$(echo "$input" | grep -oP 'deadline=\K[^&]*' | sed 's/+/ /g' | sed 's/%20/ /g' | sed 's/%3A/:/g')
priority=$(echo "$input" | grep -oP 'priority=\K[^&]*' | sed 's/+/ /g' | sed 's/%20/ /g')

echo "<html>"
echo "<head><title>Task Manager</title></head>"
echo "<body>"
echo "<h3><a href='/index.html'>Task Manager</a></h3>"
echo "<hr>"
echo "<h2>Adding a task</h2>"


# Check that all fields are filled in
if [ -z "$description" ] || [ -z "$deadline" ] || [ -z "$priority" ]; then
    echo "<p><font color='red'>Error: All fields must be filled.</font></p>"
    echo "<a href='/cgi-bin/task.sh'>Return to the task adding form</a>"
else
	# SQL-query to update task
    mariadb -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "INSERT INTO tasks (description, deadline, priority) VALUES ('$description', '$deadline', '$priority');"

	# Check if previous command was successful
    if [ $? -eq 0 ]; then
        echo "<p>Task has been successfully added:</p>"
        echo "<ul>"
        echo "<li>Description: $description</li>"
        echo "<li>Deadline: $deadline</li>"
        echo "<li>Priority: $priority</li>"
        echo "</ul>"
        echo "<a href='/cgi-bin/show_tasks.sh'>Return to the list of tasks</a>"
    else
        echo "<p><font color='red'>Error adding task. Try again.</font></p>"
        echo "<a href='/cgi-bin/task.sh'>Return to the task adding form</a>"
    fi
fi

echo "</body>"
echo "</html>"

