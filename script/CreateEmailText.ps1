param(
    [Parameter(Mandatory=$true)]
     $datafile,
     $n = 10, #not used anymore
     $outfile
    )

$defendants = import-csv $datafile
$emailTemplate = get-content "./templates/email.txt"
$emailTemplate = $emailTemplate.replace("[NUMBER]",$n)
$rowTemplate = get-content "./templates/row.txt"

#MURDER AND TRIALS
$sortedlist = $defendants|
     where {($_."Recent event").contains("TRIAL") -or ($_.charge).toLower().contains("murder") -or ($_.charge).toLower().contains("homicide") -or ($_.charge).toLower().contains("manslaughter")}|
     sort Defendant -unique |
     sort {[int] $_."Match count (narrow)"} -descending |
     select defendant, 
        @{Name="numBroad";Expression={$_."Match count (broad)"}}, 
        @{Name="numNarrow";Expression={$_."Match count (narrow)"}}, 
        @{Name="link";Expression={$_."Search results URL (narrow)"}},
        @{Name="event";Expression={$_."Recent event"}},
		@{Name="caseNumber";Expression={$_."Case Number"}}

$rows=""
$sortedlist|foreach{
    $sortline = $_
    $charges =""
    $defendants| where {$_.Defendant -eq $sortline.defendant}|select "charge"|foreach{ 
        if(!$charges.Contains($_.charge.trim())){
            $charges +=$_.charge+", "
        }
    }
    $charges = $charges.trim(', ')

    #until i figure out a better way to format multi-line command chaining
	$row = $rowTemplate.replace("[RESULT_URL]",$sortline.link).replace("[DEFENDANT_NAME]",$sortline.defendant).replace("[CASE_NUMBER]", $sortline.caseNumber)
    $row = $row.replace("[EVENT_DESC]",$sortline.event).replace("[CHARGES]",$charges).replace("[HIT_COUNT_BROAD]",$sortline.numBroad).replace("[HIT_COUNT_NARROW]",$sortline.numNarrow)
	$row = $row.replace("Event : STCK - STATUS CHECK", "Status check").replace("Event : PC - PLEA CONFERENCE", "Plea conference").replace("Event : MH - MOTION HEARING", "Motion hearing").replace("Event : CD - CASE DISPOSITION", "Case disposition").replace("Event : 2 - 2 HR CALL", "2-hr call").replace("Event : JT - JURY TRIAL", "Jury trial").replace("Event : AR - ARRAIGNMENT", "Arraignment").replace("Event : OH - OTHER HEARING", "Other hearing").replace("Event : CC - CALENDAR CALL", "Calendar call").replace("Event : VOP - VIOLATION OF PROBATION", "Violation of probation").replace("Event : STF - STATE TO FILE CHARGES", "State to file charges").replace("Event : BOND - BOND HEARING", "Bond hearing").replace("Event : SENT - SENTENCING", "Sentencing").replace("Event : MCH - MULTIPLE COURT HEARINGS", "Multiple court hearings").replace("Event : PRH - FINAL VOP REVOKED HEARING", "Final VOP revoked hearing").replace("Event : MWD - MOTION TO WITHDRAW", "Motion to withdraw").replace("Event : FS - FULFILLMENT OF SENTENCE", "Fulfillment of sentence").replace("Event : MTS - MOTION TO SUPPRESS", "Motion to suppress").replace("Event : EVI - EVIDENTIARY HEARING", "Evidentiary hearing").replace("Event : 1 - 1 HR CALL", "1-hr call").replace("Event : PREL - PRELIMINARY HEARING", "Preliminary hearing").replace("Event : AH - ADVERSARY HEARING", "Adversary hearing").replace("Event : MCMP - MOTION TO COMPEL", "Motion to compel").replace("Event : RH - RESTITUTION HEARING", "Restitution hearing").replace("Event : MTD - MOTION TO DISMISS", "Motion to dismiss").replace("Event : PCSX - PROBABLE CAUSE HRG RYCE DETERM", "Probable cause HRG Ryce determ").replace("Event : MFUL - MITIGATION AND FULFILLMENT", "Mitigation and fulfillment").replace("Event : SC - SHOW CAUSE", "Show cause").replace("Event : NJ - NON JURY TRIAL", "Non jury trial").replace("Event : FTA - FAILURE TO APPEAR", "Failure to appear").replace("Event : MTV - MOTION TO VACATE", "Motion to vacate").replace("Event : FTAA - FTA ARRAIGNMENT", "FTA arraignment").replace("Event : DS - DRUG COURT STATUS CHECK", "Drug court status check").replace("Event : ARAM - ARRAIGNMENT AMENDED INFOR", "Arraignment amended infor").replace("Event : FAP - FIRST APPEARANCE", "First appearance").replace("Event : PCAD - ADVERSARIAL HRG RYCE ACT", "Adversarial HRG Ryce act").replace("Event : 24 - 24 HR CALL", "24-hr call").replace("Event : OC - ON CALL", "On call").replace("Event : HRNG - Hearing", "Hearing").replace("Event : FTAT - FTA TRIAL", "FTA trial").replace("Event : MTT - MOTION TO TRANSFER", "Motion to transfer")

    $rows += $row
        
}

$emailTemplate = $emailTemplate.replace("[TRIALANDMURDERSROWS_LOCATION]",$rows)

#ALL RECORDS
$sortedlist = $defendants|
     sort Defendant -unique |
     sort {[int] $_."Match count (narrow)"} -descending |
     select defendant, 
        @{Name="numBroad";Expression={$_."Match count (broad)"}}, 
        @{Name="numNarrow";Expression={$_."Match count (narrow)"}}, 
        @{Name="link";Expression={$_."Search results URL (narrow)"}},
        @{Name="event";Expression={$_."Recent event"}},
		@{Name="caseNumber";Expression={$_."Case Number"}}

$rows=""
$sortedlist|foreach{
    $sortline = $_
    $charges =""
    $defendants| where {$_.Defendant -eq $sortline.defendant}|select "charge"|foreach{ 
        if(!$charges.Contains($_.charge.trim())){
            $charges +=$_.charge+", "
        }
    }
    $charges = $charges.trim(', ')

    #until i figure out a better way to format multi-line command chaining
	#$sortline.defendant = ToTitleCase($sortline.defendant)
    $row = $rowTemplate.replace("[RESULT_URL]",$sortline.link).replace("[DEFENDANT_NAME]",$sortline.defendant)
    $row = $row.replace("[EVENT_DESC]",$sortline.event).replace("[CHARGES]",$charges).replace("[HIT_COUNT_BROAD]",$sortline.numBroad).replace("[HIT_COUNT_NARROW]",$sortline.numNarrow).replace("[CASE_NUMBER]", $sortline.caseNumber)
	$row = $row.replace("Event : STCK - STATUS CHECK", "Status check").replace("Event : PC - PLEA CONFERENCE", "Plea conference").replace("Event : MH - MOTION HEARING", "Motion hearing").replace("Event : CD - CASE DISPOSITION", "Case disposition").replace("Event : 2 - 2 HR CALL", "2-hr call").replace("Event : JT - JURY TRIAL", "Jury trial").replace("Event : AR - ARRAIGNMENT", "Arraignment").replace("Event : OH - OTHER HEARING", "Other hearing").replace("Event : CC - CALENDAR CALL", "Calendar call").replace("Event : VOP - VIOLATION OF PROBATION", "Violation of probation").replace("Event : STF - STATE TO FILE CHARGES", "State to file charges").replace("Event : BOND - BOND HEARING", "Bond hearing").replace("Event : SENT - SENTENCING", "Sentencing").replace("Event : MCH - MULTIPLE COURT HEARINGS", "Multiple court hearings").replace("Event : PRH - FINAL VOP REVOKED HEARING", "Final VOP revoked hearing").replace("Event : MWD - MOTION TO WITHDRAW", "Motion to withdraw").replace("Event : FS - FULFILLMENT OF SENTENCE", "Fulfillment of sentence").replace("Event : MTS - MOTION TO SUPPRESS", "Motion to suppress").replace("Event : EVI - EVIDENTIARY HEARING", "Evidentiary hearing").replace("Event : 1 - 1 HR CALL", "1-hr call").replace("Event : PREL - PRELIMINARY HEARING", "Preliminary hearing").replace("Event : AH - ADVERSARY HEARING", "Adversary hearing").replace("Event : MCMP - MOTION TO COMPEL", "Motion to compel").replace("Event : RH - RESTITUTION HEARING", "Restitution hearing").replace("Event : MTD - MOTION TO DISMISS", "Motion to dismiss").replace("Event : PCSX - PROBABLE CAUSE HRG RYCE DETERM", "Probable cause HRG Ryce determ").replace("Event : MFUL - MITIGATION AND FULFILLMENT", "Mitigation and fulfillment").replace("Event : SC - SHOW CAUSE", "Show cause").replace("Event : NJ - NON JURY TRIAL", "Non jury trial").replace("Event : FTA - FAILURE TO APPEAR", "Failure to appear").replace("Event : MTV - MOTION TO VACATE", "Motion to vacate").replace("Event : FTAA - FTA ARRAIGNMENT", "FTA arraignment").replace("Event : DS - DRUG COURT STATUS CHECK", "Drug court status check").replace("Event : ARAM - ARRAIGNMENT AMENDED INFOR", "Arraignment amended infor").replace("Event : FAP - FIRST APPEARANCE", "First appearance").replace("Event : PCAD - ADVERSARIAL HRG RYCE ACT", "Adversarial HRG Ryce act").replace("Event : 24 - 24 HR CALL", "24-hr call").replace("Event : OC - ON CALL", "On call").replace("Event : HRNG - Hearing", "Hearing").replace("Event : FTAT - FTA TRIAL", "FTA trial").replace("Event : MTT - MOTION TO TRANSFER", "Motion to transfer")

    $rows += $row
        
}

$emailTemplate.replace("[ALLROWS_LOCATION]",$rows)|out-file $outfile






