$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"

$siteOld= "https://gss2.ekmd.huji.ac.il/home/general/GEN28-2021"
$siteNew= "https://gss2.ekmd.huji.ac.il/home/general/GEN30-2021"

$content = get-OldDefault $siteOld
$contentNew =  repl-DefContent $siteOld $siteNew $content

$contentNew | out-file "defPage.html" -Encoding default