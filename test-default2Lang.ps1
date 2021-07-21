$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"


$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"

#$siteOld= "https://scholarships2.ekmd.huji.ac.il/home/Medicine/MED225-2020"
$siteNew= "https://scholarships2.ekmd.huji.ac.il/home/agriculture/AGR157-2021"

#$contentEn = get-OldDefault2Lang  $siteOld ""
#$contentHe = get-OldDefault2Lang  $siteOld "He"
write-host "He"
get-WPIdArray $contentHe

write-host "En"
$wpArray = get-WPIdArray $contentEn
$wpArray.count

#$contentEn = $contentEn.replace($wpArray[0],"")
$wpArray1 = Get-WPfromContent $contentHe
$wpArray1.count

$clearContentEN = Extract-ContentFromWPPage $contentEn

$clearContentHe = Extract-ContentFromWPPage $contentHe
$clearContentHe = (SwitchToEng "Default" $siteNew) + $clearContentHe
#$contentHe = $contentHe.replace($wpArray1[0],"")


$contentNew =  repl-DefContent $siteOld $siteNew $contentEn

$contentNew | out-file "defPageEn.html" -Encoding default

$contentNew =  repl-DefContent $siteOld $siteNew $contentHe

$contentNew | out-file "defPageHe.html" -Encoding default

$switcher = IS-SwitcherExists $clearContentHe
write-host "Is Switcher exists: $switcher"

$clearContentHe | out-file "defPageClearHe.html" -Encoding default
$clearContentEn | out-file "defPageClearEn.html" -Encoding default