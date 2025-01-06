#!/bin/bash

# To load variables containing user, password and database name for database connection
source config/db_params.sh

echo "Content-type: text/html"
echo ""

# Receive the passed argument (task ID)
task_id=$(echo "$QUERY_STRING" | grep -oP 'task_id=\K[^&]*')


echo "<html>"
echo "<head>"
echo "<title>Task Manager</title>"
echo "</head>"
echo "<body>"
echo "<h3><a href='/index.html'>Task Manager</a></h3>"
echo "<hr>"


if [ -z "$task_id" ]; then
    # If there is no argument (task_id is not specified in the URL), display a form for adding a task
    echo "<h2>Adding a Task</h2>"
    echo "<form action='/cgi-bin/add_task.sh' method='post'>"
    echo "<label for='description'>Task description:</label>"
    echo "<input type='text' id='description' name='description' required>"
    echo "<label for='deadline'>Deadline:</label>"
    echo "<input type='datetime-local' id='deadline' name='deadline' required>"
    echo "<label for='priority'>Priority:</label>"
    echo "<select id='priority' name='priority' required>"
    echo "<option value='low'>low</option>"
    echo "<option value='medium'>medium</option>"
    echo "<option value='high'>high</option>"
    echo "</select>"
    echo "<button type='submit'>Add</button>"
    echo "</form>"

else
	# check if task_id is a number (to prevent any attempts of SQL-injections)
	if ! [[ "$task_id" =~ ^[0-9]+$ ]]; then
		echo "<p><font color='red'>Error: Task ID must be a number.</font></p>"
		echo "<a href='/cgi-bin/show_tasks.sh'>Return to the list of tasks</a>"
		exit 1
	fi

    # If task_id is specified, get the task data from the database
    result=$(mariadb -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SELECT description, deadline, priority, created_at, updated_at, status, finished_at FROM tasks WHERE id='$task_id';" | tail -n 1)
    # Split the result into variables
    description=$(echo "$result" | awk -F '\t' '{print $1}')
    deadline=$(echo "$result" | awk -F '\t' '{print $2}')
    priority=$(echo "$result" | awk -F '\t' '{print $3}')
    created_at=$(echo "$result" | awk -F '\t' '{print $4}')
    updated_at=$(echo "$result" | awk -F '\t' '{print $5}')
    status=$(echo "$result" | awk -F '\t' '{print $6}')
    finished_at=$(echo "$result" | awk -F '\t' '{print $7}')
    
    # If the task was found, display a form for editing a task
    if [ -n "$description" ]; then
        echo "<h2>Editing Task #$task_id</h2>"
        echo "<form action='/cgi-bin/edit_task.sh' method='post'>"
        echo "<input type='hidden' name='task_id' value='$task_id'>"
        echo "<label for='description'>Task description:</label>"
        echo "<input type='text' id='description' name='description' value='$description' required>"
        echo "<label for='deadline'>Deadline:</label>"
        echo "<input type='datetime-local' id='deadline' name='deadline' value='$deadline' required>"
        echo "<label for='priority'>Priority:</label>"
        echo "<select id='priority' name='priority' required>"
        echo "<option value='low' $( [ "$priority" = "low" ] && echo "selected" )>low</option>"
        echo "<option value='medium' $( [ "$priority" = "medium" ] && echo "selected" )>medium</option>"
        echo "<option value='high' $( [ "$priority" = "high" ] && echo "selected" )>high</option>"
        echo "</select>"
        echo "<br><br>"
        echo "<label for='created_at'>Created at:</label>"
        echo "<input type='datetime-local' id='created_at' value='$created_at' readonly>"
        echo "<label for='updated_at'>Updated at:</label>"
        echo "<input type='datetime-local' id='updated_at' value='$updated_at' readonly>"
        echo "<br><br>"
        echo "<label for='status'>Status:</label>"
        echo "<input type='text' id='status' value='$status' readonly>"
        echo "<label for='finished_at'>Finished at:</label>"
        echo "<input type='datetime-local' id='finished_at' value='$finished_at' readonly>"
        echo "<br>"
        echo "<button type='submit'>Save Changes</button>"
        echo "</form>"
        
        # Form for deleting a task
        echo "<form action='/cgi-bin/delete_task.sh' method='post'>"
		echo "<input type='hidden' name='task_id' value='$task_id'>"
		echo "<button type='submit'>Delete Task</button>"
		echo "</form>"
		
		# Form for completing a task
		echo "<form action='/cgi-bin/complete_task.sh' method='post'>"
		echo "<input type='hidden' name='task_id' value='$task_id'>"
		echo "<button type='submit'>Complete Task</button>"
		echo "</form>"
    else
        # If the task was not found, display an error message
        echo "<p><font color='red'>Error: Task with ID $task_id not found.</font></p>"
    fi
fi
# Link to return to the task list
echo "<br><a href='/cgi-bin/show_tasks.sh'>Return to the list of tasks</a>"
echo "</body>"
echo "</html>"
