

[CmdletBinding()]
param(
    [string[]]$DotNetProjDir = './'
)


Import-Module "$DotNetProjDir\bin\x64\Debug\netstandard2.0\*.dll"