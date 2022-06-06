[CmdletBinding()]
param(
    [string]$Name
)



Get-Module | where-Object { $_.Name -eq $Name } | ForEach-Object {
    $mdl = $_  ;

    Remove-Module $mdl.Name;

    Write-Host "Importing $($mdl.Path)";

    Import-Module $mdl.Path;
    return ;
};
 





