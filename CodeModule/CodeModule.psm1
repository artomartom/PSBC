function Log `
{
   param(
      [string] $Text = $(Get-Date -format 'HH:mm:ss' ),
      [string] $Col = 'Cyan'
   )
   write-host   -ForegroundColor  $Col -Object $Text
}
function Show-Proj `
{
   Log -Text "Session Initialized with: $($global:CurrentProj.Name) $($global:CurrentProj.Config) $($global:CurrentProj.Arch)"     
}
function GoTo-Proj `
{
   param(
      [string]$Project = $global:CurrentProj.Name,
      [ValidateSet('Root', 'Build')][string]$Section = 'Root'   , 
      [string]$Config = $global:CurrentProj.Config
   ) 
   switch ($Section) {
      'Build' { Set-Location "$env:Proj//$($Project)//build//$($global:CurrentProj.Arch)//$($Config)" }
      Default { Set-Location "$env:Proj//$($Project)" }
   }
   $global:CurrentProj.Name = $Project;
}
function Change-Proj `
{
   param(
      [string]$Project  ,
      [ValidateSet('debug', 'release')][string]$Config  ,
      [ValidateSet( 'x64', 'x86')][string]$Arch  
   )

   $global:CurrentProj = [PSCustomObject]@{
      PSTypeName = 'ProjectInfo'
      Name       = $Project
      Config     = $Config
      Arch       = $Arch 
   } 
   GoTo-Proj;
   Show-Proj; 
} 
function Make-Proj `
{
   cmake -S "F:\Dev\Projects\$($global:CurrentProj.Name)/source" -B "F:\Dev\Projects\$($global:CurrentProj.Name)/build/x64"  `
      -G"Visual Studio 17 2022"  -T host=x64 -A $($global:CurrentProj.Arch)  
   if ( $LASTEXITCODE -ne 0) { F:\Dev\Projects\PowerShell\CodeModule\util\Play_Sound.exe } ;
}
function Build-Proj `
{
   param(
      [string]$ProjectName = $global:CurrentProj.Name ,
      [string]$BuildConfig = $global:CurrentProj.Config
   )
   if (($ProjectName -eq 'q') -or ($BuildConfig -eq 'q' )  ) { return; };
   cmake --build "F:\Dev\Projects\$($ProjectName)\build\x64" --config "$($BuildConfig)" ;

   $PostBuild ="$($env:Proj)/$($ProjectName)/PostBuild.ps1";
   if([System.IO.File]::Exists($PostBuild ))  {& $PostBuild };


   if ($LASTEXITCODE -ne 0) { F:\Dev\Projects\PowerShell\CodeModule\util\Play_Sound.exe ; } else { Log 'build succeeded' ; };
} 
function BuildRun-Proj `
{ 
   Build-Proj ;
   Run-Proj   ;   
}
function Enable-DebugFlags {
   gflags /i "$($global:CurrentProj.Name).exe"  +sls ;
}
function Run-Proj `
{  
   param(  [ValidateSet('default', '', ' ', 'ChildProcess')]   [string]$Mode     ) 
   $exe = "$($env:Proj)//$($global:CurrentProj.Name)/build/x64/$($global:CurrentProj.Config)/$($global:CurrentProj.Name).exe" ;
   switch ($Mode) {
      'ChildProcess' { & F:\Dev\Projects\PowerShell\CodeModule\util/Run_Process.exe "$exe" }
      Default { & $exe  ; }
   }
}
function Init-Proj `
{
   #param ([string] $Name)
   #$NewDir = "$($env:Proj)//$($Name)"; 
   #New-Item $NewDir
   #git clone `````
   

    
}
function Init-Git `
{
   $pat =Get-Location;
   Set-Location "$($env:Proj)//$($global:CurrentProj.Name)//"
   git init $pat;

   git add . ;
   git commit -m "Init"; 
   git push --set-upstream origin master;
}

function Update-Git `
{
   param( [string] $Message ) 
   $pat = Get-Location ;
   Set-Location "$($env:Proj)//$($global:CurrentProj.Name)" ;
   git add .  ;
   git commit -m $Message; 
   git push; 
   git gc ;
   Set-Location $pat;
} 
 
function Show-GitCommands {  
   git help '-a'
}

 

function Clear-Build `
{ 
   param(
      [string] $ProjectName = $global:CurrentProj.Name ,
      [string] $BuildConfig = $global:CurrentProj.Config
   ) 
   Get-ChildItem -Path F:\Dev\Projects\$ProjectName\build\x64\  -File   -Recurse | ForEach-Object { $_.Delete() }
      
}
function Compile-Shader `
{  
   param(
      [ValidateSet('debug', 'release')][string] $Config = $global:CurrentProj.Config,   
      [ValidateSet('vso', 'hpp')]      [string] $OutType = 'vso' ,
      [string] $SourcePath `
         = "$($env:Proj)//$($global:CurrentProj.Name)//source//shader//source"
   )
   & 'F:\Dev\Projects\PSBC\G_MSVS\x64\Compile-Shader.ps1'   $Config      $OutType     $SourcePath ;
}


 
 
