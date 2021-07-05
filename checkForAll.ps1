Start-Transcript "checkForAll.log"


# System.Reflection.Assembly]::LoadWithPartialName("System")
# [System.Reflection.Assembly]::LoadWithPartialName("System.IO")
# Add-PsSnapin Microsoft.SharePoint.PowerShell
cls
# $0 = $myInvocation.MyCommand.Definition
# $dp0 = [System.IO.Path]::GetDirectoryName($0)
# . "$dp0\checkForDoubleDataNameXML.ps1"


#=================--  MED --=================

$filter = "MED*.xml"
$xMedXMLs=get-childitem -path \\ekeksql00\sp_resources$\HSS\default\ -recurse -File -Filter $filter

foreach($item in $xMedXMLs){
	.\checkForDoubleDataNameXML.ps1 $item.FullName
}


#=================--  HUM --=================


$filter = "HUM*.xml"
$xHumXMLs=get-childitem -path \\ekeksql00\sp_resources$\HSS\default\ -recurse -File -Filter $filter

foreach($item in $xHumXMLs){
	.\checkForDoubleDataNameXML.ps1 $item.FullName
}


#=================--  AGR --=================


$filter = "AGR*.xml"
$xAgrXMLs=get-childitem -path \\ekeksql00\sp_resources$\HSS\default\ -recurse -File -Filter $filter

foreach($item in $xAgrXMLs){
	.\checkForDoubleDataNameXML.ps1 $item.FullName
}

#=================--  EDU --=================

$filter = "EDU*.xml"
$xEduXMLs=get-childitem -path \\ekeksql00\sp_resources$\HSS\default\ -recurse -File -Filter $filter

foreach($item in $xEduXMLs){
	.\checkForDoubleDataNameXML.ps1 $item.FullName
}


Stop-Transcript