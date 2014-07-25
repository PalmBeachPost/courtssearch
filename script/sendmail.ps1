param(
    $sendTo = "ksukumar@pbpost.com",
    $attachment ="..\datafiles\readme.md",
    $subject = "Automated by sendMail",
    $bodytext =" "
    )

$outlook = new-object -com outlook.application; 

$mail = $outlook.CreateItem(0)

$mail.subject =$subject
$mail.HTMLBody =$bodyText
$attachment =resolve-path $attachment
$mail.attachments.add($attachment.path)

$sendTo.split(',')|foreach{
	if($_){
		$mail.Recipients.Add($_)
	}
}

$mail.send()