param([string] $groupName = "")
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
if ([string]::isNullOrEmpty($groupName) -or !$groupName.ToUpper().Contains("SCI"))
{
	write-host SCI groupName Must be specified -f Yellow
	write-host in format HSS_SCI164-2021 -f Yellow
	
}
else
{

	$Credentials = get-SCred

	$adAdminGroupName  = $groupName + "_adminUG"
	$adJudgesGroupName = $groupName + "_judgesUG"

	$judGRPS = 'appphys','chem','earth','life','math','phys'
	$admGrps = 'appphys','chem','earth','fac','life','math','phys'

	write-Host "AD Admin  Group: $adAdminGroupName"  -f Yellow
	
	$srcADMGrp =  Get-ADGroup -Filter {Name -eq $adAdminGroupName}
	

	forEach($admGrp in $admGrps){
		$destADMGrpName = 'HSS_SCI-'+$admGrp+'_adminUG'
		$dstADMGrp =  Get-ADGroup -Filter {Name -eq $destADMGrpName}
		
		Add-ADGroupMember  $srcADMGrp -Members $dstADMGrp		
	}	
	#write-host "Press key to continue..."
	#Read-Host
	
	
	write-Host "AD Judges Group: $adJudgesGroupName" -f Yellow

	$srcJUDGrp =  Get-ADGroup -Filter {Name -eq $adJudgesGroupName}	
	

	forEach($judGrp in $judGRPS){
		$destJUDGrpName = 'HSS_SCI-'+$judGrp+'_judegesUG'
		$dstJUDGrp =  Get-ADGroup -Filter {Name -eq $destJUDGrpName}
		#$dstJUDGrp
		Add-ADGroupMember  $srcJUDGrp -Members $dstJUDGrp		
		
	}	
			

	 $configFile = ".\SCI\HSS_SCI.csv"
	 $template = $GroupName.Replace("HSS_","")
	 $listObj = @()
	 $listArray = @()
	 if (Test-Path -Path $configFile){
		$configCSV =  Import-CSV $configFile
		foreach($line in $configCSV){
			$listArray += $line.Title
			$listoItem = "" | Select ListName,AdmGrp, JudgesGrp, PermLvlJud, PermLvlAdm
	 
			$listoItem.ListName = $line.Title
			$listoItem.AdmGrp = "HSS_SCI-"+$line.GRP+"_adminUG"
			$listoItem.JudgesGrp = "HSS_SCI-"+$line.GRP+"_judegesUG"
			$listoItem.PermLvlJud = "Contribute"
			$listoItem.PermLvlAdm = "Full Control"
			$listObj += $listoItem
	 
			
		}
		write-host "Ensure that this Groups Exists:"  -f Green
		foreach($grp in $listObj){
			write-host $grp.AdmGrp -f Yellow
		}
		write-host
		foreach($grp in $listObj){
			write-host $grp.JudgesGrp -f Yellow
		}
		$tmpEdtGroupName="ekmd\sharepoint_temp_editorsug "
		$tmpEdtPermissionLevel="Full Control"
		 
		 read-host
		 $siteFQDN = "https://scholarships2.ekmd.huji.ac.il"
		 $listPrefix = "/home/NaturalScience/" + $template + "/"
		 
		 $siteName = $siteFQDN + $listPrefix;
		 
		 
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
			
			$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
			$spCurrentUser = $web.EnsureUser($currentUserName)


			
			
			
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
				#write-Host $listPrefix -f Green
				#write-Host $listItem.ListName -f Cyan
				$listURL = $listPrefix + $listItem.ListName
				write-host $listURL
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
			   
			   $Group =$Web.EnsureUser($tmpEdtGroupName)
			   $Ctx.load($Group)
			   $Ctx.ExecuteQuery()
		 
			#Grant permission to Group     
			#Get the role required
				$Role = $web.RoleDefinitions.GetByName($tmpEdtPermissionLevel)
				$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
				$RoleDB.Add($Role)
				 
			#Assign list permissions to the group
				$Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
				$List.Update()
				$Ctx.ExecuteQuery()
			#>
			$groupADM = "ekmd\"+$listItem.AdmGrp
			$groupJud = "ekmd\"+$listItem.JudgesGrp
			$permLvlAdm = $listItem.PermLvlAdm
			$permLvlJud = $listItem.PermLvlJud
			
			   $Group =$Web.EnsureUser($groupADM)
			   $Ctx.load($Group)
			   $Ctx.ExecuteQuery()
		 
			#Grant permission to Group     
			#Get the role required
				$Role = $web.RoleDefinitions.GetByName($permLvlAdm)
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
				$Role = $web.RoleDefinitions.GetByName($permLvlJud)
				$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
				$RoleDB.Add($Role)
				 
			#Assign list permissions to the group
				$Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
				$List.Update()
				$Ctx.ExecuteQuery()
			Write-Host "DocType: $ListName" -f Yellow
			Write-Host "Added $permLvlJud permission to $groupJud group." -foregroundcolor Green
			Write-Host "Added $permLvlAdm permission to $groupADM group." -foregroundcolor Green
			Write-Host "Added $tmpEdtPermissionLevel permission to $tmpEdtGroupName group." -foregroundcolor Green
			Write-Host 
			# Remove Current User from List Permissions
			# Current User rights Full Control was assignment
			# when we break inheritance rights
			
			$List.RoleAssignments.GetByPrincipal($spCurrentUser).DeleteObject()
			$List.Update()
			$Ctx.ExecuteQuery()



			}
			
	
		}
		Catch {
			write-host -f Red "Error Granting Permissions!" $_.Exception.Message
		} 
			
	}
	else
	{
		write-Host "Config File $configFile not Exists" -f Yellow
	}
				
	  

}


	

 