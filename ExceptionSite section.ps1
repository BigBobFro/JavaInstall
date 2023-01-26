$nctr = $true
$cber = $false
$ecms = $true


[array]$NCTRurls = "http://ncsz4oraapp01.nctr.fda.gov:8888"
[array]$CBERurls = "https://cberiqs.test.fda.gov/","https://cberiqs.preprod.fda.gov/", "https://cberiqs.fda.gov/"
[array]$ECMSurls = "http://ecsmweb.fda.gov:8080","http://ecmsweb.fda.gov:8081", "http://ecmsweb.fda.gov:8880", "http://fdarecords.fda.gov:8080"

if ($nctr) {$urls = $NCTRurls}
elseif ($cber) {$urls = $CBERurls}
if ($ecms) 
{
    if (($urls -eq $null) -or ($urls.count -eq 0))
        {$urls = $ECMSurls}
    else {$urls += $ECMSurls}
}

$ReadFile = "C:\windows\sun\java\deployment\exception.sites"
[array]$urls = 
if (test-path $readfile)
{
    $filedata = Get-Content $ReadFile
    foreach ($url in $urls)
    {
        if ($filedata -notcontains $url){$url|out-file -FilePath $ReadFile -append}
    }
}
else
{
	"http://ecsmweb.fda.gov:8080"|out-file -filepath $ReadFile
	"http://ecmsweb.fda.gov:8081"|out-file -filepath $ReadFile -append
	"http://ecmsweb.fda.gov:8880"|out-file -filepath $ReadFile -append
	"http://fdarecords.fda.gov:8080"|out-file -filepath $ReadFile -append
}
