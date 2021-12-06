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
Function Get-ParentLookupID($siteURL,$ParentListName, $ParentListLookupField, $ParentListLookupValue)
{
	$ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext(get-UrlNoF5 $siteURL)
    $ParentList = $Ctx1.Web.lists.GetByTitle($ParentListName)
 
    #Get the Parent List Item Filtered by given Lookup Value
    $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
	$qry = "<View Scope='RecursiveAll'><Query><Where><Eq><FieldRef Name='$($ParentListLookupField)'/><Value Type='Text'>$($ParentListLookupValue)</Value></Eq></Where></Query></View>"
	#write-host $qry
    $Query.ViewXml=$qry
	
    $ListItems = $ParentList.GetItems($Query)
    $Ctx1.Load($ListItems)
    $Ctx1.ExecuteQuery()
	Write-Host $ListItems.count -f Magenta
    
    #Get the ID of the List Item
    If($ListItems.count -gt 0)
    {
        Return $ListItems[0].ID #Get the first item - If there are more than One
    }
    else
    {
        Return $Null
    }
}


#Read more: https://www.sharepointdiary.com/2017/03/sharepoint-online-powershell-to-update-lookup-field.html#ixzz7DsNK0wXO
$Credentials = get-SCred

 
 $siteURL = "https://grs2.ekmd.huji.ac.il/home/Agriculture/AGR13-2021";
 
 
 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 $listNameAppl = "Applicants"
 $ApplList = get-allListItemsByID $siteURL  $listNameAppl
 
 $Students = @()
 ForEach($AppItem in $ApplList){
	 $studentItem = "" | Select FirstName, SurName, Email
	 $studentItem.Email =  $AppItem["email"] 
	 $studentItem.FirstName =  $AppItem["firstName"] 
	 $studentItem.SurName =  $AppItem["surname"] 
	 $Students += $studentItem
	 
 }
 
 #Write-Host 62
 $listNameOver = "Overseas Applicants Unit"
 $newListSchema = get-ListSchema $siteURL $listNameOver
 $newListSchema | ConvertTo-Json -Depth 100 | out-file $("JSON\Overseas-ApplFields.json")
	
 $OversList = get-allListItemsByID $siteURL  $listNameOver
 $StudentsOverS = @() 
 ForEach($OverItem in $OversList){
	 $OversItem = "" | Select ID, FullName, Email
	 $lookupEmail = [Microsoft.SharePoint.Client.FieldLookupValue]$OverItem["e_x002d_mail"] 
	 $OversItem.Email =  $lookupEmail.LookupValue
	 $OversItem.FullName =  $OverItem["FileLeafRef"] 
	 
	 $OversItem.ID =  $OverItem.Id 
	 
	 <#
     $ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext(get-UrlNoF5 $siteURL) 
	 $ctx1.Credentials = $Credentials
	
	 $list1 = $Ctx1.Web.lists.GetByTitle($listName)
	
	 $item1 = $list1.GetItemById($OversItem.ID)
	 $Ctx1.Load($Item1)
     $Ctx1.ExecuteQuery()
     $OversItem.Email = $item1["e_x002d_mail"] 
	 #>
	 
	 $StudentsOverS += $OversItem
	 
 }
 
  forEach($overStudent in $StudentsOverS){
	  $FullNameOver = $overStudent.FullName.Split(".")[0]
	  $overEmail = $overStudent.Email
      if ([string]::isNullOrEmpty($overEmail)){	  
	    $studentFound = $false
		forEach($Student in $Students){
			$FullNameStudent = $Student.FirstName + " "+ $Student.SurName
			if ($FullNameStudent -eq $FullNameOver){
				$EmailParentID = Get-ParentLookupID $siteURL $listNameAppl "email" $Student.Email
				#Write-Host "$EmailParentID , $FullNameOver" -f Cyan
				Write-Host $FullNameOver -f Cyan
				$ctx2 = New-Object Microsoft.SharePoint.Client.ClientContext(get-UrlNoF5 $siteURL) 
				$ctx2.Credentials = $Credentials
	
				$list1 = $Ctx2.Web.lists.GetByTitle($listNameOver)
	
				$item1 = $list1.GetItemById($overStudent.ID)
				$Ctx2.Load($Item1)
				$Ctx2.ExecuteQuery()
				$item1["e_x002d_mail"] = $EmailParentID	
				$item1.Update()
				$Ctx2.ExecuteQuery()				
				$studentFound = $true
				#read-host
				break
			}
		}
		if (!$studentFound){
			#Write-Host "$FullNameOver Not Found in Applicants" -f Yellow
		}
	  }
	  
  }
  #$StudentsOverS 
  
  #$OversList | fl
 
  
  


