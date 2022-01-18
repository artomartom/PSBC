$ProjectName=  $args[0]

cmake -S ../../$ProjectName/source -B ../../$ProjectName/buildMSVS/x86  -T host=x86 -A win32

if( $LASTEXITCODE -ne 0)
{
  F:\Dev\other\Play_Sound.exe
} 
