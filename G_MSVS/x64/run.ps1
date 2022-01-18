$ProjectName=  $args[0] 
$BuildConfig=  $args[1] 

 
 

 
& "F:/Dev/Projects/$ProjectName/build/x64/$BuildConfig/$ProjectName.exe"  ;
#write-host  "$ProjectName.exe"

if( $LASTEXITCODE -ne 0)
{
  F:/Dev/other/Play_Sound.exe
} 


 