
[CmdletBinding()]
param(
    [string[]]$cpp,
    [switch]$Dbg = $false
)
$name = Split-Path $cpp[0] -Leaf;
$ext = Split-Path  $name  -Extension;
$name = $name.Replace( $ext, '.exe');
  
$BuildArgs = @( 
    '-nologo',
    '-EHsc',
    '/std:c++20',
    "/Fe$($name)"
);
if ($dbg) {
    $BuildArgs += '/Zi';
} 

$compilerOutput = cl.exe $cpp  $BuildArgs  ;
if ($LASTEXITCODE -ne 0) {
    throw $compilerOutput;
}
Write-Output @{
    Executable = [string]$name
    Status     = $LASTEXITCODE
};
 