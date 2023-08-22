function AddWebPartToPage ($ctx, $sitesURL) {

	$pageRelativeUrl = "/Pages/Default.aspx"
	$wpZoneID = "Left"
	$wpZoneOrder= 0


	try{

		#Using the params, build the page url
		$pageUrl = $sitesURL + $pageRelativeUrl
		Write-Host "Getting the page with the webpart we are going to modify: " $pageUrl -ForegroundColor Green

		#Getting the page using the GetFileByServerRelativeURL and do the Checkout
		#After that, we need to call the executeQuery to do the actions in the site
		$page = $ctx.Web.GetFileByServerRelativeUrl($pageUrl);
		$page.CheckOut()
		$ctx.ExecuteQuery()
		try{

			#Get the webpart manager from the page, to handle the webparts
			Write-Host "The page $pageUrl is checkout" -ForegroundColor Green
			#read-host
			$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);
			
	<#
Key                 Value
---                 -----
Height
Direction           0
ExportMode          1
Width
ChromeState         0
AllowClose          True
ChromeType          2
Hidden              False
CatalogIconImageUrl
AllowConnect        True
AllowEdit           True
AllowHide           True
HelpUrl
HelpMode            1
TitleIconImageUrl
TitleUrl
AllowMinimize       True
Description         Use for formatted text, tables, and images.
Title               ContentEditorWebPart
AllowZoneChange     True
AuthorizationFilter
MissingAssembly     Cannot import this Web Part.
ImportErrorMessage  Cannot import this Web Part.
ContentLink
ContentHasToken     False
PartStorage
	#>		
			
			#Write-Host $WebPartXml.OuterXml
			

			#Load and execute the query to get the data in the webparts
			Write-Host "Getting the webparts from the page" -ForegroundColor Green
			$WebParts = $webpartManager.WebParts
			$ctx.Load($webpartManager);
			$ctx.Load($WebParts);
			$ctx.ExecuteQuery();
			foreach($wp in $webparts){
				#$wp | fl
				#$wp.WebPart | fl # | gm
				
				
				$ctx.Load($wp.WebPart.Properties)
				$ctx.Load($wp.WebPart)
				$ctx.Load($wp)
				$ctx.ExecuteQuery() 
				if ($wp.WebPart.Title.contains("ContentEditorWebPart"))
				{
					#$wp.WebPart | gm
					#$wp.id
					$wp.WebPart.Properties.FieldValues
					
					# Email Text Alignment
					#$wp.WebPart.Properties["WP_Language"] = 1
					#$wp.WebPart.Properties["Content"] = "<![CDATA[<div><h1>Hello</h1></div>]]>"
					
					#Set content and Save
					#$xmlContent = get-content SimchaContent.dwp -encoding Default
					#$wp.Content = $xmlContent   
					#$wp.SaveWebPartChanges();				
				}
				
			}
			
			
		}
		catch{
			Write-Host "Errors found:`n$_" -ForegroundColor Red

		}
		finally{
			#CheckIn and Publish the Page
			Write-Host "Checkin and Publish the Page" -ForegroundColor Green
			
			
			#$page.UndoCheckOut()
			$page.CheckIn("Add the User Profile WebPart", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
			$page.Publish("Add the User Profile WebPart")
			$ctx.ExecuteQuery()

			#Write-Host "The webpart has been added" -ForegroundColor Yellow 
			
		}	

	}
	catch{
		Write-Host "Errors found:`n$_" -ForegroundColor Red
	}

}
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

 $tenantAdmin = "ekmd\ashersa"
 $tenantAdminPassword = "GrapeFloor789"
 $secureAdminPassword = $(convertto-securestring $tenantAdminPassword -asplaintext -force)
 $siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 $siteURL = "https://grs.ekmd.huji.ac.il/home/Education/EDU62-2022";
 $siteURL = "https://grs.ekmd.huji.ac.il/home/natureScience/SCI25-2021";
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
 # $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($tenantAdmin, $secureAdminPassword)  
 $ctx.Credentials = New-Object System.Net.NetworkCredential($tenantAdmin, $tenantAdminPassword)
    
######################################
# Set Add WebPart to Page Parameters #
######################################
$relUrl = "/home/huca/EinKarem/ekcc/QA/AsherSpace"
$relUrl = "/home/natureScience/SCI25-2021"
# LogSection "Add Manual Correction WebPart to Page"
AddWebPartToPage $ctx $relUrl