#####################################
# CONFIGURATION AND GLOBAL VARIABLES:
#####################################
name=$(whoami)
date="$(date +"%d/%m/%y")"
time="$(date +"%H:%M %p")"
path=~/cli-diary/  
db_path=~/cli-diary/db/
prompt=$(printf "\n[>] ")
id="md-$file_name-$entry_date"
db_name="$db.db"
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
    echo "...creating the diary's directory in '~'"
    $(mkdir $path)
    sleep 1
  fi
}
# Check database directory exists:
function db_path_check {
  if [ ! -d $db_path ]; then
    $(mkdir $db_path)
    e="then"
  else
    e="else"
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
        ;; 
      2 )
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
# Check the path of the db:
function db_check {
  db_path_check
  empty_dir=$(ls -A $db_path | wc -w )
  search_db=$(find $db_path -name "*.db" | wc -w )
  create_db=$(cd $db_path && touch diary.db )
  if [ $empty_dir != '0' ]; then 
    if [ $search_db = '0' ]; then
      echo "No databases found!"
      sleep .5
      clear
      echo "Creating 'diary.db'..."
      $create_db
      sleep .3
      echo "Done!"
    else
      sleep .3
      clear
    fi
  else 
    echo "This is an empty directory!"
    sleep .5 
    echo "Creating 'diary.db'..."
    $create_db
    sleep .3
    echo "Done!"
  fi
}

# Get table data
function dbdata {
  if [ $(sqlite3 $db_path$db_name ".tables" | wc -w ) -ne  "1" ]; then 
    # get the tables in db
    tables=$(sqlite3 $db_path$db_name ".tables" | tr " " "\n" | awk 'NF')
    # provide a select option to choose a table to procceed with
    select_table
    # get the schema of the table
    table_data=$(sqlite3 $db_path$db_name ".schema $selection")
    # get the contents of the table
    table_rows=$(echo $table_data | awk -F "[()]" '{print $2}' | awk -F "," '{print $1; print $2; print $3}' | awk '{print "> "$1}')
    dbdata_e="then"
  else
    # get the table in the db
    tables=$(sqlite3 $db_path$db_name ".tables")
    # get the schema of the table
    table_data=$(sqlite3 $db_path$db_name ".schema")
    # get the names of the rows and what they are
    table_rows=$(echo $table_data | awk -F "[()]" '{print $2}' | awk -F "," '{print $1; print $2; print $3}' | awk '{print "> "$1}')
    dbdata_e="else"
  fi
  # If the database is empty:
  if [ $(sqlite3 $db_path$db_name ".tables" | wc -w ) =  "0" ]; then 
    echo "This database is empty, would you like me to create the required entries ? "
    yn
    if [ $choice  = "y" ]; then 
      create_new_table
      sleep .5
      clear
      dbdata
      if [ $dbdata_e = "then" ]; then 
        echo "$selection contains: "
        echo "$table_rows"
        back_to_retrieve
      else
        echo "$db contains:" 
        echo "Table/s: $tables"
        echo ""
        echo "$tables contains:" 
        echo "$table_rows"
        back_to_retrieve
      fi
    else
      back_to_retrieve 
    fi
  fi
}
# Show available db's:
function db_show {
  echo "Database/s found: "
  echo "$(find $db_path -name "*.db" | awk -F "/" '{print "[" $NF "]"}')"
  sleep .3

}
# Create a new db:
function db_create {
  read -p "Enter a db name: " db
  create_db=$(cd "$db_path" && touch "$db".db )
  echo "Created '"$db".db', in "$db_path" "; 
  sleep .8
}
# Search for a db:
function db_search {
  read -p "Enter a db name: " db
  if [ $(find "$db_path$db".db >> /dev/null; echo $? ) = '0' ]; then
    echo "Loading "$db" data..."; 
    sleep .5
    clear
    dbdata
    if [ $dbdata_e = "then" ]; then 
      echo "$selection contains: "
      echo "$table_rows"
      back_to_retrieve
    else
      echo "$db contains:" 
      echo "Table/s: $tables"
      echo ""
      echo "$tables contains:" 
      echo "$table_rows"
      back_to_retrieve
    fi
  else
    echo "$db does not exist!";
    sleep 1
    db_menu
  fi
}
# Retrieve database:
function get_db {
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
      sleep 1
    fi
  done
  selection="$table"
}

function create_new_table {
  entries=$(sqlite3 $db_path$db.db "CREATE TABLE entries ( id INTEGER PRIMARY KEY, title TEXT NOT NULL, content TEXT NOT NULL, created DATETIME DEFAULT CURRENT_TIMESTAMP );")
  $entries
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
  # Save the value of the name in "sq_name"
  read -p "What's the name of the file you're searching for $prompt? " sq_name
  # Make the pattern the name of the string that we searched for plus the markdown filetype.
  # Good, this now prints the nameOfTheFile.md
  file_name=$(printf "$sq_name.md")
  # Location of the file. 
  file=~/cli-diary/
  # Check if the file exists. GOOOD!!!
  if [ -f $file$file_name ]; then
    clear
    printf "\n1) Read the file.\n2) Open in VIM.\n3) Go back to main menu"
    read -p "What would you like to do ? $prompt" opt
    case $opt in
      1) echo "Reading to be inplemented via some method which allows me to read from the screen with the ability to scroll..."
        ;;
      2) echo "Opening in vim soon come!..."
        ;;
      3) main
        ;;
    esac

  elif [ ! -d $file ]; then
    printf "\nSorry, we couldn't find the document '$file' you were looking for!\n Did you spell it correctly ?"
    search_name
  fi
}
# Search by word 
function search_word {
  clear
  # 1.Capture the word we want to search for in the $word variable.
  read -p "What's the word you want to search for ? $prompt" word
  echo ""
  # 2. Search in the path directory for the $word in the $path.
  result=$(grep -i -r -n $word $path | awk -F ":" '{print "Location: " $1; print "Line Number: " $2; print "Result: " $3, $4; print "\\n"}')
  # Check if the search was successfull or not
  check=$(grep -i -r -n $word $path >> /dev/null; echo $?)
  if [ $check = '0' ]; then
    printf "$result"
    echo  "Would you like to search for another term ?" 
  else
    echo "The word you're looking for does not exist."
    echo ""
    echo  "Would you like to search for another term ?" 
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
# Retrieve records:
function get_record {
  clear
  echo "1) Search by word in a file."
  echo "2) Search by date."
  echo "3) Search by name."
  echo "4) Search by database"
  echo "5) Back to main-menu"
  read -p "How would you like to search ? (type in the number [1-5] and press ENTER) $prompt" opt
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
# Edit record:
function edit_record {
  printf "\n FUNCTION IN PROGRESS OF CREATION..."
  sleep 1
  clear
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
  printf "\nType [y] for [YES] | [n] for [NO]$prompt"
  read choice
  if [ $choice != 'y' -a $choice != 'n' ]; then 
    while [ $choice != 'y' -a $choice != 'n' ]; do  
      printf "\nInvalid choice!\n \nType a lowercase [y]/[n] for [YES]/[NO] and then press [ENTER]$prompt"
      read choice
    done
  fi
}
#####################################
# SCRIPT ENTRY POINT:
#####################################
greeting
main
