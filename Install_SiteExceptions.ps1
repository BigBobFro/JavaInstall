# Install Site Exceptions

# ===================================================================================================
# Constants
$srcPath = Split-Path -Path $MyInvocation.MyCommand.Path
$divider = "====================================================================================================================" 

$destpath = "c:\program files\fda\utils\JavaExceptions\"
If(-not(Test-Path -Path $DestPath) -eq $true)							# Create Directory if doesn't exist
	{New-Item -ItemType Directory -Path $DestPath}
	
$ExceptionLists = get-childitem $srcPath | ?{$_.name -like "SiteExceptions(*).ps1"} | select name

foreach ($list in ExceptionLists)
{
	copy-item $srcpath\$($list.name) $destpath
	$shortname = $list.name.substring(0,$($list.name.length - 4))
	$RegPath = "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\$shortname"
	new-item -path $regpath -force
	new-itemproperty -path $regpath -name "{Default}" -PropertyType String -value "User Specific Site Exceptions for $shortname" -force
	new-itemproperty -path $regpath -name "StubPath"  -PropertyType String -value "powershell -executionpolicy bypass -file ""$destpath\$list.name"" " -force
	new-itemproperty -path $regpath -name "Version"   -PropertyType String -value "20190220" -force

}