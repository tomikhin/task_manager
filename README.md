# Task Manager Project

**Task Manager** is a web-application for task management, developed using Bash, HTML, MariaDB, Apache, and sockets.

## Features
1. **Add Tasks**: Specify the description, deadline, and priority of a task.
2. **Edit Tasks**: Update task details using a form.
3. **View Tasks**: Display all tasks in a structured table format.
4. **Complete Tasks**: Mark tasks as completed, transfer them to an archive using sockets, and save their details in text files.
5. **Delete Tasks**: Delete selected tasks.
6. **Task Tracking**: Automatic tracking of task creation date and last modification date.

## Prerequisites
Before running the project, ensure the following:
1. **MariaDB**:
   - Create a database named `task_manager_db` using `mariadb.sql` script.
   - Create a directory `config` in `/lib/cgi-bin/` and place `db_params.sh` in it.
2. **Apache Web Server**:
   - Configure the server to process CGI scripts.
   - Place `.sh` files in the appropriate CGI directory (/lib/cgi-bin).
   - Place `index.html` file in the appropriate HTML directory (/var/www/html).
   - Place images in the appropriate `images` directory (/var/www/html/images).
3. **Socket Support**:
   - Ensure that the `nc` (netcat) command is installed.
   - Place `server.sh` in any directory and in this directory create another directory called `archive`
   - Start a socket server `./server.sh`.
4. **Permissions**:
   - Set executable permissions for all `.sh` scripts using `chmod +x <script_name>`.

## Usage
1. Start the Apache web server and ensure MariaDB is running.
2. Open the web application `localhost/index.html` in your browser:
   - Add tasks using the "Add Task" form.
   - Edit, delete or complete tasks by clicking the task ID in the task list.
   - Mark tasks as completed to move them to the archive.
3. For socket operations, ensure the server script is running in the background:
`./server.sh`
