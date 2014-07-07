#Download today's files
.\DownloadCSV.ps1 

#run ruby script to parse and search
ruby textArchiveScanner.rb

#send the result in email
#$addresses = "ksukumar@pbpost.com, cpersaud@pbpost.com,fzarkhin@pbpost.com,jengelhardt@pbpost.com" 
$addresses ="ksukumar@pbpost.com, kavya.sukumar@outlook.com"
$date = get-date -format yyyy-MM-dd
$file = "../datafiles/defendants_$date.csv"
if(test-path $file){
    $file = resolve-path $file
    write-host "sending $file"
    .\SendMail.ps1 -sendTo $addresses -attachment $file.path -bodytext "Testing daily emails " 
}
else{
    .\SendMail.ps1 -bodytext "Today is not a good day. Something went wrong. No result file was found. Check script"
}
