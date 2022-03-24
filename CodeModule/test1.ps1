 

function prefunc `
{
   
   return [pscustomobject]   @{
   
      first='true'
      second=
      BuildStatus='true'
   }  ;
}
function func `
{   

   
   param(
      [Parameter(ValueFromPipelineByPropertyName = $true)]
      [string]$BuildStatus = 'false',
      [string]$other = 'o'
     
   )

   if ($BuildStatus -eq 'true' )
   { return   'build succeeded'     ; }
   
   return  'build failed '        ;   

    
}

prefunc ;
 
 
 
