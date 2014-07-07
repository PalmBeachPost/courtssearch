This folder contains scripts to interface with outlook

Requirements
1. Powershell 3.0
2. Outlook must be running


DOWNLOADING ATTACHMENT
-----------------------
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