	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.Portable.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Search.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
	Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
. "$dp0\Utils-Request.ps1"
. "$dp0\Utils-DualLanguage.ps1"

$Credentials = get-SCred

 
 $siteName = "https://sep.ekmd.huji.ac.il/home";
 
 
 $siteUrl = get-UrlNoF5 $siteName

 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
 
 $site = $Ctx.Site
 $Ctx.Load($site)
 $Ctx.ExecuteQuery()
 
 $features = $site.Features
 $Ctx.Load($features)
 $Ctx.ExecuteQuery()
 <#
0c8a9a47-22a9-4798-82f1-00e62a96006e
a392da98-270b-4e85-9769-04c0fde267aa
f6924d36-2fa8-4f0b-b16d-06b7250180fa
068bc832-4951-11dc-8314-0800200c9a66
915c240e-a6cc-49b8-8b2c-0bff8b553ed3
b7e45a46-1843-47f5-8742-106a33ac4259
ba407bbd-27e3-4926-9ba8-112af322874b
2ed1c45e-a73b-4779-ae81-1524e4de467a
536c8e3f-fc61-4fa9-ae3e-1598469515a7
3ea4684b-070f-4e15-91c7-1d814314ce61
0d5284d6-e336-4635-8cf6-23e886ab7169
8581a8a7-cf16-4770-ac54-260265ddb0b2
695b6570-a48b-4a8e-8ea5-26ea7fc1d162
92b451e0-12df-475c-9772-31dc9cbb8dd0
4326e7fc-f35a-4b0f-927c-36264b0a4cf0
bd8c6784-27d7-4baf-8ef1-365a9c7f2cb3
3e067d25-4642-490e-9d45-36be9214456c
17415b1d-5339-42f9-a10b-3fef756b84d1
89e0306d-453b-4ec5-8d68-42067cdbf98e
9ee1ade6-87c1-42f6-93e8-434d63dde605
c85e5759-f323-4efb-b548-443d2216efb5
57cc6207-aebf-426e-9ece-45946ea82e4a
6e5e88d0-b02e-4fb7-93c4-48c637aa1f84
39d18bbf-6e0f-4321-8f16-4e3b51212393
a7cc6578-64b8-4545-b43d-542d097a9fea
6e8f2b8d-d765-4e69-84ea-5702574c11d6
ca7bd552-10b1-4563-85b9-5ed1d39c962a
f893df2c-632b-4259-8b1b-5f8c67268454
592ccb4a-9304-49ab-aab1-66638198bb58
9fec40ea-a949-407d-be09-6cba26470a0c
70b06070-cad8-4cf2-a025-6d6eae8ba039
5b79b49a-2da6-4161-95bd-7375c1995ef9
c9c9515d-e4e2-4001-9050-74f980f93160
4248e21f-a816-4c88-8cab-79d82201da7b
b21b090c-c796-4b0f-ac0f-7ef1659c20ae
5f3b0127-2f1d-4cfd-8dd2-85ad1fb00bfc
fde5d850-671e-4143-950a-87b473922dc7
3fb906ba-2df6-4cc7-87a0-91da7af4e287
d3f51be2-38a8-4e44-ba84-940d35be1566
aebc918d-b20f-4a11-a1db-9ed84d79c87e
a4c654e4-a8da-4db3-897c-a386048f7157
4e7276bc-e7ab-4951-9c4b-a74d44205c32
4c42ab64-55af-4c7c-986a-ac216a6e0c0e
eaf6a128-0482-4f71-9a2f-b1c650680e77
43f41342-1a37-4372-8ca0-b44d881e4434
063c26fa-3ccc-4180-8a84-b6f98e991df3
5bccb9a4-b903-4fd1-8620-b795fa33c9ba
00bfea71-1c5e-4a24-b310-ba51c3eb7a57
a942a218-fa43-4d11-9d85-c01e3e3a37cb
6e1e5426-2ebd-4871-8027-c5ca86371ead
c88c4ff1-dbf5-4649-ad9f-c6c426ebcbf5
99e2770b-a82a-49c7-9b36-cd40bc464789
5a979115-6b71-45a5-9881-cdc872051a69
e995e28b-9ba8-4668-9933-cf5c146d7a9f
875d1044-c0cf-4244-8865-d2a0039c2a49
19b28d0f-ceaa-4aff-b44f-d503053623e1
a3e97f54-ea15-4648-a3ef-d81d9b189d34
14aafd3a-fcb9-4bb7-9ad7-d8e36b663bbd
3cb475e7-4e87-45eb-a1f3-db96ad7cf313
744b5fd3-3b09-4da6-9bd1-de18315b045d
4bcccd62-dcaf-46dc-a7d4-e38277ef33f4
6a26c332-41cd-422f-93ef-e5b898ca9bc1
3c993d1f-cdeb-4a7b-bc21-eb582240439d
569b49a8-4522-4116-a30c-eb5f4bfa95fa
73ef14b1-13a9-416b-a9b5-ececa2b0604c
5eac763d-fbf5-4d6f-a76b-eded7dd7b0a5
8b2c6bcb-c47f-4f17-8127-f8eae47a44dd
3bae86a2-776d-499d-9db8-fa4cdc7884f8
7094bd89-2cfe-490a-8c7e-fbace37b4a34 
 #>
 $featID = 'd307b72d-f359-4f2a-8d6a-23fd49f33589'
 foreach($feat in $features){
	 if ($feat.DefinitionId.Guid -eq $featID){
		 write-host "Feature Found"
	 }
 }
  
 $features.Add('d307b72d-f359-4f2a-8d6a-23fd49f33589',$true,[Microsoft.SharePoint.Client.FeatureDefinitionScope]::None)
 $Ctx.ExecuteQuery()
 


