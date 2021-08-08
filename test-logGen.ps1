
$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$spObj = get-content .\JSON\HSS_AGR159-2021.json | ConvertFrom-Json

Log-Generate $spObj "https://scholarships.ekmd.huji.ac.il/home/agriculture/AGR159-2021" | Out-Null