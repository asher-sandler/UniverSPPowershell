param([string] $FileName = "")
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "..\Utils-Request.ps1"
. "..\Utils-DualLanguage.ps1"

if ([string]::isNullOrEmpty($FileName))
{
	write-host "File Name Must be specified" -f Yellow
	write-host in "format לימודי הוראה-FieldList.txt" -f Yellow
	
}
else
{
	if (Test-Path $FileName){
		$outXSLT = @()
		$fileFields =  get-Content $FileName -Encoding UTF8 
		
		$jsonFileName = "..\JSON\"+$FileName.split("-")[0]+"-ListSource.json"
		Write-Host "Reading File $jsonFileName" -f Green
		if (Test-Path $jsonFileName){
			$jsonFieldObj  = get-content $jsonFileName -encoding default | ConvertFrom-Json
			
			$fieldID = 1
			foreach($rowf in $fileFields){
				$wrowf = $rowf
				$addEdit = $false
				$addRead = $false
				if ($wrowf.contains(";")){
					continue
				}
				if (!($wrowf.contains("+") -or $wrowf.contains("*"))){
					continue
				}
				if ($wrowf.contains("+")){
					$wrowf = $wrowf.replace("+","")
					$addEdit = $true
					
				}
				if ($wrowf.contains("*")){
					$wrowf = $wrowf.replace("*","")
					$addRead = $true
				}
				
				foreach($jfield in $jsonFieldObj){
					if ($wrowf -eq $jfield.DisplayName){
						#write-host $wrowf -f Green
						if ($addRead){
							$outXSLT += "					<tr>"	
							$outXSLT += '						<td width="190px" valign="top" class="ms-formlabel">'	
							$outXSLT += '							<H3 class="ms-standardheader">'
							$outXSLT += "								<nobr>"	+ $jfield.DisplayName + "</nobr>"
							$outXSLT += "							</H3>"
							$outXSLT += "						</td>"
							$outXSLT += '						<td width="400px" valign="top" class="ms-formbody">'
							$outXSLT += '							<xsl:value-of select="@' + $jfield.Name + '"/>'
							$outXSLT += '						</td>'
							$outXSLT += '					</tr>'
						}
						if ($addEdit){
							#write-host $jfield.Schema
							#read-host
							$requriedField = $jfield.Schema.Contains('Required="TRUE"')
							$spanValidation = ''
							if ($requriedField){
								$spanValidation = '<span class="ms-formvalidation"> *</span>'
							}
							$outXSLT += "					<tr>"
							$outXSLT += '						<td width="190px" valign="top" class="ms-formlabel">'
							$outXSLT += '							<H3 class="ms-standardheader">'
							$outXSLT += '								<nobr>'+ $jfield.DisplayName + $spanValidation
							$outXSLT += '								</nobr>'
							$outXSLT += '							</H3>'
							$outXSLT += '						</td>'
							$outXSLT += '						<td width="400px" valign="top" class="ms-formbody">'
							$outXSLT += '							<SharePoint:FormField runat="server" id="ff' +$fieldID.ToString().Trim() +'{$Pos}" ControlMode="Edit" FieldName="'+$jfield.Name +'" __designer:bind="{ddwrt:DataBind('+"'u',concat('ff"+$fieldID.ToString().Trim() +"',"+'$Pos'+"),'Value','ValueChanged','ID',ddwrt:EscapeDelims(string(@ID)),'@" +$jfield.Name+"')}"+'"'+"/>"
							
							$outXSLT += '							<SharePoint:FieldDescription runat="server" id="ff'+$fieldID.ToString().Trim() +'description{$Pos}" FieldName="'+$jfield.Name +'" ControlMode="Edit"/>'							
							$outXSLT += '						</td>'							
							
							$outXSLT += "					</tr>"	
							$fieldID++
						}
						
					}
				}
				
				
			}
			$outFileName = $FileName.split("-")[0] + "-SPD.xslt"
			$outXSLT | out-file $outFileName -encoding UTF8
			write-host "Written file $outFileName" -f Green
		}
		else
		{
			Write-Host "FileName $jsonFileName is Not Exists" -f Yellow
			Write-Host "Run Procedure .\12.prepare-listFields.ps1 again" -f Yellow
			
		}
		


	}
	else{
		Write-Host "FileName $FileName is Not Exists" -f Yellow
	}

 
}
 
 
 

 