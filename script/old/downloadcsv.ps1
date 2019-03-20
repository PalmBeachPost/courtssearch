param(
    $path ="..\datafiles\",
    $folder ="courtscsv"
    )

$olFolderInbox = 6

$objOutlook = new-object -com outlook.application; 
$ns = $objOutlook.GetNameSpace("MAPI");
$inbox = $ns.GetDefaultFolder($olFolderInbox)

$targetfolder = $inbox.Folders | where-object { $_.name -eq $folder }
$message = $targetfolder.Items | where-object {$_.subject -like "*CSV Court Calendar.rdl*" -and $_.receivedTime.dayofyear -eq (get-date).dayofyear}

$path = resolve-path $path
$message.attachments|foreach{
	$filepath = join-path $path $_.filename
	write-host "saving file to " $filepath
	$_.saveasfile($filepath)
}
