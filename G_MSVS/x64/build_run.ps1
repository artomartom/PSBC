
$ProjectName=  $args[0]
$BuildConfig=  $args[1]
cmake --build F:\Dev\Projects\$ProjectName\build/x64   --config $BuildConfig
if( $LASTEXITCODE -eq 0)
{
  run.ps1 $ProjectName $BuildConfig
}else {
  F:\Dev\other\Play_Sound.exe
}
