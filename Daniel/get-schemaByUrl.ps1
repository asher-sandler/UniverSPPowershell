function change-DocLibHinich($siteName, $listURL){
	
	$siteName = get-UrlNoF5 $siteName	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials

	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	$List = $Web.GetList($listUrl)
	$Ctx.Load($List)
	$Ctx.ExecuteQuery()
  
  	$DefaultView = $list.DefaultView
    $Ctx.load($DefaultView) 
    $Ctx.ExecuteQuery()

    $ViewFields = $DefaultView.ViewFields
	$Ctx.load($ViewFields) 
    $Ctx.ExecuteQuery()
	
	#write-host $ViewFields
	
	
	$arrFields = $ViewFields.Split(" ")
	
	foreach($el in $arrFields){
		if ($el.Trim() -eq "Modified"){
			write-host $el -f Green
			$List.DefaultView.ViewFields.Remove("Modified")
			$List.DefaultView.Update()
			$Ctx.ExecuteQuery()			
		}
		if ($el.Trim() -eq "Editor"){
			write-host $el -f Green
			$List.DefaultView.ViewFields.Remove("Editor")
			$List.DefaultView.Update()
			$Ctx.ExecuteQuery()			
		}
			
		
	}
	
	
	return $null
	
}
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


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

	$Credentials = get-SCred

	#$schema = get-ListSchemaByUrl $siteURL $listUrl
	#$outFile = "32278698.json"
	#$schema | ConvertTo-Json -Depth 100 | out-file $outFile -Encoding Default
 
    #$defaultView = get-DefaultViewByURL  $siteURL $listUrl
	
	#$outFile = "32278698-DefaultView.json"
	#$defaultView | ConvertTo-Json -Depth 100 | out-file $outFile -Encoding Default
 	 
	
	#$siteURL = "https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders"
	$siteURL = "https://portals2.ekmd.huji.ac.il/home/Dental/StdFolders"
	
	#$students = Import-CSV 	studentsPURE.csv -Encoding Default
	$students = Import-CSV 	StudentList.csv -Encoding Default
	foreach($student in $students){
		#$listUrl = "/home/EDU/stdFolders/"+$student.StudentID
		$listUrl = "/home/Dental/StdFolders/"+$student.ID
		
		write-host $listUrl -f Cyan
		#read-host
	
	
		change-DocLibHinich $siteURL $listUrl
	}
