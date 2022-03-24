@{   RootModule      = 'CodeModule.psm1'
   FunctionsToExport = @(
      'GetProj',
      'SetProj',
      'NewProj',
      'MakeProj',
      'BuildProj',
      'RunProj',
      'ClearBuild',
      'Compile-hlslFile',
      'EnableDebugFlags'
   )
   AliasesToExport   = @('')  
   VariablesToExport = @('')
  
}

function Log `
{
   param(
      [string] $Text = $(Get-Date -format 'HH:mm:ss' ),
      [string] $Col = 'Cyan'
   )
   write-host   -ForegroundColor  $Col -Object $Text
}
<#____________________________________________________Projects________________________________________________________#>


function GoToProj `
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
function GetProj `
{  
   Log -Text 'Session Initialized with:'
   $global:CurrentProj   
   #Log -Text "Session Initialized with: $($global:CurrentProj.Name) $($global:CurrentProj.Config) $($global:CurrentProj.Arch)"     
} 
function SetProj `
{
   param(
      [string]$Project = $global:CurrentProj.Name ,
      [ValidateSet('Debug', 'Release')][string]$Config = $global:CurrentProj.Config ,
      [ValidateSet( 'x64', 'x86')][string]$Arch = $global:CurrentProj.Arch 
   )

   $global:CurrentProj = [PSCustomObject]@{
      PSTypeName = 'ProjectInfo'
      Name       = $Project
      Config     = $Config
      Arch       = $Arch 
   } 
   GoToProj;
   GetProj; 
}
function NewProj `
{   
   param ([Parameter(Mandatory = $true)][string] $Name)
   $NewDir = "$($env:Proj)//$($Name)"; 
   New-Item -Path $NewDir -ItemType Directory;
   git clone https://github.com/artomartom/Hello_World.git    $NewDir;
   GoToProj $Name;
   New-Item -Path "$($NewDir)/Build" -ItemType Directory;
   New-Item -Path "$($NewDir)/Build/x64" -ItemType Directory;
   New-Item -Path "$($NewDir)/Build/x86" -ItemType Directory;
   Remove-Item -Path "$($NewDir)/.git" -Recurse -Force;
   
}
 


<#____________________________________________________Build________________________________________________________#>

function MakeProj `
{
   cmake -S "$($env:Proj)\$($global:CurrentProj.Name)/source" -B "F:\Dev\Projects\$($global:CurrentProj.Name)/build/$($global:CurrentProj.Arch)"  `
      -G"Visual Studio 17 2022"  -T host=x64 -A $($global:CurrentProj.Arch)  
   if ( $LASTEXITCODE -ne 0) { F:\Dev\Projects\PowerShell\CodeModule\util\Play_Sound.exe } ;
}
function BuildProj `
{
   param(
      [switch]$AndRun = $false,
      [string]$ProjectName = $global:CurrentProj.Name ,
      [string]$BuildConfig = $global:CurrentProj.Config 
   )
  
   Log 'build started' -Col Green  ;

   $StartTime = $(Get-Date -format 'HH:mm:ss' )   ;
   cmake --build "$($env:Proj)\$($ProjectName)\build\x64" --config "$($BuildConfig)" ;
   
    
   if ([System.IO.File]::Exists($PostBuild )) { & "$($env:Proj)/$($ProjectName)/PostBuild.ps1" };
    
   
   if ($LASTEXITCODE -ne 0) `
   {
      & "$($env:Proj)\PowerShell\CodeModule\util\Play_Sound.exe"  ; 
   
      [pscustomobject]@{
         Status     = 'Error'
         ProjName   = $($ProjectName)
         ProjConfig = $($BuildConfig)
      } ;
   }
   else `
   {
      [pscustomobject]@{
         Status     = 'build succeeded'
         ProjName   = $($ProjectName)
         ProjConfig = $($BuildConfig)
         StartTime  = "$($StartTime )"
         EndTime    = "$(Get-Date -format 'HH:mm:ss' )"
      } ;
      
      if ($AndRun) { & "$($env:Proj)//$($ProjectName)/build/x64/$($BuildConfig)/$($ProjectName).exe"  ; }

   };
      
  

   
} 
 

function RunProj `
{    
   param( 
      [ValidateSet('default', 'ChildProcess')]   [string]$Mode     ) 
        
   $exe = "$($env:Proj)//$($global:CurrentProj.Name)/build/x64/$($global:CurrentProj.Config)/$($global:CurrentProj.Name).exe" ;
   switch ($Mode) {
      'ChildProcess' { & F:\Dev\Projects\PowerShell\CodeModule\util/Run_Process.exe "$exe" }
      Default { & $exe  ; }
   }
   
}
 
function ClearBuild `
{ 
   param(
      [string] $ProjectName = $global:CurrentProj.Name ,
      [string] $BuildConfig = $global:CurrentProj.Config
   ) 
   Get-ChildItem -Path F:\Dev\Projects\$ProjectName\build\x64\  -File   -Recurse | ForEach-Object { $_.Delete() }
      
}
<#____________________________________________________Shaders________________________________________________________#>
function Compile-hlslFile {
     
   param( 
      [Parameter(Mandatory = $true)]      [string] $Name  ,
      [Parameter(Mandatory = $true)]      [ValidateSet('Debug', 'Release')][string] $Config  ,
      [Parameter(Mandatory = $true)]                                      [string] $OutName ,
      [Parameter(Mandatory = $true)]      [ValidateSet('so', 'hpp')]      [string] $OutType ,
      [Parameter(Mandatory = $true)]      [string] $EntryPoint ,
      [Parameter(Mandatory = $true)]      [ValidateSet(
         'cs_4_0', 'cs_4_1', 'cs_5_0', 'cs_5_1' ,
         'ds_5_0', 'ds_5_1' ,
         'gs_4_0', 'gs_4_1', 'gs_5_0', 'gs_5_1' ,
         'hs_5_0' , 'hs_5_1' ,
         'lib_4_0', 'lib_4_1',
         'lib_4_0_level_9_1',
         'lib_4_0_level_9_1_vs_only', 'lib_4_0_level_9_1_ps_only',
         'lib_4_0_level_9_3', 'lib_4_0_level_9_3_vs_only',
         'lib_4_0_level_9_3_ps_only',
         'lib_5_0' ,
         'ps_2_0' , 'ps_2_a', 'ps_2_b', 'ps_2_sw', 'ps_3_0', 'ps_3_sw', 'ps_4_0',
         'ps_4_0_level_9_1', 'ps_4_0_level_9_3', 'ps_4_0_level_9_0' ,
         'ps_4_1', 'ps_5_0', 'ps_5_1',
         'rootsig_1_0', 'rootsig_1_1',
         'tx_1_0' ,
         'vs_1_1', 'vs_2_0', 'vs_2_a', 'vs_2_sw', 'vs_3_0', 'vs_3_sw', 'vs_4_0',
         'vs_4_0_level_9_1', 'vs_4_0_level_9_3', 'vs_4_0_level_9_0',
         'vs_4_1', 'vs_5_0', 'vs_5_1' )]      [string] $Profile  ,
      [string]  $In ,
      [string]  $Out  
   )

   $exe = 'C://Program Files (x86)//Windows Kits//10//bin//10.0.22000.0//x64//fxc.exe';                
   switch ($Config) {
      'Debug' { $Params = @("/E$($EntryPoint)", '/nologo', "/T$( $Profile)", '/O0', '/WX', '/Zi', '/Zss', '/all_resources_bound' ) }
      'Release' { $Params = @("/E$($EntryPoint)", '/nologo', "/T$( $Profile)", '/O3', '/WX' ) }
   };
         
   switch ($OutType) {
      'so' { $Params += '/Fo'; }
      'hpp' { $Params += "/Vn$($EntryPoint)" ; $Params += '/Fh'; }
   };   
  
   $paths =
   @(
      "$out//$($OutName).$OutType" ,
      "$In//$Name.hlsl"     
   );                                                                            
   & $exe  $Params    $paths  ;
   #Write-Host $Params $paths
};
 
<#____________________________________________________Debug________________________________________________________#>
 
 
function EnableDebugFlags { gflags /i "$($global:CurrentProj.Name).exe"  +sls ; }



 





   
















   
   
   
      




   

   




   
   
   
      



   
   
   



#>
 
 



#Get-Content -Path C:\Test\computers.txt | Get-ConnectionStatus 
#may be used to read  project state from file 