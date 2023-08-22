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

$Credentials = get-SCred

 $siteURL = "https://grs.ekmd.huji.ac.il/home/natureScience/SCI25-2021";
 $pageURL = "/home/natureScience/SCI25-2021/Pages/DocumentsUpload.aspx"
 
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials

 $page = $ctx.Web.GetFileByServerRelativeUrl($pageURL);
	
 $ctx.Load($page);
 $ctx.Load($page.ListItemAllFields);
 $ctx.ExecuteQuery();

 $webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);
	#$webpartManager | gm | fl		

  #Load and execute the query to get the data in the webparts
  Write-Host "Getting the webparts from the page" -ForegroundColor Green
  $WebParts = $webpartManager.WebParts
  $ctx.Load($webpartManager);
  $ctx.Load($WebParts);
  $ctx.ExecuteQuery();
  foreach($wp in $webparts){
	  
	  $webPartId = $wp.ID
	  $wp.ExportMode="All";
	  Write-Host $webPartId
	  #$wp | gm | fl	
	  $wpXML = $webpartManager.ExportWebPart($webPartId);
	  $ctx.Load($wpXML);
	  $ctx.ExecuteQuery();
	  read-host
	  $xmlVal = $wpXML.Value
	  $xmlVal
  }
#>
######################################
# Set Add WebPart to Page Parameters #
######################################
#$relUrl = "/home/huca/EinKarem/ekcc/QA/AsherSpace"
#$relUrl = "/home/Medicine/MED80-2021"
# LogSection "Add Manual Correction WebPart to Page"
#ExprtWebPart $ctx $relUrl $siteURL