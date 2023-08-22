function get-WPIdArray($sContent){
$resArray = @()
$aID = $sContent | Select-String -Pattern "ms-rtestate-notify  ms-rtestate-read"

for ($i=0; $i -lt $aID.count; $i++){
	$findStr = 'id="div_'
	$nIdPos = $aID[$i].ToString().IndexOf($findStr)
	$sSubtr = $aID[$i].ToString().SubString($nIdPos+$findStr.Length)
	$nHyph  = $sSubtr.IndexOf('"')
	$resId = $sSubtr.Substring(0,$nHyph)
	
	$resArray += $resId
	}
	return $resArray
}
cls

$fNames = @()

$fNames += ".\DoubleLang\form.txt"
$fNames += ".\DoubleLang\home.txt"
$fNames += ".\DoubleLang\Recomendations.txt"
$fNames += ".\DoubleLang\SubmissionStatus.txt"
$fNames += ".\DoubleLang\CancelCandidaty.txt"


foreach ($name in $fNames){
	write-host
	write-host $name
	
	$cont = get-content $name
	get-WPIdArray $cont
	
	 
}

