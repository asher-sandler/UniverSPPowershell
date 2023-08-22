	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.Portable.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Search.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$cred = get-SCred

 
 $siteName = "https://portals2.ekmd.huji.ac.il/home/huca/committees/SPProjects2017";
 $siteName = "https://portals2.ekmd.huji.ac.il/home/huca/spSupport";
 $ListName="spRequestsList"

	 

 
 write-host "URL: $siteName" -foregroundcolor Yellow
 
 
 $siteUrl = get-UrlNoF5 $siteName

 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 $List = $Ctx.Web.lists.GetByTitle($listName)	

	#Define the CAML Query
  $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
  $qry = "<View><Query>
   <Where>
      <Eq>
         <FieldRef Name='status' />
         <Value Type='Choice'>טופל</Value>
      </Eq>
   </Where>
   <OrderBy>
      <FieldRef Name='Created' Ascending='False' />
   </OrderBy>
	
</Query>
<RowLimit>50</RowLimit>
</View>"
    $Query.ViewXml = $qry
  
	$ListItems = $List.GetItems($Query)
	$Ctx.Load($ListItems)
	$Ctx.ExecuteQuery()
	
	$i= $ListItems.Count
	$templROW = get-Content "EmailTemplate\templateRow.html" -raw -encoding UTF8
	$idxRow = ""
	$templIndex = get-Content "EmailTemplate\index.html" -raw -encoding UTF8
	$needToSend = $false
	
	forEach($reqstItem in $ListItems){
		$currentGroup = $reqstItem["assignedGroup"]
		
		
		#write-host $currentSystem
		$ipad = $i.ToString().PadLeft(4," ")
		write-host $("`r$ipad") -noNewLine -f Magenta
		if ([string]::isNullOrEmpty($currentGroup)){
			continue
		}
		if ([string]::isNullOrEmpty($currentGroup.Trim())){
			continue
		}
		
		$currentSystem = Get-CurrentSystem $currentGroup
		
		if ([string]::isNullOrEmpty($currentSystem.appHomeUrl)){
			continue
		}
		
		#write-host $currentGroup
		
		$systemUrl = $currentSystem.appHomeUrl
		$systemListName = $currentSystem.listName
		$groupTEMPLATE = Get-GroupTemplate $currentGroup
		$currentList = $systemUrl + "lists/"+$systemList
		
		$groupSuffix =  Get-GroupSuffix $currentGroup
		$relURL = get-UrlNoF5 $(Get-GroupTemplate $currentGroup)
		$mailSuffix = $groupSuffix.toUpper() +"-"+ $relURL
		
		
		#write-host $mailSuffix -f Green
		#write-host $systemUrl -f Cyan
		#write-host $systemListName -f Magenta

		$CtxSystem = New-Object Microsoft.SharePoint.Client.ClientContext($systemUrl)
		$CtxSystem.Credentials = $Credentials
		$SystemList = $CtxSystem.Web.lists.GetByTitle($systemListName)

		$QuerySystem = New-Object Microsoft.SharePoint.Client.CamlQuery
		$qryS = "<View><Query>
		   <Where>
			  <Eq>
				 <FieldRef Name='mailSuffix' />
				 <Value Type='Text'>$mailSuffix</Value>
			  </Eq>
		   </Where>
		</Query>
</View>"
		$QuerySystem.ViewXml = $qryS
			
		$SystemListItems = $SystemList.GetItems($QuerySystem)
		$CtxSystem.Load($SystemListItems)
		$CtxSystem.ExecuteQuery()
		
		forEach($ListSystmItm in $SystemListItems ){
			$workURL = get-UrlNoF5 $ListSystmItm["url"]
			$systemID = $ListSystmItm.ID
			$deadLineS = $ListSystmItm["deadline"] # deadline System
			$checkedDeadlFromAvailList = $deadLineS.Year.ToString()+"-"+$deadLineS.Month.ToString().PadLeft(2,"0")+"-"+$deadLineS.Day.ToString().PadLeft(2,"0")
			$nowDate = Get-Date
			if ($deadLineS -ge $nowDate){
				#write-host $deadLineS  -f Green
				$ctx2 = New-Object Microsoft.SharePoint.Client.ClientContext($workURL)  
				
				$ctx2.Credentials = $Credentials
				$lists2 = $ctx2.web.Lists
				$applist = $lists2.GetByTitle("applicants")
				
				$Ctx2.load($applist.Fields) 
				$Ctx2.ExecuteQuery()	


				forEach($fld in $applist.Fields){
					if ($fld.Title -eq "deadline"){
						#write-host "Found"
						$schemaField = $fld.SchemaXml
						$isXML = [bool]($schemaField -as [xml])
			# file is XML type
			
						if ($isXML){
							#write-host $schemaField
							$xmlNodeData = Select-Xml -Content $schemaField -XPath "/Field" | ForEach-Object {$_.Node.Default}
							foreach ($line in $xmlNodeData){
						
								if (![String]::IsNullOrEmpty($line)){
									$dedlW = Get-Date $line
									$israelTZ = "Israel Standard Time"
									$GMTTZ = "GMT Standard Time"
									# [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::Now,"AUS Eastern Standard Time")
									# [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($dedlW,$israelTZ)
									
									$dlnD =  $dedlW.AddHours(-4)
									
									
									$checkedDeadlFromApplicant = $dlnD.Year.ToString()+"-"+$dlnD.Month.ToString().PadLeft(2,"0")+"-"+$dlnD.Day.ToString().PadLeft(2,"0")
									
									If (!$($checkedDeadlFromAvailList -eq $checkedDeadlFromApplicant)){
										$systemListHtml = $(get-UrlWithF5 $($systemUrl+"lists/"+$systemListName))
										$applicURLHtml = $(get-UrlWithF5 $workURL)
										write-host
										write-host $groupTEMPLATE
										write-host $systemID
										write-host $systemListHtml
										write-host $applicURLHtml
										write-host $checkedDeadlFromAvailList -f Green
										write-host $checkedDeadlFromApplicant -f Cyan
										$deadLineS1 = $deadLineS.AddDays(1)
										$deadlineSystem = $deadLineS1.Day.ToString().PadLeft(2,"0")+"."+$deadLineS1.Month.ToString().PadLeft(2,"0")+"."+$deadLineS1.Year.ToString()
										$dlnD1 = $dlnD.AddDays(1)
										$deadLineApplicant = $dlnD1.Day.ToString().PadLeft(2,"0")+"."+$dlnD1.Month.ToString().PadLeft(2,"0")+"."+$dlnD1.Year.ToString()
										
										$needToSend = $true
										$idxRow += $templROW
										
										$idxRow = $idxRow -Replace "{TEMPLATE}",$groupTEMPLATE
										$idxRow = $idxRow -Replace "{DEADLINESYSTEM}",$deadlineSystem
										$idxRow = $idxRow -Replace "{DEADLINEAPPLICANTS}",$deadLineApplicant
										$idxRow = $idxRow -Replace "{SYSTEMLIST}",$systemListHtml
										$idxRow = $idxRow -Replace "{SYSTEMID}",$systemID
										$idxRow = $idxRow -Replace "{SYSTEMID}",$systemID
										$idxRow = $idxRow -Replace "{APPLICANTURL}",$applicURLHtml
										<#
										https://grs2.ekmd.huji.ac.il/home/_layouts/15/listform.aspx?PageType=6&ListId=%7B64F16E96%2DDA30%2D4F2E%2D9DF9%2DC917735CD72D%7D&ID=361
										https://grs2.ekmd.huji.ac.il/home/_layouts/15/listform.aspx?PageType=6&ListID=availableGRSList&ID=361
										https://grs2.ekmd.huji.ac.il/home/lists/availableGRSList/DispForm.aspx?ID=361
										#>
									}
									
									
								}
							}	

						}
					}
				}
				<#
				$fieldDedl = $applist.Fields.GetByTitle("deadline")
				$ctx2.Load($fieldDedl);
				$ctx.ExecuteQuery();	
				
				$dedlW = $fieldDedl.DefaultValue
				
				write-host
				
				write-host $workURL -f Yellow
				write-host $deadLineS -f Cyan
				write-host $dedlW -f Magenta
				 $fieldDedl | fl
				
				#>
			}	
	
			
		}
		
		#$SystemListItems.FieldValues | fl

		$i--	
	}
	$needToSend = $true
	if ($needToSend){
		
		    $htmlBody = $templIndex -Replace "{TEMPLATEROW}",$idxRow 
			$target = "support@ekmd.huji.ac.il"
			$supportEmail = "AsherSa@ekmd.huji.ac.il"
			$doNotReply = "support@ekmd.huji.ac.il"
			$subj = "Deadline inconsistency found"
			
			#$smtpserverName = "ekekcas01"
			
			#Send-MailMessage -Encoding ([system.Text.Encoding]::UTF8) -To $target -From $doNotReply -cc $supportEmail -Subject $subj -body $newtext -BodyAsHtml -smtpserver $smtpServerName  -erroraction Stop
			
			$Outlook = New-Object -ComObject Outlook.Application
			$Mail = $Outlook.CreateItem(0)
			$Mail.To = $target
			$Mail.Sender = $doNotReply
			$Mail.Subject = $subj
			$Mail.HTMLBody  =$htmlBody
			$Mail.Send()
			

	}

	  


