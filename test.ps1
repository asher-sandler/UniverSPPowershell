cls
$spTypes = @()
write-host Init
#$spTypes += "Microsoft.Office.Client.Policy.dll"
#$spTypes += "Microsoft.Office.Client.Policy.Portable.dll"
#$spTypes += "Microsoft.Office.Client.TranslationServices.dll"
#$spTypes += "Microsoft.Office.Client.TranslationServices.Portable.dll"

#$spTypes += "Microsoft.SharePoint.Client.DocumentManagement.dll"
#$spTypes += "Microsoft.SharePoint.Client.DocumentManagement.Portable.dll"
#$spTypes += "Microsoft.SharePoint.Client.Portable.dll"

#$spTypes += "Microsoft.SharePoint.Client.Publishing.Portable.dll"

#$spTypes += "Microsoft.SharePoint.Client.Runtime.Portable.dll"
#$spTypes += "Microsoft.SharePoint.Client.Runtime.Windows.dll"
#$spTypes += "Microsoft.SharePoint.Client.Runtime.WindowsPhone.dll"
#$spTypes += "Microsoft.SharePoint.Client.Runtime.WindowsStore.dll"
#$spTypes += "Microsoft.SharePoint.Client.Search.Applications.dll"
#$spTypes += "Microsoft.SharePoint.Client.Search.Applications.Portable.dll"

#$spTypes += "Microsoft.SharePoint.Client.Search.Portable.dll"

#$spTypes += "Microsoft.SharePoint.Client.Taxonomy.Portable.dll"

#$spTypes += "Microsoft.SharePoint.Client.UserProfiles.Portable.dll"
#$spTypes += "Microsoft.SharePoint.Client.WorkflowServices.dll"
#$spTypes += "Microsoft.SharePoint.Client.WorkflowServices.Portable.dll"



$spTypes += "Microsoft.SharePoint.Client.Publishing.dll"
$spTypes += "Microsoft.SharePoint.Client.Runtime.dll"
$spTypes += "Microsoft.SharePoint.Client.Search.dll"
$spTypes += "Microsoft.SharePoint.Client.Taxonomy.dll"
$spTypes += "Microsoft.SharePoint.Client.UserProfiles.dll"
$spTypes += "Microsoft.SharePoint.Client.dll"

#$user = "AsherC@chordmed.com"
$user = "ashersa@ekmd.huji.ac.il"

#$siteURL = "https://fordmed.sharepoint.com/sites/it_helpdesk/ARD"
$siteURL = "https://scholarships.ekmd.huji.ac.il/home/General/GEN132-2021"

$spPath = 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\'

	#Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.UserProfiles.dll")
	#Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.Taxonomy.dll")
	#Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.Search.dll")
	#Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.Runtime.dll")
	#Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.Publishing.dll")
	#Add-Type -Path ($spPath+"Microsoft.SharePoint.Client.dll")
    

foreach ($dll in $spTypes)
{
	Add-Type -Path ($spPath+$dll)
}

Write-Host Password
$pwd = read-host -Prompt "Please enter your password" -AsSecureString
$creds = New-Object Microsoft.SharePoint.Client.SharepointOnlineCredentials ($user, $pwd)

$Context = New-Object Microsoft.SharePoint.Client.ClientContext($siteURL)
$Context.Credentials = $creds

#site properties

write-host site properties

$site = $Context.Site

write-host We are Here 1
$Context.Load($site)
$Context | gm
$Context.Web
write-host We are Here 2
$context.ExecuteQuery()

write-host We are Here 3
$site.URL
$site.GeoLocation
