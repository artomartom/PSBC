

 

Class Serializer {

    static hidden [bool]  Move([Project]$Object, [string]$NewPath  ) {
        return $false;
    }

    static hidden [bool]  Export([Project]$Object  ) {
        if ((Test-Path $Object.Path) -eq $true) {

            

            Write-Debug "$($Object.Path): Exporting"
            $Object | Export-Clixml "$($Object.Path)//.PSBC";
            return $true;
        }
        else {
            Write-Error 'Export: Object path failed test';
            return $false;
        }
    }

    static hidden [Project] Import(   [string]$Path ) {
    
        [Project] $deserializedProject = $null;
        #if path exists resolve it and check if it conteins the file 
        if ((Test-Path $Path) -eq $true) {
            #Write-Debug 'test-path succ'
            $Path = Resolve-Path $Path;

            Get-ChildItem  $Path -Filter '.PSBC' | Where-Object { 
                $deserializedProject = Import-CliXml "$($Path)//.PSBC";
                #Write-Debug 'importing...'
                #if deserialized is not same type don't return it, return #null
                if ([type]$deserializedProject.ToString() -ne [Project]) {
                    $deserializedProject = $null;
                }
            }
        }
        return $deserializedProject;

    }
}



Class Project {
    
    # ctr
    
    hidden Project(    ) {  

        $this.Path = Resolve-Path './';
        $this.Name = 'NewProject';
        $this.Config = 'Debug';
        $this.Arch = 'X64';
        $this.PreBuildEvent = $null;
        $this.PostBuildEvent = $null;
    }
     
    hidden [void] Move( [Project]$Other   ) {
        $this.Path = $Other.Path;
        $this.Name = $Other.Name;
        $this.Config = $Other.Config;
        $this.Arch = $Other.Arch;
        $this.PreBuildEvent = $Other.PreBuildEvent;
        $this.PostBuildEvent = $Other.PostBuildEvent;
    }

    # methods :
    #set methods 
    [void] SetPath( [string]$NewPath   ) {
        $IsValidPath = Test-Path $NewPath -PathType  Container;
        if ($IsValidPath -ne $false) {
            $this.Path = Resolve-Path  $NewPath;
            #TODO:serializer moves PSBC file 
        }
        else {
            Write-Error "Can't set new path $($NewPath): it doesn't exist";
            #TODO: create new directory if it doesn't exist and make it this error an option 
        }
    }

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

    [void] SetName([string]$NewName ) {
        if ((test-path $NewName -IsValid) -eq $true) {
            $this.Name = $NewName; 
            [Serializer]::Export($this);
        }
        else {
            Write-Error "Invalid Name $($NewName)";
        };
    }

    [void] SetArch(  [string]$NewArch  ) {
        $this.Arch = $NewArch; 
    }   
        
    #get methods
    [string] GetPath( ) {
        return $this.Path;
    }

    [string] GetConfig ( ) {
        return $this.Config;
    }

    [string] GetName(  ) {
        return $this.Name; 
    }

    [string] GetArch(   ) {
        return $this.Arch; 
    }   
    
    #  members:
    <# 
    Absolute path to the project's root directory.
            Root directory contains one .PSBC ("$($this.Path)//.PSBC") file storing serizlized Project object
            leaf of path allowed, but not restricted, to be equal to Project::Name member.
    #>
    [String]$Private:Path = $null;
    [String]$Private:BuildDir = 'not implemented';
    [String]$Private:SourceDir = 'not implemented';
 
    <# project name / target name (projects producing anything besides one .exe file are no supported for now)
    #>
    [String]$Private:Name = $null;
    
    <# project's configuration 
    TODO: add strong typization to this member, different build options support   
    #>
    [String]$Private:Config = $null;
 
    <# project's architecture
    don't see much sense to add anything here, it just exists as a member for now   
    #>
    [String]$Private:Arch = $null;
 
    <#  array of path to invokable files to execute before starting project::build method  #>
    [String[]]$Private:PreBuildEvent = $null;
 
    <#      same as $PreBuildEvent, but PostBuildEvent,u get it lol    #>
    [String[]]$Private:PostBuildEvent = $null; 

    [String]$Private:ToolChain = $null; 

}

 
function  Get-Project { 
    [CmdletBinding()]
    [OutputType([Project])]
    param(
        [string]$Path = './'
    )

    [Project]$Project = [Serializer]::Import($Path );
     
    
    if ( $null -eq $Project ) {
        Write-Error 'Project not found';
        return $null;
    }
    else {
        return  $Project;
    }
};


function  Initialize-Project { 
    [CmdletBinding()]
    [OutputType([Project])]
    param(
        [string]$Path = './'
    )
    
    [Project]$NewProject = [Serializer]::Import($Path );
    if ($null -eq $NewProject) {
        
        [Project]$NewProject = [Project]::new( );
        #set path to new project before exporting  
        $NewProject.SetPath( $Path);
        $res = [Serializer]::Export($NewProject );
        if ($res -eq $false) {
            Write-Error 'Exporting failed';
        }
        
    }
    else {
        Write-Warning "Commad can not override existing Project $($NewProject.GetName())";
    }

    return $NewProject;
}; 
function  Execute-Commands { 
    [CmdletBinding()]

    param(
        [string[]]$Commands 
    )
    foreach ($eachCommand in $Commands) {
        &  eachCommand;
    }
}  
function  New-Project { 
    [CmdletBinding()]
    [OutputType([Project])]
    param (
        [string] 
        $Path = './NewProject'
    )
    $DebugPreference = 'Continue';
    $NewName = Split-Path $Path -Leaf;
    $ExistPath = Split-Path $Path;

    #if path to the new directory doesn't exist
    if ((Test-Path $ExistPath) -eq $false ) {
        Write-Error  "directory  $ExistPath does not exists";
        return $null;
    }

    #if path with new directory already exists, don't create new project in it
    if ((Test-Path $Path) -eq $true ) {
        Write-Error  "Path  with name $Path already exists";
        return $null;
    }
    

    $ExistPath = Resolve-Path $ExistPath;
 
    if ($null -eq $ExistPath) {
        Write-Error  "Path $($Path) does not exist";
        return $null;
    }
    else {
        New-Item -Path $ExistPath -Name $NewName -ItemType Directory;
        $Path = Resolve-Path $Path    ;
        Set-Location $Path;
        Write-Debug   "Creating $($NewName)...";
        Write-Debug   "Here $($Path)";

    }
     

    git clone https://github.com/artomartom/Hello_World.git  $Path  ;

    if ($LASTEXITCODE -eq 0 ) {

        New-Item -Path    "$($Path)/Build" -ItemType Directory;
        Remove-Item -Path "$($Path)/.git" -Recurse -Force;
        Remove-Item -Path "$($Path)/.gitmodules"  -Force;
        Remove-Item -Path "$($Path)/Source/Hello"  -Force;
  
        $Cmake = 'Source/CMakeLists.txt';
        $Content = (Get-Content   "$($Path)//$($Cmake)" -Raw);
        $Content.Replace('Hello_World', $NewName) | Set-Content  $Cmake;

    }
    else {
        Write-Error  'Cloning Hello_World falied: continuing initializing  empty project ...';
    };
  
    git init $Path  ;
    git submodule  add https://github.com/artomartom/Hello.git './/Source//Hello';
     
    if ($LASTEXITCODE -eq 0 ) {
        Set-Location  "$($Path)//Source//Hello";
        git branch -u origin/main main;
        Set-Location  $Path  ;     
    };
     
    git add $Path  ;
    git commit -m "init $($NewName)" ;
    [Project]$NewProj = [Project](Initialize-Project $Path ) ;
    $NewProj.SetName($NewName);

    return $NewProj
}    

function Execute-Project {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0, 
            Mandatory = $true, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Project]$Project
    )
    & "$($Project.Path)//Build/$($Project.Config)//$($Project.Name).exe";
}   

function  Make-Project { 
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Project]$Project 
    )
    $MSBuildArchName = '';
    switch ($Project.Arch) {
        'x86' { $MSBuildArchName = 'win32' }
        'x64' { $MSBuildArchName = 'x64' }
        Default { Write-Error "Invalid input parameter 'Arch' $($Project.Arch)"; return $false; }
    }
      
    Write-Host "$($Project.Name) : Running Cmake" -ForegroundColor Green  ;

    #function outs an array of some values,dont know how that works,but we so cast it in case there was an error
    [string] $output = cmake -S "$($Project.Path)//Source//" -B "$($Project.Path)/Build/" -G"Visual Studio 17 2022"  -T host=x64 -A $( $MSBuildArchName)`
        -DCMAKE_TOOLCHAIN_FILE="$($Project.ToolChain)";
   
    if ( $LASTEXITCODE -ne 0) {
        Write-Error  $output ;
       
        return  $false;
    };
    return $true;
}

function  Build-Project { 
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(
            Position = 0, 
            Mandatory = $true, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)
        ]
        [Project]$Project,
        [switch]$AndRun,
        [switch]$Make,
        [switch]$PreBuildEvent,
        [switch]$PostBuildEvent
    )
   
    if ($PreBuildEvent) {
        Execute-Commands -Commands $Project.PreGetBuildEvent();
        
    }
    if ($Make) {
        if (  $false -eq (Make-Project -Project $Project) ) {
             
         
            [pscustomobject]@{
                Status       = 'CMake Error'
                ProjName     = $Project.Name  
                ProjConfig   = $($Project.Config)
                Architecture = $($Project.Arch )
                StartTime    = "$($StartTime)"
                EndTime      = "$(Get-Date -format 'HH:mm:ss' )"
            };
         
            return ; #TODO build stars anyways wtf
        };
    }
    

    Write-Host "$($Project.Name) : build started" -ForegroundColor Green  ;
    $StartTime = $(Get-Date -format 'HH:mm:ss' )   ;
    cmake --build "$($Project.Path)//Build" --config "$($Project.Config)" ;
    $Status = '';
    if ($LASTEXITCODE -ne 0) {
        $Status = 'compilation Error';
    }
    else {
        $Status = 'build succeeded';
        if ($PostBuildEvent) {
            Execute-Commands -Commands $Project.GetPostBuildEvent();  
        }
        
        [pscustomobject]@{
            Status     = $($Status)
            ProjName   = $Project.Name  
            ProjConfig = $($Project.Config)
            StartTime  = "$($StartTime)"
            EndTime    = "$(Get-Date -format 'HH:mm:ss' )"
        };
        
        if ($AndRun) {
            Execute-Project $Project ;
        }
    };
};
