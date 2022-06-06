 
[CmdletBinding()]
[OutputType([void])]
param(
    [Parameter(
        Position = 0, 
        Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)
    ]
    $CompileData,
    [string[]]$argss
)

 
if ($CompileData.Status -eq 0) {
    #   Write-Host  '$CompileData.Status -eq 0';
    $exe =Resolve-Path $CompileData.Executable;
     & $exe $argss ;
    if ($LASTEXITCODE -ne 0) {
        Write-Error ('{0:X}' -f $LASTEXITCODE);
    }
}
else {
    Write-Error 'Run.ps1 abort, compilation error';
}
