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
#ConvHexFieldToName "_x05de__x05d2__x05de__x05d4_"
#ConvHexFieldToName "_x05db__x05d5__x05e1__x0020__x05"
ConvHexFieldToName '_x05e1__x05d8__x05d0__x05d8__x05'

