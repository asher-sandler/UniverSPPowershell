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
 $siteURL = "https://grs.ekmd.huji.ac.il/home/SocialSciences/SOC36-2020";
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
	<#
	
	
	
		CustomFromJson               Method     bool CustomFromJson(Microso...
		DeleteObject                 Method     void DeleteObject()
		Equals                       Method     bool Equals(System.Object obj)
		FromJson                     Method     void FromJson(Microsoft.Sha...
		GetHashCode                  Method     int GetHashCode()
		IsObjectPropertyInstantiated Method     bool IsObjectPropertyInstan...
		IsPropertyAvailable          Method     bool IsPropertyAvailable(st...
		RefreshLoad                  Method     void RefreshLoad()
		Retrieve                     Method     void Retrieve(), void Retri...
		ToString                     Method     string ToString()
		Update                       Method     void Update()
		Children                     Property   Microsoft.SharePoint.Client...
		Context                      Property   Microsoft.SharePoint.Client...
		Id                           Property   int Id {get;}
		IsDocLib                     Property   bool IsDocLib {get;}
		IsExternal                   Property   bool IsExternal {get;}
		IsVisible                    Property   bool IsVisible {get;set;}
		ListTemplateType             Property   Microsoft.SharePoint.Client...
		ObjectVersion                Property   string ObjectVersion {get;s...
		Path                         Property   Microsoft.SharePoint.Client...
		ServerObjectIsNull           Property   System.Nullable[bool] Serve...
		Tag                          Property   System.Object Tag {get;set;}
		Title                        Property   string Title {get;set;}
		TypedObject                  Property   Microsoft.SharePoint.Client...
		Url                          Property   string Url {get;set;}
			
			
	
	
	
	$QuickLaunch = $Ctx.Web.Navigation.QuickLaunch
	
	$Ctx.load($QuickLaunch)
	$Ctx.ExecuteQuery()
 	
	For($i = $QuickLaunch.Count -1 ; $i -ge 0; $i--)
	{
		if ($QuickLaunch[$i].Title -eq "Support Center"){
			$QuickLaunch[$i].DeleteObject()
			$Ctx.ExecuteQuery()
		}
	}
	#>
	$menuDump = @()
	
	$QuickLaunch = $Ctx.Web.Navigation.QuickLaunch
	
	$Ctx.load($QuickLaunch)
	$Ctx.ExecuteQuery()
 	
    foreach($QuickLaunchLink in $QuickLaunch){	
	    $menuItem =  "" | Select Title, Url, Items
		$Ctx.Load($QuickLaunchLink)
		$Ctx.Load($QuickLaunchLink.Children)
		$Ctx.ExecuteQuery()
		$menuItem.Title = $QuickLaunchLink.Title
		$menuItem.Url = $QuickLaunchLink.Url
		$docLibNameHe = "העלאת מסמכים"
		if ($QuickLaunchLink.Title.Contains($docLibNameHe)){
			continue
		}
		$QuickLaunchLink.Url
		$QuickLaunchLink.Title
		#$Ctx.Load($QuickLaunchLink.Properties)
		#$Ctx.ExecuteQuery()
		# $QuickLaunchLink.Properties["Audience"] 
		
		#$QuickLaunchLink | gm
		$child = $QuickLaunchLink.Children
		$items = @() 
		foreach($childItem in $child) {
			$Ctx.Load($childItem)
			
			$Ctx.ExecuteQuery()
			$submenu = "" | Select Title, Url
			$submenu.Title = $childItem.Title
			$submenu.Url = $childItem.Url
			$items += $submenu
			#$childItem | gm
			#$childItem 
		}
		$menuItem.Items = $items
		$menuDump += $menuItem
		
		#read-host
	}
	$outfile = ".\JSON\MenuDmp.json"
	$menuDump | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
	#$child = $QuickLaunch.Children 
	
	#$Ctx.load($child)
	
	#$Ctx.ExecuteQuery()
	#$child
	#read-host
<#	
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

#>

#Read more: https://www.sharepointdiary.com/2018/03/sharepoint-online-add-link-top-navigation-using-powershell.html#ixzz73nvMPDJY	


#Read more: https://www.sharepointdiary.com/2018/03/sharepoint-online-add-link-to-quick-launch-using-powershell.html#ixzz73nWEVmZe	
	 