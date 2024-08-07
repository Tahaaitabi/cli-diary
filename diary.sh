# TODO: 
# 1. search_by word -> ability to search for a word inside of a document. Need to be able to first read the contents of a document and then use a a mix of grep and awk in order to then search for the word in the document. 
######################
# 2. search_by_date -> Read through the file ID's and then ascertain the date and match it to then only show the files that match the same date.
# I need to also create a new preview function that allows for just the title and then the first sentence of the document(need this in regex too).
####################
# 3. search_by_name -> match the input string to the name of the document [ done ].

# GLOBAL VARIABLES:
name=$(whoami)
date="$(date +"%d/%m/%y")"
time="$(date +"%H:%M %p")"
path=~/cli-diary  
prompt=$(printf "\n[>] ")
id="md-$file_name-$entry_date"

#Greeting:
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
  sleep 1
}

# [y/n]:
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

# Path checker;
function check_path {
  if [ ! -d $path ]; then
    echo "...creating the diary's directory in '~'"
    $(mkdir $path)
    sleep 1
  fi
}

# Save file:
function save_file {
  if [ -d $path ]; then
    printf "**ID**: $id\n**Added on**: $entry_date at $entry_time\n**Title**: # $title\n**Content**: $content\n" >> $path/$file_name.md
    echo "Saved as $file_name.md on $date at $time, in $path"
    echo ""
    back_to_main
  else 
    check_path
    save_file
  fi
}

# Preview entry data:
function preview { 
  clear
  echo "Added on:   [ $entry_date ]"
  echo "Title:      [ $title ]"
  echo "Content:    [ $content ]"
  echo "Save as:    [ $file_name.md ]"
  echo ""
}

# Back to main menu:
function back_to_main {
  read -p "Press [Enter] to return to the main menu:$prompt"
  main
}

# Create new record:
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
      3) main_menu
        ;;
    esac

  elif [ ! -d $file ]; then
    printf "\nSorry, we couldn't find the document '$file' you were looking for!\n Did you spell it correctly ?"
    search_name
  fi
}

function search_word {
  clear
  # 1.Capture the word we want to search for in the $word variable.
  read -p "What's the word you want to search for ? $prompt" word
  # 2. Search in the path directory for the $word in the $path.
  result=$(grep -i -r -n $word $path | awk -F ":" '{print "Location: " $1; print "Line Numeber: " $2; print "Result: " $3, $4; print "\n"}')
  printf "$result"
  echo ""
  echo  "Would you like to search for another term ?" 
  echo ""
  yn
  if [ $choice = 'y' ]; then
    search_word
  elif [ $choice = 'n' ]; then
    echo "Returning to the main menu..."
    sleep 1
    main
  fi
  }
  function get_record {
    clear
    echo "1) Search by word in a file."
    echo "2) Search by date."
    echo "3) Search by name."
    echo ""
    read -p "How would you like to search ? (type in the number [1-4] and press ENTER) $prompt" opt
    case $opt in
      1 ) search_word
        ;;
      2 ) search_date
        ;;
      3 ) search_name
        ;;
    esac
  }

# Edit entry
function edit_record {
  printf "\nEditing records..."
  sleep 1
  clear
}

# Function for the main menu:
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


greeting
main
