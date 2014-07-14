param(
    $sendTo = "ksukumar@pbpost.com",
    $attachment ="..\datafiles\readme.md",
    $bodytext =" "
    )

$outlook = new-object -com outlook.application; 

$mail = $outlook.CreateItem(0)

$datestring = get-date -format d
$mail.subject ="Courts search $datestring"
$mail.body =$bodyText
$attachment =resolve-path $attachment
$mail.attachments.add($attachment.path)

$sendTo.split(',')|foreach{
	if($_){
		$mail.Recipients.Add($_)
	}
}

$mail.send()