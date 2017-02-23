#Release Change Log

Current latest release is version 0.7

----
0.7 - Created Set-ACMod function, this updates existing mod.txt files.  New-ACmod function only creates mod.txt files if they dont already exist.  Created helper functions for repeated tasks.  Added some error handling around reading the existing mod.txt files.

0.6.1 - bug fix #17

0.6 - Added 1 hour limit to checking Race Department website, shows local mod.txt informaiton if last checked date is less than 1 hour from the current date.  New param -override_check_limit to override this 1 hour limit.

0.5.1 - Added $export_path variable, this is used when exporting the file to csv.  Can be set by user at a global level.

0.5 - New Params for better usability of the script, error handling on mod.txt file being invalid.  Output default to grid window, this looks better.  Option to export to csv via param.

0.4 - Created New-ACMod function, this creates mod.txt folder in specified directory

0.3 - Moved script into a function called Get-ACMod, created initial parameters

0.2 - Script scrapes RD URL for Version and Last Updated date, scraped data added to table output

0.1 - Initial Script Creation - Looks for mod.txt file in specified folder and shows output in a table

