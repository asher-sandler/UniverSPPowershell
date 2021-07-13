function gen-Class($arr){
	$outFile = ''
	
$crlf = [char][int]13+[char][int]10

$body = ''+$crlf

	foreach($item in $arr)	{
	
		$body += "			public string "+$item.Name + " { get; set; } // "+$item.DisplayName+$crlf
	
	}
	$body += $crlf+$crlf
    $body += "   public static Applicant bindItem(SPListItem spItem){" + $crlf
    $body += "			Applicant ItemRow = new Applicant();" + $crlf+ $crlf	
	$body += '          ItemRow.ID = (int)spItem["ID"];'+$crlf

	foreach($item in $arr)	{
		

		$body += "			ItemRow."+$item.Name +' = (string)spItem["'+$item.Name+'"];'+ $crlf	
	}
	
    $body += "           return ItemRow;" + $crlf
    $body += "    }" + $crlf
        	

	
	
	$header = @'
using System;



#region for sharepoint using
// for sharepoint access
using Microsoft.SharePoint;

#endregion




namespace ListToPDF
{
    partial class Applicant
    {
       public int ID { get; set; }
	   
'@

$footer = @'

    }
}
'@


$outFile = $header + $body + $footer
return $outFile
}


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



	$userName = "ekmd\ashersa"
	$userPWD = "GrapeFloor789"
	
	$SiteURL="https://scholarships.ekmd.huji.ac.il/home/NaturalScience/SCI72-2021"
	$className = $SiteURL.split('/')[-1]

	$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
	$Ctx.Credentials = New-Object System.Net.NetworkCredential($userName, $userPWD)
	$List = $Ctx.Web.lists.GetByTitle("ApplicantTemplate")
	    #$ViewFields = $List.DefaultView.ViewFields
    $Ctx.load($List.Fields) 
    #$Ctx.load($List.SchemaXml) 
	#$Ctx.load($List) 
    $Ctx.ExecuteQuery()
	
	$crlf = [char][int]13+[char][int]10
	$FieldXML = '<Fields>'
	foreach($field in $List.Fields){
		# write-host "$($field.Title) : Hidden : $($field.Hidden)"
		#if ($field.SchemaXml.Contains('ReadOnly="TRUE"')){
		#}
		#else{
			#if ($field.SchemaXml.Contains('Group="_Hidden"')){
			#}
			#else{
		
				#If (!($field.Hidden -or $field.ReadOnly )){
					$FieldXML += $field.SchemaXml+$crlf
				#}
		
			#}
		#}	
	}
	$FieldXML += '</Fields>'
	
	$FieldXML | out-file "F.xml" -Encoding Default
	$arr = @()
	Select-Xml -Content $FieldXML -XPath "/Fields/Field" | ForEach-Object {
				$nodeName = "" | Select Name,DisplayName;
				$nodeName.Name = $_.Node.Name
				$nodeName.DisplayName = $_.Node.DisplayName
				if (!($_.Node.Name -eq "ID")){
					
					$arr += $nodeName
				}					
				
			}


			gen-Class $arr | out-file "Template-$($className).cs" -Encoding Default
			

