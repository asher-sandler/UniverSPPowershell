Add-PsSnapin Microsoft.SharePoint.PowerShell

$srcSiteUrl =     "https://gss2.ekmd.huji.ac.il/home/OverseasApplicantsUnit/GEN27-2020/"
write-host "Site: $srcSiteUrl" -f Yellow
write-host
write-host "Looking for subsites..."
$homeweb = Get-SPWeb  $srcSiteUrl
$subsites = $homeweb.Webs
$subSitesObj = [System.Collections.ArrayList]::new()
$idx = 1
#$subsites
foreach($site in $subsites){
	$sItem = "" | Select Index, Title, Url
	$sItem.Index = $idx
	$sItem.Title = $site.Title
	$sItem.Url = $site.Url
	#write-host 13
	$subSitesObj.Add($sItem) | out-null
	$idx++
}

#$subSitesObj = Get-ListSubSiteObj $homeweb
#$subSitesObj
#$subSitesObj.Count
if ($subSitesObj.Count -gt 0){
	write-host "Subsites found." -f Green
	write-host "Please choose subsite you want to delete by Index (1,2,...)" -f Green
	write-host "Index Title"
	write-host "----- -----"
	foreach($st in $subSitesObj){
		
		write-host " " $st.Index " " $st.Title 
	}
	write-host "Choose Index :" -f Yellow -noNewLine
	$continue = read-host 
    $choice = $null	
	$siteURL = ""
    if (($continue.length -eq 1) -and ("123456789".contains($continue))){
		foreach($st in $subSitesObj){
			if ($st.Index.ToString() -eq $continue){
				$choice = $st.Title
				$siteURL = $st.Url
				break
			}
		}
	}
	if($choice){
		write-host "Deleting $choice. Are you sure  [Y/n]?" -noNewLine -f Yellow
		$continue = read-host  
		if (($continue.length -eq 1) -and ([int][char]$continue -eq 89)){
             Write-Host $siteURL -f Cyan
             Write-Host "Processing..." -f Magenta
			 $archWeb = get-SPWEB $siteURL
			 $aLists = $archWeb.Lists
			 $xLists =  @()
			 foreach($ls in $aLists){
				$xLists += $ls.Title 
			 }
			 
			 $xLists.Count
			 foreach($tl in $xLists){
				try{ 
				if ($tl -eq "Submitted"){
					continue
				}
				$listForDelete = $archWeb.Lists[$tl] 
				write-host $tl
				$listForDelete.Delete()
				#read-host
				write-host "Done deleting list..." -f Green
				}
				catch{
					Write-Host "$($_.Exception.Message)" 	-f Yellow	
				}
			 }
			 Remove-SPWeb $siteURL -Confirm:$false
			 
		}
		else
		{
			write-host "Exiting..." -f Yellow 
		}
	}
	else 	
	{
		write-host "Wrong Choice. Exiting..." -f Yellow 
	}

	
}
else
{
	write-host "No Subsites Found." -f Yellow
}
