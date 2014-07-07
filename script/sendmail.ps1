param(
    $sendTo = "ksukumar@pbpost.com,cpersaud@pbpost.com",
    $attachment ="c:\temp\file.csv",
    $bodytext ="testing! ignore mail"
    )

$outlook = new-object -com outlook.application; 

$mail = $outlook.CreateItem(0)

$datestring = get-date -format d
$mail.subject ="Courts search $datestring"
$mail.body =$bodyText
$mail.attachments.add($attachment)

$sendTo.split(',')|foreach{
	if($_){
		$mail.Recipients.Add($_)
	}
}

$mail.send()