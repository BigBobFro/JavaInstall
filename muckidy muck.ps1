$lists = "ECMS"
$srcpath = "c:\temp\java\javare_1.8u111"
$logfile = "c:\program files\fda\logs\install_java.log"
	

    [array]$exception2Load = $lists.split(",")
	
	foreach ($exceptionList in $exception2Load)
	{
		$importfile = "$srcpath\$exceptionList.sites"
		
		
		$DestFile = "C:\windows\sun\java\deployment\exception.sites"
		if (!(test-path $DestFile))	{""|out-file -filepath $destfile}
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