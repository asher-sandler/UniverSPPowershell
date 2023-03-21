Start-Transcript DuplicateFiles.log
$dtBeg = Get-Date
Write-Host "Started on: " $dtBeg
$file_dublicates = Get-ChildItem –path c:\ -Recurse -ErrorAction SilentlyContinue | Where{$_.Length -gt 40Mb} | Group-Object -property Length

forEach($fl in $file_dublicates){
if (($fl.Count -gt 1) -and $fl.Name){
write-host --------------------------
Write-Host "Size: " $fl.Name
    $res = $fl |Select-Object –Expand Group| Get-FileHash | Group-Object -property hash #|
ForEach ( $grp in $res.group) { Write-Host $grp.Path}
write-host
#$res
}
}

$dtEnd = Get-Date
Write-Host "Finished on: " $dtEnd
Stop-Transcript