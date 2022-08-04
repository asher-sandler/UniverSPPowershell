param([string] $groupName = "")

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
if ([string]::isNullOrEmpty($groupName))
{
	write-host groupName Must be specified  -foregroundcolor Yellow
	write-host in format hss_HUM164-2021  -foregroundcolor Yellow
	
}
else
{
	if (Test-CurrentSystem $groupName){
		$jsonFile = "JSON\"+$groupName+".json"
		if (Test-Path $jsonFile){
			write-host "Group: $groupName" -foregroundcolor Green
			$Credentials = get-SCred	
			
			$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
			$jsonMenuFile = ".\JSON\"+ $groupName+"-MenuDmp-Src.json"
			if (Test-Path $jsonMenuFile){
				$menuNewItems = get-content $jsonMenuFile -encoding default | ConvertFrom-Json
				$siteUrl    = get-CreatedSiteName $spObj
				$oldSiteURL = $spObj.oldSiteURL
				
				$menuTitle = "Ranking"
				$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
				
				

				$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
				$Ctx.Credentials = $Credentials
				
			 
				$Web = $Ctx.Web
				$ctx.Load($Web)
				$Ctx.ExecuteQuery()
				$spCurrentUser = $web.EnsureUser($currentUserName)

				
				write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
				write-host "New Site: $siteUrl" -foregroundcolor Green
				write-host "menuTitle: $menuTitle" -foregroundcolor Green
				write-Host Press Key ...
				read-host
				foreach($subMenuMain in $menuNewItems){
					
					$mainMenuTitle = $subMenuMain.Title
					if ($mainMenuTitle -eq $menuTitle){
						write-Host  "mainMenuTitle : $mainMenuTitle" -f Green
						foreach($subMenuItem in $subMenuMain.Items){
							if (![string]::isNullOrEmpty($subMenuItem)){
								$docLibName = $subMenuItem.Name
								write-Host "docLibName : $docLibName" -f Cyan
							
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
									
									$List = $Ctx.Web.lists.GetByTitle($docLibName)
									$Ctx.load($List)
									
									Invoke-LoadMethod -Object $List -PropertyName "HasUniqueRoleAssignments"
									$Ctx.ExecuteQuery()	
									
									if($List.HasUniqueRoleAssignments -eq $False)
									{
										$List.BreakRoleInheritance($False,$false) #keep existing list permissions & Item level permissions
										$Ctx.ExecuteQuery()
										Write-host -f Green "$docLibName : Permission inheritance broken successfully!"
									}
									else
									{
										write-Host "$docLibName is already using Unique permissions!" -f Yellow
									}

									foreach($permItem in $subMenuItem.ListPermissons){

										$groupName = $permItem.Name.Replace($spObj.OldSiteSuffix,$spObj.RelURL)
										write-Host $groupName -f Magenta
										write-Host $permItem.PermissionLevels -f Magenta
										write-Host "----------------" -f Magenta
										write-Host

										$Group =$Web.EnsureUser($groupName)
										$Ctx.load($Group)
										$Ctx.ExecuteQuery()
										
										$Role = $web.RoleDefinitions.GetByName($permItem.PermissionLevels)
										$RoleDB = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Ctx)
										$RoleDB.Add($Role)
					 
										#Assign list permissions to the group
										$Permissions = $List.RoleAssignments.Add($Group,$RoleDB)
										
										$List.Update()
										$Ctx.ExecuteQuery()

									}
									# Remove Current User from List Permissions
									# Current User rights Full Control was assignment
									# when we break inheritance rights
									
									$List.RoleAssignments.GetByPrincipal($spCurrentUser).DeleteObject()
									$List.Update()
									$Ctx.ExecuteQuery()
									
									#read-host
								}
								Catch
								{
									write-host -f Red "Error Granting Permissions!" $_.Exception.Message
								} 
								
								
							}
						}	

					}
				}

				

			}
			else
			{
				Write-Host "File $jsonMenuFile does not exists." -foregroundcolor Yellow
				Write-Host "Run 5.copy-Doclib.ps1 first. " -foregroundcolor Yellow
				
			}
			

		}	
		else
		{
			Write-Host "File $jsonFile does not exists." -foregroundcolor Yellow
			Write-Host "Run 1.Get-SPRequest.ps1 first. " -foregroundcolor Yellow
		}
	}
	else
	{
		Write-Host "Group Name $groupName is not valid!" -foregroundcolor Yellow
	}
}	