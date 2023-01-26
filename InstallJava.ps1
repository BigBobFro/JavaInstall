<#
Install Java, disable Java Updates
-- Possibly remove other versions of java prior to installation

Originally written: February 21, 2016
Original Author: Victor Willingham (https://github.com/BigBobFro)

Dependancies: 		Powershell 2.0+
					.NET 4.0+
					Windows 7 or Windows 8
					PowerShell Execution Policy set to Bypass
					
============================================					
Usage:
powershell -executionpolicy bypass -file ".\<scriptname>" -64 -32 -remprev
powershell -executionpolicy bypass -file ".\<scriptname>" -OSD 
	For OSD Only
Default behavior (no switches): Install 32b Java only; remove nothing.

-64 = Present: 64b Java installed; abcent: 64b Java skipped
-32 = Present: 32b Java skipped; abcent: 32b Java installed
-remprev = Presnet: remove all preveous versions of java except 1.6u17 and 1.6u38; Abcent: remove nothing
-remall = Removes all prior versions; includes remprev but does not exempt certain versions from removal
-osd = ignores all other parameters and overrides to install 32b and 64b and removes nothing
NOTE: To remove nothing, neither RemPrev nor RemAll can be present

============================================
					
Current Version 1.8 -- Aug 21, 2017
============================================
Version History
1.0 - New Script written
1.1 - Update for new version (JRE 1.8u73)
1.2 = [2016-03-10] by vaw: Updated to support 64b installation with the same script.
	- Added 32 and 64 switches.  32 defaults to true ( not false)
		-Expected behavior: (none): 32 ins; (32): nothing installed; (64): 32 & 64 installed; (32+64): only 64 installed
1.3 = [2016-04-20] by vaw: Update for new version (JRE 1.8u91)
	- Added usage section in comments to clarify param switch use
	- Added Deployment.config and Deployment.properties copy in features along with the setx cmd at end
1.4 = [2016-08-02 by vaw] - Updated for new version (JRE 1.8u101)
1.5 = [2016-10-24 by vaw] - Updated for new version (JRE 1.8u111)
	- Added OSD Switch function
1.6 = [2017-02-10 by vaw] - <REDACTED>
1.7 = [2017-07-20 by vaw] - Added capabilities to add certificates to Java store
1.8 = [2017-08-21 by vaw] - <REDACTED>
1.9 = [2023-01-24 by vaw] - Sanatized for general consumption
	
============================================
#>
param(
	[switch]$remPrev,				#Remove previous versions other than those exempted
	[switch]$remAll,
	[switch]$32,
	[switch]$64,
	[switch]$OSD,
	[switch]$Cert,
	)
	
$32 =  $(!$32)						# Invert the default value to $true if not present


# ===================================================================================================
# Constants
$srcPath = Split-Path -Path $MyInvocation.MyCommand.Path
$divider = "====================================================================================================================" 

function CompArray
{
	param($items = $null, $iWClist = $null, $xWCList = $null)
    [array]$retlist = $null
    
	"Include: $iwclist" | out-file -filepath $logfile -append
	"Exclude: $xwclist" | out-file -filepath $logfile -append
	
    if (($items -eq $null) -or ($iWClist -eq $null) -or ($xWCList -eq $null))
        {$retlist = $null}
    else
    {
		
        foreach($item in $items)
        {
            $included = $false
            $excluded = $false
            foreach ($inc in $iWClist) {if (!$included) {$included = $($item.name -like $inc)}}
            foreach ($x in $xWCList)   {if (!$excluded) {$excluded = $($item.name -like $x)}}
            if ($included -and $(!$excluded) -and $($retlist -notcontains $item)) {$retlist += $item}
        }
    }
    return $retlist
}

function RemoveJava
{
	"[$([DateTime]::now)] Removing Previous Java Version" | out-file -filepath $logfile -append
	$strComputer = "."

	[array]$include = "*java*","*JRE*"
	[array]$Exempt = "*SE*", "*SDK*","*JDK*"
	if(!$remall) {$exempt += "*TM) 6 Update 17" , "*TM) 6 Update 38"}
	
	$colItems = Get-WmiObject -Class Win32_Product -ComputerName . 
	$founditems = CompArray -items $colitems -iWClist $include -xWCList $exempt
	"[$([DateTime]::now)] Gather Complete" | out-file -filepath $logfile -append
	foreach ($objItem in $founditems) 
	{
		"[$([DateTime]::now)] Removing Software: $($objItem.Name)" | out-file -filepath $logfile -append
		$guid = $objItem.identifyingnumber
		$guid | out-file -filepath $logfile -append
		
		$ec = start-process -filepath "msiexec.exe" -argumentlist "/x$guid /qn" -wait -passthru
		"[$([DateTime]::now)] $($objItem.name) removed with exit code: $($ec.ExitCode)" | out-file -filepath $logfile -append
	}
	"$divider`n" | out-file -filepath $logfile -append
}

function KillTasks
{
	# Kill java and updater processes if running
	[array]$processes = "java*","jusched*"
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
					write-host "$proc still running..."
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
	"[$([DateTime]::now)] Installer running..." | out-file -filepath $LogFile -append
	start-sleep -s 10
}while ($rc.hasexited -eq $false)

"`t[$([DateTime]::now)] Installer exited with exit code: $($rc.exitcode)" | out-file -filepath $LogFile -append
"`n$divider" | out-file -filepath $LogFile -append

}

# ===================================================================================================
# Begin Installation
$logpath = "c:\program files\Logs"
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
"Passed Switches:" | out-file -filepath $logfile -append
	"`t32bit:    $32" | out-file -filepath $logfile -append
	"`t64bit:    $64" | out-file -filepath $logfile -append
	"`tRemPrev:  $remprev" | out-file -filepath $logfile -append
	"`tRemAll:   $remall" | out-file -filepath $logfile -append
	if ($OSD) {"`tOSD:      $OSD" | out-file -filepath $logfile -append}
	if ($NCTR) {"`tNCTR:     $NCTR" | out-file -filepath $logfile -append}
	
if ($OSD)
{
	Install -MSIpath "$srcpath\jre1.8.0_111.msi"
	Install -MSIpath "$srcpath\jre1.8.0_111_x64.msi"
    $cert = $true
}
else
{
	KillTasks("")

	if ($remPrev -or $remAll) {RemoveJava("")}

	if ($32) {Install -MSIpath "$srcpath\jre1.8.0_111.msi"}
	if ($64) {Install -MSIpath "$srcpath\jre1.8.0_111_x64.msi"}
}

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

# Copy Files
$DestPath = "c:\windows\sun\java\deployment"
If(-not(Test-Path -Path $DestPath) -eq $true)							# Create Directory if doesn't exist
	{New-Item -ItemType Directory -Path $DestPath}
$copysource = "$srcpath\deployment.*"
copy-item $copysource $destpath -force

# Verify copies
if (test-path "$destpath\deployment.properties") {"Deployment.Properties copied sucessfully" | out-file -filepath $logfile -append}
else {"Deployment.properties not copied successfully" | out-file -filepath $logfile -append}

if (test-path "$destpath\deployment.Config") {"Deployment.config copied sucessfully" | out-file -filepath $logfile -append}
else {"Deployment.config not copied successfully" | out-file -filepath $logfile -append}

if ($NCTR -or $CBER)
{
	if (test-path "$destpath\exception.sites") {"Exception.Sites copied sucessfully" | out-file -filepath $logfile -append}
	else {"Exception.Sites not copied successfully" | out-file -filepath $logfile -append}
}

# set update permissions
&setx deployment.expiration.check.enabled false /m	

# Delete Check for Updates shortcut from start menu
$path = "c:\programdata\microsoft\windows\start menu\programs\java"
$filename = "Check for updates.lnk"
if (test-path "$path\$filename"){remove-item -path "$path\$filename" -force}

# ==================================================================================================
# Add Certs to Java stores

if ($cert)
{
	$32subs = get-childitem -path "c:\program files (x86)\java"
	$64subs = get-childitem -path "c:\program files\java"
    $cers = Get-ChildItem "$srcpath\certificates\*.cer"

	if ($32subs -ne $null)
	{
		"`n$divider`n"| out-file -filepath $logfile -append
		"Beginning 32b Certificate install"| out-file -filepath $logfile -append
		foreach($path in $32subs)
		{
			$rootpath = "c:\program files (x86)\java\$path\bin"
			$kt = "$rootpath\keytool.exe"

			foreach($cer in $cers)
            {
                $TempAlias = $($cer.name).substring(0,(($cer.name.length)-4))
                $arrgs = "-importcert -alias $tempalias -storepass changeit  -file $cer -trustcacerts -keystore cacerts -noprompt"
                $rc = start-process $kt -argumentlist $arrgs -PassThru -wait -windowstyle hidden
			    $handle = $rc.handle 									#caching the process handle of the process to return ExitCode later
			    "`t[$([DateTime]::now)] $tempalias installer exited with exit code: $($rc.exitcode)" | out-file -filepath $LogFile -append
            }
            
			"$divider" | out-file -filepath $LogFile -append
            "$kt Key Report:`n$checkout" | out-file -filepath $logfile -append
			&$kt -list -storepass changeit -keystore cacerts | out-file -filepath $logfile -append
		}
	}
	if ($64subs -ne $null)
	{
		"`n$divider`n"| out-file -filepath $logfile -append
		"Beginning 64b Certificate install"| out-file -filepath $logfile -append
		foreach($path in $64subs)
		{
			$rootpath = "c:\program files\java\$path\bin"
			$kt = "$rootpath\keytool.exe"
			
            foreach($cer in $cers)
            {
                $TempAlias = $($cer.name).substring(0,(($cer.name.length)-4))
                $arrgs = "-importcert -alias $tempalias -storepass changeit  -file $cer -trustcacerts -keystore cacerts -noprompt"
                $rc = start-process $kt -argumentlist $arrgs -PassThru -wait -windowstyle hidden
			    $handle = $rc.handle 									#caching the process handle of the process to return ExitCode later
			    "`t[$([DateTime]::now)] $tempalias installer exited with exit code: $($rc.exitcode)" | out-file -filepath $LogFile -append
            }

			"$divider" | out-file -filepath $LogFile -append
            "$kt Key Report:`n$checkout" | out-file -filepath $logfile -append
            &$kt -list -storepass changeit -keystore cacerts | out-file -FilePath $LogFile -Append
		}
	}
}

# ===================================================================================================
"$divider" | out-file -filepath $LogFile -append
"Install Java script complete at [$([DateTime]::now)]" | out-file -filepath $LogFile -append
"$divider" | out-file -filepath $LogFile -append
