
$ErrorActionPreference = 'Continue'

Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All" 

$Manager = Read-Host "Please enter Manager UPN"
$managerid = Get-MgUser -UserId $Manager

$Employee = Read-Host "Please enter Emloyeee UPN"
$EmployeeID = Get-MgUser -UserId $Employee

 $ManagerIDHT = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($managerid.Id)"
    }

Set-MgUserManagerByRef -UserId $EmployeeID.Id -BodyParameter $ManagerIDHT

#get-mguser -UserId (Get-MgUserManager -UserId $EmployeeID.Id).Id  
