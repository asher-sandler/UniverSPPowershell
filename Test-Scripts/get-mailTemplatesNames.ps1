if (Test-Path ".\mailTemplates.csv"){
	$ietems = Import-Csv "mailTemplates.csv" -Encoding Default
}
else
{
	$pName = "\\ekeksql00\SP_Resources$\"
	$ietems = get-ChildItem -Path   $pName  -recurse -Directory | where-Object {$_.Name.Contains("mailTemplates")} | Select FullName

	$ietems | Export-Csv "mailTemplates.csv" -Encoding Default
}

foreach($dir in $ietems){
	#write-host $dir.FullName
	$prefix = $dir.FullName.Split("\")[-2]
	if ($prefix.length -eq 3){
		#Write-Host $prefix
		Write-Host $dir.FullName
		
		write-host $fileName
		$arrEn = @()
		$arrHe = @()
		$arrEn += $dir.FullName
		$arrHe += $dir.FullName
		
		$itemsPath =  $dir.FullName + "\*.txt"
		$itemsDir = get-Item -Path $itemsPath
		#$arrEn += $itemsDir.count
		$enFiles = 0
		$heFiles = 0
		foreach($itemFile in $itemsDir){
			$fileCont = get-content $itemFile -Encoding UTF8
			write-host $itemFile
			if ($fileCont[3].Contains("for")){
				$arrEn += $fileCont[3]
				$enFiles++
			}
			else{
				copy-item $itemFile ".\file-utf8.txt" 
				cmd.exe /c "cnvr.cmd"
				$fileCont = get-content ".\file-utf8-win.txt" -Encoding UTF8
				$arrHe += $fileCont[3]
				write-host $fileCont[3]
				$heFiles++
				#read-host
			}
		
		}
		$arrEn += "ENCount : $enFiles"
		$arrHe += "HeCount : $heFiles"
		$fileNameEn = $prefix + "-En.txt"
		$fileNameHe = $prefix + "-He.txt"
		$arrEn | Out-File $fileNameEn -Encoding Default
		$arrHe | Out-File $fileNameHe -Encoding UTF8
		#write-host $itemsDir.count
		#read-host
	}
}

