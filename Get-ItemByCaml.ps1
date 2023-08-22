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

 
 
 $siteName = "https://crs.ekmd.huji.ac.il/home/services/2019";
 $siteName = "https://crs2.ekmd.huji.ac.il/home/exempt/2019";
 $siteName = "https://crs2.ekmd.huji.ac.il/home/murshe/2019";
 #$siteName = "https://portals2.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 
 $siteUrl = get-UrlNoF5 $siteName
 $ListName = "contractors"
 #$ListName = "ProductsGroup"
 #$ListName = "MonthGroup"

 write-host "URL: $siteURL" -foregroundcolor Yellow
 
 
 $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 $Ctx.Credentials = $Credentials
 
    #$List=$Ctx.Web.Lists.GetByTitle($ListName)
    #$Ctx.Load($List)
    #$Ctx.ExecuteQuery()
	
	$Web = $Ctx.Web
	$ctx.Load($Web)
	$Ctx.ExecuteQuery() 

    #Get All List Items

    $List = $Ctx.Web.lists.GetByTitle($listName)	
	
    $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
    $Query.ViewXml ="<View><Query><Where><Eq><FieldRef Name='studentId' /><Value Type='Text'>510556517</Value></Eq></Where></Query></View>"
    $Query.ViewXml ="<View><Query><Where><Eq><FieldRef Name='studentId' /><Value Type='Text'>580296283</Value></Eq></Where></Query></View>"
    #$Query.ViewXml ="<View><Query></Query></View>"
<#
$Query.ViewXml =@"
<View>
  <Query>
    <GroupBy Collapse="TRUE">
      <FieldRef Name="productType"/>
    </GroupBy>
    <OrderBy>
      <FieldRef Name="productType"/>
    </OrderBy>
    <ViewFields>
      <FieldRef Name="productType"/>
      <FieldRef Name="Cost" Type="SUM"/>
    </ViewFields>
  </Query>
</View>
"@

$Query.ViewXml =@"
<View>
  <Query>
    <GroupBy Collapse="TRUE">
      <FieldRef Name="productType"/>
    </GroupBy>
    <OrderBy>
      <FieldRef Name="productType"/>
    </OrderBy>
  </Query>
  <ViewFields>
    <FieldRef Name="productType"/>
  </ViewFields>
</View>
"@

$Query.ViewXml =@"
<View>
  <Query>
    <GroupBy Collapse="TRUE">
      <FieldRef Name="productType"/>
    </GroupBy>
  </Query>
  <ViewFields>
    <FieldRef Name="productType"/>
    <FieldRef Name="Cost"/>
  </ViewFields>
  <Aggregations>
    <FieldRef Name="Cost" Type="SUM"/>
  </Aggregations>
</View>
"@

$Query.ViewXml =@"
<View>
  <Query>
    <GroupBy Collapse="TRUE">
      <FieldRef Name="productType"/>
    </GroupBy>
  </Query>
  <ViewFields>
    <FieldRef Name="productType"/>
    <FieldRef Name="Cost"/>
  </ViewFields>
  <ProjectedFields>
    <Field ShowField="Cost" Type="SUM" Name="TotalCost"/>
  </ProjectedFields>
</View>
"@

$Query.ViewXml =@"
<View>
  <Query>
    <GroupBy Collapse='TRUE'>
      <FieldRef Name='productType'/>
    </GroupBy>
  </Query>
  <ViewFields>
    <FieldRef Name='productType'/>
	<Field Name='Cost' />    
	<Field Name='TotalCost' />
  </ViewFields>
  <ProjectedFields>
    <Field Name='TotalCost' Type='Currency' 
           ResultType='Currency' 
           Aggregation='Sum(Cost)' />
  </ProjectedFields>
</View>
"@

$Query.ViewXml =@"
<View>
    <ViewFields>
		<FieldRef Name='productType'/>
   </ViewFields>
    <Query>
        <GroupBy Collapse="TRUE" GroupLimit="300">
            <FieldRef Name="productType" />
        </GroupBy>
    </Query>
</View>
"@
#>
<#
$Query.ViewXml =@"
<View>
<Aggregations Value='On'><FieldRef Name='Month' Type='COUNT'/></Aggregations>
   <ViewFields>
        <FieldRef Name="Month"/>
    </ViewFields>
<Query>
<GroupBy Collapse='TRUE' GroupLimit='100'><FieldRef Name='Month' /></GroupBy>
<OrderBy><FieldRef Name='Month' Ascending='TRUE' /></OrderBy>
</Query></View>
"@
#>	
    $ListItems = $List.GetItems($Query)
    #$ListItems = $List.RenderListData($Query)
    $Ctx.Load($ListItems)
    $Ctx.ExecuteQuery()
	#$ListItems
	forEach($itm in $ListItems ){
		#Write-Host  $itm["Month"] 
		Write-Host  $itm.ID
		Write-Host $($siteName+"/Lists/"+$ListName+"/EditForm.aspx?ID="+$itm.ID)
		#https://crs2.ekmd.huji.ac.il/home/murshe/2019/Lists/contractors/EditForm.aspx?ID=3161&Source=https%3A%2F%2Fcrs2%2Eekmd%2Ehuji%2Eac%2Eil%2Fhome%2Fmurshe%2F2019%2FLists%2Fcontractors%2FAllItems%2Easpx
	}
 