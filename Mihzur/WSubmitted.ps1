function Change-Theme ( $siteURL)
{
	$validThemes = "Sea Monster","Nature","Blossom","Sketch","City","Orbit","Characters","Breeze","Immerse","Wood"

	$spWeb = Get-SPWeb $siteURL
	$designCatalog = $spWeb.Site.GetCatalog("Design")
	$random = get-random -Minimum 0 -Maximum $($validThemes.Count-1)
	$ApplyiedTheme = $validThemes[$random]
	write-Host "Apply Theme: $ApplyiedTheme"
	$theme = $designCatalog.Items | Where{$_.Name -eq $ApplyiedTheme}
	$spweb.ApplyTheme($theme["ThemeUrl"].Split(",")[1].Trim(), $null, $theme["ImageUrl"].Split(",")[1].Trim(), $true) 

	#$theme = $designCatalog.Items | Where{$_.Name -eq "Immerse"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Sea Monster"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Nature"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Blossom"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Sketch"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "City"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Orbit"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Characters"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Immerse"}
	#$theme = $designCatalog.Items | Where{$_.Name -eq "Wood"}
	
<#
Sea Monster+
Nature /green/
Blossom /rose/
Sketch+  
City	/black/
Orbit  /black/
Characters
Breeze+
Immerse
Wood
#>

}
function Map-DocType($siteURL, $DocTypeValue){
	$retValue = $null
	$spWeb = get-SPWeb $siteURL
	$docTypeList = $spWeb.Lists["DocType"]
	$found = $false
	foreach($item in $docTypeList.Items){
		if ($item.Name -eq $DocTypeValue){
			$retValue = $item.ID
			#write-Host "found ID"
			$found=$true
			break
		}
	}
	if (!$found){
			write-Host "not found ID for: $DocTypeValue" -f Yellow
	}
	return $retValue
}
function Copy-SubmittedX($srcSite, $dstSite,$langID){
	$srcweb = get-SPWeb $srcSite
	$applList = $srcweb.Lists['Applicants']
	$applItems = $applList.Items
	$applItemscount = $applItems.Count 
	write-Host "Applicants items count : $applItemscount"
	$maxCount = 10
	$cnt =0
	foreach($applItem in $applItems){
		
		
		$docfolder = [string]$applItem['documentsCopyFolder']
		if (![string]::isNullOrEmpty($docfolder)){
			#write-Host $cnt
			$firstPart = $docfolder.Split(",")[0].Trim()
			$secondPart = $firstPart.Split("/")
			$submitfolder = $secondPart[-2]+"/"+$secondPart[-1]
			do-Submitted $srcSite $dstSite $langID $submitfolder
			write-Host $submitfolder
		}
		$cnt++
		if ($cnt -ge $maxCount){
			write-Host "$cnt Rows was readed"
			break
			
		}
	}
	
	
	change-DefView $srcSite $dstSite "Submitted"
	
}
function change-DefView($srcSite, $dstSite,$docLibName){
	
	write-host $srcSite
	write-host $dstSite
	write-host $docLibName
	
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists[$docLibName]
	#$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists[$docLibName]
	write-host "change Default View of $docLibName"
	<#
	$dstList.DefaultView.Query = $srcList.DefaultView.Query
	$dstList.DefaultView.Update()
	$dstList.Update()
	#>
	
	$dstDefView = $dstList.DefaultView
	$vwFields =  @()
	$vwFields += "Edit"
	foreach($fld in $dstDefView.ViewFields)
	{
		$vf = $fld 
		if ($vf -eq "Modified"){
			Continue
		}
		if ($vf -eq "Edit"){
			Continue
		}
		
		
		$vwFields += $vf
	}

	$dstDefView.ViewFields.DeleteAll();
	foreach($xF in $vwFields){
		$dstDefView.ViewFields.Add($xF)	
	}
	#write-Host $srcList.DefaultView.Query
	$dstDefView.Query = $srcList.DefaultView.Query
	$dstDefView.Update()
	
	$dstList.Update()
	
	
	

	
}
function do-Submitted($srcSite, $dstSite,$langID,$sFolder){
	$docLibName = "Submitted"
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)
	
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists[$docLibName]
	$srcFolder 	   = $srcweb.GetFolder($srcList.RootFolder.Url)

	$srcDocTypeFieldName = "Document Type"
	if ($langID -eq 1037){
		$srcDocTypeFieldName = "תוכן קובץ"
	}
	
    #$subFolders = $srcList.Folders
	<#
The following exception occurred while trying to enumerate the collection: 
"The attempted operation is prohibited because it exceeds the list view threshold enforced by the administrator.".	
	#>
	#foreach($sFolder in $subFolders){
		$srcFolder 	   = $srcweb.GetFolder($sFolder)
		
		$fldDateCreat = $srcFolder.Item["Created" ]
		$fldDateEdit  = $srcFolder.Item["Modified"]
		$fldWhoCreat  = $srcFolder.Item["Author"  ]
		$fldWhoEdit   = $srcFolder.Item["Editor"  ]
		$fldDescr     = $srcFolder.Item["description"]
		
		write-Host $srcFolder.Name
		write-Host $fldDateCreat
		write-Host $fldDateEdit
		write-Host $fldWhoCreat
		write-Host $fldWhoEdit
		write-Host $fldDescr
		write-host --------------
		$folder = $dstList.ParentWeb.GetFolder($dstList.RootFolder.Url + "/" +$srcFolder.Name);
		
		If(!$folder.Exists)
		{
		   #Create a Folder
		   $folder = $dstList.AddItem([string]::Empty, [Microsoft.SharePoint.SPFileSystemObjectType]::Folder, $srcFolder.Name)
		   $folder.Update();
		   # write-host "Created Folder '$fldNew'" -f Green
		}

		$folder = $dstList.ParentWeb.GetFolder($dstList.RootFolder.Url + "/" +$srcFolder.Name);

		$folder.Item["Created" ] = $fldDateCreat
		$folder.Item["Modified"] = $fldDateEdit		
		$folder.Item["Author"  ] = $fldWhoCreat		
		$folder.Item["Editor"  ] = $fldWhoEdit	
		$folder.Item["description"] = $fldDescr	
		$folder.Item.Update()
		
		foreach($sFile in $srcFolder.Files)
		{
			$srcDocTypeValue = new-object Microsoft.SharePoint.SPFieldLookupValue($sFile.Item[$srcDocTypeFieldName] )
			$srcDocTypeValue = $srcDocTypeValue.LookupValue
			$srcDateCreat = $sFile.Item["Created" ]
			$srcDateEdit  = $sFile.Item["Modified"]
			$srcWhoCreat  = $sFile.Item["Author"  ]
			$srcWhoEdit   = $sFile.Item["Editor"  ]
			$srcDescription  = $sFile.Item["description"]
			
			$srcData = $sFile.OpenBinary()
			$fileName = $dstList.RootFolder.Url + "/"+$srcFolder.Name + "/" + $sFile.Name
			Write-host -f Yellow $fileName

			$dstFile = $dstFolder.Files.Add($fileName,$srcData,$true)
			$newDocTypeID = Map-DocType $dstSite $srcDocTypeValue 
			
			$dstFile.Item["Created" ] = $srcDateCreat
			$dstFile.Item["Modified"] = $srcDateEdit
			$dstFile.Item["Author"  ] = $srcWhoCreat
			$dstFile.Item["Editor"  ] = $srcWhoEdit
			$dstFile.Item["description"]  = $srcDescription
			#               description
			$dstFile.Item[$srcDocTypeFieldName] = $newDocTypeID
			$dstFile.Item.Update()
			
		}
		$dstList.Update()

	#}
		


	<#	
	$dstDefView = $dstList.DefaultView
	$vwFields =  @()
	$vwFields += "Edit"
	foreach($fld in $dstDefView.ViewFields)
	{
		$vf = $fld 
		if ($vf -eq "Modified"){
			Continue
		}
		
		$vwFields += $vf
	}

	$dstDefView.ViewFields.DeleteAll();
	foreach($xF in $vwFields){
		$dstDefView.ViewFields.Add($xF)	
	}
	$dstDefView.Update()
	#>
	return $null
	
}
function get-PageContent($siteURL, $PageName, $pageField){
	$spWeb = Get-SPWeb $siteURL
	write-Host $siteURL
	
    $pageFullName = "Pages/" + $PageName + ".aspx"
	write-Host $pageFullName
	$page = $spweb.GetFile($pageFullName)
	$PageContent = ""
    if ($page.exists){
		$page.CheckOut()
		$pageFields = $page.ListItemAllFields
		$PageContent = $pageFields[$pageField]
		$page.UndoCheckOut()
	}
	return $PageContent
}
function Update-PageContent($siteURL, $PageName, $pageField,$Content){
	$spWeb = Get-SPWeb $siteURL
	write-Host $siteURL
	
    $pageFullName = "Pages/" + $PageName + ".aspx"
	write-Host $pageFullName
	$page = $spweb.GetFile($pageFullName)
	$PageContent = ""
    if ($page.exists){
		$page.CheckOut()
		$pageFields = $page.ListItemAllFields
		$pageFields[$pageField] = $Content
		$pageFields.Update()
		$page.CheckIn('')
		
		$page.Publish('')
	}
	return $null
	
}
function create-WPPage($siteURL, $PageName, $setDefault){
	$spWeb = Get-SPWeb $siteURL
	write-Host $siteURL
    $pageFullName = "Pages/" + $PageName + ".aspx"
	$pageFile = $spweb.GetFile($pageFullName)
    if ($pageFile.exists){
		
	}
	else
	{
		$pubWeb =[Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spWeb)
		# Create blank web part page
		$pl = $pubWeb.GetAvailablePageLayouts() | Where { $_.Name -eq "BlankWebPartPage.aspx" } #you may change "BlankWebPartPage.aspx" to your custom page layout file name
		$newPage = $pubWeb.AddPublishingPage($PageName + ".aspx", $pl) #filename need end with .aspx extension
		$newPage.Update()
		# Check-in and publish page
		$newPage.CheckIn("")
		$newPage.ListItem.File.Publish("")
		
		
		
	}
	if ( $setDefault){
		$pageFile = $spWeb.GetFile($pageFullName)
		$pubWeb =[Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($spWeb)
		$pubWeb.DefaultPage = $pageFile
		$pubWeb.Update();
		$spweb.Update()
	}

 
}
Add-PsSnapin Microsoft.SharePoint.PowerShell
$srcSite =     "https://gss2.ekmd.huji.ac.il/home/FacultyofMedicine/MED15-2017/"
$srcSite =     "https://gss2.ekmd.huji.ac.il/home/FacultyofMedicine/MED15-2017"
$srcSite =     "https://gss2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN27-2020/"
$archSubSite = $srcSite +"Archive-2022-07-20-1"
$languageID = 1033
$langID = $languageID
$dstSite = $archSubSite
#Copy-SubmittedX $srcSite $archSubSite $languageID
change-DefView $srcSite $archSubSite "Submitted"
#Change-Theme $archSubSite
#create-WPPage $archSubSite "Default" $true

<#
$Content = get-PageContent $srcSite "default" "PublishingPageContent"
$Title = get-PageContent $srcSite "default" "Title"
$ContentHe = get-PageContent $srcSite "defaultHe" "PublishingPageContent"
$TitleHe = get-PageContent $srcSite "defaultHe" "Title"

Update-PageContent $archSubSite "default" "PublishingPageContent" $Content
Update-PageContent $archSubSite "default" "Title" $Title
Update-PageContent $archSubSite "defaultHe" "PublishingPageContent" $ContentHe
Update-PageContent $archSubSite "defaultHe" "Title" $TitleHe
#>


