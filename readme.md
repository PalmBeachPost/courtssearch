# Court Docket-Archive Search
Everyday Palm Beach County Courts sends a daily docket that has all the scheduled court activity for the next day.

This script gets an email after it's been forwarded it to a Gmail account. It fetches the current day's email and downloads the court's CSV file. That CSV file is parsed into a database. Another program checks the docket against the Palm Beach Post's archives and generates another CSV. Another program checks that CSV and parses it into an HTML email highlighting cases of interest.

The master script is DailyRunner.ps1. But debug.bat can also be used to call DailyRunner and generate a log.

This started off as a mix of Powershell and Ruby. To get away from a dependency on Outlook, it's now a weird marriage of Powershell, Ruby, Python and an optional batch file.

## Dependencies
Lots. This is built with Python 2.7, a version of Powershell that's at least greather than 2.0 and Ruby 1.93. It's also set up to talk to a MySQL database.

Python basics: pip install email

Ruby basics: gem install nokogiri sequel sqlite3 mysql mysql2 --no-ri --no-rdoc
Also, you need to a bridge for MySQL, available here:
http://dev.mysql.com/get/Downloads/Connector-C/mysql-connector-c-noinstall-6.0.2-win32.zip/from/pick
Then you put lib\libmysql.dll in your Ruby\bin folder.

Powershell: Get yourself the newest version, possibly here: https://www.microsoft.com/en-us/download/details.aspx?id=40855

Powershell: You'll need to give some permissions, e.g.: set-executionpolicy unrestricted
Then you may need to grant individual access on a per-script basis.


## Court Calendar Scanner 
This Ruby script scans the "Court Calendar.csv" file sent out to media outlets daily. 

### How It Works
---
1. The script goes through the file's rows...
2. Finds the defendant's first and last names within a row...
3. Searches the name (e.g. "JOE SMITH") in the Palm Beach Post's text archives, which ranges from 1989 to present and includes only print stories...
4. Counts how many stories in the archives have the defendant's name...
5. Gets the URL for the search results of the defendant's name...
6. Adds to a SQLite database the defendant's first and last name, number of archived print stories with the defendant's first and last name, and the URL to those search results
7. Adds to a CSV the stuff it adds to the SQLite database.


### To do's
---
- Add details on what is happening in court today (look at column S and Y)


### Suggestions
---
- Add defense attorney info
- Add judge info
- Add charge info
- Add link to the court system (REQUESTED)
