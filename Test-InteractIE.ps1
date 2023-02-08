$ie = New-Object -ComObject "InternetExplorer.Application"
$requestUrl = "https://grs.ekmd.huji.ac.il/home/Pages/createGrsSite.aspx"
#$userId = "username-input";
#$passwordId = "password-input"
#$signIn = "act"

$ie.visible = $true
#ie.silent = $true
$ie.navigate($requestUrl)
while ($ie.busy) {
    Start-Sleep -Milliseconds 100
}
$doc = $ie.Document


Invoke-RestMethod https://grs.ekmd.huji.ac.il/home/Pages/createGrsSite.aspx
Invoke-RestMethod 401 UNAUTHORIZED


$user = 'ashersa'
$token = 'GrapeFloor789'

$pair = "$($user):$($token)"

$encodedCreds = [System.Text.Encoding]::UTF8.GetBytes($pair)

$encodedBase64 = [System.Convert]::ToBase64String($encodedCreds)

$basicAuthValue = "Basic $encodedBase64"

$authHeader = @{
Authorization = $basicAuthValue
}

# рабртает
Invoke-WebRequest -uri $("https://grs.ekmd.huji.ac.il/home/Pages/createGrsSite.aspx") -UseDefaultCredential
 Invoke-RestMethod https://grs.ekmd.huji.ac.il/home/Pages/createGrsSite.aspx -UseDefaultCredential

