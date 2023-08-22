
$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"
$wrkSite 		=  "https://portals.ekmd.huji.ac.il/home/huca/committees/SPProjects2017/"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Cred= Get-Credential
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($wrkSite)
	
$Ctx.Credentials = New-Object System.Net.NetworkCredential($Cred.userName, $Cred.Password)

		$ListName="spRequestsList"
		$List = $Ctx.Web.lists.GetByTitle($ListName)
		 
		#Define the CAML Query
		$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
		$qry = "<View><Query></Query></View>"
		$Query.ViewXml = $qry

		#Get All List Items matching the query
		$ListItems = $List.GetItems($Query)
		$Ctx.Load($ListItems)
		$Ctx.ExecuteQuery()
		
		write-host $ListItems.count


