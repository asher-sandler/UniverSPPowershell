param([string] $name = "1")
# $name = "טופל"

$resString = ""

for ($i = 0; $i -lt $name.Length ; $i++) {
	$cod =  $([int][char]$name[$i])
	$resString += "[char][int]" + $cod 
	If ($i -lt $name.Length-1){
		$resString += " + "
	}
	
}
write-host $resString