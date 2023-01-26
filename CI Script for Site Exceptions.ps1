
<#CHECK#>
param($DestFile = "c:\windows\sun\java\deployment\exception.sites",$site="http://ncsz4oraapp01.nctr.fda.gov:8888")
$PrevExceptions = get-content $destFile
if($prevExceptions -contains $site){RETURN 0}
else {RETURN 1}



<#REMEDIATE#>
param($DestFile = "c:\windows\sun\java\deployment\exception.sites",$site="http://ncsz4oraapp01.nctr.fda.gov:8888")

if (!(test-path $DestFile))	{$null|out-file -filepath $destfile}
$prevExceptions = Get-content $Destfile
if ($prevExceptions -notcontains $site)
	{"$site"|out-file -filepath $destFile -append}

