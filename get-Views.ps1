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

 # prepare exclude fields for form 
 # Evgenia
 # Krakover
 
 $siteSrcURL ="https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN31-2021";
 $siteSrcURL ="https://grs2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN32-2022";

 $sourceListName = "Applicants"
 $needViewNames = @()
 $needViewNames += "administration"
 $needViewNames += "rakefet"
 
 
  
 
 write-host "URL: $siteSrcURL" -foregroundcolor Yellow
 write-host "SourceList: $sourceListName" -foregroundcolor Cyan
 
 $siteUrl = get-UrlNoF5 $siteSrcURL

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
 $Web = $Ctx.Web
 $ctx.Load($Web)
 $Ctx.ExecuteQuery()
 
 $sList = $Web.lists.GetByTitle($sourceListName)
 $ctx.Load($sList)
 $Ctx.ExecuteQuery()
 
 $srcdocLibName = $sList.Title
 write-host "Opened List : $srcdocLibName"

 $schemaListSrc1 =  get-ListSchema $siteUrl $srcdocLibName
 
 $schemaListObj = get-SchemaObject $schemaListSrc1
 $outFileName = "JSON\"+$srcdocLibName+"-ListSource.json"
 $schemaListObj | ConvertTo-Json -Depth 100 | out-file $outFileName
 Write-Host "Created File : $outFileName" -f Yellow
 
 $objViews = Get-AllViews $srcdocLibName $siteUrl 
 $outFileName = "JSON\"+$srcdocLibName+"-Views.json" 
 $objViews | ConvertTo-Json -Depth 100 | out-file $($outFileName) 
 Write-Host "Created File : $outFileName" -f Yellow
 
 $krkFormOrd    = get-FormFieldsOrder $srcdocLibName $siteURL  
 $outfile = 	$("JSON\"+$srcdocLibName+"-KrakoverFormOrder.json") 
  $krkFormOrd | ConvertTo-Json -Depth 100 | out-file $outfile
  write-host "Created File : $outfile" -f Yellow
 
foreach($needViewName in $needViewNames){
	$excludedFields = ""

		$realFieldsList = @()
		 foreach($view in $objViews){
			if ($view.Title -eq $needViewName){
				write-host "Processing View : $needViewName"

				foreach ($vfield in $view.Fields){
					$isRealField = $false
					foreach( $fld in $krkFormOrd){
						if ($fld -eq $vfield){
							$isRealField = $true
							break
						}
					}
					if ($isRealField){
						$realFieldsList += $vfield
					}
				}
			}	
				
					
		}

	$excludeList = @()
	foreach($kfld in $krkFormOrd){
		$fieldToExcludeList=$true
		foreach($rField in $realFieldsList ){
			if ($kfld -eq $rfield){
				$fieldToExcludeList = $false
				break
			}
		}
		if ($fieldToExcludeList){
			$excludeList += $kfld
		}	
	}

	#$outFileName = $("Evgenia-Custom Forms\"+$needViewName+"-exclude.txt")
	$outFileName = $("Evgenia-Custom Forms\"+$needViewName+"-RealFields.txt")
	$realFieldsList | Out-File $outFileName -encoding UTF8
	write-host "Created File : $outFileName" -f Green


	$outFileName = $("Evgenia-Custom Forms\"+$needViewName+"-ExludedFields.txt")
	$excludeList | Out-File $outFileName -encoding UTF8
	write-host "Created File : $outFileName" -f Green

	$excludedFldsDisplayNames = @()



	foreach( $exfld in $excludeList){
		
		foreach($schemaField in $schemaListObj){
			if ($exfld -eq $schemaField.Name){
				$excludedFldsDisplayNames += $schemaField.DisplayName
				break
			}
		}
		
	}

	$excludedFields = ""
	foreach($fDispName in $excludedFldsDisplayNames){
		$excludedFields +=$fDispName+ ','
	}

	$outFileName = $("Evgenia-Custom Forms\"+$needViewName+"-exclude.txt")
	$excludedFields | Out-File $outFileName -encoding UTF8
	write-host "Created File : $outFileName" -f Green

}
 
 
	 
 
