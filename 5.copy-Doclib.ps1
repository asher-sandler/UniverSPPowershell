param([string] $groupName = "")
function Create-NavSubMenuX( $SiteURL, $menu, $pTitle){
	$siteName = get-UrlNoF5 $SiteURL
	write-host "Create Nav SubMenu: $siteURL" -foregroundcolor Green
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
	$ctx.Credentials = $Credentials
 	
	
	#Get the Quick Launch Navigation of the web
	$Navigation = $Ctx.Web.Navigation.QuickLaunch
	$Ctx.load($Navigation)
	$Ctx.ExecuteQuery()
	
    	

	$ParentNode = $Navigation | Where-Object {$_.Title -eq $pTitle}
    $Ctx.Load($ParentNode)
    $Ctx.Load($ParentNode.Children)
    $Ctx.ExecuteQuery()
	
	If($ParentNode -eq $null)
	{
		write-host write-host $("Menu Item Does Not Exist:" + $item.Title) -f Magenta
	}
	else
	{
		#foreach($subMenuItem in $menu){

			$NavigationNode = New-Object Microsoft.SharePoint.Client.NavigationNodeCreationInformation
			$NavigationNode.Title = $menu.Title
			$NavigationNode.Url = $menu.Url
			$NavigationNode.AsLastNode = $true
 
			$Node = $ParentNode.Children | Where-Object {$_.Title -eq $subMenuItem.Title}

			If($Node -eq $Null)
			{
				#Add Link to Parent Node
				$Ctx.Load($ParentNode.Children.Add($NavigationNode))
				$Ctx.ExecuteQuery()
				Write-Host -f Green "New Navigation Link '$Title' Added to the Parent '$ParentNodeTitle'!"
				write-host $("Menu Item:" + $pTitle) -f Yellow
				write-host $("Create SubMenuItem Name:" + $subMenuItem.Title) -f Cyan
				write-host $("Create SubMenuItem Url :" + $subMenuItem.Url) -f Cyan
				write-host 	

			}
			Else
			{
				Write-Host -f Yellow "Navigation Node $($subMenuItem.Title) Already Exists in Parent Node $pTitle!"
			}



		#}			
	}
 
	
}

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
			
			
			$siteUrl    = get-CreatedSiteName $spObj
			$oldSiteURL = $spObj.oldSiteURL
			
			

			$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
			$Ctx.Credentials = $Credentials
				
			
			$web = $Ctx.Web
			$ctx.Load($web)
			$Ctx.ExecuteQuery()

			$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
			$spCurrentUser = $web.EnsureUser($currentUserName)

			
			write-host "Old Site: $oldSiteURL" -foregroundcolor Cyan
			write-host "New Site: $siteUrl" -foregroundcolor Green
			write-Host Press Key ...
			read-host
			# $docLibName = "סמירה עליאן"
			#$docLibNames =  @()
			#$docLibNames += "ResponseLetters"
			# $docLibNames += "Biotechnology (890)"
			
			#$docLibNames += "Computer Science (521)"
			#$docLibNames += "Computational Biology (532)"
			#$docLibNames += "Bioengineering (582)"
			#$docLibNames += "אסמהאן מסרי-חרזאללה"
			#$docLibNames += "פרידה ניסים-אמיתי"
			#$docLibNames += "applicantsCV"
			#$docLibNames += "פיסיקה (541)"
			<#
			$docLibNames += "מתמטיקה (530)"
			$docLibNames += "כימיה (560)"
			$docLibNames += "ביוטכנולוגיה (890)"
			$docLibNames += "פיסיקה יישומית (511)"
			$docLibNames += "מדעי החיים"
			$docLibNames += "מדעי כדור הארץ"
			$docLibNames += "מדעי הסביבה (591)"
			$docLibNames += "ביו-הנדסה (582)"
			#>
			#$docLibNames += "C MA and PhD students"
			
			$heDocLibName = "העלאת מסמכים"
			$enDocLibName = "Documents Upload"
			$flagOldMenu =  $True
			$menuDumpSrc = Collect-Navigation $oldSiteURL $flagOldMenu
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-Src.json"
			#$menuDumpSrc = get-content $outfile -encoding default | ConvertFrom-Json	
			$menuDumpSrc | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
		
			
			$menuDumpDst = Collect-Navigation $siteUrl $flagOldMenu
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-Dst.json"
			#$menuDumpDst = get-content $outfile -encoding default | ConvertFrom-Json
			$menuDumpDst | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
						
			
			$menuNewItemsX = Compare-Navig $menuDumpSrc $menuDumpDst $oldSuffix $newSuffix
			$menuNewItems  = Check-SubNavOldItems  $menuDumpSrc $menuNewItemsX $oldSuffix $newSuffix
		
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-NewX.json"
			$menuNewItemsX | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
			write-Host "Written File $outfile" -f Green
			$outfile = ".\JSON\"+ $groupName+"-MenuDmp-New.json"
			$menuNewItems = Get-DocLibCollectionsRealNames  $menuNewItems $oldSiteURL $siteUrl
			
			$menuNewItems | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
			
			
			foreach($subMenu in $menuNewItems){
				if (!$subMenu.IsOldMenu){
					$newMenu = "" | Select Title,Url
					$newMenu.Title = $subMenu.Title
					$newMenu.Url = $subMenu.Url.Replace($spObj.OldSiteSuffix,$spObj.RelURL)
					
					Create-MainMenuSingle $siteUrl $newMenu
				}
			}
			write-Host "Written File $outfile" -f Green
			
			foreach($subMenuMain in $menuNewItems){
				$mainMenuTitle = $subMenuMain.Title
				write-Host  $mainMenuTitle
				
				foreach($subMenuItem in $subMenuMain.Items){
					if (![string]::isNullOrEmpty($subMenuItem)){
						if($subMenuItem.Type -eq "DocLib" -and !$subMenuItem.IsOldMenu){
							
							create-DocLib $siteUrl $subMenuItem.InnerName $subMenuItem.Name
							foreach($fieldsSchema in $subMenuItem.ListSchema){
								$DisplayName = Select-Xml -Content $fieldsSchema  -XPath "/Field" | ForEach-Object {
									$_.Node.DisplayName
								}
								if($DisplayName -eq "Name" -or $DisplayName -eq "Title"){
									continue
								}
								add-SchemaFields $siteUrl $subMenuItem.Name $fieldsSchema
							}
							$newMenu = "" | Select Title,Url
							$newMenu.Title = $subMenuItem.Title
							$newMenu.Url = $subMenuItem.Url.Replace($spObj.OldSiteSuffix,$spObj.RelURL)
							Create-NavSubMenuX $siteUrl $newMenu $mainMenuTitle
							
							
							#write-Host "175" "Press key to continue..."
							#read-host
						}
					}
				}
			}
			$RecentsTitle = "לאחרונה"
			if ($spObj.language.ToLower().Contains("en")){
				$RecentsTitle = "Recent"
			}
			$NOmoreSubItems = $false
			while (!$NOmoreSubItems){
				$NOmoreSubItems =  Delete-RecentsSubMenu $siteURL $RecentsTitle 
							
			}
			Delete-RecentMainMenu $siteURL $RecentsTitle

			foreach($subMenuMain in $menuNewItems){
				
				$mainMenuTitle = $subMenuMain.Title
				if (!$subMenuMain.IsOldMenu){
					write-Host  "mainMenuTitle : $mainMenuTitle" -f Green
					write-Host  "Press any key..." -f Green
					
					read-host
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

				
			
			#write-Host "189" "Press key to continue..."
			#read-host			
			#$docLibNames
			# Delete-RecentsSubMenu
			<#
				$RecentsTitle = "לאחרונה"
				$NOmoreSubItems = $false
				while (!$NOmoreSubItems){
					$NOmoreSubItems =  Delete-RecentsSubMenu $siteURL $RecentsTitle 
							
				}	
			
			#>
			<#
			foreach($docLibName in $docLibNames){
			
				$schemaDocLibSrc1 =  get-ListSchema $oldSiteURL $docLibName
				#write-Host 48
				#read-host
				#$schemaDocLib1 | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLib1.json")
				$sourceDocObj = get-SchemaObject $schemaDocLibSrc1 
				$sourceDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLibSrc1.json")
				create-DocLib $siteUrl $docLibName
				
				# ======================= new DocLib
				$schemaDocLibDst1 =  get-ListSchema $siteUrl $docLibName
				$dstDocObj = get-SchemaObject $schemaDocLibDst1 
				$dstDocObj | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$groupName+"-DocLibDst1.json")
					
				foreach($srcEl in $sourceDocObj){
						$fieldExists = $false
						foreach($dstEl in $dstDocObj){
							if ($srcEl.Name -eq $dstEl.Name){
								write-Host "$($dstEl.Name) Exists in Destination List" -foregroundcolor Yellow
								$fieldExists = $true
								break
							}
							
						}
						if (!$fieldExists){
							write-Host "Add $($srcEl.DisplayName) to Destination List" -foregroundcolor Green
							$type= $srcEl.Type
							switch ($type)
							{
								"Text" {
									Write-Host "It is Text.";
									add-TextFields $siteUrl $docLibName $srcEl;
									Break
									}
								
								"Choice" {
									Write-Host "It is Choice.";
									add-ChoiceFields $siteUrl $docLibName $srcEl;
									Break
									}
									
								"Note" {
									Write-Host  "It is Note.";
									add-NoteFields $siteUrl $docLibName $srcEl;
									Break}
									
								"Boolean" {
									Write-Host  "It is Boolean.";
									add-BooleanFields $siteUrl $docLibName $srcEl;
									Break}
									
								"DateTime" {
									Write-Host  "It is DateTime.";
									add-DateTimeFields $siteUrl $docLibName $srcEl;
									Break}
									
								Default {
									Write-Host "No matches"
										}
							}					
						}
									
					}
					$SrcFieldsOrder = get-FormFieldsOrder $docLibName $oldSiteURL
					
					$DestFieldOrder    = get-FormFieldsOrder $docLibName $siteURL
					
					#check for Field in Destination exist in Source
					$newFieldOrder = checkForArrElExists $SrcFieldsOrder $DestFieldOrder
					reorder-FormFields $docLibName	$siteURL $newFieldOrder
					
					$objViews = Get-AllViews $docLibName $oldSiteURL
			 
					$objViews | ConvertTo-Json -Depth 100 | out-file $("JSON\"+$docLibName+"-Views.json")
					
					foreach($view in $objViews){
						$viewExists = Check-ViewExists $docLibName  $siteURL $view 
						if ($viewExists.Exists){
							write-host "view $($view.Title) exists on $newSite" -foregroundcolor Green
							#check if first field in source view is on destination view
							$firstField = $view.Fields[0]
							write-host "First field in source view : $firstField"
							$fieldInView = check-FieldInView  $docLibName $($viewExists.Title) $siteURL $firstField
							write-host "$firstField on View : $fieldInView"
							#if not {add this field}
							if (!$fieldInView){
								Add-FieldInView $docLibName $($viewExists.Title) $siteURL $firstField
								
							}
							#delete all fields in destination from view but first field in source
							 
							remove-AllFieldsFromViewButOne $docLibName $($viewExists.Title) $siteURL $firstField
							Add-FieldsToView $docLibName $($viewExists.Title) $siteURL $($view.Fields)
							#add other view
							Rename-View $docLibName $($viewExists.Title) $siteURL $($view.Title) $($view.ViewQuery)
						}
						else
						{
							
							$viewName = $($view.Title)
							if ([string]::isNullOrEmpty($viewName)){
								$viewName = $($view.ServerRelativeUrl.Split("/")[-1]).Replace(".aspx","")
								
							}
							write-host "view $viewName does Not exists on $newSite" -foregroundcolor Yellow
							write-host "ViewQuery : $($view.ViewQuery)"
							write-host "Check for View! "
							
							$viewDefault = $false
							Create-NewView $siteURL $docLibName $viewName  $($view.Fields) $($view.ViewQuery) $($view.Aggregations) $viewDefault
						}
					}
								
					


			}
			#>			
	
			
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