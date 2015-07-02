#!/python27/python
from datetime import date
from datetime import datetime
import time
import os
import imaplib
import email
import creds

## So, this logs into the pbpostdata@gmail.com account and looks for that one specific csv file
## from within emails sent today with that one specific email subject line.

## If you get to it a day late, the easiest way is to just forward the old input file again,
## and then it counts as an email from today. When you're done with it, you should delete the old
## email.

date.today().strftime("%d-%b-%Y")
detach_dir = '../datafiles' # directory where to save attachments (default: current)
target="Court Calendar.csv"


if os.path.isfile(detach_dir + "/" + target):
	print "Deleting old file " + detach_dir + "/" + target
	os.remove(detach_dir + "/" + target)

while (not os.path.isfile(detach_dir + "/" + target)) or datetime.now().strftime("%H")<=22:
	# connecting to the gmail imap server
	print "Looking for email ..."
	m = imaplib.IMAP4_SSL("imap.gmail.com")		# Got a SSL handshake error here once.
	m.login(creds.access['gmailaccount'], creds.access['gmailpassword'])

	# use m.list() to get all the mailboxes
	m.select(creds.access['gmailbox'])

	#resp, items = m.search(None, "ALL") # you could filter using the IMAP rules here (check http://www.example-code.com/csharp/imap-search-critera.asp)
	searchstring=str("SINCE " + date.today().strftime("%d-%b-%Y"))
	resp, items = m.search(None, 'ON', date.today().strftime("%d-%b-%Y"))
	#print items
	items = items[0].split() # getting the mails id

	#bslist = []
	##bslist.append(items[0].split()[-1])
	#bslist.append(items[0].split())

	for emailid in items:
		resp, data = m.fetch(emailid, "(RFC822)") # fetching the mail, "`(RFC822)`" means "get the whole stuff", but you can ask for headers only, etc
		email_body = data[0][1] # getting the mail content
		mail = email.message_from_string(email_body) # parsing the mail content to get a mail object

		#Check if any attachments at all
		if mail.get_content_maintype() != 'multipart':
			continue

		print "["+mail["From"]+"] :" + mail["Subject"]

		# we use walk to create a generator so we can iterate on the parts and forget about the recursive headach
		for part in mail.walk():
			# multipart are just containers, so we skip them
			if part.get_content_maintype() == 'multipart':
				continue

			# is this part an attachment ?
			if part.get('Content-Disposition') is None:
				continue

			filename = part.get_filename()
			counter = 1

			# if there is no filename, we create one with a counter to avoid duplicates
			if not filename:
				filename = 'part-%03d%s' % (counter, 'bin')
				counter += 1

			if not filename==target:
				print "Found filename " + filename + " but I don't know what it is and don't trust it. Ignoring."
			else:
				print "Found " + filename + " so we can get to work."		
				fp = open(detach_dir + "/" + filename, 'wb')
				fp.write(part.get_payload(decode=True))
				fp.close()
	if not os.path.isfile(detach_dir + "/" + target):
		print "Correct attachment not found. Waiting a while before trying again."
		time.sleep(360)			# Wait a while if we don't have our file yet.
			
	## Yeah, the below stuff just never worked.
	# Now let's move the old stuff to trash
	# print "Trying to move stuff to trash"
	# typ, data = m.uid('STORE', emailid, '+X-GM-LABELS', '\Trash')
	# typ, data = m.uid('STORE', emailid, '+X-GM-LABELS', '\Deleted')
	# typ, data = m.uid('STORE', emailid, '-X-GM-LABELS', 'Courtssearch')
	# typ, data = m.uid('STORE', emailid, '-X-GM-LABELS', '\Courtssearch')
	