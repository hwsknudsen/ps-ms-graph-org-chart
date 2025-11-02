#Import-Module activedirectory
#Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes "User.Read.All"
$ErrorActionPreference = 'SilentlyContinue'
$OrgChart = ".\ADOrgChart.txt"
$InitialIndent = " |--> "

$TopUser = Read-Host "Please enter Top Level Manager"
#$TopUser = "user@tld.com"
$OrgChart = ".\$TopUser-ADOrgChart.txt"
$OrgChartCSV = ".\$TopUser-ADOrgChart.csv"

$Tld = $TopUser.Split('@')[1]

Write-host "Please refer to $OrgChart and $OrgChartCSV for results"

function Get-DirectReports {
    param(
        [string]$Manager,
        [string]$Indent,
        [switch]$initial
    )
try{
    $UserResult = Get-MgUser -UserId $Manager
    $UserResultreports = Get-MgUserDirectReport -UserId $UserResult.Id

    if($initial){
        write-output ""  | Tee-Object $OrgChart
        write-output "$($UserResult.DisplayName) : $($UserResult.UserPrincipalName)"  | Tee-Object $OrgChart -Append
        write-output " |"  | Tee-Object $OrgChart -Append

        $UserResult | Select-Object DisplayName,UserPrincipalName | export-csv $OrgChartCSV -NoTypeInformation

    }
    if($UserResultreports.Id) {
            Foreach ($DR in $UserResultreports.Id){
         
                $DRObj = Get-MgUser -UserId $DR -Property DisplayName, ID, UserPrincipalName, Department, JobTitle
                $DRObjReports = Get-MgUserDirectReport -UserId $DRObj.UserPrincipalName

               
                if($DRObj.UserPrincipalName -notlike "*-a"){
                    $DRObj | Select-Object DisplayName,UserPrincipalName | export-csv $OrgChartCSV -NoTypeInformation -Append
                    write-output "$Indent$($DRObj.DisplayName) : $($DRObj.UserPrincipalName) : $($DRObj.JobTitle) : $($DRObj.Department)" | Tee-Object $OrgChart -Append


                if($DRObjReports.Count -ne 0){
                        $NewIndent = "`t$Indent"
                        Get-DirectReports -Manager $DRObj.UserPrincipalName -Indent $NewIndent
               
                    }
                }
            }
        }
       

   
    } catch {
        Write-Host "No User ID found for $TopUser.  Exiting" -ForegroundColor Red
        break
    }

}


Get-DirectReports -Manager $TopUser -initial -Indent $InitialIndent

Write-Output "----------Unmanaged below--------- in tld: $tld"

$usersp = Get-MgUser -All -Filter 'assignedLicenses/$count ne 0' -ConsistencyLevel eventual -CountVariable licensedUserCount -Property DisplayName, ID, UserPrincipalName, Department, JobTitle
$users = $usersp |Where-Object {$_.UserPrincipalName -like "*$Tld"} | Sort-Object -Property UserPrincipalName
$count = 0
Foreach ($user in $users){
    
    $manager = Get-MgUserManager -UserId $user.UserPrincipalName -Property DisplayName, ID, UserPrincipalName, Department 
    if($manager.Count -eq 0){
        write-output "$($user.DisplayName) : $($user.UserPrincipalName) : $($user.JobTitle) : $($user.Department)"
        $count = $count +1
    }
}

write-output "unmanaged count: $count"

#Disconnect-MgGraph
