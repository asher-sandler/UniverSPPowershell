function Add-List($strField)
{
	$outList = New-Object 'System.Collections.Generic.List[psobject]'
	if (![string]::isNullOrEmpty($strField)){
		$xArr = $strField.Split(",").Split(";").Trim()
		foreach($xEl in $xArr)
		{
			$itemAlreadyExists = $false
			foreach($itmX in $outList){
				if ($itmX.ToLower() -eq  $xEl.ToLower()){
					$itemAlreadyExists = $true
					break
				}
			}
			if (!$itemAlreadyExists){
				$outList.Add($xEl);	
			}
		}
	} 
	return $outList
}
$x= Add-List("doclib,123,doclib;doclib,doclib2;xyz;123,456")
#$x
$clrLists = "doclib,123,doclib;doclib,doclib2;xyz;123,456"
$clrListArr = @()
if (![string]::isNullOrEmpty($clrLists)){
	$clrATmp = $clrLists.Split(";").Split(",")
	foreach($clrItm in $clrATmp){
		$clrListArr += $clrItm.Trim()
	}
}

$clrListArr = $clrListArr | Sort -Unique
$clrListArr
