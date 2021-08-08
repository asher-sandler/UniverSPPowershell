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

$iniFile =  "$dp0\UserIni.json"


if (Test-Path $iniFile){
	$content = Get-Content -raw $iniFile
	$userObj=$content | ConvertFrom-Json
	write-host $userObj.UserName
	
	$regPath = "HKCU:\SOFTWARE\Microsoft\CrSiteAutomate"
	#set-location -path $regPath
	$passw = (Get-ItemProperty -Path $regPath -Name Param).Param | ConvertTo-SecureString
	# $passw = Get-Item -path "$regPath\Param" | ConvertTo-SecureString
	# $passw = $userObj.Password | ConvertTo-SecureString
	write-host $passw
	$siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";	
	$Credentials = New-Object System.Management.Automation.PSCredential ($userObj.UserName, $passw)
	
	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
	$ctx.Credentials = $Credentials
	
	#Get the Web
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery()
		
	$Web.Title
	set-location c:
	

}
else
{
	$location = Get-Location
	write-host "First need to create ini file": -foregroundcolor Yellow
	Write-Host "Enter UserName in domain ekmd:" -NoNewline  -foregroundcolor Yellow
	$UserName = Read-Host
	Write-Host "Enter Password:" -NoNewline -foregroundcolor Yellow
	$passw = Read-Host  -AsSecureString
	
	
	$userObj = "" | Select-Object UserName,Password
	$userObj.UserName = $UserName
	$userObj.Password = $passw | ConvertFrom-SecureString
	
	$regPath = "HKCU:\SOFTWARE\Microsoft\CrSiteAutomate"
	$testReg = Test-Path $regPath
	
	if (!$testReg){
		cd  HKCU:\SOFTWARE\Microsoft\ | out-null
		New-Item  -Name "CrSiteAutomate" | out-null
		New-ItemProperty -Path $regPath -Name "Param" -Value $($userObj.Password)  -PropertyType "String" | out-null
		
	}
	else{
		Set-Itemproperty -path $regPath -Name 'Param' -value $($userObj.Password) 
	}
	
	$userObj.Password = "[SECURE STRING]"
	
	$userObj | ConvertTo-Json -Depth 100 | out-file $($iniFile)
	Write-Host "INI file was created."
	set-location $location
	
}