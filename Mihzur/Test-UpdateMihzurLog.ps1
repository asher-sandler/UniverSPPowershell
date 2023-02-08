function Update-MihzurLog(){
	$dt =  get-Date
	#$nullDate = get-date -Year 1900 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
	
	$spWeb =  get-SPWeb "https://gss2.ekmd.huji.ac.il/home/" -ErrorAction SilentlyContinue
	if ($spWeb){
		$list = $spWeb.Lists["availableArchives"]


			$listItm = $list.GetItembyID(1)	
			
			$listItm["SiteURL"]     = "1111"
			$listItm["ArchiveURL"]  = "https://scholarships2.ekmd.huji.ac.il/home/General/GEN164-2021/Archive-2023-01-15"
			$listItm["availableListURL"]  = "https://scholarships2.ekmd.huji.ac.il/home/General/GEN164-2021/Archive-2023-01-15"
			$listItm["ArchiveDate"] = $dt
			$listItm["SiteCleaned"] = $false
			$listItm["CleanDate"]   = $null # Date
			$listItm["Title"]       = "4444" # Title
			$listItm["siteDescription"]   = "5555" # English name
			$listItm["ReqListConnection_UID"]   = "66666" # 
			$listItm["integrityReport"]   = "<b>Check Integrity</b><br>https://scholarships2.ekmd.huji.ac.il/home/General/GEN164-2021/Archive-2023-01-15<br/>List: <b>Submitted</b><br>Source Items Count     : 256<br/>Destination Items Count: <br/>-----------<br/><br/>" # 
			$listItm.Update()
		}
}
Add-PsSnapin Microsoft.SharePoint.PowerShell
Update-MihzurLog
