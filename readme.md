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
7) Adds to a CSV the stuff it adds to the SQLite database.


TO DO
===
- Make defendant names unique
- Sort the names by numebr of charges
- Add details on what is happening in court today (look at column S and Y)


SUGGESTIONS
===
- Add defense attorney info
- Add judge info
- Add charge info

DOWNLOADING ATTACHMENT
-----------------------
This scripts interfaces with outlook to download today's Courts CSV file

Requirements
1. Powershell 3.0
2. Outlook must be running



	SET UP FOR DOWNLOADING ATTACHMENTS
	----------------------------------
	1. Create an outlook rule to move mails with CSV attachments to a separate folder
	2. To avoid perfromance degradation over time, make sure that the folder has a reasonable archive setting. Recommended, delete every week

	RUNNING SCRIPT
	--------------
	1. Open powershell command line and navigate to the scripts folder
	2. Run the following
		downloadCSV.ps1 -path <folder path of where to download the file to> - folder <name of the outlook folder to search in>
		
	DEFAULT VALUES
	--------------
	path ="c:\temp",
	folder ="courtscsv"

SENDING MAIL
--------------
		RUNNING SCRIPT
		--------------
		1. Open powershell command line and navigate to the scripts folder
		2. Run the following
			sendMail.ps1 -senTo < a comma-separated list of email addresses> - attachment <full path of the file to attach>
		3. optional parameter
			-bodyText "email text"

		DEFAULT VALUES
		---------------
		sendTo = "ksukumar@pbpost.com,cpersaud@pbpost.com",
		attachment ="c:\temp\file.csv",
		bodytext =" "