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
	$List = $Ctx.Web.lists.GetByTitle("applicants")

    $ViewFields = $List.DefaultView.ViewFields
    $Ctx.load($ViewFields) 
    $Ctx.ExecuteQuery() 

       $List.DefaultView.ViewFields.Remove("zip")
        $List.DefaultView.Update()
        $Ctx.ExecuteQuery()
 


	<#

	
	
	$fieldToDel = "zip"
	$viewFields = $view.ViewFields 
	$ctx.load($viewFields)
	$ctx.executeQuery()
	
	#if($ViewFields.ToStringCollection().Contains($fieldToDel)){
		$view.ViewFields.delete("zip")
		$View.Update()
		$ctx.executeQuery()
	#}
	#>




	#$viewFields 
    	
