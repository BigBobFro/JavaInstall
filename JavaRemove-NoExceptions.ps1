<#
Remove previously installed versions of java with no exceptions!

Originally written: June 3, 2016
Original Author: Victor Willingham (HP Enterprise Services)

Dependancies: 		Powershell 2.0+
					.NET 4.0+
					Windows 7 or Windows 8
					PowerShell Execution Policy set to Bypass
					
Current Version 1.0 -- June 3, 2016
============================================
Version History
1.0 - New Script written

============================================
#>

# ===================================================================================================
# Constants
$srcPath = Split-Path -Path $MyInvocation.MyCommand.Path
$divider = "====================================================================================================================" 

# ===================================================================================================
# Begin Installation
$logpath = "c:\program files\fda\Logs"
If(-not(Test-Path -Path $LogPath) -eq $true)							# Create Directory if doesn't exist
	{New-Item -ItemType Directory -Path $LogPath}
$LogFile = "$logpath\Java_Removal.log"
If(test-path $logfile) 
{
	"$divider`n" | out-file -filepath $LogFile -append
	"Java Removal`n`tStarted at [$([DateTime]::now)]" |out-file -filepath $LogFile -append
}
else{"Java Removal`n `tStarted at [$([DateTime]::now)]"|out-file -filepath $LogFile}
"`n$divider`n" | out-file -filepath $LogFile -append


$include = "*java*"
#[array]$Exempt = "*SE*", "*SDK*","*JDK*" 

$colItems = Get-WmiObject -Class Win32_Product -ComputerName . | ? {$_.name -like $include} 
#write-host "Gather Complete"
foreach ($objItem in $colItems) 
{
	"Removing Software: $($objItem.Name)" | out-file -filepath $logfile -append
	$guid = $objItem.identifyingnumber
	"`t$guid"  | out-file -filepath $logfile -append
    
    $ec = start-process -filepath "msiexec.exe" -argumentlist "/x$guid /qn" -wait -passthru
    "$($objItem.name) removed with exit code: $($ec.ExitCode)"  | out-file -filepath $logfile -append
}

# ===================================================================================================
"Java Removal script complete at [$([DateTime]::now)]" | out-file -filepath $LogFile -append
"$divider" | out-file -filepath $LogFile -append