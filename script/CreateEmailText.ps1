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
        @{Name="event";Expression={$_."Recent event"}}

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
    $row = $rowTemplate.replace("[RESULT_URL]",$sortline.link).replace("[DEFENDANT_NAME]",$sortline.defendant)
    $row = $row.replace("[EVENT_DESC]",$sortline.event).replace("[CHARGES]",$charges).replace("[HIT_COUNT_BROAD]",$sortline.numBroad).replace("[HIT_COUNT_NARROW]",$sortline.numNarrow)

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
        @{Name="event";Expression={$_."Recent event"}}

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
    $row = $rowTemplate.replace("[RESULT_URL]",$sortline.link).replace("[DEFENDANT_NAME]",$sortline.defendant)
    $row = $row.replace("[EVENT_DESC]",$sortline.event).replace("[CHARGES]",$charges).replace("[HIT_COUNT_BROAD]",$sortline.numBroad).replace("[HIT_COUNT_NARROW]",$sortline.numNarrow)

    $rows += $row
        
}

$emailTemplate.replace("[ALLROWS_LOCATION]",$rows)|out-file $outfile






