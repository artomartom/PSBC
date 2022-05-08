

Import-Module './PSBC.psm1'





#$proj = Initialize-Project -Path '..\DX11bubblesDemo\';
$proj = Get-Project ;
#$proj = Get-Project  ;


 

$proj.SetArch('x64');
 

Remove-Module PSBC
 