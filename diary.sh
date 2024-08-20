#!/bin/bash
#####################################
# CONFIGURATION AND GLOBAL VARIABLES:
#####################################
name=$(whoami)
date="$(date +"%d/%m/%y")"
time="$(date +"%H:%M %p")"
path="${HOME}/cli-diary/" 
db_path="${HOME}/cli-diary/db/"
prompt=$(printf "\n[>] ")
id="md-$file_name-$entry_date"
list_all_files=$(ls -l "$path"* | awk '/-r/ {print $NF}')
#####################################
# INITIALIZATION AND SETUP:
#####################################
# Greeting:
function greeting {
  if [ $(date +"%p") = "AM" ]; then
    greeting="Good Morning"
  elif [ $(date +"%p") = "PM" ] && [ $(date +"%H") -le 16 ]; then
    greeting="Good Afternoon"
  elif [ $(date +"%p") = "PM" ] && [ $(date +"%H") -ge 17 ]; then
    greeting="Good Evening"
  fi
  clear
  printf "$greeting, $name!\n"
  sleep .5
}
# Check if cli-diary dir exists:
function check_path {
  if [ ! -d $path ]; then
    $(mkdir $path)
    echo "...creating the diary's directory in '~'"
    press_enter
  fi
}
# Check database directory exists:
function db_path_check {
  if [ ! -e $db_path ]; then
    $(mkdir -p $db_path)
    db_path_e="then"
  else
    db_path_e="else"
  fi
}
#####################################
# NAVIGATION AND MENUS:
#####################################
# The main menu:
function main {
  clear
  while true; do
    clear
    printf "What would you like to do ?"
    echo ""
    printf " 1. Create a new record\n 2. Retrieve a record\n 3. Edit a record\n 4. Exit diary$prompt"
    read menu_choice 
    case $menu_choice in
      1 )
        new_record
        ;; 2 )
        get_record
        ;;
      3 )
        edit_record
        ;;
      4 ) exit 
        ;;
      * ) echo "invalid option please select between 1-4"
        sleep 1
        clear
        ;;
    esac
  done
  menu_name="main"
}
# DB menu:
function db_menu {
  clear
  echo "1) Search for a different database."
  echo "2) Show available database's."
  echo "3) Create a new database."
  echo "4) Go back to the previous menu."
  read -p "What would you like to do ? $prompt" opt
  case $opt in
    1) db_search
      ;;
    2) db_show
      ;;
    3) db_create
      ;;
    4) back_to-retrieve
      ;;
  esac
  menu_name="db_menu"
}
# Select edit action
function edit_action {
  printf "1) Read "$file".\n2) Open "$file" in VIM.\n3) Go back to main menu.\n"
  read -p "What would you like to do ? $prompt" opt
  case $opt in
    1) clear
      echo $(cat $file)
      press_enter
      ;;
    2) vim $file
      ;;
    3) main
      ;;
  esac
  menu_name="edit_action"
}
# Retrieve records:
function get_record {
  clear
  echo "1) Search by word in a file."
  echo "2) Search by date."
  echo "3) Search by name."
  echo "4) Search by database"
  echo "5) Back to main-menu"
  printf "How would you like to search ?\n(type in the number [1-5] and press ENTER)"
  read -p "$prompt" opt
  case $opt in
    1 ) search_word
      ;;
    2 ) search_date
      ;;
    3 ) search_name
      ;;
    4 ) get_db
      ;;
    5 ) main 
  esac
}
# Back to main menu:
function back_to_main {
  read -p "Press [Enter] to return to the main menu:$prompt" opt
  main
}
# Back to Retrieve records:
function back_to_retrieve {
  read -p "Press [Enter] to return to the previous menu:$prompt" opt
  get_record
}
# Back to db_menu
function back_to_db_menu {
  read -p "Press [Enter] to return to the previous menu:$prompt" opt
  db_menu
}
#####################################
# DATABASE OPERATIONS:
#####################################

function db_check {
  db_empty_dir=$(ls -A $db_path | wc -w )
  $db_empty_dir
  if [ $db_empty_dir = "0" ]; then 
    clear
    echo "The db directory is empty!"
    sleep 1
    clear
    echo "Would you like to create a new database?"
    yn
    if [ $choice = "y" ]; then 
      db_create
    elif [ $choice = "n" ]; then 
      back_to_retrieve
    fi
  elif [ $db_empty_dir != "0" ]; then
    db_search
  fi
}

# Get table data
function dbdata {
  clear
   # If the database is empty:
  if [ $(sqlite3 "$db_path$db".db ".tables" | wc -w ) = "0" ]; then 
    dbdata_e="empty"
    echo "This database is empty, would you like me to create the required entries ? "
    yn
    if [ $choice  = "y" ]; then 
      create_new_table
    elif [ $choice = "n" ]; then
      back_to_retrieve 
    fi
  elif [ $(sqlite3 "$db_path$db".db ".tables" | wc -w ) != "1" ]; then 
    # get the tables in db
    tables=$(sqlite3 "$db_path$db".db ".tables" | tr " " "\n" | awk 'NF')
    # provide a select option to choose a table to procceed with
    select_table
    # get the schema of the table
    table_data=$(sqlite3 "$db_path$db".db ".schema $selection")
    # get the contents of the table
    table_rows=$(echo $table_data | awk -F "[()]" '{print $2}' | awk -F "," '{print $1; print $2; print $3}' | awk '{print "> "$1}')
    dbdata_e="multiple"
  elif [ $(sqlite3 "$db_path$db".db ".tables" | wc -w ) = "1" ]; then 
    # get the table in the db
    tables=$(sqlite3 "$db_path$db".db ".tables")
    # get the schema of the table
    table_data=$(sqlite3 "$db_path$db".db ".schema")
    # get the names of the rows and what they are
    table_rows=$(echo $table_data | awk -F "[()]" '{print $2}' | awk -F "," '{print $1; print $2; print $3}' | awk '{print "> "$1}')
    dbdata_e="one"
   fi
}
# Show available db's:
function db_show {
  clear
  echo "Database/s found: "
  database=$(find $db_path -name *.db | awk -F "/" '{print $NF}' | awk -F"." '{print "> ["$1"]"}')
  echo "$database"
}
# Create a new db:
function db_create {
  clear
  read -p "Name the database:$prompt" db
  create_db=$(touch "$db_path$db".db )
  $create_db
  echo "Created '"$db".db', in "$db_path""; 
  press_enter
}
# Search for & display a db:
function db_search {
  busqueda=$(find $db_path -name "$db".db | wc -w)
  db_show
    read -p "Enter the name of the database you want to search in:$prompt" db
    if [ $(find "$db_path$db".db >> /dev/null; echo $? ) = '0' ]; then
      echo "Loading "$db" data..."; 
      sleep .5
      clear
      dbdata
      if [ $dbdata_e = "multiple" ]; then 
        echo "$selection contains: "
        echo "$table_rows"
        back_to_retrieve
      elif [ $dbdata_e = "one" ]; then
        echo "$db contains:" 
        echo "Table/s: $tables"
        echo ""
        echo "$tables contains:" 
        echo "$table_rows"
        back_to_retrieve
      elif [ $dbdata_e = "empty" ]; then 
        create_new_table
      fi
    elif [ $busqueda = "0" ]; then
      echo "'$db' does not exist, please choose a db from the list above"
      press_enter
    fi
  }
  # Retrieve database:
  function get_db {
    db_path_check
    db_check
    db_search
  }
  # TABLE RELATED:
  #---------------
  # Select Table in a DB:
  function select_table {
    PS3="Select a Table to view: "
    select table in $tables 
    do
      if [ -n "$table" ]; then 
        clear
        echo "You selected: [$table]"
        break
      else 
        echo "Invalid selection. Please try again."
        sleep .5
      fi
    done
    selection="$table"
  }
  # Create a new table in db:
  function create_new_table {
    entries=$(sqlite3 $db_path$db.db "CREATE TABLE entries ( id INTEGER PRIMARY KEY, title TEXT NOT NULL, content TEXT NOT NULL, created DATETIME DEFAULT CURRENT_TIMESTAMP );")
    $entries
    echo "Default table 'entries' successfully created!"
    sleep .8
    dbdata
  }
  #####################################
  # FILE OPERATIONS:
  #####################################
  # Create a new record:
  function new_record { 
    clear
    read -p "Enter a title: $prompt" title
    read -p "Enter the content: $prompt" content
    clear
    preview
    printf "Use today's date ?"  
    yn 
    if [ $choice = 'y' ]; then
      entry_date=$date
      entry_time=$time
      clear
      printf "Date added sucessfully!\n"
      clear
      preview
    elif [ $choice = 'n' ]; then
      clear
      printf "Please enter a date [DD/MM/YY]:$prompt"
      read entry_date
      entry_time=$time
      clear
      preview
    fi
    # Name the file
    echo -n "Please name your file:$prompt" 
    read file_name
    # Set the id:
    id="md-$file_name-$entry_date" # Save file:
    save_file
  }
  # Save file:
  function save_file {
    if [ -d $path ]; then
      printf "**ID**: $id\n**Added on**: $entry_date at $entry_time\n**Title**: # $title\n**Content**: $content\n" >> $path$file_name.md
      echo "Saved as $file_name.md on $date at $time, in $path"
      echo ""
      back_to_main
    else 
      check_path
      save_file
    fi
  }
  # Search by name 
  function search_name { 
    clear
    echo "Do you know the name of the file you're looking for?"
    yn
    if [ $choice = "y" ]; then 
      clear
      read -p "What's the name of the file you're searching for?$prompt" sq_name
      file_name=$(printf "$sq_name.md")
      file="$path$file_name"
      if [ -f $file ]; then
        clear
        edit_action
      elif [ ! -d $file ]; then
        clear
        printf "Sorry, we couldn't find the document '$sq_name'.\nHere's a list of the available docs:\n"
        show_docs=$(ls -A "$path"| awk '/\.md/ {print}' | awk -F"\n" '{print "> "$0}')
        printf "$show_docs\n"
        press_enter
        clear
        echo "Would you like to search for another file by name?"
        yn
        if [ $choice = "y" ]; then 
          search_name
        elif [ $choice = "n" ]; then
          back_to_retrieve
        fi
      fi
    else 
      clear
      echo "Here's a list of all the available files:"
      select_file
      edit_action
    fi
  }
  function select_file {
    PS3="Select a file to proceed:$prompt"
    select file in $list_all_files; 
    do
      if [ -n "$file" ]; then 
        clear
        echo "You selected: "$(echo "$file" | awk -F "/" '{print $NF}')""
        break
      else
        clear
        echo "Invalid selection, please select a valid file..."
      fi
    done
  }
  # Search by word 
  function search_word {
    clear
    read -p "What's the word you want to search for ?$prompt" word
    clear
    result=$(grep -i -r -n $word $path | awk -F ":" '{print "Location: " $1; print "Line Number: " $2; print "Result: " $3, $4; print "\\n"}')
    check=$(grep -i -r -n $word $path >> /dev/null; echo $?)
    if [ $check = '0' ]; then
      printf "$result"
      press_enter
      clear
      echo "Would you like to search for another word?" 
      yn
      if [ $choice = 'y' ]; then
        search_word
      elif [ $choice = 'n' ]; then
        get_record 
      fi
    else
      echo "'"$word"' does not exist."
      echo ""
      echo  "Would you like to search again?" 
      yn
      if [ $choice = 'y' ]; then
        search_word
      elif [ $choice = 'n' ]; then
        echo "Returning to the main menu..."
        sleep 0.5
        main
      fi
    fi
  }
  # Search by date:
  function search_date {
    clear
    read -p "Enter a date in the 'dd/mm/yy': $prompt" date
    #check_format
    check=$(grep -i -r -n "$date" $path >> /dev/null; echo $?)
    result=$(grep -i -r -n "$date" $path | awk '/ID/' | awk -F ":" '{print $1}' | awk -F "/" '{print "> "$NF}')
    if [ $check = "0" ]; then 
      clear
      echo "These are the documents that were written on $date:"
      echo "$result"
      #TODO: Code a selection menu. So we can add options of what to do with those documents. 
      press_enter
      clear
      echo "Would you like to try another date?"
      yn
      if [ $choice = "y" ]; then 
        search_date
      elif [ $choice = "n" ]; then
        back_to_main
      fi
    else
      echo "No results for '$date'."
      echo "Would you like to try another date?"
      yn
      if [ $choice = "y" ]; then 
        search_date
      elif [ $choice = "n" ]; then
        back_to_main
      fi
    fi
  }
  # Edit record:
  function edit_record {
    clear
    search_name
  }
  # Search gor a record:
  function search_record {
    # search for $record
    echo ""
  }
  # Select record:
  function select_record {
    echo "selecting record under construction."
  }
  #####################################
  # UTILITY FUNCTIONS:
  #####################################
  # Preview of what a file looks like:
  function preview { 
    clear
    echo "Added on:   [ $entry_date ]"
    echo "Title:      [ $title ]"
    echo "Content:    [ $content ]"
    echo "Save as:    [ $file_name.md ]"
    echo ""
  }
  # [y/n] options:
  function yn {
    printf "Type [y] for [YES] | [n] for [NO]$prompt"
    read choice
    if [ $choice != 'y' -a $choice != 'n' ]; then 
      while [ $choice != 'y' -a $choice != 'n' ]; do  
        printf "\nInvalid choice!\n \nType a lowercase [y]/[n] for [YES]/[NO] and then press [ENTER]$prompt"
        read choice
      done
    fi
  }
  # Press Enter to continue:
  function press_enter {
    read -p "Press [ENTER] to continue $prompt" keypress
  }
  #####################################
  # SCRIPT ENTRY POINT:
  #####################################
  greeting
  main
