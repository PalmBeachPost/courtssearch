#!/usr/bin/python
#import smtplib
#from email.mime.text import MIMEText
#from email.mime.multipart import MIMEMultipart
import sys
from datetime import date
import subprocess
import os
import creds

## Switched to using BLAT from
## http://sourceforge.net/projects/blat/

## If shifting to Unix, try mutt.

server = creds.access['emailserver']
fromaddr = creds.access['emailfrom']
toaddr = creds.access['emailto']

## Uncomment below for testing #########################################
#toaddr = "mstucka@pbpost.com"

msgsource = "..\datafiles\email.htm"
msgattach = "..\datafiles\defendants_" + str(date.today().strftime("%Y-%m-%d")) + ".csv"
toaddr = toaddr.replace(" ", "")			# Get rid of extra spaces
subject="TEST TEST TEST TEST Courts search " + str(date.today().strftime("%Y-%m-%d"))

if not (os.path.isfile(msgsource) and os.path.isfile(msgattach)):
	print "Some of the files are missing. Not emailing."
else:
	print "All files found. Let's try to send an email."
	subprocess.check_call(["./bin/blat.exe", msgsource, "-attacht", '"' + msgattach + '"', "-to", toaddr, "-f", fromaddr, "-subject", subject, "-server", server ])

## Python emails were kind of hinky. Switched to Blat, disabled this.
# msg = MIMEMultipart()
# msg['Subject'] = "Courts search " + str(date.today().strftime("%Y-%m-%d"))
# msg['From'] = fromaddr
# msg['To'] = toaddr


# #Send email.htm
# filehandler = open(msgsource, 'r')
# contents = MIMEText(filehandler.read(), 'html')
# filehandler.close()
# msg.attach(contents)

# #Send the defendants csv file
# filehandler = open(msgattach, 'r')
# contents = MIMEText(filehandler.read(), 'text')
# filehandler.close()
# msg.attach(contents)

# s=smtplib.SMTP(server)
# s.sendmail(msg['From'],msg['To'],msg.as_string())
# s.quit()