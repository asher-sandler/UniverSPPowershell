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
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
function get-OldDefaultX($oldSiteName,$pageN){
	$pageName = "Pages/"+$pageN
	$siteName = get-UrlNoF5 $oldSiteName
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	
	#write-host $pageURL 
	#read-host


	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials



	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();


	$page.CheckOut()
	$pageFields = $page.ListItemAllFields

	$PageContent = $pageFields["PublishingPageContent"]
	
	#$page.CheckIn("",1)
	$page.UndoCheckOut()
	
	$ctx.ExecuteQuery()	
	
	return $PageContent
	
}
function edt-HomePageX($newSiteName, $Pagen,$content){
	$pageName = "Pages/"+$Pagen
	$siteName = get-UrlNoF5 $newSiteName
	
	$relUrl   = get-RelURL $siteName
	
	$pageURL  = $relUrl + $pageName
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials



	$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	
	$page.CheckOut()
	
	
	$pageFields = $page.ListItemAllFields
	
	$pageFields["PublishingPageContent"] = $content
	
	$pageFields.Update()
	
	$ctx.Load($pageFields)
	$ctx.ExecuteQuery();
	
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()
	write-host "$pageName Was Updated" -foregroundcolor Green
}


$cred = get-SCred


 $siteName = "https://hss2.ekmd.huji.ac.il/home/";
 $ListName="availableScholarshipsList"

	 

 
 write-host "URL: $siteName" -foregroundcolor Yellow
 
 
 $siteUrl = get-UrlNoF5 $siteName

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 $List = $Ctx.Web.lists.GetByTitle($listName)
 $dt = Get-Date
 $dt.AddDays(-2)
 $dtS = $dt.Year.ToString()+"-"+$dt.Month.ToString().PadLeft(2,"0")+"-"+$dt.Day.ToString().PadLeft(2,"0") + "T03:00:00Z"

	#Define the CAML Query
  $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
 
  $qry = "<View><Query></Query></View>"
    $Query.ViewXml = $qry
  
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	#$i= $ListItems.Count
	
	$opendeSites = @()
	forEach($reqstItem in $ListItems){
		$urlSite = get-UrlNoF5 $reqstItem["url"]
		
		$deadline = $reqstItem["deadline"]
		if ($deadline -ge $((get-Date).AddDays(-1))){
			$i++
			$siteProps =  "" | Select-Object URL, Deadline, Lang
			$siteProps.URL = $urlSite
			$siteProps.Deadline = $deadline
			$jsonFile = "JSON\HSS_" + $urlSite.split("/")[-1]+".json"
			if (Test-Path $jsonFile){
				#write-Host 
				$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
				$siteProps.Lang = $spObj.language
			}
			$opendeSites += $siteProps
			#write-host "$urlSite ; $deadline" -f Yellow
			
		}
		
	}
	Write-Host "Open Sites Found: $($opendeSites.Count) " -f Yellow
	
	$i=0;
	forEach($sProp in $opendeSites){
		$jsonFile = "JSON\HSS_" + $sProp.URL.split("/")[-1]+".json"
		if (Test-Path $jsonFile){
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			$lang = $spObj.language
			
		}
		else
		{
			$lang = "He"
		}
        if ($lang.ToUpper().contains("HE") -and $lang.ToUpper().contains("EN"))
		{
			# two language siteName
			$contentDefEn = get-OldDefaultX $sProp.URL "Default.aspx" 
			$contentDefHe = get-OldDefaultX $sProp.URL "DefaultHe.aspx" 
			
			$fileName = "Daniel\HSS_"+$sProp.URL.split("/")[-1]+"-EN.txt"
			
			$stringA = 'a href="/' + $sProp.URL.split("/")[-3]+"/"+$sProp.URL.split("/")[-2]+"/Pages/DocumentsUpload.aspx"+'"'
			$stringS = 'B. Upload the following documents to your personal folder'
			$stringARX = 'a href="/' + $sProp.URL.split("/")[-3]+"/"+$sProp.URL.split("/")[-2]+"/"+$sProp.URL.split("/")[-1]+"/Pages/DocumentsUpload.aspx"+'"'
			
			$stringAT =  'upload instructions'
			$stringATR = 'Documents Upload page'
			
			if (!$contentDefEn.Contains($stringS))
			{
				$stringS = 'B. Please upload the following documents according to the'
				if (!$contentDefEn.Contains($stringS)){
					Write-Host "$fileName Not Contains S" -f Yellow
				}				
			}

			if (!$contentDefEn.Contains($stringA))
			{
				Write-Host "$fileName Not Contains A" -f Yellow				
			}
			if (!$contentDefEn.Contains($stringAT))
			{
				Write-Host "$fileName Not Contains T" -f Yellow				
			}
			$stringA = 'a href="/' + $sProp.URL.split("/")[-3]+"/"+$sProp.URL.split("/")[-2]+"/Pages/DocumentsUpload.aspx"+'"'
			$stringARX = 'a href="/' + $sProp.URL.split("/")[-3]+"/"+$sProp.URL.split("/")[-2]+"/"+$sProp.URL.split("/")[-1]+"/Pages/DocumentsUpload.aspx"+'"'

			#$ContentDefEn = $ContentDefEn -Replace $stringAT, $stringATR
			$ContentDefEn = $ContentDefEn -Replace $stringA, $stringARX
			#$ContentDefEn = $ContentDefEn -Replace $stringS, $stringSR
			

			$contentDefEn | Out-File $fileName -Encoding UTF8
			write-Host $sProp.URL -f Cyan
			write-Host "Default.aspx"
			
			edt-HomePageX  $sProp.URL "Default.aspx" $contentDefEn

			$stringS = 'ב. להעלות את המסמכים הבאים לתיקיית העלאת מסמכים אישית לפי'
			$stringSR = 'ב. להעלות את המסמכים הבאים באמצעות '
			
			$stringA = 'a href="/home/Pages/InstructionsHe.aspx" target="_blank"'
			$stringAT =  'ההוראות המופיעות'
			$stringATR = "דף העלאת המסמכים"	
			
			$fileName = "Daniel\HSS_"+$sProp.URL.split("/")[-1]+"-HE.txt"

			if (!$contentDefHe.Contains($stringS))
			{
				Write-Host "$fileName Not Contains S" -f Yellow				
			}

			if (!$contentDefHe.Contains($stringA))
			{
				Write-Host "$fileName Not Contains A" -f Yellow				
			}

			if (!$contentDefHe.Contains($stringAT))
			{
				Write-Host "$fileName Not Contains T" -f Yellow				
			}
			$stringA = 'a href="/' + $sProp.URL.split("/")[-3]+"/"+$sProp.URL.split("/")[-2]+"/Pages/DocumentsUpload.aspx"+'"'
			$stringARX = 'a href="/' + $sProp.URL.split("/")[-3]+"/"+$sProp.URL.split("/")[-2]+"/"+$sProp.URL.split("/")[-1]+"/Pages/DocumentsUpload.aspx"+'"'
			#$ContentDefHe = $ContentDefHe -Replace $stringAT, $stringATR
			$ContentDefHe = $ContentDefHe -Replace $stringA, $stringARX
			#$ContentDefHe = $ContentDefHe -Replace $stringS, $stringSR

			$contentDefHe | Out-File $fileName -Encoding UTF8

			write-Host $sProp.URL -f Cyan
			write-Host "DefaultHe.aspx"
			edt-HomePageX  $sProp.URL "DefaultHe.aspx" $contentDefHe
		}
        else{
			$contentDef = get-OldDefaultX $sProp.URL "Default.aspx" 
			$fileName = "Daniel\HSS_"+$sProp.URL.split("/")[-1]+"-EN.txt"
			$stringA = '"/home/Pages/InstructionsEn.aspx" target="_blank"'
			$stringAT =  'upload instructions'
			
			$stringS = 'B. Upload the following documents to your personal folder'
			$stringSR = 'B. The following documents should be uploaded via the '
			
			$stringATR = 'Documents Upload page'
			$stringARX = 'a href="/' + $sProp.URL.split("/")[-3]+"/"+$sProp.URL.split("/")[-2]+"/Pages/DocumentsUpload.aspx"+'"'
			
			
			
			if ($lang.ToUpper().contains("HE")){
				$stringS = 'ב. להעלות את המסמכים הבאים לתיקיית העלאת מסמכים אישית לפי'
				$stringA = 'a href="/home/Pages/InstructionsHe.aspx" target="_blank"'
				$stringSR = 'ב. להעלות את המסמכים הבאים באמצעות '
				$stringAT =  'ההוראות המופיעות'
				$stringATR = "דף העלאת המסמכים"	
				$fileName = "Daniel\HSS_"+$sProp.URL.split("/")[-1]+"-HE.txt"
			}
			if (!$contentDef.Contains($stringS))
			{
				$stringS = 'ב. להעלות את המסמכים הבאים (בעברית או באנגלית) לתיקיית העלאת מסמכים אישית לפי'
				if (!$contentDef.Contains($stringS)){
					$stringS = 'להעלות את המסמכים הבאים לתיקיית העלאת מסמכים אישית'
					# !!
					if (!$contentDef.Contains($stringS)){
						$stringS = 'B. Upload the following documents to your personal folder (see'
						$stringSR = 'B. The following documents should be uploaded via the '
						$stringATR = 'Documents Upload page'
						if (!$contentDef.Contains($stringS)){
							Write-Host "$fileName Not Contains S" -f Yellow
							
						}
					}
				}				
			}

			if (!$contentDef.Contains($stringA))
			{
				$stringA = 'href="/home/Pages/InstructionsHe.aspx"'
				if (!$contentDef.Contains($stringA)){
					$stringA = '"/home/Pages/InstructionsEn.aspx" target="_blank"'
					if (!$contentDef.Contains($stringA)){
					
						Write-Host "$fileName Not Contains A" -f Yellow	
					}
				}	
			}
			
			if (!$contentDef.Contains($stringAT)){
				$stringAT =  'instructions for uploading'
				$stringATR = 'Documents Upload page'
				if (!$contentDef.Contains($stringAT)){
					Write-Host "$fileName Not Contains T" -f Yellow	
				}
			}
			$stringA = 'a href="/' + $sProp.URL.split("/")[-3]+"/"+$sProp.URL.split("/")[-2]+"/Pages/DocumentsUpload.aspx"+'"'
			$stringARX = 'a href="/' + $sProp.URL.split("/")[-3]+"/"+$sProp.URL.split("/")[-2]+"/"+$sProp.URL.split("/")[-1]+"/Pages/DocumentsUpload.aspx"+'"'
			
			#$contentDef = $contentDef -Replace $stringAT, $stringATR
			$contentDef = $contentDef -Replace $stringA, $stringARX
			#$contentDef = $contentDef.Replace($stringS, $stringSR)
			
			
			
			
			
			
			
			$contentDef | Out-File $fileName -Encoding UTF8
			
			#if ($sProp.URL.split("/")[-1] -eq "EDU127-2021"){
				write-Host $sProp.URL -f Cyan
				edt-HomePageX  $sProp.URL "Default.aspx" $contentDef
			#}
			
			
		}		

	}
	$outCSV = "JSON\HSS_Sites.csv"
	
	$opendeSites | Export-CSV -Path $outCSV -Encoding Default -NoTypeInfo
	