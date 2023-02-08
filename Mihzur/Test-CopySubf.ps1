 Function Copy-SPFolder($srcSite, $dstSite, $listName,  $srcFolderURL, $dstFolderURL)
 {
		$dstweb = get-SPWeb $dstSite
		$dstList = $dstweb.Lists[$listName]
		#Write-Host "Destination List"$dstList.Title
		#$dstList = $dstweb.Lists[$docLibName]
		
		$srcweb = get-SPWeb $srcSite
		$srcList = $srcweb.Lists[$listName]

		write-host "srcFolderURL: "$srcFolderURL
		write-host "dstFolderURL: "$dstFolderURL
		read-host

        $SPFolder = $srcweb.GetFolder($srcFolderURL)
        ForEach ($sFile in @($SPFolder.Files))
        {
			$srcData = $sFile.OpenBinary()

			$srcDateCreat = $sFile.Item["Created" ]
			$srcDateEdit  = $sFile.Item["Modified"]
			$srcWhoCreat  = $sFile.Item["Author"  ]
			$srcWhoEdit   = $sFile.Item["Editor"  ]
			
			$dstSubDir = $dstList.ParentWeb.GetFolder($dstFolderURL);
			$dstFile   = $dstSubDir.Files.Add($sFile.Name,$srcData,$true)

			$dstFile.Item["Created" ] = $srcDateCreat
			$dstFile.Item["Modified"] = $srcDateEdit
			$dstFile.Item["Author"  ] = $srcWhoCreat
			$dstFile.Item["Editor"  ] = $srcWhoEdit

			$dstFile.Item.Update()
       }	

        ForEach ($SubFolder in @($SPFolder.SubFolders))
         {
            If($SubFolder.Name -ne "Forms") 
             {
				$fldCreated  = $SubFolder.Item["Created" ]
				$fldModified = $SubFolder.Item["Modified"]
				$fldAuthor   = $SubFolder.Item["Author"  ]
				$fldEditor   = $SubFolder.Item["Editor"  ]

				$dstSubDirName = $dstFolderURL + "/" +$SubFolder.Name
				$srcSubDirName = $srcFolderURL + "/" +$SubFolder.Name
				
				write-host "dstSubDirName :"$dstSubDirName
				write-host "srcSubDirName :"$srcSubDirName
				$dstSubDir = $dstList.ParentWeb.GetFolder($dstSubDirName);

				If(!$dstSubDir.Exists)
				{
					$fldDstNew = $dstweb.Folders.Add($dstSubDirName)
					
					$fldDstNew.Item["Created" ] = $fldCreated
					$fldDstNew.Item["Modified"] = $fldModified
					$fldDstNew.Item["Author"  ] = $fldAuthor
					$fldDstNew.Item["Editor"  ] = $fldEditor
					$fldDstNew.Item.Update();
					$fldDstNew.Update();
				}
				  
				Copy-SPFolder $srcSite $dstSite $listName $srcSubDirName $dstSubDirName 
             }
         }		
 } 
Function Copy-DocLibToDocLib ($srcSite, $dstSite ,$list){
	# Copy Source Lookup Fields  destination  Text
	$dstweb = get-SPWeb $dstSite
	$dstList = $dstweb.Lists[$list]
	#$dstList = $dstweb.Lists[$docLibName]
	$dstFolder 	   = $dstweb.GetFolder($dstList.RootFolder.Url)

	$srcweb = get-SPWeb $srcSite
	$srcList = $srcweb.Lists[$list]

   	$srcFolder 	   = $srcweb.GetFolder($srcList.RootFolder.Url)

    Write-Host "738 Copy From " $srcList.Title " TO " $dstList.Title 
    Copy-SPFolder -srcSite $srcSite -dstSite  $dstSite -listName $list -srcFolder $srcList.RootFolder.Url -dstFolder $dstList.RootFolder.Url

	return $null	
}
Add-PsSnapin Microsoft.SharePoint.PowerShell

$sSite = "https://gss2.ekmd.huji.ac.il/home/general/GEN27-2021" 
$dSite = "https://gss2.ekmd.huji.ac.il/home/general/GEN27-2021/Dst"
$list = "referencesPDF"

#Copy-DocLibToDocLib $sSite $dSite $list
$list = "Documents"
Copy-DocLibToDocLib $sSite $dSite $list



