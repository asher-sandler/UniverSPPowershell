##############################################
#
#   Check for double tag <Data> in XML Form
#
#   Author: Asher Sandler, Hebrew University of Jerusalem
#
#   Date: 2021-05-05
#   Release: 0.0.2
#   
#   Example usage:  .\checkForDoubleDataName.ps1 \\ekeksql00\sp_resources$\HSS\default\AGR123-2020-He.xml
#
##############################################


#$wrkFileName = "\\ekeksql00\sp_resources$\HSS\default\AGR123-2020-He.xml"; 

param([string] $wrkFileName = "")

if ([String]::isNullOrEmpty($wrkFileName)){
	write-host "File Name must be as first param of script!"
}

else

{
	if (Test-Path $wrkFileName){
		
		$isXML = [bool]((Get-Content $wrkFileName) -as [xml])
		# file is XML type
		
		if ($isXML){
		
			write-host
			write-host "Checking for double tag <Data></Data> in  $wrkFileName..." -ForeGroundColor Yellow 
			# check for tag <Data></Data>
			
			$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/rows/row/control" | ForEach-Object {$_.Node.Data}

			$arrDataTag = @()
			$isError = $false
			
			# adding tags to array 
			foreach ($line in $xmlNodeData)
			{
					
					if (![String]::IsNullOrEmpty($line)){
						$itemToAdd = $line.toString().toUpper().Trim()
						$itArr = "" | Select Item
						$itArr.Item = $itemToAdd
						
						$arrDataTag +=  $itArr
					}
					
				
				
			}



			# $arrDataTag
			# check array for doubles
			for($i=0; $i -lt $arrDataTag.Length; $i++){

				$itemSource =  $arrDataTag[$i].Item
				
				for ($j = $i+1; $j -lt $arrDataTag.Length; $j++){
					  $itemToCompare = $arrDataTag[$j].Item
					  
					  if ($itemSource -eq $itemToCompare){
						  write-host
						  write-host "Tag $itemSource exist too many times!" -ForeGroundColor Yellow
						  $isError = $true
						  break;
					  }
				}
			}

			if (!$isError){
				write-host "   Everething looks fine!" -ForeGroundColor Green -NoNewLine;
			}
		}
		else
		{
			write-host "File type is not XML file!"
		}
	}
	else
	{
		write-host "File $wrkFileName does not exists!"
	}
}