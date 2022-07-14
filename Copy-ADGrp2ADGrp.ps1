write-host
write-host "This script copy AD members from Source AD Group  to destination AD Group" -f Green
write-host "Are you sure to continue [Y/n]?" -f Yellow -noNewLine
$continue = read-host  
if (($continue.length -eq 1) -and ([int][char]$continue -eq 89)){

    write-host "Enter Source      AD Group Name:   -->" -f Yellow -noNewLine
	[string]$srcGroupName=read-host
	write-host "Enter Destination AD Group Name:   -->" -f Yellow -noNewLine	
	[string]$dstGroupName=read-host 
	Write-Host "Copy AD Members from [" -f Yellow -noNewLine
	Write-Host $srcGroupName -f Cyan -noNewLine
	Write-Host "] to [" -f Yellow -noNewLine
	Write-Host $dstGroupName -f Cyan -noNewLine
	Write-Host "]" -f Yellow
	write-host "Press any key to begin process or CTRL^C to abort..." -f Yellow
	read-host
try{	
	$srcGrps =  Get-ADGroup -Filter {Name -eq $srcGroupName}
	$dstGrp  =  Get-ADGroup -Filter {Name -eq $dstGroupName}

	$srcMembers =  Get-ADGroupMember -Identity $srcGrps
	Add-ADGroupMember -Identity $dstGrp -Members $srcMembers
	write-host "$($srcMembers.Count) Members were copied." -f Yellow
	write-host "Done" -f Green
	}
catch{
	write-host "Something was wrong..." -f Yellow
	write-host "Probably Source or Destination group does not exists..." -f Yellow
	
	}
}
else
{
	write-host "You have to enter only [Y] to continue. Exiting."	 -f Yellow
}
write-host "Have a nice day ☺!" -f Cyan

