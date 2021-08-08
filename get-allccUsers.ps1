$targetObj2 = "*"
$result=Get-ADuser -Filter 'CN -like $targetObj2' -Properties * -Server hustaff.huji.local
$result | Export-Csv -Path ccUsers.csv -Delimiter `t -Encoding Default