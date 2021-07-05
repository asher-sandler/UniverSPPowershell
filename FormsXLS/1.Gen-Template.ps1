param(
	[Parameter(Mandatory=$true)]
	[string[]]$FileName = ""
)

function Kill-Word()
{

            Start-Sleep 5

            #read-Host Press a key... 1

            $wordCount = @(Get-Process winword -ea 0).Count
            
            #"Word process 2: {0}" -f $wordCount
            if ($wordCount -gt 0)
            {
                     $noOutput = Stop-Process -Name WinWord
            }
            #read-Host Press a key... 2

            #"Word process 3: {0}" -f @(Get-Process WinWord -ea 0).Count

       


}

function Add-Header($fileName){
	$fContent = get-Content $fileName
	$itemFile = get-Item $fileName
	
	$outContent = @()
	$outContent += ""
	$outContent += "; Markup language for form generator"
	$outContent += "; Hebrew University of Jerusalem"
	$outContent += "; All rights reserved"
	$outContent += "; Author : Asher Sandler"
	$outContent += ";"
	$outContent += "; ./dh   - docHeader <docHeader></docHeader>"
	$outContent += "; ./e    - end of control sequence"
	$outContent += "; ./h    - header (<row><Header></Header></row>)"
	$outContent += "; ./ri   - row input"
	$outContent += "; ./rt   - row text"
	$outContent += "; _____  - input field block"
	$outContent += "; ./rb    - radio button"
	$outContent += '; ./th    - table header divided by "|"'
	$outContent += '; ./mi    - text divided by "|" in various columns and input'
	$outContent += "; ./ti r:10 c:3  - table input 10 rows, 3 columns"
	$outContent += "; ./cb   - checkbox"  
	$outContent += "; ./mtb   - Multi Line Text Box"  
	$outContent += ";"
	$outContent += ";"
	$outContent += ";"
	$outContent += "; ==================   Date Template ===================="
	$outContent += ";"	
	$outContent += ";	<control>"
	$outContent += ";		<Type>TextBox</Type>"
	$outContent += ";		<Data>date001</Data>"
			
	$outContent += ";		<width>100</width>"
	$outContent += ";		<regex>^($|(((0[1-9]|[12][0-9]|3[01])\/(0[13578]|1[02])\/((19|[2-9][0-9])[0-9]{2}))|((0[1-9]|[12][0-9]|30)\/(0[13456789]|1[012])\/((19|[2-9][0-9])[0-9]{2}))|((0[1-9]|1[0-9]|2[0-8])\/02\/((19|[2-9][0-9])[0-9]{2}))|(29\/02\/((1[6-9]|[2-9][0-9])(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)))))$</regex>"
	$outContent += ";		<tooltip>DD/MM/YYYY</tooltip>"
	$outContent += ";		<required>yes</required>"
	$outContent += ";	</control>"
	
	$outContent += ";"
	$outContent += ";=================== Teudat Zeut Template ==============="
	$outContent += ";	<row>"
	$outContent += ";"
	$outContent += ";			<Label>"
	$outContent += ";				<text>ת.ז.</text>"
	$outContent += ";				<width>95</width>"
	$outContent += ";			</Label>"
	$outContent += ";		<control>"
	$outContent += ";			<Type>TextLabel</Type>"
	$outContent += ";			<Data>studentId</Data>"
	$outContent += ";			<width>150</width>"
	$outContent += ";		</control>"
	$outContent += ";	</row>"	
	$outContent += ";========================================================"
	$outContent += ";"	
	$outContent += ""	
	foreach($line in $fContent){
		$outContent += $line		
	}
	
	$fileNameOut =  "Work\$($itemFile.BaseName).txt"
	If (Test-Path $fileNameOut){
		write-host "Template File $fileNameOut already exists. OverWrite is not allowed!"
	}
	else{
		$outContent | out-file  -filepath "Work\$($itemFile.BaseName).txt" -encoding UTF8
		write-host "Template  File Saved to Work\$($itemFile.BaseName).txt"
	}


  
}

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
write-host "Read file $FileName"

$wordItem = get-Item $fileName
write-host Open MS Word. Please wait...

Kill-Word


$Word=NEW-Object –comobject Word.Application
Start-Sleep 5

$Document=$Word.documents.open($wordItem.FullName)
Start-Sleep 5

$outputName = $dp0+"\Temp\$($wordItem.BaseName).txt"
# write-host Saving file $outputName. 
# write-host Please wait...
$def = [Type]::Missing
#$Document.SaveAs($outputName, 2, $false, $null, $false, $null, $false,$false, $false, $false, $false, 1255, $false, $false, $null, $false, $null)  # 2- Microsoft Windows text format
$Document.SaveAs(
		#ref Object FileName,
        [ref] $outputName, 
        #ref Object FileFormat,
        [ref] 2, 
        #ref Object LockComments,
        $def,
        #ref Object Password,
        $def,
        #ref Object AddToRecentFiles,
        $def,
        #ref Object WritePassword,
        $def,
        #ref Object ReadOnlyRecommended,
        $def,
        #ref Object EmbedTrueTypeFonts,
        $def,
        #ref Object SaveNativePictureFormat,
        $def,
        #ref Object SaveFormsData,
        $def,
        #ref Object SaveAsAOCELetter,
        $def,
        #ref Object Encoding,
        65001
        #ref Object InsertLineBreaks,
        #ref Object AllowSubstitutions,
        #ref Object LineEnding,
        #ref Object AddBiDiMarks
    )


$document.close()
$Word.quit()

Kill-Word

Add-Header $outputName

Write-Host Done.


