function AddWebPartToPage ($ctx, $sitesURL) {

	$pageRelativeUrl = "/Pages/WPTest.aspx"
	$wpZoneID = "Left"
	$wpZoneOrder= 0

	$WebPartXml = [xml] "
	<WebPart xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns='http://schemas.microsoft.com/WebPart/v2'>
<Title>Content Editor</Title>  
    <FrameType>Default</FrameType>  
    <Description>Allows authors to enter rich text content.</Description>  
    <IsIncluded>true</IsIncluded>  
    <ZoneID></ZoneID>  
    <PartOrder>0</PartOrder>  
    <FrameState>Normal</FrameState>  
    <Height />  
    <Width />  
    <AllowRemove>true</AllowRemove>  
    <AllowZoneChange>true</AllowZoneChange>  
    <AllowMinimize>true</AllowMinimize>  
    <AllowConnect>true</AllowConnect>  
    <AllowEdit>true</AllowEdit>  
    <AllowHide>true</AllowHide>  
    <IsVisible>true</IsVisible>  
    <DetailLink />  
    <HelpLink />  
    <HelpMode>Modeless</HelpMode>  
    <Dir>Default</Dir>  
    <PartImageSmall />  
    <MissingAssembly>Cannot import this Web Part.</MissingAssembly>  
    <PartImageLarge>/_layouts/15/images/mscontl.gif</PartImageLarge>  
    <IsIncludedFilter />  
    <Assembly>Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c</Assembly>  
    <TypeName>Microsoft.SharePoint.WebPartPages.ContentEditorWebPart</TypeName>  
    <ContentLink xmlns='http://schemas.microsoft.com/WebPart/v2/ContentEditor' />  
    <Content xmlns='http://schemas.microsoft.com/WebPart/v2/ContentEditor' >
	<![CDATA[This is a first paragraph!<div>bvnvbn</div>And this is a second paragraph.]]></Content>	
    <PartStorage xmlns='http://schemas.microsoft.com/WebPart/v2/ContentEditor' /> 
	
</WebPart> "

	try{

		Write-Host "Starting the Process to add the User WebPart to the Home Page" -ForegroundColor Yellow

		#Adding the reference to the client libraries. Here I'm executing this for a SharePoint Server (and I'm referencing it from the SharePoint ISAPI directory, 
		#but we could execute it from wherever we want, only need to copy the dlls and reference the path from here        
		
		Write-Host "Getting the page with the webpart we are going to modify" -ForegroundColor Green

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
			$ctx.ExecuteQuery() 
			
			# $wp.WebPart.Properties
			$propValues = $wp.WebPart.Properties.FieldValues
			$propValues | fl
		}
		# read-host
		<#
		#Import the webpart
		$wp = $webpartManager.ImportWebPart($WebPartXml.OuterXml)
		

		#Add the webpart to the page
		Write-Host "Add the webpart to the Page" -ForegroundColor Green
		
		$webPartToAdd = $webpartManager.AddWebPart($wp.WebPart, $wpZoneID, $wpZoneOrder)
            
		$ctx.Load($webPartToAdd);
		$ctx.ExecuteQuery()
		#>
		}
		catch{
			Write-Host "Errors found:`n$_" -ForegroundColor Red

		}
		finally{
			#CheckIn and Publish the Page
			Write-Host "Checkin and Publish the Page" -ForegroundColor Green
			$page.CheckIn("Add the User Profile WebPart", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
			$page.Publish("Add the User Profile WebPart")
			$ctx.ExecuteQuery()

			Write-Host "The webpart has been added" -ForegroundColor Yellow 
			
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
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
 # $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($tenantAdmin, $secureAdminPassword)  
 $ctx.Credentials = New-Object System.Net.NetworkCredential($tenantAdmin, $tenantAdminPassword)
    
######################################
# Set Add WebPart to Page Parameters #
######################################
$relUrl = "/home/huca/EinKarem/ekcc/QA/AsherSpace"
# LogSection "Add Manual Correction WebPart to Page"
AddWebPartToPage $ctx $relUrl