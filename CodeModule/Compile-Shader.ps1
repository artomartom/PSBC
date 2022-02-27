function Parse-Name {
  param(  [string]$FileName   )
  
  $ShaderObject = [PSCustomObject]@{
    Name    = ''
    Profile = "/T"
  }
  $FileName = $FileName -replace '.Source.hlsl';
  foreach ($pos in 0..$FileName.length) { 
    if ($FileName[$pos] -eq '.') `
    {
      $ShaderObject.Name = $FileName.substring(0, $pos);
      #write-host $ShaderObject.Name 
      $ShaderObject.Profile +=$FileName.substring( $pos+1 );
      #write-host $ShaderObject.Profile
    };
  }

   
   
  return $ShaderObject;
};


function Compile-hlsl {
 
  param(
    [string] $Shader ,
    [string] $OutType,
    [string] $Config
  )
      
  $exe = 'C://Program Files (x86)//Windows Kits//10//bin//10.0.22000.0//x64//fxc.exe';               

  $ShaderProfile = $(Parse-Name -FileName  $Shader );             
  switch ($Config) {
    'debug' { $Params = @("/E$($ShaderProfile.Name)main", '/nologo', $( $ShaderProfile.Profile), '/O0', '/WX', '/Zi', '/Zss', '/all_resources_bound' ) }
    'release' { $Params = @("/E$($ShaderProfile.Name)main", '/nologo', $( $ShaderProfile.Profile), '/O3', '/WX' ) }
  };
        
  switch ($OutType) {
    'vso' { $Params += '/Fo';   $out = "$(Get-Location)//build//x64//$Config"; }
    'hpp' {$Params += "/Vn$($ShaderProfile.Name)" ; $Params += '/Fh'; $out = "$(Get-Location)//Source//Shader//$Config"; }
  } ;
                   
  $In = "$(Get-Location)//Source//shader//source";
  $paths =
  @(
    "$out//$($ShaderProfile.Name).$OutType" ,
    "$In//$Shader"     
  );                                                                            
     & $exe  $Params    $paths  ;
    # Write-Host $Params 
};



function Compile-Shader {
  param(
    [string] $Config    ,   
    [string] $OutType   ,
    [string] $SourcePath  
  )
 
  Get-ChildItem  '*Source.hlsl'  -Path $SourcePath  | ForEach-Object  `
  {
     
    Compile-hlsl -Shader  $_.Name    -OutType  $OutType     -Config     $Config ;
  }  
   
}
Compile-Shader -Config   $($args[0]) -OutType $( $args[1]) -SourcePath $( $args[2]);
