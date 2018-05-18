#!/usr/bin/python
from datetime import date
# import subprocess
import os
import creds

import emails

emailuser = os.environ["GOOGLEADDRESS"]
emailpassword = os.environ["GOOGLEPASSWORD"]
emailname = os.environ["GOOGLENAME"]
emailfrom = emailname + " <" + emailuser + ">"
toaddr = creds.access['emailto']

msgsource = "..\datafiles\email.htm"
with open(msgsource, "r") as f:
    html = f.read()

msgattachpre = "../datafiles/"
msgattach = "defendants_" + str(date.today().strftime("%Y-%m-%d")) + ".csv"
# toaddr = toaddr.replace(" ", "")            # Get rid of extra spaces
subject = "Courts search " + str(date.today().strftime("%Y-%m-%d"))

if not (os.path.isfile(msgsource) and os.path.isfile(msgattachpre + msgattach)):
    print "Some of the files are missing. Not emailing."
else:
    print "All files found. Let's try to send an email."
    # subprocess.check_call(["./bin/blat.exe", msgsource, "-attacht", '"' + msgattach + '"', "-to", toaddr, "-f", fromaddr, "-subject", subject, "-server", server ])
    message = emails.html(html=html, subject=subject, mail_from=emailfrom)
    message.attach(filename=msgattach, content_disposition="inline", data=open(msgattachpre + msgattach, "r"))
    message.send(to=(toaddr), smtp={"host":"smtp.gmail.com", "port":465, "ssl":True, "user":emailuser, "password":emailpassword} )