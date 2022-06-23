param([string] $groupName = "")
function get-vQryString($qryS){
	return '<OrderBy><FieldRef Name="ID" /></OrderBy><Where><Eq><FieldRef Name="instituteDestination" /><Value Type="Text">'+
			$qryS+'</Value></Eq></Where>'
}
function Create-NavSubMenuX( $SiteURL, $menu, $pTitle){
	$siteName = get-UrlNoF5 $SiteURL
	write-host "Create Nav SubMenu: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	
	#Get the Quick Launch Navigation of the web
	$Navigation = $Ctx.Web.Navigation.QuickLaunch
	$Ctx.load($Navigation)
	$Ctx.ExecuteQuery()
	
    	

	$ParentNode = $Navigation | Where-Object {$_.Title -eq $pTitle}
    $Ctx.Load($ParentNode)
    $Ctx.Load($ParentNode.Children)
    $Ctx.ExecuteQuery()
	
	If($ParentNode -eq $null)
	{
		write-host write-host $("Menu Item Does Not Exist:" + $item.Title) -f Magenta
	}
	else
	{
		foreach($subMenuItem in $menu){

			$NavigationNode = New-Object Microsoft.SharePoint.Client.NavigationNodeCreationInformation
			$NavigationNode.Title = $subMenuItem.Title
			$NavigationNode.Url = $subMenuItem.Url
			$NavigationNode.AsLastNode = $true
 
			$Node = $ParentNode.Children | Where-Object {$_.Title -eq $subMenuItem.Title}

			If($Node -eq $Null)
			{
				#Add Link to Parent Node
				$Ctx.Load($ParentNode.Children.Add($NavigationNode))
				$Ctx.ExecuteQuery()
				Write-Host -f Green "New Navigation Link '$Title' Added to the Parent '$ParentNodeTitle'!"
				write-host $("Menu Item:" + $pTitle) -f Yellow
				write-host $("Create SubMenuItem Name:" + $subMenuItem.Title) -f Cyan
				write-host $("Create SubMenuItem Url :" + $subMenuItem.Url) -f Cyan
				write-host 	

			}
			Else
			{
				Write-Host -f Yellow "Navigation Node $($subMenuItem.Title) Already Exists in Parent Node $pTitle!"
			}



		}			
	}
 
	
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

start-transcript ADD-SCI.log

. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

if ([string]::isNullOrEmpty($groupName) -or !$groupName.ToUpper().Contains("SCI"))
{
	write-host SCI groupName Must be specified -f Yellow
	write-host in format HSS_SCI164-2021 -f Yellow
	
}
else
{
	if (Test-CurrentSystem $groupName){
		$jsonFile = "JSON\"+$groupName+".json"
		if (Test-Path $jsonFile){

			$Credentials = get-SCred
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			$language = $spObj.language
			$siteUrl    = get-CreatedSiteName $spObj
			$applSchmDst = get-ApplicantsSchema $siteUrl
			#$jsonFileName = ".\JSON\"+$groupName+"-ApplFields.json"
			#$applSchmDst | ConvertTo-Json -Depth 100 | out-file $jsonFileName
			
			$InstituteFound = $false
			$requiredField = 'NAME="instituteDestination"'
			foreach($fld in $applSchmDst){
				
				if ($fld.ToUpper().Contains($requiredField.ToUpper())){
					$InstituteFound = $true
					break
				}
			}
			
			if ($InstituteFound){
				
				$listName = "Applicants"
				$objViews = Get-AllViews $listName $siteUrl
				$jsonFileName = $(".\JSON\"+$groupName+"-Applicants-Views.json")
				$objViews | ConvertTo-Json -Depth 100 | out-file $jsonFileName
				write-host "Json File Written: $jsonFileName" -foregroundcolor Green
				$fields = @()
				$aggregations = ""
				$servRelUrl = ""
				 
				foreach($oView in $objViews){
					if ($oView.DefaultView){
						$fields	= $oView.Fields
						$aggregations= $oView.Aggregations
						#"/home/NaturalScience/SCI94-2022/Lists/applicants/view.aspx"
						$servRelUrl = $oView.ServerRelativeUrl.Substring(0,$oView.ServerRelativeUrl.LastIndexOf("/"))
						break
					}
				}
				$viewsObjs = @()
				$pTitle	= ""			
				if ($language.ToUpper().Contains("EN")){
					write-Host "Language: En " -f Green
				}
				else
				{
					write-Host "Language: He " -f Green
					$pTitle = "תפריט ניהול"
					# $viewName  $($view.Fields) $($view.ViewQuery) $($view.Aggregations) $viewDefault
					
					###    "Physics"
					$viewO = "" | Select Title, Fields, ViewQuery, Aggregations,ServerRelativeUrl,MenuTitle,DocLibName
					$viewO.Title = "Physics"
					$fieldVal = 'פיסיקה'
					$viewO.Fields = $fields
					$viewO.MenuTitle = "מועמדים - " + $fieldVal
					$viewO.DocLibName = "תיקים סופיים - " + $fieldVal
					$viewO.ViewQuery = get-vQryString $fieldVal
					$viewO.Aggregations = $aggregations
					$viewO.ServerRelativeUrl = $servRelUrl + "/"+$viewO.Title+".aspx"
					$viewsObjs += $viewO	

					### Math מתמטיקה
					$viewO = "" | Select Title, Fields, ViewQuery, Aggregations,ServerRelativeUrl,MenuTitle,DocLibName
					$viewO.Title = "Math"
					$fieldVal = 'מתמטיקה'
					$viewO.Fields = $fields
					$viewO.MenuTitle = "מועמדים - " + $fieldVal
					$viewO.DocLibName = "תיקים סופיים - " + $fieldVal
					$viewO.ViewQuery = get-vQryString $fieldVal
					$viewO.Aggregations = $aggregations
					$viewO.ServerRelativeUrl = $servRelUrl + "/"+$viewO.Title+".aspx"
					$viewsObjs += $viewO

					### מדעי החיים LifeScience
					$viewO = "" | Select Title, Fields, ViewQuery, Aggregations,ServerRelativeUrl,MenuTitle,DocLibName
					$viewO.Title = "LifeScience"
					$fieldVal = 'מדעי החיים'
					$viewO.MenuTitle = "מועמדים - " + $fieldVal
					$viewO.DocLibName = "תיקים סופיים - " + $fieldVal
					$viewO.Fields = $fields
					$viewO.ViewQuery = get-vQryString $fieldVal
					$viewO.Aggregations = $aggregations
					$viewO.ServerRelativeUrl = $servRelUrl + "/"+$viewO.Title+".aspx"
					$viewsObjs += $viewO
					
					### Earth כדור הארץ
					$viewO = "" | Select Title, Fields, ViewQuery, Aggregations,ServerRelativeUrl,MenuTitle,DocLibName
					$viewO.Title = "Earth"
					$fieldVal = 'כדור הארץ'
					$viewO.Fields = $fields
					$viewO.MenuTitle = "מועמדים - " + $fieldVal
					$viewO.DocLibName = "תיקים סופיים - " + $fieldVal
					$viewO.ViewQuery = get-vQryString $fieldVal
					$viewO.Aggregations = $aggregations
					$viewO.ServerRelativeUrl = $servRelUrl + "/"+$viewO.Title+".aspx"
					$viewsObjs += $viewO
					
					### פיסיקה יישומית AppliedPhysics
					$viewO = "" | Select Title, Fields, ViewQuery, Aggregations,ServerRelativeUrl,MenuTitle,DocLibName
					$viewO.Title = "AppliedPhysics"
					$fieldVal = 'פיסיקה יישומית'
					$viewO.MenuTitle = "מועמדים - " + $fieldVal
					$viewO.DocLibName = "תיקים סופיים - " + $fieldVal
					$viewO.Fields = $fields
					$viewO.ViewQuery = get-vQryString $fieldVal
					$viewO.Aggregations = $aggregations
					$viewO.ServerRelativeUrl = $servRelUrl + "/"+$viewO.Title+".aspx"
					$viewsObjs += $viewO

					### Chemistry כימיה 
					$viewO = "" | Select Title, Fields, ViewQuery, Aggregations ,ServerRelativeUrl,MenuTitle,DocLibName
					$viewO.Title = "Chemistry"
					$fieldVal = 'כימיה'
					$viewO.Fields = $fields
					$viewO.MenuTitle = "מועמדים - " + $fieldVal
					$viewO.DocLibName = "תיקים סופיים - " + $fieldVal
					$viewO.ViewQuery = get-vQryString $fieldVal
					$viewO.Aggregations = $aggregations
					$viewO.ServerRelativeUrl = $servRelUrl + "/"+$viewO.Title+".aspx"
					$viewsObjs += $viewO
					
					
				}
				#$siteUrlOld = "https://scholarships2.ekmd.huji.ac.il/home/NaturalScience/SCI94-2022/"
				
				
				#$objViewsOld = Get-AllViews $listName $siteUrlOld
				#$jsonFileName = $(".\JSON\"+$groupName+"-Old-Applicants-Views.json")
				#$objViewsOld | ConvertTo-Json -Depth 100 | out-file $jsonFileName
				
				$jsonFileName = $(".\JSON\"+$groupName+"-ViewObj.json")
				$viewsObjs	| ConvertTo-Json -Depth 100 | out-file $jsonFileName

                foreach($xOView in $viewsObjs){
					$viewExists = Check-ViewExists $listName  $siteURL $xOView 
					if ($viewExists.Exists){
						write-Host "$($xOView.Title)  Exists" -f Green
					}
					else
					{
						write-Host "$($xOView.Title) does Not Exists" -f Yellow
						$viewDefault = $false
						Create-NewView $siteURL $listName $xOView.Title   $xOView.Fields  $xOView.ViewQuery  $xOView.Aggregations $viewDefault
						
					}
				}
				$flagOldMenu = $true
				$menuDumpSrc = Collect-Navigation $SiteURL $flagOldMenu | out-null
				$outfile = ".\JSON\"+ $groupName+"-MenuDmp-Src.json"
				#$menuDumpSrc = get-content $outfile -encoding default | ConvertFrom-Json	
				$menuDumpSrc | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
				
				$newMenu = @()

				foreach($yOView in $viewsObjs){
				    $menuItemexists = $false
					#$yOView.ServerRelativeUrl
					#$yOView.Title

					foreach($menuMain in $menuDumpSrc){
						foreach($menuItm in $menuMain.Items){
							if ($menuItm.Url -eq $yOView.ServerRelativeUrl){
								$menuItemexists = $true
								break
							}
						}
						if ($menuItemexists){
							break
						}
					}
					if (!$menuItemexists){
						$newMenuItem = "" | Select Title, URL
						$newMenuItem.Title = $yOView.MenuTitle
						$newMenuItem.URL = $yOView.ServerRelativeUrl
						$newMenu += $newMenuItem
						#write-Host "$($yOView.ServerRelativeUrl) Menu Not Found, Creating..."	-f Yellow
					}
					
				}
				
				Create-NavSubMenuX $siteUrl $newMenu $pTitle
				
				foreach($viewOX1 in $viewsObjs){
					#$viewOX1.Title  
					#$viewOX1.DocLibName
					create-DocLib $siteUrl $viewOX1.Title  $viewOX1.DocLibName
				}
				
				create-DocLib $siteUrl "ScholarShip"
				
				
				write-Host "Required Field Exists : $requiredField" -f Green
				write-host "New Site: $siteUrl" -foregroundcolor Green
				write-host "Json File Written: $jsonFileName" -foregroundcolor Green

				#$fields
				write-Host "Press any key..."
				read-host

			}
			else
			{
				write-Host "Required Field Does not Exists : $requiredField" -f Yellow
				
			}

				
		}
		else
		{
			Write-Host "File $jsonFile does not exists." -foregroundcolor Yellow
			Write-Host "Run 1.Get-SPRequest.ps1 first. " -foregroundcolor Yellow
		}
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}	 
} 

stop-transcript