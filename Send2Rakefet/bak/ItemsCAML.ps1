# Add SharePoint Snapin
Add-PSSnapin "Microsoft.SharePoint.PowerShell"

# SSO Configuration
$siteUrl = "https://gss2.ekmd.huji.ac.il/home/SocialSciences/SOC23-2019"
# https://gss2.ekmd.huji.ac.il/home/SocialSciences/SOC23-2019/Final

<#
смотрим в папке пользрвателя
если дата изменеия файла больще - посылаем
если файла нет, смотрим дата изменеия списка

#>
# Connect to SharePoint site
$spWeb =  get-SPWeb $siteUrl

$spweb.AllowUnsafeUpdates = $true
$libraryName = "Final"

$library = $spweb.Lists | Where {$_.RootFolder.Name -eq $libraryName}

#[$libraryName]

#$library.Items | gm

# Build and execute the CAML query

$query=New-Object Microsoft.SharePoint.SPQuery
$query.ViewAttributes = "Scope='RecursiveAll'"
$query.Query = "<Where><Gt><FieldRef Name='Modified' /><Value IncludeTimeValue='TRUE' Type='DateTime'>2023-03-11T00:00:00Z</Value></Gt></Where>"

$items = $library.GetItems($query)

$items.Count
write-host Press any key...
read-host

# Loop through the retrieved items and display metadata
foreach ($item in $items) {
    $fileName = $item["FileLeafRef"]
    $createdDate = $item["Created"]
    $modifiedDate = $item["Modified"]
    
    Write-Host "File Name: $fileName"
    Write-Host "Created Date: $createdDate"
    Write-Host "Modified Date: $modifiedDate"
    Write-Host ""
}

# Dispose SharePoint objects
$spweb.Dispose()


