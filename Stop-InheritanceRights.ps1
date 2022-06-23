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

$Credentials = get-SCred

 $group = "SCI96-2022"
 $listArray = "AppliedPhysics","Physics","Math","LifeScience","Earth","Chemistry"
 $siteFQDN = "https://scholarships2.ekmd.huji.ac.il"
 $listPrefix = "/home/NaturalScience/" + $group + "/"
 
 $siteName = $siteFQDN + $listPrefix;
 $listObj = @()
 
 $listoItem = "" | Select ListName,AdmGrp, JudgesGrp, PermissionLevel
 
 $listoItem.ListName = "Physics"
 $listoItem.AdmGrp = "HSS_"+$group+"_admin-physUG"
 $listoItem.JudgesGrp = "HSS_"+$group+"_judges-physUG"
 $listoItem.PermissionLevel = "Contribute"
 
 $listObj += $listoItem
 
 $listoItem = "" | Select ListName,AdmGrp, JudgesGrp, PermissionLevel
 
 $listoItem.ListName = "AppliedPhysics"
 $listoItem.AdmGrp = "HSS_"+$group+"_admin-appphysUG"
 $listoItem.JudgesGrp = "HSS_"+$group+"_judges-appphysUG"
 $listoItem.PermissionLevel = "Contribute"
 
 $listObj += $listoItem
 
 $listoItem = "" | Select ListName,AdmGrp, JudgesGrp, PermissionLevel
 
 $listoItem.ListName = "Math"
 $listoItem.AdmGrp = "HSS_"+$group+"_admin-mathUG"
 $listoItem.JudgesGrp = "HSS_"+$group+"_judges-mathUG"
 $listoItem.PermissionLevel = "Contribute"
 
 $listObj += $listoItem
 
 $listoItem = "" | Select ListName,AdmGrp, JudgesGrp, PermissionLevel
 
 $listoItem.ListName = "LifeScience"
 $listoItem.AdmGrp = "HSS_"+$group+"_admin-lifeUG"
 $listoItem.JudgesGrp = "HSS_"+$group+"_judges-lifeUG"
 $listoItem.PermissionLevel = "Contribute"
 
 $listObj += $listoItem

 $listoItem = "" | Select ListName,AdmGrp, JudgesGrp, PermissionLevel
 
 $listoItem.ListName = "Earth"
 $listoItem.AdmGrp = "HSS_"+$group+"_admin-earthUG"
 $listoItem.JudgesGrp = "HSS_"+$group+"_judges-earthUG"
 $listoItem.PermissionLevel = "Contribute"
 
 $listObj += $listoItem


 $listoItem = "" | Select ListName,AdmGrp, JudgesGrp, PermissionLevel
 
 $listoItem.ListName = "Chemistry"
 $listoItem.AdmGrp = "HSS_"+$group+"_admin-chemUG"
 $listoItem.JudgesGrp = "HSS_"+$group+"_judges-chemUG"
 $listoItem.PermissionLevel = "Contribute"
 
 $listObj += $listoItem
 
 #$listObj | ConvertTo-Json -Depth 100 | out-file $("JSON\SPGRPS-NaturalScience-"+$group+".json") 
 $siteUrl = get-UrlNoF5 $siteName

 #write-host ...
 #read-host
 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx.Credentials = $Credentials
	
 
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
	
	$GroupName="ekmd\sharepoint_temp_editorsug "
	$PermissionLevel="Full Control"


	
	
	
Try {

    #Helper function to get nongeneric properties of the Object in CSOM  
    Function Invoke-LoadMethod() {
    param( [Microsoft.SharePoint.Client.ClientObject]$Object, [string]$PropertyName )
       $ctx = $Object.Context
       $load = [Microsoft.SharePoint.Client.ClientContext].GetMethod("Load")
       $type = $Object.GetType()
       $clientLoad = $load.MakeGenericMethod($type)
 
       $Parameter = [System.Linq.Expressions.Expression]::Parameter(($type), $type.Name)
       $Expression = [System.Linq.Expressions.Expression]::Lambda(
                [System.Linq.Expressions.Expression]::Convert([System.Linq.Expressions.Expression]::PropertyOrField($Parameter,$PropertyName),
                [System.Object] ), $($Parameter))
 
       $ExpressionArray = [System.Array]::CreateInstance($Expression.GetType(), 1)
       $ExpressionArray.SetValue($Expression, 0)
       $clientLoad.Invoke($ctx,@($Object,$ExpressionArray))
    }
   
    #Setup the context
 	foreach($listItem in $listObj){
		$listURL = $listPrefix + $listItem.ListName
	    #write-host $listURL
		#read-host
		#Get the List
		$List = $Web.GetList($listURL)
		$Ctx.Load($List)
		#$Ctx.ExecuteQuery()
		Invoke-LoadMethod -Object $List -PropertyName "HasUniqueRoleAssignments"
		$Ctx.ExecuteQuery()
		$ListName = $List.Title

	 
		#Check if list is inheriting permissions; Break permissions of the list, if its inherited
		if($List.HasUniqueRoleAssignments -eq $False)
		{
			#sharepoint online break inheritance powershell
			#$List.BreakRoleInheritance($True,$True) #keep existing list permissions & Item level permissions
			$List.BreakRoleInheritance($False,$False) #keep existing list permissions & Item level permissions
			$Ctx.ExecuteQuery()
			Write-host -f Green "Permission inheritance broken successfully!"
		}
		else
		{
			Write-Host -f Yellow "List is already using Unique permissions!"
		}
        #Get the group or user
       #$Group =$Web.SiteGroups.GetByName($GroupName) #For User: $Web.EnsureUser('salaudeen@crescent.com')
	   $Group =$Web.EnsureUser($GroupName)
       $Ctx.load($Group)
       $Ctx.ExecuteQuery()
 
    #Grant permission to Group     
    #Get the role required
        $Role = $web.RoleDefinitions.GetByName($PermissionLevel)
        $RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
        $RoleDB.Add($Role)
         
    #Assign list permissions to the group
        $Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
        $List.Update()
    $Ctx.ExecuteQuery()
	
	$groupADM = "ekmd\"+$listItem.AdmGrp
	$groupJud = "ekmd\"+$listItem.JudgesGrp
	$permLvlX = $listItem.PermissionLevel
	
	   $Group =$Web.EnsureUser($groupADM)
       $Ctx.load($Group)
       $Ctx.ExecuteQuery()
 
    #Grant permission to Group     
    #Get the role required
        $Role = $web.RoleDefinitions.GetByName($permLvlX)
        $RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
        $RoleDB.Add($Role)
         
    #Assign list permissions to the group
        $Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
        $List.Update()
    $Ctx.ExecuteQuery()

	   $Group =$Web.EnsureUser($groupJud)
       $Ctx.load($Group)
       $Ctx.ExecuteQuery()
 
    #Grant permission to Group     
    #Get the role required
        $Role = $web.RoleDefinitions.GetByName($permLvlX)
        $RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
        $RoleDB.Add($Role)
         
    #Assign list permissions to the group
        $Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
        $List.Update()
    $Ctx.ExecuteQuery()
	
    Write-Host "Added $PermissionLevel permission to $GroupName group in $ListName list. " -foregroundcolor Green



	}
}
Catch {
    write-host -f Red "Error Granting Permissions!" $_.Exception.Message
} 




	

 