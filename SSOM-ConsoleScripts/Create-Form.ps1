$webUrl = "https://gss.ekmd.huji.ac.il/home/general/GEN27-2021/"
$web = get-spweb -Identity $webUrl
$Fruitlist = $web.Lists.TryGetList("Fruits")

$rootFolder = $Fruitlist.RootFolder;

$newFormUrl = [string]::Format("{0}/{1}/NewFormAlt.aspx", $web.ServerRelativeUrl, $rootFolder.Url);
$newForm = $web.GetFile($newFormUrl)
if ($newForm -ne $null -and $newForm.Exists){
    $newForm.Delete()   # delete & recreate our new form
}	

$newForm = $rootFolder.Files.Add($newFormUrl,  [Microsoft.SharePoint.SPTemplateFileType]::FormPage)
 
$Fruitlist.Update()