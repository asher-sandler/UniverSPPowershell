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

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
. "$dp0\Utils-SiteClone.ps1"

<#
GLOBAL#0	Global template
STS#0	Team Site
STS#1	Blank Site
STS#2	Document Workspace
MPS#0	Basic Meeting Workspace
MPS#1	Blank Meeting Workspace
MPS#2	Decision Meeting Workspace
MPS#3	Social Meeting Workspace
MPS#4	Multipage Meeting Workspace
CENTRALADMIN#0	Central Admin Site
WIKI#0	Wiki Site
BLOG#0	Blog
SGS#0	Group Work Site
TENANTADMIN#0	Tenant Admin Site
APP#0	App Template
APPCATALOG#0	App Catalog Site
ACCSRV#0	Access Services Site
ACCSVC#0	Access Services Site Internal
ACCSVC#1	Access Services Site
BDR#0	Document Center
DEV#0	Developer Site
DOCMARKETPLACESITE#0	Academic Library
EDISC#0	eDiscovery Center
EDISC#1	eDiscovery Case
OFFILE#0	(obsolete) Records Center
OFFILE#1	Records Center
OSRV#0	Shared Services Administration Site
PPSMASite#0	PerformancePoint
BICenterSite#0	Business Intelligence Center
SPS#0	SharePoint Portal Server Site
SPSPERS#0	SharePoint Portal Server Personal Space
SPSPERS#2	Storage And Social SharePoint Portal Server Personal Space
SPSPERS#3	Storage Only SharePoint Portal Server Personal Space
SPSPERS#4	Social Only SharePoint Portal Server Personal Space
SPSPERS#5	Empty SharePoint Portal Server Personal Space
SPSMSITE#0	Personalization Site
SPSTOC#0	Contents area Template
SPSTOPIC#0	Topic area template
SPSNEWS#0	News Site
CMSPUBLISHING#0	Publishing Site
BLANKINTERNET#0	Publishing Site
BLANKINTERNET#1	Press Releases Site
BLANKINTERNET#2	Publishing Site with Workflow
SPSNHOME#0	News Site
SPSSITES#0	Site Directory
SPSCOMMU#0	Community area template
SPSREPORTCENTER#0	Report Center
SPSPORTAL#0	Collaboration Portal
SRCHCEN#0	Enterprise Search Center
PROFILES#0	Profiles
BLANKINTERNETCONTAINER#0	Publishing Portal
SPSMSITEHOST#0	My Site Host
ENTERWIKI#0	Enterprise Wiki
PROJECTSITE#0	Project Site
PRODUCTCATALOG#0	Product Catalog
COMMUNITY#0	Community Site
COMMUNITYPORTAL#0	Community Portal
SRCHCENTERLITE#0	Basic Search Center
SRCHCENTERLITE#1	Basic Search Center
visprus#0	Visio Process Repository



#>
function Get-SubSiteName($siteName,$SubsiteURL){
	$siteUrl = get-UrlNoF5 $siteName
	
	#$siteUrl =  $siteName

	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx.Credentials = $Credentials
	$web = $ctx.web;
	$Ctx.Load($web)
	$Ctx.ExecuteQuery()
	
	$fullSubSiteUrl = $web.URL + "/" + $SubsiteURL
	return $fullSubSiteUrl
		
}
function Check-SubSiteExists($siteName,$SubsiteURL){
	$siteUrl = get-UrlNoF5 $siteName
	
	#$siteUrl =  $siteName

	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx.Credentials = $Credentials
	$web = $ctx.web;
	$Ctx.Load($web)
	$Ctx.Load($web.Webs)
	$Ctx.ExecuteQuery()
	
	$fullSubSiteUrl = $web.URL + "/" + $SubsiteURL
	$subSiteExists = $false
    foreach($subweb in $web.webs){
 	   if ($subweb.Url -eq $fullSubSiteUrl)
	   {
		   $subSiteExists = $true
		   break
	   }
	   
	
	}
	return $subSiteExists
}

function Create-SubSite($siteName,$template,$subUrl,$subTitle){
	 $siteUrl = get-UrlNoF5 $siteName
	 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	 $Ctx.Credentials = $Credentials
	 $regionalSetting = $Ctx.Web.RegionalSettings;
	 #$SiteTemplates = $Ctx.Site.GetWebTemplates("1033","0")
	 #$Ctx.Load($SiteX)
 
	 $Ctx.Load($regionalSetting)
	 $Ctx.ExecuteQuery() 
	#$SiteTemplates
	#$SiteX | fl
	$regSet = $regionalSetting.LocaleId # | gm
	$SiteTemplates = $Ctx.Site.GetWebTemplates($regSet.ToString(),"0")
	$Ctx.Load($SiteTemplates)
	$Ctx.ExecuteQuery() 
	 
	$Template = $SiteTemplates | Where {$_.Name -eq $SiteTemplateName}
	
 
	$Subsite  = New-Object Microsoft.SharePoint.Client.WebCreationInformation
	$Subsite.Title = $SubsiteTitle
	$Subsite.WebTemplate = $Template.Name
	$Subsite.Url = $SubsiteURL
	#$Subsite.Language = 1037;
	$Subsite.Language = $regSet;
	$NewSubsite = $Ctx.Web.Webs.Add($Subsite)
	$Ctx.ExecuteQuery()
	write-host "$SubsiteURL created" -f Yellow

 	return $Subsite
}
function Get-WebUsers($siteName){
	 $siteUrl = get-UrlNoF5 $siteName
	 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	 $Ctx.Credentials = $Credentials
 	 
    $RoleAssignments=$Ctx.web.RoleAssignments 
    $Ctx.Load($RoleAssignments)
    $Ctx.ExecuteQuery()
	
    $siteRoles = @()
	foreach($roleassgn in $RoleAssignments){
		$member = $roleassgn.Member
		$Rd = $roleassgn.RoleDefinitionBindings
		$Ctx.Load($member)
		$Ctx.Load($Rd)
		$Ctx.ExecuteQuery()
		
		$rl = "" | Select LoginName, Title, PrincipalType, RoleDefinition, Hidden
		
		$rl.LoginName = $member.LoginName
		$rl.Title = $member.Title
		$rl.PrincipalType = $member.PrincipalType
		$rl.RoleDefinition = $Rd.Name
		$rl.Hidden = $Rd.Hidden
		$siteRoles += $rl
		
		#write-host $member.LoginName
		#write-host $Rd.Name
	}
	 
	 return $siteRoles
    	
}
# HSS_SCI30-2020_adminSP
function Set-WebPermissionsOnWeb($siteName,$GroupName,$Role){

	$siteUrl = get-UrlNoF5 $siteName
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx.Credentials = $Credentials
    $RoleAssignments=$Ctx.web.RoleAssignments 
	$web = $ctx.web;
	$Ctx.Load($web)
	
	$web.BreakRoleInheritance($true, $false) 
    $roleType = [Microsoft.SharePoint.Client.RoleType]$Role

    # get role definition
    $roleDefs = $web.RoleDefinitions
    $Ctx.Load($roleDefs)
    $Ctx.ExecuteQuery()
    $roleDef = $roleDefs | where {$_.RoleTypeKind -eq $Roletype}

    # get group/principal
    $groups = $web.SiteGroups
    $ctx.Load($groups)
    $ctx.ExecuteQuery()
    #$group = $groups | where {$_.Title -eq $RootWeb.Title + " " + $GroupName}
    $group = $groups | where {$_.Title -eq  $GroupName}


    $collRdb = new-object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($ctx)
    $collRdb.Add($roleDef)
    $collRoleAssign = $web.RoleAssignments
    $rollAssign = $collRoleAssign.Add($group, $collRdb)
    $ctx.ExecuteQuery()
	
	return $roleDef
 	
}
 $Credentials = get-SCred

 
 $siteName = "https://grs2.ekmd.huji.ac.il/home/natureScience/SCI26-2022";
 $siteName = "https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 
 
 <#
 $SiteTemplateName = "STS#1" # empty 
 $SubsiteURL = "2022-2"
 $SubsiteTitle = "Archive 2022 Semester 2" 
 
 $subSiteExists = Check-SubSiteExists $siteName  $SubsiteURL
 
 if ($subSiteExists){
	 write-host "$SubsiteURL already exists" -f Yellow
 }
 else
 {
	$subsite = Create-SubSite $siteName $SiteTemplateName $SubsiteURL $SubsiteTitle
	 
 }
 $subsiteName = Get-SubSiteName $siteName $SubsiteURL 
 write-host $subsiteName -f Yellow
  $siteRoles = Get-WebUsers $subsiteName
  
  $siteRoles
  write-host $siteName -f Yellow
  $siteRoles = Get-WebUsers $siteName
  
  $siteRoles
 $group = "HSS_SCI30-2020_adminSP"
 $Role = "Read"
 Set-WebPermissionsOnWeb $siteName $group $Role
 #>
 write-host $siteName -f Green
 # MIHZUR
 
 
 #Get Old Site Name
 $siteObj = "" | Select SiteName
 
 $siteObj.SiteName = Get-SiteName $siteName
 
 $siteObj
 #Get Old Site Groups and Permissions
 #Get Old site Lists
 #Get Old Site DocType
 #Get Old Site DocLib
 #Copy All File from docLib and MetaData (DocType)
 
 #Create new Subsite with name and Archive
 
 #Create all lists
 #Create DocType
 #Create Applicants
 #Create All Premissions
 #Create All DocLib
 #Copy Files to Doclibs
 #Bind new DocType to each file in DocLib
 
 #Clear Old Site
 #Replace Home Page
 #Set New deadline for Applicants
 #
