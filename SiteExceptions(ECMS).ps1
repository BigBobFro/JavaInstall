$DestFile = "$env:userprofile"+"\appdata\locallow\sun\java\deployment\exception.sites"
[array]$sites = "http://ncsz4oraapp01.nctr.fda.gov:8888"
$sites += "http://ecmsweb.fda.gov:8080"

if (!(test-path $DestFile))	{$null|out-file -filepath $destfile}
$PrevExceptions = get-content $destFile
foreach ($site in $sites)
{
	if($prevExceptions -contains $site)
		{"Site already in user site exceptions"}
	else 
		{"$site"|out-file -filepath $destFile -append}
}

