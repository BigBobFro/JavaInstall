<#CHECK#>
<#
param($Prop1="deployment.system.config=file:c:\windows\sun\java\deployment\deployment.properties"
    , $Prop2="deployment.system.config.manditory=TRUE")

$currPropFile = "c:\windows\sun\java\deployment\deployment.config"
$currProps = get-content $currPropFile 
$retval = -1
if ($($currProps) -contains $("$prop1"))
    {$retval = $retval}
else {$retval++}
if ($($currProps) -contains $("$prop2"))
    {$retval = $retval}
else {$retval++}


RETURN $retval
#>

<#Remedy#>
[array]$Props="deployment.system.config=file:c:\windows\sun\java\deployment\deployment.properties"
$props += "deployment.system.config.manditory=TRUE"

$currPropFile = "c:\windows\sun\java\deployment\deployment.config"
$currProps = get-content $currPropFile
$proplocked = $false

clear-content $currpropfile
foreach ($prop in $props)
    {$prop|out-file -filepath $currpropfile -append}
    
    