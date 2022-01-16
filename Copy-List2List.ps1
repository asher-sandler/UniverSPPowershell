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
 $sourceList = "/home/OverseasApplicantsUnit/GEN32-2022/Lists/applicants/AllItems.aspx"
 $siteDstName = "https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace/"
 $dstListName = "applTest"
 
  
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

 

 
  $srcObjViews = Get-AllViews $docLibName $siteName 
  $outFileName = "JSON\"+$docLibName+"-CopyExtViews.json"	 
  $srcObjViews | ConvertTo-Json -Depth 100 | out-file $outFileName 
  Write-Host "Created File : $outFileName"
  Write-Host
  
read-host 141 
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
		 
  
			

 
 
 
 

 



