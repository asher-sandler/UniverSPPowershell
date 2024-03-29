param([string] $urlSite = ""

	
	
	)
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

$Credentials = get-SCred

 
 $siteName = $urlSite;
 if ([string]::IsNullOrEmpty($siteName)){
	 write-host "Please Specify Site Url." -f Yellow
 }
 else
 {
 
	$siteUrl = get-UrlNoF5 $siteName

	write-host "URL: $siteURL" -foregroundcolor Yellow
	 
	 
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
	$Ctx.Credentials = $Credentials
	$Web = $Ctx.Web
	
	$ctx.Load($Web)
	Try 
	{
        $Ctx.ExecuteQuery()
		$Ctx.Load($web.Webs)
		$Ctx.executeQuery()
		
		$subSitesObj = [System.Collections.ArrayList]::new()
		$idx = 1		
		foreach($subweb in $web.Webs){
			$sItem = "" | Select Index, Title, Url
			$sItem.Index = $idx
			$sItem.Title = $subweb.Title
			$sItem.Url = $subweb.Url
			#write-host 13
			$subSitesObj.Add($sItem) | out-null
			$idx++	
		}

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
			$siteURLArc = ""
			if (($continue.length -eq 1) -and ("123456789".contains($continue))){
				foreach($st in $subSitesObj){
					if ($st.Index.ToString() -eq $continue){
						$choice = $st.Title
						$siteURLArc = $st.Url
						break
					}
				}
			}
			if($choice){
				write-host "Deleting $choice. Are you sure  [Y/n]?" -noNewLine -f Yellow
				$continue = read-host 
				$ctx=$null				
				if (($continue.length -eq 1) -and ([int][char]$continue -eq 89)){
					Write-Host $siteURLArc -f Cyan
					$CtxArc = New-Object Microsoft.SharePoint.Client.ClientContext($siteURLArc)
					$CtxArc.Credentials = $Credentials
					$WebArc = $CtxArc.Web
					$ctxArc.Load($WebArc)
                    $CtxArc.ExecuteQuery()

					
					Write-Host "Processing..." -f Magenta
					$ListsArc = $WebArc.Lists
					$CtxArc.Load($ListsArc)
                    $CtxArc.ExecuteQuery()
					$listCount = $ListsArc.Count
					$heDocLibName = "העלאת מסמכים"
					$enDocLibName = "Documents Upload"
					#$List.DeleteObject()
					$applicantsLists =  @()

					Write-Host "Found $listCount Lists" -f Magenta
					ForEach($list in $ListsArc){
								if ($list.Title.contains($enDocLibName) -or 
									$list.Title.contains($heDocLibName)){
								
									$applicantsLists += $list.Title 
								}
					}
					$applicantsLists = $applicantsLists | sort -Unique
					#$applicantsLists 
					foreach($applList in $applicantsLists){
						write-host "Deleting... " $applList -f Magenta
						$ListForDel=$CtxArc.Web.Lists.GetByTitle($applList)
						$ListForDel.DeleteObject()
						$CtxArc.ExecuteQuery()
						write-host "Done." -f Yellow
						#read-host
						
					}
					<#
					$WebArc = $CtxArc.Web
					$ctxArc.Load($WebArc)
                    $CtxArc.ExecuteQuery()
					
					$ListsArc = $WebArc.Lists
					$CtxArc.Load($ListsArc)
                    $CtxArc.ExecuteQuery()

					$applicantsLists =  @()

					
					ForEach($list in $ListsArc){
								if ($list.Title.contains($enDocLibName) -or 
									$list.Title.contains($heDocLibName)){
								
									$applicantsLists += $list.Title 
								}
					}
					$applicantsLists = $applicantsLists | sort -Unique
					#$applicantsLists 
					foreach($applList in $applicantsLists){
						write-host "Deleting... " $applList -f Magenta
						$ListForDel=$CtxArc.Web.Lists.GetByTitle($applList)
						$ListForDel.DeleteObject()
						$CtxArc.ExecuteQuery()
						write-host "Done." -f Yellow
						#read-host
						
					}
					#>
				
				}
			}
		}			
    }
		Catch [Exception] {
		Write-host "************************"
		Write-host $_.Exception.Message -f Cyan
		Write-host "Error During Open Site" -f Yellow
      
    }   

 } 
    