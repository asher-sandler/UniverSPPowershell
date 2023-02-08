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
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"
$list_ofLists = "101","102","105","105_2","108","109","112","113","117","122","128","123","124_1","124_2","124_3","124_4","140","141","144","150_1","150_2","150_3","150_4","151","155","156","157","172","176","179","180","181_1","181_2","197","199","299","33"

$tmpEdtGroupName="ekmd\sharepoint_temp_editorsug"
$tmpEdtPermissionLevel="Full Control"

$admGroupName="GRS_HUM22-2022_adminUG"
$admPermissionLevel="Full Control"


$groupJudPrefix = "grs_hum20-2022_judges-"
$groupJudPermissionLevel = "Contribute"

$Credentials = get-SCred
$siteName = "https://grs2.ekmd.huji.ac.il/home/humanities/HUM22-2022"
$siteUrl = get-UrlNoF5 $siteName

$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
$Ctx.Credentials = $Credentials
			
		 
$Web = $Ctx.Web
$ctx.Load($Web)
$Ctx.ExecuteQuery()
			
$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$spCurrentUser = $web.EnsureUser($currentUserName)

$listPrefix = "/home/humanities/HUM22-2022/"
foreach($listName in $list_ofLists){
	 
	$listURL = $listPrefix + $listName 
	#write-host $listURL
	#read-host
	#Get the List
	$List = $Web.GetList($listURL)
	$Ctx.Load($List)
	$Ctx.ExecuteQuery()
	Invoke-LoadMethod -Object $List -PropertyName "HasUniqueRoleAssignments"
	$Ctx.ExecuteQuery()
	if($List.HasUniqueRoleAssignments -eq $False)
	{
		write-host $List.Title " has inheriting permissions" -f Yellow
		$List.BreakRoleInheritance($False,$False) #keep existing list permissions & Item level permissions
		$Ctx.ExecuteQuery()
		Write-host -f Green "Permission inheritance broken successfully!"
	
	}
	else
	{
		Write-Host -f Yellow $List.Title " is already using Unique permissions!"
		
	}
	
	$groupJud = "EKMD\"+$groupJudPrefix+$listName.Replace("_","-")+"ug"
	$groupJudLocal = $groupJudPrefix+$listName.Replace("_","-")+"ug"
	
	$grpADJud = Get-ADGroup -identity $groupJudLocal
	if (![string]::IsNullOrEmpty($grpADJud)){
		write-host $groupJud
		#####################################
		$Group =$Web.EnsureUser($tmpEdtGroupName)
		$Ctx.load($Group)
		$Ctx.ExecuteQuery()
		 

		$Role = $web.RoleDefinitions.GetByName($tmpEdtPermissionLevel)
		$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
		$RoleDB.Add($Role)
				 
    	#Assign list permissions to the group
		$Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
		$List.Update()
		$Ctx.ExecuteQuery()
		
		################################

		$Group =$Web.EnsureUser($admGroupName)
		$Ctx.load($Group)
		$Ctx.ExecuteQuery()
		 

		$Role = $web.RoleDefinitions.GetByName($admPermissionLevel)
		$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
		$RoleDB.Add($Role)
				 
    	#Assign list permissions to the group
		$Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
		$List.Update()
		$Ctx.ExecuteQuery()

		#####################################
		$Group =$Web.EnsureUser($groupJud)
		$Ctx.load($Group)
		$Ctx.ExecuteQuery()
		 

		$Role = $web.RoleDefinitions.GetByName($groupJudPermissionLevel)
		$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
		$RoleDB.Add($Role)
				 
    	#Assign list permissions to the group
		$Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
		$List.Update()
		$Ctx.ExecuteQuery()
		
		#######################################

		$List.RoleAssignments.GetByPrincipal($spCurrentUser).DeleteObject()
		$List.Update()
		$Ctx.ExecuteQuery()
		
		
		
	}
	
	#read-host
	

}