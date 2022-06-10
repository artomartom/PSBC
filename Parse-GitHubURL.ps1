
[CmdletBinding()]
[OutputType([void])]
param(
    [Parameter(
        Position = 0, 
        #  Mandatory = $true, 
        ValueFromPipelineByPropertyName = $true)
    ]
    [string]$URL = 'https://github.com/owner/name/tree/master/examples/124124'
    
)
[string[]]$attribs = @( );
 
while ($attrib -ne 'github.com' ) {
    [string]$attrib = Split-Path $URL -Leaf;
    $URL = Split-Path $URL ;
    $attribs += $attrib;
}
 
$count = $attribs.Count;
if (($count - 2) -ige 0) { $Owner = $attribs[$count - 2] ; }
if (($count - 3) -ige 0) { $Name = $attribs[$count - 3] ; }
if (($count - 5) -ige 0) { $Branch = $attribs[$count - 5] ; }
if (($count - 6) -ige 0) {
    for ($i = 6; $count - $i -ige 0 ; $i++) {
        $Path += "$($attribs[$count - $i])/" ;
    }
}
Write-Output @{
    Owner  = $Owner  
    Name   = $Name  
    Branch = $Branch  
    Path   = $Path  
}  