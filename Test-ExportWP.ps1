function ExprtWebPart ($ctx, $relUrl, $siteURL) {

    $pageURL = "Pages/healthDeclaration.aspx"
	$pageRelativeUrl = "/"+$pageURL
	$wpZoneID = "Left"
	$wpZoneOrder= 0

	$absUrl = (New-Object System.Uri($ctx.Url)).GetLeftPart([System.UriPartial]::Authority) + $pageRelativeUrl
	$absUrl = $siteURL+$pageURL
	
	#write-host $absUrl
	#read-host
 
	try{

		#Using the params, build the page url
		$pageUrl = $relUrl + $pageRelativeUrl
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
				write-host $wp.WebPart.Title				
				$wbID =  $wp.ID
				
				$exportPath = "ExportWP\1.xml"
				$xwTmp = new-object System.Xml.XmlTextWriter($exportPath,$null);
				$xwTmp.Formatting = 1;#Indent
				#$webpartManager.ExportWebPart($wp, $xwTmp);
				$xwTmp = $webpartManager.ExportWebPart($wbID);
				$xwTmp.Flush();
				$xwTmp.Close();				
				#$webPartXml = $webpartManager.ExportWebPart($wbID);
				#$ctx.ExecuteQuery()
				#$webPartXml | OUT-File "ExportWP\1.xml" -Encoding UTF8

				
			}
			
			
		}
		catch{
			Write-Host "Errors found:`n$_" -ForegroundColor Red

		}
		finally{
			#CheckIn and Publish the Page
			Write-Host "Undo Checkin In" -ForegroundColor Green
			
			
			#$page.UndoCheckOut()
			$page.UndoCheckOut()
	
			$ctx.ExecuteQuery()	
			#$page.CheckIn("Add the User Profile WebPart", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
			#$page.Publish("Add the User Profile WebPart")
			#$ctx.ExecuteQuery()

			#Write-Host "The webpart has been added" -ForegroundColor Yellow 
			
		}	

	}
	catch{
		Write-Host "Errors found:`n$_" -ForegroundColor Red
	}

}
	Add-Type -Path "C:\AdminDir\Nuget\Microsoft.SharePointOnline.CSOM.16.1.21812.12000\lib\net45\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\AdminDir\Nuget\Microsoft.SharePointOnline.CSOM.16.1.21812.12000\lib\net45\Microsoft.SharePoint.Client.Runtime.dll"

 $tenantAdmin = "ekmd\ashersa"
 $tenantAdminPassword = "GrapeFloor789"
 $secureAdminPassword = $(convertto-securestring $tenantAdminPassword -asplaintext -force)
 $siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 $siteURL = "https://grs.ekmd.huji.ac.il/home/Education/EDU62-2022";
 $siteURL = "https://grs.ekmd.huji.ac.il/home/natureScience/SCI25-2021";
 $siteURL = "https://grs.ekmd.huji.ac.il/home/Medicine/MED80-2021/";
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
 # $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($tenantAdmin, $secureAdminPassword)  
 $ctx.Credentials = New-Object System.Net.NetworkCredential($tenantAdmin, $tenantAdminPassword)
    
######################################
# Set Add WebPart to Page Parameters #
######################################
$relUrl = "/home/huca/EinKarem/ekcc/QA/AsherSpace"
$relUrl = "/home/Medicine/MED80-2021"
# LogSection "Add Manual Correction WebPart to Page"
ExprtWebPart $ctx $relUrl $siteURL