

function Get-XmlObj($xmlFileName){
	$obj = "" | Select Service,SPSource,Params
	$oParams = @()
	$servc  = "" | Select TargetUrl,FileName,Delimiter,Encoding
	$SPSource  = "" | Select ListUrl,ListName,MainList,RunColumn,UniqueIdentifierColumn,DoneColumn
	$xmlFile = Get-Content $xmlFileName -raw
	$isXML = [bool](($xmlFile) -as [xml])
	if ($isXML){
			#$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/Config/application/control" | ForEach-Object 
			              #{$_.Node.Data}
						  
		$xmlDoc = [xml]$xmlFile
		$xmlServices = $xmlDoc.SelectNodes("//Service")
		#write-host 14	
		foreach($service in $xmlServices){
			$servc.TargetUrl =  $service.TargetUrl
			$servc.FileName =   $service.FileName
			$servc.Delimiter =  $service.Delimiter.InnerText
			
			$servc.Encoding =   $service.Encoding
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

$xmlFileName = ".\crsMursheToSap.xml"
#$xmlFileName = "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\rakefet.xml"
$xmlRakfObj = get-XmlObj $xmlFileName



	$JsonFile =   "xmlObj.json"
	$xmlRakfObj | ConvertTo-Json -Depth 100 | out-file $JsonFile
