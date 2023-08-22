function get-SiteNameFromNote($note){
	$sName = ""
	if (![string]::IsNullOrEmpty($note)){
		[regex]$regex = '(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?'
		$siteName = $regex.Matches($note).Value
		
		if (![string]::IsNullOrEmpty($siteName)){
			$sName = "https://"
			$aName = $siteName.split("/")
			for ($i = 2; $i -le 5; $i++ ){
				$sName += $aName[$i] + "/"
			}
		}
		
		
	}
	write-Host "Old Site Name : $sName" -foregroundcolor Green
	
	return $sName
}


$note = "אין אתר קודם אבל כל האתרים של חלקלאות באותו מבנה של הטופס"
get-SiteNameFromNote $note
