$ProjectName=  $args[0]

cmake -S ../../$ProjectName/source -B ../../$ProjectName/build/x86 -G"Visual Studio 16 2019" -T host=x86 -A win32

if( $LASTEXITCODE -ne 0)
{
  F:\Dev\other\Play_Sound.exe
} 
