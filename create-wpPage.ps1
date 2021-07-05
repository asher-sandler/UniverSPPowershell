$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"
$siteUrl="https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
$pageUrl = '/Pages/WPTest.aspx'

$webPartXml =@"
<?xml version="1.0" encoding="utf-8"?>  
<WebPart xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/WebPart/v2">  
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
    <ContentLink xmlns="http://schemas.microsoft.com/WebPart/v2/ContentEditor" />  
    <Content xmlns="http://schemas.microsoft.com/WebPart/v2/ContentEditor" >
	<![CDATA[This is a first paragraph!<div>bvnvbn</div>And this is a second paragraph.]]></Content>	
    <PartStorage xmlns="http://schemas.microsoft.com/WebPart/v2/ContentEditor" /> 
	
</WebPart> 
"@

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
# . "$dp0\Utils-WebPart.ps1"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"


	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)  
	$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$web = $ctx.Web
	
	$Ctx.Load($web)
	$Ctx.ExecuteQuery()
	
	$page = $web.GetFileByServerRelativeUrl($pageUrl);
	$shared = [System.Web.UI.WebControls.Webparts.PersonalizationScope]::Shared
	$page.CheckOut();

    #$page | gm
	#

	$webPartManager = $page.GetLimitedWebPartManager($shared)
	$webparts = $webPartManager.Webparts  
	$ctx.Load($webparts)  
	$ctx.ExecuteQuery()
	

	$importedWebPart = $webPartManager.ImportWebPart($webPartXml)
	$webPartToAdd = $webPartManager.AddWebPart($importedWebPart.WebPart, "Left", 1);
    # $Ctx.Load($importedWebPart)	
	$ctx.Load($webPartToAdd)
	$Ctx.ExecuteQuery()	
	#$page.CheckIn("");

	#>
    #$page.Title = "Asher 23.06.2021"
	#$wikiPage= $page.ListItemAllFields
	#$wikiPage.item | gm
	#read-host
	#$wikiPage["Title"] =  "Asher 23.06.2021"
	#$wikiPage.Update();
	#$Ctx.ExecuteQuery()
	#$page.Update();
	
	$page.CheckIn("Asher 23.06.2021", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn);
	$page.Publish("Asher 23.06.2021")
	
	#$Ctx.Load($page)
	$Ctx.ExecuteQuery()
	
	
	