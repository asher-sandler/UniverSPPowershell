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

Start-Transcript "AddMembersToSpGroup.log"
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

	$Credentials = get-SCred

 if (!$(Test-Path ".\TSS_ARS10-2020_applicantsUG.csv")){
	$membersAD = Get-AdGroupMember TSS_ARS10-2020_applicantsUG
 }
 else
 {
	$membersAD = Import-Csv .\TSS_ARS10-2020_applicantsUG.csv 
 }
 
 $i=1
 $countW = 5 
 $siteName = "https://tss2.ekmd.huji.ac.il/home/ARS/ARS10-2020";
 $spGroupName = "ARS10_2020_Applicants_SP"
 $crlf = [char][int]13+[char][int]10
 
 write-host "Site: $siteName" -f Green
 write-host "SPGroupName:  $spGroupName" -f Green
 $UsersNotAdded = @()
 forEach ($member in $membersAD){
	 $userName = $member.SamAccountName
	 if ($member.distinguishedName.contains("hustaff")){
		 $userName = "cc\"+$member.SamAccountName
	 }
	 
	 write-host $userName -f Yellow
	 #write-host "Press key to continue..."
	 #read-host
	 #$UsersNotAdded += "User $i"
	 $UsersNotAdded += Add-MemberToSpGroup $siteName $spGroupName $userName
	 $i++
	 #if ($i -gt $countW){
	 #	 break
	 #}
 }
 $UsersNotAdded | Out-File -FilePath ".\UsersNotAdded.csv"  -encoding Default
 Stop-Transcript
 
