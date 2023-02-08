	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.Portable.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Search.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
function copyPdf($drive, $FolderName,$source, $hug){
	if(Test-Path $source){
		#write-host "Copy From: $source" -f Green
		$destination = $drive+$FolderName+"\"+"תיק מועמדות"
		if (Test-Path $destination){
			
			
		    $itm = Get-Item $source
			$dtFile = $destination + "\" + $itm.BaseName+"-"+$hug+$itm.Extension
			write-host "Copy To: $dtFile" -f Green
			#write-host $dtFile -f Green
			if (Test-Path $dtFile)
			{
				#remove-item $dtFile
				write-host "$dtFile Already Exists" -f Yellow
				#read-host
			}
			else
			{
				#Copy-Item -Path $source -Destination $dtFile
				Copy-Item -Path $source -Destination $destination
				
				write-host "Ok" -f Green
				#read-host
			}
			
			
		}
		else
		{
			write-host "$destination Does Not exists" -f Yellow
		}
	}
	else
	{
		write-host "$source File Does not Exists" - f Yellow
	}
	return $null
	
}

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

Start-Transcript DocumentFill-FinalDoc.log
# Evgenia

$Credentials = get-SCred
 $rootflr = ""
 $destFiles = import-csv $(".\"+$rootflr +"finalList.csv" )
 $errorsInFinal = @()

 
 foreach($rowf in $destFiles){
	 $siteName = $rowf.site;
	 
	 $libName  = "ResponseLetters"
	 $destFolder = $rowf.destFolder
	 $potok = $rowf.potok
 	 $siteUrl = get-UrlNoF5 $siteName

	 #write-host "URL: $siteURL" -foregroundcolor Green
	 #write-host  $libName -f Cyan
	 #write-host  $destFolder -f Magenta
	$listExists = Check-ListExists $siteUrl  $libName
	if ($listExists){
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
		$Ctx.Credentials = $Credentials
	
		$schemaDocLibSrc1 = get-ListSchema	$siteUrl $libName
		$sourceDocObj = get-SchemaObject $schemaDocLibSrc1 
		$sourceDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$potok+"-"+$libName+"LibEvgDoc.json")

		$listItems = get-allListItemsByID $siteURL  $libName
	
		$studentsL = @()
		foreach($litem in $listItems){

		
	
			$stud = "" | Select-Object FileName,Title,Description 
			$stud.FileName 		= $litem["FileLeafRef"]
			$stud.Title 		= $litem["Title"]
			$stud.Description 	= $litem["description0"]
			if ($stud.FileName -eq "56565656.doc"){
				
			}
			else{
				$studentsL += $stud
			}	
		}
		$outFileName = ".\"+$potok+"-"+$libName+"-Students.csv"
		$studentsL | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8 

		$List = $Ctx.Web.Lists.GetByTitle($libName)
		$Ctx.Load($List)
		$Ctx.ExecuteQuery()
		 

		$Folder = $List.RootFolder
		$FilesColl = $Folder.Files
		$Ctx.Load($FilesColl)
		$Ctx.ExecuteQuery()
		
		$targetDir = $rootflr+$destFolder
		$TZList = @()
		Foreach($File in $FilesColl)
		{
			
			#$TargetFile = $targetDir + "\"+$File.Name
			if (!$(Test-Path $targetDir)){
				
				New-Item -Path $targetDir -ItemType directory
				
			}
			$newDir = $(get-Item $targetDir)
			$TargetFile = $newDir.FullName+"\"+$File.Name
			# 
			#
			#Download the file
			
			foreach($student in $studentsL){
				if ($student.FileName -eq $File.Name){
					#write-host $student.FileName -f Yellow
					if (!$(Test-Path $TargetFile)){
						#write-Host $TargetFile -f Yellow
						$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx,$File.ServerRelativeURL)
						$WriteStream = [System.IO.File]::Open($TargetFile,[System.IO.FileMode]::Create)
						$FileInfo.Stream.CopyTo($WriteStream)
						$WriteStream.Close()
					}
					#Write-Host $TargetFile
					$outfile = get-Item $TargetFile
					
					$TZLine = "" | Select-Object TZ,FullName,UserName
					$TZLine.TZ = $outfile.BaseName
					$TZLine.FullName = $outfile.FullName
					$TZLine.UserName = $student.Description.replace($TZLine.TZ,"")
					
					$TZList += $TZLine

					break
				}
			}
			#
		}
		$outFileName = ".\"+$targetDir +"\userList.csv"
		#if (!$(Test-Path $outFileName)){
			$TZList | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8
		#}
		net use w: /del	/yes
		net use w: https://portals.ekmd.huji.ac.il/home/EDU/stdFolders /yes /user:ekmd\ashersa GrapeFloor789
		#write-Host $siteName -f Green
		foreach($tzx in $TZList){
			$destPath = "W:\"+$tzx.tz # +"\תיק מועמדות"
			#write-host $destPath -f Green
			if (Test-Path $destPath){
				$source = $tzx.FullName
				#write-Host $source -f Cyan
				$hugSite = $siteName.split("/")[-2]
				copyPdf "W:" $tzx.TZ $source $hugSite
				#read-host
			}else
			{
				$ErrorsInFinal += ""
				$ErrorsInFinal += "=================================="

				$ErrorsInFinal += "On Site https://portals.ekmd.huji.ac.il/home/EDU/stdFolders"
				$ErrorsInFinal += "No Folder: $($tzx.TZ)"
				$ErrorsInFinal += "Student:  $($tzx.UserName)"
				$ErrorsInFinal += "Site: $siteUrl"
				
				$ErrorsInFinal += "=================================="
				$ErrorsInFinal += ""
				#write-Host $tzx.FullName -f Magenta
				$badDir = $(Get-Item $tzx.FullName).DirectoryName + "\EDU-Not-Found\"
				if (!$(Test-Path $badDir)){
				
					New-Item -Path $badDir -ItemType directory
					
				
				}				
				Copy-Item $($tzx.FullName) $badDir
				
				#write-host $("$destPath not Exists") -f Yellow
				#read-host
			}
		}
		
		foreach($tzx in $TZList){
			$destPath = "W:\"+$tzx.tz.substring(0,$tzx.tz.length-1) # +"\תיק מועמדות"
			#write-host $destPath -f Green
			if (Test-Path $destPath){
				write-Host "found $destPath" -f Magenta
				#read-host
			}

		}		
	

	}
 	else{
		#write-Host 
		
		#write-Host "$libName not Exists on Site $siteUrl" -f Yellow
		$ErrorsInFinal += ""
		$ErrorsInFinal += "************************************"
		$ErrorsInFinal += "$libName (מכתבי תשובה -קבצים) not Exists" 
		$ErrorsInFinal += "on Site $siteUrl"
		$ErrorsInFinal += "************************************"
		$ErrorsInFinal += ""
		#write-Host 
	}
 }	
 $outFileName = ".\"+$rootflr +"ErrorsInReponses.txt"
 write-Host "Written error log $outFileName"	
 $ErrorsInFinal | OUT-File $outFileName  -Encoding UTF8

 Stop-Transcript

 
 
 
 
 
 
 
 
 
 