function Invoke-fxcCompiler {
     
    param( 
        [Parameter(Mandatory = $true)]      [string] $Name  ,
        [Parameter(Mandatory = $true)]      [ValidateSet('Debug', 'Release')][string] $Config  ,
        [Parameter(Mandatory = $true)]                                      [string] $OutName ,
        [Parameter(Mandatory = $true)]      [ValidateSet('so', 'hpp')]      [string] $OutType ,
        [Parameter(Mandatory = $true)]      [string] $EntryPoint ,
        [string] $VarName = $EntryPoint,
       
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
        Write-Host  "Shader $($($EntryPoint))/$($Name).hlsl: build succeeded" -ForegroundColor  Green   
    }
    else {
        Write-Host  "Build Error at $($EntryPoint)" -ForegroundColor red
    };
};