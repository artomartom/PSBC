$ProjectName=  $args[0] 
$BuildConfig=  $args[1] 

 
  $Path = "F:/Dev/Projects/$ProjectName/build/x64/$BuildConfig/$ProjectName.exe" ;
 
 
#write-host $Path
F:\Dev\Projects\Run_Process\build\x64\Release\Run_Process.exe "F:/Dev/Projects/$ProjectName/build/x64/$BuildConfig/$ProjectName.exe" 
 
 
 

if( $LASTEXITCODE -ne 0)
{
F:/Dev/Projects/PSBC/G_MSVS/Play_Sound.exe
} 

