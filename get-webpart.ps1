$userName = "ekmd\ashersa"
$userPWD = "GrapeFloor789"


function Get-WebPart
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext,
        [Parameter(ValueFromPipeline=$true)][string]$PageUrl,
        [Parameter(ValueFromPipeline=$true)][System.Guid]$WebPartId
    )

    begin
    {
        $webPartPagesServiceUrl = "$($ClientContext.Url)/_vti_bin/WebPartPages.asmx?WSDL"
    }
    process
    {
        # generate a cookie

            $cookieContainer = New-Object System.Net.CookieContainer
            $cookieContainer.SetCookies( "https://$($([uri]$ClientContext.Url).Authority)", $clientContext.Credentials.GetAuthenticationCookie( $clientContext.Url ) )

        # geneate web sevice proxy class

            $webPartPagesWebService = New-WebServiceProxy -Uri $webPartPagesServiceUrl -Namespace "WebPartPages" -UseDefaultCredential:$false
            $webPartPagesWebService.Credentials     = $clientContext.Credentials
            $webPartPagesWebService.CookieContainer = $cookieContainer

        # get the web part

            $webPartPagesWebService.GetWebPart2( $PageUrl, $WebPartId, [WebPartPages.Storage]::Shared, [WebPartPages.SPWebServiceBehavior]::Version3 )

    }
    end
    {
    }
}

$site = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace"
$relUrl = "/home/huca/EinKarem/ekcc/QA/AsherSpace"
$page = "contactus"
	
$pageName = "/Pages/"+$pageName+".aspx"
$pageURL = $relUrl + $pageName

$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	
	# $page = $ctx.Web.GetFileByServerRelativeUrl($pageUrl);
	# $page.CheckOut()
$ctx.ExecuteQuery()	
Get-WebPart -ClientContext $Ctx -PageUrl $pageURL
