param (
   [string] $time_check
)
$DateNow = date
$Date10minAgo = $DateNow.AddMinutes(-$time_check)
$dateStart = '"'+$Date10minAgo.toString("yyy-MM-dd HH-mm-ss")+'"'
$dateEnd = '"'+$DateNow.toString("yyy-MM-dd HH-mm-ss")+'"'
$jsonvirlog = C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get logs --name virlog --start-date $dateStart --end-date $dateEnd
RETURN $jsonvirlog
