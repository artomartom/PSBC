$ProjectName=  $args[0] 
$BuildConfig=  $args[1] 

 # F:\Dev\Projects\$ProjectName\build\x64\$BuildConfig\; 
 
 
Get-ChildItem -Path F:\Dev\Projects\$ProjectName\build\x64\  -Include *.* -File -Recurse | foreach { $_.Delete()}


 

 