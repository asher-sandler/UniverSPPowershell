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
$SiteURL="https://ttp.ekmd.huji.ac.il/home/SocialSciences/SOC68-2021"

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
	$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$List = $Ctx.Web.lists.GetByTitle("ApplicantTemplate")

    $ViewFields = $List.DefaultView.ViewFields
	$View = $list.DefaultView
    $Ctx.load($ViewFields) 
    $Ctx.load($View) 
    $Ctx.ExecuteQuery()

$View.ViewQuery
read-host

$ModerationStatusExists = $($List.DefaultView.ViewFields).contains("_ModerationStatus");
write-host "Moderation Status Exists: $ModerationStatusExists" 
#$List.DefaultView.ViewFields
if ($ModerationStatusExists){
	   $List.DefaultView.ViewFields.Remove("_ModerationStatus")
       $List.DefaultView.Update()
       $Ctx.ExecuteQuery()
}

#$qryView = '<OrderBy><FieldRef Name="_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_" /></OrderBy>'
#$View.ViewQuery = $qryView
#$view.Update();
#$ctx.ExecuteQuery();

# not works in CSOM

#$FileName = "SCI72-2021"
#$TemplateName = "SCI72-2021"
#$list.SaveAsTemplate($FileName, $TemplateName, "", $false)  
#$ctx.ExecuteQuery() 


# $x= charToHeb $List.DefaultView.ViewFields[4]

#$x

       <#
	   
$FileName = "SCI72-2021"
$TemplateName = "SCI72-2021"
$list.SaveAsTemplate($FileName, $TemplateName, "", $true)  
$ctx.ExecuteQuery()  	   
	   
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
    	
