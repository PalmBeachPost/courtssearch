## This requires some version of Powershell greater than 2.0. 4.0 seems to work fine.

## This is the master script, which calls a bunch of helpers:
## -- getcsv.py , which gets a certain CSV file attachment from the court system.
## -- textArchiveScanner.rb , which processes the initial CSV file by checking our story archives
## -- CreateEmailText.ps1 , which processes the archive scanner's CSV file to create HTML
## -- sendemail.py , which sends the CSV and HTML files using
## -- bin/blat.exe

## getcsv.py is designed to check regularly for the new CSV file until it's available. It will
## quit if the file isn't sent before a certain time, late at night.


#Download today's files
####### .\DownloadCSV.ps1
c:\python27\python getcsv.py

#run ruby script to parse and search
# c:\Ruby193\bin\ruby textArchiveScanner.rb

# Run Python script to parse and search
c:\python37\python textarchiveScanner.py

$date = get-date -format yyyy-MM-dd
$file = "../datafiles/defendants_$date.csv"

$emailfile = "../datafiles/email.htm"
.\CreateEmailText.ps1 -datafile $file -outfile $emailfile -n 10

c:\python27\python sendemail.py

