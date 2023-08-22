function Add-ADGrpToSPGrp($siteUrl,$spGroupName,$adGroupName){
	#try{	
		$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
		$Ctx.Credentials = $Credentials
		
			#Get the Web and SharePoint Group
		$Web = $Ctx.Web
		$Group= $Web.SiteGroups.GetByName($spGroupName)
		$Ctx.Load($Group)
		$Ctx.ExecuteQuery()
		
		#$Group
		
		#Read-Host
		  
			#Resolve the AD Security Group
		$ADGroup = $web.EnsureUser($adGroupName)
		$Ctx.Load($ADGroup)
		$Ctx.ExecuteQuery()
	  

		#$Group
		
		#Read-Host

			#sharepoint online powershell add AD group to sharepoint group
		$Result = $Group.Users.AddUser($ADGroup)
		$Ctx.Load($Result)
		$Ctx.ExecuteQuery()
	  
		write-host  -f Green "Active Directory Group '$adGroupName' has been added to '$spGroupName'"
   	
   #}
   # Catch {
   #     write-host -f Red "Error:" $_.Exception.Message
   # }	
	return $null
}
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

start-transcript ADD-SCI-ADGrpToSPGRP.log

. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"
$Credentials = get-SCred

$Grps = 'SCI105-2022','SCI106-2022','SCI107-2022','SCI108-2022'

forEach ($grp in $Grps){
	$siteName = "https://scholarships2.ekmd.huji.ac.il/home/NaturalScience/"+$grp

	$spAdminGroupName  = "HSS_"+$grp+"_adminSP"
	$spJudgesGroupName = "HSS_"+$grp+"_judgesSP"
	
	$adAdminGroupName  = "HSS_"+$grp+"_adminUG"
	$adJudgesGroupName = "HSS_"+$grp+"_judgesUG"


	
	write-Host "SP Admin  Group: $spAdminGroupName"  -f Yellow
	write-Host "SP Judges Group: $spJudgesGroupName" -f Yellow
	write-host "-----------------" -f Cyan
	write-Host "AD Admin  Group: $adAdminGroupName"  -f Yellow
	write-Host "AD Judges Group: $adJudgesGroupName" -f Yellow
	write-host "-----------------" -f Cyan

	Write-Host "Site : $siteName" -f Green
	
    $siteUrl = get-UrlNoF5 $siteName
	Add-ADGrpToSPGrp $siteUrl $spAdminGroupName  $adAdminGroupName
	Add-ADGrpToSPGrp $siteUrl $spJudgesGroupName $adJudgesGroupName
    #read-host
}



stop-transcript