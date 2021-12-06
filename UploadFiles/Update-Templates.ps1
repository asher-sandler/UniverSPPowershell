#
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

$grsItems = get-item "\\ekeksql00\SP_Resources$\GRS\UploadFiles\*.xml"
$i=1
foreach ($grsitm in $grsItems){
	$groupName = "GRS_"+$grsitm.BaseName
	$grsJSONFileName = "..\JSON\"+$groupName+".json"
	if (Test-Path $grsJSONFileName){
		
		if (Test-CurrentSystem $groupName){
			#write-host $grsJSONFileName -f Cyan
			$spObj = get-content $grsJSONFileName -encoding default | ConvertFrom-Json
			$Credentials = get-SCred	

			$siteUrl    = get-CreatedSiteName $spObj
			write-host $i -f Cyan
			write-host $spObj.GroupName -f Green
			write-host $spObj.language -f Yellow
			write-host "New Site: $siteUrl" -foregroundcolor Magenta
			$destFileName = $grsitm.DirectoryName+"\OLD\"+$grsitm.Name
			write-host $destFileName  
			edt-DocUploadWP $siteUrl  $spObj
			copy-item $grsitm.Fullname $destFileName
			remove-item $grsitm.Fullname
			#read-host
			$i++
		}
		
		
	}
}

