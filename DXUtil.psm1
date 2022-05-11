function Invoke-fxcCompiler {
     
    param( 
        [Parameter(Mandatory = $true)]
        [string] 
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $EntryPoint,
       
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
            'vs_4_1', 'vs_5_0', 'vs_5_1' )]      
        [string] 
        $Profile, 

        [ValidateSet('Object', 'Header', 'Library', 'Assembly')]      
        [string]
        $OutputType = 'Header',
        
        [string] 
        $Destination ,
      
        [ValidateSet('Debug', 'Release')]
        [string]
        $Config = 'Release',

        [string]
        $VarName = $EntryPoint
    )
        
    
    if ((Test-Path $Path) -eq $false) {
        Write-Error  "Path $($Path) does not exist";
        return;
    }
    else {
        if ((Test-Path $Path -PathType Leaf) -eq $false) {
            Write-Error  "$(Split-Path $Path -Leaf) is not shader source file. Please, specify a existing path to shader source file.";
            return;
        }
    }

    if ('' -eq $Destination ) {
         
        switch ($OutputType) {
            'Object' { $ext = '.so' ; }
            'Header' { $ext = '.hpp'; }
            'Library' { $ext = '.lib'; }
            'Assembly' { $ext = '.asm'; }
        }; 
        $Destination = "./$($EntryPoint).$($Profile)$($ext)";
         
    }
    else {
        #if  $Destination already exists...         
        if ((Test-Path    $Destination  ) -eq $true) {
            
            #... but if leaf of Destination is not a file, but a container,
            # use this container and default output file name 
            if ((Test-Path    $Destination -PathType Container) -eq $true) {
                
                switch ($OutputType) {
                    'Object' { $ext = '.so' ; }
                    'Header' { $ext = '.hpp'; }
                    'Library' { $ext = '.lib'; }
                    'Assembly' { $ext = '.asm'; }
                    
                }; 
                $Destination = "$($Destination)//$($EntryPoint).$($Profile)$($ext)";
            }#else means $Destination is path to existing file, so we override it with output  
        }
        else { 
            #file, $Destination points to, may be not existing for the first time we compile...
            #if  $Destination  doex not exists, separate leaf ( here assume that leaf is output file's name ) from it...
            $ExistingPath = Split-Path $Destination ;
            #.. and check again  
            if ((Test-Path    $ExistingPath) -eq $false) { 
                Write-Error  "Destination path $($ExistingPath) is not an existing directory.";
                return;
            };
        }
    }
 
    switch ($Config) {
        'Debug' { $Params = @("/E$($EntryPoint)", "/T$( $Profile)", '/nologo', '/O0', '/WX', '/Zi', '/Zss', '/all_resources_bound' ) }
        'Release' { $Params = @("/E$($EntryPoint)", "/T$( $Profile)", '/nologo', '/Vd', '/O3', '/WX' ) }
    };
    
    switch ($OutputType) {
        'Object' { $Params += "/Fo$($Destination)"; }
        'Header' { $Params += "/Vn$($VarName)" ; $Params += "/Fh$($Destination)"; }
        'Library' { $Params += "/Fl$($Destination)"; }
        'Assembly' { $Params += "/Fc$($Destination)"; }
    };   

    $exe = 'C://Program Files (x86)//Windows Kits//10//bin//10.0.22000.0//x64//fxc.exe';                
    $captureOutString = & $exe  $Params      $Path ;
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host  "build succeeded: $($EntryPoint) -> $($Destination)" -ForegroundColor  Green;
    }
    else {
        Write-Host  "Build Error at $($EntryPoint)" -ForegroundColor Red;
    };
};