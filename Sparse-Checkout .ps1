

 
[CmdletBinding()]
[OutputType([void])]
param(
    [Parameter(
        Position = 0, 
        Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)
    ]
    [string]$URL
)

$Repo = Parse-GitHubURL.ps1 $URL;

if (  $null -eq $Repo.Owner -or `
        $null -eq $Repo.Name -or `
        $null -eq $Repo.Branch -or `
        $null -eq $Repo.Path   
) {
    Write-Error 'URL is incomplete' ; 
};

#git clone "https://github.com/$($Repo.Owner)/$($Repo.Name)" --no-checkout  --depth 1;
#Set-Location  $Repo.Name;
#git sparse-checkout init;
#Set-Content -Path .\.git\info\sparse-checkout -Value $Repo.Path;
#git sparse-checkout list;
#git checkout "origin/$($Repo.Branch)";


 