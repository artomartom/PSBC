
function Log {
   param(
      [string] $Text = $(Get-Date -format 'HH:mm:ss' ),
      [string] $Col = 'Cyan'
   )
   write-host   -ForegroundColor  $Col -Object $Text
}

 
function Get-Project {  
   
   Import-CliXml  $HOME/.PS; 
} 

function Restore-Session {  
    
   $Data = Get-Project ; 
   Set-Project -Path $Data.Path   -Config  $Data.Config  -Arch $Data.Arch;
} 
 

function Select-Project {  
    
   Set-Location $(Get-Project).Path;
} 

 
function Set-Project {
   param(
      [Parameter(Mandatory = $true,
         Position = 0,
         ParameterSetName = 'Path',
         ValueFromPipelineByPropertyName = $true,
         HelpMessage = 'Path to one project root directory')]
      [ValidateNotNullOrEmpty()]
      [SupportsWildcards()]
      [string[]]
      $Path,

      [ValidateSet('Debug', 'Release')]
      [string]
      $Config = 'Debug',

      [ValidateSet( 'x64', 'x86')]
      [string]
      $Arch = 'x64'
   )
   $FullPath = Resolve-Path $Path;
   
 
   if (( Test-Path    $FullPath -PathType  Container ) -eq $false) {
      return Write-Error  "Path $($FullPath) does not exist";
   };
   
   [PSCustomObject]@{
      PSTypeName = 'ProjectData'
      Path       = $FullPath  
      Config     = $Config
      Arch       = $Arch 
   }  | Export-Clixml -Path $HOME/.PS ;
 
    
} 
 

function New-Project {   
   param (
      [Parameter(Mandatory = $true)]
      [string] 
      $Path 
   )

   $NewDir = Split-Path $Path -leaf;
   $Path = Split-Path $Path  ;

   if (!Test-Path   $Path -PathType  Container) {
      return Write-Error  "Path $($Path) does not exist";
   }
   Set-Project -Path  $Path -Name $NewDir  -Config 'Debug' -Arch 'x64';
   
   New-Item -Path $Path -ItemType Directory;
   git clone https://github.com/artomartom/Hello_World.git     $Path;

   if ($LASTEXITCODE -ne 0 ) { return ; };

   New-Item -Path "$($Path)/Build" -ItemType Directory;
   Set-Location $Path;
   Remove-Item -Path "$($Path)/.git" -Recurse -Force;
   Remove-Item -Path "$($Path)/.gitmodules"  -Force;
   Remove-Item -Path "$($Path)/Source/Hello"  -Force;

   $Cmake = 'Source/CMakeLists.txt';
   $Content = (Get-Content   $Cmake -Raw);
   $Content.Replace('Hello_World', $NewDir) | Set-Content  $Cmake;
   
   git init;
   
   git submodule  add https://github.com/artomartom/Hello.git Source/Hello;
   
   if ($LASTEXITCODE -eq 0 ) `
   {
      Set-Location  ./Source/Hello;
      git branch -u origin/main main;
      
   };
   
   git add .  ;
   git commit -m 'init' ;
    
}
 
function Invoke-Cmake {
   param(
      [Parameter(Mandatory = $true)] 
      [ValidateNotNullOrEmpty()]
      [string]
      $Path,
      [Parameter(Mandatory = $true)] 
      [ValidateNotNullOrEmpty()]
      [string]
      $Arch   
   )

   if (!Test-Path $Path) { return -1; };
   
   switch ($Arch) `
   {
      'x86' { $MSBuildArchName = 'win32' }
      'x64' { $MSBuildArchName = 'x64' }
      Default { Log -Col Red -Text "Invalid input parameter 'Arch' $($Arch)"; return -1; }
   }

   
   Log "$($ProjectName) : Running Cmake" -Col Green  ;
   
   $output = cmake -S "$($Path)/Source" -B "$($Path)/Build/"  `
      -G"Visual Studio 17 2022"  -T host=x64 -A $( $MSBuildArchName);

   if ( $LASTEXITCODE -ne 0) `
   {
      
      [pscustomobject]@{
         Name         = $($ProjectName)
         Architecture = $($Arch )
      };

      Log -Col Red -Text $output ;
      
   } ;
   
   return $LASTEXITCODE ;
}
   
function Build-Project {
   param(
      [switch]
      $AndRun = $false,
      [switch]
      $Make = $false,
      [string[]]
      $Before,
      [string[]]
      $After 
   )

   $ProjectName = Get-Project;
   
   foreach ($string in $Before) {
      & $($string)
      if (0 -ne $LASTEXITCODE ) { return; } ;
   };
      
   if ($Make) {
    
      if (0 -ne (Invoke-Cmake -ProjectName  $ProjectName -Arch   $global:CurrentProj.Arch) ) `
      {
         return ;
      };   
    
   };

   Log "$($ProjectName) : build started" -Col Green  ;

   $StartTime = $(Get-Date -format 'HH:mm:ss' )   ;
   cmake --build "$($ProjectName.RootDir)//$($ProjectName.Name)\build" --config "$($BuildConfig)" ;
    
    
   $Status ;
   if ($LASTEXITCODE -ne 0) {
      $Status = 'Error';
   
   }
   else {
      $Status = 'build succeeded';
      
      foreach ($string in $After) {
         & $($string) ;
         if (0 -ne $LASTEXITCODE ) { return; } ;
      };   
   };

   
   [pscustomobject]@{
      Status     = $($Status)
      ProjName   = $($ProjectName)
      ProjConfig = $($BuildConfig)
      StartTime  = "$($StartTime )"
      EndTime    = "$(Get-Date -format 'HH:mm:ss' )"
   } ;

      
   if (($LASTEXITCODE -eq 0) -and $AndRun) { Invoke-Project  ; }

} 

function Invoke-Project {    
   $Project = Get-Project;
   & "$($Project.RootDir)//$($Project.Name)/build/$($Project.Config)/$($Project.Name).exe" ;
}
 
function Clear-BuildDir { 
  
   $Project = Get-Project;
   Get-ChildItem -Path "$($Project.RootDir)//$($Project.Name)\build\"  -File   -Recurse | ForEach-Object { $_.Delete() }
      
}
<#____________________________________________________Shaders________________________________________________________#>
function Invoke-fxcCompiler {
     
   param( 
      [Parameter(Mandatory = $true)]
      [string] 
      $Name,
      [Parameter(Mandatory = $true)][ValidateSet('Debug', 'Release')]
      [string] 
      $Config,
      [Parameter(Mandatory = $true)]
      [string] 
      $OutName ,
      [Parameter(Mandatory = $true)][ValidateSet('so', 'hpp')]
      [string] 
      $OutType,
      [Parameter(Mandatory = $true)]
      [string] 
      $EntryPoint ,
      [string]
      $VarName = $EntryPoint,
      [Parameter(Mandatory = $true)]     
      [ValidateSet(
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
         'vs_4_1', 'vs_5_0', 'vs_5_1' )][string] $Profile,
      [string] 
      $In,
      [string] 
      $Out  
   )
   $exe = 'C://Program Files (x86)//Windows Kits//10//bin//10.0.22000.0//x64//fxc.exe';                

   switch ($Config) {
      'Debug' { $Params = @("/E$($EntryPoint)", '/nologo', "/T$( $Profile)", '/O0', '/WX', '/Zi', '/Zss', '/all_resources_bound' ) }
      'Release' { $Params = @("/E$($EntryPoint)", '/nologo', "/T$( $Profile)", '/Vd', '/O3', '/WX' ) }
   };
   
   switch ($OutType) {
      'so' { $Params += '/Fo'; }
      'hpp' { $Params += "/Vn$($VarName)" ; $Params += '/Fh'; }
   };   
   
   $paths =
   @(
      "$out//$($OutName).$OutType" ,
      "$In//$Name.hlsl"     
   );                                                                            
   $captureOutString = & $exe  $Params    $paths  ;
   #Write-Host $Params $paths

   if ($LASTEXITCODE -eq 0) {
      Log -Text "Shader $($($EntryPoint))/$($Name).hlsl: build succeeded" -Col  Green   
   }
   else {
      Log -Text $captureOutString -Col  Red   
   };
};
 
function  git_log_but_cooler { git log --graph --decorate --oneline; };
 
function Enable-DebugFlags { gflags /i "$($Project.Path).exe"  +sls ; }


  