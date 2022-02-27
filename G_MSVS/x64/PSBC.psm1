function Log `
{
   param(
      [string] $Text = $(Get-Date -format 'HH:mm:ss' ),
      [string] $Col = 'Cyan'
   )
   write-host  $Text  $Col 
}
function Get-Proj `
{
   Log -Text 'Session Initialized with:    ' `
      "$($global:CurrentProj.Name) $($global:CurrentProj.Config) $($global:CurrentProj.Arch)"     
}
function Set-Proj `
{
   param(
      [Parameter(Mandatory = $true)][string]$Project  ,
      [Parameter(Mandatory = $true)][string]$Config  ,
      [Parameter(Mandatory = $true)][string]$Arch  
   )

   $global:CurrentProj = [PSCustomObject]@{
      PSTypeName = 'ProjectInfo'
      Name       = $Project
      Config     = $Config
      Arch       = $Arch 
   } 
   Get-Proj; 
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
function Make-Proj `
{
   cmake -S "F:\Dev\Projects\$($global:CurrentProj.Name)/source" -B "F:\Dev\Projects\$($global:CurrentProj.Name)/build/x64"  `
      -G"Visual Studio 17 2022"  -T host=x64 -A $($global:CurrentProj.Arch)  
   if ( $LASTEXITCODE -ne 0) { F:\Dev\other\Play_Sound.exe } ;
}
function Build-Proj `
{
   param(
      [string]$ProjectName = $global:CurrentProj.Name ,
      [string]$BuildConfig = $global:CurrentProj.Config
   )
   if (($ProjectName -eq 'q') -or ($BuildConfig -eq 'q' )  ) {  return; };
   cmake --build "F:\Dev\Projects\$($ProjectName)\build\x64" --config "$($BuildConfig)" ;
   if ($LASTEXITCODE -ne 0) { F:/Dev/Projects/PSBC/G_MSVS/Play_Sound.exe ;   } else { Log 'build succeeded' ; };
} 
function BuildRun-Proj `
{ 
   Build-Proj ;
   Run-Proj   ;   
}
function Run-Proj `
{  
   param(  [ValidateSet('default', '', ' ', 'ChildProcess')]   [string]$Mode     ) 
   $exe = "F:/Dev/Projects/$($global:CurrentProj.Name)/build/x64/$($global:CurrentProj.Config)/$($global:CurrentProj.Name).exe" ;
   switch ($Mode) {
      'ChildProcess' { & F:\Dev\Projects\Run_Process\build\x64\Release\Run_Process.exe "$exe" }
      Default { & $exe  ; }
   }
}
function init-Git `
{
   Log ' lol'
   
}
function Update-Git `
{
   param(
      [string] $Message = $args[0]
   ) 
   git add . ; git commit -m $Message; git push; 
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
      [Parameter(Mandatory = $true)][ValidateSet('debug', 'release')][string] $Config  ,   
      [Parameter(Mandatory = $true)][ValidateSet('vso', 'hpp')]      [string] $OutType  ,
                                                                     [string] $SourcePath `
      ="$($env:Proj)//$($global:CurrentProj.Name)//source//shader//source"
   )
   & 'F:\Dev\Projects\PSBC\G_MSVS\x64\Compile-Shader.ps1'   $Config      $OutType     $SourcePath ;
}


 
 
