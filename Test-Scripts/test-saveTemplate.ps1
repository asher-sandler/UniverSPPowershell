


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



$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"
$SiteURL="https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
	$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$List = $Ctx.Web.lists.GetByTitle("Faculty")

    #$ViewFields = $List.DefaultView.ViewFields
	#$View = $list.DefaultView
    #$Ctx.load($ViewFields) 
    #$Ctx.load($View) 
    #$Ctx.ExecuteQuery()

#https://portals2.ekmd.huji.ac.il/home/_catalogs/lt/Forms/AllItems.aspx
# https://portals2.ekmd.huji.ac.il/home/_catalogs/lt/Forms/AllItems.aspx?InitialTabId=Ribbon%2ERead&VisibilityContext=WSSTabPersistence

$FileName = "ASHERFaculty"
$TemplateName = "ASHERFaculty"
  $Ctx.load($List) 
  $Ctx.ExecuteQuery()
$list | gm
$list.SaveAsTemplate($FileName, $TemplateName, "", $false)  
$ctx.ExecuteQuery() 
