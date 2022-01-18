$ProjectName=  $args[0]
$BuildConfig=  $args[1]
cmake --build F:\Dev\Projects\$ProjectName\build\x64   --config $BuildConfig

if( $LASTEXITCODE -ne 0)
{
  F:\Dev\other\Play_Sound.exe
} 