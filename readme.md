# Diary program for the cli written in Bash

The program should be executed by running "diary" in the cli.
Make sure to add an alias for it in the bashrc.

### Program concept:
---
The program should be able to:
---

1. Welcome screen -> `welcome()`
    - a. `greeting()` -> [done]
    - b. `main()` -> Function with a case with 4 options; create, retireve, edit and exit. -> [done]
    
---
2. Create a new record -> `new_record()`
The function should create the following variables:
    - a. `$title` [done]
    - b. `$content` [done]
    - c. `$date` [done]
    - d. `$time` 
    - e. `$id`
    - f. `double_check()` -> Check that there isn't a duplicate record with the same id or title with the same date. If there is, then return an error message and instructions for a valid entry.
---
3. Retrieve a record -> `get_record()`
This function should be able to search the file in which the entries are saved, and fetch a list of entry titles, date, time and the first 2 lines of the entry.
    - a. `$title`
    - b. `$preview`
    - c. `$id`
    - d. `$date` 
    - e. `$time`
    - f. Code to read from the database.[todo]
---
4. Edit a record -> `edit_record()`
