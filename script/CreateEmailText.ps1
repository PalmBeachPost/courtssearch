param(
    [Parameter(Mandatory=$true)]
     $datafile,
     $n = 10,
     $outfile
    )

$defendants = import-csv $datafile
$sortedlist = $defendants|sort Defendant -unique |
     sort {[int] $_."Number of matches in PBP text archive"} -descending |
     select -first $n |
     select defendant, 
        @{Name="Num";Expression={$_."Number of matches in PBP text archive"}}, 
        @{Name="link";Expression={$_."PBP archive search result URL"}},
        @{Name="event";Expression={$_."Recent event"}}

$emailTemplate = get-content "./templates/email.txt"
$emailTemplate = $emailTemplate.replace("[NUMBER]",$n)
$rowTemplate = get-content "./templates/row.txt"

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
    $row = $rowTemplate.replace("[RESULT_URL]",$sortline.link).replace("[DEFANDANT_NAME]",$sortline.defendant)
    $row = $row.replace("[EVENT_DESC]",$sortline.event).replace("[CHARGES]",$charges).replace("[HIT_COUNT]",$sortline.num)

    $rows += $row
        
}

$emailTemplate.replace("[ROWS_LOCATION]",$rows)|out-file $outfile






