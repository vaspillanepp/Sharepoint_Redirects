 
###################################
##   Variables that need editing ##
###################################



#$spmigratefile="C:\Users\IITPSPIL\Desktop\SP_WAVES_Redirects\sp_wave.txt"
$spmigratefile="C:\Users\IITPSPIL\OneDrive - Department of Veterans Affairs\SP_WAVES_Redirects\sp_wave.txt"
#$outfile="C:\Users\IITPSPIL\Desktop\SP_WAVES_Redirects\sp_wave_output.txt"
$outfile="C:\Users\IITPSPIL\OneDrive - Department of Veterans Affairs\SP_WAVES_Redirects\sp_wave_output.txt"
#$regex="hsrd"
$F5_INT1 = "10.206.160.238"
$F5_INT2 = "10.206.160.239"
#LAB F5s
#$F5_INT1 = "10.206.160.235"
#$F5_INT2 = "10.206.160.236"
$plinkpath = "C:\Users\IITPSPIL\OneDrive - Department of Veterans Affairs\apps\Putty\plink.exe"


#$spmigratefile=$spmigratefile -replace ' ','` '
#$outfile=$outfile -replace ' ','` '
$plinkpath = $plinkpath -replace ' ','` '

#$wavenum = 47
$wavenum = $null                 #if you set $wavenum to null it will prompt user to enter it

###################################
#   Start Program                ##
###################################

#$xFolderArray = @()
#$xFolderArray = LoadFolderArray $xFolderArray

mode con: cols=1100 lines=50
clear

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

##############################
#  Get WAVE Number if not $null
##############################
$title = 'Enter Wave number'
$msg   = 'Which wave number is this? '
if ($wavenum -eq $null) {
    $wavenum = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $wavenum)
}



#If (Test-Path $spmigratefile){
#    Remove-Item $spmigratefile
#}
If (Test-Path $outfile){
    Remove-Item $outfile
}
#Start-Transcript -Path $outfile -Append


$d = Get-Content $spmigratefile
$d = $d -replace '\r', ''
$d = $d -replace 'https://', ''
$d = $d -replace 'http://', ''
$clen = $d.Length
$rowhash = @{}

"tmsh show /cm sync-status" | out-file $outfile -Append
"tmsh run /cm config-sync to-group sync-failover-device-group" | out-file $outfile -Append
"" | out-file $outfile -Append

$recs=0
For ($i=0; $i -le $clen; $i++) {
    $value = $d[$i]
    $value = $value -replace ' ','%20'
    if ($value -ne "" -And $value -notmatch "dvagov.sharepoint.com" -And $value) {
        $old = $value.ToLower()
        $i++
        $new = $d[$i]
        if ($old -notmatch '.+?/$') {
            $old += '/'
        }
        $recs += 1
        $rowhash[$old]=$new

        "{0,-55} `t {1,-55}" -f $old, $new | out-file $outfile -Append

    }
 }
 
 "=========================" | out-file $outfile -Append
 "Number of Redirects $recs" | out-file $outfile -Append


 "" | out-file $outfile -Append
 "" | out-file $outfile -Append


"###################################" | out-file $outfile -Append
"#  MIGRATION $wavenum $(Get-Date)" | out-file $outfile -Append
"#" | out-file $outfile -Append
"#  tmsh modify /ltm data-group internal datagroup_uri_list_lc records add {  { data  } }" | out-file $outfile -Append
"###################################" | out-file $outfile -Append

$commands=$null
foreach($key in $rowhash.keys) {

    $old=$key
    $old=$old.replace(" ","%20")
    $new=$rowhash[$key]
    "tmsh modify /ltm data-group internal datagroup_uri_list_lc records add { $old { data $new } }" | out-file $outfile -Append
    $commands += "tmsh modify /ltm data-group internal datagroup_uri_list_lc records add { $old { data $new } } `r`n"
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") 

c:
#cd C:\Users\IITPSPIL\Desktop\apps\Putty
cd "C:\Users\IITPSPIL\OneDrive - Department of Veterans Affairs\apps\Putty"

#$test= Invoke-Expression 'cmd /c start powershell -Command { c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@10.206.160.238 "tmsh show /cm sync-status"}'
#start powershell { "[console]::WindowWidth=160;[console]::BackgroundColor='Red';c:\users\iitpspil\desktop\apps\putty\plink vaphiwbtweb100 ./bin/tailbep.sh" }
#$active1= Invoke-Expression "c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@$F5_INT1 'tmsh show /cm failover-status | grep ACTIVE'"
#$active2= Invoke-Expression "c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@$F5_INT2 'tmsh show /cm failover-status | grep ACTIVE'"
$active1= Invoke-Expression "$plinkpath -pw Pretz3! root@$F5_INT1 'tmsh show /cm failover-status | grep ACTIVE'"
$active2= Invoke-Expression "$plinkpath -pw Pretz3! root@$F5_INT2 'tmsh show /cm failover-status | grep ACTIVE'"

if ($active1 -match "ACTIVE") {
    $active_F5 = $F5_INT1
}elseif ($active2 -match "ACTIVE") {
    $active_F5 = $F5_INT2
} else {
    write-host "NO ACTIVE F5s!!!!!"
    [System.Windows.MessageBox]::Show('NO ACTIVE F5s DETECTED','ALERT')
}
#$hostname = Invoke-Expression "c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@$active_F5 'tmsh list sys global-settings hostname'"
$hostname = Invoke-Expression "$plinkpath -pw Pretz3! root@$active_F5 'tmsh list sys global-settings hostname'"
$hostname = $hostname.split()
$hostname = $hostname[8]
$pendcomm = "tmsh show /cm sync-status"
#$pending= Invoke-Expression "c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@$active_F5 '$pendcomm'"
$pending= Invoke-Expression "$plinkpath -pw Pretz3! root@$active_F5 '$pendcomm'"
#$pending = $pending -replace '\r', '\r\n'
$newpending=$null

########################
#  Check Sync Status
########################

$needtosync = $false
foreach ($line in $pending) { 
    $newpending += "$line `r`n" 
    if ($line -match "Changes Pending") {
        $needtosync = $true
    }
}
if ($needtosync -eq $true) {
        $title  = "Sync F5s?"
        $question = "The F5s are not in Sync.`r`n `r`n The active F5 is: $active_F5 ($hostname) `r`n `r`n Would you like to sync them using the active configuration? `r`n $newpending"

        $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
        if ($decision -eq 0) {

            Write-Host 'confirmed'
            $synccommand = "tmsh run /cm config-sync to-group sync-failover-device-group"
            #$synccommand = "tmsh run /cm config-sync to-group sync-failover-group"                #Dev F5s
            #$syncoutput= Invoke-Expression "c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@$active_F5 '$synccommand'"
            $syncoutput= Invoke-Expression "$plinkpath -pw Pretz3! root@$active_F5 '$synccommand'"
            [System.Windows.MessageBox]::Show("Sync Completed")

        } else {
            Write-Host 'F5s NOT synched'
        }
}
########################
#  Run Import commands
########################
$title  = "Run tmsh redirect commands?"
$question = "Would you like to run these import commands?`r`n `r`n$commands `r`n `r`n"

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
$importoutput = $null
if ($decision -eq 0) {

    Write-Host 'confirmed'
    foreach($key in $rowhash.keys) {
        $old=$key
        $new=$rowhash[$key]
        $importline = "tmsh modify /ltm data-group internal datagroup_uri_list_lc records add { $old { data $new } }" 
        #$importoutput += Invoke-Expression "c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@$active_F5 '$importline'"
        $importoutput += Invoke-Expression "$plinkpath -pw Pretz3! root@$active_F5 '$importline'"
    }
     "" | out-file $outfile -Append
     "" | out-file $outfile -Append
     "OUTPUT OF tmsh modify commands" | out-file $outfile -Append
     "**************************************" | out-file $outfile -Append    
     $importoutput | out-file $outfile -Append

} else {
    Write-Host 'Import Commands NOT run'
}


$title  = "Sync F5s?"
$question = "The F5s are not in Sync.`r`n `r`n The active F5 is: $active_F5 ($hostname) `r`n `r`n Would you like to sync them using the active configuration? `r`n $newpending"

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {

    Write-Host 'confirmed'
    $synccommand = "tmsh run /cm config-sync to-group sync-failover-device-group"
    #$synccommand = "tmsh run /cm config-sync to-group sync-failover-group"                #Dev F5s
    #$syncoutput= Invoke-Expression "c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@$active_F5 '$synccommand'"
    $syncoutput= Invoke-Expression "$plinkpath -pw Pretz3! root@$active_F5 '$synccommand'"
    [System.Windows.MessageBox]::Show("Sync Completed")

} else {
    Write-Host 'F5s synching not run'
}


####################################
# OUTPUT NEW DATAGROUP to text file
####################################
"" | out-file $outfile -Append
"" | out-file $outfile -Append
"#######################################" | out-file $outfile -Append
"#  Current DataGroup after wave $wavenum" | out-file $outfile -Append
"#" | out-file $outfile -Append
"#  tmsh list /ltm data-group internal datagroup_uri_list_lc" | out-file $outfile -Append
"#######################################" | out-file $outfile -Append
"" | out-file $outfile -Append
$showdatagroupline = "tmsh list /ltm data-group internal datagroup_uri_list_lc" 
#Invoke-Expression "c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@$active_F5 '$showdatagroupline'"  | out-file $outfile -Append
Invoke-Expression "$plinkpath -pw Pretz3! root@$active_F5 '$showdatagroupline'"  | out-file $outfile -Append
"" | out-file $outfile -Append
"" | out-file $outfile -Append

#################################
# OUTPUT iRULE to txt file
#################################

"#######################################" | out-file $outfile -Append
"#  Current iRule after wave $wavenum" | out-file $outfile -Append
"#" | out-file $outfile -Append
"#  tmsh list /ltm rule oed_protal_redirect_6" | out-file $outfile -Append
"#######################################" | out-file $outfile -Append
"" | out-file $outfile -Append
$showiruleline = "tmsh list /ltm rule oed_protal_redirect_6" 
#Invoke-Expression "c:\users\iitpspil\desktop\apps\putty\plink -pw Pretz3! root@$active_F5 '$showiruleline'"  | out-file $outfile -Append
Invoke-Expression "$plinkpath -pw Pretz3! root@$active_F5 '$showiruleline'"  | out-file $outfile -Append
