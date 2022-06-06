
[CmdletBinding()]
param(
    [string]
    $vcvarsbat ,
    [string]
    [Parameter(Mandatory = $true)]
    [ValidateSet('x86', 'x86_amd64', 'x86_x64', 'x86_arm', 'x86_arm64', 'amd64', 
        'x64', 'amd64_x86', 'x64_x86', 'amd64_arm', 'x64_arm',	 
        'amd64_arm64', 'x64_arm64')]
    $arch,
    [ValidateSet('store', 'uwp')]
    [string]
    $platform_type,
    [string]
    $winsdk_version,
    [string]
    $vcvars_ver,
    [ValidateSet( 'spectre')]
    [string]
    $vcvars_spectre_libs  
)

$fname = "$env:temp\vcvars$($arch)$($platform_type)$($winsdk_version)$($vcvars_ver)$($vcvars_spectre_libs).txt";

for ($i = 0; $i -lt 2; $i++) {
     
    
    if (Test-Path  $fname ) {
        $lines = Get-Content  $fname;
        foreach ($line in $lines) {
            $idx = $line.IndexOf('=')
            if ($idx -ne -1) {
                [System.Environment]::SetEnvironmentVariable($line.Substring(0, $idx), $line.Substring($idx + 1))
            }
        }
        return;
    }
    else {
        Write-Host 'Initializing...';
        cmd.exe /c "call `"$($vcvarsbat)`" $($arch) $($platform_type) $($winsdk_version) -vcvars_ver=$($vcvars_ver) -vcvars_spectre_libs=$($vcvars_spectre_libs) && set > $($fname)";

        if ($LASTEXITCODE -ne 0) { return ; };
    }
}
Write-Warning 'Envirnment not initialized';
