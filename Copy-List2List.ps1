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

 
 $siteSrcURL = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN32-2022";
 $siteSrcURL = "https://ttp2.ekmd.huji.ac.il/home/Humanities/HUM27-2021";
 $sourceList = "/home/OverseasApplicantsUnit/GEN32-2022/Lists/applicants/AllItems.aspx"
 $sourceList = "/home/Humanities/HUM27-2021/Islam%20in%20South%20Asia/Forms/AllItems.aspx"
 $siteDstName = "https://ttp2.ekmd.huji.ac.il/home/Humanities/HUM27-2021"
 $dstListName = "Comparative Literature"
 $dstListName = "Hebrew Literature"
 $dstListName = "Islamic and Middle Eastern"
 $dstListName = "Linguistics"
 $dstListName = "Musicology"
 $dstListName = "Spanish and Latin American Studies"
 
  
 $siteName = get-UrlNoF5 $siteSrcURL
 write-host "URL: $siteSrcURL" -foregroundcolor Yellow

 write-host "Get-ListFields DocLib: $siteSrcURL" -foregroundcolor Green
 $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteName) 
 $ctx.Credentials = $Credentials
 	
 $Web = $Ctx.Web
 $ctx.Load($Web)
 $Ctx.ExecuteQuery()
 
 $sList = $Web.GetList($sourceList);
 $ctx.Load($sList)
 $Ctx.ExecuteQuery()
 
 $docLibName = $sList.Title
 write-host "Opened List : $docLibName"
 
 
 $schemaListSrc1 =  get-ListSchema $siteSrcURL $docLibName
 
 $sourceListObj = get-SchemaObject $schemaListSrc1
 $outFileName = "JSON\"+$docLibName+"-ListSource.json"
 $sourceListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"
 
 $AllFields = @()
 forEach($fEl in $sourceListObj){
	 $AllFields += $fel.DisplayName
 }
 
 $outFileName = "JSON\"+$docLibName+"-ListSource.txt"
 $AllFields | out-file $outFileName
 Write-Host "Created File : $outFileName"
 
 
 $siteUrlDst =  get-UrlNoF5 $siteDstName
 $schemaDocLibDst1 =  get-ListSchema $siteUrlDst $dstListName
 $dstDocObj = get-SchemaObject $schemaDocLibDst1 
 $outFileName = "JSON\"+$dstListName+"-ListDest.json"
 $dstDocObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"
 Write-Host

 
 $i=0

 forEach($srcFld in $sourceListObj){
	$fieldExistsInList = $false
	foreach($dstFld in $dstDocObj){
		if ($srcFld.Name -eq $dstFld.Name){
			#write-Host $srcFld.Name
			$fieldExistsInList = $true
			break			
		}
	}
	if (!$fieldExistsInList){
		write-Host $($srcFld.Name + " ") -noNewLine
		$fieldToCreateObj = "" | Select-Object Name, Type, DisplayName, Schema, Choice, Required, Format
		$fieldToCreateObj.Name = $srcFld.Name
		$fieldToCreateObj.Type = $srcFld.Type
		$fieldToCreateObj.DisplayName = $srcFld.DisplayName
		$fieldToCreateObj.Schema = $srcFld.Schema
		$fieldToCreateObj.Choice = $srcFld.Choice
		$fieldToCreateObj.Required = $srcFld.Required
		$fieldToCreateObj.Format = $srcFld.Format
		$type= $fieldToCreateObj.Type
		write-Host $type
				switch ($type)
				{
						"Text" {
							Write-Host "It is Text.";
							add-TextFields $siteUrlDst $dstListName $fieldToCreateObj;
							Break
							}
						
						"Choice" {
							Write-Host "It is Choice.";
							add-ChoiceFields $siteUrlDst $dstListName $fieldToCreateObj;
							Break
							}
							
						"Note" {
							Write-Host  "It is Note.";
							add-NoteFields $siteUrlDst $dstListName $fieldToCreateObj;
							Break}
							
						"Boolean" {
							Write-Host  "It is Boolean.";
							add-BooleanFields $siteUrlDst $dstListName $fieldToCreateObj;
							Break}
							
						"DateTime" {
							Write-Host  "It is DateTime.";
							add-DateTimeFields $siteUrlDst $dstListName $fieldToCreateObj;
							Break}
							
						Default {
							Write-Host "No matches"
								}
				}
				#read-host 127
				
	}
 }

 

 
  $objViews = Get-AllViews $docLibName $siteName 
  $outFileName = "JSON\"+$docLibName+"-CopyExtViews.json"
  $objViews | ConvertTo-Json -Depth 100 | out-file $outFileName
  
  Write-Host "Created File : $outFileName"
  Write-Host


  foreach($view in $objViews){
	    $view
		#write-Host 147
		#read-host
		$viewExists = Check-ViewExists $dstListName  $siteDstName $view 
		if ($viewExists.Exists){
			write-host "view $($view.Title) exists on $newSite" -foregroundcolor Green
			#check if first field in source view is on destination view
			$firstField = $view.Fields[0]
			write-host "First field in source view : $firstField"
			#write-Host 155
			#read-host
			$fieldInView = check-FieldInView  $dstListName $($viewExists.Title) $siteDstName $firstField
			write-host "$firstField on View : $fieldInView"
			#if not {add this field}
			if (!$fieldInView){
				Add-FieldInView $dstListName $($viewExists.Title) $siteDstName $firstField
				
			}
			#delete all fields in destination from view but first field in source
			 
			remove-AllFieldsFromViewButOne $dstListName $($viewExists.Title) $siteDstName $firstField
			Add-FieldsToView $dstListName $($viewExists.Title) $siteDstName $($view.Fields)
			#add other view
			Rename-View $docLibName $($viewExists.Title) $siteDstName $($view.Title) $($view.ViewQuery)
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
			Create-NewView $siteDstName $dstListName $viewName  $($view.Fields) $($view.ViewQuery) $($view.Aggregations) $viewDefault
		}
	}
				 
