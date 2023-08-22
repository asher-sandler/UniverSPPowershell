$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)


$readmeFiles = @{sDir = "\\ekekaiosp05\c$\AdminDir\Send2Rakefet\" ;source="readme";htmlName="ReadMe-SendRakefet"},
			  @{sDir = "\\ekekaiosp05\c$\AdminDir\TSS-Reminders\" ;source="readme";htmlName="ReadMe-TSSReminder"},
			  @{sDir = "\\ekekaiosp05\c$\AdminDir\ContractorsReminder\" ;source="readme";htmlName="ReadMe-ContrRemider"},
			  @{sDir = "\\ekekaiosp05\c$\AdminDir\Mihzur\" ;source="ReadMe-ClearSite";htmlName="ReadMe-ClearSite"},
			  @{sDir = "\\ekekaiosp05\c$\AdminDir\Mihzur\" ;source="ReadMe-Mihzur";htmlName="ReadMe-Mihzur"}


foreach ($rFile in $readmeFiles){
	$sFile = Join-Path $rFile.sDir  $($rFile.source + ".txt")
	
	if (Test-Path $sFile){
		#Write-Host $sFile -f Cyan
		$txtFile = Join-Path $dp0 $($rFile.htmlName + ".txt")
		#Write-Host $txtFile -f Magenta
		if (Test-Path $txtFile){
			Remove-Item $txtFile
			
		}
		Write-Host "================================"
		
		write-host "Copy From: $sFile To: $txtFile" -f Yellow
		
		
		Copy-Item $sFile $txtFile
		$htmlFile = Join-Path $dp0 $($rFile.htmlName + ".html")
		if (Test-Path $htmlFile){
			Remove-Item $htmlFile
			
		}
		Write-Host "--------------------------------"
		.\Gen-Readme.ps1 $txtFile $htmlFile	
        $originHtmlName = Join-Path $rFile.sDir $($rFile.htmlName + ".html")
		
        if (Test-Path $originHtmlName){
			
			Remove-Item $originHtmlName
		}
		Write-Host 	$originHtmlName  " Was Created!"-f Yellow
        Copy-Item $htmlFile $originHtmlName		
		
	}
	else
	{
		Write-Host $sPath " Not Found" -f Yellow
	}
}

