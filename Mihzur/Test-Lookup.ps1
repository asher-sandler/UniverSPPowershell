	$srcSite = "https://gss2.ekmd.huji.ac.il/home/general/GEN16-2018"
	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists["StudentList"]
	$SourceColumns = $srcList.Fields
	$SourceItems = $srcList.GetItems();
	Foreach($SourceItem in $SourceItems)
	{
	
		Foreach($column in $SourceColumns){
			if($column.Hidden -eq $False -and $column.ReadOnlyField -eq $False -and $column.InternalName -ne "Attachments"){
				if($column.Type -eq "Lookup"){
					#$column | Select Title, Type
					If(![string]::IsNullOrEmpty($SourceItem[$column.InternalName])){
						#$column | gm
						$realType = $column.TypeAsString
						Write-Host $realType
						Write-Host $column.InternalName
						$columnValue = ""
						if ($realType -eq "LookupMulti"){
							$lokpVal = @()
							forEach ($sItem in $SourceItem[$column.InternalName]){
								if (![string]::IsNullOrEmpty($sItem.LookupValue)){
									$lokpVal += $sItem.LookupValue.ToString()
								}
							} 
							$vlCount  = 1
							forEach($lVal in $lokpVal){
								
								$columnValue += $lVal
								if ( $vlCount -lt $lokpVal.Count ){
									$columnValue += ";"
								}
								$vlCount++
								
							}
						}
						else
						{
							$srcLookUp = new-object Microsoft.SharePoint.SPFieldLookupValue($sourceItem[$($column.InternalName)] )
							if (![string]::IsNullOrEmpty($srcLookUp)){
								
								$columnValue = $srcLookUp.LookupValue
							}
						}
						write-host 42 $columnValue
					}
					
				}
			}
		}
	}
