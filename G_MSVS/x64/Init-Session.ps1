 
Import-module -Name F:\Dev\Projects\PSBC\G_MSVS\x64\PSBC.psm1 -DisableNameChecking

#Get-ChildItem -Path Function:\Functionname    check if function is loaded into memory 
<#
The module autoloading feature was introduced in PowerShell version 3.
 To take advantage of module autoloading, a script module needs to be
 saved in a folder with the same base name as the .PSM1 file and in a
location specified in $env:PSModulePath.
#>

Set-Proj  
GoTo-Proj 