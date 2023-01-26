
$strComputer = "."

$include = "*java*"
[array]$Exempt = "*SE*", "*SDK*","*JDK*" #,"*JRE*"

$colItems = Get-WmiObject -Class Win32_Product -ComputerName . | ? {$_.name -like $include -and -not $($Exempt -contains $_.name)} 
write-host "Gather Complete"
foreach ($objItem in $colItems) 
{
	write-host
	write-host "Removing Software: $($objItem.Name)"
	$guid = $objItem.identifyingnumber
	write-host $guid
    
    $ec = start-process -filepath "msiexec.exe" -argumentlist "/x$guid /qn" -wait -passthru
    write-host "$($objItem.name) removed with exit code: $($ec.ExitCode)"
}