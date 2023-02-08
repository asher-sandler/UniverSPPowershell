##############################################
#
#   Compare for Fields Differents in Two in XML Form
#
#   Author: Asher Sandler, Hebrew University of Jerusalem
#
#   Date: 2023-01-05
#   Release: 0.0.2
#   
#
##############################################


$wrkFileName2 = "\\ekeksql00\SP_Resources$\GRS\default\EDU61-2021.xml"; 
$wrkFileName1 = "\\ekeksql00\SP_Resources$\GRS\default\EDU69-2022.xml"; 

	if ($(Test-Path $wrkFileName1) -and $(Test-Path $wrkFileName2)){
		
		$isXML1 = [bool]((Get-Content $wrkFileName1) -as [xml])
		$isXML2 = [bool]((Get-Content $wrkFileName2) -as [xml])
		# file is XML type
		
		if ($isXML1 -and $isXML1){
		
			write-host
			write-host "Checking for double tag <Data></Data> ..." -ForeGroundColor Yellow 
			# check for tag <Data></Data>
			
			$xmlNodeData1 = Select-Xml -Path $wrkFileName1 -XPath "/rows/row/control" | ForEach-Object {$_.Node.Data}
			$xmlNodeData2 = Select-Xml -Path $wrkFileName2 -XPath "/rows/row/control" | ForEach-Object {$_.Node.Data}

			
			# adding tags to array 
			foreach ($line1 in $xmlNodeData1)
			{
				$itemFound = $false
				if (![String]::IsNullOrEmpty($line1)){
					$item1 = $line1.toString().toUpper().Trim()
					foreach ($line2 in $xmlNodeData2)
					{
						if (![String]::IsNullOrEmpty($line2)){
							$item2 = $line2.toString().toUpper().Trim()
							if ($item1 -eq $item2){
								$itemFound = $true
								#Write-Host $item1 " found" -f Green
								break
							}
						}
					}
					if (!$itemFound){
						write-Host $item1 " Not found in " $wrkFileName2 -f Yellow
					}
				}
			}
					
				
				
		}
		else
		{
			write-host "File type is not XML file!"
		}
	}
	else
	{
		write-host "File $wrkFileName1 does not exists!"
	}
