$fileName  = "..\Work\1\listekmd.csv"
$usersEKMD = Import-CSV $fileName
$userWrkArr = @()
foreach ($user in $usersEKMD){
	$usere = $user.UserName.Trim()
	$userx =  $(Get-ADuser $usere -Properties EmployeeID,LastLogonDate,DisplayName,LockedOut,Enabled,mail)
	
	$userObj = "" | Select Name, DisplayName,Email, ID, LogonDate,Locked,Enabled,GeYear
	$userObj.Name = $usere
	$userObj.DisplayName = $userx.DisplayName
	$userObj.ID = $userx.EmployeeID
	$userObj.LogonDate = $userx.LastLogonDate
	$userObj.Locked = $userx.LockedOut
	$userObj.Enabled = $userx.Enabled
	$userObj.Email = $userx.mail
	$userObj.GeYear = $false
	if ([string]::IsNullOrEmpty($userObj.LogonDate)){
		$userObj.GeYear = $true
	}
	else
	{
		$lastYearDate = $(Get-Date).AddYears(-1)
		if ($userObj.LogonDate -lt $lastYearDate){
			$userObj.GeYear = $true
		}
	}
	$userWrkArr += $userObj
	
}
$outFileName = "..\Work\1\listekmd-out.csv"
$userWrkArr | Export-CSV $outFileName -NoTypeInfo -Encoding UTF8
write-host "Press key..."
read-host
foreach($usex in $userWrkArr){
	If ($usex.GeYear){
		$targetUser = $usex.Name
		
		$ADObj=get-aduser  $targetUser -properties EmployeeID , description
		$employeeID=$ADObj.EmployeeID
		$newPwd =[string]$newPwd
		$newPwd=$employeeID
		write-host $targetUser
		Set-ADAccountPassword -identity $targetUser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $newPwd -Force)
		#read-host
	}
	if ($usex.Locked){
		Unlock-ADAccount -Identity $targetUser
	}
	if (!$usex.Enabled){
		Enable-ADAccount -Identity $targetUser
	}	
}