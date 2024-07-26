#!/bin/bash
# GLOBAL VARIABLES:
name=$(whoami)
date="$(date +"%d/%m/%y")"
time="$(date +"%H:%M %p")"

#Greeting:
function greeting {
  if [ $(date +"%p") = "AM" ]; then
    greeting="Good Morning"
  elif [ $(date +"%p") = "PM" ] && [ $(date +"%H") -ge 5 ]; then
    greeting="Good Afternoon"
  elif [ $(date +"%p") = "PM" ] && [ $(date +"%H") -le 5 ]; then
    greeting="Good Evening"
  fi
  clear
  printf "$greeting, $name!\n"
  sleep 1
}

# [y/n]:
function yn_choice {
  printf "\nType [y] for [YES] | [n] for [NO] "
  read choice
  if [ $choice != 'y' -a $choice != 'n' ]; then 
    while [ $choice != 'y' -a $choice != 'n' ]; do  
      printf "\nInvalid choice!\n \nType a lowercase [y]/[n] for [YES]/[NO] and then press [ENTER] "
      read choice
    done
  fi
}

# Preview entry data:
function preview { 
  clear
  echo "**PREVIEW**:"
  echo ""
  echo "Added on:   [ $entry_date ]"
  echo "Title:      [ $title ]"
  echo "Content:    [ $content ]"
  echo ""
}

# Back to main menu:
function back_to_main {
  echo "Press [Enter] to return to the main menu: "  
  read 
  main
}

# Create new record:
function new_record { 
  clear
  read -p "Enter a title: " title
  read -p "Enter the content: " content
  clear
  #printf "[Preview]:\n \n[Title]: $title\n[Content]: $content"
  preview
  printf "Use today's date ?\n"  
  yn_choice
  if [ $choice = 'y' ]; then
    entry_date=$date
    clear
    printf "Date added sucessfully!\n"
    #printf "[Preview]:\n \n[Title]: $title\n[Content]: $content\n[Added on]: $entry_date\n"
    clear
    preview
    back_to_main
  elif [ $choice = 'n' ]; then
    clear
    printf "Please enter a date [DD/MM/YY]: "
    read entry_date
    #printf "\n[Preview]:\n \n[Title]: $title\n[Content]: $content\n[Added on]: $entry_date\n"
    clear
    preview
    back_to_main
  fi
  # create a folder in the home directory and save file
}


function get_record {
  clear
}

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
    printf " 1. Create a new record\n 2. Retrieve a record\n 3. Edit a record\n 4. Exit diary\n"
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
