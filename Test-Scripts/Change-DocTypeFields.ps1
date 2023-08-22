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
function Add-FiledsToDstX2($siteUrlDst,$dstListName,$sourceListObj){
 $schemaDocLibDst1 =  get-ListSchema $siteUrlDst $doclibSrc
 $dstDocObj = get-SchemaObject $schemaDocLibDst1 
 $outFileName = "JSON\"+$dstListName+"-ListDest.json"
 $dstDocObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"
 Write-Host


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
						add-TextFieldsX2 $siteUrlDst $dstListName $fieldToCreateObj;
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
function add-TextFieldsX2($siteUrl, $listName, $fieldObj){
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
        $Ctx.Credentials = $Credentials
         
        #Get the List
        $List = $Ctx.Web.Lists.GetByTitle($listName)
        $Ctx.Load($List)
        $Ctx.ExecuteQuery()
 
        #Check if the column exists in list already
        $Fields = $List.Fields
        $Ctx.Load($Fields)
        $Ctx.executeQuery()
        $NewField = $Fields | where { ($_.Title -eq $($fieldObj.DisplayName))  }
        if(($NewField -ne $NULL) -and ($NewField.InternalName -eq $($fieldObj.Name))) 
        {
			Write-Host $NewField.InternalName 
			read-host
            Write-host "Column $($fieldObj.DisplayName) already exists in the List!" -f Yellow
        }
        else
        {
			$DisplayName = $fieldObj.DisplayName
			$IsRequired = $fieldObj.Required
			
			#Define XML for Field Schema
            $FieldSchema = "<Field Type='Text' DisplayName='$DisplayName' Required='$IsRequired'  />"
			write-host $FieldSchema
            $NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint)
            $Ctx.ExecuteQuery()   
 
            Write-host "New Column $DisplayName Added to the $listName Successfully!" -ForegroundColor Green 


		
		}
}

$cred = get-SCred

 $siteSrcURL = get-UrlNoF5 "https://scholarships2.ekmd.huji.ac.il/home/Education/EDU129-2021";
 $doclibSrc =  "DocType"

 

 $schemaListSrc1 =  get-ListSchema $siteSrcURL $doclibSrc
 $sourceListObj = get-SchemaObject $schemaListSrc1
 $outFileName = "JSON\"+$docLibSrc+"-ListSource.json"
 $sourceListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName"
 


 $siteUrlDst =  get-UrlNoF5 "https://scholarships2.ekmd.huji.ac.il/home/SocialSciences/SOC211-2021"
 Add-FiledsToDstX2 $siteUrlDst $doclibSrc $sourceListObj 
 
 $siteName = "https://hss2.ekmd.huji.ac.il/home/";
 $ListName="availableScholarshipsList"

	 

 
 write-host "URL: $siteName" -foregroundcolor Yellow
 
 
 $siteUrl = get-UrlNoF5 $siteName

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 $List = $Ctx.Web.lists.GetByTitle($listName)
 $dt = Get-Date
 $dt.AddDays(-2)
 $dtS = $dt.Year.ToString()+"-"+$dt.Month.ToString().PadLeft(2,"0")+"-"+$dt.Day.ToString().PadLeft(2,"0") + "T03:00:00Z"

	#Define the CAML Query
  $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
  $qry = "<View><Query>
   <Where>
      <Geq>
         <FieldRef Name='deadline' />
         <Value IncludeTimeValue='TRUE' Type='DateTime'>$dtS</Value>
      </Geq>
   </Where>
</Query>
</View>"
  $qry = "<View><Query></Query></View>"
    $Query.ViewXml = $qry
  
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	#$i= $ListItems.Count
	$i=0;
	forEach($reqstItem in $ListItems){
		$urlSite = get-UrlNoF5 $reqstItem["url"]
		
		$deadline = $reqstItem["deadline"]
		if ($deadline -ge $((get-Date).AddDays(-1))){
			$i++
			write-host "$urlSite ; $deadline" -f Yellow
			#Add-FiledsToDstX2 $urlSite $doclibSrc $sourceListObj
		}
		
	}
	Write-Host "Open Sites Found: $i" -f Yellow
	
	Write-Host "Press Any key"
	read-host
