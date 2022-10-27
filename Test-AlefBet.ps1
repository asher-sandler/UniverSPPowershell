function HebrewToLatin($phraseHeb){
	
	$abcHeb = "אבגדהוזחטיךכלםמןנסעףפץצקרשת"
	$abcLat = "abgdaozhtikklmmnnsappcckrst"
<#	
for($i=0;$i -lt $abcHeb.Length;$i++){
	write-host $abcHeb[$i]
	write-host $abcLat[$i]
	write-host --------
	
}
#>

$cnt = $phraseHeb.Length

$outPhraseLatin = ""
for($k=0;$k -lt $cnt;$k++){
	$symbl = $phraseHeb[$k]
	$idx = $abcHeb.IndexOf($symbl)
	if ($idx -ge 0)
	{
		$outPhraseLatin += $abcLat[$idx]
	}
	else
	{
		$outPhraseLatin += $symbl
	}
}

return $outPhraseLatin
}


$xH = 'האם צריך לבקש מכם או שמא זה אוטומטי – אפשרות לבחור את שנת תשפ "ג" בפרטי הקורסים בטופס זה: '
$xL =  HebrewToLatin $xH 
write-host $xL
<#
$x="א"
$y="ת"

$x1=[int][char]$x
$y1=[int][char]$y

write-host $x1
write-host $y1

$alefBet = 1488..1514
$sAlefBet = ""
foreach($otia in $alefBet){
    $sOtia = [char]$otia
	#write-host $sOtia
	#write-host $otia
	$sAlefBet += $sOtia
}

write-host $sAlefBet
write-host $sAlefBet.Length

$x="ב"
$y="ת"

$x1=[int][char]$x
$y1=[int][char]$y

write-host $x1
write-host $y1
#>