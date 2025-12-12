
$ErrorActionPreference = 'Continue'

Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All" 


function Set-manager {
    param (
        [string]$Manager,
        [string]$Employee
    )
    

    $managerid = Get-MgUser -UserId $Manager
    $EmployeeID = Get-MgUser -UserId $Employee
    $ManagerIDHT = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($managerid.Id)"
    }

    Set-MgUserManagerByRef -UserId $EmployeeID.Id -BodyParameter $ManagerIDHT
}
