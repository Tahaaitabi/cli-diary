#!/bin/bash
# GLOBAL VARIABLES:
name=$(whoami)
date="$(date +"%d/%m/%y")"
time="$(date +"%H:%M %p")"
path=~/cli-diary  
prompt=$'\n> '


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
    printf "**ID:** $id\n**Added on:** $entry_date at $entry_time\n**Title:** # $title\n**Content:** $content\n" >> $path/$file_name.md
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
  read -p "Enter a title:$prompt" title
  read -p "Enter the content:$prompt" content
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
  id="md-$file_name-$entry_date"

  # Save file:
  save_file
}

# Fetch record:
function get_record {
  clear
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
