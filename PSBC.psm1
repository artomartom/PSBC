

 

Class Serializer {

   static hidden [void]  Export([Project]$Object  ) {
      if ((Test-Path $Object.Path) -eq $true) {
         $Object | Export-Clixml "$($Object.Path).PSBC";
      }
      else {
         Write-Error 'Export: Object path failed test';
      }
   }

   static hidden [Project] Import(   [string]$Path ) {
    
      #if path exists resolve it and check if it conteins the file 
      if ((Test-Path $Path) -eq $true) {

         $Path = Resolve-Path $Path;

         Get-ChildItem  $Path -Filter '.PSBC' | Where-Object { 
            $deserializedProject = Import-CliXml "$($Path)//.PSBC";
            
            #if file is of type Project return it 
            if ([type]$deserializedProject.ToString() -eq [Project]) {
               return $deserializedProject;
            }
         }
      }
      return $null;

   }
}



Class Project {
   #  ctr

   <#
   called from a cmdlet 
   $Path is always current path
   #>
   Project( [string]$Path   ) {  

      [Project]$Proj = [Serializer]::Import($Path);
      if ($null -ne $Proj   ) {
         $this.[Project]::new($Proj); #move  
      }
      
      $this.[Project]::new();
   }

   <# move ctr   #>
   Project( [Project]$Other   ) {  
      $this.Path = $Other.Path;
      $this.Name = $Other.Name;
      $this.Config = $Other.Config;
      $this.Arch = $Other.Arch;
      $this.Before = $Other.Before;
      $this.After = $Other.After;
      $this.guid = $Other.guid;
      
      $Other.Path = $null;
      $Other.Name = $null;
      $Other.Config = $null;
      $Other.Arch = $null;
      $Other.Before = $null;
      $Other.After = $null;
      $Other.guid = $null;
   
   }

   <#gets internally  call if any other constuctor fails to find project file. 
   It creates a new project file in current directory 
   #>
   hidden Project(    ) {  
      $this.Path = Resolve-Path './';
      $this.Name = 'Unknown';
      $this.SetConfigDebug();
      $this.SetArch('x64');
      $this.NewGuid();
      [Serializer]::ExportProject($this);
   }
   # methods :

   #set methods

   [void] SetConfig( [string]$Config   ) {

      switch ($Config) {
         'Debug' { $this.Config = 'Debug'; }
         'Release' { $this.Config = 'Release'; }
         Default { Write-Error "Unknown config $($Config), operation interrupted"; }
      };
     
   }
   [void] SetConfigDebug(    ) {
      $this.SetConfig('Debug');
   }

   [void] SetConfigRelease(    ) {
      $this.SetConfig('Release');
   }

   [void] SetName(   [string]$NewName ) {
      $this.Name = $NewName; 
       
   }

   [void] SetArch(  [string]$NewArch  ) {
      $this.Arch = $NewArch; 
    
   }
  
   [void] NewGuid() {
      $this.guid = New-Guid;
   }


 
   #build methods
   [int] Before() {
      foreach ($string in $this.Before) {
         & $($string)
         if (0 -ne $LASTEXITCODE ) { return 0; } ;
      };
      return 1;
   }
   
   [int] After() {
      foreach ($string in $this.After) {
         & $($string)
         if (0 -ne $LASTEXITCODE ) { return 0; } ;
      };
      return 1;
   }

   [int] Make( ) {
      $MSBuildArchName = '';
      switch ($this.Arch) {
         'x86' { $MSBuildArchName = 'win32' }
         'x64' { $MSBuildArchName = 'x64' }
         Default { Write-Error "Invalid input parameter 'Arch' $($this.Arch)"; return -1; }
      }
        
      write-host "$($this.Name) : Running Cmake" -ForegroundColor Green  ;
        
      $output = cmake -S "$($this.Path)/Source" -B "$($this.Path)/Build/"  
      -G"Visual Studio 17 2022"  -T host=x64 -A $( $MSBuildArchName);
     
      if ( $LASTEXITCODE -ne 0) {
           
         [pscustomobject]@{
            Name         = $($this.Name)
            Architecture = $($this.Arch )
         };
         Write-Error  $output ;
      };
        
      return $LASTEXITCODE ;
   }
  
   [void] Build(    ) {

      Write-Host "$($this.Name) : build started" -ForegroundColor Green  ;
      $StartTime = $(Get-Date -format 'HH:mm:ss' )   ;
      cmake --build "$($this.Path)//Build" --config "$($this.Config)" ;
      $Status = '';
      if ($LASTEXITCODE -ne 0) {
         $Status = 'Error';
      }
      else {
         $Status = 'build succeeded';
      };
      [pscustomobject]@{
         Status     = $($Status)
         ProjName   = $this.Name  
         ProjConfig = $($this.Config)
         StartTime  = "$($StartTime)"
         EndTime    = "$(Get-Date -format 'HH:mm:ss' )"
      };
   }

   [void] Run( ) {
      & "$($this.Path)//Build//$($this.Config)//$($this.Name).exe" ;
   }
   
   #  members:
   <# 
   Absolute path to the project's root directory.
   Root directory contains one .PSBC ("$($this.Path)//.PSBC") file storing serizlized Project object
   leaf of path allowed to be equal to Project::Name member, but not restricted to be the same.
   #>
   [String]$Private:Path;

   <# project name / target name (projects producing anything besides one .exe file are no supported for now)
   #>
   [String]$Private:Name;
   
   <# project's configuration 
   TODO: add strong typization to this member, different build options support   
   #>
   [String]$Private:Config;

   <# project's architecture
   don't see much sense to add anything here, it just exists as a member for now   
   #>
   [String]$Private:Arch;

   <#  array of path to invokable files to execute before starting project::build method  #>
   [String]$Private:Before;

   <#      same as $before, but after,u get it lol    #>
   [String]$Private:After;

   [GUID]$Private:guid;

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
   
   New-Item -Path $Path -ItemType Directory;
   Set-Project -Path  $NewDir    -Config 'Debug' -Arch 'x64';
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
   
   if ($LASTEXITCODE -eq 0 ) {
      Set-Location  ./Source/Hello;
      git branch -u origin/main main;
      
   };
   
   git add .  ;
   git commit -m 'init' ;
    
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
      Write-Host   "Shader $($($EntryPoint))/$($Name).hlsl: build succeeded" -ForegroundColor  Green;
   }
   else {
      Write-Error   $captureOutString;
   };
};
 
function  git_log_but_cooler { git log --graph --decorate --oneline; };
 
function Enable-DebugFlags { gflags /i "$($Project.Path).exe"  +sls ; }


#new-project create a complitely new proj, if doesn't exist at path (pull from git )
#