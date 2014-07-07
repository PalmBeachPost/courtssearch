param(
    $path ="c:\temp",
    $foldername ="courtscsv"
    )

$olFolderInbox = 6

$objOutlook = new-object -com outlook.application; 
$ns = $objOutlook.GetNameSpace("MAPI");
$inbox = $ns.GetDefaultFolder($olFolderInbox)

$targetfolder = $inbox.Folders | where-object { $_.name -eq $foldername }
$message = $targetfolder.Items | where-object {$_.subject -like "*CSV*" -and $_.receivedTime.dayofyear -eq (get-date).dayofyear}

$message.attachments|foreach{
	$filepath = join-path $path $_.filename
	write-host "saving file to " $filepath
	$_.saveasfile($filepath)
}
