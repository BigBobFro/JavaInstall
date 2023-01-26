


param(
	$Setting,
	$SettingLoc,
	$value
)

$DeplProp = "C:\Windows\sun\java\deployment\deployment.properties"
$DeplSett = "C:\Windows\sun\java\deployment\deployment.config"
$SiteExcp = "C:\Windows\sun\java\deployment\Sites.Exception"

switch ($settingLoc)
	{
		"DP" {$destFile = $DelpProp}
		"DS" {$destFile = $DelpSett}
		"SE" {$destFile = $SiteExcp}
	}

if (!(test-path $destFile)) {$null|out-file -filepath $destfile}

$prevSett = get-content $destfile

switch ($value)
	{
		"Locked" {$2set = "$setting.locked"}
		default {$2set = "$setting=$value"}
	}

if ($prevsett -contains $setting)
{
	#validate that the setting is correct
	
}
else {$2set|out-file -filepath $destFile -append}

<#
		$importfile = "$srcpath\SiteLists\$exceptionList.sites"	
		$DestFile = "C:\windows\sun\java\deployment\exception.sites"
		if (!(test-path $DestFile))	{""|out-file -filepath $destfile}
		if (!(test-path $importfile)) {"No Exceptions list for $exceptionList"|out-file -filepath $logfile -append}
		else
		{
			$PrevExceptions = get-content $destFile
			$importdata = get-content $importfile
			foreach ($site in $importdata)
			{
				if ($prevExceptions -contains $site)
					{"Site Exception $site skipped. Already excepted."|out-file -filepath $logfile -append}
				else
				{
					"$site"|out-file -filepath $destFile -append
					"Site Exception $site added."|out-file -filepath $logfile -append
				}
			}
		}
#>