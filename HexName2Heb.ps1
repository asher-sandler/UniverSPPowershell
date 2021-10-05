function ConvHexFieldToName($str){
	$result = ""
	$aStr = $str.split("_x")
    for($i=0;$i -lt $aStr.count;$i++){
		if (![string]::isNullOrEmpty($aStr[$i])){
			$result += [char][int]$([Convert]::ToString("0x"+$aStr[$i],10))
		}
	}
	return $result
}
ConvHexFieldToName "_x05de__x05d2__x05de__x05d4_"

