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

$mask = @()
 
 $mask += '.\DefPages-Repl\*-2020.html'
 $mask += '.\DefPages-Repl\*-2021.html'
 $mask += '.\DefPages-Repl\*-2022.html'
 
 $maskJson = @()
 #$maskJson += '.\json\*-2020.json'
 #$maskJson += '.\json\*-2021.json'
 $maskJson += '.\json\GRS_GEN35-2022.json'
 $maskJson += '.\json\HSS_SOC220-2022.json'
 
 $instrHe =  'A href="/home/Pages/InstructionsHe.aspx" target=_blank'
 $instrEn =  'A href="/home/Pages/InstructionsEn.aspx" target=_blank'


 $instrHe =  'href="/home/Pages/InstructionsHe.aspx"'
 $instrEn =  'href="/home/Pages/InstructionsEn.aspx"'

 
 
 $aTags = @()
 $aHtmlTags = @()
 
 foreach($mskJson in $maskJson){
	$jsonFiles = get-childitem $mskJson 
	foreach($jsonFile in $jsonFiles){
		$spObj = get-content $jsonFile -encoding default | ConvertFrom-Json
		if (![string]::isNullOrEmpty($spObj.oldSiteURL) -and $spObj.oldSiteURL.contains('ekmd')){
		    $oldSiteURL = $spObj.oldSiteURL
			
			$siteSuffix = $oldSiteURL.split("/")[-2].Trim()
			
			if (![string]::isNullOrEmpty($siteSuffix)){
				write-host $oldSiteURL -f Cyan
				#$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($oldSiteURL)
				#$Ctx.Credentials = $Credentials
				$offset = 400
				$begOffset = 200
				$contentOldDefault = get-OldDefault $oldSiteURL
                $aHtmlTags += get-HtmlInstructTag $oldSiteURL $contentOldDefault
				
				if ($contentOldDefault.contains($instrHe)){
					Write-Host "He" -f Green
					$indexBeg = $contentOldDefault.IndexOf($instrHe)
					if ($indexBeg -gt $begOffset){
						$sObj = "" | Select-Object string, textBefore, textAfter
						$sObj.string = $contentOldDefault.substring($indexBeg-$begOffset,$offset)
						$aTags += $sObj
					}
				}


				if ($contentOldDefault.contains($instrEn)){
					Write-Host "En" -f Green
					$indexBeg = $contentOldDefault.IndexOf($instrEn)
					if ($indexBeg -gt $begOffset){
						$sObj = "" | Select-Object string, textBefore, textAfter
						$sObj.string = $contentOldDefault.substring($indexBeg-$begOffset,$offset)
						$aTags += $sObj
					}					
				}

		 
		
				
			}
		}
		
	}
 }
 
  $outfile = ".\JSON\TestDefault-ATag.json"
  $outfile = ".\JSON\TestDefault-ATag.txt"
  $aTags | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
  $aTags | out-file $outfile -Encoding Default
 $outfile = ".\JSON\TestDefault-AHtmlTag.json"
  #$outfile = ".\JSON\TestDefault-ATag.txt"
  $aHtmlTags | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
  #$aTags | out-file $outfile -Encoding Default


<#
 foreach ($msk in $mask){
	 $htmlf = get-childitem $msk
	 #write-host $msk
	 
	 foreach($filen in $htmlf){
		 $fileCont = get-content $filen -encoding default -raw 
		 #write-host $filen -f Cyan
		 
		 $HTML = New-Object -Com "HTMLFile"
		 $HTML.IHTMLDocument2_write($fileCont)
		 
		 #$HTML.All.Tags('a') | ForEach-Object{ $_.outerHTML.Contains($instrHe)}
		 #$HTML.All.Tags('a') | ForEach-Object{ $_}
		 
		 $x = $HTML.All.Tags('a') | ForEach-Object{
			 $aTag = "" | Select-Object URL,lang, innerHTML, outerHTML, innerText, outerText, href , parent,foundInFile
			 if ($_.outerHTML.Contains($instrHe)){
				 $aTag.URL = $filen.FullName
				 $aTag.innerHTML = $_.innerHTML
				 $aTag.outerHTML = $_.outerHTML
				 $aTag.parent = $_.parentNode.outerHTML
				 $aTag.innerText = $_.parentNode.innerText
				 $aTag.outerText = $_.outerText
				 $aTag.href = $_.pathname
				 $aTag.foundInFile = $fileCont.ToLower().contains($_.parentNode.outerHTML.ToLower())
				 $aTag.lang = "He"
				 $aTags += $aTag
				 #Write-Host "He" -f Green
			 }
			 if ($_.outerHTML.Contains($instrEn)){
				 $aTag.URL = $filen.FullName
				 $aTag.innerHTML = $_.innerHTML
				 $aTag.outerHTML = $_.outerHTML
				 $aTag.parent = $_.parentNode.outerHTML
				 $aTag.innerText = $_.parentNode.innerText
				 $aTag.outerText = $_.outerText
				 $aTag.href = $_.pathname
				 $aTag.foundInFile = $fileCont.ToLower().contains($_.parentNode.outerHTML.ToLower())
				 $aTag.lang = "En"
				 $aTags += $aTag
				 #Write-Host "En" -f Yellow
			 }
			 
		 }
		 
		
		 
	 }
	 #$jsons.count
 }
  
  $outfile = ".\JSON\TestDefault-ATag.json"
  $aTags | ConvertTo-Json -Depth 100 | out-file $outfile -Encoding Default
  $aTags[0] | fl
 $aTags[1] | fl
  $aTags[2] | fl
 $aTags[3] | fl
 
 $aTags[0].parent | Out-File '.\DefPages-Repl\Test1.html' -Encoding Default
 $aTags[1].parent | Out-File '.\DefPages-Repl\Test2.html' -Encoding Default
 
 #>
 <#
 
 
 className                    :
id                           :
tagName                      : A
parentElement                : System.__ComObject
style                        : System.__ComObject
onhelp                       :
onclick                      :
ondblclick                   :
onkeydown                    :
onkeyup                      :
onkeypress                   :
onmouseout                   :
onmouseover                  :
onmousemove                  :
onmousedown                  :
onmouseup                    :
document                     : mshtml.HTMLDocumentClass
title                        :
language                     :
onselectstart                :
sourceIndex                  : 85
recordNumber                 :
lang                         :
offsetLeft                   : 0
offsetTop                    : 0
offsetWidth                  : 0
offsetHeight                 : 0
offsetParent                 : System.__ComObject
innerHTML                    : <FONT class="ms-rteThemeFontFace-1 ms-rteFontSize-2" color=#0072bc><SPAN
                               style="text-decoration-line: underline">המופיעות כאן</SPAN></FONT>
innerText                    : המופיעות כאן
outerHTML                    : <A href="/home/Pages/InstructionsHe.aspx" target=_blank><FONT
                               class="ms-rteThemeFontFace-1 ms-rteFontSize-2" color=#0072bc><SPAN
                               style="text-decoration-line: underline">המופיעות כאן</SPAN></FONT></A>
outerText                    : המופיעות כאן
parentTextEdit               : System.__ComObject
isTextEdit                   : False
filters                      : System.__ComObject
ondragstart                  :
onbeforeupdate               :
onafterupdate                :
onerrorupdate                :
onrowexit                    :
onrowenter                   :
ondatasetchanged             :
ondataavailable              :
ondatasetcomplete            :
onfilterchange               :
children                     : System.__ComObject
all                          : System.__ComObject
scopeName                    : HTML
onlosecapture                :
onscroll                     :
ondrag                       :
ondragend                    :
ondragenter                  :
ondragover                   :
ondragleave                  :
ondrop                       :
onbeforecut                  :
oncut                        :
onbeforecopy                 :
oncopy                       :
onbeforepaste                :
onpaste                      :
currentStyle                 : System.__ComObject
onpropertychange             :
tabIndex                     : 0
accessKey                    :
onblur                       :
onfocus                      :
onresize                     :
clientHeight                 : 0
clientWidth                  : 0
clientTop                    : 0
clientLeft                   : 0
readyState                   : complete
onreadystatechange           :
onrowsdelete                 :
onrowsinserted               :
oncellchange                 :
dir                          :
scrollHeight                 : 0
scrollWidth                  : 0
scrollTop                    : 0
scrollLeft                   : 0
oncontextmenu                :
canHaveChildren              : True
runtimeStyle                 : System.__ComObject
behaviorUrns                 : System.__ComObject
tagUrn                       :
onbeforeeditfocus            :
isMultiLine                  : True
canHaveHTML                  : True
onlayoutcomplete             :
onpage                       :
onbeforedeactivate           :
contentEditable              : inherit
isContentEditable            : False
hideFocus                    : False
disabled                     : False
isDisabled                   : False
onmove                       :
oncontrolselect              :
onresizestart                :
onresizeend                  :
onmovestart                  :
onmoveend                    :
onmouseenter                 :
onmouseleave                 :
onactivate                   :
ondeactivate                 :
onmousewheel                 :
onbeforeactivate             :
onfocusin                    :
onfocusout                   :
uniqueNumber                 : 4
uniqueID                     : ms__id4
nodeType                     : 1
parentNode                   : System.__ComObject
childNodes                   : System.__ComObject
attributes                   : System.__ComObject
nodeName                     : A
nodeValue                    :
firstChild                   : System.__ComObject
lastChild                    : System.__ComObject
previousSibling              : System.__ComObject
nextSibling                  : System.__ComObject
ownerDocument                : mshtml.HTMLDocumentClass
prefix                       :
localName                    : a
namespaceURI                 : http://www.w3.org/1999/xhtml
textContent                  : המופיעות כאן
dataFld                      :
dataSrc                      :
dataFormatAs                 :
role                         :
ariaBusy                     :
ariaChecked                  :
ariaDisabled                 :
ariaExpanded                 :
ariaHaspopup                 :
ariaHidden                   :
ariaInvalid                  :
ariaMultiselectable          :
ariaPressed                  :
ariaReadonly                 :
ariaRequired                 :
ariaSecret                   :
ariaSelected                 :
ie8_attributes               : System.__ComObject
ariaValuenow                 :
ariaPosinset                 : 0
ariaSetsize                  : 0
ariaLevel                    : 0
ariaValuemin                 :
ariaValuemax                 :
ariaControls                 :
ariaDescribedby              :
ariaFlowto                   :
ariaLabelledby               :
ariaActivedescendant         :
ariaOwns                     :
ariaLive                     :
ariaRelevant                 :
ie9_tagName                  : A
ie9_nodeName                 : A
onabort                      :
oncanplay                    :
oncanplaythrough             :
onchange                     :
ondurationchange             :
onemptied                    :
onended                      :
onerror                      :
oninput                      :
onload                       :
onloadeddata                 :
onloadedmetadata             :
onloadstart                  :
onpause                      :
onplay                       :
onplaying                    :
onprogress                   :
onratechange                 :
onreset                      :
onseeked                     :
onseeking                    :
onselect                     :
onstalled                    :
onsubmit                     :
onsuspend                    :
ontimeupdate                 :
onvolumechange               :
onwaiting                    :
constructor                  : System.__ComObject
onmspointerdown              :
onmspointermove              :
onmspointerup                :
onmspointerover              :
onmspointerout               :
onmspointercancel            :
onmspointerhover             :
onmslostpointercapture       :
onmsgotpointercapture        :
onmsgesturestart             :
onmsgesturechange            :
onmsgestureend               :
onmsgesturehold              :
onmsgesturetap               :
onmsgesturedoubletap         :
onmsinertiastart             :
onmstransitionstart          :
onmstransitionend            :
onmsanimationstart           :
onmsanimationend             :
onmsanimationiteration       :
oninvalid                    :
xmsAcceleratorKey            :
spellcheck                   : False
onmsmanipulationstatechanged :
oncuechange                  :
href                         : about:/home/Pages/InstructionsHe.aspx
target                       : _blank
rel                          :
rev                          :
urn                          :
Methods                      :
name                         :
host                         :
hostname                     :
pathname                     : home/Pages/InstructionsHe.aspx
port                         :
protocol                     : about:
search                       :
hash                         :
protocolLong                 : Unknown Protocol
mimeType                     :
nameProp                     : InstructionsHe.aspx
charset                      :
coords                       :
hreflang                     :
shape                        :
type                         :
ie8_shape                    : rect
ie8_coords                   :
ie8_href                     : about:/home/Pages/InstructionsHe.aspx

className                    :
id                           :
tagName                      : A
parentElement                : System.__ComObject
style                        : System.__ComObject
onhelp                       :
onclick                      :
ondblclick                   :
onkeydown                    :
onkeyup                      :
onkeypress                   :
onmouseout                   :
onmouseover                  :
onmousemove                  :
onmousedown                  :
onmouseup                    :
document                     : mshtml.HTMLDocumentClass
title                        :
language                     :
onselectstart                :
sourceIndex                  : 297
recordNumber                 :
lang                         :
offsetLeft                   : 0
offsetTop                    : 0
offsetWidth                  : 0
offsetHeight                 : 0
offsetParent                 : System.__ComObject
innerHTML                    : <FONT class="ms-rteThemeFontFace-1 ms-rteFontSize-2" color=#0072bc><SPAN
                               style="text-decoration-line: underline">המופיעות כאן</SPAN></FONT>
innerText                    : המופיעות כאן
outerHTML                    : <A href="/home/Pages/InstructionsHe.aspx" target=_blank><FONT
                               class="ms-rteThemeFontFace-1 ms-rteFontSize-2" color=#0072bc><SPAN
                               style="text-decoration-line: underline">המופיעות כאן</SPAN></FONT></A>
outerText                    : המופיעות כאן
parentTextEdit               : System.__ComObject
isTextEdit                   : False
filters                      : System.__ComObject
ondragstart                  :
onbeforeupdate               :
onafterupdate                :
onerrorupdate                :
onrowexit                    :
onrowenter                   :
ondatasetchanged             :
ondataavailable              :
ondatasetcomplete            :
onfilterchange               :
children                     : System.__ComObject
all                          : System.__ComObject
scopeName                    : HTML
onlosecapture                :
onscroll                     :
ondrag                       :
ondragend                    :
ondragenter                  :
ondragover                   :
ondragleave                  :
ondrop                       :
onbeforecut                  :
oncut                        :
onbeforecopy                 :
oncopy                       :
onbeforepaste                :
onpaste                      :
currentStyle                 : System.__ComObject
onpropertychange             :
tabIndex                     : 0
accessKey                    :
onblur                       :
onfocus                      :
onresize                     :
clientHeight                 : 0
clientWidth                  : 0
clientTop                    : 0
clientLeft                   : 0
readyState                   : complete
onreadystatechange           :
onrowsdelete                 :
onrowsinserted               :
oncellchange                 :
dir                          :
scrollHeight                 : 0
scrollWidth                  : 0
scrollTop                    : 0
scrollLeft                   : 0
oncontextmenu                :
canHaveChildren              : True
runtimeStyle                 : System.__ComObject
behaviorUrns                 : System.__ComObject
tagUrn                       :
onbeforeeditfocus            :
isMultiLine                  : True
canHaveHTML                  : True
onlayoutcomplete             :
onpage                       :
onbeforedeactivate           :
contentEditable              : inherit
isContentEditable            : False
hideFocus                    : False
disabled                     : False
isDisabled                   : False
onmove                       :
oncontrolselect              :
onresizestart                :
onresizeend                  :
onmovestart                  :
onmoveend                    :
onmouseenter                 :
onmouseleave                 :
onactivate                   :
ondeactivate                 :
onmousewheel                 :
onbeforeactivate             :
onfocusin                    :
onfocusout                   :
uniqueNumber                 : 15
uniqueID                     : ms__id15
nodeType                     : 1
parentNode                   : System.__ComObject
childNodes                   : System.__ComObject
attributes                   : System.__ComObject
nodeName                     : A
nodeValue                    :
firstChild                   : System.__ComObject
lastChild                    : System.__ComObject
previousSibling              : System.__ComObject
nextSibling                  : System.__ComObject
ownerDocument                : mshtml.HTMLDocumentClass
prefix                       :
localName                    : a
namespaceURI                 : http://www.w3.org/1999/xhtml
textContent                  : המופיעות כאן
dataFld                      :
dataSrc                      :
dataFormatAs                 :
role                         :
ariaBusy                     :
ariaChecked                  :
ariaDisabled                 :
ariaExpanded                 :
ariaHaspopup                 :
ariaHidden                   :
ariaInvalid                  :
ariaMultiselectable          :
ariaPressed                  :
ariaReadonly                 :
ariaRequired                 :
ariaSecret                   :
ariaSelected                 :
ie8_attributes               : System.__ComObject
ariaValuenow                 :
ariaPosinset                 : 0
ariaSetsize                  : 0
ariaLevel                    : 0
ariaValuemin                 :
ariaValuemax                 :
ariaControls                 :
ariaDescribedby              :
ariaFlowto                   :
ariaLabelledby               :
ariaActivedescendant         :
ariaOwns                     :
ariaLive                     :
ariaRelevant                 :
ie9_tagName                  : A
ie9_nodeName                 : A
onabort                      :
oncanplay                    :
oncanplaythrough             :
onchange                     :
ondurationchange             :
onemptied                    :
onended                      :
onerror                      :
oninput                      :
onload                       :
onloadeddata                 :
onloadedmetadata             :
onloadstart                  :
onpause                      :
onplay                       :
onplaying                    :
onprogress                   :
onratechange                 :
onreset                      :
onseeked                     :
onseeking                    :
onselect                     :
onstalled                    :
onsubmit                     :
onsuspend                    :
ontimeupdate                 :
onvolumechange               :
onwaiting                    :
constructor                  : System.__ComObject
onmspointerdown              :
onmspointermove              :
onmspointerup                :
onmspointerover              :
onmspointerout               :
onmspointercancel            :
onmspointerhover             :
onmslostpointercapture       :
onmsgotpointercapture        :
onmsgesturestart             :
onmsgesturechange            :
onmsgestureend               :
onmsgesturehold              :
onmsgesturetap               :
onmsgesturedoubletap         :
onmsinertiastart             :
onmstransitionstart          :
onmstransitionend            :
onmsanimationstart           :
onmsanimationend             :
onmsanimationiteration       :
oninvalid                    :
xmsAcceleratorKey            :
spellcheck                   : False
onmsmanipulationstatechanged :
oncuechange                  :
href                         : about:/home/Pages/InstructionsHe.aspx
target                       : _blank
rel                          :
rev                          :
urn                          :
Methods                      :
name                         :
host                         :
hostname                     :
pathname                     : home/Pages/InstructionsHe.aspx
port                         :
protocol                     : about:
search                       :
hash                         :
protocolLong                 : Unknown Protocol
mimeType                     :
nameProp                     : InstructionsHe.aspx
charset                      :
coords                       :
hreflang                     :
shape                        :
type                         :
ie8_shape                    : rect
ie8_coords                   :
ie8_href                     : about:/home/Pages/InstructionsHe.aspx


 
 #>
 #write-host "URL: $siteURL" -foregroundcolor Yellow
 
 #$siteUrl = get-UrlNoF5 $siteName

 #$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)
 #$Ctx.Credentials = $Credentials
 
 
 
 
 