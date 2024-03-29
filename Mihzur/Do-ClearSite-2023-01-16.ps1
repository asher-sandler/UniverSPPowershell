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
			$itemAlreadyExists = $false
			foreach($itmX in $outList){
				if ($itmX.ToLower() -eq  $xEl.ToLower()){
					$itemAlreadyExists = $true
					break
				}
			}
			if (!$itemAlreadyExists){
				$outList.Add($xEl);	
			}
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
							$mihzurItem =  "" | Select  XYZSite, XYZList, ID, ArchiveURL,DestList,ListsToClear, ListsToDelete,RealArchiveSiteURL,relativeURL,timeStamp,applicantsGroup
							$mihzurItem.XYZSite = $currentSite
							$mihzurItem.XYZList = $currentList
							$mihzurItem.ID = $listItem.ID
							$mihzurItem.ArchiveURL = $listItem["url"]
							$mihzurItem.DestList = Add-List $listItem["destinationList"]
							$mihzurItem.RealArchiveSiteURL = $listItem["Archive_URL"]
							$mihzurItem.ListsToClear = $listItem["Archive_Lists_Clear"]
							$mihzurItem.ListsToDelete = $listItem["Archive_Lists_Delete"]
							$mihzurItem.relativeURL = $listItem["relativeURL"]
							$mihzurItem.applicantsGroup = $listItem["applicantsGroup"]
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
 
        #Write-host -f Green "Deleted File '$($File.Name)' from '$($File.ServerRelativeURL)'"
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
	#$docLib = $Web.Lists.TryGetList($listName)
	$docLib = $web.Lists | Where-Object{$_.RootFolder.Name -eq $listName}
	
	write-Host 181 $listName
	write-Host 182 $docLib.RootFolder
    Delete-AllFilesFromLibrary	$docLib.RootFolder
}
function Is-ListMatch ($basTempl,$rootFldr,$lstName){
	$retVal = $false
	$rFolderName = $rootFldr.ToString()
	if ($basTempl -eq "GenericList"){
		$rFolderName = $rootFldr.Split("/")[1]
	}
	
	if ($rFolderName.ToUpper() -eq $lstName.ToUpper())
	{
		$retVal = $true
	}
	#write-Host 176 $basTempl $rFolderName $lstName  $retVal
	#read-Host
	
	return $retVal
}
function Clear-SiteList($siteURL,$listName){

	#Parameters
	$BatchSize = 1000  #Lets delete 1000 items at a time
	$listNameParam =  $listName
	#Get the web object
	$web = Get-SPWeb $siteURL
	  
	#Get the List
	$list = $web.Lists[$ListName]

	if ([string]::IsNullOrEmpty($list)){
		$list = $web.Lists | Where-Object { Is-ListMatch $_.BaseTemplate $_.RootFolder.Url $listName }
		$listName = $list.Title	
	}
	if (![string]::IsNullOrEmpty($list)){
		#get-date 
		$basTempl = $List.BaseTemplate
		write-Host "List  " $listNameParam $list.Title
		Write-host "Total Number of Items:" $list.itemcount
		
		#read-Host
		if ($basTempl -eq 100){ # list
			while ($list.ItemCount -gt 0)
			{
		 

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
					#Write-Host	"203 " $StringBuilder.ToString()
				}
				#get-date 
				$stringbuilder.Append("</ows:Batch>") > $null
				
				#Write-Host	"208 " $StringBuilder.ToString()
				$web.ProcessBatchData($StringBuilder.ToString()) > $null
				$list.Update()
			
			#get-date	
			#write-host Batch Done...
			#read-Host
			}
		}
		if ($basTempl -eq 101){ # DocLib
			#Clear-SiteDocLib $siteURL $listName 		
			Clear-SiteDocLib $siteURL $list.RootFolder.Name 		
		}
		
	}
	else
	{
		write-Host "Can't open list" $listName
	}
}

function Test-ListExists( $realListArr ,$clrListItem){
	$listExists = "" | Select Exists, RootFolder
	$listExists.Exists = $false
	foreach($itm in $realListArr){
		if ($itm.Title.ToUpper() -eq $clrListItem.ToUpper())
		{
			$listExists.Exists = $true
			$listExists.RootFolder = $itm.RootFolder
			break
		}
	}
	if (!$listExists.Exists){
		foreach($itm in $realListArr){
			$rFolderName = $itm.RootFolder
			if ($itm.BaseTemplate -eq 100){
				# i.e. "RootFolder":  "Lists/applicants"
				$rFolderName = $itm.RootFolder.Split("/")[1]
			}
			if ($rFolderName.ToUpper() -eq $clrListItem.ToUpper())
			{
				$listExists.Exists = $true
				$listExists.RootFolder = $rFolderName
				break
			}
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
		$list = $spWeb.Lists["spRequestsList"]
		foreach($mihzurItem in $mihzurObj){
			if (![string]::IsNullOrEmpty($mihzurItem.relativeURL)){
				$relUrl       = $mihzurItem.relativeURL.Trim()
				#$QueryStr = "<Where><Contains><FieldRef Name='currentSiteUrl' /><Value Type='Text'>$relUrl</Value></Contains></Where>"
				$QueryStr = "<Where><And><Contains><FieldRef Name='currentSiteUrl' /><Value Type='Text'>$relUrl</Value></Contains><Neq><FieldRef Name='status' /><Value Type='Choice'>9 - טופל</Value></Neq></And></Where><OrderBy><FieldRef Name='language' Ascending='False' /></OrderBy>"
				$query=New-Object Microsoft.SharePoint.SPQuery
				$query.Query = $QueryStr
				$SPListItemCollection = $list.GetItems($query)
				$itemID =  0
				foreach($listItem in $SPListItemCollection){
					$itemID = $listItem.ID
					break
				}
				if($itemID -gt 0){
					$listItm = $list.GetItembyID($itemID)
					#$listItm["MihzurConnection_UID"]   = $mihzurItem.timeStamp
					if ($listItm["status"] -eq "2 - ארכיון בוצע"){
						$listItm["status"]   = "4 - ניקוי לאחר ארכוב בוצע" 
					}
					$listItm.Update()

				}
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
function Clear-AdGroup($mihzurObj){
	foreach($mihzurItem in $mihzurObj){
		$applicantsGroup = $mihzurItem.applicantsGroup
		if (![string]::IsNullOrEmpty($applicantsGroup)){
			write-Host "Clear users in AD applicantsGroup(s)" -f Cyan
			break
		}
	}
	foreach($mihzurItem in $mihzurObj){
		$applicantsGroup = $mihzurItem.applicantsGroup
		if (![string]::IsNullOrEmpty($applicantsGroup)){
			# check for valid group
			if (![string]::IsNullOrEmpty($mihzurItem.relativeURL)){
				$applGrp = ($mihzurItem.relativeURL + "_applicantsug").toLower()
				write-Host $applGrp
				if ($applicantsGroup.ToLower().Contains($applGrp)){
					write-Host "Group: " $applicantsGroup -f Yellow
					$members =  $null
					$members = Get-ADGroupMember $applicantsGroup -Recursive
					foreach($groupMember in $members){
						write-Host "Remove User: " $groupMember.SamAccountName -f Yellow
						if (![string]::IsNullOrEmpty($groupMember.SamAccountName )){
							Remove-ADGroupMember $applicantsGroup $groupMember -Confirm:$false
						}
						#read-Host
					}
				}
			}
		}
	}
}
function get-ScrptFullPath($scriptX ){
	$fileScr = get-Item $scriptX
	return $fileScr.DirectoryName
}
Add-PsSnapin Microsoft.SharePoint.PowerShell
$dtNow = Get-Date

$dtNowStrLog 	= get-FrendlyDateLog 	$dtNow
$dtNowStr 		= get-FrendlyDate 		$dtNow

$logFile = "AS-ClearSite-01-"+$dtNowStrLog+".txt"
#$logFile = "AS-ClearSite-01.log"
Start-Transcript $logFile
$cultureHE = [System.Globalization.CultureInfo]::CreateSpecificCulture("he-IL")
$cultureEN = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US") 

$heDocLibName = "העלאת מסמכים"
$enDocLibName = "Documents Upload"

$script=$MyInvocation.InvocationName
$cmpName = $ENV:Computername
$scriptDirectory = get-ScrptFullPath $script

write-host
write-host "Script For CleanUp version 2022-12-07.1"           
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
$mihzurNotEmpty = $false

foreach($oMihzurItem in $oMihzur){
	$mihzurNotEmpty = $true	
}
if ($mihzurNotEmpty){	
	$ts = gc $jsonFileName -raw 
	if (![string]::IsNullOrEmpty($ts)){
		 $msgSubj = "Task Do-ClearSite Started on Sites: " + $JsonFile
		 Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "supportsp@savion.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		 #Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
		 start-sleep 2
	}
}
foreach($oMihzurItem in $oMihzur){
    $srcSiteUrl = $oMihzurItem.ArchiveURL
	#write-Host 263 $srcSiteUrl
	
	#if ($cmpName -eq "EKEKAIOSP05"){
		#$srcSiteUrl = $oMihzurItem.RealArchiveSiteURL.Split(",")[1].Trim()
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
	$ts = gc $realListArrFileName -raw 
	$msgSubj = $realListArrFileName
    Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "ashersa@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue

	
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
	$clrListArr = $clrListArr | Sort -Unique	

	$dltListArr = @()
	if (![string]::isNullOrEmpty($delLists)){
		$dltATmp = $delLists.Split(";").Split(",")
		foreach($dltItm in $dltATmp){
			$dltListArr += $dltItm.Trim()
		}
	}
	$dltListArr = $dltListArr | Sort -Unique	
	
	#write-Host $destList
	# Process Clear List Field
	Write-Host "Process Clear List Field" -f Green
	Write-Host "========================" -f Green
	foreach($clrListItem in $clrListArr){
		$isListExists = Test-ListExists $realListArr $clrListItem
		if ($isListExists.Exists){
			Write-Host $clrListItem -f Yellow
			Clear-SiteList $srcSiteUrl $clrListItem
		}
	}
	
	
	Write-Host "Process Delete List Field" -f Green
	Write-Host "========================" -f Green
	foreach($dltListItem in $dltListArr){
		$isListExists = Test-ListExists $realListArr $dltListItem
		if ($isListExists.Exists){
			Write-Host 571 $dltListItem -f Yellow
			Write-Host 572 $isListExists.RootFolder -f Yellow
			$listToDelete=$homeweb.Lists | Where {$_.RootFolder.Name.Trim().ToLower() -eq $isListExists.RootFolder.Trim().ToLower()}
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
	if ($isListExists.Exists){
		Clear-SiteDocLib $srcSiteUrl $listName
	}


    Write-Host "Clear Submitted" -f Green	
    Write-Host "===============" -f Green
	$listName = "Submitted"
	$isListExists = Test-ListExists $realListArr $listName 
	if ($isListExists.Exists){
		write-Host 588 $listName
		
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
		if ($isListExists.Exists){
			Write-Host "Clear "$listName" List" -f Green
			Write-Host "========================" -f Green

			Clear-SiteList $srcSiteUrl $listName
		}
	}
	
	# cancelledApplicantsList
	$listName = "cancelledApplicantsList"
	$isListExists = Test-ListExists $realListArr $listName
	if ($isListExists.Exists){
		Write-Host "Clear "$listName" List" -f Green
		Write-Host "========================" -f Green

		Clear-SiteList $srcSiteUrl $listName
	}	
	
	
}

Update-CleaningIsDone $oMihzur 
Clear-AdGroup $oMihzur
Update-MihzurLog $oMihzur
write-host "Clear Mihzur Completed. Bye." -f Yellow
write-host "==============================================" -f Yellow

Stop-Transcript
if ($mihzurNotEmpty){
	$ts = gc $logFile -raw 
	$msgSubj = "Do ClearSite Log"
	Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "supportsp@savion.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "evgeniat@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To "danielkl@ekmd.huji.ac.il"   -From $doNotReply  -Subject $msgSubj -body $ts  -smtpserver ekekcas01  -erroraction SilentlyContinue
	start-sleep 2 



	$gzipexec = $scriptDirectory + "\Utils\gzip"	

	write-host "$gzipexec $logFile -f"
	& $gzipexec $logFile -f #| Out-Null
	$gzLogFile = $logFile.Replace("txt","txt.gz")

	$gzFile = get-Item $gzLogFile
	$outGzPath = "\\ekekfls00\data$\scriptFolders\LOGS\Mihzur"
	copy-item $gzFile $outGzPath

	$msgSubj = "Do ClearSite Log gz"
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






