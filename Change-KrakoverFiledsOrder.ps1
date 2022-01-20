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
function get-ListSchemaX2($siteURL,$listName){
	
	$fieldsSchema = @()
	#write-Host "$siteURL , $listName" -f Cyan
	$siteUrlC = get-UrlNoF5 $siteUrl
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrlC)
	#$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$Ctx.Credentials = $Credentials
	
	$List = $Ctx.Web.lists.GetByTitle($ListName)
	
    $Ctx.load($List.Fields) 
    $Ctx.ExecuteQuery()	


	foreach($field in $List.Fields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		#if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		#}
		#else{
		#	if ($field.SchemaXml.Contains('Group="_Hidden"')){
		#	}
		#	else{
		
		#		If (!($field.Hidden -or $field.ReadOnly )){
					$fieldsSchema += $field.SchemaXml
		#		}
		
		#	}
		#}	
	}	
	#write-Host 1214
	return $fieldsSchema

}


$Credentials = get-SCred

 
 $siteName = "https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN32-2022";
 
 
 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 $siteUrl = get-UrlNoF5 $siteName

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
 $RelURL = Get-RelURL $siteURL
 $grRelURL = $RelURL.split("/")[-2]
 write-host $RelURL -f Cyan
 write-host $grRelURL -f Magenta
 
  $doclibExternalName = "Applicants"
  $schemaDocLib4 =  get-ListSchemaX2 $siteUrl $doclibExternalName
  $dstDocObj4 = get-SchemaObject $schemaDocLib4
  $outfile = 	$("JSON\"+$doclibExternalName+"-"+$grRelURL+"-KrakSchema.json")
  $dstDocObj4 | ConvertTo-Json -Depth 100 | out-file $outfile
  write-host "$outfile written" -f Yellow
		  
  $objViews = Get-AllViews $doclibExternalName $siteURL
  $outfile = 	$("JSON\"+$doclibExternalName+"-"+ $grRelURL+ "-KrakViews.json") 
  $objViews | ConvertTo-Json -Depth 100 | out-file $outfile
  write-host "$outfile written" -f Yellow
  #$child = $QuickLaunch.Children 
  
  $applDestFieldOrder    = get-FormFieldsOrder $doclibExternalName $siteURL  
  $outfile = 	$("JSON\"+$doclibExternalName+"-"+ $grRelURL+ "-KrakOrder.json") 
  $applDestFieldOrder | ConvertTo-Json -Depth 100 | out-file $outfile
  write-host "$outfile written" -f Yellow
  
  
  $newOrder = @()
  foreach($view in $objViews){
	if ($view.Title -eq "administration"){
		write-Host $view.Title -f Green
		foreach($vfield in $view.Fields)
        {
			# fField = Form Field
			foreach($fField in $applDestFieldOrder)
			{
				if ($vfield -eq $fField){
					$fieldAlreadyExists = $false
					#oField = Order Field
					foreach($oField in $newOrder){
						if($oField -eq $fField){
							$fieldAlreadyExists = $true
							break
						}
					}
					if (!$fieldAlreadyExists){
						write-Host $vfield
						$newOrder += $fField
					}
				}	
				
			}
			
		}		
	}
  }	
  foreach($view in $objViews){
	if ($view.Title -eq "Rakefet"){
		write-Host $view.Title -f Cyan
		foreach($vfield in $view.Fields)
        {
			# fField = Form Field
			foreach($fField in $applDestFieldOrder)
			{
				if ($vfield -eq $fField){
					$fieldAlreadyExists = $false
					#oField = Order Field
					foreach($oField in $newOrder){
						if($oField -eq $fField){
							$fieldAlreadyExists = $true
							break
						}
					}
					if (!$fieldAlreadyExists){
						write-Host $vfield
						$newOrder += $fField
					}
				}	
				
			}
			
		}			
	}
	
  }
  write-Host "Other Fields in Form" -f Cyan
  foreach($fField in $applDestFieldOrder)
  {

	$fieldAlreadyExists = $false
	#oField = Order Field
	foreach($oField in $newOrder){
		if($oField -eq $fField){
			$fieldAlreadyExists = $true
			break
		}
	}
	if (!$fieldAlreadyExists){
		write-Host $fField
		$newOrder += $fField
	}
		
 }  
 

  reorder-FormFields $doclibExternalName	$siteURL $newOrder 
  
 