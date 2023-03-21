param([string] $xmlFileName = "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\CRS\crsMursheToSap.xml")

function Update-Contractor($siteUrl, $listName,$ListOfIDs, $sendSapField, $doneField){
	#Write-Host 2 $siteUrl $listName  $sendSapField  $doneField
	$spWeb = Get-SPWeb $siteUrl
	if ($spWeb){
		$sapakimList = $spWeb.Lists[$listName]
		if ($sapakimList){
			forEach($lid in $ListOfIDs){
				if ($lid.Status -eq "Ok"){
					$sapakListItem = $sapakimList.GetItembyID($lid.ID)
					$sapakListItem[$sendSapField] = $false
					$sapakListItem[$doneField] = $true
					$sapakListItem.Update()
				}
			}
			
		}
		
	}		
	return $null
}
function Copy-Pdfs($currentSite, $currentList, $targetPDF,$finalListName,$idList,$fieldName){
	#Write-Host $currentSite
	#Write-Host $currentList
	#Write-Host $targetPDF
	#Write-Host $finalListName
	$spWeb = Get-SPWeb $currentSite
	if ($spWeb){
		$listFinal = $spWeb.Lists | Where{$_.RootFolder.Name -eq $finalListName}
		if ($listFinal){
			Write-Host "Opened List: "$listFinal.Title
			$sapakimList = $spWeb.Lists[$currentList]
			if ($sapakimList){
				forEach($lid in $idList){
					$sapakListItem = $sapakimList.GetItembyID($lid.ID)
					$pdfIdVal  = $sapakListItem[$fieldName]
					
					$query = New-Object Microsoft.SharePoint.SPQuery
					$query.Query = "<Where><Contains><FieldRef Name='FileLeafRef' /><Value Type='File'>$pdfIdVal</Value></Contains></Where>"
					$query.RowLimit = 1
					$files = $listFinal.GetItems($query)
					$pdfFile = $files[0].File
					# write-host $pdfIdVal $pdfFile
					
					if ($pdfFile.Exists -and $pdfFile.Name.ToUpper().Contains(".PDF")){
						# $pdfFile | gm
						# write-host $pdfFile.Name " File Found"
						$lid.Status = "Ok"
						
						if (Test-Path $targetPDF){
							$targDir =  Get-Item  $targetPDF
							$outPath =  Join-Path $targDir  $($pdfIdVal+".pdf")
							try{
								Write-Host "Saving file: "  $outPath
								[System.IO.File]::WriteAllBytes($outPath, $pdfFile.OpenBinary())	
							}
							catch{
								$lid.Status = "Error"
								$lid.Message = $_.Exception.Message
								write-host $lid.Message -f Yellow
							}
						}
						else
						{
							$lid.Status = "Error"
							$lid.Message = "Output Dir "+$targetPDF+".pdf not found"
							
						}
					}	
					
					else
					{
						$ErrMessage = "File " + $($pdfIdVal)+".pdf (Value of field: "+$fieldName+" ) doesn't Found in List: " + $finalListName 
						# write-host $ErrMessage -f Yellow
						$lid.Status = "Error"
						$lid.Message = $ErrMessage
					}
					# <Where><BeginsWith><FieldRef Name='FileLeafRef' /><Value Type='Text'>$fileNamePrefix</Value></BeginsWith></Where>
					# 028824860.pdf
					# 310 707 625 
					# 570043 984
					# <Where><Contains><FieldRef Name='FileLeafRef' /><Value Type='File'>28824860</Value></Contains></Where>
					<#
					$query = New-Object Microsoft.SharePoint.SPQuery
					$query.Query = "<Where><BeginsWith><FieldRef Name='FileLeafRef' /><Value Type='Text'>$fileNamePrefix</Value></BeginsWith></Where>"
					# $query.RowLimit = 1
					$files = $list.GetItems($query)
					$file = $files[0].File
						
					# Set the local path where you want to save the PDF file
					$localPath = $targetPDF + $pdfIdVal + ".pdf" # Replace with your desired local path

					# Save the PDF file to the local path
					[System.IO.File]::WriteAllBytes($localPath, $file.OpenBinary())				
					#>
				}
			}
			
		}
		
	}
}	
function get-FrendlyDate($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + " " + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")+":"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-FrendlyDateLog($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + "-" + $dtNow.Hour.ToString().PadLeft(2,"0")+"-"+$dtNow.Minute.ToString().PadLeft(2,"0")+"-"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-ScrptFullPath($scriptX ){
	$fileScr = get-Item $scriptX
	return $fileScr.DirectoryName
}
function Get-XmlObj($xmlFileName){
	$obj = "" | Select Service,SPSource,Params
	$oParams = @()
	$servc  = "" | Select TargetUrl,TargetPdf,FileName,Delimiter,Encoding,ReportErrorTo,ReportErrorSubject
	$SPSource  = "" | Select ListUrl,ListName,MainList,RunColumn,UniqueIdentifierColumn,DoneColumn,SapDone,PdfFinalListName,SrchInFinalColumn
	# $xmlFile = Get-Content $xmlFileName -raw
	$xmlFile = [IO.File]::ReadAllText($xmlFileName)
	$isXML = [bool](($xmlFile) -as [xml])
	if ($isXML){
			#$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/Config/application/control" | ForEach-Object 
			              #{$_.Node.Data}
						  
		$xmlDoc = [xml]$xmlFile
		$xmlServices = $xmlDoc.SelectNodes("//Service")
		#write-host 14	
		foreach($service in $xmlServices){
			$servc.TargetUrl =  $service.TargetUrl
			$servc.TargetPdf =  $service.TargetPdf
			$servc.FileName  =   $service.FileName
			$servc.Delimiter =  $service.Delimiter.InnerText
			$servc.Encoding  =   $service.Encoding
			
			$servc.ReportErrorTo 		=   $service.ReportErrorTo
			$servc.ReportErrorSubject 	=   $service.ReportErrorSubject
			break
		}
		$xmlOSPSource = $xmlDoc.SelectNodes("//SPSource")
		foreach($spSrc in $xmlOSPSource){
			$SPSource.ListUrl = $spSrc.ListUrl
			$SPSource.ListName = $spSrc.ListName
			$SPSource.MainList = $spSrc.MainList
			$SPSource.RunColumn = $spSrc.RunColumn
			$SPSource.UniqueIdentifierColumn = $spSrc.UniqueIdentifierColumn
			$SPSource.DoneColumn = $spSrc.DoneColumn
			$SPSource.SapDone = $spSrc.DoneColumn
			$SPSource.PdfFinalListName = $spSrc.PdfFinalListName
			$SPSource.SrchInFinalColumn = $spSrc.SearchInFinalColumn
			
			break
		}
		
		$xmlOParams   = $xmlDoc.SelectNodes("//Param")

		#write-host 22 $xmlOParams.Count
		#$xmlOParams | gm
		
		foreach($oXMLParam in $xmlOParams){
			$oParm = "" | Select SPColumnName,ParamType,CharLength,TargetOrder,Trim,Fill
			$oParm.SPColumnName = $oXMLParam.SPColumnName
			$oParm.ParamType    = $oXMLParam.ParamType
			$oParm.CharLength   = $oXMLParam.CharLength
			$oParm.TargetOrder  = $([string]$oXMLParam.TargetOrder).Padleft(4,"0")
			$oParm.Trim         = $oXMLParam.Trim
			$oParm.Fill         = $oXMLParam.Fill
			
			$oParams+=$oParm
		}	

		$obj.Service = $servc
		$obj.SPSource = $SPSource
		$oPar =  $oParams | Sort-Object TargetOrder
		$obj.Params = $oPar
		
	}	
	return $obj
}
function get-RakefetListItems($xObj){
	
	$listofIDs =  @()
	$outObj = "" | Select  ListOfIDs
	$currentSite = $xObj.SPSource.ListUrl
	$delimtr = $xObj.Service.Delimiter
	$params = $xObj.Params
	$paramsCount = $params.Count
	Write-Host "Params Count: " $paramsCount -f Cyan
	$spWeb = Get-SPWeb $currentSite

	if ($spWeb){
		Write-Host "Opened $currentSite" -f Cyan
		$currentList = $xObj.SPSource.ListName
		$list = $spWeb.Lists[$currentList]
		$Fields = $list.Fields
		$params = @()
		foreach ($xItem in $xObj.Params){
			$pItem = "" | Select SPColumnName, Type, CalculatedField
			$pItem.SPColumnName = $xItem.SPColumnName
			$fldObj = $Fields | Where{$_.Title -eq $pItem.SPColumnName}
			$pItem.Type = $fldObj.Type
			if ($pItem.Type -eq "Calculated"){
				$pItem.CalculatedField = $List.Fields[$pItem.SPColumnName] -as [Microsoft.SharePoint.SPFieldCalculated]  
			}
			$params += $pItem
		}
		
		if ($list){
			Write-Host "Opened List: $currentList" -f Cyan
			$runColumn = $xObj.SPSource.RunColumn
			$doneColumn = $xObj.SPSource.SapDone
			#Write-Host "Check for : $runColumn" -f Cyan
			$query=New-Object Microsoft.SharePoint.SPQuery
			$sQry = 	  "<Where>"+
								"<And>"+
									"<Eq>"+
											"<FieldRef Name='$runColumn' />"+
											"<Value Type='Boolean'>1</Value>"+
									"</Eq>"+
									"<Eq>"+
											"<FieldRef Name='$doneColumn' />"+
											"<Value Type='Boolean'>0</Value>"+
									"</Eq>"+
								"</And>"+
							"</Where>"
			if ($isDebug){
				$sQry = "<Where><Or><Eq><FieldRef Name='ID' /><Value Type='Counter'>11</Value></Eq><Eq><FieldRef Name='ID' /><Value Type='Counter'>2103</Value></Eq></Or></Where>"
				$sQry = "<Where><Or><Eq><FieldRef Name='ID' /><Value Type='Counter'>11</Value></Eq><Or><Eq><FieldRef Name='ID' /><Value Type='Counter'>500</Value></Eq><Eq><FieldRef Name='ID' /><Value Type='Counter'>400</Value></Eq></Or></Or></Where>"
				#$sQry = "<Where><Or><Eq><FieldRef Name='ID' /><Value Type='Counter'>7011</Value></Eq><Or><Eq><FieldRef Name='ID' /><Value Type='Counter'>7500</Value></Eq><Eq><FieldRef Name='ID' /><Value Type='Counter'>7400</Value></Eq></Or></Or></Where>"
			}
			$query.Query = $sQry
			$SPListItemCollection = $list.GetItems($query)
			
			if ($SPListItemCollection){
				$itemsCnt = $SPListItemCollection.Count
				Write-Host "Found $itemsCnt items." -f Yellow
				$countDown = $itemsCnt
                #if (![string]::IsNullOrEmpty($itemsCnt)){				
                if ($itemsCnt -gt 0){				
					foreach($listItem in $SPListItemCollection){
						#Write-Host $countDown
						$rItem = ""
						$fldCnt = 1
						foreach($param in $params){
							$fldName = $param.SPColumnName
								
							$fldValue = $listItem[$fldName] 
							$fldType = $fldExist.Type
							if ($param.Type -eq "Calculated"){
								$fldValue =$param.CalculatedField.GetFieldValueAsText($listItem[$fldName])
							}
							else
							{
								if (![string]::IsNullOrEmpty($fldValue)){
									$fldValue = $fldValue.Trim() 
								}
							}
							$rItem += $fldValue
							
							
							#Calculated
							<#
							https://crs2.ekmd.huji.ac.il/home/murshe/2019/Lists/contractors/dispForm.aspx?ID=236
							https://crs2.ekmd.huji.ac.il/home/murshe/2019/Lists/contractors/dispForm.aspx?ID=11
							Calculated
							idForSap
							string;#IL570043984
							
												
							Calculated
							bankForSap
							error;#256
							
							=CONCATENATE(LEFT(bankName,(FIND("-",bankName)-2)),bankBranchNum)
							
							=CONCATENATE(IF(ISERROR(FIND("-",[BankName])),LEFT([BankName],2),LEFT(bankName,(FIND("-",bankName)-2))),IF(ISBLANK([BankBranchNum]),"[Error: Branch Number is Empty]",[BankBranchNum]))
							=CONCATENATE(IF(ISERROR(FIND("-",[BankName])),IF(ISBLANK([bankName]),"[Error: Bank  is Empty]",LEFT([BankName],2)),IF(ISBLANK([bankName]),"[Error: Bank  is Empty]",LEFT(bankName,(FIND("-",bankName)-2)))),IF(ISBLANK([BankBranchNum]),"[Error: Branch Number is Empty]",[BankBranchNum]))
							IF(ISBLANK([bankName]),"[Error: Bank  is Empty]",LEFT([BankName],2))
							IF(ISBLANK([bankName]),"[Error: Bank  is Empty]",LEFT(bankName,(FIND("-",bankName)-2)))
							=IF(ISBLANK([BankBranchNum]),"No Branch Number",[BankBranchNum])

							--------------------
							Write-Host $fldType
							Write-Host $fldName
							Write-Host $listItem[$fldName]
							
							Write-Host --------------------
							Write-Host 
							#>
							
							if ($fldCnt -lt $paramsCount){
								$rItem += $delimtr
							}
							$fldCnt++
							
						}
						$countDown--
						
						
						$idItem = "" | Select ID, Status, Message, OutString
						$idItem.OutString = $rItem
						$idItem.ID = $listItem.ID
						$listofIDs += $idItem
						#break
					}	
					
				}
			}

		}

	}  # endif
	
	$outObj.ListOfIDs = $listofIDs
	
	return $outObj
}
<#
  Проблемы обсуждаемые с Евгенией 28/02/23
  
  1. Прроблема поля bankForSap. Это calculated field  по формуле.
	=CONCATENATE(LEFT(bankName,(FIND("-",bankName)-2)),bankBranchNum)
	Еслм в поле bankName нет тире, то поле имеет значение #Name?
	Предлагается заменить формулу на:
	
	=CONCATENATE(IF(ISERROR(FIND("-",[BankName])),IF(ISBLANK([bankName]),"[Error: Bank  is Empty]",LEFT([BankName],2)),IF(ISBLANK([bankName]),"[Error: Bank  is Empty]",LEFT(bankName,(FIND("-",bankName)-2)))),IF(ISBLANK([BankBranchNum]),"[Error: Branch Number is Empty]",[BankBranchNum]))
	
	
	Эта формула протестирована на стенде \\ekekaiosp05 .
	https://gss2.ekmd.huji.ac.il/home/SocialSciences/SOC23-2019/Lists/Murshe/SendToSap.aspx
	Поле : Test-BankToSap
	
	Следует также обсудить Значения "Error:..."
  
  2. При успешном формировании файла необходимо также положить в определенное место
		\\ekekfls00\data$\scriptFolders\FilesToSap\  
		(прописать путь в XML)
		PDF file из списка Final c именем из поля studentId 
		(прописать поле в XML)
		
		Важно: Имя файла а также поле studentId могут быть частью друг друга
		Например значение поля studentId 035798203 а имя файла 35798203.pdf
		или поле значение  03579820 имя файла 35798203.pdf (не хватает последней цифры)
		или имя файла перепутано или файл просто не существует.
		Для этого необходимо предусмотреть механизм фиксации ошибок и информирования по e-mail пользователя
		(имя пользователя и e-mail прописать в XML)
		
		Важно: в папке Final на данный момент ~2000 файлов.
		Следует учесть способ поиска файлов не перебором а как-то еще.
		Как вариант самостоятельно формировать PDF из папки пользователя.
		
       28/02/23	
       А.С.	   
		
		
#>
Add-PsSnapin Microsoft.SharePoint.PowerShell

$isDebug = $true
#$isDebug = $false
$crlf = [char][int]13+[char][int]10
$script=$MyInvocation.InvocationName
$cmpName = $ENV:Computername
$scriptDirectory = get-ScrptFullPath $script
Set-Location $scriptDirectory 
$dtNow = Get-Date

$dtNowStrLog 	= get-FrendlyDateLog 	$dtNow
$dtNowStr 		= get-FrendlyDate 		$dtNow


# $xmlFileName = "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\CRS\crsMursheToSap.xml"
$logFile = $scriptDirectory + "\AS-SendSap-"+$dtNowStrLog+".txt"

if ($isDebug){
	$xmlFileName = $scriptDirectory+"\crsMursheToSap.xml"
	$logFile = $scriptDirectory + "\AS-SendSap.txt"
}


Start-Transcript $logFile


$cultureHE = [System.Globalization.CultureInfo]::CreateSpecificCulture("he-IL")
$cultureEN = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 


write-host
write-host "Script For SendRalefetToSap version 2023-03-09.1"           
write-host "Asher Sandler	: mailTo:AsherSa@ekmd.huji.ac.il"           
write-host "Start time		:  <$dtNowStr>"           
write-host "User			:  <$whoami>"        
write-host "Running ON		:  <$cmpName>" 
write-host "Script file		:  <$script>"        
write-host "Log file		:  <$logFile>"
write-host "Script Directory:  <$scriptDirectory>"

write-host "XML File		:  <$xmlFileName>"        
write-host 


$xmlRakfObj = get-XmlObj $xmlFileName

	$JsonFile =   $scriptDirectory + "\xmlObj.json"
	$xmlRakfObj | ConvertTo-Json -Depth 100 | out-file $JsonFile
#	Write-Host 408 "...."
#read-host
$sapIsEmpty = $true
$oSap = get-RakefetListItems $xmlRakfObj

forEach($itm in $oSap.ListOfIDs){
	$sapIsEmpty = $false
	break
}

if (!$sapIsEmpty){
	$currentSite = $xmlRakfObj.SPSource.ListUrl
	$currentList = $xmlRakfObj.SPSource.ListName
	$targetPDF   = $xmlRakfObj.Service.TargetPdf
	$fieldName 	 = $xmlRakfObj.SPSource.SrchInFinalColumn
	$finalListName = $xmlRakfObj.SPSource.PdfFinalListName
	$idList      = $oSap.ListOfIDs
	Copy-Pdfs $currentSite $currentList $targetPDF $finalListName $idList $fieldName

	$sendSapField = $xmlRakfObj.SPSource.RunColumn
	$doneField    = $xmlRakfObj.SPSource.SapDone
	
	Update-Contractor $currentSite $currentList $oSap.ListOfIDs $sendSapField $doneField

    # Send "sapObj.json"
	$JsonFile =   "sapObj.json"
	$oSap | ConvertTo-Json -Depth 100 | out-file $JsonFile
	$ts = gc $JsonFile -raw 
	$msgSubj = "Export To SAP json: "+$(Get-Date).ToString("yyyy-MM-dd HH:mm")
	
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue

	
	$msgSubj = "Export To SAP: " + $outFileName
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue

    Write-Host "Sending Errors if exist ..."	
	$oStr = @()
	$oErr = @()
	$oErr += "There are error(s) during Processing export to SAP: "
	$isOerr = $false
	foreach($osp in $oSap.ListOfIDs){
		if ($osp.Status -eq "Ok"){
			$oStr += $osp.OutString
		}
		else
		{
			$errLine = $currentSite + "/Lists/" + $currentList+ "/DispForm.aspx?ID="+$osp.ID+$crlf
			$errLine += $osp.Message+$crlf+$crlf
			$oErr += $errLine
			$isOerr = $true
		}
	}
    if ($isOerr){
		$outFileName = ".\errors.txt"
		
		$oErr | Out-File $outFileName -Encoding Unicode
		$ts = gc $outFileName -raw 
		$msgSubj = $xmlRakfObj.Service.ReportErrorSubject + ": "+$(Get-Date).ToString("yyyy-MM-dd HH:mm")
		$recepnt = $xmlRakfObj.Service.ReportErrorTo
		# Write-Host 454 $recepnt $msgSubj
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "supportsp@savion.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $recepnt   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		
	}

	Write-Host "Sending Output CSV File..."
	# $oSap.listofIDs | Export-Csv ".\idList.csv" -Encoding UTF8 -NoTypeInfo
	$outFileName = ".\crsMursheToSap.txt"
	$oStr | Out-File $outFileName -Encoding Unicode
 	

}
Stop-Transcript

if (!$sapIsEmpty){


	$gzipexec = $scriptDirectory + "\Utils\gzip"	

	write-host "$gzipexec $logFile -f"
	& $gzipexec $logFile -f #| Out-Null
	$gzLogFile = $logFile.Replace("txt","txt.gz")

	$gzFile = get-Item $gzLogFile
	$outGzPath = "\\ekekfls00\data$\scriptFolders\LOGS\SAPExport"
	write-host "Copy gzip log to: " $outGzPath
	copy-item $gzFile $outGzPath

	write-host "Send $gzFile to: supportsp@savion.huji.ac.il" 

	$msgSubj = "Do SAP Export Log gz"
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "supportsp@savion.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "evgeniat@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $outGzPath  -Attachments  $gzFile -smtpserver ekekcas01  -erroraction SilentlyContinue
	start-sleep 2 
	remove-Item $gzFile
	
}
else
{
	$lgFile = Get-Item $logFile
	remove-Item $lgFile
}

