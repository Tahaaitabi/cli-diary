# Diary script for the cli written in Bash
---
## Concept:
---
The script should be able to do the following:

1. Greet the user and show a menu:
    - a. `greeting()` -> [done]
    - b. `main()` -> Function with a case with 4 options; create, retireve, edit and exit. -> [done]
    
---
2. Create a new record -> `new_record()`
The function should create the following variables:
    - a. `$title` [done]
    - b. `$content` [done]
    - c. `$date` [done]
    - d. `$time` [done]
    - e. `$id` [done]
    - f. `check_path()` -> Check if a directory called "cli-diary"  exists in the home directory and if not create it. [done]
---
3. Retrieve a record -> `get_record()` [**in-progress**]
This function should be able to search the file in which the entries are saved, and fetch a list of entry titles, date, time and the first 2 lines of the entry.
    - a. `$title`
    - b. `$preview`
    - c. `$id`
    - d. `$date` 
    - e. `$time`
    - f. Code to read from the database.[todo]
---
4. Edit a record -> `edit_record()`
This function should be able to edit an entry as well as create some variables to save the history of the changes made to an entry, a sort of mini git inspired system to keep track of the history.

>Note: You're more than welcome to fork this and create your  own version of it if you want. If you have any advice and pointers on what I could do to make it better please get in touch!
