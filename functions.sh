#! /bin/ksh93
# current selected database
$CURDB
# Reminder :
# 1- Refer to the insert function for the solution for multiple condition in if statement using [[ ]]
#############################################################  
# TODO
# 1- in createTbl function add more checks and validation on column name 
#    like if the column name is the same as existing one etc
# 2- also validate on the table name on createTbl function
################# main menu functions ###################
################## Creating the database####################
function createDb
{
	clear
	print 'Please enter your database name ?'
	read dbName
	# create a directory for the database and create the db metadata file
	mkdir -p /home/$LOGNAME/ShellProject/$dbName
	touch /home/$LOGNAME/ShellProject/$dbName/$dbName".meta"
	echo $dbName":"$CURUSER >> /home/$LOGNAME/ShellProject/metadata.all
	clear
	# return to the main menu
	mainMenu
}
############# select a database ################
function selectDb
{
	clear
	print 'Enter the database name to select ?'
	read dbName
	# check if the given db is already exist
	for db in `ls /home/$LOGNAME/ShellProject`
	do
		if [[ $db = $dbName ]];	then
			# found the db directory 
			CURDB=$dbName
			validDb=1
			clear
			# break out the loop once the db directory is found
			break
		else
			# means the given db name not existed
			validDb=0
		fi
	done
	# checks if the db found or not 
	if [[ $validDb -eq 1 ]]; then
		# get the db operations menu
		clear
		dbMenu
	else
		echo $dbName" Not exist, Press anykey to get the main menu"
		# [-s] don't echo input character / [-n 1] reads only one character  
		read -s -n 1 
		clear
		# return to the main menu
		mainMenu
	fi
}
############# list databases ##############
function listDbs
{
	awk -F: '{print $1," Created by :",$2}END{print "press anykey to return to the main menu"}' /home/$LOGNAME/ShellProject/metadata.all
	read -s -n 1
	clear
	# return to the main menu
	mainMenu 
}
############# delete database ################
function deleteDb
{
	print 'Please enter a database name to delete?'
	read dbName;
	# check if the given db is already exist
	for db in `ls /home/$LOGNAME/ShellProject`
	do
		if [[ $db = $dbName ]];	then
			# found the db directory and remove it and it's content
			rm -r /home/$LOGNAME/ShellProject/$dbName
			# since every line in the meta file must start by database name and it's field seperated
			# so this pattern searches for any line that starts with exact word given by user
			# [^] starts with / [\<\>] when surround a word means exact match / [d] deletes the line
			# [-i] edit the file in place so no need to redirection 
			sed -i "/^\<$dbName\>/d" /home/$LOGNAME/ShellProject/metadata.all 	 
			validDb=1
			clear
			# break out the loop once the db directory is found
			break
		else
			# means the given db name not existed
			validDb=0
		fi
	done
		# checks if the db found or not 
	if [[ $validDb -eq 1 ]]; then
		# here i'm supposed to print a new menu for db operations
		echo $dbName" Successfully deleted, Press anykey to get the main menu"
		read -s -n 1
		clear
		# return to the main menu
		mainMenu
	else
		echo $dbName" Not exist, Press anykey to get the main menu"
		# [-s] don't echo input character / [-n 1] reads only one character  
		read -s -n 1 
		clear
		# return to the main menu
		mainMenu
	fi
}
############### adding user ###############
function addUser
{
	print 'Enter username ?'
	read username
	# search user info file for the given user if grep returns anything means it's exist
	if [[ `grep $username /home/$LOGNAME/ShellProject/usersInfo` ]]; then
		print 'User already exist'
	else
	# if it's not in userinfo file (not a user already)
		print 'Enter password ?'
		read password
		# write new user information in userinfo file
		echo $username":"$password >> /home/$LOGNAME/ShellProject/usersInfo
		print "\""$username"\" Created, Press anykey to get back"		
	fi

	read -s -n 1
	clear
	userTransactions
}
############# delete user #################
function deleteUser
{
	print 'Enter username to delete?'
	read username
	# serach userinfo file to see if the given user is already exist 
	if [[ `grep $username /home/$LOGNAME/ShellProject/usersInfo` ]]; then
	# delete the line that contains user data used [-i] to edit in the file directley
		sed -i "/^\<$username\>/d" /home/$LOGNAME/ShellProject/usersInfo
		print "User : \""$username"\" Deleted, Press anykey to get back"
	else
		print "\""$username"\" not exist"
	fi

	read -s -n 1
	clear
	userTransactions
}
################# User transactions menu ############### 
function userTransactions
{
	clear
	if [[ $CURUSER = 'root'  ]]; then
		# change the prompt 
		PS3='Please enter your choice : '
		# menu options 
		options=("Create User" "Delete User" "Exit")
		# drawing the menu
		select option in "${options[@]}"
		do
			case $option in 
				"Create User" )
					addUser			
					break
				;;
				"Delete User" )
					deleteUser
					break
				;;
				"Exit" )
					clear
					mainMenu
					break
				;;
				* ) 
					echo 'not a valid option'
				;;
			esac
		done
	else
		print 'Sorry you must be root to access this section!!'
		read -s -n 1
		clear
		mainMenu
	fi
}

################### end of main menu functions #################

############ create table function #################
function createTbl
{
	clear
	print 'Please enter table name ?'
	read tblName
	print 'Please enter number of columns ?'
	read columnsNo
	# [typeset -i] makes the colCounter variable treated as integer value
	typeset -i colCounter=1
	# [typeset -A] declaring an associative array
	# this for columns data type every datatype indexed by it's column name
	typeset -A datatypesArr
	# getting column informations 
	while [[ $colCounter -le $columnsNo ]]; do
		clear
		print 'Enter column '$colCounter' name and datatype seperated by a space'
		# read column name and datatype into two seprate variables
		read columnName columnDt
		# checks if the columns name like the table name 
		if [[ $columnName != $tblName ]]; then
		# checks if the datatype is int or char 
		# [[ condition ]] is not working when using -o or -a had to use test with if 
			if test "$columnDt" = 'int' -o "$columnDt" = 'char' 
		    then
		# add column name to the columns array
		# and then add it's datatype to the datatypes arrray indexed by the column name
				columnsArr[$colCounter]=$columnName
				datatypesArr[$columnName]=$columnDt
		# increament the colCounter
				((colCounter=colCounter+1))
			else
		# if invalid datatype is given 
				print 'Invalid datatype'
				print 'Avaliable Datatypes is "int" or "char" only'
			fi
		else
		# if invalid column name is given
			print 'Invalid column name'
		fi
	done
	# write the table name, number of column and user created the table to the database global .meta file
	echo $tblName':'$columnsNo':'$CURUSER >> /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'
	# creates .meta file for table metadata and .data file for the data
	touch /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'
	touch /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data'
	# write every columns and it's datatype to the table.meta file  
	for column in ${columnsArr[@]}
	do
		echo $column':'${datatypesArr[$column]}':' >> /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'
	done
	# setting a column as a primary key
	# putting true in the while condition means infinite loop 
	while true 
	do
		clear
		print 'Select a column to be the primary key ?'
		read primaryColumn
	# search if the column name given is exist
		if [[ `grep $primaryColumn /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'` ]]; then
	# replace the line mathched with the search with the new line with "primary" word added at the end
	# the regex means anyline [^] starts with given column name 
	# put [:] to limit the resutlts to only lines that the givencolumn name is representing a whole field in it 
	# [.*] and anything else after it [/] followed by the new line then [:primary] that represents a primary key column
			sed -i 's/^'$primaryColumn':.*/'$primaryColumn':'${datatypesArr[$primaryColumn]}':primary/' /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta' 	
	# to break out the loop once found the desired column
			break
		else
	# if invalid column name is provided it'll ask again 
			print 'Column dosent exist, Press anykey to try again'
			read -s -n 1
		fi
	done
	clear
	# completion message
	print 'Table "'$tblName'" Created, Press anykey to go back !'
	read -s -n 1
	clear
	# back to the database operations menu 
	dbMenu
} 
############## list database tables ################
function listTbls
{
	clear
	# get all tables in the database from database.meta file
	awk -F: '{print $1," Created by :",$3}END{print "press anykey to go back"}' /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'
	read -s -n 1
	clear
	# return to the db operations menu
	dbMenu	
}
############ list table information #############
function listTbl 
{
	clear
	print 'Please enter table name ?'
	read tblName
	# search for the given name to see if it's already exist or not
	# used [-v var="$tblName"] to import a program variable into the awk to be able to use it inside the if condition  
	if [[ `awk -F: -v var="$tblName" '{if($1==var)print $1}' /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'` ]]; then
	# if exist print all column and their datatype and primary 
		awk -F: '{print "Column-name : "$1,"	Datatybe : ",$2,"	",$3}END{print "press anykey to go back"}' /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'
	else
		print 'Table dosent exist, Press anykey to go back'
	fi
	read -s -n 1
	dbMenu
}
############ drop table ################
function dropTbl
{
	print 'Enter table name ?'
	read tblName
	# since #1 field in the database .meta file is it's tables names so i cut it and search in it for the given table name
	for tbl in `cut -f1 -d: /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'`
	do
	# if found the given table name in the data base 
		if [[ $tbl = $tblName ]];	then
	# remove table's .meta and .data files
			rm /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta' /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data'
	# remove the table info from database .meta file 
			sed -i "/^\<$tblName\>/d" /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'
			clear
			print $tblName' Successfully deleted, Press any key to go back !'
			read -s -n 1
			dbMenu
	# exit the function 
			return
		fi
	done
	print $tblName' dosent exist, Press any key to go back ! '
	read -s -n 1
	clear
	dbMenu
}
################## add column #################
function addColumn
{
	print 'Enter table name ?'
	read tblName
	# if found the given table name in the data base 
	if [[ `grep $tblName /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'` ]];	then
	# get the column name and it's data type (if already exist of invalid datatype will read from user again)	
		while true 
		do
			clear
			print 'Enter column name and datatype seperated by a space '
	# read column name and datatype
			read colName colDt
	# see if the column name is already exist 
	# used [grep -x] to match the exact name 
			if [[ `cut -f1 -d: /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta' | grep -x $colName` ]]; then
				print 'Column already exist'
				read -s -n 1
			else
	# check if user entered a valid datatype 
				if test "$colDt" = 'char' -o "$colDt" = 'int'   
				then
	# write in the table .meta file the new column description
					echo $colName':'$colDt':' >> /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'
	# since awk cant edit file in place and using direct redirection results in an empty file,
	# so i copied the content of the original file into a temp file .tmp and made awk work on it,
	# and then redirected the awk output to the original file and overwrite it then remove the tmp file
	# -PS: [-F or FS] is input field seprator awk use it when reading from the file to determine the field seperator
	# -and [OFS] is the output field seprator awk use it when printing a whole field 
	# -if not set it'll be space by default even if FS is set to something else
	# in awk begin i set [OFS=":"] to set the output field seperator to ":"  
					cp /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta' /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta.tmp'
	# increment the column number field of the given table name by 1
					awk -F: -v var="$tblName" 'BEGIN{OFS=":"}{if($1==var)$2++;print}' /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta.tmp' > /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'
					rm /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta.tmp'
					print 'All good, press anykey to exit !'
					break		
				else
	# if invalid datatype is given
					print 'Invalid datatype, Avaliable Datatypes is "int" or "char" only'
					read -s -n 1
				fi		
			fi
		done
	else
		print 'Invalid table name'
	fi
	read -s -n 1 
	alterTbl
}	
############ delete column ###################
function delCol
{
	clear
	print 'Enter table name ?'
	read tblName
	# if found the given table name in the data base 
	if [[ `grep $tblName /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'` ]];	then
		clear
		print 'Enter column name ?'
	# read column name 
		read colName
	# see if the column name is already exist 
	# used [grep -x] to match the exact name 
		if [[ `cut -f1 -d: /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta' | grep -x $colName` ]]; then
			if [[ `sed -n "/^\<$colName\>/p" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta' | cut -d: -f3` ]]; then
				print 'Srry you cant delete a primary key column :('
			else
	# get the number of the column we want to delete so that we can use it to delete it's data from the .data file
	# so i user [=] after the pattern in sed to print the matched line number 
	# [-n] to prevent the default behaviour of sed (printing) and print only if ordered to do so 
				colNum=`sed -n "/^\<$colName\>/=" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'`
	# delete the column description from the table .meta file 
				sed -i "/^\<$colName\>/d" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'
	# same as mentioned in other functions a file cant act as input and output in the same time 
	# so i made a temp copy of the table .data file 
				cp /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data' /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data.tmp'
	# used [ --complement ] with cut to select all column except those provided (reverse the cut command behaviour)
	# cut command now read from the .tmp file and redirection is in the original file  
				cut -d: -f"$colNum" --complement /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data.tmp' > /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data'
	# remove the temp file
				rm /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data.tmp'
	# we deleted a column so we decrement the column number field of the given table name in the database .meta file
				cp /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta' /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta.tmp'
				awk -F: -v var="$tblName" 'BEGIN{OFS=":"}{if($1==var)$2--;print}' /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta.tmp' > /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'
				rm /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta.tmp'
				print 'All good, press any key to go back'
			fi
	
		else
			print 'Column not exist'
		fi
	else
		print 'Table not exist'
	fi
	read -s -n 1
	alterTbl
}
#################### insert #########################
function insert 
{
	clear
	print 'Enter table name ?'
	read tblName
	# if found the given table name in the data base 
	if [[ `grep $tblName /home/$LOGNAME/ShellProject/$CURDB/$CURDB'.meta'` ]];	then
	# loop over all columns names in the given table 
		for column in `cut -d: -f1 /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'`
		do
	# infinite loop over the proccess of inserting values to ensure the user write the right value with the right datatype
			while true 
			do
	# this is a flag for the check on uniqueness of primary key values if the given value is not unique it'll be true 
				found='false'
	# get the datatype of current column for further checks
				colDt=`sed -n "/^\<$column\>/p" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta' | cut -d: -f2`
				clear
	# [-n] prevents echo to draw new line after printing so that it'll be like a prompt 
	# it'll print the current column name to insert into and it's datatype
				echo -n "$column [$colDt] = "
				read value
	# if the the value given matched the datatype of the column
	# i found a soulution to use multiple conditions without having to use [test]
	# now i can surrond every condition with [[ condition ]] and add any operator then other condition [[ condition ]]
				if [[ "$value" == +([0-9]) ]] && [[ "$colDt" == 'int' ]]; then
	# checks if the current column is the primary key columns for further operations
					if [[ `sed -n "/^\<$column\>/p" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta' | cut -d: -f3` ]]; then
	# get the primary key column number in the table (i'll use that to be able check it's values later) 
						pColNum=`sed -n "/^\<$column\>/=" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'`
	# loop over the existing values of the primary key column in the table
						for pVal in `cut -d: -f"$pColNum" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data'`
						do
	# checks if the value given is already exist in the primary key column
							if [[ $value = $pVal ]]; then
	# set [found] to true if the value already exist
								found='true'
	# break the inner for loop 
								break
							fi
						done
					fi
	# if value exists
					if [[ $found = 'true' ]]; then
						print 'You must enter unique value in primary key column'
						read -s -n 1
	# ask again for a value
						continue
					else
	# if all good append the value to the values array and break out the while loop
						values+=("$value")
						break
					fi
	# same as above block of code but with [char] datatype
				elif [[ "$value" == +([0-9|a-z|A-Z|@|-|_|.]) ]] && [[ "$colDt" == 'char' ]]; then
					if [[ `sed -n "/^\<$column\>/p" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta' | cut -d: -f3` ]]; then
						pColNum=`sed -n "/^\<$column\>/=" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.meta'`
						for pVal in `cut -d: -f"$pColNum" /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data'`
						do
							if [[ $value = $pVal ]]; then
								found='true'
								break
							fi
						done
					fi
					if [[ $found = 'true' ]]; then
						print 'You must enter unique value in primary key column'
						read -s -n 1
						continue
					else
						values+=("$value")
						break	
					fi
				else
					print 'Invalid datatype'
					read -s -n 1
					continue
				fi
			done
		done	
	# write the new added row in the table .data file 
	# first echo will echo the whole array in one line with space seperator between each element
	# [tr ' ' ':'] will remove every space in the line and add [:] as a delimiter 
	# then append the result in the table .data file as a new record 
		echo ${values[@]} | tr ' ' ':' >> /home/$LOGNAME/ShellProject/$CURDB/$tblName'.data'
		print 'All good, press any key to go back'
		read -s -n 1
	else
		print 'Invalid table name !!'	
	fi	
	tblQuery
}
############## database specific operations menus ################
############ alter table menu ##############
function alterTbl
{
	clear
	# change the prompt 
	PS3='Please enter your choice : '
	# menu options 
	options=("Add Column" "Delete Column" "Exit")
	# drawing the menu
	select option in "${options[@]}"
	do
		case $option in 
			"Add Column" )
				addColumn				
				break
			;;
			"Delete Column" )
				delCol
				break
			;;
			"Exit" )
				clear
				dbMenu
				break
			;;
			* ) 
				echo 'not a valid option'
			;;
		esac
	done	
}
############ table Queries menu ################
function tblQuery
{
	clear
	# change the prompt 
	PS3='Please enter your choice : '
	# menu options 
	options=("Insert" "Update" "Delete" "Select" "Exit")
	# drawing the menu
	select option in "${options[@]}"
	do
		case $option in 
			"Insert" )
				insert						
				break
			;;
			"Update" )
				
				break
			;;
			"Delete" )
				
				break
			;;
			"Select" )
				
				break
			;;
			"Exit" )
				clear
				dbMenu
				break
			;;
			* ) 
				echo 'not a valid option'
			;;
		esac
	done	
}
############ db specific main menu ##################
function dbMenu
{
	clear
	# change the prompt 
	PS3='Please enter your choice : '
	# menu options 
	options=("Create table" "List tables" "List table" "Alter table" "Drop table" "Query Table" "Exit")
	# drawing the menu
	select option in "${options[@]}"
	do
		case $option in 
			"Create table" )
				createTbl
				break
			;;
			"List tables" )
				listTbls
				break
			;;
			"List table" )
				listTbl
				break
			;;
			"Alter table" )
				alterTbl
				break
			;;
			"Drop table" )
				dropTbl
				break
			;;
			"Query Table" )
				tblQuery
				break
			;;
			"Exit" )
				clear
				mainMenu
				break
			;;
			* ) 
				echo 'not a valid option'
			;;
		esac
	done
}
############# menu display function ############
function mainMenu
{
	# change the prompt 
	PS3='Please enter your choice : '
	# menu options 
	options=("Create Database" "List Databases" "Select Database" "Delete Database" "Add&Remove Users" "Exit")
	# drawing the menu
	select option in "${options[@]}"
	do
		case $option in 
			"Create Database" )
				createDb
				break
			;;
			"List Databases" )
				listDbs
				break
			;;
			"Select Database" )
				selectDb
				break
			;;
			"Delete Database" )
				deleteDb
				break
			;;
			"Add&Remove Users" )
				userTransactions
				break
			;;
			"Exit" )
				echo "Bye!"
				break
			;;
			* ) 
				echo 'not a valid option'
			;;
		esac
	done
}
