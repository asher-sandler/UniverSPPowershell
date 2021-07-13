param([string] $wrkFileName = "")
function gen-Class($arr){
	$outFile = ''
	
$crlf = [char][int]13+[char][int]10

$body = ''+$crlf

foreach($item in $arr)	{
	if (!($item.Hidden -or $item.ReadOnly)){
		$body += "			public string "+$item.Name + " { get; set; } // "+$item.DisplayName+$crlf
	}
}
	$body += $crlf+$crlf
    $body += "   public static Applicant bindItem(SPListItem spItem){" + $crlf
    $body += "			Applicant ItemRow = new Applicant();" + $crlf	
	$body += '          ItemRow.ID = (int)spItem["ID"];'+$crlf

	foreach($item in $arr)	{
		if (!($item.Hidden -or $item.ReadOnly)){

			$body += "			ItemRow."+$item.Name +' = (string)spItem["'+$item.Name+'"];'+ $crlf	}
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



if ([String]::isNullOrEmpty($wrkFileName)){
	write-host "File Name must be as first param of script!"
}

else

{
	if (Test-Path $wrkFileName){
		
		$isXML = [bool]((Get-Content $wrkFileName) -as [xml])
		# file is XML type
		
		if ($isXML){
		
			write-host
			write-host "Checking for  Name & DisplayName  in  $wrkFileName..." -ForeGroundColor Yellow 
			# check for tag <Data></Data>
			$arr = @()
			$xmlNodeData = Select-Xml -Path $wrkFileName -XPath "/Fields/Field" | ForEach-Object {
				$nodeName = "" | Select Name,DisplayName, Hidden, ReadOnly;
				$nodeName.Name = $_.Node.Name
				$nodeName.DisplayName = $_.Node.DisplayName
				
				if ([string]::isNullOrEmpty($_.Node.Hidden)){
					$nodeName.Hidden = $False
				}
				else
				{
					$nodeName.Hidden = $True
				}	
	
				if ([string]::isNullOrEmpty($_.Node.ReadOnly)){
					$nodeName.ReadOnly = $False
				}
				else
				{
					$nodeName.ReadOnly = $True
				}					
				$arr += $nodeName
			}
			#$xmlNodeData
			
			$isError = $false
			
			# adding tags to array 
			#foreach ($line in $xmlNodeData)
			#{
			#	$arr += $line.toString().toUpper().Trim()
			#}
			
			gen-Class $arr | out-file "Template.cs" -Encoding Default

		}
		else
		{
			write-host "File type is not XML file!"
		}
	}
	else
	{
		write-host "File $wrkFileName does not exists!"
	}
}