
$ProjectName=  $args[0]
$BuildConfig=  $args[1]
cmake --build F:\Dev\Projects\$ProjectName\build/x86   --config $BuildConfig
if( $LASTEXITCODE -eq 0)
{
 F:\Dev\Projects\PSBC\x86\run.ps1 $ProjectName $BuildConfig
}else {
  F:\Dev\other\Play_Sound.exe
}
