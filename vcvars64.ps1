
[CmdletBinding()]
param()

for ($i = 0; $i -lt 2; $i++) {
     
    
    if (Test-Path "$env:temp\vcvars.txt") {
        $lines = Get-Content "$env:temp\vcvars.txt"
        foreach ($line in $lines) {
            $idx = $line.IndexOf('=')
            if ($idx -ne -1) {
                [System.Environment]::SetEnvironmentVariable($line.Substring(0, $idx), $line.Substring($idx + 1))
            }
        }
        return ;
    }
    else {
        Write-Warning  'vcvars.txt not found';
        cmd.exe /c "call `"$($env:MSVS)\2022\Community\VC\Auxiliary\Build\vcvars64.bat`" && set > %temp%\vcvars.txt";

    }
}
Write-Warning 'envirnment not initialized';

