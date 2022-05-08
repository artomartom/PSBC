

 

Class Serializer {

    static hidden [bool]  Move([Project]$Object, [string]$NewPath  ) {
        return $false;
    }

    static hidden [bool]  Export([Project]$Object  ) {
        if ((Test-Path $Object.Path) -eq $true) {

            

            Write-host "$($Object.Path): Exporting"
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
            #Write-host 'test-path succ'
            $Path = Resolve-Path $Path;

            Get-ChildItem  $Path -Filter '.PSBC' | Where-Object { 
                $deserializedProject = Import-CliXml "$($Path)//.PSBC";
                #Write-host 'importing...'
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
        $this.Before = $null;
        $this.After = $null;
       

    }
    
    # methods :
    
    hidden [void] Move( [Project]$Other   ) {
        $this.Path = $Other.Path;
        $this.Name = $Other.Name;
        $this.Config = $Other.Config;
        $this.Arch = $Other.Arch;
        $this.Before = $Other.Before;
        $this.After = $Other.After;
         
    }


    #set methodsSet
    [void] SetPath( [string]$NewPath   ) {

        $this.Path = Resolve-Path  $NewPath;
        #TODO:serializer moves PSBC file 
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
        }
        else {
            Write-Error "Invalid Name $($NewName)";
        };
    }

    [void] SetArch(  [string]$NewArch  ) {
        $this.Arch = $NewArch; 
    }   

    [void] Execute(  ) {
        & "$($this.Path)//Build/$($this.Config)//$($this.Name).exe";
    }   
    
    #  members:
    <# 
    Absolute path to the project's root directory.
            Root directory contains one .PSBC ("$($this.Path)//.PSBC") file storing serizlized Project object
            leaf of path allowed to be equal to Project::Name member, but not restricted to be the same.
            #>
    hidden [String]$Private:Path = $null;
 
    <# project name / target name (projects producing anything besides one .exe file are no supported for now)
    #>
    hidden [String]$Private:Name = $null;
    
    <# project's configuration 
    TODO: add strong typization to this member, different build options support   
    #>
    hidden [String]$Private:Config = $null;
 
    <# project's architecture
    don't see much sense to add anything here, it just exists as a member for now   
    #>
    hidden [String]$Private:Arch = $null;
 
    <#  array of path to invokable files to execute before starting project::build method  #>
    hidden [String[]]$Private:Before = $null;
 
    <#      same as $before, but after,u get it lol    #>
    hidden [String[]]$Private:After = $null; 

}

function  Initialize-Project { 
    [CmdletBinding()]
    [OutputType([Project])]
    param(
        [string]$Path = './'
    )

    [Project]$NewProject = [Project]::new( );
    $NewProject.SetPath( $Path);
    [Serializer]::Export($NewProject  );
    
    return $NewProject;
}; 
function  New-Project { 
    param (
        [Parameter(Mandatory = $true)]
        [string] 
        $Path 
    )
    
    Import-Module 'F:\Dev\Projects\PowerShell\PSBC.psm1'
           
    $NewName = Split-Path $Path -Leaf;
    if (Test-Path $Path ) {
        Write-Error  "directory with name $($NewName) already exists";
        return $null;
    }
        
    $NewName = Split-Path $Path -Leaf;
    
    $ExistPath = Split-Path $Path
    $ExistPath = Resolve-Path $ExistPath;
     
    if ($null -eq $ExistPath) {
        Write-Error  "Path $($Path) does not exist";
        return $null;
    }
    else {
        New-Item -Path $ExistPath -Name $NewName -ItemType Directory;
        $Path = Resolve-Path $Path    ;
        Set-Location $Path;
        Write-Host   "Path is $($Path) ";
        Write-Host   "existing Path is $($ExistPath) ";
        Write-Host   "Name is $($NewName) ";
    }
         
    git clone https://github.com/artomartom/Hello_World.git  ;
      
    if ($LASTEXITCODE -ne 0 ) { return ; };
      
    New-Item -Path './Build' -ItemType Directory;
    Remove-Item -Path './.git' -Recurse -Force;
    Remove-Item -Path './.gitmodules'  -Force;
    Remove-Item -Path './Source/Hello'  -Force;
      
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
    $NewProj = Initialize-Project   ;
    $NewProj.SetName($NewName);
    
    Remove-Module PSBC;
    return $NewProj
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
    }
    else {
        return  $Project;
    }
};

function  Make-Project { 
    [CmdletBinding()]
    param(
        [Project]$Project 
    )
    $MSBuildArchName = '';
    switch ($Project.Arch) {
        'x86' { $MSBuildArchName = 'win32' }
        'x64' { $MSBuildArchName = 'x64' }
        Default { Write-Error "Invalid input parameter 'Arch' $($Project.Arch)"; return $false; }
    }
      
    write-host "$($Project.Name) : Running Cmake" -ForegroundColor Green  ;
      
    $output = cmake -S "$($Project.Path)//Source//" -B "$($Project.Path)/Build/" -G"Visual Studio 17 2022"  -T host=x64 -A $( $MSBuildArchName);
   
    if ( $LASTEXITCODE -ne 0) {
         
        [pscustomobject]@{
            Name         = $($Project.Name)
            Architecture = $($Project.Arch )
        };
        Write-Error  $output ;
        return $false;
    };
    return $true;
}

function  Build-Project { 
    [CmdletBinding()]
    param(
        [Project]$Project,
        [switch]$AndRun,
        [switch]$Make,
        [switch]$Before,
        [switch]$After
    )
   
    if ($Before) {
        $Project.Before();
    }
    if ($Make) {
        if (  $false -eq (Make-Project -Project $Project ) ) {
            return ;
        };
    }
    

    Write-Host "$($Project.Name) : build started" -ForegroundColor Green  ;
    $StartTime = $(Get-Date -format 'HH:mm:ss' )   ;
    cmake --build "$($Project.Path)//Build" --config "$($Project.Config)" ;
    $Status = '';
    if ($LASTEXITCODE -ne 0) {
        $Status = 'Error';
    }
    else {
        $Status = 'build succeeded';
        if ($After) {
            $Project.After();
        }
        if ($AndRun) {
            $Project.Execute();
        }
    };

    [pscustomobject]@{
        Status     = $($Status)
        ProjName   = $Project.Name  
        ProjConfig = $($Project.Config)
        StartTime  = "$($StartTime)"
        EndTime    = "$(Get-Date -format 'HH:mm:ss' )"
    };
};