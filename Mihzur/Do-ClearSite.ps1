function get-FrendlyDate($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + " " + $dtNow.Hour.ToString().PadLeft(2,"0")+":"+$dtNow.Minute.ToString().PadLeft(2,"0")+":"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function get-FrendlyDateLog($dtNow){
	$dtNowS = $dtNow.Year.ToString() + "-" +$dtNow.Month.ToString().PadLeft(2,"0") + "-"+$dtNow.Day.ToString().PadLeft(2,"0") + "-" + $dtNow.Hour.ToString().PadLeft(2,"0")+"-"+$dtNow.Minute.ToString().PadLeft(2,"0")+"-"+$dtNow.Second.ToString().PadLeft(2,"0")
	return 	$dtNowS
}
function Add-List($strField)
{
	$outList = New-Object 'System.Collections.Generic.List[psobject]'
	if (![string]::isNullOrEmpty($strField)){
		$xArr = $strField.Split(",").Split(";").Trim()
		foreach($xEl in $xArr)
		{
			$outList.Add($xEl);	
		}
	} 
	return $outList
}
function get-siteToClear(){
#$mihzurObj = @()
$mihzurObj = New-Object 'System.Collections.Generic.List[psobject]'
$icount = 0
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
					#write-host "1072: $currentSite was Opened" -f Magenta	
					$webTitle = $spWeb.Title
					#write-host $currentSite -f Yellow
					#write-host "1075: " $currentList -f Green

					#write-host $webTitle -f Magenta
					$list = $spWeb.Lists[$currentList]
					$FieldsOfList = $list.Fields
					$arcfieldName = "Archive_Waiting_for_Cleanup"
					$creatArchExists =  $FieldsOfList | where{$_.Title -eq $arcfieldName}
					if ($creatArchExists){
						$query=New-Object Microsoft.SharePoint.SPQuery
						$query.Query =  "<Where>"+
											"<And>"+
												"<Eq>"+
													"<FieldRef Name='Archive_Site_Checked' />"+
													"<Value Type='Boolean'>1</Value>"+
												"</Eq>"+
												"<Eq>"+
													"<FieldRef Name='Archive_Waiting_for_Cleanup' />"+
													"<Value Type='Boolean'>1</Value>"+
												"</Eq>"+
											"</And>"+
										"</Where>"
						# 'Status'is the name of the List Column. 'CHOICE'is the information type of the Column.

						$SPListItemCollection = $list.GetItems($query)
						#write-host "Collection Count"$SPListItemCollection.Count
						foreach($listItem in $SPListItemCollection){
							$mihzurItem =  "" | Select  XYZSite, XYZList, ID, ArchiveURL,DestList,ListsToClear, ListsToDelete,RealArchiveSiteURL
							$mihzurItem.XYZSite = $currentSite
							$mihzurItem.XYZList = $currentList
							$mihzurItem.ID = $listItem.ID
							$mihzurItem.ArchiveURL = $listItem["url"]
							$mihzurItem.DestList = Add-List $listItem["destinationList"]
							$mihzurItem.RealArchiveSiteURL = $listItem["Archive_URL"]
							$mihzurItem.ListsToClear = $listItem["Archive_Lists_Clear"]
							$mihzurItem.ListsToDelete = $listItem["Archive_Lists_Delete"]
							$mhzAddToObj = $true
							foreach($mhzItem in $mihzurObj){
								if ($mhzItem.ArchiveURL -eq $mihzurItem.ArchiveURL){
									# url already exists
									$mhzAddToObj = $false
									break
								}
							}
							if ([string]::isNullOrEmpty($mihzurItem.RealArchiveSiteURL)){
								$mhzAddToObj = $false
							}
							else							
							{
								if ($mihzurItem.RealArchiveSiteURL.Contains(",")){
									$archSite = $mihzurItem.RealArchiveSiteURL.Split(",")[1].Trim()
									$archiveWeb =  get-SPWeb $archSite -ErrorAction SilentlyContinue
									if (!$archiveWeb){
										$mhzAddToObj = $false
										#Write-Host "Source Site: "$mihzurItem.ArchiveURL -f Yellow
										#Write-Host "Error: Archive Site "$mihzurItem.RealArchiveSiteURL" Not Found. Cleaning is impossible!" -f Yellow
									}
								}
								else
								{
									$mhzAddToObj = $false	
									#Write-Host "88: Source Site: "$mihzurItem.ArchiveURL -f Yellow
									#Write-Host "Error: Archive Site "$mihzurItem.RealArchiveSiteURL" Not Found. Cleaning is impossible!" -f Yellow
									#read-host
									
								}
							}
							if ($mhzAddToObj){
								$icount++
								#write-host "Icount"$icount
								$mihzurObj += $mihzurItem
								#write-host $mihzurItem.RealArchiveSiteURL -f Cyan
								#write-host "$($mihzurItem.ArchiveURL) : Will Clean"  -f Green	
								#read-host
							}
						}
					}
					else
					{
						Write-Host "Field $arcfieldName Does Not Exists in $currentList "
						Write-Host "On Site  $currentSite"
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
Function Delete-AllFilesFromLibrary([Microsoft.SharePoint.SPFolder]$Folder)
{
    #Delete All Files in the Folder
    Foreach ($File in @($Folder.Files)) 
    {
        #Delete the file
        $File.Delete() | Out-Null
 
        Write-host -f Green "Deleted File '$($File.Name)' from '$($File.ServerRelativeURL)'"
    }
 
    #Delete files in Sub-folders
    Foreach ($SubFolder in $Folder.SubFolders | where {$_.Name -ne "Forms"})
    {
        #Call the function recursively
        Delete-AllFilesFromLibrary($SubFolder)
    }
 
    #Delete folders
    ForEach ($SubFolder in @($Folder.SubFolders))
    {
        #Exclude "Forms" and Hidden folders
        If(($SubFolder.Name -ne "Forms") -and (-Not($SubFolder.Name.StartsWith("_"))))
        {
            #Delete the Sub-Folder
            $SubFolder.Delete() | Out-Null
            Write-host -f Green "Deleted Folder '$($SubFolder.Name)' from '$($SubFolder.ServerRelativeUrl)'"
        }
    }
}
function Clear-SiteDocLib($siteURL,$listName){
	$web = Get-SPWeb $siteURL
	$docLib = $Web.Lists.TryGetList($listName)
	
    Delete-AllFilesFromLibrary	$docLib.RootFolder
}
function Clear-SiteList($siteURL,$listName){

	#Parameters
	$BatchSize = 1000  #Lets delete 1000 items at a time
	 
	#Get the web object
	$web = Get-SPWeb $siteURL
	  
	#Get the List
	$list = $web.Lists[$ListName]
	#get-date 
	while ($list.ItemCount -gt 0)
	{
	 
		Write-host "Total Number of Items:"$list.itemcount
		 
		$StringBuilder = New-Object System.Text.StringBuilder
		$StringBuilder.Append("<?xml version=`"1.0`" encoding=`"UTF-8`"?><Batch>") > $null
	 
		$BatchCount=0
		 
		foreach($item in $List.Items)
		{
			$StringBuilder.Append("<Method><SetList Scope=`"Request`">$($list.ID)</SetList><SetVar Name=`"ID`">$($item.ID)</SetVar><SetVar Name=`"Cmd`">Delete</SetVar></Method>") > $null
			$BatchCount++
			if($BatchCount -ge $BatchSize) { #Break from this foreach loop
				break 
			} 
		}
		#get-date 
		$stringbuilder.Append("</ows:Batch>") > $null
	 
		$web.ProcessBatchData($StringBuilder.ToString()) > $null
		$list.Update()
		#get-date	
		#write-host Batch Done...
		#read-Host
	}
}
function Test-ListExists( $realListArr ,$clrListItem){
	$listExists = $false
	foreach($itm in $realListArr){
		if ($itm.Title.ToUpper() -eq $clrListItem.ToUpper())
		{
			$listExists = $true
			break
		}
	}
	return $listExists
}
function Update-MihzurLog($mihzurObj){
	$dt =  get-Date
	#$nullDate = get-date -Year 1900 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0
	$spWeb =  get-SPWeb "https://portals2.ekmd.huji.ac.il/home/huca/spSupport" -ErrorAction SilentlyContinue
	if ($spWeb){
		$list = $spWeb.Lists["availableArchives"]

		foreach($mihzurItem in $mihzurObj){
			$archURL = $mihzurItem.ArchiveURL
			$currentSite = $mihzurItem.XYZSite
			$currentList = $mihzurItem.XYZList
			$currentID =  $mihzurItem.ID
			$avialListUrl = $currentSite + "Lists/"+$currentList+"/EditForm.aspx?ID="+$currentID
			
			$QueryStr = "<Where><Contains><FieldRef Name='ArchiveURL' /><Value Type='URL'>$archURL</Value></Contains></Where>"
			$query=New-Object Microsoft.SharePoint.SPQuery
			$query.Query = $QueryStr
			$SPListItemCollection = $list.GetItems($query)
			#write-Host 1045 $SPListItemCollection.Count
			
			$itemID =  0
			foreach($listItem in $SPListItemCollection){
				
				$itemID = $listItem.ID
				break
			}
			if($itemID -gt 0){
				$listItm = $list.GetItembyID($itemID)	
				$listItm["SiteCleaned"] = $true
				$listItm["CleanDate"]   = $dt # Date
				$listItm.Update()
			}
			
		}
	}	
	
}
function Update-CleaningIsDone($mihzurObj){
	$dt =  get-Date
	foreach($mihzurItem in $mihzurObj){
		$currentSite = $mihzurItem.XYZSite
		$currentList = $mihzurItem.XYZList
		$currentID =  $mihzurItem.ID
		$archURL = $mihzurItem.ArchiveURL
		
		$spWeb =  get-SPWeb $currentSite -ErrorAction SilentlyContinue
		if ($spWeb){
			write-host "$archURL : CleanUp Done" -f Green
			$list = $spWeb.Lists[$currentList]
			$ListItem = $List.GetItembyID($currentID)	
			
			$ListItem["Archive_Waiting_for_Cleanup"] = $false
			$ListItem["Archive_Cleanup_Date"] = $dt
			
			$ListItem.Update()
		}	
		
	}
	return $null
	
}
Add-PsSnapin Microsoft.SharePoint.PowerShell
$dtNow = Get-Date

$dtNowStrLog 	= get-FrendlyDateLog 	$dtNow
$dtNowStr 		= get-FrendlyDate 		$dtNow

$logFile = "AS-ClearSite-01-"+$dtNowStrLog+".log"
$logFile = "AS-ClearSite-01.log"
Start-Transcript $logFile
$cultureHE = [System.Globalization.CultureInfo]::CreateSpecificCulture("he-IL")
$cultureEN = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 

$heDocLibName = "העלאת מסמכים"
$enDocLibName = "Documents Upload"

$script=$MyInvocation.InvocationName
$cmpName = $ENV:Computername

write-host
write-host "Script For CleanUp version 2022-09-14.1"           
write-host "Asher Sandler	: mailTo:AsherSa@ekmd.huji.ac.il"           
write-host "Start time		:  <$dtNowStr>"           
write-host "User			:  <$whoami>"        
write-host "Running ON		:  <$cmpName>" 
write-host "Script file		:  <$script>"        
write-host "Log file		:  <$logFile>"        
write-host 


$oMihzur = get-siteToClear
 [system.gc]::Collect()
# write-Host $oMihzur.Count
# write-Host $oMihzur.Length
# foreach($oMihzurItemX in $oMihzur){#
# 	write-Host $oMihzurItemX
# }

$jsonFileName = ".\AS-Mihzurim2Clear.json"
$oMihzur | ConvertTo-Json -Depth 100 | out-file $jsonFileName
write-host "Json File $jsonFileName was Created"

foreach($oMihzurItem in $oMihzur){
    $srcSiteUrl = $oMihzurItem.ArchiveURL
	#write-Host 263 $srcSiteUrl
	
	#if ($cmpName -eq "EKEKAIOSP05"){
		$srcSiteUrl = $oMihzurItem.RealArchiveSiteURL.Split(",")[1].Trim()
	#}
	write-host 
	write-host "==============================="
	write-host "Site To CleanUp: " $srcSiteUrl
	#read-Host
	$homeweb = Get-SPWeb  $srcSiteUrl
	$languageID = $homeweb.Language 
	
	write-host 
	write-host "Collecting Information About Lists and Document Library on Source Web" -f Yellow
	write-host "=====================================================================" -f Yellow
	$tmpListArr =  $homeweb.Lists | Select Title,RootFolder, BaseTemplate,ID,Fields | Where {$_.BaseTemplate -lt 102} 
	$realListArr = @()
	$listCount = $tmpListArr.Count
	$listCollectingProgress = 0
	foreach($tlArr in $tmpListArr){
			 
		$tmplFName = $templateName + "-" + $tlArr.Title
		$newListArrItem ="" | Select Title, RootFolder, BaseTemplate, Done
		$newListArrItem.Title=$tlArr.Title
		$newListArrItem.RootFolder=$tlArr.RootFolder.ToString()
		$newListArrItem.BaseTemplate=$tlArr.BaseTemplate
		#$newListArrItem.UIDOld =$tlArr.ID
		$docLib = $(($newListArrItem.BaseTemplate -eq 101) -and 
				  ($newListArrItem.Title.Contains($heDocLibName) -or $newListArrItem.Title.Contains($enDocLibName)))
		#$newListArrItem.IsLookupField = $null
		if (!$docLib){
			#$newListArrItem.IsLookupField = IsFieldLookup $tlArr.Fields	 
		}	 
			 
		#$newListArrItem.templateFileName=$tmplFName
		$newListArrItem.Done=$false
			 
		$realListArr += $newListArrItem 
		$listCollectingProgress++ 
		$Completed = [math]::Round(($listCollectingProgress/$listCount*100),0)
		if ($($Completed % 50) -eq 0){
			write-Host $Completed "%"
		}
		#Write-Progress -Activity "Collecting Lists" -Status "Progress:" -PercentComplete $Completed
		#write-host "Progress : $listCollectingProgress of $listCount % $Completed" -f Yellow
	}
	$realListArrFileName = ".\AS-Clear-AllList.json"
	$realListArr | ConvertTo-Json -Depth 100 | out-file $realListArrFileName
	
	write-host "Collecting Completed" -f Yellow
	$destList = $oMihzurItem.DestList
	$clrLists = $oMihzurItem.ListsToClear
	$delLists = $oMihzurItem.ListsToDelete
	
	
	# 
	$clrListArr = @()
	if (![string]::isNullOrEmpty($clrLists)){
		$clrATmp = $clrLists.Split(";").Split(",")
		foreach($clrItm in $clrATmp){
			$clrListArr += $clrItm.Trim()
		}
	}
	$dltListArr = @()
	if (![string]::isNullOrEmpty($delLists)){
		$dltATmp = $delLists.Split(";").Split(",")
		foreach($dltItm in $dltATmp){
			$dltListArr += $dltItm.Trim()
		}
	}	
	#write-Host $destList
	# Process Clear List Field
	Write-Host "Process Clear List Field" -f Green
	Write-Host "========================" -f Green
	foreach($clrListItem in $clrListArr){
		$isListExists = Test-ListExists $realListArr $clrListItem
		if ($isListExists){
			Write-Host $clrListItem -f Yellow
			Clear-SiteList $srcSiteUrl $clrListItem
		}
	}
	
	
	Write-Host "Process Delete List Field" -f Green
	Write-Host "========================" -f Green
	foreach($dltListItem in $dltListArr){
		$isListExists = Test-ListExists $realListArr $dltListItem
		if ($isListExists){
			Write-Host $dltListItem -f Yellow
			$listToDelete=$homeweb.Lists[$dltListItem]
			$listToDelete.AllowDeletion = $true
			$listToDelete.Update()
 
			$listToDelete.Delete()
 
			#Clear-SiteList $srcSiteUrl $clrListItem
		}
	}
	
    Write-Host "Clear Final" -f Green	
    Write-Host "===========" -f Green
	$listName = "Final"
	$isListExists = Test-ListExists $realListArr $listName 
	if ($isListExists){
		Clear-SiteDocLib $srcSiteUrl $listName
	}


    Write-Host "Clear Submitted" -f Green	
    Write-Host "===============" -f Green
	$listName = "Submitted"
	$isListExists = Test-ListExists $realListArr $listName 
	if ($isListExists){
		Clear-SiteDocLib $srcSiteUrl $listName
	}
	
    Write-Host "Delete User Document Libs" -f Green	
    Write-Host "=========================" -f Green
	foreach($dltListItem in $realListArr){
		$docLibName = $dltListItem.Title
		$isUsrLib = ($docLibName.Contains($heDocLibName) -or $docLibName.Contains($enDocLibName))
		if ($isUsrLib){
			Write-Host $docLibName
			$listToDelete=$homeweb.Lists[$docLibName]
			$listToDelete.AllowDeletion = $true
			$listToDelete.Update()
 
			$listToDelete.Delete()
 
			
		}
	}	

	foreach($dltListItem in $destList){
		$listName = $dltListItem
		$isListExists = Test-ListExists $realListArr $listName
		if ($isListExists){
			Write-Host "Clear "$listName" List" -f Green
			Write-Host "========================" -f Green

			Clear-SiteList $srcSiteUrl $listName
		}
	}
	
	# cancelledApplicantsList
	$listName = "cancelledApplicantsList"
	$isListExists = Test-ListExists $realListArr $listName
	if ($isListExists){
		Write-Host "Clear "$listName" List" -f Green
		Write-Host "========================" -f Green

		Clear-SiteList $srcSiteUrl $listName
	}	
	
	
}

Update-CleaningIsDone $oMihzur 
Update-MihzurLog $oMihzur

Stop-Transcript
$ts = gc $logFile -raw 
$msgSubj = "Do ClearSite Log"
Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
start-sleep 2 





