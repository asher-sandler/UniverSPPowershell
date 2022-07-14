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

function Copy-Submitted($srcSite, $dstSite,$langID){
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
	
   $subFolders = $srcList.Folders
	foreach($sFolder in $subFolders){
		$srcFolder 	   = $srcweb.GetFolder($sFolder.Url)


		$fldDateCreat = $sFolder["Created" ]
		$fldDateEdit  = $sFolder["Modified"]
		$fldWhoCreat  = $sFolder["Author"  ]
		$fldWhoEdit   = $sFolder["Editor"  ]
		$fldDescr     = $sFolder["description"]
		write-host $fldDateCreat
		write-host $fldDateEdit
		write-host $fldWhoCreat
		write-host $fldWhoEdit
		write-host $fldDescr
			
		$srcFolder | gm

		write-Host $srcFolder.Name
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
			#$newDocTypeID = Map-DocType $dstSite $srcDocTypeValue 
			
			$dstFile.Item["Created" ] = $srcDateCreat
			$dstFile.Item["Modified"] = $srcDateEdit
			$dstFile.Item["Author"  ] = $srcWhoCreat
			$dstFile.Item["Editor"  ] = $srcWhoEdit
			$dstFile.Item["description"] = "dhskjahdksa"
			#$dstFile.Item[$srcDocTypeFieldName] = $newDocTypeID
			$dstFile.Item.Update()
			
		}
		break
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
$srcSite =     "https://gss2.ekmd.huji.ac.il/home/FacultyofMedicine/MED15-2017/"
$archSubSite = "https://gss2.ekmd.huji.ac.il/home/FacultyofMedicine/MED15-2017/Archive-2022-07-14"
$languageID = 1037
$langID = $languageID
$dstSite = $archSubSite
#Copy-Submitted $srcSite $archSubSite $languageID
#Change-Theme $archSubSite
create-WPPage $archSubSite "DefaultHe" $true