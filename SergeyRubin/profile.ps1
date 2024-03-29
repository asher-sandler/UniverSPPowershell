################  profile.sp1 DO NOT CHANGE THIS FILE ###########################
# this is the general profile file for helpdesk and above                                #
# this is the all local users default profile                                            #
# this is good for all user and environments (hosts) ie: PS ISE and shell                #
# the first line loads the common central module for EKCC PS scripts                     #
#                                                                                        #

[string]$psvMajor  = $Host.Version.Major
[string]$psMinor   = $Host.Version.Minor
$PSVersion         = $psvMajor + "." +  $psMinor
$Host.UI.RawUI.WindowTitle = "-- Beginning Load of Shell <profile.ps1>  PS $PSVersion"

# map s: if needed
if ((test-path s:\) -eq $false) {new-psdrive S FileSystem \\ekekdc04\netlogon\ekcc\system_scripts}
cd s:

#set color functions
#region colors
function yellow {$Host.UI.RawUI.foregroundcolor="yellow"}
function red    {$Host.UI.RawUI.foregroundcolor="red"}
function white  {$Host.UI.RawUI.foregroundcolor="white"}
function green  {$Host.UI.RawUI.foregroundcolor="green"}
function blue   {$Host.UI.RawUI.foregroundcolor="blue"}
Set-Alias -Name g -Value green
Set-Alias -Name w -Value white
Set-Alias -Name y -Value yellow
Set-Alias -Name b -Value blue

function bgBlue   {$Host.UI.RawUI.backgroundcolor="blue"}
function bgBlack  {$Host.UI.RawUI.backgroundcolor="black"}
function bgGreen  {$Host.UI.RawUI.backgroundcolor="green"}
function bgyellow {$Host.UI.RawUI.backgroundcolor="yellow"}
function bgred    {$Host.UI.RawUI.backgroundcolor="red"}
Set-Alias -Name bb  -Value bgblue
Set-Alias -Name bbl -Value bgblack
Set-Alias -Name bg  -Value bggreen
Set-Alias -Name by  -Value bgyellow
Set-Alias -Name br  -Value bgred

#endregion

$WarningPreference = "SilentlyContinue"

$Host.UI.RawUI.WindowTitle = " -- Loading helpdesk level and above Modules -- PS $PSVersion"
sleep -Seconds 1	
# loading modules,  this is for everyone helpdesk level and above
get-module -ListAvailable | import-module -WarningAction SilentlyContinue 

# increasing def shell memory
$shellMem=(get-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB).value
if ([int]$shellMem -lt 1024) {set-Item "WSMan:\localhost\Shell\MaxMemoryPerShellMB" 1024} #else {y;"Shell Memory =>1024";w}


#region Remoting Exchange
# using the loged on user credentials
$Host.UI.RawUI.WindowTitle = " -- Importing Exchange cmdlets -- PS $PSVersion"
$a="ekekmbx00","ekekmbx01"
#$targetServer	= get-randomserverx $a
$random 		= Get-Random -Minimum 0 -Maximum 2
$targetServer 	= $a[$random]
#"connectionUri 	= http://$targetServer.ekmd.huji.uni/PowerShell/"
$connectionUri 	= "http://$targetServer.ekmd.huji.uni/PowerShell/"
$myXPss 		= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $connectionUri #-WarningAction SilentlyContinue #-Authentication Kerberos
$a				= import-pssession $myXPss #-ErrorAction SilentlyContinue -WarningAction SilentlyContinue -AllowClobber
y;bb
"Target`t`tServer`t`tPersistent Session Name"
"Exchange`t$targetServer`t"+'$myXPss'
w
#endregion


##########################################################################################                                                          

#region filesx_master
####################################################################
#               NEW.....
# contains all aliases, variables and modules to be loaded accept the colors that were loaded on top
# and functions I collect for systemgrp and helpdesk
# Roy Shapira June, 2013
###########################

#region prepare window
$now=(get-date).ToString()
$Host.UI.RawUI.WindowTitle = "$now -- Loading Functions, Preferences and Aliases -- PS $PSVersion"
w; bb #;"Loading Common Shell Environment"

#endregion

############## filters block ####################
#region filters 
filter DN   {$_.distinguishedname}
filter sam  {$_.samaccountname}
filter name {$_.name}
filter sid  {$_.sid.value}
filter guid {$_.objectguid.value}
filter CN   {$_.CN}
filter NameFromDN {%{($_ -replace "CN=" -split ",",2)[0]}}
#endregion filters

################ PS preferences ##################################
$PSEmailServer = "ekekcas01.ekmd.huji.uni"
  # 132.64.169.175

#region VARIABLES and CONSTANTS
#Set-Variable -Name ouCode -Scope global
$web = New-Object Net.WebClient 
$ekekdc04      	= "CN=EKEKDC04,OU=Domain Controllers,DC=ekmd,DC=huji,DC=uni"
$ekekdc05      	= "CN=EKEKDC05,OU=Domain Controllers,DC=ekmd,DC=huji,DC=uni"
$timeStampForm 	= "dd-MMM-yyyy@HH-mm-ss"
$whoami		   	= $env:username
$logonDC		= ($env:logonserver).remove(0,2)
$HostName		= $env:computername
$seperator		= "="*60
$inputFilePath	= "\\ekekfls00\data$\scriptFolders\DATA"
$dataFilePath	= "\\ekekfls00\data$\scriptFolders\DATA"
$logFilePath	= "\\ekekfls00\data$\scriptFolders\LOGS"
$logfileName	= "c:\temp\tempLogFileName.log"
$doNotReply		= "do-not-reply@ekmd.huji.ac.il"
$helpdesk		= "helpdesk@ekmd.huji.ac.il"
$systemgrp		= "systemgrpug@ekmd.huji.ac.il"
$ekcc			= "ekcc@ekmd.huji.ac.il"
$roys			= "roys@ekmd.huji.ac.il"
#endregion VARIABLES and CONSTANTS


#region FUNCTIONS


##################################
function sendHebMail($textBody,$target)
# accepts a hash input that plugs into place
# caller code must call function as per example below

#$a=@"
#<div>שלום רועי</div>
#<br></br>
#<div>חשבון זה נפתח לפי בקשתך מיום ___ ומשעה ___</div>
#<div>שם המשתמש שלך (באנגלית) הוא:  ZXCVB</div>
#<div>סיסמתך הראשונית היא (העתק מה שבין הסוגריים המרובעים) [GHKGGKJ]</div>
#<div>לפתיחת או ניהול תא סטודנטים גשו אל: </div>
#<div>להגשת מועמדות למלגות גשו אל: </div>
#<br></br>
#<div>להרשמה לתארים מתקדמים ותכניות מיוחדות גשו אל: </div>
#<br></br>
#<div>זהו דואר ממוכן - אין לענות לו ישירות </div>
#"@

#sendHebMail $a

{
$newtext=@"
<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="utf-8" />
<title></title>
</head>
<body>
<div style="direction:rtl;font-family:Courier New;">

$textBody

<div>לתמיכה טכנית בנוגע לחשבון זה, בלבד פנו אל: helpdesk@ekmd.huji.ac.il </div>
</div>
</body>
</html>

"@

try
 {
  Send-MailMessage  -Encoding ([system.Text.Encoding]::UTF8)  -To $target -From $doNotReply -cc $helpdesk -Subject "חשבון חדש נפתח עבורך" -body $newtext -BodyAsHtml -erroraction  Stop
  g;"Successfuly sent Hebrew mail";w
 }
catch
 {
   red;"Failed Hebrew mail Send `n$error[0]";w
 }

}

##################################


##################################
function get-NameFromCanonicalName ($CanonName)
{
 [array]$tmp = $CanonName.Split("/")
 $length	 = $tmp.Length
 $cell		 = $length-1
 $tmp[$cell]
}
##################################
function setConsole ($newHeight=40,$newWidth=100)
# set the console to any size so buffer and window size are same
# remember to record these values before if u want at end of callinf acript
# to return to prev values
{
 # Verify values
 if($newHeight -lt 10 -or $newHeight -gt 60) {$newHeight=40}
 if($newWidth  -lt 40 -or $newWidth -gt 130) {$newWidth=100}
  
 $WindowHeight	= [console]::WindowHeight       # the height of the console window area
 $WindowWidth	= [console]::WindowWidth 		# the width of the console window
 # buffer set to large values
 $newBufferWidth  = 150  #$WindowWidth
 $newBufferheight = 1000 #$WindowHeight
 # create a very large  buffer
 $host.UI.RawUI.BufferSize = new-object System.Management.Automation.Host.Size($newBufferWidth,$newBufferheight)
 # set window - this will be smaller then buffer for sure
 $host.UI.RawUI.WindowSize = new-object System.Management.Automation.Host.Size($newWidth,$newHeight)
 # then change the buffer to fit window
 $host.UI.RawUI.BufferSize = new-object System.Management.Automation.Host.Size($newWidth,$newHeight)
 
} 
##################################
function rmv-exceptions ($originalList,$myExceptionList,$silent=1)
{
 $cleanList   = New-Object system.Collections.ArrayList
 foreach ($item in $originalList)
  {
   if (($myExceptionList.contains($item.tolower()) -eq $false))   # if name is NOT in exceptions list
    {$nullString=$cleanList.add($item)}                         # so will not echo index to console
  }
 return $cleanList
}
##########################################################
function cleanServersList ($serverExceptions="")
{
if ($serverExceptions -eq "")
 {
  $serverExceptions = ("ekekdag01","ekekdd620","ekekcls04","ekekcls02","ekekocs00","EKEKCLS01DHCP","EKEKSQL00","EKEKFLS00").tolower() 
 }
# get list of servers
$beforeServersList   = (Get-ADComputer -Filter 'name -like "ekek*"').name # wrong type
$beforeCount         = $beforeServersList.count
$afterServersList    = rmv-exceptions $beforeServersList $serverExceptions
$afterCount=$afterServersList.count
# in calling code
# $array[0] is list
# $array[1] is BEFORE
# $array[2] is AFTER
return $afterServersList,$beforeCount,$afterCount
}
##########################################################
function WriteToPos ([string]$inputStr, [int]$x = 0 , [int]$y = [console]::CursorTop, [string]$bgc = [console]::BackgroundColor, [string]$fgc = [Console]::ForegroundColor)
 # get current position and color
 # from: http://blogs.technet.com/b/heyscriptingguy/archive/2010/03/26/hey-scripting-guy-march-26-2010.aspx
 # small change as i want this to write in the current position and NOT in absolut coordinate in original y=0 is def
{
 if(($x -ge 0) -and ($y -ge 0) -and ($x -le [Console]::WindowWidth) -and ($y -le [Console]::WindowHeight)) 
  {
   $saveY = [console]::CursorTop
   $offY  = [console]::WindowTop        
   [console]::setcursorposition($x,$offY+$y)
   #[console]::write($inputStr)
   Write-Host -Object $inputStr -BackgroundColor $bgc -ForegroundColor $fgc -NoNewline
   [console]::setcursorposition(0,$saveY) 
  }
  $inputStr=$null;$y=$null;$x=$null;$bgc=$null;$fgc=$null;$saveY=$null;$offY=$null
}

##############################################################
#function get-servers
# i do not know how to keep type on caller
# {
#   # so we can easily use add and remove
#   $srvList=New-Object system.Collections.ArrayList
#   $srvList=(Get-ADComputer -Filter{name -like "ekek*"}).name
#   return $srvList
# }


###############################
function isMember($targetUser, $targetUG) # needs special permissions
{
  $DN=getdnx $targetUG
  try
  {
   (Get-ADUser $targetUser -Properties memberof).Memberof -like $DN -as [bool]
   #$grp=Get-ADPrincipalGroupMembership $targetUser -ea stop | name 
   #$grp=Get-ADAccountAuthorizationGroup $targetUser -ea stop | name   TOO LONG
   #$grp=Get-ADgroupmember $targetUG -ea stop | name  ONLY domain admin
   #foreach ($usr in $grp) {if ($usr -eq $targetUG){return $true} } 
  }
  catch 
   {return $false } #"error in ismember $targetUser $targetUG"}
}  #### functions needed early

###############################
function folderexist ($folderpath)
 {
  if ($folderPath -eq $null) {return $false}
  try
  {
   $a=new-item -path $folderPath -type file -name "delme.txt" -value "this file can safely be deleted" -ea stop
  }
  catch
  {
   $err=$error[0].exception.message
   if ($err.contains("Could not find a part of the path") -eq $true) {return $false}
  }
  return $true
 }
############################
function loadPssnapin {Add-PSSnapin Microsoft.SharePoint.Powershell}
############################
function localHostName {$env:computername}
############################
function isDate($Value) { ($Value -as [DateTime]) -ne $null }
############################
function isIP($Value) { ($Value -as [System.Net.IPAddress]) -ne $null -and ($Value -as [Int]) -eq $null }
############################
function getoux ($targetOU,$recurse=$true)
{
$myhelp=@"
 Returns list of OUs
 Usage: getoux targetou [name] recurse [True or False] present [True or False]
 where: targetou is the name of the ou
        recurse true will recurse and false will Not
		present true will show on screen and false will return list of OU names to caller
 Examples:
 		getoux ekusers true true
		getoux ekservers false true
"@
if ($targetOU -eq $null) {y;$myhelp;w;break}
w
$cntRecursion++
$targetOuDN   = getdnx $targetOU # may return an array!
#getting the first OU value"
foreach ($item in $targetOuDN){if ($item.startswith("OU=")){$targetOuDN=$item}}
$pad=" "*$cntRecursion
$listOUs=(Get-ADOrganizationalUnit -SearchBase $targetOuDN -searchscope onelevel -filter *).name | sort 
#| where {$_ -notlike $targetOU}
if ($recurse)
 {
 foreach ($ou in $listOUs)
  {
   "$pad$ou"
   getoux $ou #$recurse
  }
 }
 else {$listOUs}
}
############################
function myround ($number,$digits=2)
{
 [decimal]$number=$number
 return ([Math]::Round($number,$digits))
}
############################
function cap ($sentence)
 {
  return (get-culture).textinfo.TotitleCase($sentence)
 }
############################
function createUniqueUserName ($newGN,$newSN)
{
 $a=$newSN.length
 set-variable -Name cntStep -value 0
 for ($i=0;$i -le ($newSN.length)-1;$i++) 
 { 
  $suffix+=$newSN[$i]
  $newN=$newGN+$suffix
  $result=Get-ADuser -Filter 'CN -eq $newN' 
  If ($result -ne $null) {} # found such a username - continue
  else  # no such user so this is a good name and we exit
  {
   #log "$newN IS Unique in AD" $logFileName
   return ($newN).tolower()
  }
 } # end of for
} 

############################
function VerifyUserEnabled ($targetObj,$holdTime=10)
# holds execution til AD obj is found and enabled on both DCs, each tick is 500 msec
# if no go after holdTime in seconds then aborts with a negative
{
 $tick=500 # mSec
 $limit=$holdTime/ ($tick/1000)
 y
 while ($true)
 {
  sleep -Milliseconds 500
  write-host -NoNewline "."
  try {$a=(get-adobject -Server "ekekdc05" -Identity  $targetObj).enabled} catch {}
  try {$b=(get-adobject -Server "ekekdc04" -Identity  $targetObj).enabled} catch {}
  if(($a -eq $true) -and ($b -eq $true)){"`n";w;return $true}
  $cntTime =($cntTime+($tick/1000))  # in mSecs
  if ($cntTime -eq $limit){"`n";w;return $false}
 }
 w
}
##########################################
 function isURL ($targetURL, $auth=$false)
 # connect to target URL, returns true if site is up or false if site is down
 #if $auth-= TRUE then tries to auth
{
 #$web = New-Object Net.WebClient
 Try
  {
	$result = $web.DownloadString($targetURL)
    return $true
  } 
 Catch
   {
    return $error[0].exception #$false
   } 
}  # end of function
######################################### 
 function isNumber ($target)
 {try {[int]$target=$target; return $true} catch {return $false}}
##########################################
function abs ($num) {[math]::abs($num)}
# returns an absolute val

##########################################
function isEven ($num){[bool]!($num%2)}
# true if number is even: 2,4,6..

##########################################
#region pwdx 
function pwdx($targetUser="",$newPwd="")
{
# updated 29 aug 2012 to fix description new format
############### begin script########
$myHelp=@"
 Used to change the user pwd, enable account, fix description and return mailbox to DB defaults.
 You will be asked if you want to reset to NID or gen a new random password
"@
#region 
function setpwd ($targetUser,$newPwd)
{
 try
 {
  Set-ADAccountPassword -identity $targetUser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $newPwd -Force)
  y;"Password set to <$newPwd>";w
 }
 catch
  {
   $err=$Error[0].exception
   $txt="Failed to set password to <$newPwd>`n$err"
   red;$txt;w
  }
}

#endregion
if ($targetUser -eq "") {scriptDetails($MyInvocation.mycommand.name);$myHelp;w} 

 else # act
 {
  try {$ADObj=get-aduser  $targetUser -properties EmployeeID, description}   # get employeeid
  catch {y;"NO such USER - Aborting";w;break}	
  $user			= $ADObj.name
  $employeeID	= $ADObj.EmployeeID
  $description	= $ADObj.description
  #"$user $employeeID $description" 
  #p2c
  if($description -ne $null)
  {
  if ($description.contains("||"))
  {
   $newDescription = ($description.split("||"))[0]          # change for new format 28-aug-2012
   try
    {
     $result = adAttrEditx $user description $newdescription
     if($result -eq $true){g;" Successfuly recovered Description to <$newDescription>";w} else {red;" Failed to change Description";w}
    }
   catch
    {
	
    }
  }
  else
   {
    "Account is NOT disabled for inactivity - description NOT fixed"
   }
   
   } # end description code
  try   {Enable-ADAccount -Identity $targetUser;g;" Account Enabled";w}  # enable the acount
  catch {red;"Failed to ENABLE Account";w}
  try   {Unlock-ADAccount -Identity $targetUser;g;" Account Unlocked";w}  # unlock the account
  catch {red;"Failed to UNLOCK Account";w}
  if ((getmailusertype $targetUser) -eq "UserMailbox")
  {
   try   {set-mailbox -identity $targetUser  -UseDatabaseQuotaDefaults $true -WarningAction silentlycontinue;g;" Account set to use Exchange MB Defaults";w}
   catch {red;"failed to set MailBox dataBase to defaults";w}
   try   {set-mailbox -identity $targetUser  -MaxSendSize unlimited -WarningAction silentlycontinue;g;" Account can send mail";w}
   catch {red;"failed to set MailBox to allow sends";w}
  }

  $newPwd =[string]$newPwd # !!! important
  $newRndPwd=genpwdx 8
  if ($newPwd -eq "")  # ie only user name given
   {
	"1) Reset PWD to National Identity <$employeeID>"
	"2) Reset PWD to random password   <$newRndPwd>"
	"3) exit"
	$ans=Read-Host "--> "     #" Reset PWD to National Identity <$employeeID> [def=n]"
    switch ($ans)
	 {
	  1 { $newPwd=$employeeID;	 setpwd $targetUser $newPwd}
	  2 { $newPwd=$newRndPwd;	 setpwd $targetUser $newPwd}
	  3 { break}
	 }
   }
   
  else # a password was also given
   {
	if ($newPwd.length -lt 8)  {y;"Password must be 8 chars long";$myHelp;w;exit}
	else {setpwd $targetUser $newPwd}
   }
 } 
}
 #endregion function pwd
##########################################
function adAttrEditx($userName,[string]$attr,$value)
# function to change ldap field in our AD
# performs NO verifications
# will work for most but not all fields - veryusefull for auctomAttributes
{
 if (($username -eq $null) -or ($attr -eq $null) -or ($value -eq $null))
 {y;"Usage: <adAttEditxr username ldapAttName AttValue>";w;break}

 $userDN=getdnx $userName 1
 $Class = “User”
 $objUser = [ADSI]"LDAP://$userDN"
 try
 {
  $objUser.Put($attr,$value)
  $objUser.setInfo()
  #g;"Success";w
  return $true
 }
 catch
  {
   $err=$error[0].exception.message 
   #red; "Failed to set $attr=$value for $userName`n$err"; w
   return $false
  }
}
##########################################
function edit-adAttribute($userName,[string]$attr,[string]$value)
# function to change ldap field in our AD
# performs NO verifications
# will work for most but not all fields - veryusefull for auctomAttributes
{
 if (($username -eq $null) -or ($attr -eq $null) -or ($value -eq $null))
 {y;"`nNull value input`nUsage: <edit-adAttribute username ldapAttName AttValue>";w;break}

 $userDN=getdnx $userName 1
 $Class = “User”
 $objUser = [ADSI]"LDAP://$userDN"
 try
 {
  $objUser.Put($attr,$value)
  $objUser.setInfo()
  #g;"Success";w
  return $true
 }
 catch
  {
   $err=$error[0].exception.message 
   #red; "Failed to set $attr=$value for $userName`n$err"; w
   return $false
  }
}

##############################

function genpwdx ([int]$pwdlength=8, [string]$level=0)
# a simple function to generat a random pwd of rerequired length from
# a given set of chars. Does not enforce complexity but may be complex
# default is 8 chars long
{
 $simple  ='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
 $complex ='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890[],&*+-=^?><'
 if ($level -eq "0"){$c=$simple}
 if ($level -eq "1"){$c=$complex}
 return -join ([Char[]]$c | Get-Random -Count $pwdlength)
}

##############################
function verifyADobjx ($targetObj,[int]$repeats=20)
{
# verifies obj exists on both DCS before exiting
# insert in script after creating an obj user and befor manipulating it to avois random fails
# can take 1-5 secs

if ($targetObj -eq $null){red;"No Input obj name to verifyADObjx";w;exit}

$time=$repeats/2
#y;write-host -NoNewline ".";w
$a=Get-ADDomainController -filter *
$cnt=$a.count
$counter=0

while ($true)
{
 $n++
 for ($i=0;$i -le $cnt-1;$i++)
 {
  $srv=$a[$i].hostname
  try {$ans=Get-ADobject -filter 'name -eq $targetObj' -Server $srv -ea silentlycontinue} catch{}
  If ($ans -ne $null) {$counter++}
 }
 
 if ($counter -eq $cnt){w;return $true} else {$counter=0}
 if ($n -eq $repeats){w;return $false}
 sleep -Milliseconds 500
 y;write-host -NoNewline -backgroundcolor green "."
}

} # end of function



##############################
function isIPAddressx($targetIP)
{
 ($targetIP -as [System.Net.IPAddress]).IPAddressToString -eq $targetIP -and $targetIP -ne $null
}


################################
function timethisx
{
  $codetext = $Args -join ' '
  $codetext = $ExecutionContext.InvokeCommand.ExpandString($codetext)

  $code = [ScriptBlock]::Create($codetext)

  $timespan = Measure-Command $code
  "Your code took {0:0.000} seconds to run" -f $timespan.TotalSeconds
} 

###############################

function CCodex ($target)
{
 if ($target -eq $null) {y;"Usage: <ccode countryName> OR <ccode countrycode>";w;break}
 $target=$target.tolower()	
 $a=get-content s:\countrycodes.txt
 $lineArray=@()
 foreach ($line in $a)
 {
  $lineArray=($line -split ";")
  $code   =(($lineArray[0]).tolower()).trimend(" ")
  $country=(($lineArray[1]).tolower()).trimend(" ")
  if ($code    -eq $target) {return $country}
  if ($country -eq $target) {return $code}
 }
}
####################################
function delayx($sec=5)
{
 y;for($i=1; $i -le $sec; $i++){sleep 1;write-host -nonewline $i;if($i -eq $sec){""}};w
}

####################################
function timestampx
{return Get-Date -format $timeStampform}
####################################

function getdnx ([string]$target)# returns the DN of THE FIRST object in AD
{
 if ($target -eq ""){y;"enter AD Object name";w}
 else
 {
  $sb="DC=ekmd,DC=huji,dc=uni"
  $A=Get-ADObject -searchbase $sb -Filter 'name -like $target' | DN 
  if ($A -ne $null) {return $A} else {$null}
 }
} 
####################################
function idobj ($target)
# similar to getdnx but we only want 1 item returned
# when used by other scripts: user, contact, ou, computer or group
# if more then one answer or not one of allowed then return $false!!
# used by other scripts that need a simple answer
{
 try 
 {
  $a=(Get-ADobject -searchbase "DC=ekmd,DC=huji,DC=uni" -Filter 'name -like $target' -ea stop)
  if ($a.count -ne 1) {return $false} #else {return $a.objectclass}
  #
   switch ($a.objectclass)
   {
    "user"               {return "user"}
    "computer"           {return "computer"}
    "contact"            {return "contact"}
    "group"              {return "group"}
    "organizationalUnit" {return "organizationalUnit"}
    "container"          {return "container"}
	default {$false}
   }
 } 
 catch {"err in idobj for <$target>"}
}
####################################
function usrorgrp ($target)
 {
  try 
   {
    $a=(Get-ADobject -Filter 'name -like $target' -ea stop)
	foreach ($result in $a)
	{if ($a -eq $null) {return $false} else {return $a.objectclass}}
   }
  catch {"err in usrorgrp for <$target>"}
 }
#####################################

function log ($txt,$lName,$silent=$false)
{
 try 
 {
  $path="\\ekekfls00\data$\scriptFolders\LOGS\$lName"
  Add-Content -Path $path -Value $txt -EA stop
  if ($silent -eq $false) {Write-Output $txt}
  w
 }  # end try
catch
 {
  #$err=$error[0].exception.message | Out-string
  red
  "<==========>"
  "ERR in function log"
  "lName=$lName"
  "path=$path"
  "text=$txt"
  "<==========>"
  #$err
  w
  return
 }
} # end function
#######################################
function getMailUserType ($name)
# returns "user" "UserMailbox" "MailUser" OR "MailContact"
 {
  $targetUser=get-user $name -errorAction silentlycontinue
  if ($targetuser -eq $null)      # not an AD user obj
   {
    $targetContact=get-contact $name -errorAction silentlycontinue
    if ($targetContact -ne $null)  
     {
      $targetContactTypeDetails = $targetContact.RecipientTypedetails
      $targetContactType        = $targetContact.RecipientType
      $mail						= $targetContact.WindowsEmailAddress
	  return $targetContactTypeDetails
     }
    else {return $false}
   }
  elseif ($targetuser -ne $null)
   {
    $targetUserTypeDetails=$targetUser.RecipientTypedetails
    return $targetUserTypeDetails
   }
 }
#######################################
function renamFolder ($oldN,$newN) 
{
$myHelp=@"
RENAME folders across volumes AND servers - you must have appropriate NTFS permissions 
Usage: <renameFolder oldName newName> Where:
 oldName - is full path of folder you want to RENAME
 newName - is the NEW name of this folder
examples:
 <renameFolder     c:\temp\ kuku>                            will result in
                   c:\kuku\
 <renameFolder     \\serverName\shareName\oldName\ newName>  will result in
                   \\serverName\shareName\newName\
 ----------------RSH DEC 2011---------------------------
"@
if ($args.count -le 1) {yellow;$myhelp;white}
#$oldFolderName="$undergradHomePath\$oldN"
#$newFolderName="$undergradHomePath\$newN"
  
try{rename-item -Path $oldFolderName -NewName $newFolderName -ea stop}
catch
 {
  $err=$Error[0].exception.message
  Set-Variable -Name renameFolderResult -Scope 1  -Value "RENAME Fail - $err"
  return $false
 }
#true only if no err before
return $true
}
#######################################
function createFolder($fldrpath)
{
 try
  {
   $a=New-Item -Path $fldrpath -type directory -ea stop
   g;"Created Folder <$fldrpath>";w
  }
 catch
  {
   $err=$error[0].exception.message
   red;" Failed to Create folder <$fldrpath>`n$err";w
  }
}


###########################
function scriptDetails ($callerScript) # enumerates script run details for debugging
{
 y
 "Script:              " +$callerScript 
 "start:               " +$now
 "Run By:              " +$whoami
 "From PC:             " +$localcomputer
 "Logon DC:            " +$logondc
 "Script Engine:       " +$ShellId
 w
}
###########################
function Sid2user {(get-aduser $args[0]).name}
###########################
function User2Sid {(get-aduser $args[0]).sid.value}
###########################
function getPcType ($target)#returns type of station
{
 if ($target -eq $null) {"Usage: getpctype targetComputerName";break}
 if (test-connection -computername $target -quiet -count 2)
 {
 $tmpObj=Get-WmiObject -Class Win32_Computersystem -ComputerName $target
 $domainRole=$tmpObj.domainrole
 switch -regex ($domainRole)
  {
  [0-1]{"Workstation"}
  [2-3]{"Member Server"}
  [4-5]{"Domain Controller"}
  default {"Unknown"}
  }
}
 else {red;"$target is not online or not responding";white;break}
}
###########################
function p2c ($text="<A>bort or <enter> to continue")
 {
  #Write-Host $text
  $ans=Read-Host $text   
  if ($ans -eq "a"){w;exit} else {}
  #$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
 }
 ##########################
 function padStr($targetStr, $totalLength, $Char=" ")
{
 $diff=[int]$totalLength-$targetStr.length
 if($diff -le 0) {$diff=0}
 $bpad=$char*$diff
 return [string]("$targetStr$bpad")
}
###########################
function fixdate($dateValue=(Get-Date))
{
 return $dateValue.tostring("dd/MMM/yyyy HH:mm:ss") 
}
###########################
function convertWMITime ($time) 
{
 fixdate (Get-WmiObject win32_Operatingsystem).ConvertToDateTime($time)
}
###########################
function cntCPUs ($target)
{  
 try
  {
   $list=get-wmiobject -computername $target win32_processor -Property "deviceid" -ea stop
   $array=foreach ($result in $list) {$cntCPUs++}
   return $cntCPUs
  } 
 catch {return $false}
}

##########################
Function Using-Culture (
[System.Globalization.CultureInfo]$culture = (throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"),
[ScriptBlock]$script= (throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"))
{
    $OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
    trap 
    {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
    }
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
    Invoke-Command $script
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
}

##############################
function addFolderPermissions ($fldr, $usr,$lfn=$null)
# 
{
  $myHelp=@"
   adds permissions to a folder.
   usage: <addFolderPermissions folder user logfile (optional)>
"@
  if ($fldr -eq $null) {y;$myHelp;w;break}
  $folderPerm="ekmd\$usr", "modify", "ContainerInherit, ObjectInherit", "None", "Allow"
  $newSystemSecurityObj=new-object system.Security.AccessControl.FileSystemAccessRule $folderPerm 
  # test if target folder exists
  $a=(Test-Path $fldr)
  if ($a -eq $false) # target folder does not exist
   {
    if ($lfn -eq $null){red;"Folder <$fldr> does NOT exist - cannot set permissions";w;return} 
	else {red;log $txt $lfn;w}
   }
  try
   {
	$folderAcl=Get-Acl $fldr
	$folderAcl.addaccessrule($newSystemSecurityObj)
	$folderAcl | Set-Acl $fldr
	$txt1="Successfuly set Security on folder <$fldr> for user <$usr>"
	if ($lfn -eq $null){g;$txt1;w} else {g;log $txt1 $lfn;w}
   }
	 catch
   {
	$err=$error[0] | Out-string
	$txt2="Failed to Set security on folder <$fldr> for user <$usr>`n$err"
	if ($lfn -eq $null){red;$txt2;w} else {red;log $txt2 $lfn;w}
   }
}
############################## 
function enableMBX($username,$lfn=$null)
{
  if ($username -eq $null){red;"No username input to emableMBX";w;exit}
  verifyadobjx $username
  $listofStandardDataBases=Get-MailboxDatabase -identity Standarduser0*
  $rnd=get-random -minimum (0) -maximum (10)
  $userDB=[string]$listofStandardDataBases[$rnd]
  $primarySmtpAddress	= "$username@ekmd.huji.ac.il"
  try
  {
   enable-Mailbox -Identity $username -Alias $username  -database $userDB -ea stop | Out-Null 
   $txt="Successfuly created mailbox for user <$username> on DB <$userDB> "
   if ($lfn -eq $null){g;$txt;w} else {g;log $txt $lfn;w}
  }
  catch
  {
   $err=$error[0] | Out-string
   $txt="Failed to create mailbox for user <$username> on DB <$userDB>`n$err"
   if ($lfn -eq $null){red;$txt;w} else {red;log $txt $lfn;w}
  }
}
##############################
function disableSMTP ($username,$lfn=$null)
 {
  verifyadobjx $username
  try
   {
    disable-mailuser -identity $username -confirm:$false -ea stop
  	$txt="Successfuly removed MailUser Properties from <$username>"
	if ($lfn -eq $null){g;$txt;w} else {g;log $txt $lfn;w}
   }	
   catch
  {
   $err=$error[0] | Out-string
   $txt="Failed to removed MailUser Properties from <$username>`n$err"
   if ($lfn -eq $null){red;$txt;w} else {red;log $txt $lfn;w}
  }
 }
############################## 
function enableSMTP ($username,$externalMail,$lfn=$null)
 {
  try
   {
    enable-mailuser -DomainController $logondc -identity $username -externalEmailAddress $externalMail -ea stop
    $txt="Successfuly mail enabled <$username> with SMTP <$externalMail>"
    if ($lfn -eq $null){g;$txt;w} else {g;log $txt $lfn;w}
   }	
   catch
  {
   $err=$error[0] | Out-string
   $txt="Failed to Mail Enable <$username> with SMTP <$externalMail>`n$err"
   if ($lfn -eq $null){red;$txt;w} else {red;log $txt $lfn;w}
  }
 }
 
 
#endregion functions

#region ALIASES
############## ALIASES BLOCK #######################################
set-alias sidx   user2sidx
set-alias userx  Sid2userx
set-alias fe     folderExist
set-alias cf     createFolder
Set-Alias grep   select-string
Set-Alias gpss   get-PSSession
Set-Alias rpss   remove-PSSession
Set-Alias npss   new-PSSession
Set-Alias epss   enter-PSSession
set-alias username createUniqueUserName
set-alias createpwd genpwdx
set-alias enable-smtp enablesmtp
set-alias disable-smtp disablesmtp

#endregion aliases

$Host.UI.RawUI.WindowTitle = "$now -- Done Loading Common Shell -- PS $PSVersion"

#endregion







