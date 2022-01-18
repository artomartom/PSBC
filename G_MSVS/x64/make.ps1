$ProjectName=  $args[0]
#$compiler="F:/MicrosoftVisualStudio/2019/Community/VC/Tools/MSVC/14.29.30133/bin/Hostx64/x64/cl.exe"; 
cmake -S F:\Dev\Projects\$ProjectName/source -B F:\Dev\Projects\$ProjectName/build/x64 -G"Visual Studio 17 2022"  -T host=x64 -A x64  

if( $LASTEXITCODE -ne 0)
{
  F:\Dev\other\Play_Sound.exe
} 
 
 