#Download today's files
#.\DownloadCSV.ps1 

#run ruby script to parse and search
#ruby textArchiveScanner.rb

#send the result in email
$addresses ="ksukumar@pbpost.com"
#$addresses ="ksukumar@pbpost.com,cpersaud@pbpost.com,fzarkhin@pbpost.com, jengelhardt@pbpost.com, dduret@pbpost.com"
$date = get-date -format yyyy-MM-dd
$file = "../datafiles/defendants_$date.csv"

$datestring = get-date -format d
$subject ="Courts search $datestring"

$emailfile = "../datafiles/email.htm";
.\CreateEmailText.ps1 -datafile $file -outfile $emailfile -n 10

$bodytext = get-content "../datafiles/email.htm"

if(test-path $file){
    $file = resolve-path $file
    write-host "sending $file"
    .\SendMail.ps1 -sendTo $addresses -attachment $file.path -subject $subject -bodytext $bodytext
}
else{
    .\SendMail.ps1 -subject "ERROR processing courts file" -bodytext "Today is not a good day. Something went wrong. No result file was found. Check script"
}
