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

 $siteURL = "https://portals.ekmd.huji.ac.il/home/huca/EinKarem/ekcc/QA/AsherSpace";
 $siteURL = "https://portals.ekmd.huji.ac.il/home/EDU/stdFolders";
 $ListTitle = "FirstGrade"
 $ListDisplayTitle = "תואר ראשון"
 
<#

דוגמה: https://portals2.ekmd.huji.ac.il/home/Dental/StdFolders/Pages/default.aspx
להכין בכתובת : https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders/Pages/Default.aspx


תעודת זהות	
שם פרטי
שם משפחה
דוא"ל	
טלפון
קישור לתיק אישי
תחילת לימודים 


סטודנטים
סגירת תואר 
חטיבה בחינוך

#> 

$fArr = @()



$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="FamilyName"/>'
$schemaXML.DisplayName = "שם משפחה"
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="StudentID"   />'
$schemaXML.DisplayName = "תעודת זהות"
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="Email" />'
$schemaXML.DisplayName = 'דוא"ל'
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="PhoneNumber" />'
$schemaXML.DisplayName = 'טלפון'
$fArr += $schemaXML


# $fArr +='<Field Type="URL" DisplayName="קישור לתיק אישי" Required="FALSE" EnforceUniqueValues="FALSE" Indexed="FALSE" Format="Hyperlink"  StaticName="LinkToPersonalFolder" Name="LinkToPersonalFolder"  />'
$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="URL" DisplayName="LinkToPersonalFolder"  Format="Hyperlink"/>'
$schemaXML.DisplayName = "קישור לתיק אישי"
$fArr += $schemaXML


# $fArr +='<Field Type="DateTime" DisplayName="תחילת לימודים" Required="FALSE" EnforceUniqueValues="FALSE" Indexed="FALSE" Format="DateOnly" FriendlyDisplayFormat="Disabled"  StaticName="BeginningOfStudies" Name="BeginningOfStudies"  />'
$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="DateTime" Format="DateOnly" DisplayName="BeginningOfStudies"  />'
$schemaXML.DisplayName = "תחילת לימודים"
$fArr += $schemaXML

#$fArr +='<Field Type="Choice" DisplayName="תואר ראשון" Required="FALSE" EnforceUniqueValues="FALSE" Indexed="FALSE" Format="Dropdown" FillInChoice="FALSE"  ><Default>סטודנטים</Default><CHOICES><CHOICE>סטודנטים</CHOICE><CHOICE>סגירת תואר</CHOICE><CHOICE>חטיבה בחינוך</CHOICE></CHOICES></Field>'
$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Choice" DisplayName="FirstGrade" Required="FALSE"  Format="Dropdown" FillInChoice="FALSE"  ><Default>סטודנטים</Default><CHOICES><CHOICE>סטודנטים</CHOICE><CHOICE>סגירת תואר</CHOICE><CHOICE>חטיבה בחינוך</CHOICE></CHOICES></Field>'
$schemaXML.DisplayName ="תואר ראשון"
$fArr += $schemaXML

<#
$ftest = @()
$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = "<Field DisplayName='CustomField'   Type='Text' />"
$schemaXML.DisplayName='1תעודת זהות'
$schemaXML1 = "" | Select XML,DisplayName
$schemaXML1.XML = "<Field DisplayName='CustomField1'   Type='Text' />"
$schemaXML1.DisplayName='1תעודת זהות'
$fArr1 = "" | Select XML,DisplayName 
$fArr1.XML = '<Field Type="Choice" DisplayName="StudentDD" Required="FALSE"  Format="Dropdown" FillInChoice="FALSE"  ><Default>סטודנטים</Default><CHOICES><CHOICE>סטודנטים</CHOICE><CHOICE>סגירת תואר</CHOICE><CHOICE>חטיבה בחינוך</CHOICE></CHOICES></Field>'
$fArr1.DisplayName="שלום שבת"

$ftest += $schemaXML
$ftest += $schemaXML1
$ftest += $fArr1
 #Create-List $siteUrl $ListTitle $ListDisplayTitle
 #Rename-ListColumn $siteUrl $ListDisplayTitle "Title" "שם פרטי" 
 Delete-List $siteUrl $ListDisplayTitle
#> 
 #Delete-List $siteUrl $ListDisplayTitle
 Create-List $siteUrl $ListTitle $ListDisplayTitle
 Rename-ListColumn $siteUrl $ListDisplayTitle "Title" "שם פרטי"  
 Add-FieldsToList $siteUrl $ListDisplayTitle $fArr
 
 
 
<#
שם משפחה
שם פרטי
ת.ז.
מייל
טלפון
סטאטוס טיפול
תיק אישי
מקצוע קבלה 1
מקצוע קבלה 2
מקצוע קבלה 3
סוג מסלול
מסלול
סטאטוס לימודים (פעיל/לא פעיל)



#>


$ListTitle = "TeachingStudies"
$ListDisplayTitle = "לימודי הוראה"

$fArr = @()



$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="FamilyName"/>'
$schemaXML.DisplayName = "שם משפחה"
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="StudentID"   />'
$schemaXML.DisplayName = "תעודת זהות"
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="Email" />'
$schemaXML.DisplayName = 'דוא"ל'
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="PhoneNumber" />'
$schemaXML.DisplayName = 'טלפון'
$fArr += $schemaXML

$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Choice" DisplayName="TreatmentStatus" Required="FALSE"  Format="Dropdown" FillInChoice="FALSE"  ><Default>1</Default><CHOICES><CHOICE>1</CHOICE><CHOICE>2</CHOICE><CHOICE>3</CHOICE></CHOICES></Field>'
$schemaXML.DisplayName ="סטאטוס טיפול"
$fArr += $schemaXML



# $fArr +='<Field Type="URL" DisplayName="קישור לתיק אישי" Required="FALSE" EnforceUniqueValues="FALSE" Indexed="FALSE" Format="Hyperlink"  StaticName="LinkToPersonalFolder" Name="LinkToPersonalFolder"  />'
$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="URL" DisplayName="LinkToPersonalFolder"  Format="Hyperlink"/>'
$schemaXML.DisplayName = "תיק אישי"
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="Profession1" />'
$schemaXML.DisplayName = 'מקצוע קבלה 1'
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="Profession2" />'
$schemaXML.DisplayName = 'מקצוע קבלה 2'
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="Profession3" />'
$schemaXML.DisplayName = 'מקצוע קבלה 3'
$fArr += $schemaXML


#$fArr +='<Field Type="Choice" DisplayName="תואר ראשון" Required="FALSE" EnforceUniqueValues="FALSE" Indexed="FALSE" Format="Dropdown" FillInChoice="FALSE"  ><Default>סטודנטים</Default><CHOICES><CHOICE>סטודנטים</CHOICE><CHOICE>סגירת תואר</CHOICE><CHOICE>חטיבה בחינוך</CHOICE></CHOICES></Field>'
$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Choice" DisplayName="RouteType" Required="FALSE"  Format="Dropdown" FillInChoice="FALSE"  ><Default>סוג מסלול1</Default><CHOICES><CHOICE>סוג מסלול1</CHOICE><CHOICE>סוג מסלול2</CHOICE><CHOICE>סוג מסלול3</CHOICE></CHOICES></Field>'
$schemaXML.DisplayName ="סוג מסלול"
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="Route" />'
$schemaXML.DisplayName = 'מסלול'
$fArr += $schemaXML


#$fArr +='<Field Type="Choice" DisplayName="תואר ראשון" Required="FALSE" EnforceUniqueValues="FALSE" Indexed="FALSE" Format="Dropdown" FillInChoice="FALSE"  ><Default>סטודנטים</Default><CHOICES><CHOICE>סטודנטים</CHOICE><CHOICE>סגירת תואר</CHOICE><CHOICE>חטיבה בחינוך</CHOICE></CHOICES></Field>'
$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Choice" DisplayName="StudyStatus" Required="FALSE"  Format="Dropdown" FillInChoice="FALSE"  ><Default>פעיל</Default><CHOICES><CHOICE>פעיל</CHOICE><CHOICE>לא פעיל</CHOICE></CHOICES></Field>'
$schemaXML.DisplayName ="סטאטוס לימודים"
$fArr += $schemaXML

#Delete-List $siteUrl $ListDisplayTitle
Create-List $siteUrl $ListTitle $ListDisplayTitle
Rename-ListColumn $siteUrl $ListDisplayTitle "Title" "שם פרטי"  
Add-FieldsToList $siteUrl $ListDisplayTitle $fArr
 
 
 
<#
שם משפחה
שם פרטי
ת.ז.
קישור לתיק אישי
טלפון
דוא"ל אוני'
דוא"ל אישי
מסלול: מחקרי/לא מחקרי
תחילת לימודים

#> 
 

$ListTitle = "Certified"
$ListDisplayTitle = "מוסמך"

$fArr = @()



$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="FamilyName"/>'
$schemaXML.DisplayName = "שם משפחה"
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="StudentID"   />'
$schemaXML.DisplayName = "תעודת זהות"
$fArr += $schemaXML



# $fArr +='<Field Type="URL" DisplayName="קישור לתיק אישי" Required="FALSE" EnforceUniqueValues="FALSE" Indexed="FALSE" Format="Hyperlink"  StaticName="LinkToPersonalFolder" Name="LinkToPersonalFolder"  />'
$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="URL" DisplayName="LinkToPersonalFolder"  Format="Hyperlink"/>'
$schemaXML.DisplayName = "קישור לתיק אישי"
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="PhoneNumber" />'
$schemaXML.DisplayName = 'טלפון'
$fArr += $schemaXML

$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="EmailUniv" />'
$schemaXML.DisplayName = 'דוא"ל אוני'
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Text" DisplayName="EmailPersonal" />'
$schemaXML.DisplayName = 'דוא"ל אישי'
$fArr += $schemaXML


$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="Choice" DisplayName="Track" Required="FALSE"  Format="Dropdown" FillInChoice="FALSE"  ><Default>מחקרי</Default><CHOICES><CHOICE>מחקרי</CHOICE><CHOICE>לא מחקרי</CHOICE></CHOICES></Field>'
$schemaXML.DisplayName ="מסלול"
$fArr += $schemaXML



# $fArr +='<Field Type="DateTime" DisplayName="תחילת לימודים" Required="FALSE" EnforceUniqueValues="FALSE" Indexed="FALSE" Format="DateOnly" FriendlyDisplayFormat="Disabled"  StaticName="BeginningOfStudies" Name="BeginningOfStudies"  />'
$schemaXML = "" | Select XML,DisplayName
$schemaXML.XML = '<Field Type="DateTime" Format="DateOnly" DisplayName="BeginningOfStudies"  />'
$schemaXML.DisplayName = "תחילת לימודים"
$fArr += $schemaXML

#Delete-List $siteUrl $ListDisplayTitle
Create-List $siteUrl $ListTitle $ListDisplayTitle
Rename-ListColumn $siteUrl $ListDisplayTitle "Title" "שם פרטי"  
Add-FieldsToList $siteUrl $ListDisplayTitle $fArr
 
 
 


 

