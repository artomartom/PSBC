 

 
function GoToBuild
{   
   New-Variable -Name $Projects -Value $(Get-ChildItem -Path $env:Proj) -Option Constant
   param(
      [ValidateSet($Projects)]
      [string]$Project = $LastCurrentProject.Path
       
   ) 

    
}


 

GoToBuild