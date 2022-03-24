
 
 

function Git `
{
   param (
      [ValidateSet('Show-Branch', 'Show-Commits', 'Set-Branch', 'Set-Commit', 'Create-Branch', 'Remove-Branch')][string]$Action ,
      [string] $Commit ,      
      [string] $Branch   ,
      [switch]$Force = $false     
   )
   $pat = Get-Location; Set-Location "$($env:Proj)//$($global:CurrentProj.Name)" ; 

   switch ($Action) `
   {
      'Show-Commits' { git log; }
      'Show-Branch' { git show-branch; }
      
      'Set-Commit' { if ($Commit ) { PrvSetCommit -Branch $Commit; } else { git log; PrvSetCommit; }; }
      'Set-Branch' { if ($Branch ) { PrvSetBranch -Branch $Branch; } else { git show-branch; PrvSetBranch; }; }

      'Create-Branch' { if ($Branch ) { PrvCreateBranch -Branch $Branch; } else { PrvCreateBranch; }; }
      'Remove-Branch' { if ($Branch ) { PrvRemoveBranch -Branch $Branch -Mode ($Force)? ('-D'):('-b'); } else { git show-branch; PrvRemoveBranch; }; }
      'Remove-Branch' { git show-branch; }
   }
 
   Set-Location  $pat;  
}

<#___________________________Private_________________________________#>
function  PrvSetBranch  `
{   
   param ([Parameter(Mandatory = $true)][string] $Branch);
   git switch $Branch;
}

function PrvSetCommit `
{
   param ([Parameter(Mandatory = $true)][string] $Commit);
   git checkout  $Commit;
}
function PrvCreateBranch   `
{   
   param ([Parameter(Mandatory = $true)][string] $Branch)
   git branch $Branch; 
}
function PrvRemoveBranch   `
{   
   param ([Parameter(Mandatory = $true)][string] $Branch,
      [ValidateSet('-b', '-D' )]    [string] $Mode
   )

   git branch $Mode $Branch;
    
   
}
 