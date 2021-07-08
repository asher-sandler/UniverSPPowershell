function charToHeb($sName){
	
# $name = "טופל"

$aName = $sName.split("_x")
$rArray =  $aName |?{$_} # copy array
 #write-host $aName
 #write-host $rArray
[array]::Reverse($rArray)


$resString = ""
$reVerseString = ""

	for ($i = 0; $i -lt $aName.Count ; $i++) {
		if ([string]::isNullOrEmpty($aName[$i]))
		{}
		else
		{
			#write-host $aName[$i]
			
			$resString +=  [char]([convert]::toint16($aName[$i],16))
			
		}
	
	}
	
	for ($i = 0; $i -lt $rArray.Count ; $i++) {
		if ([string]::isNullOrEmpty($rArray[$i]))
		{}
		else
		{
			#write-host $rArray[$i]
			$reVerseString += [char]([convert]::toint16($rArray[$i],16))
			# $s = "" # $([char][int]$aName[$i])
		}
	
	}
	
	#write-host $resString
	#write-host $reVerseString
	$res = @()
	$res += $resString
	$res += $reVerseString
	return $res
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



$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"
$SiteURL="https://ttp.ekmd.huji.ac.il/home/Humanities/HUM24-2021"

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
	$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$List = $Ctx.Web.lists.GetByTitle("ApplicantTemplate")

    $ViewFields = $List.DefaultView.ViewFields
    $Ctx.load($ViewFields) 
    $Ctx.ExecuteQuery()

#$list.DefaultView	| gm
$List.DefaultView.ViewFields
# $x= charToHeb $List.DefaultView.ViewFields[4]

#$x

       <#
	   
Edit
DocIcon
LinkFilename
Created
_ModerationStatus
Document_x0020_Type



	   $List.DefaultView.ViewFields.Remove("zip")
        $List.DefaultView.Update()
        $Ctx.ExecuteQuery()
		#>


	<#

	
	
	$fieldToDel = "zip"
	$viewFields = $view.ViewFields 
	$ctx.load($viewFields)
	$ctx.executeQuery()
	
	#if($ViewFields.ToStringCollection().Contains($fieldToDel)){
		$view.ViewFields.delete("zip")
		$View.Update()
		$ctx.executeQuery()
	#}
	#>




	#$viewFields 
    	
