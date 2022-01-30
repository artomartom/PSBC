$ProjectName=  $args[0] 
$BuildConfig=  $args[1] 

 
 

 
#write-host  "$ProjectName.exe"

& "F:/Dev/Projects/$ProjectName/build/x64/$BuildConfig/$ProjectName.exe"  ;
if( $LASTEXITCODE -ne 0)
{
 #F:/Dev/Projects/PSBC/G_MSVS/Play_Sound.exe
} 

