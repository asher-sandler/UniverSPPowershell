param (
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

# Get the contents of the file
$fileContent = Get-Content $FilePath

$functionNames = @()
    $inFunctionBlock = $false
    foreach ($line in $fileContent) {
        if ($line.TrimStart().ToLower().StartsWith("function ")) {
            # We've found the start of a new function definition
            $functionLine = $line.Trim()
            $functionName = $functionLine.Substring(9).Split("(")[0]
            $functionNames += $functionName
            $inFunctionBlock = $true
        } elseif ($inFunctionBlock -and $line.Trim() -eq "}") {
            # We've found the end of the function definition
            $inFunctionBlock = $false
        }
    }

#$functionNames = $functionNames | Sort
$functionDefinition = Get-Content $FilePath -raw

foreach ($functionName in $functionNames) {
    $startIndex = $functionDefinition.IndexOf("function $functionName") + ("function $functionName").Length
	$endIndex = $startIndex
    $openBraces = 0
    for ($i = $startIndex; $i -lt $functionDefinition.Length; $i++) {
		#Write-Host "openBraces : " $openBraces
        if ($functionDefinition[$i] -eq "{") {
            $openBraces++
        } elseif ($functionDefinition[$i] -eq "}") {
            $openBraces--
            if ($openBraces -eq 0) {
                $endIndex = $i
                break
            }
        }
    }
	#Write-Host 42
	#read-host
    $fDefinition = $functionDefinition.Substring($startIndex, $endIndex - $startIndex).Trim()
    #$functionName
	#$startIndex
	#$($endIndex - $startIndex)
    #$fDefinition
	#Read-Host 43
    if ($fDefinition.Contains("<#")) {
        $startIndex = $fDefinition.IndexOf("<#") + 2
        $endIndex = $fDefinition.IndexOf("#>") - 1
        $comment = $fDefinition.Substring($startIndex, $endIndex - $startIndex).Trim()
		if ($comment.Contains(".SYNOPSIS")){
			Write-Output $functionName
			Write-Output *******************************
			Write-Output "$functionName`n$comment`n"
			Write-Output *******************************
			
		}
    }
}
