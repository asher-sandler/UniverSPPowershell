
$ViewName="Administration"
$ViewName="Rakefet"

$site = "-32-2022-Fields-"
$site = "-31-2021-Fields-"


$fileNameView = $ViewName +$site+ "View.txt"
$fileFormName = $ViewName +$site+ "Form.txt"

$viewf = get-content $fileNameView -encoding UTF8
$formf = get-content $fileFormName -encoding UTF8

foreach($viewl in $viewf){
	$vO = $viewl.trim()
	if(![string]::isNullOrEmpty($vO)){
		$fieldExists = $false
		foreach($forml in $formf){
			$fO = $forml.trim()
			if(![string]::isNullOrEmpty($fO)){
				if ($vO -eq $fO){
					$fieldExists = $true
					break
				}
			}	
		}
		if (!$fieldExists){
			write-host $vO 
		}
	}
}
