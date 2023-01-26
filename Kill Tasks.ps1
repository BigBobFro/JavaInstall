$logfile = "c:\temp\templog.log"
"start log" | out-file -FilePath $logfile

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