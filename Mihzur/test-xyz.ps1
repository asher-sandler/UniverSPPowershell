function Update-MihzurIsDone($mihzurObj){
	$dt =  get-Date
	foreach($mihzurItem in $mihzurObj){
		$currentSite = $mihzurItem.XYZSite
		$currentList = $mihzurItem.XYZList
		$currentID =  $mihzurItem.ID
		$archURL = $mihzurItem.ArchiveURL
		
		$spWeb =  get-SPWeb $currentSite -ErrorAction SilentlyContinue
		if ($spWeb){
			write-host "$archURL : Archive Done" -f Green
			$list = $spWeb.Lists[$currentList]
			$ListItem = $List.GetItembyID($currentID)	
			#$ListItem["createArchive"] = $false
			$ListItem["lastArchive"] = $dt
			$ListItem.Update()
		}	
		
	}
	return $null
	
}
function get-siteToArchive(){
$mihzurObj = @()
$xmlConfigFile = "\\ekeksql00\SP_Resources$\WP_Config\availableXYZListPath\availableXYZListPath.xml"
$xmlFile = Get-Content $xmlConfigFile -raw
$isXML = [bool](($xmlFile) -as [xml])
		if ($isXML){
			#$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/Config/application/control" | ForEach-Object 
			              #{$_.Node.Data}
						  
			$xmlDoc = [xml]$xmlFile
			$configXYZList = $xmlDoc.SelectNodes("//application")
			foreach($elXYZ in $configXYZList){
				$currentSite = $elXYZ.appHomeUrl
				$currentList = $elXYZ.listName

				$spWeb =  get-SPWeb $currentSite -ErrorAction SilentlyContinue
				if ($spWeb){
					#write-host " $currentSite was Opened" -f Magenta	
					$webTitle = $spWeb.Title
					#write-host $currentSite -f Yellow
					#write-host $currentList -f Green

					#write-host $webTitle -f Magenta
					$list = $spWeb.Lists[$currentList]
					$query=New-Object Microsoft.SharePoint.SPQuery
					$query.Query = "<Where><Eq><FieldRef Name='createArchive' /><Value Type='Boolean'>1</Value></Eq></Where>"

					# 'Status'is the name of the List Column. 'CHOICE'is the information type of the Column.

					$SPListItemCollection = $list.GetItems($query)
					#$SPListItemCollection.Count
					foreach($listItem in $SPListItemCollection){
						$mihzurItem =  "" | Select  XYZSite, XYZList, ID, ArchiveURL
						$mihzurItem.XYZSite = $currentSite
						$mihzurItem.XYZList = $currentList
						$mihzurItem.ID = $listItem.ID
						$mihzurItem.ArchiveURL = $listItem["url"]
						$mihzurObj += $mihzurItem
						
						write-host "$($mihzurItem.ArchiveURL) : Will Archive"  -f Green	

					}
					$spWeb.Dispose()
				}
				
			}
			
		}
		else
		{
			write-host "$xmlConfigFile File type is not XML file!" 
		}
		return $mihzurObj
	
}
Add-PsSnapin Microsoft.SharePoint.PowerShell
$oMihzur = get-siteToArchive

Update-MihzurIsDone $oMihzur

$oMihzur