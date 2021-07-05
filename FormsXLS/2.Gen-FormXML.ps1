param(
	[Parameter(Mandatory=$true)]
	[string[]]$FileName = "",

	[Parameter(Mandatory=$false)]
	[ValidateSet("He", "En")]
	[string[]]$Language = "He"
)

function get-header(){
	$outStr = '<?xml version="1.0" encoding="utf-8"?>
<rows>
	<config>
		<fileName>applicationForm</fileName>
		<docHeader>טופס בקשה למלגה</docHeader>
		<finalMessage>הפרטים נשמרו בהצלחה</finalMessage>
		<missingDataMessage>יש למלא את כל השדות המסומנים</missingDataMessage>
		<registrationMessage>אינך רשום/ה למלגה זו. <![CDATA[<a href="http://hss2.ekmd.huji.ac.il/home">הירשם/י כאן</a>]]></registrationMessage>
		<docTypeList>docType</docTypeList>
		<docTypeColumn>תוכן קובץ</docTypeColumn>
		<docType>0. טופס בקשה</docType>
		
		
		<!--
		<createPDF>yes</createPDF>
		<destinationFolder>advisorPDF</destinationFolder>
		<destinationList>advisorList</destinationList>
		<ticketNum>ADV01</ticketNum>
		<description>[studentName]-[advisorName]-</description>
		<createSubFolder>yes</createSubFolder>
		<redirectPage>https://scholarships.ekmd.huji.ac.il/home/agriculture/AGR129-2020/Pages/Success.aspx?isdlg=1&amp;e=1</redirectPage>
		-->

	</config>
	
<!-- ==================   Date Template ==================== -->

<!-- 
	<control>
		<Type>TextBox</Type>
		<Data>date001</Data>
		<width>100</width>
		<regex>^($|(((0[1-9]|[12][0-9]|3[01])\/(0[13578]|1[02])\/((19|[2-9][0-9])[0-9]{2}))|((0[1-9]|[12][0-9]|30)\/(0[13456789]|1[012])\/((19|[2-9][0-9])[0-9]{2}))|((0[1-9]|1[0-9]|2[0-8])\/02\/((19|[2-9][0-9])[0-9]{2}))|(29\/02\/((1[6-9]|[2-9][0-9])(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)))))$</regex>
		<tooltip>DD/MM/YYYY</tooltip>
		<required>yes</required>
	</control>

-->
<!-- =================== Teudat Zeut Template =============== -->

<!--
	<row>

			<Label>
				<text>ת.ז.</text>
				<width>95</width>
			</Label>
		<control>
			<Type>TextLabel</Type>
			<Data>studentId</Data>
			<width>150</width>
		</control>
	</row>
	
-->	
<!-- ===================== Hatima ===================== -->

<!--    
	<row>
		<control>
			<Type>Signature</Type>
			<Data>Signature</Data>
			<width>300</width>
			<required>no</required>	
			<print>yes</print>
		</control>
	
	</row>

-->	

<!-- =====================RadioButtonList=================== -->

'

return $outStr
}

function get-headerEn(){
	$outStr = '<?xml version="1.0" encoding="utf-8"?>
<rows>
	<config>
		<fileName>applicationForm</fileName>
		<docHeader>Application form</docHeader>
		<finalMessage>All the information was saved successfully</finalMessage>
		<missingDataMessage>Please fill out all of the marked fields</missingDataMessage>
		<registrationMessage>You are not registered for this scholarship. <![CDATA[<a href="http://scholarships2.ekmd.huji.ac.il/home">Register here</a>]]></registrationMessage>
		<docTypeList>docType</docTypeList>
		<docTypeColumn>Document Type</docTypeColumn>
		<docType>0. Application Form</docType>
		<calculations>no</calculations>
		
		
		<!--
		<createPDF>yes</createPDF>
		<destinationFolder>advisorPDF</destinationFolder>
		<destinationList>advisorList</destinationList>
		<ticketNum>ADV01</ticketNum>
		<description>[studentName]-[advisorName]-</description>
		<createSubFolder>yes</createSubFolder>
		<redirectPage>https://scholarships.ekmd.huji.ac.il/home/agriculture/AGR129-2020/Pages/Success.aspx?isdlg=1&amp;e=1</redirectPage>
		-->
		
	</config>

	
<!-- ==================   Date Template ==================== -->

<!-- 
	<control>
		<Type>TextBox</Type>
		<Data>date001</Data>
		<width>100</width>
		<regex>^($|(((0[1-9]|[12][0-9]|3[01])\/(0[13578]|1[02])\/((19|[2-9][0-9])[0-9]{2}))|((0[1-9]|[12][0-9]|30)\/(0[13456789]|1[012])\/((19|[2-9][0-9])[0-9]{2}))|((0[1-9]|1[0-9]|2[0-8])\/02\/((19|[2-9][0-9])[0-9]{2}))|(29\/02\/((1[6-9]|[2-9][0-9])(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00)))))$</regex>
		<tooltip>DD/MM/YYYY</tooltip>
		<required>yes</required>
	</control>

-->
<!-- =================== Teudat Zeut Template =============== -->

<!--
	<row>

			<Label>
				<text>ת.ז.</text>
				<width>95</width>
			</Label>
		<control>
			<Type>TextLabel</Type>
			<Data>studentId</Data>
			<width>150</width>
		</control>
	</row>
	
-->	

<!-- ===================== Hatima ===================== -->

<!--    
	<row>
		<control>
			<Type>Signature</Type>
			<Data>Signature</Data>
			<width>300</width>
			<required>no</required>	
			<print>yes</print>
		</control>
	
	</row>

-->	

<!-- ================================================= -->




'

return $outStr
}

function get-footer(){
	$outStr = "	
	<row>
		<Label></Label>
	</row>
  
	<row>
		<Button>שמירה</Button>
	</row>
	
	<row>
		<Label></Label>
	</row>
	
	<row>
		<control>
			<Type>finalMessage</Type>
			<Data>MyCustomLabel</Data>
			<width>500</width>
			<Text></Text>
		</control>
	</row>
</rows>"	
	return $outStr
}

function get-footerEn(){
	$outStr = "
	<row>
		<Label></Label>
	</row>
  	
	<row>
		<Button>Save</Button>
	</row>

	<row>
		<control>
			<Type>finalMessage</Type>
			<Data>MyCustomLabel</Data>
			<width>500</width>
			<Text></Text>
		</control>
	</row>
</rows>
"	
	return $outStr	
}


function get-XMLHeaderOpen(){
	$outStr = '
	<row>
		<Header>'
	return $outStr	
}

function get-XMLHeaderClose(){
	$outStr = '</Header>
	</row>

	<row>
		<Label></Label>
	</row>

'
	return $outStr
}


function get-XMLRowInputOpen(){
	$outStr = '
	<row>

	'
	return $outStr	
}

function get-XMLRowInputClose(){
	$outStr = '
	</row>

	<!--row>
		<Label></Label>
	</row-->
	
'
	return $outStr		
}

function get-XMLRowTextOpen(){
	$outStr = '
	<row>
		<Label>
			<text>
	'
	return $outStr		
}

function get-XMLRowTextClose()
{
	$outStr = '
			</text>
			<width>520</width>
		</Label>
	</row>
	
'
	return $outStr		
}


function get-XMLRadioOpen()
{
	$outStr = '			<control>
			<Type>RadioButtonList</Type>
			<Data>DikanList</Data>
			<List>yesNoList</List>
			<width>100</width>
			<direction>horizontal</direction>
			<required>yes</required>
		</control>
	
'
	return $outStr	
}


function get-XMLRadioClose(){
	$outStr	= ""
	return $outStr		
}
function get-XMLRowTableHeaderOpen()
{
	$outStr	= '
	<row>
	
	'
	
	return $outStr		
}

function get-XMLRowTableHeaderClose()
{
	$outStr	= "	
	</row>
		
	"
	return $outStr		
}

function get-RowTableHeaderControls($str){
	$outStr = ""
	$strArr = $str.split('|');
	foreach ($el in $strArr){
		$outStr +="		
			<Label>
				<text>"+$el.trim()+"</text>
				<width>150</width>		
			</Label>
		
"			
	}		
	return $outStr
}


function get-XMLTableInput($str){
	$outStr = ""
	$str = $str.toLower()
	# deletes comment in string
	if ($str.contains(";")){
		$commPosition = $str.IndexOf(";")
		$str = $str.substring(0,$commPosition)
	}
	if ($str.contains("r:") -and $str.contains("c:")){
		
		$arrStr = $str.split(" ")
		[int]$rows = 0
		[int]$cols = 0
		foreach ($el in $arrStr){
			if ($el.contains("r:"))
			{
				$wel = $el.split(":")[1].Trim()
				if ($wel -match "^\d+$"){
					[int]$rows = [int]$wel
				}
				
			}
			if ($el.contains("c:"))
			{
				$wel = $el.split(":")[1].Trim()	
				if ($wel -match "^\d+$"){
					[int]$cols = [int]$wel
				}
				
			}
		}	
			
			$outStr = "
	<!--Table Input Rows:"+$rows.ToString() +" Columns:" +$cols.ToString()+" -->
		"
	# write-host "FieldID: $global:fieldID"
		
		for($i=1;$i -le $rows; $i++){
			$outStr += get-XMLRowTableHeaderOpen
			
			for($j=1; $j -le $cols; $j++){
				$outStr += get-ControlTextBox
            
			
				$global:fieldID ++				
			}
			
			$outStr += get-XMLRowTableHeaderClose
			
		}
			

	}
	return $outStr	
}
function get-XMLMultiTextInputOpen(){
	$outStr	= '
	<row>
	
	'
	
	return $outStr		
}

function get-XMLMultiTextDivided($str){
	$outStr = ""
	if ([string]::IsNullOrEmpty($str)){
		# do nothing
	}else
	{	
		$arrStr = $str.split("|")
		foreach($el in $arrStr){
			if ($el.trim()  -match "^[_]+$"){ # only symbol _, this means is a input
				# input
				$outStr += get-ControlTextBox
				$global:fieldID ++
			}
			else
			{
				$outStr +=  get-Label $el
			}
		}
		
		
	}
	
	return $outStr
}

function get-XMLMultiTextInput($str){
	
	$xmlMultiText =  get-XMLMultiTextDivided $str
	
	$outStr	= $xmlMultiText+ '
	</row>
	
	'
	
	return $outStr		
}

function get-ControlTextBox(){
	return "
		<control>
			<Type>TextBox</Type>
			<Data>field"+$global:fieldID.toString().padLeft(3,'0')+"</Data>
			<width>150</width>
			<required>yes</required>
		</control>

"	
}
function get-Label($str){
	
$outStr += "
		<Label>
			<text>"+$str.trim()+"</text>
			<width>95</width>
		</Label>
		
"	
return $outStr
	
}

function get-XMLCheckBoxOpen(){
return "
	<!-- Put checkBox into a Row -->
	<row>
		<control>
			<Type>CheckBox</Type>
			<Data>field"+$global:fieldID.toString().padLeft(3,'0')+"</Data>
			<width>20</width>
			<required>yes</required>
		</control>	
	</row>
"
}

function get-XMLMultiLineTBOpen(){
	return "
	<row>
		<control>
			<Type>MultiLineTextBox</Type>
			<Data>field"+$global:fieldID.toString().padLeft(3,'0')+"</Data>
			<width>500</width>
		</control>

		<Label>
			<text></text>
			<width>2</width>
		</Label>
	</row>		
	"
}

function get-RowInputControls($str){
	$outStr = ""
	# $global:fieldID ++
	$strArr = $str.split(' ');
	$wasfield = $false
	$textLabel = ""
	foreach ($el in $strArr){
		if ($el.trim().contains('_')){  #  field
		    
			if ($textLabel.length -gt 0){
				$outStr += get-Label $textLabel 
	
				$textLabel =  ""
			}
			
		    $outStr += get-ControlTextBox
            
			$wasfield = $true
			$global:fieldID ++
		}
		else
		{
			if ($wasfield){
				$textLabel = $el.trim()
				$wasfield = $false
			}
			else
			{
				$textLabel += " "+ $el.trim()
			}
		}
		
			
		
		
	}
	if ($textLabel.length -gt 0){
				$outStr += get-Label $textLabel
	
				$textLabel =  ""
	}	

	return $outStr
	
}

# wf - work file
if ([string]::isNullOrEmpty($fileName)){
	write-host File name must be specified.
}
else
{
	$Language = $Language.toUpper().Trim()
	write-host "Language choosen:$Language"
	if ($Language -eq "HE"){
		$outFile = get-header 
	}
	else	
	{
		$outFile = get-headerEn 		
	}

	$wf = get-content $fileName
	#$wf

	$tagOpened = $false
	$headerOpen= $false
	$tagRowInputOpen = $false
	$tagRowTextOpen = $false
	$tagRowTableHeaderOpen = $false
	$tagTableInput  = $false
	$tagMultiTextInput = $false
	$tagCheckBoxInput = $false
	$tagMultiLineTextBoxInput = $false
	
	$global:fieldID = 0
	
	
	foreach($line in $wf)
	{
		# wl- work line
		$wl = $line.trim()
		
		if ($wl.Length -eq 0){  # empty string
			continue
		}
				
		
		if ($wl.substring(0,1) -eq ";"){ # comments
			continue
		}
		

		if ($wl.contains("./h")){
			$tagOpened = $true
			$headerOpen = $true
			$outFile += get-XMLHeaderOpen
			continue
		}
		
		if ($wl.contains("./ri")){
			$tagOpened = $true	
			$tagRowInputOpen = $true
			$outFile += get-XMLRowInputOpen
			continue
		}	

		if ($wl.contains("./rt")){
			$tagOpened = $true	
			$tagRowTextOpen = $true
			$outFile += get-XMLRowTextOpen
			continue
		}

		if ($wl.contains("./th")){
			$tagOpened = $true	
			$tagRowTableHeaderOpen = $true
			$outFile += get-XMLRowTableHeaderOpen
			continue
		}
		
		if ($wl.contains("./ti")){
			$tagOpened = $true	
			$tagTableInput = $true
			$outFile += get-XMLTableInput $wl
			continue
		}
		
		if ($wl.contains("./mi")){
			$tagOpened = $true	
			$tagMultiTextInput = $true
			$outFile += get-XMLMultiTextInputOpen
			continue
		}
		
		
		if ($wl.contains("./cb")){
			$tagOpened = $true	
			$tagCheckBoxInput = $true
			$outFile += get-XMLCheckBoxOpen
			$global:fieldID++
			continue
		}		
		
		
		if ($wl.contains("./mtb")){
			$tagOpened = $true	
			$tagMultiLineTextBoxInput = $true
			$outFile += get-XMLMultiLineTBOpen
			$global:fieldID++
			continue
		}		
				
		
		
		
		if ($wl.contains("./e")){
			if ($headerOpen){
				$outFile += get-XMLHeaderClose
			}
			
			if ($tagRowInputOpen){
				$outFile += get-XMLRowInputClose
			}
			
			if ($tagRowTextOpen){
				$outFile += get-XMLRowTextClose
			}
			
			if ($tagRowTableHeaderOpen){
				$outFile += get-XMLRowTableHeaderClose
			}
			
			if ($tagCheckBoxInput){
				$outFile += "" # get-XMLCheckBoxClose
			}
			
			if ($tagTableInput){
				$outFile += ""
			}
			
			$tagOpened 		 = $false
			$headerOpen 	 = $false
			$tagRowInputOpen = $false
			$tagRowTextOpen  = $false
			$tagRowTableHeaderOpen = $false
			$tagTableInput  = $false
			$tagMultiTextInput = $false
			$tagCheckBoxInput = $false
			$tagMultiLineTextBoxInput = $false
			
			continue
		}
		
		if ($tagOpened ){
			if ($tagRowInputOpen){
				$outFile += get-RowInputControls($wl)
				
			}elseif ($tagRowTableHeaderOpen){
				$outFile += get-RowTableHeaderControls($wl)
			}elseif ($tagTableInput){
				$outFile += ""
			}elseif ($tagMultiTextInput)
			{
				$outFile += get-XMLMultiTextInput($wl)
			}else
			{
				$outFile += $wl
			}
			
		}	
			
		
	}
	$fileItem = Get-Item $fileName
	$outFileName = "XML\$($fileItem.BaseName).xml"
	
	
	if ($Language -eq 'HE'){
	
		$outFile += get-footer
		$outFileName = "XML\$($fileItem.BaseName)" + "-HE.xml"
	}
	else
	{
		$outFile += get-footerEn
		$outFileName = "XML\$($fileItem.BaseName)" + "-EN.xml"		
	}
	

	
	$outFile | out-file  -filepath $outFileName -encoding UTF8
	
	write-host "XML Saved to $outFileName."
	write-host Done.
	
	# write-host 	$global:fieldID 
}