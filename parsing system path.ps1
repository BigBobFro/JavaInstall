$stuff = Get-ChildItem env: | ? {$_.name -eq "Path"}
$strStuff = $stuff.value
$totalLength = $strstuff.length

$done = $false
[array]$list = $null

do
{
    $nextindex = $strstuff.indexof(";")
    $remLength = $strstuff.length
    if ($($nextindex -le $remlength) -and $($nextindex -ne $null) -and $($nextindex -ge 0))      #grab the next but not last item
    {
        $list += $($strstuff.Substring(0,$nextindex))
        $strstuff = $($strstuff.Substring(   $nextindex+1,$($($remLength-1)-$($nextindex))))
        $done = $false
    }
    elseif ($($nextindex -lt 0) -or $($strstuff.length -gt 0) -or $($nextindex -eq $null))    #Grab Last Item
    {
        $list += $strstuff
        $strstuff = $null
        $done = $true
    }
    else                                       #done
    {
        $done = $true
    }
}while ($(!$done))


$retString = $null
[string]$retString
# Remove the java stuff
foreach ($item in $list)
{
    if (!($($item -like "c:\program files*") -and $($item -like "*java*")))
    {
        if ($retstring -eq $null) {$retstring = "$($item)"}
        else {$tempstring= "$retstring;$($item)";$retString = $tempstring}
    }
}

[environment]::SetEnvironmentVariable("path",$retString,"Machine")
