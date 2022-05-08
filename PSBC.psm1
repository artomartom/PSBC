

 

Class Serializer {

    static hidden [bool]  Export([Project]$Object  ) {
        if ((Test-Path $Object.Path) -eq $true) {
            #Write-host 'Exporting'
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
    
    Project(    ) {  

        $this.Path = Resolve-Path './';
        $this.Name = 'NewProject';
        $this.Config = 'Debug';
        $this.Arch = 'X64';
        $this.Before = $null;
        $this.After = $null;
        $this.Export();

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
   
    [bool] IsValid(   ) {
        return ($null -eq $this);
    }

  
    
    #serizlization  methods for indirect calls to serializer class

    [bool] Import([string]$Path ) {
        #Write-Host 'import method'
        $Imported = [Serializer]::Import( $Path);
        
        if ($null -ne $Imported) {
            $this.Move(  $Imported);
            Write-Host "Project imported: $($this.Name)"
            return $true;
        }
        Write-Warning 'import: skipped';
        return $false;
    }

    [bool] Export() {
        #Write-Host 'Export method'
        [Serializer]::Export($this);
        Write-Host "Project Exported: $($this.Name)"
        return $true;
    }
 
    
    #  members:
    <# 
    Absolute path to the project's root directory.
            Root directory contains one .PSBC ("$($this.Path)//.PSBC") file storing serizlized Project object
            leaf of path allowed to be equal to Project::Name member, but not restricted to be the same.
            #>
    [String]$Private:Path = $null;
 
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
    [String]$Private:Before = $null;
 
    <#      same as $before, but after,u get it lol    #>
    [String]$Private:After = $null; 

}
 

function  Initialize-Project { 
    [CmdletBinding()]
    param()

    return [Project]::new( );
}; 

 
function  Get-Project { 
    [CmdletBinding()]
    param()

    [Project]$Project = [Serializer]::Import('./');
    Write-host "Path: $($Project.Path)"
    if ( $null -eq $Project ) {
        Write-Error 'Project not found';

    }
    else {

        return $Project;
    }
};
 