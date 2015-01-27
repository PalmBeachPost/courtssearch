# Court Docket-Archive Search
Everyday Palm Beach County Courts sends a daily docket that has all the scheduled court activity for the next day
This script downlaods the email from Outlook, parses it into a DB, runs a search for each name in the docket against Palm Beach Post's archives and sends out a result email highlighting cases of interest.

## Court Calendar Scanner 
This Ruby script scans the "Court Calendar.csv" file we get from Kathy Burstein. 

### How It Works
===
1. The script goes through the file's rows...
2. Finds the defendant's first and last names within a row...
3. Searches the name (e.g. "JOE SMITH") in the Palm Beach Post's text archives, which ranges from 1989 to present and includes only print stories...
4. Counts how many stories in the archives have the defendant's name...
5. Gets the URL for the search results of the defendant's name...
6. Adds to a SQLite database the defendant's first and last name, number of archived print stories with the defendant's first and last name, and the URL to those search results
7. Adds to a CSV the stuff it adds to the SQLite database.


### To do's
===
- Add details on what is happening in court today (look at column S and Y)


### Suggestions
===
- Add defense attorney info
- Add judge info
- Add charge info


### Downloading Attachment
===
This scripts interfaces with outlook to download today's Courts CSV file

Requirements
* Powershell 3.0
* Outlook must be running



#### Set Up For Downloading Attachments
===
1. Create an outlook rule to move mails with CSV attachments to a separate folder
2. To avoid perfromance degradation over time, make sure that the folder has a reasonable archive setting. Recommended, delete every week

#### Running Script
===
1. Open powershell command line and navigate to the scripts folder
2. Run the following
	downloadCSV.ps1 -path <folder path of where to download the file to> - folder <name of the outlook folder to search in>
	
Default Values
===
path ="c:\temp",
folder ="courtscsv"

### Sending Mail
--------------
1. Open powershell command line and navigate to the scripts folder
2. Run the following
	sendMail.ps1 -senTo < a comma-separated list of email addresses> - attachment <full path of the file to attach>
3. optional parameter
	-bodyText "email text"