$siteUrl = "https://grs.ekmd.huji.ac.il/home/socialSciences/SOC44-2021/"
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)

$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"

$ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)

$lists = $ctx.web.Lists
$list = $lists.GetByTitle("applicants")
$field = $list.Fields.GetByTitle("deadline")
$field.DefaultValue
$ctx.Load($field)
$ctx.ExecuteQuery()

$field.SchemaXml
# <Field Type="DateTime" DisplayName="deadline" Required="FALSE" EnforceUniqueValues="FALSE" Indexed="FALSE" Format="DateOnly" ID="{ef8abc65-c4e0-46eb-99ff-7ebefb829575}" SourceID="{8FCF85A5-6717-457C-BD5A-E23E432FADC3}" StaticName="deadline" Name="deadline" ColName="datetime1" RowOrdinal="0" Version="5" CalType="0" FriendlyDisplayFormat="Disabled"><Default>2021-07-11T00:00:00Z</Default></Field>
