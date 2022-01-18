$ProjectName=  $args[0] 
$BuildConfig=  $args[1] 

Set-Location F:\Dev\Projects\$ProjectName\build\x86\$BuildConfig\; 

& "./$ProjectName.exe"  ;

if( $LASTEXITCODE -ne 0)
{
  F:\Dev\other\Play_Sound.exe
} 

Set-Location F:\Dev\Projects\PSBC\x86;

