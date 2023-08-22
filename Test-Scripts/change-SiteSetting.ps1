param([string] $SiteURL = "")
$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"

#$wrkSite 		=  "https://scholarships.ekmd.huji.ac.il/home/SocialSciences/SOC201-2021"
#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
    
#Config Parameters
$SiteURL= "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace/Navigation"
$SiteURL= "https://scholarships.ekmd.huji.ac.il/home/SocialSciences/SOC202-2021"
$SiteURL= "https://ttp.ekmd.huji.ac.il/home/EdmondandLilySafraCenterforBrainSciences/ELS16-2021"
 
#Get Credentials to connect
$Cred = Get-Credential
  
Try {
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    $Ctx.Credentials = New-Object System.Net.NetworkCredential($Cred.UserName,$Cred.Password)
    
    #Get the Web
    $Web = $Ctx.Web
    $ctx.Load($Web)
    $Ctx.ExecuteQuery()
 
    $TaxonomySession = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($Ctx)
    $NavigationSettings = New-Object Microsoft.SharePoint.Client.Publishing.Navigation.WebNavigationSettings($Ctx, $Web)
 
    #Set Both current and global navigation settings to structural - Other values: PortalProvider,InheritFromParentWeb ,TaxonomyProvider
    #$NavigationSettings.GlobalNavigation.Source = "PortalProvider"
    $NavigationSettings.CurrentNavigation.Source = "PortalProvider"
 
    #Show subsites in Global navigation
    $Web.AllProperties["__IncludeSubSitesInNavigation"] = $False
 
    #Show pages in global navigation
    $Web.AllProperties["__IncludePagesInNavigation"] = $True
 
    #Maximum number of dynamic items to in global navigation
    $web.AllProperties["__GlobalDynamicChildLimit"] = 15
 
    #Update Settings
    $Web.Update()
    $NavigationSettings.Update($TaxonomySession)
    $Ctx.ExecuteQuery()
 
    Write-host -f Green "Navigation Settings Updated!"
}
Catch {
    write-host -f Red "Error Updating Navigation Settings!" $_.Exception.Message
}



