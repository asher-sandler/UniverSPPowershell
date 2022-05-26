param([string] $groupName = "",

	[Parameter(Mandatory=$false)]
	[ValidateSet("No", "Yes")]
	[string[]]$DeleteJson = "No"
)
function gen-HtmlPerm($objPerm,$retHTML, $oldSiteURL, $siteUrl){
	$permHTML = ""
	foreach($permRow in $objPerm){
		$permHTML += get-content ".\HtmlLog\rowReportPerm.html"	
		$permHTML = $permHTML -Replace "{PERMLISTNAME}",$permRow.List
		#write-Host 	$permRow -f Cyan	
		$permHTML = $permHTML -Replace "{PERMLISTDIFF}",$permRow.PermDifference		
	}
	$retHTML = $retHTML -Replace "{ROWREPORTPERMISSIONS}",$permHTML
	return $retHTML	
}
function gen-HtmlWP($objWP,$retHTML,$outPerm, $oldSiteURL, $siteUrl)
{
	$wpHTML = ""
	$siteDomainOld = [System.Uri]$(get-UrlWithF5 $oldSiteURL)
	$siteDomainNew = [System.Uri]$(get-UrlWithF5 $siteUrl)
	
	$realDomOld = $(get-UrlWithF5 $oldSiteURL) -Replace $siteDomainOld.AbsolutePath,""
	$realDomNew = $(get-UrlWithF5 $siteUrl)    -Replace $siteDomainNew.AbsolutePath,""
	
	foreach($wpRow in $objWP){
		$randomID = Get-FiveRandomLetters
		$wpHTML += get-content ".\HtmlLog\rowReportWP.html"
		$sourcePageName = $wpRow.SourcePageURL.Split("/")[-1]
		$destPageName = $wpRow.DestPageURL.Split("/")[-1]
		$wpHTML = $wpHTML -Replace "{SourcePageURL}",$($realDomOld + $wpRow.SourcePageURL)
		$wpHTML = $wpHTML -Replace "{DestPageURL}",$($realDomNew + $wpRow.DestPageURL)
		$wpHTML = $wpHTML -Replace "{SourcePageName}",$sourcePageName
		$wpHTML = $wpHTML -Replace "{DestPageName}",$destPageName
		
		$wpHTML = $wpHTML -Replace "{WebPartName}",$wpRow.WebPartName
		$wpHTML = $wpHTML -Replace "{WebPartKey}",$wpRow.WebPartKey
		$wpHTML = $wpHTML -Replace "{WebPartValueSRC}",$wpRow.WebPartValueSRC
		$wpHTML = $wpHTML -Replace "{WebPartValueDST}",$wpRow.WebPartValueDST
	}
	
	
	$retHTML = $retHTML -Replace "{ROWREPORTWEBPART}",$wpHTML
	return $retHTML
}

function gen-HtmlFLD($objLST, $oldSiteURL, $siteUrl, $siteTitle){
	$retHTML = get-content ".\HtmlLog\10ContraintTemplate.html"
	
	$rowReportHTML = ""
	foreach($rowList in $objLST){
		if (!$($rowList.ListExistsOnDest -and $rowList.FieldsNotFoundInDest.count -eq 0 )){
			write-Host "7 $($rowList.ListName)"
			#read-host
			$rowReportHTML += get-content ".\HtmlLog\rowReportField.html"
			$rowReportHTML = $rowReportHTML -Replace "{LISTNAME}",$rowList.ListName
			$rowReportHTML = $rowReportHTML -Replace "{LISTEXISTS}",$rowList.ListExistsOnDest
			$alert = "danger"
			if ($rowList.ListExistsOnDest){
				$alert = "info"
			}
			$rowReportHTML = $rowReportHTML -Replace "{ALERT}",$alert	
			$colFieldHTML = ""
			foreach ($colField in $rowList.FieldsNotFoundInDest){
				write-Host "14 $($colField.FieldName)"
				#read-host
				
				$colFieldHTML += get-content ".\HtmlLog\colReportField.html"
				$colFieldHTML = $colFieldHTML -Replace "{FIELDNAME}",$colField.FieldName
				
			}
			$rowReportHTML = $rowReportHTML -Replace "{FieldsNotFound}",$colFieldHTML
		}
	}
	$dt = get-Date
	$dtString = $dt.day.tostring().PadLeft(2,"0")+"."+$dt.month.tostring().PadLeft(2,"0")+"."+$dt.year+" "+$dt.hour.tostring().PadLeft(2,"0")+":"+$dt.minute.tostring().PadLeft(2,"0")
	#write-Host $rowReportHTML
	
	$retHTML = $retHTML -Replace "{SiteName}", $siteTitle
	$retHTML = $retHTML -Replace "{DateNow}", $dtString
	$retHTML = $retHTML -Replace "{OldSite}", $(get-UrlWithF5 $oldSiteURL)
	$retHTML = $retHTML -Replace "{NewSite}", $(get-UrlWithF5 $siteUrl)
	$retHTML = $retHTML -Replace "{ROWREPORTFIELD}", $rowReportHTML
	return $retHTML 
}

function CreatePropsArr($Props){
	$wpPropsActual = @()	
	$members = $Props | gm
	$mCount = $members.Count
	for($i=0;$i -lt $mCount; $i++){
		$mType = $members[$i].ToString().split(" ")[0]
		$mOstatok = $($members[$i].ToString() -Replace $mType, "").trim()
		if (!$mOstatok.contains("(")){
			$mOArr = $mOstatok.split("=")
			
			$props = "" | Select Key, Value
			$props.Key = $mOArr[0]
			$props.Value = $mOArr[1]
			$wpPropsActual += $props
			
			
		}
		
		
	}
	return $wpPropsActual
		
}
function CompareWPProps( $webPartDst, $webPartSrc,$srcPageURL, $dstPageURL){
	#write-host $webPartDst.Properties 
	#$mo = $webPartDst.Properties   
	#write-host "keys: $mo"
	#$propsCount = $webPartDst.Properties.length
	$errorWP = @()
	$wpPropsDst =  CreatePropsArr $webPartDst.Properties
	$wpPropsSrc =  CreatePropsArr $webPartSrc.Properties
	foreach($elDst in  $wpPropsDst){
		#write-Host $el.Key -f Yellow
		#write-Host $el -f Green
		foreach($elSrc in  $wpPropsSrc){
			if ($elSrc.Key -eq $elDst.Key){
				if ($elSrc.Value -ne $elDst.Value){
					
					$errWPObj = "" | select-Object SourcePageURL, DestPageURL, WebPartName, WebPartKey, WebPartValueSRC, WebPartValueDST
					$errWPObj.SourcePageURL 	= $srcPageURL
					$errWPObj.DestPageURL  		= $dstPageURL
					$errWPObj.WebPartName 		= $webPartDst.Title
					$errWPObj.WebPartKey    	= $elDst.Key
					$errWPObj.WebPartValueSRC   = $elSrc.Value
					$errWPObj.WebPartValueDST   = $elDst.Value
					
					$errorWP    += $errWPObj
					
					#write-Host $elDst -f Cyan
					#write-Host $elSrc -f Yellow
				}
				break
			}
			
			#write-Host $el.Key -f Cyan
			#write-Host $el -f Cyan
		
		}		
		
	}
		
	#write-Host "Count: $($members.count)"
	
	#write-Host "m1: $($members[1])"
	
	#write-host "PropsWP Count: $propsCount "
	#write-Host "Props: $($webPartDst.Properties.GetEnumerator())"
	
	return $errorWP
	
}
function Find-WebParts($src, $dstPage,  $webPart, $dstRelPath){
	$srcRelPath = $src.RelPath
	#write-Host $srcRelPath -f Magenta
	#write-Host $dstRelPath -f Magenta
	#read-host
	$eWP = @()
	foreach ($elSrc in $src.Pages){
		$PageExistsInSource = $false
		$srcPage = $elSrc.URL
		$srcWP   = $elSrc.WebParts
		$tmpPage = $srcPage
		#compare Page
		
		$compPage = $tmpPage -Replace $srcRelPath,$dstRelPath
		#write-Host $tmpPage
		#write-Host $compPage
		#read-host
		if ($compPage -eq $dstPage.URL){
			#write-Host "Found Source Page $srcPage" -f Yellow
			$PageExistsInSource = $true
			foreach($wpsrc in $srcWP){
				if ($wpsrc.Title -eq $webPart.Title){
					$eWPEl = CompareWPProps $webPart $wpsrc $srcPage $dstPage.URL
					$eWP += $eWPEl
				}
			}
		}	
	}
	return $eWP
}

function check-WebParts($src,$dst){
	$dstRelPath = $dst.RelPath
	$cWP = @()
	foreach ($elDst in $dst.Pages){
		
		$dstPage = $elDst
		$dstWP   = $elDst.WebParts
		if (![string]::isNullOrEmpty($dstWP)){
			#write-Host "DestPage  : $dstPage" -f Green
			
			foreach($wpItem in $dstWP){
				#write-Host $wpItem
				$webPartName = $wpItem.Title
				#write-Host "webPartName : $webPartName" -f Cyan
				$cElWP = Find-WebParts $src $dstPage  $wpItem $dstRelPath
				$cWP += $cElWP
			}
		}
	}
	return $cWP
}

function get-PageWebPartAll($SiteURL,$pageURL){
	
	$wpsObject = $null
	if ($pageURL.contains(".aspx")){
		
			$siteName = get-UrlNoF5 $SiteURL
		
		write-Host $pageURL -f Cyan
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName)
		
		$Ctx.Credentials = $Credentials



		$page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
		
		$ctx.Load($page);
		$ctx.Load($page.ListItemAllFields);
		$ctx.ExecuteQuery();


		$page.CheckOut()
		$pageFields = $page.ListItemAllFields

		$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);	
		
		Write-Host "Get webparts on the page : $pageURL" -ForegroundColor Green

		
		$WebParts = $webpartManager.WebParts
		$ctx.Load($webpartManager);
		$ctx.Load($WebParts);
		$ctx.ExecuteQuery();
		
		$wpsObject = @()	
		
		foreach($wp in $webparts){
				
				
				
				$ctx.Load($wp.WebPart.Properties)
				$ctx.Load($wp.WebPart)
				$ctx.Load($wp)
				$ctx.ExecuteQuery() 
				write-host $wp.WebPart.Title
				$wps = "" | Select-Object Title, Properties
				$wps.Title = $wp.WebPart.Title
				$wps.Properties = $wp.WebPart.Properties.FieldValues
				$wpsObject += $wps
				<#
				if ($wp.WebPart.Title -eq $wpName){
					$wp.WebPart.Properties["WP_Language"] = $lang
					$wp.WebPart.Properties["EmailTemplatePath"] = $spObj.MailPath
					
					$wp.WebPart.Properties["EmailTemplateName"] = $spObj.MailFile;
					
					$wp.SaveWebPartChanges();				
				}
				#>
		}
		#$PageContent = $pageFields["PublishingPageContent"]
		
		$page.UndoCheckOut()
		
		$ctx.ExecuteQuery()	
	}
	return $wpsObject

}

function Check-ConsinsentListAndFields ($siteDumpObj){
	$ListAndFieldsErrors = @()
	foreach ($srcList in $siteDumpObj.Source.Lists)
	{
		$listExists = $false
		$dstListFields = @()
		foreach ($dstList in $siteDumpObj.Destination.Lists){
			if ($dstList.Title -eq $srcList.Title){
				$dstListFields  = $dstList.Fields
				$listExists = $true
				break
			}
			
		}
		$ListerrObj = "" | Select-Object ListName, ListExistsOnDest, FieldsNotFoundInDest
		$ListerrObj.ListName = $srcList.Title
		if (!$listExists){
			#Write-Host $srcList.Title -f Cyan
			$ListerrObj.ListExistsOnDest = $false
			$ListerrObj.FieldsNotFoundInDest = @()
			
		}
		else
		{
   			$ListerrObj.ListExistsOnDest = $true
			$FldsNotFoundInSrc = @()

		    #write-Host $srcList.Title -f Green
			foreach($srcFld in $srcList.Fields){
				
				$srcfDN = $srcFld.DisplayName
				$srcfType =  $srcFld.Type
				
				$fieldExists = $false
				foreach($dstFld in $dstListFields){
					$dstfDN   =  $dstFld.DisplayName
					$dstfType =  $dstFld.Type
					if (($dstfDN -eq $srcfDN) -and ($dstfType -eq $srcfType)){
						$fieldExists = $true
						break
					}
				}
				if (!$fieldExists){
					$fldNotFound = "" | Select-Object FieldName
					$fldNotFound.FieldName = $srcfDN
					#write-Host $srcfDN 
					$FldsNotFoundInSrc += $fldNotFound
				}
			}
			$ListerrObj.FieldsNotFoundInDest = $FldsNotFoundInSrc
		}
		$ListAndFieldsErrors += $ListerrObj
		
		
		
	}
	return $ListAndFieldsErrors
}

function Collect-libs($SiteURL){
	$siteName = get-UrlNoF5 $SiteURL
	write-host "Collect Libraries and Lists: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	$Lists = $Ctx.Web.Lists
	$Ctx.Load($Lists)
    $Ctx.ExecuteQuery()
	#write-host $Lists.Count
	$listArr = @()
	
	foreach($list in $Lists){
		$hebrDocLibName = "העלאת מסמכים"
		if (!$($list.Title.contains("Documents Upload") -or 
			$list.Title.contains($hebrDocLibName))){		
				write-host $list.title
				
				$Ctx.Load($list.RootFolder);
				$Ctx.ExecuteQuery();
				
				
				
				$FieldsSchema = get-ListSchema $siteName $list.title
				$Map = Map-LookupFields $FieldsSchema  $siteName ""
				
				$listObj = "" | Select-Object Title,URL, Fields	
				$listObj.Title  = $list.Title
				$listObj.URL  = $list.RootFolder.ServerRelativeUrl
				#write-host $listObj.URL	
			
				$fields = @()
				foreach($el in $Map.FieldMap){
					$field = "" | Select DisplayName, Type
					$field.DisplayName = $el.FieldObj.DisplayName.ToString()
					$field.Type = $el.Type.ToString()
					#write-Host $el
					#write-Host $field
					#read-host
					$fields += $field
				}
				
				$listObj.Fields = $fields
				$listArr += $listObj				
		}
	}
	

	return $listArr
	
}

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified  -foregroundcolor Yellow
	write-host in format hss_HUM164-2021  -foregroundcolor Yellow
	
}
else
{
	if (Test-CurrentSystem $groupName){
		$jsonFile = "JSON\"+$groupName+".json"
		if (Test-Path $jsonFile){
			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			
			
			$siteUrl    = get-CreatedSiteName $spObj
			$oldSiteURL = $spObj.oldSiteURL
			$RelURL = get-RelURL $siteUrl
			$oldSiteSuffix = $spObj.OldSiteSuffix
			if ([string]::isNullOrEmpty($oldSiteSuffix)){
				$oldSiteSuffix = $spObj.oldSiteURL.split("/")[-2]
			}
				
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "New Site: $siteUrl" -foregroundcolor Magenta
			write-host "RelURL:   $RelURL" -foregroundcolor Yellow
			#write-Host Press Key ...
			#read-host
			$siteDumpFileName = ".\JSON\"+ $groupName+"-SiteDump.json"
			if ($DeleteJson.ToUpper().Trim() -eq "YES"){
				If (Test-Path $siteDumpFileName){
					Remove-Item $siteDumpFileName
				}
			}
			
			If (Test-Path $siteDumpFileName){
				write-Host "Object file: $siteDumpFileName" -f Yellow
				write-Host "To Collect new Dump Just Delete this file" -f Cyan
				
				$siteDumpObj = get-content $siteDumpFileName -encoding default | ConvertFrom-Json				
			}
			else
			{
			
				$siteDumpObj = "" | Select-Object Source, Destination
				$sourceObj   = "" | Select-Object URL, RelPath, Lists, Pages      
				$DestObj     = "" | Select-Object URL, RelPath, Lists, Pages      

				$sourceObj.Url = $oldSiteURL
				$sourceObj.RelPath = get-RelURL $oldSiteURL
				$sourceObj.Lists = Collect-libs $oldSiteURL
				
				$DestObj.URL   = $siteUrl
				$DestObj.RelPath = $RelURL
				$DestObj.Lists   = Collect-libs $siteUrl
				
				
		
				#Dest
				$PagesName = getListOrDocName $siteUrl $($RelURL+"Pages") "DocLib"
				$SitePagesName = getListOrDocName $siteUrl $($RelURL+"SitePages") "DocLib"
			
			
				#Write-Host $PagesName -f Yellow
				$pageItems = get-allListItemsByID $siteUrl $PagesName
				#$pageItems
			
				$SPages = @()
			
				foreach ($itm in $pageItems){
					$pgObj = "" | Select-Object URL, WebParts
					$pgObj.URL = $itm["FileRef"]
					$pgObj.WebParts = get-PageWebPartAll $siteUrl $pgObj.URL
					$SPages += $pgObj
				}			
			
				#Write-Host $SitePagesName -f Yellow
				$sitePageItems = get-allListItemsByID $siteUrl $SitePagesName
			
				foreach ($itm in $sitePageItems){
					$pgObj = "" | Select-Object URL, WebParts
					$pgObj.URL = $itm["FileRef"]
					$pgObj.WebParts = get-PageWebPartAll $siteUrl $pgObj.URL
					$SPages += $pgObj
				}
				
				$DestObj.Pages = $SPages
				#write-host 170 -f Yellow


				#Source
				$RelURL = get-RelURL $oldSiteURL
				$PagesName = getListOrDocName $oldSiteURL $($RelURL+"Pages") "DocLib"
				$SitePagesName = getListOrDocName $oldSiteURL $($RelURL+"SitePages") "DocLib"
			
			
				#Write-Host $PagesName -f Yellow
				$pageItems = get-allListItemsByID $oldSiteURL $PagesName
				#$pageItems
			
				$SPages = @()
			
				foreach ($itm in $pageItems){
					$pgObj = "" | Select-Object URL, WebParts
					$pgObj.URL = $itm["FileRef"]
					$pgObj.WebParts = get-PageWebPartAll $oldSiteURL $pgObj.URL
					$SPages += $pgObj
				}			
			
				#Write-Host $SitePagesName -f Yellow
				$sitePageItems = get-allListItemsByID $oldSiteURL $SitePagesName
			
				foreach ($itm in $sitePageItems){
					$pgObj = "" | Select-Object URL, WebParts
					$pgObj.URL = $itm["FileRef"]
					$pgObj.WebParts = get-PageWebPartAll $oldSiteURL $pgObj.URL
					$SPages += $pgObj
				}
				
				$sourceObj.Pages = $SPages


				$siteDumpObj.Source = $sourceObj
				$siteDumpObj.Destination = $DestObj
				
				
				
		
				$siteDumpObj | ConvertTo-Json -Depth 100 | out-file $siteDumpFileName -Encoding Default
			}
			Write-Host 
			Write-Host "============" -f Green
			
			
			$cFldAndVErr = Check-ConsinsentListAndFields $siteDumpObj
			$cFldAndVErrFileName = ".\JSON\"+ $groupName +"-FldVErrors.json"
			$cFldAndVErr | ConvertTo-Json -Depth 100 | out-file $cFldAndVErrFileName -Encoding Default
			Write-Host "Written file $cFldAndVErrFileName" -f Cyan
			
			
			$cwpObjErr = check-WebParts $siteDumpObj.Source $siteDumpObj.Destination
			$cwpObjErrFileName = ".\JSON\"+ $groupName +"-WPErrors.json"
			$cwpObjErr | ConvertTo-Json -Depth 100 | out-file $cwpObjErrFileName -Encoding Default
			Write-Host "Written file $cwpObjErrFileName" -f Cyan
			
			#get-PageWebPartAll $siteUrl "/home/schoolofsocialwork/SSW45-2022/Pages/DeleteEmptyFolders.aspx"

  
			$siteDomainOld = [System.Uri]$(get-UrlWithF5 $oldSiteURL)
			$siteDomainNew = [System.Uri]$(get-UrlWithF5 $siteUrl)
			<#
		   
			[System.Uri]		   
			AbsolutePath   : /folder/
			AbsoluteUri    : http://www.domain.com/folder/
			LocalPath      : /folder/
			Authority      : www.domain.com
			HostNameType   : Dns
			IsDefaultPort  : True
			IsFile         : False
			IsLoopback     : False
			PathAndQuery   : /folder/
			Segments       : {/, folder/}
			IsUnc          : False
			Host           : www.domain.com
			Port           : 80
			Query          :
			Fragment       :
			Scheme         : http
			OriginalString : http://www.domain.com/folder/
			DnsSafeHost    : www.domain.com
			IsAbsoluteUri  : True
			UserEscaped    : False
			UserInfo       :		   
		   
			#>			
			#write-Host $siteDomainOld.AbsolutePath
			#write-Host $siteDomainNew.AbsolutePath
			
			#write-Host $siteDomainOld.AbsoluteUri
			#write-Host $siteDomainNew.AbsoluteUri
			
			$realDomOld = $(get-UrlWithF5 $oldSiteURL) -Replace $siteDomainOld.AbsolutePath,""
			$realDomNew = $(get-UrlWithF5 $siteUrl)    -Replace $siteDomainNew.AbsolutePath,""


			write-Host $realDomOld
			write-Host $realDomNew
			
		
			$fileNameSrc = ".\JSON\"+ $groupName+"-MenuDmp-Src.json"
			$fileNameDst = ".\JSON\"+ $groupName+"-MenuDmp-Dst.json"
			$permReport = $false
			$outReport = @()
			if ((Test-Path $fileNameSrc) -and
				(Test-Path $fileNameDst)){
					
					#cls
					write-host "Procedure 8.Dump-Site.ps1 $groupName Was Created Files:" -f Green
					write-host "Reading file: $fileNameSrc" -f Yellow
					write-host "Reading file: $fileNameDst" -f Magenta
					
					$spSrc = get-content $fileNameSrc -encoding default | ConvertFrom-Json
					$spDst = get-content $fileNameDst -encoding default | ConvertFrom-Json
					
					
					foreach($itemMenu in $spDst){
						forEach($itemSubm in $itemMenu.Items){
							if ($itemSubm.Type -eq "Lists" -or $itemSubm.Type -eq "DocLib" ){
								$listItemExists = $false
								# смотрим что мы еще не обрабатывали этот список.
								# проверяем в обекьте $outReport
								forEach($rp in $outReport){
									if ($rp.List -eq $itemSubm.Name){
										$listItemExists = $true
										break;
									}
								}
								if (!$listItemExists){
									
									$permDiff = get-DestListObjPerm $spObj.RelURL $oldSiteSuffix  $spSrc $itemSubm.Name $itemSubm.ListPermissons
								    if (![string]::IsNullOrEmpty($permDiff)){
										$repObj = "" | Select Group, SiteSource, SiteDest, List ,PermDifference, PermSource, PermDest 
										$repObj.Group = $groupName
										$repObj.SiteSource = $siteUrl
										$repObj.SiteDest = $oldSiteURL
										$repObj.List = $itemSubm.Name
										$repObj.PermDifference = $permDiff
										$repObj.PermSource = $itemSubm.ListPermissons
										$repObj.PermDest = $itemSubm.ListPermissons
										$outReport += $repObj 
									}
								}
							}
						}
						
					}
					#$w1255File = 
					$outFile =".\SiteReport\"+$groupName +".csv"
					
					$outReport | Export-CSV $outFile -Encoding UTF8 -NoTypeInfo
					write-Host "Written file : $outFile"
					#Invoke-Expression $outFile
					$outJson = ".\JSON\"+$groupName +"-Permissions.json"
					$outReport | ConvertTo-Json -Depth 100 | out-file $outJson -Encoding Default
					
					write-Host "Written file : $outJson"
					
					$permReport = $true
					
			}
			else
			{
				write-host "$fileNameSrc Does Not Exist Or"  -foregroundcolor Yellow
				write-host "$fileNameDst Doesn't  Exist"  -foregroundcolor Yellow
			}				
			$outHTMLFLD = gen-HtmlFLD $cFldAndVErr $oldSiteURL $siteUrl $spObj.siteName
			
			if ($permReport){
				$outHTMLFLD =  gen-HtmlPerm $outReport	$outHTMLFLD
			}
			$outHTML 	= gen-HtmlWP $cwpObjErr $outHTMLFLD $outPerm $oldSiteURL $siteUrl
			$outHTMLFileName = ".\Log\"+$groupName+"-CompareSites.html"
			$outHTML | Out-File $outHTMLFileName -Encoding Default
			
			Invoke-Expression $outHTMLFileName
			
	
			Write-Host "Done..." -f Green
		
		}
		
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}	
		
}