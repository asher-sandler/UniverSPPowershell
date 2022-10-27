function get-ScrptFullPath($scriptX ){
	$fileScr = get-Item $scriptX
	return $fileScr.DirectoryName
}
function Replace-Brackets($strInp){
	$braks = " ","(",")","[","]","{","}","/","\"
	$outStr = $strInp
	foreach($brkItm in $braks){
		$outStr = $outStr.Replace($brkItm,"")
	}
	return $outStr
}
$script=$MyInvocation.InvocationName

$srcrDir = get-ScrptFullPath $script
write-host $srcrDir

$utilExecPath = $srcrDir+"\Utils\MakeCab"

& $utilExecPath 


$inStr = "(972) abc  [ ] { } / \"

$xStr = Replace-Brackets $inStr

write-host $xStr




