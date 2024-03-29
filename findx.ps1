  param ([string]$targetobj, $targetType="user", [string]$B)
  if($B){$B=$b.toLower()}
  
  $myHelp=@"
   
   Finds AD objects based on search Term and search Type
   "Usage:  <findx searchTerm searchType>       
   Search Base is "OU=EKusers,DC=ekmd,DC=huji,DC=uni"
   
     SearchTerm like: <jackk> OR <ekcc*> OR <c123*> OR <04752*>
     searchType:                                                        
         <user> - Returns AD users by username; the default                                                  
         <pc>   - Returns AD Computers by computername                                                          
         <grp>  - Returns AD groups      
         <id>   - Returns AD User based on National ID
         <mail> - Returns AD User based on MAIL
     	 <sn>   - Returns AD User based on SURNAME
		 
         <*>    - ALL Object Types  - CAREFULL..                                                     
     Examples     cmd                Returns                                                           
              <findx *>          ALL users
              <findx jack*>      All AD users beginning with jack                     
              <findx jackk>      ONLY jackk           
              <findx ek* grp>    All AD grp objects beginning with ek  
              <findx *445 id>    All National IDs ending with 445
              <findx *stein sn>  All surnames ending with stein
              <findx frank* sn>  All surnames begining with frank
     ------------------------------RSH 12July2011----------------------- "
"@
if ($targetObj -eq ""){y;$myhelp;w;exit}
$searchBase="OU=EKusers,DC=ekmd,DC=huji,DC=uni"
# validate values
#if (($targetType -ne "user") -and ($targettype -ne "pc") -and ($targettype -ne "grp") -and ($targettype -ne "id") -and `
#($targettype -ne "sn") -and ($targettype -ne "mail")) {"No such target type - $targettype - ABORTING";exit} 
#if ($targetObj -ne "*") {$targetObj=$targetObj+"*"}
if (($B).tolower() -ne "b") {"Looking for objects like <$targetObj> of type <$targetType>"}
 
#################################################################

 
#################### start script body ########################## 
if(($targetObj -like "cc\*") -Or ($targetObj -like "CC\*"))
{
	#################################################################
	$targetObj2=$targetObj.Substring(3)
	$targetObj2
	switch ($targetType)
	{
		"user" {$result=Get-ADuser -Filter 'CN -like $targetObj2' -Properties * -Server hustaff.huji.local         | ft  SamAccountName, givenName, Surname,mail, telephoneNumber, employeeID -AutoSize}
		"pc"   {$result=Get-ADcomputer -Filter 'Name -like $targetObj2'  -Properties * -Server hustaff.huji.local  | ft  Enabled,SamAccountName, DistinguishedName,sid -AutoSize}
		"grp"  {$result=Get-ADgroup -Filter 'Name -like $targetObj2'  -Properties * -Server hustaff.huji.local     | ft  CN, DistinguishedName,created,mail -AutoSize}
		"id"   {$result=Get-ADuser -Filter 'employeeID -like $targetObj2' -Properties * -Server hustaff.huji.local | ft  SamAccountName, givenName, Surname,mail, telephoneNumber, employeeID, DistinguishedName -AutoSize}
		"sn"   {$result=Get-ADuser -Filter 'surname -like $targetObj2' -Properties * -Server hustaff.huji.local    | ft  SamAccountName, givenName, Surname,mail, telephoneNumber, employeeID -AutoSize}
		"mail" {$result=Get-ADuser -Filter 'mail -like $targetObj2' -Properties * -Server hustaff.huji.local       | ft  SamAccountName, givenName, Surname,mail, telephoneNumber, employeeID -AutoSize}
	}

	if (($B).tolower() -ne "b") {w;$result;$seperator}

	w
	if(($B).tolower() -eq "b"){if (($result.count -gt 1)) {w;return $true} else {w;return $false}}
	if($result.count -gt 1){[string]($result.count-4) +" $targetType Objects Found"} else {"Nada"}
	w
	$seperator

}
else
{

	#################################################################

	switch ($targetType)
	{
		"user" {$result=Get-ADuser -Filter 'CN -like $targetObj' -Properties *         | ft  SamAccountName, givenName, Surname,mail, telephoneNumber, employeeID -AutoSize}
		"pc"   {$result=Get-ADcomputer -Filter 'Name -like $targetObj'  -Properties *  | ft  Enabled,SamAccountName, DistinguishedName,sid -AutoSize}
		"grp"  {$result=Get-ADgroup -Filter 'Name -like $targetObj'  -Properties *     | ft  CN, DistinguishedName,created,mail -AutoSize}
		"id"   {$result=Get-ADuser -Filter 'employeeID -like $targetObj' -Properties * | ft  SamAccountName, givenName, Surname,mail, telephoneNumber, employeeID, DistinguishedName -AutoSize}
		"sn"   {$result=Get-ADuser -Filter 'surname -like $targetObj' -Properties *    | ft  SamAccountName, givenName, Surname,mail, telephoneNumber, employeeID -AutoSize}
		"mail" {$result=Get-ADuser -Filter 'mail -like $targetObj' -Properties *       | ft  SamAccountName, givenName, Surname,mail, telephoneNumber, employeeID -AutoSize}
	}

	if (($B).tolower() -ne "b") {w;$result;$seperator}

	w
	if(($B).tolower() -eq "b"){if (($result.count -gt 1)) {w;return $true} else {w;return $false}}
	if($result.count -gt 1){[string]($result.count-4) +" $targetType Objects Found"} else {"Nada"}
	w
	$seperator
}
