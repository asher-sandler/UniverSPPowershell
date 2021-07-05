param ([string]$target)
 $myHelp=@"
 .
 Retrievs a great deal of information from AD, FileSystem, Exchange and target PC when relevant.
 Target must be a User, Computer or Contact AD Object.
 Contacts get an unformated presentation
 
 USage:
   <whoisx target>
 
 Examples:
   <whoisx "udi shavit">  (A contact)
   <whoisx danid>         (A user)
   <whoisx danidpc>       (A Computer) 
            -----------RSH Dec 2011------------
"@

####################################
function idobj ($target)
# similar to getdnx but we only want 1 item returned
# when used by other scripts: user, contact, ou, computer or group
# if more then one answer or not one of allowed then return $false!!
# used by other scripts that need a simple answer
{
 if(($target -like "cc\*") -Or ($target -like "CC\*"))
 {
	 try 
	 {
	  #$a=(Get-ADobject -searchbase "DC=ekmd,DC=huji,DC=uni" -Filter 'name -like $target' -ea stop)
	  $target2=$target.Substring(3)
	  $a=(Get-ADobject -Server hustaff.huji.local -Filter 'name -like $target2' -ea stop)
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
 else
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
}
####################################

###############################BEGIN FUNCTION BLOCK###########################
function localAdmins ($target)
{
# !! simplefy to simple list of administrators and develope seperately a function to resolved nested groups
# this function enumerates the members of a LOCAL group of a PC in domain it does not ask for cred and
# assumes u either have them (helpdesk) or NOT. call it after testing if pc is on line using function "isonline"

$strGroup="administrators"
$strComputer=$target
$b=""
$computer = [ADSI]("WinNT://" + $strComputer + ",computer") 
$AdminGroup = $computer.psbase.children.find("Administrators") 
$Adminmembers= $AdminGroup.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
$stop=$Adminmembers.Count
for ($I=0; $I -le $stop-1; $I++) {$b+=[string]$Adminmembers[$I]+"; "}
$b
} 
################################################################################

function getpc ($target)
{
" "
$ADObj=Get-ADcomputer $target -Properties * 
#AccountExpirationDate,badPasswordTime,CanonicalName,City,CN,Company,Country,Created,Department,Description,DisplayName,
#DistinguishedName,EmailAddress,EmployeeID,Enabled,Fax,GivenName,HomeDirectory,HomeDrive,homeMDB,HomePage,HomePhone,
#LastBadPasswordAttempt,lastLogon,LockedOut,lockoutTime,logonCount,LogonWorkstations,mail,Manager,mDBOverHardQuotaLimit,
#mDBOverQuotaLimit,mDBStorageQuota,mDBUseDefaults,MemberOf,MNSLogonAccount,MobilePhone,Modified,msExchHomeServerName,
#msExchWhenMailboxCreated,msRTCSIP-FederationEnabled,msRTCSIP-InternetAccessEnabled,msRTCSIP-OptionFlags,msRTCSIP-PrimaryHomeServer,
#msRTCSIP-PrimaryUserAddress,msRTCSIP-UserEnabled,SamAccountName,Name,UserPrincipalName,Surname,sn,objectSid,SID,Office,#
#OfficePhone,Organization,OtherName,PasswordExpired,PasswordLastSet,PasswordNeverExpires,PasswordNotRequired,
#physicalDeliveryOfficeName,POBox,PostalCode,PrimaryGroup,primaryGroupID,ProfilePath,ProtectedFromAccidentalDeletion,pwdLastSet,
#sAMAccountType,ScriptPath,State,StreetAddress,telephoneNumber,Title,userAccountControl,whenChanged,whenCreated

if ($ADObj.DistinguishedName -eq $null) {"NO SUCH Computer in AD - May be a contact - Aborting"; exit}
"DistinguishedName:    " + $ADObj.DistinguishedName
"SID:                  " + $ADObj.SID
"ObjectGUID:           " + $ADObj.ObjectGUID
"CanonicalName:        " + $ADObj.CanonicalName
"Name:                 " + $ADObj.Name
"SamAccountName:       " + $ADObj.SamAccountName
"DNSHostName:          " + $ADObj.DNSHostName
"IPv4Address:          " + $ADObj.IPv4Address
if ($ADObj.IPv6Address) {"IPv6Address:          " + $ADObj.IPv6Address}

w;$seperator
$enabled=$ADObj.Enabled
if ($enabled -eq $false) {y;"Account is Disabled!";w} else {"Enabled:              " + $enabled}
"Operating System:     " + $ADObj.OperatingSystem 
"OS Version:           " + $ADObj.OperatingSystemVersion +"  Service Pack: " + $ADObj.OperatingSystemServicePack
if ($ADObj.hotfix)      {"OS Hotfix:            " + $ADObj.OperatingSystemHotfix}
if ($ADObj.Description) {"Description:          " + $ADObj.Description}
if ($ADObj.Location)    {"Location:             " + $ADObj.Location}
if ($ADObj.ManagedBy)   {"Managed By:           " + $ADObj.ManagedBy}
if ($ADObj.memberof)
{ "Member Of:            " 
  $ADObj.memberof |%{($_ -replace "CN=" -split ",",2)[0]}
}  
 $now			= fixdate(Get-Date)
 $Created		= fixdate($ADObj.Created)
 $whenChanged 	= fixdate($ADObj.whenChanged )
 #if ($AccountLockoutTime) {$AccountLockoutTime=($ADObj.AccountLockoutTime)}
"Created:              " + $Created
"Last Changed:         " + $whenChanged
"Primary Group:        " + $ADObj.PrimaryGroup + " ("+$ADObj.primaryGroupID+")"
"Delete protected:     " + $ADObj.ProtectedFromAccidentalDeletion
"LockedOut:            " + $ADObj.LockedOut +" @ " + $AccountLockoutTime
"TrustedForDelegation: " + $ADObj.TrustedForDelegation

 w;$seperator
"BadLogonCount:        " + $ADObj.BadLogonCount+ "   badPwdCount:  " + $ADObj.badPwdCount
"Instance Type:        " + $ADObj.instanceType+  "   Is Deleted:   " + $ADObj.isDeleted + " " + $ADObj.Deleted
"logon Count:          " + $ADObj.logonCount
$PasswordLastSet=$ADObj.PasswordLastSet
"Password Last Set:    " + $PasswordLastSet
w;$seperator
"Querying PC:  " +$ADObj.Name  # works manualy from shell but not from script?
#"pwd Last Set:         " + [datetime]::FromFileTime($ADObj.pwdLastSet) #$ADObj.pwdLastSet
#"sAMAccountType:       " + $ADObj.sAMAccountType
#"Certificates:         " + $ADObj.Certificates
#$LastLogonDate=$ADObj.$LastLogonDate
#"Last Logon:           " + $LastLogonDate


# tesing if pc is on line
if (test-connection -computername $ADObj.Name -quiet -count 2)
{

$tmp=getpctype ($ADObj.Name)
"   Target is online and is a ->" +$tmp

$pcobj=get-wmiobject -class win32_computersystem -computername $ADObj.Name
$PhysicalMemory=$pcobj.TotalPhysicalMemory/1mb
"   Model:           " +$pcobj.model
$localTimeZone=$pcobj.currenttimezone

$pcobj=get-wmiobject -class win32_bios -computername $ADObj.Name
"   BIOS:            " +$pcobj.Manufacturer +" "+$pcobj.caption

$pcobj= get-wmiobject -class win32_operatingsystem -computername $ADObj.Name
if($pcobj.caption -match "Vista") {$notice=" !NOTICE!"}
if($pcobj.caption -match "xp")    {$notice=" !NOTICE!"}
"   OS:             " +$notice +" " +$pcobj.caption +" build: "+ $pcobj.BuildNumber +" SP "+  $pcobj.CSDVersion  +" "+ $pcobj.OSArchitecture

#"   Free Physical Memory:  "  +$pcobj.totalvisiblememorysize/1kb
"   Memory in MB           "
"     Physical:            "  +$PhysicalMemory
"     Free Physical:       "  +$pcobj.FreePhysicalMemory/1kb                    
"     Free In Paging File: "  +$pcobj.FreeSpaceInPagingFiles/1kb               
#"   Free Virtual Memory:   "  +$pcobj.FreeVirtualMemory/1kb   
$LastBoot=$pcobj.ConvertToDateTime($pcobj.lastbootuptime)
$LastBootstr=fixdate($Lastboot)
$now=Get-Date
"   Time Since last Boot:  " +($now-$lastboot)
"   Last Boot:             " +$LastBootstr
$pcobj= get-wmiobject -class win32_localtime -computername $ADObj.Name
$localDate= [string]$pcobj.day +"/"+  [string]$pcobj.month +"/"+[string]$pcobj.year
$localtime= [string]$pcobj.hour +":"+  [string]$pcobj.minute +":"+[string]$pcobj.second
"   Time on PC:            " +  $localtime +" "+ $localDate +" TimeZone(min): " + $localTimeZone
$localadmins=localAdmins($ADObj.Name)
"   Local Admins: " + $localadmins

# obtain local disk info
w;$seperator
"Logical Disk Information in GB "
$a=Get-WmiObject win32_logicaldisk -ComputerName $ADObj.Name
for ($I=0; $I -le $a.count-1; $I++)
 {
   $a[$I].size=$a[$I].size/1gb
   $a[$I].freespace=$a[$I].freespace/1gb
 }
 $a | ft -AutoSize
w;$seperator
# checking dhcp details
"NICS:"
$a=Get-WmiObject win32_networkadapter -computername $ADObj.Name -filter "NetConnectionStatus=2"
foreach ($nic in $a) {
 $deviceID=$nic.deviceid
 Get-WmiObject win32_networkadapterconfiguration -computername $ADObj.Name -filter "INDEX=$deviceID"}

}
# else PC is not on line
else 
{$ADObj.Name + " is off line or does not respond to pings"}
w;$seperator
" RUN END "
"          "
exit
}


###############  END getPC function ###################################  
function getuser ($targetuser)
{
$ErrorActionPreference="silentlycontinue"
if(($targetuser -like "cc\*") -Or ($targetuser -like "CC\*"))
{
	$ADObj=Get-ADUser $targetuser.Substring(3) -Properties * -Server hustaff.huji.local
	$pwdPolicy=Get-ADDefaultDomainPasswordPolicy -Server hustaff.huji.local
}
else{$ADObj=Get-ADUser $targetuser -Properties * ;$pwdPolicy=Get-ADDefaultDomainPasswordPolicy}


# AccountExpirationDate,badPasswordTime,CanonicalName,City,CN,Company,Country,Created,Department,Description
#,DisplayName,DistinguishedName,EmailAddress,EmployeeID,Enabled,Fax,GivenName,HomeDirectory,HomeDrive,homeMDB,
# HomePage,HomePhone,LastBadPasswordAttempt,lastLogon,LockedOut,lockoutTime,logonCount,LogonWorkstations
#,mail,Manager,mDBOverHardQuotaLimit,mDBOverQuotaLimit,mDBStorageQuota,mDBUseDefaults,MemberOf,MNSLogonAccount
#,MobilePhone,Modified,msExchHomeServerName,msExchWhenMailboxCreated,msRTCSIP-FederationEnabled
#,msRTCSIP-InternetAccessEnabled,msRTCSIP-OptionFlags,msRTCSIP-PrimaryHomeServer,msRTCSIP-PrimaryUserAddress,msRTCSIP-UserEnabled,
#SamAccountName,Name,UserPrincipalName,Surname,sn,objectSid,SID,Office,OfficePhone,Organization,OtherName,
#PasswordExpired,PasswordLastSet,PasswordNeverExpires,PasswordNotRequired,physicalDeliveryOfficeName,POBox,PostalCode,
#PrimaryGroup,primaryGroupID,ProfilePath,ProtectedFromAccidentalDeletion,pwdLastSet,sAMAccountType,ScriptPath,State,StreetAddress,
#telephoneNumber,Title,userAccountControl,whenChanged,whenCreated

#--------------------------------------------------------
 # if no such user we check if PC exists
 #if ($ADObj.DistinguishedName -eq $null) {"NO SUCH USER - trying for PC"; getpc $ADObj}
 " "
 "DistinguishedName:       " + $ADObj.DistinguishedName
 $userMailType=getMailUserType $ADObj.SamAccountName
 if ($userMailType -eq "user"){$userMailType="User with NO Mail Properties"}
 y;"User type is:            " + $userMailType;w
 "User mail:               " + $ADObj.EmailAddress
 "User Principal Name:     " + $ADObj.UserPrincipalName
 "SAmAccountName:          " + $ADObj.SamAccountName
 "Display Name:            " + $ADObj.DisplayName
 "GivenName SurName:       " + $ADObj.givenname +" " + $ADObj.sn  
 "----------------"
 
 $enabled=$ADObj.Enabled
 if ($enabled -eq $false)
  { 
   y;"Status:                  Disabled!"
   "Description:             " + $ADObj.Description;w  
  }
  else
  {
   w;"Status:                  Enabled"
   "Description:             " + $ADObj.Description  
}
 
 "SID:                     " + $ADObj.SID   
 $AccountLockoutTime=$ADObj.AccountLockoutTime
 if ($ADObj.LockedOut)
  {
   y
   $AccountLockoutTime=fixdate $AccountLockoutTime
   "LockOut:                 " + $ADObj.LockedOut + " at " + $AccountLockoutTime    
   w
  }
  else   {"LockOut:                 " + $ADObj.LockedOut}
 $now			= Get-Date
 $Created		= $ADObj.Created
 $whenChanged	= $ADObj.whenChanged 
 $LastLogonDate	= $ADObj.LastLogonDate
 "Now:                     " + (fixdate($now ))
 "Created:                 " + (fixdate($Created))
 "Acc. Last changed:       " + (fixdate($whenChanged)) 
 "Last Logon:              " + (fixdate($LastLogonDate))
 $AccountExpirationDate=$ADObj.AccountExpirationDate
 #if ($AccountExpirationDate -eq $null){y;"Account has NO Expiration date - should only be true for special accounts!";w}
 $AccountExpirationDatestr=fixdate($ADObj.AccountExpirationDate)
 $tmp=$AccountExpirationDate-$now
 $tmp=($tmp -split ".",0,  "simplematch")[0]
 if ($AccountExpirationDate -ne $null) # there is an expiration date  
 {
  if ($AccountExpirationDate -lt $now) # and it is past so acc expired
  {y;"Account has Expired on:  $AccountExpirationDatestr"; w}
  else
  {
   "Acc. expiration date     " + $AccountExpirationDatestr + " ($tmp days)"
   #"($AccountExpirationDate)"
  }
 }
 elseif(($targetuser -like "cc\*") -Or ($targetuser -like "CC\*"))
 {g;"CC Accounts usually have NO Expiration date";w}

 else 
 {y;"Account has NO Expiration date - should only be true for special accounts!";w}
 $ProtectedFromAccidentalDeletion=$ADObj.ProtectedFromAccidentalDeletion
 If ($ProtectedFromAccidentalDeletion -eq $true) 
 {y;"Account is Deletion protected  - should only be true for special accounts!";w}

w;$seperator
 "Password:"
  $PasswordLastSet=fixdate($ADObj.PasswordLastSet)
  $PasswordNotRequired=$ADObj.PasswordNotRequired
  $LastBadPasswordAttempt=fixdate($ADObj.LastBadPasswordAttempt)
 "  PWD last changed:      " + $PasswordLastSet
  if($PasswordNotRequired  -eq $true){y;"  Password NOT required - pls Investigate";w} else { "  PWD NOT Required:      " + $PasswordNotRequired}

 "  Last Bad PWD Attempt:  " + $LastBadPasswordAttempt
   $PasswordNeverExpires=$ADObj.PasswordNeverExpires 
# if pwd is set to never expire
   if($PasswordNeverExpires -eq $true) 
   {y;"  PWD set to never Expire - should only be true for special accounts!";w}
    else
   { 
    "  PWD never Expires:     " + $PasswordNeverExpires # false
	$PasswordExpired=$ADObj.PasswordExpired
	if($PasswordExpired -eq $true){y; "  PWD expired:           " + $PasswordExpired; w}
	else{"  PWD expired:           " + $PasswordExpired}
   }
# obtaining default AD password policies
	#$pwdPolicy=Get-ADDefaultDomainPasswordPolicy # this row is moved upstairs
	$pwdLife=$pwdPolicy.MaxPasswordAge
	if($pwdLife.Days -ne 0)
	{
		$expirationDate=$ADObj.PasswordLastSet + $pwdPolicy.MaxPasswordAge
		$now=Get-Date 
		[string]$daysAgo=$expirationDate-$now
		$daysAgo=($daysAgo -split ".",0,  "simplematch")[0]
		if($PasswordExpired -eq $true){y; "  PWD expiration date:   " +(fixdate($expirationDate)) +"  ("+$daysAgo+" days)"; w}
		else{"  PWD expiration date:   " +(fixdate($expirationDate)) +"  ("+$daysAgo+" days)"}
	}
	else {g; "  Password expiration policy not set";w}
	
	w;$seperator
 "More Account information:"
 $addcountry	= $ADObj.co  
 $gender		= $ADObj.extensionAttribute3
 $citizenship	= $ADObj.extensionAttribute4
 $consultingHrs	= $ADObj.extensionAttribute5
 if ($addcountry    -ne $null) {y;"  Add. Country:            " + $addcountry;w}
 if ($gender        -ne $null) {y;"  Gender:                  " + $gender;w}
 if ($citizenship   -ne $null) {y;"  Citizenship:             " + $citizenship;w}
 if ($consultingHrs -ne $null) {y;"  consulting hrs:          " + $consultingHrs;w}
 #"  Description:           " + $ADObj.Description  
 "  National ID:           " + $ADObj.EmployeeID  
 "  Unique ID:             " + $ADObj.extensionAttribute15
 "  Office:                " + $ADObj.physicalDeliveryOfficeName  
 "  Phone:                 " + $ADObj.telephoneNumber  
 "  department:            " + $ADObj.Department
 "  script:                " + $ADObj.ScriptPath
 "  home Directory:        " + $ADObj.HomeDirectory + " on " + $ADObj.HomeDrive
 #"  Manager:               " + $ADObj.Manager
 #"  Home Page:             " + $ADObj.HomePageHomePage  
 #"  primary Group D:       " + $ADObj.PrimaryGroup 
 "  profile Path:          " + $ADObj.ProfilePath
 #"  Direct Reports:        " + $ADObj.userAccountControl

 #write-host 
 " "
 $mo=$ADObj.memberof.count
 w;$seperator
 "User is a direct Member of $mo groups:"
  #grpNestx $ADObj.Name
  grpNestx2 $targetuser
 " "
 w;$seperator

 if (($userMailType -eq "UserMailbox") -And ($targetuser -notlike "cc\*") -And ($targetuser -notlike "CC\*"))
  {
  "eMail:               " + $ADObj.EmailAddress    
   $a=Get-MailboxStatistics $ADObj.Name
   y;"   Quota Status:     "+$a.StorageLimitStatus;w
   "   Size:             "+$a.totalitemsize
   y;"   Del Items Size:   "+$a.TotalDeletedItemSize;w
   "   Last Logon:       "+(fixdate $a.LastLogonTime)
   "   Last LogOff:      "+(fixdate $a.LastLogoffTime)
   "   Created:          "+(fixdate $ADObj.msExchWhenMailboxCreated)
   "   DataBase:         "+$a.database
   "   Items:            "+$a.itemcount
   y;"   Use Mail DB default:  " + $ADObj.mDBUseDefaults;w
   $fl=$false
   if (($ADObj.mDBOverHardQuotaLimit) -ne $null) {$fl=$true;"   Absolut Quota (MB):   " + $ADObj.mDBOverHardQuotaLimit}
   if (($ADObj.mDBOverQuotaLimit) -ne $null)     {$fl=$true;"   No Send Quota (MB):   " + $ADObj.mDBOverQuotaLimit}
   if (($ADObj.mDBStorageQuota) -ne $null)       {$fl=$true;"   Warning Quota (MB):   " + $ADObj.mDBStorageQuota}
   if ($fl -eq $true)                            {y;"   Note: Only special cases have explicit mbx level quotas set:";w}

   #"SIP:                     " + $ADObj.'msRTCSIP-PrimaryUserAddress'
   #"SIP Server:              ekekocp00"# + $ADObj.'msRTCSIP-PrimaryHomeServer'
   $userObj = Get-Mailbox $ADObj.Name
   $smtpAddresses	= $userObj.emailAddresses
   $maxSendSize	= $userObj.maxSendSize
   if ($maxSendSize -eq "unlimited") { w;"   Max Item Send Size: Server Limit (default)"}
	else 
	{
	 $LI	=$maxSendSize.lastindexof("MB")+2
	 $maxSendSize= $maxSendSize.remove($li)
	 y;"   Max Item Send Size: $maxSendSize (0 means Send Blocked)";w
	}
   
   "Addresses:"
   foreach ($add in $smtpAddresses) {$ln="   "+$add;if($add.contains("SMTP")){y} else {w} $ln}
   ##new
   $tmp=$ADObj.SamAccountName
   
   w;$seperator
   $mobileDevices = Get-ActiveSyncDeviceStatistics -Mailbox $tmp |  ft DeviceType, DeviceUserAgent, LastSuccessSync -a
   if ($mobileDevices) {w;"Mobile Devices Last Synchronization:";$mobileDevices} else {y;"No mobile Device ever Synchronised";w}
   w
  }
  else {" No MailBox Properties"}
 w;$seperator
 if ($ADObj.msSFU30Name)
 {
 "UNIX Attributes:"
 "   msSFU30GidNumber:      " + $ADObj.msSFU30GidNumber
 "   msSFU30HomeDirectory:  " + $ADObj.msSFU30HomeDirectory
 "   msSFU30LoginShell:     " + $ADObj.msSFU30LoginShell
 "   msSFU30Name:           " + $ADObj.msSFU30Name
 "   msSFU30NisDomain:      " + $ADObj.msSFU30NisDomain
 "   msSFU30Password:       " + $ADObj.msSFU30Password
 "   msSFU30UidNumber:      " + $ADObj.msSFU30UidNumber
 }
 else {" No UNIX attributes"}
  w;$seperator
 if(($targetuser -notlike "cc\*") -And ($targetuser -notlike "CC\*"))
 {
	"Calculating H: can take long time.."
	"H: Size (GB):             " + '{0:0.00}' -f ((dir $ADObj.HomeDirectory -recurse | Measure-Object length -sum).Sum/1GB)
	" "
	" "
}
}
################ end getuser function
############### END FUNCTION BLOCK         ###########################

#############################################################################
##############  BEGIN MAIN BODY   ###########################################

# whoisx is composed of 2 main functions getpc and getuser. 

if ($target -eq "") {scriptDetails ($MyInvocation.mycommand.name);" ";y;$myHelp;w;exit}

switch (idobj $target)
 {
  "user"     {getuser $target}
  "computer" {getpc $target}
  "contact"  {onlyShowWithValues $target} 
  default    {y;"<$target> Object Not found - must be a User, Computer or Contact";w;exit}
 }
#w;"EKMD Users:"
#$seperator
#$disUsers=(get-aduser -filter 'enabled -eq $false').count
#$actUsers=(get-aduser -filter 'enabled -eq $true').count
#y;"Active Accounts:`t$actUsers"
#"Disabled Accounts:`t$disUsers";w
#w;$seperator 

 
