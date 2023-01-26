<#check#>
param($PropCheck="deployment.security.level", $value="HIGH")

$currPropFile = "c:\windows\sun\java\deployment\deployment.properties"
$currProps = get-content $currPropFile | select-string -pattern $propcheck | select linenumber,line | ? {$_.line -notlike "*.locked"}

if ($($currProps.line) -eq $("$propcheck=$value"))
    {$retval = -1}
else {$retval = $currProps.LineNumber}

RETURN $retval



<#Remedy#>
param($PropCheck="deployment.security.level", $value="HIGH")

$currPropFile = "c:\windows\sun\java\deployment\deployment.properties"
$currProps = get-content $currPropFile
$proplocked = $false

clear-content $currpropfile
foreach ($line in $currProps)
{
    $proplocked = $false
    $testline = $("$propCheck=$value")
    if ($line -eq $("$propcheck.locked")) 
        {
            write-host "lock found"
            $line|out-file -filepath $currpropfile -append
            $proplocked = $true
        }
    elseif ($line -like $("$propcheck=*")) 
        {
            write-host "setting found"
            $testline|out-file -filepath $currpropfile -append
        }
    else {$line|out-file -filepath $currpropfile -append}
}
if (!$proplocked) {$("$PropCheck.locked")|out-file -filepath $currpropfile -append}
    

