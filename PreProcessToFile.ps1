
[CmdletBinding()]
[OutputType([void])]
param(
    [Parameter(
        Position = 0, 
        Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)
    ]
    [string]$SourceFile,
    [string[]]$AddIncludes ='./'
)

$SourceFile = [string](Resolve-Path $SourceFile);
$SourceFileName = Split-Path $SourceFile -LeafBase;


if( $AddIncludes ) {

	[string[]]$Includes = @()
	$AddIncludes | ForEach-Object {
	    $Fullpath = [string](Resolve-Path $_);
	    $Includes += $Fullpath.insert(0, '/I');
	};
}; 
 
cl.exe $SourceFile '/P' "/Fi./$($SourceFileName).i" $Includes ;

#/I<dir> add to include search path
#/P # preprocess to file
#/Fi[file] #name preprocessed file 
     