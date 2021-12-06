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

 
 $siteURL = "https://scholarships.ekmd.huji.ac.il/home/General/GEN158-2021";
 $listName = "Oded Lowenheim"
 $fieldObj = @{DisplayName="Name"; Required=$FALSE; EnforceUniqueValues=$FALSE; ShowField="firstName"}
 $lookupListName = "applicants"
 		<#
1638: https://scholarships.ekmd.huji.ac.il/home/General/GEN158-2021, Oded Lowenheim, @{DisplayName=Name; Required=FALSE; EnforceUniqueValues=FALSE; ShowField=firstName}, applicants
Column Name already exists in the Oded Lowenheim!
#>


       $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
        $ctx.Credentials = $Credentials
         
        #Get the web, List and Lookup list
        $web = $Ctx.web
        $List = $Web.Lists.GetByTitle($listName)
        $lookupList = $Web.Lists.GetByTitle($lookupListName)
        $Ctx.Load($web)
        $Ctx.Load($list)
        $Ctx.Load($lookupList)
        $Ctx.ExecuteQuery()
		
        #Check if the column exists in list already
        $Fields = $List.Fields
        $Ctx.Load($Fields)
        $Ctx.executeQuery()
        $NewField = $Fields | where { ($_.Title -eq $($fieldObj.DisplayName))  }
		write-host "We are here"
		foreach ($f in $fields ){
			#$Ctx.Load($F)
			#$Ctx.executeQuery()
			
			if ($f.InternalName -eq "Name"){
				
 				write-host 54
				write-host $f.InternalName
				$f #|  ConvertTo-Json -Depth 100 | out-file $("JSON\Name-F-Field.json")
					
			}
		}
		read-host
        if($NewField -ne $NULL) 
        {
            Write-host "Column $($fieldObj.DisplayName) already exists in the $listName!" -f Yellow
        }
        else
        {
			$LookupListID= $LookupList.id
            $LookupWebID=$web.Id
			$DisplayName = $fieldObj.DisplayName
			$IsRequired = $fieldObj.Required
			$EnforceUniqueValues = $fieldObj.EnforceUniqueValues
			$LookupField = $fieldObj.ShowField
			
			#sharepoint online powershell create lookup field
            $FieldSchema = "<Field Type='Lookup'  DisplayName='$DisplayName'  Required='$IsRequired' EnforceUniqueValues='$EnforceUniqueValues' List='$LookupListID' WebId='$LookupWebID' ShowField='$LookupField' />"
			#write-host $FieldSchema
            $NewField = $List.Fields.AddFieldAsXml($FieldSchema,$True,[Microsoft.SharePoint.Client.AddFieldOptions]::DefaultValue)
            $Ctx.ExecuteQuery()   
 
            Write-host "New Column $($fieldObj.DisplayName) Added to the $listName Successfully!" -ForegroundColor Green 
 		
		}
  
 write-host "URL: $siteURL" -foregroundcolor Yellow


