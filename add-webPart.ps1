$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"


	$WebPartXml = [xml]"
	<WebPart xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns='http://schemas.microsoft.com/WebPart/v2'>
		<Title>User Properties</Title>
		<FrameType>None</FrameType>
		<Description>Allows authors to enter rich text content.</Description>
		<IsIncluded>true</IsIncluded>
		<ZoneID>QuickLinks</ZoneID>
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
		<ContentLink xmlns='http://schemas.microsoft.com/WebPart/v2/ContentEditor'>$sitesURL/Style Library/ContentEditor/CEWP_Home_UserPropertiesWP.html</ContentLink>
		<Content xmlns='http://schemas.microsoft.com/WebPart/v2/ContentEditor' />
		
		
		<PartStorage xmlns='http://schemas.microsoft.com/WebPart/v2/ContentEditor' />
	</WebPart>"
	
# <!CDATA[<p>This is just a normal text with a link <a href='https://www.microsoft.com'/></p>]]>
 	
function add-WP($site, $relUrl, $pageName){
	
	$pageName = "/Pages/"+$pageName+".aspx"
	$pageURL = $relUrl + $pageName
	
	$wpZoneID = "Left"
	$wpZoneOrder= 0

	#write-host $site
	#write-host $pageUrl

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
	$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	
	$page = $ctx.Web.GetFileByServerRelativeUrl($pageUrl);
	$page.CheckOut()
	$ctx.ExecuteQuery()	


	$webpartManager = $page.GetLimitedWebPartManager([Microsoft.Sharepoint.Client.WebParts.PersonalizationScope]::Shared);

		#Write-Host $WebPartXml.OuterXml

	#Load and execute the query to get the data in the webparts
	Write-Host "Getting the webparts from the page" -ForegroundColor Green
	$ctx.Load($webpartManager);


	
    $Ctx.Load($webpartManager.WebParts)
	$ctx.ExecuteQuery();
	
	foreach($webpart in $webpartManager.WebParts )
	{
		$Ctx.Load($webpart.WebPart)
		$ctx.Load($webpart.WebPart.Properties)
        $Ctx.ExecuteQuery()
		
		$webpart.WebPart.Title
		
		#$webpart.WebPart.Properties.Item.Name # | gm
		#$wpPropValues = $webpart.WebPart.Properties.FieldValues
		#$properties =  $webpart.WebPart.Properties.FieldValues
		Write-Host "Webpart ID: " $webpart.ID
		#Write-Host "Webpart Context: " $webpart.Context
		#$webpart.Context | gm
		
		#foreach($prop in $properties){
		#	# $prop.keys
		#}
	}
	


	$wp = $webpartManager.ImportWebPart($WebPartXml.OuterXml)
	
	
	$webPartToAdd = $webpartManager.AddWebPart($wp.WebPart, $wpZoneID, $wpZoneOrder)
            
	$ctx.Load($webPartToAdd);
	$ctx.ExecuteQuery()
	
	$page.CheckIn("Add the User Profile WebPart", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
	$page.Publish("Add the User Profile WebPart")
	$ctx.ExecuteQuery()

	Write-Host "The webpart has been added" -ForegroundColor Yellow 
		
		
	

}


$site = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
$relUrl = "/home/huca/EinKarem/ekcc/QA/AsherSpace"
$page = "contactus"
add-WP $site $relUrl $page