COURT CALENDAR SCANNER 
===

- This Ruby script scans the "Court Calendar.csv" file we get from Kathy Burstein. 

HOW IT WORKS
===
1) The script goes through the file's rows...
2) Finds the defendant's first and last names within a row...
3) Searches the name (e.g. "JOE SMITH") in the Palm Beach Post's text archives, which ranges from 1989 to present and includes only print stories...
4) Counts how many stories in the archives have the defendant's name...
5) Gets the URL for the search results of the defendant's name...
6) Adds to a SQLite database the defendant's first and last name, number of archived print stories with the defendant's first and last name, and the URL to those search results


TO DO
===
- Make defendant names unique


SUGGESTIONS
===
- Add defense attorney info
- Add judge info
- Add charge info