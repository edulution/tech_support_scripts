#!/bin/bash

export green=`tput setaf 2`
export reset=`tput sgr0`

# delete all learner activity data prior to 1st January 2019
# logged hours remains untouched

function clear_learner_activity(){
	#path to ka-lite database
	database_path=~/.kalite/database/data.sqlite

	# get databse name
	database_name=$(sqlite3 $database_path "SELECT d.name FROM securesync_device d JOIN securesync_devicemetadata s WHERE s.device_id = d.id AND s.is_own_device = 1")
	file_extension=".sqlite"
	timestamp=$(date +"%Y%m%d")
	backup_name=${database_name}_${timestamp}${file_extension}

	#make database backup
	echo "Creating datbase backup"
	cp $database_path ~/backups/$backup_name

	# stop the services for kalite and nginx
	echo "Stopping kalite and nginx services"
	sudo service ka-lite stop > /dev/null 
	sudo service nginx stop > /dev/null


	echo "Clearing exerciselog"
	# clear main_exerciselog based on completion_timestamp, latest_activity_timestamp or when each of these are null
	sqlite3 ~/.kalite/database/data.sqlite "delete from main_exerciselog where completion_timestamp <= '2018-12-31' or latest_activity_timestamp <= '2018-12-31' or completion_timestamp is null or latest_activity_timestamp is null;"

	echo "Clearing videolog"
	# clear main_videolog based on completion_timestamp, latest_activity_timestamp or when each of these are null
	sqlite3 ~/.kalite/database/data.sqlite "delete from main_videolog where completion_timestamp <= '2018-12-31' or latest_activity_timestamp <= '2018-12-31' or completion_timestamp is null or latest_activity_timestamp is null;"
	
	echo "Clearing main_userlog"
	#clear main_userlog based on timestamp
	sqlite3 ~/.kalite/database/data.sqlite "delete from main_userlog where last_active_datetime <= '2018-12-31';"

	echo "Clearing main_userlogsummary"
	#clear main_userlogsummary based on timestamp
	sqlite3 ~/.kalite/database/data.sqlite "delete from main_userlogsummary where last_activity_datetime <= '2018-12-31';"

	echo "Clearing main_attemptlog"
	# clear main_attemptlog based on timestamp
	sqlite3 ~/.kalite/database/data.sqlite "delete from main_attemptlog where timestamp <= '2018-12-31';"

	echo "Vacuuming database"
	# finally vacuum the db
	sqlite3 $database_path "vacuum"


	echo "${greem}Done!${reset}"
}

clear_learner_activity

# after running clear activity script, clear history on chrome browser on laptop and tablets
