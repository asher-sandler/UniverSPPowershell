function edit-Page($site, $relUrl, $pageName, $ctx){
	$pageName = "/Pages/"+$pageName+".aspx"
	$pageURL = $relUrl + $pageName

	$page = $ctx.Web.GetFileByServerRelativeUrl($pageUrl);
	
	$ctx.Load($page);
    $ctx.Load($page.ListItemAllFields);
    $ctx.ExecuteQuery();
	#write-host Page Methods -ForegroundColor Green
	
	#write-host Page Properties -ForegroundColor Green
	

	$page.CheckOut()
	$newItem = $page.ListItemAllFields

   $cont = '<div>
   <h1> 
      <span aria-hidden="true"></span>הסרת מועמדות</h1>
   <p> 
      <span class="ms-rteFontSize-2">
         <span lang="HE">ניתן לבטל מועמדות על ידי לחיצה על כפתור &quot;הסרת מועמדות&quot;.<br/>שימו לב, פעולה זו תסיר מהאתר את כל החומרים שהועלו, ללא אפשרות לשחזור.<br/>לרישום מחדש יש לחזור על תהליך הרישום מההתחלה (מילוי טופס/ העלאת קבצים וכו&#39;).<span aria-hidden="true"></span></span></span></p>
</div>
   <div class="ms-rtestate-read ms-rte-wpbox">
		<div class="ms-rtestate-notify  ms-rtestate-read 4d6c609d-8950-4756-b861-cdebb7444abc" id="div_4d6c609d-8950-4756-b861-cdebb7444abc">
		</div>
		
		<div id="vid_4d6c609d-8950-4756-b861-cdebb7444abc" style="display:none;">
		</div>
	</div>
	<div></div>'	
	$x = $newItem["PublishingPageContent"] 
	$titl = $newItem["Title"]
	write-host $titl
	write-host $x
	
	
	# change page
	
	$newItem["PublishingPageContent"] = $cont
	$titlNew = "הסרת מועמדות"
	$newItem["Title"] = $titlNew

	$newItem.Update();
	$ctx.Load($newItem)
	$ctx.ExecuteQuery();
	# $page.getType() | gm
	$page.CheckIn("",1)
	
	$ctx.ExecuteQuery()

	
	
}


	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

 $tenantAdmin = "ekmd\ashersa"
 $tenantAdminPassword = "GrapeFloor789"
 $secureAdminPassword = $(convertto-securestring $tenantAdminPassword -asplaintext -force)

$siteURL = "https://scholarships.ekmd.huji.ac.il/home/SocialSciences/SOC205-2021"
$relUrl = "/home/SocialSciences/SOC205-2021"
$page = "CancelCandidacy"

$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
# $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($tenantAdmin, $secureAdminPassword)  
$ctx.Credentials = New-Object System.Net.NetworkCredential($tenantAdmin, $tenantAdminPassword)
 
edit-page $siteURL $relUrl $page $ctx