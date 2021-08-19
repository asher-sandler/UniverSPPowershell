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

$cred = get-SCred

 $siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 #$siteURL = "https://portals.ekmd.huji.ac.il/home/EDU/stdFolders";
 
 write-host "URL: $siteURL" -foregroundcolor Yellow
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
 $ctx.Credentials = $cred
 	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	 
	#$TaxonomySession = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($Ctx)
	#$Navigation  = New-Object Microsoft.SharePoint.Client.Publishing.Navigation
	# [Microsoft.SharePoint.Client.Publishing.Navigation] | gm
	
	
	<#
	$navQl = $Web.Navigation.QuickLaunch
	$ctx.Load($navQl)
	$Ctx.ExecuteQuery()	
	$navQl | gm
	
	
	#>
	# $NavigationSettings = New-Object Microsoft.SharePoint.Client.Publishing.Navigation.WebNavigationSettings($Ctx, $Web)
	#$Navigation | gm | fl
	#$NavigationSettings | gm | fl
	
	
	$QuickLaunch = $Ctx.Web.Navigation.QuickLaunch
	$Ctx.load($QuickLaunch)
	
	$Ctx.ExecuteQuery()
 	$QuickLaunch | gm
	read-host
	$NavigationNode = New-Object Microsoft.SharePoint.Client.NavigationNodeCreationInformation
	$NavigationNode.Title = "Support Center"
	$NavigationNode.Url = "http://ff.com"
	$NavigationNode.AsLastNode = $false
	$Ctx.Load($QuickLaunch.Add($NavigationNode))
	$Ctx.ExecuteQuery()
	$NavigationNode | gm | fl
	
	$Node = $QuickLaunch.Children | Where-Object {$_.Title -eq "Home"}	
	#$xmlsettings = New-Object System.Xml.XmlWriterSettings
	#$xmlsettings.Indent = $true
	#$xmlsettings.IndentChars = "    "
    $Node | gm
    read-host	
	# Set the File Name Create The Document
	#$XmlWriter = [System.XML.XmlWriter]::Create("YourXML.xml", $xmlsettings)
	#$NavigationNode.WriteToXml($XmlWriter,$ctx)
    write-host "ADD Menu"
	$ParentNodeTitle="New Nav Menu"
	$Title = "Home"
	$URL = "https://www.kaluga.ru"

   #Get the Top Navigation of the web
    $TopNavigationBar = $Ctx.Web.Navigation.TopNavigationBar
    #$TopNavigationBar = $Ctx.Web.Navigation.CurrentNavigationBar
	
	$nav = Ctx.Web.Navigation
    $Ctx.load($nav)
    $Ctx.load($TopNavigationBar)
    $Ctx.ExecuteQuery()
 
 $nav | gm | fl
 
 
    #Populate New node data
    $NavigationNode = New-Object Microsoft.SharePoint.Client.NavigationNodeCreationInformation
    $NavigationNode.Title ="Kaluga"
    $NavigationNode.Url = $URL
    $NavigationNode.AsLastNode = $true

    #Get the Parent Node
    $ParentNode = $TopNavigationBar | Where-Object {$_.Title -eq $ParentNodeTitle}
     
    #Add New node to the navigation
    If($ParentNode -eq $null)
    {
        #Check if the Link with Title exists already
        $Node = $TopNavigationBar | Where-Object {$_.Title -eq $Title}
        If($Node -eq $Null)
        {
            #Add Link to Root node of the Navigation
            $Ctx.Load($TopNavigationBar.Add($NavigationNode))
            $Ctx.ExecuteQuery()
            Write-Host -f Green "New Link '$Title' Added to the Navigation Root!"
        }
        Else
        {
            Write-Host -f Yellow "Navigation Link '$Title' Already Exists in Root!"
        }
    }
    else
    {
        #Get the Parent Node
        $Ctx.Load($ParentNode)
        $Ctx.Load($ParentNode.Children)
        $Ctx.ExecuteQuery()
  
        #Check if the Link with given title exists
        $Node = $ParentNode.Children | Where-Object {$_.Title -eq $Title}
        If($Node -eq $Null)
        {
            #Add Link to Parent Node
            $Ctx.Load($ParentNode.Children.Add($NavigationNode))
            $Ctx.ExecuteQuery()
            Write-Host -f Green "New Navigation Link '$Title' Added to the Parent '$ParentNodeTitle'!"
        }
        Else
        {
            Write-Host -f Yellow "Navigation Link '$Title' Already Exists in Parnet Node '$ParentNodeTitle'!"
        }
    }


#Read more: https://www.sharepointdiary.com/2018/03/sharepoint-online-add-link-top-navigation-using-powershell.html#ixzz73nvMPDJY	


#Read more: https://www.sharepointdiary.com/2018/03/sharepoint-online-add-link-to-quick-launch-using-powershell.html#ixzz73nWEVmZe	
	 