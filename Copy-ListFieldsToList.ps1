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

 
 $siteSrcURL = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN27-2020";
 $sourceList = "/home/OverseasApplicantsUnit/GEN27-2020/Lists/administration/AllItems.aspx"
 
  
 $siteName = get-UrlNoF5 $siteSrcURL
 write-host "URL: $siteSrcURL" -foregroundcolor Yellow

 write-host "Get-ListFields DocLib: $siteURL" -foregroundcolor Green
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
 
 $fieldsTxtArr = get-Content $("Daniel\"+$docLibName+"-ListSource.txt")
 
 $fieldsArrPure = @()
 
 forEach ($line in $fieldsTxtArr){
	 if ($line.Contains("*")){
		 $fieldsArrPure += $line
	 }
 }


 $outFileName = "JSON\"+$docLibName+"-ListSourcePure.txt"
 $fieldsArrPure | out-file $outFileName
 Write-Host "Created File : $outFileName"
 
 $pureFieldList = get-Content $("Daniel\"+$docLibName+"-ListSourcePure.txt")

 $siteDstName = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN31-2021"
 $siteUrlDst =  get-UrlNoF5 $siteDstName
 $dstListName = "applicants"
 $schemaDocLibDst1 =  get-ListSchema $siteUrlDst $dstListName
 $dstDocObj = get-SchemaObject $schemaDocLibDst1 
 $outFileName = "JSON\"+$dstListName+"-ListDest.json"
 $dstDocObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"
 Write-Host

 
 $i=0
 forEach ($pEl in $pureFieldList){
	 if (![string]::IsNullOrEmpty($pEl)){
		$cEl = $pEl.Replace("*","")
		$fieldExistsInList = $false
		$fieldToCreateObj = "" | Select-Object Name, Type, DisplayName, Schema, Choice, Required, Format
		foreach($fElx in $sourceListObj){
			if ($fElx.DisplayName -eq $cEl){
				$fieldToCreateObj.Name = $fElx.Name
				$fieldToCreateObj.Type = $fElx.Type
				$fieldToCreateObj.DisplayName = $fElx.DisplayName
				$fieldToCreateObj.Schema = $fElx.Schema
				$fieldToCreateObj.Choice = $fElx.Choice
				$fieldToCreateObj.Required = $fElx.Required
				$fieldToCreateObj.Format = $fElx.Format
				
				$fieldExistsInList = $true
				$i++
				break
			}
					
		}
		if ($fieldExistsInList){
			
			$fieldWillNotBeCreate = $false
			forEach($dstEl in $dstDocObj ){
				if ($dstEl.Name -eq $fieldToCreateObj.Name){
					$fieldWillNotBeCreate = $true
					break
				}
			}
			if (!$fieldWillNotBeCreate){
				#write-Host "$i : $cEl : Ready to Create" -foregroundcolor Cyan
				# write-Host "Add $i : $($fieldToCreateObj.Name) Type: $($fieldToCreateObj.Type) to Destination List" -foregroundcolor Green
				$type= $fieldToCreateObj.Type
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
				
			}
			
		}		
		
	 }
 }
 
 
  $srcObjViews = Get-AllViews $docLibName $siteName 
  $outFileName = "JSON\"+$docLibName+"-CopyExtViews.json"	 
  $srcObjViews | ConvertTo-Json -Depth 100 | out-file $outFileName 
  Write-Host "Created File : $outFileName"
  Write-Host
  
  $inputObjFileName = "Daniel\"+$docLibName+"-CopyExtViews.json"
  write-Host "Reading Data from $inputObjFileName"
  
  $spViewObj = get-content $inputObjFileName -encoding default | ConvertFrom-Json
  
  $viewNewObj = "" | Select-Object DefaultView,Aggregations,Title, ServerRelativeUrl,ViewQuery,Fields
  
  
  
  forEach($vw in $spViewObj){
	  if ($vw.ServerRelativeUrl.Contains("AllItems.aspx") ){
		  $viewNewObj.DefaultView = $false
		  $viewNewObj.Aggregations = $vw.Aggregations
		  $viewNewObj.Title = $docLibName
		  $viewNewObj.ViewQuery = $vw.ViewQuery
		  $viewNewObj.ServerRelativeUrl = $siteUrlDst + "/Lists/"+$dstListName
		  $viewNewObj.Fields = $vw.Fields
		  
		  
	  }
	  
  }
  
  $CreatingView = $true
  forEach($fldxS in $viewNewObj.Fields)
  {
	$fieldFound=$false
    forEach($fldxD in $dstDocObj){
		if ($fldxS -eq $fldxD.DisplayName){
			$fieldFound=$true
			
			break
		}
	}
    if (!$fieldFound){
		write-Host "$fldxS Not Found in Destination" -f Yellow
		$CreatingView = $false
	}	
  }

  
  $outFileName = "JSON\"+$docLibName+"-CopyExtViewsNew.json"	 
  $viewNewObj | ConvertTo-Json -Depth 100 | out-file $outFileName 
  Write-Host "Created File : $outFileName"
  Write-Host
  
 $viewExists = Check-ViewExists $dstListName  $siteUrlDst $viewNewObj
 
 #if ($CreatingView ){
	 if ($viewExists.Exists){
		write-host "view $($viewNewObj.Title)  exists on $siteUrlDst" -foregroundcolor Cyan
	 }
	 else
	 {
		$viewName = $($viewNewObj.Title)
		$viewDefault = $false
		write-host "view $viewName  does Not exists on $siteUrlDst" -foregroundcolor Green
		Create-NewView $siteUrlDst $dstListName $viewName  $($viewNewObj.Fields) $($viewNewObj.ViewQuery) $($viewNewObj.Aggregations) $viewDefault

	 }
 #}
		 
  
			

 
 
 
 

 



