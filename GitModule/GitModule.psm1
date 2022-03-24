function  SetBranch  `
{   
   param ([Parameter(Mandatory = $true)][string] $LBranch);
   git switch $LBranch;
}
function SetCommit `
{
   param ([Parameter(Mandatory = $true)][string] $Commit);
   git checkout  $Commit;
}
function CreateBranch   `
{   
   param (
      [Parameter(Mandatory = $true)][string] $LBranch,
      [Parameter(Mandatory = $true)][string] $RemoteBranch)
   git branch $LBranch; 
   git branch --set-upstream-to origin $RemoteBranch;
}
function RemoveBranch   `
{   
   param ([Parameter(Mandatory = $true)][string] $LBranch,
      [ValidateSet('-b', '-D' )]    [string] $Mode
   )
   git branch $Mode $LBranch;
}
function Update `
{
   param( 
      [Parameter(Mandatory = $true)][string] $Message , 
      [Parameter(Mandatory = $true)][string] $RemoteBranch,
      [switch] $DontPush = $false) 
   $pat = Get-Location ;
   Set-Location "$($env:Proj)//$($global:CurrentProj.Name)" ;
   git add .  ;
   git commit -m $Message; 
   if (!($DontPush)) { git push --set-upstream origin $RemoteBranch ;};    
   git gc ;
   Set-Location $pat;
}
function New-Rep `
{
   $pat = Get-Location;
   Set-Location "$($env:Proj)//$($global:CurrentProj.Name)//"
   git init $pat;
   # git push --set-upstream origin master;
   git add . ;
   git commit -m 'Init'; 
   git push --set-upstream origin master;
}



function Rep `
{
   param (
      [ValidateSet('Show-Branch', 'Update', 'Show-Commits', 'Set-Branch', 'Set-Commit', 'Create-Branch', 'Remove-Branch')][string]$Action ,
      [string] $Commit ,      
      [string] $LBranch   ,
      [string] $Message   ,
      [switch] $Force = $false     ,
      [switch] $DontPush = $false 
   )
   $pat = Get-Location; Set-Location "$($env:Proj)//$($global:CurrentProj.Name)" ; 
 
   switch ($Action) `
   {
      'Show-Commits' { git log --graph --decorate --oneline; }
      'Show-Branch' { git show-branch; }
      
      'Set-Commit' { if ($Commit ) { SetCommit -LBranch $Commit; } else { git log; SetCommit; }; }
      'Set-Branch' { if ($LBranch ) { SetBranch -LBranch $LBranch; } else { git show-branch; SetBranch; }; }

      'Create-Branch' { if ($LBranch ) { CreateBranch -LBranch $LBranch; } else { CreateBranch; }; git show-branch; }
      'Remove-Branch' {$mode =if($true){'-D'}else{'-b'}; if ($LBranch ) { RemoveBranch -LBranch $LBranch -Mode $mode; } else { git show-branch; RemoveBranch; }; }
      'Update' { if ($Message  ) { Update $Message $DontPush; } else { Update -DontPush $DontPush  ; }; git status; }
   }
   
   Set-Location  $pat;  
}

 
 
@{
   RootModule        = 'GitModule.psm1'
   FunctionsToExport = @('Rep',
      'New-Rep' 
   )
   AliasesToExport   = @('')  
   VariablesToExport = @('')
   
   
}
 