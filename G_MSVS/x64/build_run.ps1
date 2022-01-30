
$ProjectName=  $args[0]
$BuildConfig=  $args[1]

build.ps1 $ProjectName $BuildConfig 

if($LASTEXITCODE-eq 80082 )
  {
    run.ps1 $ProjectName $BuildConfig
  } 
else
  {
    write-host $LASTEXITCODE
  }
 
 
