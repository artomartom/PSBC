$ProjectName=  $args[0]
$BuildConfig=  $args[1]
cmake --build F:\Dev\Projects\$ProjectName\build\x64   --config $BuildConfig


if( $LASTEXITCODE -ne 0)
{
  write-host (  "$ProjectName : build  filed") -ForegroundColor DarkRed;
  F:/Dev/Projects/PSBC/G_MSVS/Play_Sound.exe;
} else
{
exit 80082

}

 