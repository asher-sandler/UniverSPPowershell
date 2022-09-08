Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
     
#Config Parameters
$SiteURL="https://gss2.ekmd.huji.ac.il/home/"
$ListName="availableGssList"
$BatchSize = 10
   
#Setup Credentials to connect
   
Try {
    #Setup the context
	$spWeb =  get-SPWeb $SiteURL -ErrorAction SilentlyContinue
    if ($spWeb){
		write-host " $currentSite was Opened" -f Magenta	
		$webTitle = $spWeb.Title
		write-host $SiteURL -f Yellow
		write-host $ListName -f Green

		write-host $webTitle -f Magenta
		$list = $spWeb.Lists[$ListName]
		Write-host "Total Number of Items Found in the List:"$List.ItemCount

		$query=New-Object Microsoft.SharePoint.SPQuery
		$query.ViewXML = "<View Scope='RecursiveAll'><RowLimit Paged='TRUE'>$BatchSize</RowLimit></View>"
   
		#Do { 
			#Get items from the list in batches
			$ListItems = $List.GetItems($Query)
			write-host  $ListItems.count
			ForEach($Item in $ListItems)
			{
				$lItem = $List.GetItemById($Item.Id) # .DeleteObject()
				$lItem.Title
			}
			<#
			#Exit from Loop if No items found
			If($ListItems.count -eq 0) { Break; }
	  
			Write-host Deleting $($ListItems.count) Items from the List...
	  
			#Loop through each item and delete
			ForEach($Item in $ListItems)
			{
				$List.GetItemById($Item.Id).DeleteObject()
			}
			$Ctx.ExecuteQuery()
	  
		} While ($True)
	  
		Write-host -f Green "All Items Deleted!"
		#>
	}
}
Catch {
    write-host -f Red "Error Deleting List Items!" $_.Exception.Message
}

