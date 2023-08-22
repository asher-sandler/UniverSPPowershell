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
start-transcript "Delete-UsersFromSPGroups.log"
$Credentials = get-SCred
$grList="GSS_GEN35-2022_applicants-agrSP,
GSS_GEN35-2022_applicants-appphysSP,
GSS_GEN35-2022_applicants-bioSP,
GSS_GEN35-2022_applicants-chemSP,
GSS_GEN35-2022_applicants-cseSP,
GSS_GEN35-2022_applicants-dntSP,
GSS_GEN35-2022_applicants-earthSP,
GSS_GEN35-2022_applicants-elscSP,
GSS_GEN35-2022_applicants-mathSP,
GSS_GEN35-2022_applicants-medSP,
GSS_GEN35-2022_applicants-pharmSP,
GSS_GEN35-2022_applicants-physSP,
GSS_GEN35-2022_applicants-psySP,
GSS_GEN35-2022_applicants-vetSP"


$grList="PRT_TAP_CSE13-2023_applicants-bscSP,PRT_TAP_CSE13-2023_applicants-phdSP,
PRT_TAP_CSE13-2023_applicants-mscSP"
 
 $siteName = "https://portals2.ekmd.huji.ac.il/home/tap/CSE/CSE13-2023";
 
 $siteUrl = get-UrlNoF5 $siteName

 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 $grpArr = $grList.Split(",")

 foreach($grpLine in $grpArr){
	 if (![string]::isNullOrEmpty($grpLine)){
		 $GroupName = $grpLine.Trim()
		 #$GroupName = "GSS_GEN35-2022_admin-agrSP"
		 Write-Host "GroupName: " $GroupName -f Yellow
		 Try{
			$Group=$Ctx.web.SiteGroups.GetByName($GroupName)
			$Ctx.Load($Group)
			$Ctx.ExecuteQuery()
	  
			#Get users of the group
			$GroupUsers = $Group.Users
			$Ctx.Load($GroupUsers)
			$Ctx.ExecuteQuery()
	  
			#Remove all users from the group
			ForEach($User in $GroupUsers)
			{
				if ($User.LoginName.Contains("prt_tap_cse13-2023")){
					continue
				}
				Write-Host "UserName: " $User.LoginName -f Yellow 
				write-host "Press any key to delete..."
				read-host
				$Group.Users.RemoveByLoginName($User.LoginName)
			}
			$Ctx.ExecuteQuery()
			Write-host "All Users are Removed from the '$GroupName'!" -ForegroundColor Green       
		}
		Catch {
			write-host -f Red "Error Removing All Users from Group!" $_.Exception.Message
		}		 
	 }
 }
 
 stop-transcript

