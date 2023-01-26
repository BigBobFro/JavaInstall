<#
Possibly remove previously installed versions of java, Install Java, disable Java Updates

Originally written: February 21, 2016
Original Author: Victor Willingham (HP Enterprise Services)

Dependancies: 		Powershell 2.0+
					.NET 4.0+
					Windows 7 or Windows 8
					PowerShell Execution Policy set to Bypass
					
Current Version 1.3 -- Mar 10, 2016
============================================
Version History
1.0 - New Script written
1.1 - Update for new version (JRE 1.8u73)
1.2 = Updated to support 64b installation with the same script.
	- Added 32 and 64 switches.  32 defaults to true ( not false)
		-Expected behavior: (none): 32 ins; (32): nothing installed; (64): 32 & 64 installed; (32+64): only 64 installed
1.3 = Added exceptions site support

============================================
#>
param(
	[switch]$remPrev,				#Remove previous versions other than those exempted
	[switch]$32,
	[switch]$64
	
	)
	
$32 = -not $32						# Invert the default value to $true if not present
# ===================================================================================================
# Constants
$srcPath = Split-Path -Path $MyInvocation.MyCommand.Path
$divider = "====================================================================================================================" 



function RemoveJava
{
	#set removal thresholds
	$remMaj = 7
	$remmin = 0
	$rembld = 67
	$strComputer = "."

	$include = "*java*"
	[array]$Exempt = "*SE*", "*SDK*","*JDK*"

	$colItems = Get-WmiObject -Class Win32_Product -ComputerName . | ? {$_.name -like $include -and -not $($Exempt -contains $_.name)} 
	"Gather Complete" | out-file -filepath $logfile -append

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
			"Removing Software: $($objItem.Name)" | out-file -filepath $logfile -append
			$guid = $objItem.identifyingnumber
			$guid | out-file -filepath $logfile -append
			
			$ec = start-process -filepath "msiexec.exe" -argumentlist "/x$guid /qn" -wait -passthru
			"$($objItem.name) removed with exit code: $($ec.ExitCode)" | out-file -filepath $logfile -append
		}
	} 
	"$divider`n" | out-file -filepath $logfile -append
}


function KillTasks
{
	# Kill java and updater processes if running
	[array]$processes = "iexplo*","chro*","firefo*","java*","jusched*"
	foreach ($proc in $processes)
	{
		$ProcAct = Get-Process -processname $proc -ErrorAction SilentlyContinue
		if ($procAct -eq $null) {"Process $proc not active" | out-file -filepath $logfile -append}
		else 
		{
			"Process $proc Active.  Attempting to stop" | out-file -filepath $logfile -append
			Stop-Process -processname $proc -force -passthru
			$stillAct = get-process $proc -erroraction silentlycontinue
			if ($stillAct) 
			{
				do
				{
					"Process still active" | out-file -filepath $logfile -append
					#write-host "$proc still running..."
					start-sleep -s 2
				}while ((get-process $proc -erroraction silentlycontinue) -eq $false)
				"Process $proc successfully stopped" | out-file -filepath $logfile -append
			}
			else {"Process $proc successfully stopped" | out-file -filepath $logfile -append}
		}
	}
}

function Install
{
param($MSIpath = $null)

if ($MSIpath -eq $null) {exit 42}

$MSI = get-item -path $MSIpath
$app = "msiexec.exe"

$filename = $($msi.name).substring(0,(($msi.name.length)-4))
$Msilog = $logpath 
$msilog += "\$filename"
$msilog += ".log"
"Processing file: $($msi.name)" | out-file -filepath $LogFile -append
"`tSee '$msilog' for more details" | out-file -filepath $LogFile -append
$arrg = "/i ""$($msi)"" /quiet /norestart /log "
$arrg += """$($logpath)\"
$arrg += $filename 
$arrg += ".log"""
"`tPassing Arguements: $arrg" | out-file -filepath $LogFile -append
$rc = start-process $app -argumentlist $arrg -PassThru
$handle = $rc.handle 									#caching the process handle of the process to return ExitCode later
do
{
	"Installer running..." | out-file -filepath $LogFile -append
	start-sleep -s 10
}while ($rc.hasexited -eq $false)

"`tInstaller exited with exit code: $($rc.exitcode)" | out-file -filepath $LogFile -append
"`n$divider" | out-file -filepath $LogFile -append

}

# ===================================================================================================
# Begin Installation
$logpath = "c:\program files\fda\Logs"
If(-not(Test-Path -Path $LogPath) -eq $true)							# Create Directory if doesn't exist
	{New-Item -ItemType Directory -Path $LogPath}
$LogFile = "$logpath\Install_Java.log"
If(test-path $logfile) 
{
	"$divider`n" | out-file -filepath $LogFile -append
	"Install Java `n`tStarted at [$([DateTime]::now)]" |out-file -filepath $LogFile -append
}
else{"Install Java`n `tStarted at [$([DateTime]::now)]"|out-file -filepath $LogFile}
"`n$divider`n" | out-file -filepath $LogFile -append

KillTasks("")
if ($remPrev) {RemoveJava("")}
killtasks("")
if ($32) {Install -MSIpath "$srcpath\jre1.7.0_67.msi"}
if ($64) {Install -MSIpath "$srcpath\jre1.7.0_67_x64.msi"}
killtasks("")

# ===================================================================================================
# Disable Java Updates

[array]$keys = "HKLM:SOFTWARE\JavaSoft\Java Update\Policy"
if (test-path "c:\program files (x86)"){
$keys += "HKLM:SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy"
}

foreach ($key in $key) 
{
	new-itemproperty -path $key -name "EnableJavaUpdate" -propertytype DWORD -value 00000000
	"Key $key set in registry." | out-file -filepath $logfile -append
}

# ===================================================================================================
"Install Java script complete at [$([DateTime]::now)]" | out-file -filepath $LogFile -append
"$divider" | out-file -filepath $LogFile -append
