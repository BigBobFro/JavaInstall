<#
CBER Menu is hard coded to only use Java 1.6u21 and can't recognize newer alternatives.
Users are presented with a dialoge to approve use of currently installed Java rather than installing 1.6
This script adds two (2) entries to the personal user Java cache to prevent this message

Originally written: July 28, 2017
Original Author: Victor Willingham (DXC.Technology)

Dependancies: 		Powershell 5.0+
					.NET 4.6+
					Windows 10
					PowerShell Execution Policy set to Bypass
					
============================================					
Usage
powershell -executionpolicy bypass -file ".\CBER-Menu_JavaFix.ps1" <switches>
OSD - With this present, the script will add Reg keys that will execute the command for each new user created.
SD - With this present, the script will execute the command for all profiles currently on the system
<blank> - with no switches, script does nothing
============================================					
					
Current Version 1.0 -- Jul 28, 2017
============================================
Version History
1.0 - New Script written
	
============================================
#>
param(
	[switch]$osd,
	[switch]$sd
	)
	
# ===================================================================================================
# Constants
$srcPath = Split-Path -Path $MyInvocation.MyCommand.Path
write-host "srcpath $srcpath"
$srcScriptFile = split-path $MyInvocation.mycommand -Leaf
write-host "srcscriptfile $srcscriptfile"
$srcScriptPath = "$srcpath\$srcscriptfile"
write-host "srcScriptPath $srcscriptpath"

$divider = "====================================================================================================================" 

$path1 = "AppData\LocalLow\Sun\Java\Deployment\cache\6.0\1"
write-host "path1 $path1"
$path2 = "AppData\LocalLow\Sun\Java\Deployment\cache\6.0\12"
write-host "path2 $path2"
$file1 = "AppData\LocalLow\Sun\Java\Deployment\cache\6.0\1\172e6001-46fe16a78dee88e69875fa41b5a9bb040431e120a6a0ba5e4ea469f4975da0d1-6.0.lap"
$file2 = "AppData\LocalLow\Sun\Java\Deployment\cache\6.0\12\1ffd2d4c-aeee3f129aa4d5653f6ecf0db2e5a0f77ddc5774738d6c5c9257a47bfb562d26-6.0.lap"
$setVal = "ssv.version.allowed=ssv.latest.allowed"

# ===================================================================================================
# Begin Logging
$logpath = "c:\program files\fda\Logs"
If(-not(Test-Path -Path $LogPath) -eq $true)							# Create Directory if doesn't exist
	{New-Item -ItemType Directory -Path $LogPath}
$LogFile = "$logpath\CBER-Menu_JavaFix.log"
If(test-path $logfile) 
{
	"$divider`n" | out-file -filepath $LogFile -append
	"Install CBER-Menu_JavaFix `n`tStarted at [$([DateTime]::now)]" |out-file -filepath $LogFile -append
}
else{"Install CBER-Menu_JavaFix`n `tStarted at [$([DateTime]::now)]"|out-file -filepath $LogFile}
"`n$divider`n" | out-file -filepath $LogFile -append

$users = get-childitem -path "c:\users"
foreach ($user in $users)
{
    $basepath = "c:\users\$user"
    if (!$(test-path "$basepath\$path1")) {New-Item -ItemType Directory -Path "$basepath\$path1" -force}
    if (!$(test-path "$basepath\$path2")) {New-Item -ItemType Directory -Path "$basepath\$path2" -force}
}

if ($osd)
{
    <#"Executing fix for potential future users" | out-file -filepath $logfile -append
    new-item -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerJacob" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerJacob" -name "(Default)" -propertytype String -value "JRE Latest Version Jacob" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerJacob" -name "StubPath" -propertytype String -value "powershell -command `"& 'Add-Content' -Path '~\$file1' -Value '$setVal'`"" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerJacob" -name "Version" -propertytype String -value "1" -force
    "JRE Latest Version Jacob.jar key set in registry." | out-file -filepath $LogFile -append

    new-item -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerfrmwebutil" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerfrmwebutil" -name "(Default)" -propertytype String -value "JRE Latest Version frmwebutil" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerfrmwebutil" -name "StubPath" -propertytype String -value "powershell -command `"& 'Add-Content' -Path '~\$file2' -Value '$setVal'`"" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerfrmwebutil" -name "Version" -propertytype String -value "1" -force
    "JRE Latest Version frmwebutil.jar key set in registry." | out-file -filepath $LogFile -append
    "$divider" | out-file -filepath $LogFile -append#>
	
	"Copying script to destination" | out-file -filepath $logfile -append
	$dest = "c:\program files\fda\utils"
	copy-item $srcScriptPath $dest -force
	if (test-path "$dest\$scrScriptFile") {"File copy success" | out-file -filepath $logfile -append}
	else {"file copy fail" | out-file -filepath $logfile -append}
	
	"Creating ActiveSetup Entries" | out-file -filepath $logfile -append
    new-item -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerFixScript" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerFixScript" -name "(Default)" -propertytype String -value "JRE Latest Version Fix Script" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerFixScript" -name "StubPath" -propertytype String -value "powershell -executionpolicy bypass -file ""$dest\$srcscriptfile"" -sd" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\JRELatestVerFixScript" -name "Version" -propertytype String -value "1" -force
    "JRE Latest Version Jacob.jar key set in registry." | out-file -filepath $LogFile -append

}

if ($sd)
{
    "Executing fix for all existing users" | out-file -filepath $logfile -append
	$users = get-childitem -path "c:\users"
	foreach ($user in $users)
	{
        "Executing fix for user: $user" | out-file -FilePath $logfile -append
		$rootpath = "c:\users\$user"
        Add-Content -Path "$rootpath\$file1" -Value $setVal -force -erroraction SilentlyContinue
		Add-Content -Path "$rootpath\$file2" -Value $setVal -force -ErrorAction SilentlyContinue
	}
    "$divider" | out-file -filepath $LogFile -append
}

# ===================================================================================================

"Install CBER-Menu_JavaFix script complete at [$([DateTime]::now)]" | out-file -filepath $LogFile -append
"$divider" | out-file -filepath $LogFile -append





