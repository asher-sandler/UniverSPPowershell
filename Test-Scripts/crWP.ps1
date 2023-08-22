function AddWebPartToPage ($ctx, $sitesURL) {

	$pageRelativeUrl = "/Pages/form001.aspx"
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
		
<#
Key   : ExportMode
Value : 0


Key   : HelpUrl
Value :


Key   : HelpMode
Value : 2


Key   : Direction
Value : 0


Key   : CatalogIconImageUrl
Value :


Key   : AuthorizationFilter
Value :


Key   : AllowZoneChange
Value : True


Key   : ChromeState
Value : 0


Key   : Description
Value : Dynamic Form - v 2.0


Key   : ChromeType
Value : 2


Key   : TitleUrl
Value :


Key   : TitleIconImageUrl
Value :


Key   : Title
Value : Dynamic Form - v 2.0


Key   : ImportErrorMessage
Value : Cannot import this Web Part.


Key   : Hidden
Value : False


Key   : AllowMinimize
Value : True


Key   : AllowConnect
Value : True


Key   : AllowClose
Value : True


Key   : AllowHide
Value : True


Key   : AllowEdit
Value : True


Key   : loadFormByIdPageURL
Value : http://testportal.ekmd.huji.ac.il/abat/Pages/existingForm.aspx


Key   : showPdfLog
Value : False


Key   : checkDeadline
Value : True


Key   : successPageUrl
Value : https://adminportal2.ekmd.huji.ac.il/abat/Pages/viewPendingApp
        roal.aspx


Key   : submitMessage
Value : הכרטיס נשלח בהצלחה


Key   : submit
Value : False


Key   : showLog
Value : False


Key   : submitApproverMail
Value :


Key   : CheckStartDate
Value : False


Key   : mailServer
Value : ekekcas01.ekmd.huji.uni


Key   : domain
Value : EKMD


Key   : addColumns
Value : True


Key   : addLists
Value : True


Key   : itemLoadBy
Value : 0


Key   : addListItem
Value : False


Key   : ldap
Value : LDAP://DC=ekmd,DC=huji,DC=uni


Key   : formMode
Value : 0


Key   : parallelApprovalProcessStatusColumnValue
Value : ממתין


Key   : restartDeniedItem
Value : True


Key   : stageAdditionalData
Value : OrderDescription


Key   : approvingonGoingValue
Value : בתהליך


Key   : approvingWaitingValue
Value : ממתין


Key   : cookieName
Value : EKMD_1234


Key   : css
Value : /Style Library/DynamicForm/DynamicForm.css


Key   : writeApproverToPDF
Value : False


Key   : hujiUsersList
Value : hujiUsers


Key   : approvingDeniedValue
Value : נדחה


Key   : initiatorEmailColumn
Value : email


Key   : initiatorDisplayNameColumn
Value : Title


Key   : parallelApprovalProcessStatusColumn
Value : AdminTicketStatus


Key   : initiatorUserNameColumn
Value : userName


Key   : approverAcceptedValue
Value : אושר


Key   : approvingApprovedValue
Value : מאושר


Key   : parallelApprovalProcess
Value : False


Key   : approverDeniedValue
Value : נדחה


Key   : userNameColumn
Value : userName


Key   : buttonTag
Value : Button


Key   : TypeTag
Value : type


Key   : applicantsList
Value : applicants


Key   : messageTag
Value : finalMessage


Key   : _headerTag
Value : Header


Key   : _docHeader
Value : _docHeader


Key   : DataTag
Value : data


Key   : _labelTag
Value : label


Key   : initiatorList
Value : InitiatorsList


Key   : ADLoaderfileName
Value : ADConnectionConfig.xml


Key   : ADLoaderfilePath
Value : \\ekeksql00\SP_Resources$\ActiveDirectory


Key   : initiatorMailTemplate
Value : \\ekeksql00\SP_Resources$\ABT\mailTemplates\initiatorMail.txt


Key   : approverMailTemplate
Value : \\ekeksql00\SP_Resources$\ABT\mailTemplates\approverMail.txt


Key   : aproversProgressList
Value : TicketsApprovalProcess


Key   : aproversStagesList
Value : ApprovingStagesList


Key   : fileName
Value : requjestForm.xml


Key   : filePath
Value : \\ekeksql00\SP_Resources$\HSS\default\asherTest


Key   : controlPath
Value : /rows/row/control


Key   : textDataFontSize
Value : 10


Key   : labelFontSize
Value : 10


Key   : textAlign
Value : 0


Key   : MtHeight
Value : 150


Key   : statusColumnName
Value : TicketStatus


Key   : approverUserNameColumn
Value : userName


Key   : headerFontSize
Value : 11


Key   : docHeaderFontSize
Value : 16


Key   : textDirection
Value : 0


Key   : dataColor
Value : #545556


Key   : section_headerFontSize
Value : 14px


Key   : _dataPath
Value : /rows/row


Key   : _configPath
Value : /rows/config


Key   : _docHeaderColor
Value : #3560a0


Key   : fontName
Value : 0


Key   : sectionHeaderColor
Value : #3560a0


Key   : _doc_headerFontSize
Value : 18px


SubmissionButton WP

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
			if ($wp.WebPart.Title -eq "Dynamic Form - v 2.0")
			{
				#$wp.WebPart | gm
				#$wp.id
				#$wp.WebPart.Properties.FieldValues
				#$wp.WebPart.Properties["ContentLink"] = "/sites/dev/SiteAssets/test.css";
				$wp.WebPart.Properties["filePath"] = "\\ekeksql00\SP_Resources$\HSS\default";
				#$wp.WebPart.Properties["fileName"] = "‏‏GEN130-2021.xml";
				$wp.WebPart.Properties["fileName"] = "GEN150-2021-En.xml";
				#$wp.WebPart.Properties["fileName"] = "HUM166-2021.xml";
				
				
				$wp.WebPart.Properties["addColumns"] = $true;
				$wp.WebPart.Properties["addLists"] = $true;
				
				$wp.WebPart.Properties["textAlign"] = 1;
				$wp.WebPart.Properties["textDirection"] = 1;

				#$wp.WebPart.Properties["Content"] = "<![CDATA[<div><h1>Hello</h1></div>]]>"
				#$wp.WebPart.Properties["Content"] = "<![CDATA[<div><h1>Hello</h1></div>]]>"
				
				#Set content and Save
				#$xmlContent = get-content SimchaContent.dwp -encoding Default
				#$wp.Content = $xmlContent   
				$wp.SaveWebPartChanges();				
			}
			# $wp.WebPart.Properties
			#$propValues = $wp.WebPart.Properties.FieldValues
			#$propValues | fl
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