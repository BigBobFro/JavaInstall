#set removal thresholds
$remMaj = 7
$remmin = 0
$rembld = 71

$colItems = Get-WmiObject -Class Win32_Product -ComputerName . | ? {$_.name -like "*java*"}


foreach ($item in $colitems)
{
    $fullver = $item.Version
    $removeMe = $false
    
    $majver = $fullver.substring(0,$fullver.indexof("."))
    if($remmaj -gt $majver){$removeMe = $true}
    else
    {
        $Minorstart = $fullver.IndexOf(".") +1
        $longminor = $fullver.Substring($Minorstart,$fullver.Length - $Minorstart)

        $minor = $longminor.substring(0,$longminor.IndexOf("."))

        if ($remmin -gt $minor){$removeMe = $true}
        else
        {
            $buildstart = $longminor.indexof(".") + 1
            $longBUild = $longminor.substring($buildstart,$longminor.length - $buildstart)

            $build = $longbuild.substring(0,$longbuild.indexof("."))
            if ($rembld -gt $build) {$removeMe = $true
        }
    }
    if ($removeMe) 
    {
        ######Removal process #########
    }
}