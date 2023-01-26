<#
[array]$list = "aa","ab","ac","ad","ae","af","ay","az"
$list += "ba","bb","bc","bd","be","bf","by","bz"
$list += "ca","cb","cc","cd","ce","cf","cy","cz"
$list += "da","db","dc","dd","de","df","dy","dz"
$list += "ea","eb","ec","ed","ee","ef","ey","ez"

[array]$include = "*java*","*JRE*"
[array]$exclude = "*SE*", "*SDK*","*JDK*", "*TM) 6 Update 17" , "*TM) 6 Update 38"
#>



function CompArray
{
param($items = $null, $iWClist = $null, $xWCList = $null)

    [array]$retlist = $null
    
    if (($items -eq $null) -or ($iWClist -eq $null) -or ($xWCList -eq $null))
        {$retlist = $null}
    else
    {
        foreach($item in $items)
        {
            $included = $false
            $excluded = $false
            foreach ($inc in $iWClist) {if (!$included) {$included = $($item -like $inc)}}
            foreach ($x in $xWCList)   {if (!$excluded) {$excluded = $($item -like $x)}}
            if ($included -and $(!$excluded) -and $($retlist -notcontains $item)) {$retlist += $item}
        }
    }
    return $retlist
}


$colItems = Get-WmiObject -Class Win32_Product -ComputerName .
$founditems = comparray -items $colitems -iWClist $include -xWCList $exclude

$founditems


