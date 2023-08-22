# Asher Sanlers's Scripts
> CSOM (Client Side Object Model) Scripts to Operate with SharePoint Server from client (non server) side.

## Install CSOM 
- Download and install CSOM from https://www.microsoft.com/en-us/download/details.aspx?id=42038

INSTALL nuget 
cd [path where nuget install]
- nuget.exe install Microsoft.SharePointOnline.CSOM
- copy as administrator all files from nuget directory lib\net40-full\*.dll to C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\
because in Script uses path in command like Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"

## 1.get-spRequest.ps1
Prepare new site for create. Read information from https://portals2.ekmd.huji.ac.il/home/huca/spSupport/Lists/spRequestsList and insert new record to [AvailableXYZList].

Parameters: Name of new Group in field [assignedGroup] of [spRequestsList]; -Force Yes  (mandatory only if Year in Group not equals this year)

Required files : Utils-DualLanguage.ps1; Utils-Request.ps1

Example Using : .\1.get-spRequest.ps1 HSS_HUM164-2021

- Next Step is Open [AvailableXYZList] and Check [Target Audiences] because exist trouble to resolve Audiences in script.
- Next Step : Save item in [AvailableXYZList] and run Procedure to Create File

Actuality: Yes, actual

## 2.add-applicants.ps1

Prepare created new Site for production. Tunes Pages, WebParts, Lists in new site.

Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

- Output files: [assignedGroup].txt -  Passport of Site
- Output files: [assignedGroup].html - To-DO Instruction to prepare site

Required files : Utils-DualLanguage.ps1; Utils-Request.ps1

Example Using: .\2.add-applicants.ps1 HSS_HUM000-2020

- Next Step : Tune site for production

Actuality: Yes, actual

## 3.Clone-FormList.ps1

Copies List Information specifying in lookup fields in xml form from old to new site

Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

Required files : Utils-DualLanguage.ps1; Utils-Request.ps1

Actuality: Yes, actual


## 4.Collect-Navig.ps1

Copies Navigation from Old Site to New, copy pages from Old Site to New

Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

Required files : Utils-DualLanguage.ps1; Utils-Request.ps1

Actuality: Middle


## 5.ChangePerm-Doclib.ps1

Changes Permissions to New Site from Navigation Items of old site.

Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

Required files : Utils-DualLanguage.ps1; Utils-Request.ps1

Actuality: No actual


## 5.copy-Doclib.ps1

Copies Specific Document Libraries from Old Site to New.
Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

In code exists list of Libraries to copy.

Actuality: No actual

## 6.Change-Order.ps1

Reorders form fields of document library on new site  as in old site.
Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

In code exists name of library.

Actuality: No actual



## 7.Test-ApplicantsView.ps1

Test Query on View of Applicants on new site for identical  to old site

Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

Actuality: No actual




## 8.Dump-Site.ps1

Creates dump of new site including info of Lists, Permissions, Navigation, Pages, WebParts and it properties and saves it to JSON

Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

Actuality: No actual


## 8x.Dump-All.ps1

Creates dump of multiple sites and saves it to JSONs

Parameter: Name of txt ([.\grsList.txt]) File with List of Groups 

Actuality: No actual


## 9.Analyze-Permissions.ps1

Analyzes permissions of site based on information created in Script [8.Dump-Site.ps1]

Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

Actuality: No actual

## 9x.Analyze-PermissionsAll.ps1

Analyzes permissions of multiple sites based on information created in Script [8x.Dump-All.ps1]

Parameter: Name of txt ([.\grsList.txt]) File with List of Groups 

Actuality: No actual


## 10.Compar-Sites.ps1

Get datailed HTML report of differences of old and new sites, including info of Pages, Mavigation, WebParts and it properies, Lists, DocLibs, Permissions.
Based on information created in Script [8.Dump-Site.ps1]

Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

Actuality: Little

## 10x.Compar-Sites-all.ps1

Same as 10.Compar-Sites.ps1 but on mutliple sites
Get datailed HTML report of differences of old and new sites, including info of Pages, Mavigation, WebParts and it properies, Lists, DocLibs, Permissions.
Based on information created in Script [8x.Dump-All.ps1]
Parameter: Name of txt ([.\grsList.txt]) File with List of Groups 

Actuality: Little


## 11.Change-DestWPProps.ps1

Change Destination Web Part properties of all Site Pages source is old site , detination new site.
Used JSON file Created in procedure [10.Compar-Sites.ps1]
Based on information created in Script [10.Compar-Sites.ps1]
Parameter: Name of new Group in field [assignedGroup] of [spRequestsList]

Actuality: Little


## 13.Repair-OldSites.ps1

Script Prepare site for production after "Mihzur". 
Read information from https://portals2.ekmd.huji.ac.il/home/huca/spSupport/Lists/spRequestsList with status [4 - ניקוי לאחר ארכוב בוצע]
- 01. Add page DocumentsUpload.aspx (if not exists)
- 02. Fix DocType
- 03. Change DeadLine on applicants
- 04. Add user to applicants
- 05. Fix Default.aspx
- 06. Fix DefaultHe.aspx (if exists)
- 07. Replace site Title
- 08. Replace site Description
- 09. Replace Letter Template
- 10. Replace Title 
- 11. Replace Description 
- 12. Replace deadLine (-1 Year) 
- 13. Replace recommendationsDeadline 

Parameters: No		

Actuality: actual

## 14.Prepare-Archive.ps1

Script Prepare site for archivation
Read information from https://portals2.ekmd.huji.ac.il/home/huca/spSupport/Lists/spRequestsList with status [0 - חדש] or [1 - בביצוע]

Set field [Archive_Waiting_for_Archivation] [x] in availableXYZList (where XYZ - is a name of system, for example - Scholarship)
Parameters: No		

Parameters: No		

Actuality: actual



## activate-Feature.ps1

Script to test activate SharePoint Feature from CSOM

Actuality: No actual

## ADD-SCI.ps1

Script to add Views to Applicants, Navigation Hyerarchy and Document Libraries to  [NaturalScience/SCI94-2022] sites
Script Uses file ".\SCI\HSS_SCI.csv" with Following info:
    ==============================
Grp,Title,TitleHe
phys,Physics,פיסיקה
math,Math,מתמטיקה
life,LifeScience,מדעי החיים
earth,Earth,כדור הארץ
appphys,AppliedPhysics,פיסיקה יישומית
chem,Chemistry,כימיה
    ==============================
	
Important: In [Applicants] list must be field [instituteDestination]

Parameter: Name of Group specified in format [HSS_SCI164-2021]


Next step: Run Script 	.\ADD-SCI-InheritanceRights.ps1 to remove Inheritance Rights and add Specific rights to document libraries.

Actuality: actual

Usage: .\ADD-SCI.ps1 HSS_SCI164-2021

## Add-SCI-ADGrpsToAdSCI.ps1

Script to add [HSS_SCI-XYZ_adminUG] Where XYZ Hard Coded Group specifief in list:
$Grps = 'SCI63-2021','SCI105-2022','SCI106-2022','SCI107-2022','SCI108-2022'
to AD Groups :
- HSS_SCI-appphys_adminUG
- HSS_SCI-chem_adminUG
- HSS_SCI-earth_adminUG
- HSS_SCI-fac_adminUG
- HSS_SCI-life_adminUG
- HSS_SCI-math_adminUG
- HSS_SCI-phys_adminUG

Also to add [HSS_SCI-XYZ__judgesUG] Where XYZ Hard Coded Group specifief in list:
$Grps = 'SCI63-2021','SCI105-2022','SCI106-2022','SCI107-2022','SCI108-2022'
to AD Groups :
- HSS_SCI-appphys_judegesUG
- HSS_SCI-chem_judegesUG
- HSS_SCI-earth_judegesUG
- HSS_SCI-fac_judegesUG
- HSS_SCI-life_judegesUG
- HSS_SCI-math_judegesUG
- HSS_SCI-phys_judegesUG

Parameters: No		

Actuality: little


## ADD-SCI-AdGrpToSPGrp.ps1

Script to add AD Group [adminUG] and [judgesUG] to SP Groups [adminSP] and [judgesSP].
Name of sites hard coded  
Parameters: No	
Actuality: little	

## ADD-SCI-InheritanceRights.ps1

FOR SCI sites only!
Script to break Inheritance rights and to add specific rights to following document Libraries like [Final]:
User rights like this:

שם	סוג	רמות הרשאה
	
- EKMD\hss_sci94-2022_admin-mathug 	Contribute
	
- EKMD\hss_sci94-2022_judges-mathug 	Contribute
	
- EKMD\sharepoint_temp_editorsug 	Full Control


Libraries are:

- Earth;תיקים סופיים - כדור הארץ
- Chemistry;תיקים סופיים - כימיה
- LifeScience;תיקים סופיים - מדעי החיים
- Math;תיקים סופיים - מתמטיקה
- Physics;תיקים סופיים - פיסיקה
- AppliedPhysics;תיקים סופיים - פסיקה יישומית

Parameter: Name of Group specified in format [HSS_SCI164-2021]

Actuality: actual

Usage: .\ADD-SCI-InheritanceRights.ps1 HSS_SCI164-2021

## Add-Users2ADGroups.ps1

Add AD Users to Specific [GRS] SharePoint Groups. 
Uses file "C:\AdminDir\Work\Users.csv" as hard coded parameter

Actuality: no


## add-UserToGroups.ps1

Add Specific AD Users to Specific [GRS] [adminUG] Groups

List of Users and groups hard coded

Actuality: no


## Add-ViewRakefet.ps1

Creates views on specidied Rakefet site.
Views based on list of fields from hard coded xml file [.\daniel\rakefet.xml]
Field of view specified in xml node [SPColumnName]
Site name is hard coded

Parameters: No

Actuality: No


## AD-SPN.ps1

Test for Get SPN in AD

Actuality: No

## Change-KrakoverFiledsOrder.ps1

Change Fields Order in specified [GRS] site in [Applicants]
Site name hard coded 

Parameters: No

Actuality: No



## check2XMLForms.ps1

Compare for Fields Differents in Two in XML Form

Parameters: Hard coded

Actuality: Little



## Check-Deadline.ps1

Create report for compliance  with deadline in [spRequestsList] and [availableXYZList]

Parameters: No

Actuality: Little


## Check-DoclibExistsInApplicant.ps1

Get Report If exists Applicants document library in site 
Read [applicants] list and check field [folderLink]

Parameters: Hard coded
Actuality: Little



## checkForAll.ps1

Check for double tag <Data> in XML Form
Check for file is valid XML  

Same as [checkForDoubleDataNameXML.ps1] but on multiple files in specified directory

Parameters: Hard coded path to xml files. 
 
Actuality: no


## checkForDoubleDataNameXML.ps1

Check for double tag <Data> in XML Form
Check for file is valid XML 


Parameter: XML File Name
Actuality: actual

## classComputer.ps1

Test, how to write and use classes in PowerShell.
Actuality: no


## Consolidate-StudentFolders.ps1

Script written for : Michal Brosh
Utility to consolidate [applicants] data and files from document library and [ResponseLetters] to site 
[https://portals2.ekmd.huji.ac.il/home/humanities/stdFoldersMA]

with creating user's document library structure 

Using xml file: .\ConsolidateFolders\Consolidate-Brosh.xml

Actuality: actual

Parameters : no




## Copy-ADGroupMembersToADGroup.ps1

Copy members of source AD Group to another AD Group
Parameters : Hard coded
Actuality: little


## Copy-ADGrp2ADGrp.ps1

Copy members of source AD Group to another AD Group

Script asks names of source and destination AD group and copies from source to destination.
Parameters: No
Actuality: actual

## Copy-ADMembersToSPGroup.ps1

Copy users from AD Group TSS_ARS10-2020_applicantsUG to ARS10_2020_Applicants_SP
Parameters: No
Actuality: no

## Copy-ArchiveList.ps1

Script creates new items in AvailableXYZarchive 
Script reads [availableArchives] on [https://portals.ekmd.huji.ac.il/home/huca/spSupport] site
and check if record exists in [AvailableXYZarchive] 
and creates item in [AvailableXYZarchive ]
Actuality: actual

## Copy-FinalListToNewSites.ps1

Script Copies [GRS] [Final] List structure from Old Site To New Site
Hello Asher,

On the SSW site in GRS, you need to create columns in the Final Folders, like on last year's sites.

Thanks,
Daniel
27.01.2022

Actuality: No

## Copy-FinalSingleList.ps1

Script Reorder form fields in destination  [GSS] [Final] 
[https://gss2.ekmd.huji.ac.il/home/general/GEN31-2021]
as in source
[https://gss2.ekmd.huji.ac.il/home/general/GEN32-2022]
Actuality: No


## Copy-LisItems2ListItems.ps1
Destination site [https://portals2.ekmd.huji.ac.il/home/tap/CSE/CSE13-2023] was restored By Sergey Rubin 

Script copies items from site [https://portals2.ekmd.huji.ac.il/home/tap/CSE/CSE12-2022]
List: [coursesList]

to Destination site: [https://portals2.ekmd.huji.ac.il/home/tap/CSE/CSE13-2023]
List: [coursesList]

This is because this needed list was accidentally cleared by mistake

Actuality: Little

## copy-list.ps1

Copy hard coded List from one site to another

Actuality: No


## Copy-List2List.ps1

Copy hard coded list structure from one list to another
Actuality: No


## Copy-PageWP.ps1

Copy Web part properties between page's sites
Actuality: No


## Copy-ViewListToList.ps1
Problem: sometimes on archive mihzur list with lookup fields view on list breaks and not show correctly
this is because on archive site field with lookup replaces to text field (fld delete with lookup and creates new with same name and type Text)

This script copies view from Mihzur source to Archive .

Parameters: Hard coded

Actuality: actual

## Create-AddiitionalViews.ps1

Creates views and navigations for previous period for lists
Lists in file .\Diego\ViewLists.txt

URL;SUFFIX;List;PrevArchiveName;PrevYear;CurrentYear;mainViewName
https://forms2.ekmd.huji.ac.il/home/;socialWork;FRM_SSW24_List;2021;2022;2023;כל הפריטים
https://forms2.ekmd.huji.ac.il/home/;socialWork;FRM_SSW13_List;2021;2022;2023;עדכני
https://forms2.ekmd.huji.ac.il/home/;socialWork;FRM_SSW05_List;2021;2022;2023;עדכני
https://forms2.ekmd.huji.ac.il/home/;socialWork;FRM_SSW06_List;2021;2022;2023;עדכני
https://forms2.ekmd.huji.ac.il/home/;socialWork;FRM_SSW07_List;2021;2022;2023;עדכני
https://forms2.ekmd.huji.ac.il/home/;socialWork;FRM_SSW08_List;2021;2022;2023;עדכני
https://forms2.ekmd.huji.ac.il/home/;socialWork;FRM_SSW09_List;2021;2022;2023;עדכני


/*
Dear staff, Hello

Thank you for storing the forms of the current year and opening a new folder for the forms in the system belonging to the professional training

- Insertion of Social Involvement - Year A Pages - Insertion Form - Social Involvement (huji.ac.il)
- Questionnaire for a candidate for student guidance in vocational training - Pages - FRM_SSW19 (huji.ac.il)
Placement in vocational training - Community major - Second year graduate Pages - Placement in vocational training - Community major - Second year (huji.ac.il)
- Placement in vocational training - Community major - 3rd year graduate Pages - Placement in vocational training - Community major - third year (huji.ac.il)
- Placement in vocational training - Individual major - Second-year graduate / Completion for a master's degree - one year Pages - Placement in vocational training - Individual major - Second year (huji.ac.il)
Placement in vocational training - Individual major - Third-year graduate / Completion for a master's degree - Year in pages - Placement in vocational training - Individual major - Third year (huji.ac.il)
- Feedback questionnaire on professional training Pages - FRM_SSW13 (huji.ac.il)
- Social Involvement - Student Feedback Pages - Social Involvement - Student Feedback (huji.ac.il)
- Assessment of Social Involvement - Pages - Assessment of Social Involvement (huji.ac.il)
- Placement in vocational training outside Jerusalem - individual trend - Pages - Placement in vocational training outside Jerusalem - individual course (huji.ac.il)

https://forms2.ekmd.huji.ac.il/home/socialWork/Lists/FRM_SSW30_List/AllItems.aspx



*/
Last changed 29/01/23

Actuality: actual


## create-BigList.ps1

Test for create big list with Huge count of columns and rows

Actuality: no

## Create-DocLib.ps1

Script creates Document librarie for site :
[https://ttp2.ekmd.huji.ac.il/home/Humanities/HUM27-2021/]

List of Libs:
- "Islam in South Asia"
- "Comparative Literature"
- "Hebrew Literature"
- "Islamic and Middle Eastern"
- "Linguistics"  
- "Musicology"
- "Spanish and Latin American Studies"


Actuality: little





## Create-DocumentsUploadPage.ps1

Script to create Blank Document Upload Page  on multiple sites from scratch

Parameters: Hard coded
Next step: Add and tune  to page web parts 

Actuality: little



## create-list.ps1

Create lists and structure 

Parameters : hard coded
Actuality: No


## del-AllListItems.ps1

Script deletes all items in list

Parameters" Site name, List Name
Actuality: Little


## Delete-ADGroupMembers.ps1

Removes all group members from  [GSS_GEN35-2022_applicants-*] (15) groups 



-GSS_GEN35-2022_applicants-agrUG
-GSS_GEN35-2022_applicants-appphysUG
-GSS_GEN35-2022_applicants-bioUG
-GSS_GEN35-2022_applicants-chemUG
-GSS_GEN35-2022_applicants-cseUG
-GSS_GEN35-2022_applicants-dntUG
-GSS_GEN35-2022_applicants-earthUG
-GSS_GEN35-2022_applicants-elscUG
-GSS_GEN35-2022_applicants-mathUG
-GSS_GEN35-2022_applicants-medUG
-GSS_GEN35-2022_applicants-pharmUG
-GSS_GEN35-2022_applicants-physUG
-GSS_GEN35-2022_applicants-psyUG
-GSS_GEN35-2022_applicants-statUG
-GSS_GEN35-2022_applicants-vetUG
Actuality: Little

## Delete-SubSites.ps1

Problem: sometimes is impossible delete Mihzur subsite from web interface  cause of big items count in list(s)
This script clears items and applicants Document Libraries

Parameter: Name of main site. 
Script shows list of subsites and menu to delete one of them,

Actuality: Little

## Delete-UsersFromSPGroup.ps1

Deletes AD users from Hard Coded SP groups
Prompts and warnings before delete users
Actuality: Little

## Delete-UsersLibs.ps1

Deletes applicants Document Libraries frpm hard coded site
Actuality: Little


## Find-Contractors.ps1

Find contractor from List [contractors] on sites :

- https://crs.ekmd.huji.ac.il/home/services/2019
- https://crs2.ekmd.huji.ac.il/home/exempt/2019
- https://crs2.ekmd.huji.ac.il/home/murshe/2019

Parameter: Hard coded contractor id

Output:  Link to item with Contractor's ID and is PDF for contractor exists?
=========================
https://crs2.ekmd.huji.ac.il/home/murshe/2019/Lists/contractors/EditForm.aspx?ID=3767
Contractor from Param             :  516748548
studentId  in SP List contractors :  516748548
PDF File                          :  516748548  .pdf
=========================

Actuality: actual

## get-allccUsers.ps1

Get all cc users in domain savion
Actuality: no

## Get-Comments.ps1

Shows comments from Powershell file with powershell format .Synopsys

Example:

 .\Get-Comments.ps1 .\Utils-Request.ps1
 *******************************
Get-GroupSuffix
*******************************
Get-GroupSuffix
.SYNOPSIS
Get-GroupSuffix extracts the suffix of a group name.

.DESCRIPTION
Get-GroupSuffix is a PowerShell function that extracts the suffix of a group name
by removing the group template from the name. The function expects a single parameter,
$groupName, which is the name of the group to extract the suffix from.
The function first calls get-GroupTemplate to obtain the group template from the name.
It then removes the template from the name and returns the resulting suffix.
If the suffix contains an underscore, the function truncates it to exclude the last character.

.PARAMETER groupName
The name of the group to extract the suffix from.

.EXAMPLE
PS C:> Get-GroupSuffix "HSS_HUM218-2022"
HSS


This example extracts the suffix "XYZ" from the group name "GRP_ABC_DEF_XYZ".
.NOTES
Author: Asher Sandler

*******************************
Change-GroupDescription
*******************************
Change-GroupDescription
.SYNOPSIS
Updates the description of an Active Directory group.

.DESCRIPTION
This function updates the description of an Active Directory group by using the Get-ADGroup and Set-ADGroup cmdlets provided by PowerShell.
It takes in the name of the group and the new description as input parameters.

.PARAMETER groupName
A string parameter that represents the name of the Active Directory group whose description will be updated.

.PARAMETER description
A string parameter that represents the new description that will be set for the group.

.EXAMPLE
Change-GroupDescription "Sales Group" "This group is for sales representatives"
This command will update the description of the "Sales Group" to "This group is for sales representatives".

.NOTES
Author: Asher Sandler
Actuality: Little

## get-doclib.ps1

Hides applicants Document libraries from navigation menu

Parameters: Hard coded site name
Actuality: Little


## get-doclibItems.ps1

Check are existing applicants Doclib on site?
Actuality: no
Parameter" Hard coded site name
Actuality: No

## get-DocumentsFillFinal.ps1

Consolidate to site Education information from various edu sites.
Destination: [https://portals2.ekmd.huji.ac.il/home/EDU/stdFolders]

Source sites specified in file [finalList.csv]


Structure of file:

site,lib,destFolder,potok
-https://grs2.ekmd.huji.ac.il/home/Education/EDU62-2022/Archive-2022-12-08/,Final,238-EDU62-2022,238
-https://grs2.ekmd.huji.ac.il/home/Education/EDU61-2021/Archive-2022-11-25/,Final,245-EDU61-2021,245
-https://grs2.ekmd.huji.ac.il/home/Education/EDU69-2022/,Final,245-EDU69-2022,245
-https://grs2.ekmd.huji.ac.il/home/Education/EDU68-2022/Archive-2022-12-08/,237,237-EDU68-2022,237 - מסלול מנהיגות בית ספרית
-https://grs2.ekmd.huji.ac.il/home/Education/EDU65-2022/Archive-2022-12-08/,Final,243-EDU65-2022,243
-https://grs2.ekmd.huji.ac.il/home/Education/EDU66-2022/Archive-2022-12-08/,Final,240-EDU66-2022,240
-https://grs2.ekmd.huji.ac.il/home/Education/EDU67-2022/Archive-2022-12-08/,Final,239-EDU67-2022,239
-https://grs2.ekmd.huji.ac.il/home/Education/EDU68-2022/Archive-2022-12-08/,230,230-EDU68-2022,230
-https://grs2.ekmd.huji.ac.il/home/Education/EDU68-2022/Archive-2022-12-08/,241,241-EDU68-2022,241
-https://grs2.ekmd.huji.ac.il/home/Education/EDU68-2022/Archive-2022-12-08/,242,242-EDU68-2022,242

Actuality: actual

## get-DocUploadWP.ps1

Get web part properties of web page [DocumentsUpload]

Actuality: no

## Get-DuplicateFiles.ps1

Search and display Big size duplicate files with various names on drive c:\ and subdirs:
Search and grouping by FileHash
Parameter: No
Example Output:

=============================
Size:  115133979
C:\Windows\servicing\LCU\Package_for_RollupFix~31bf3856ad364e35~amd64~~19041.3086.1.9\amd64_microsoft-windows-edgechromium_31bf3856ad364e35_10.0.19041.1266_none_74657031110a9d30\edge.wim
C:\Windows\servicing\LCU\Package_for_RollupFix~31bf3856ad364e35~amd64~~19041.3208.1.10\amd64_microsoft-windows-edgechromium_31bf3856ad364e35_10.0.19041.1266_none_74657031110a9d30\edge.wim
C:\Windows\WinSxS\amd64_microsoft-windows-edgechromium_31bf3856ad364e35_10.0.19041.1266_none_74657031110a9d30\Edge.wim

=============================

Actuality: actual

## get-FieldList.ps1

Generate c# meta data class by SP List xml schema

Output file: ["Template.cs"]

Actuality: no



## get-Fields.ps1

Generate c# and powershell meta data class 

Output file: ["Template.cs"] - c#
Output file: ["Template.txt"] - PowerShell

Parameters: Hard Coded Site and List name

-Example Output: C#


    partial class Applicant
    {
       public int ID { get; set; }
	   
			public string FileLeafRef { get; set; } // שם
			public string Title { get; set; } // כותרת
			public string description0 { get; set; } // description


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.FileLeafRef = (string)spItem["FileLeafRef"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow.description0 = (string)spItem["description0"];
           return ItemRow;
    }

    }

-Example Output: PowerShell


$Itm = "" | Select FileLeafRef,Title,description0,

$Itm.FileLeafRef = $fitm["FileLeafRef"] #שם
$Itm.Title = $fitm["Title"] #כותרת
$Itm.description0 = $fitm["description0"] #description

Actuality: Little

## get-Formfields.ps1

Reorder Krakover Form Fields Order

Actuality: Little

## Get-ItemByCaml.ps1

Find StudentID in [Contractor] list on sites:
- https://crs.ekmd.huji.ac.il/home/services/2019
- https://crs2.ekmd.huji.ac.il/home/exempt/2019
- https://crs2.ekmd.huji.ac.il/home/murshe/2019

Actuality: actual

## Get-ListOfListForClearInMihzur.ps1

Get List of non standart Lists and DocLibs for insert to AvailableXYZList
to field [Archive_Lists_Clear] for procedure [Do-ClearSite]
Actuality: actual

## get-listProps.ps1

Get list of site lists UIDs

Actuality: no

## get-ListSchema.ps1

Get XML List Schema in xml format
Actuality: little

## GET-SiteGroups.ps1

Count groups in site collection
Example using:
Site Collection URL:  https://scholarships.ekmd.huji.ac.il/home
Groups Per Site Collection Count:  2304
Users  Per Site Collection Count:  21192
Actuality: little


## get-SubmWP.ps1

Get Submission status page web part properties
Actuality: No

## get-UsersSamAccountName.ps1

Get users SAMs. Specific task written for Evgenia Tchachkin
Actuality: No
 

## HebName2ChrCodes.ps1

Convert Hebrew Characters to PowerShell CharCodes
Example:
> .\HebName2ChrCodes.ps1 טופל
 [char][int]1496 + [char][int]1493 + [char][int]1508 + [char][int]1500
Actuality: Little


## HexName2Heb.ps1

Convert HexName to Hebrew
Example:

"_x05de__x05d2__x05de__x05d4_"
מגמה
Actuality: Little



## Outlook-GetDoubleStudentsID.ps1


Finds and shows Multiple cc versus ekmd Student ID's in GRS Registration

One person with mltiple accounts

Example:

StudentID : 312547540
https://grs2.ekmd.huji.ac.il/home/SchoolofSocialWork/SSW45-2022/Lists/applicants/EditForm.aspx?ID=540
https://grs2.ekmd.huji.ac.il/home/SchoolofSocialWork/SSW45-2022/Lists/applicants/EditForm.aspx?ID=548
Actuality: actual

## replace-FieldInList.ps1

Utility to replace [applicants] with two deadlines

site: [https://grs2.ekmd.huji.ac.il/home/Agriculture/AGR13-2021]

Consult Daniel
Actuality: no

## Replace-LibEmail.ps1

Find applicants email in Lookup List and replace it.
site: [https://grs2.ekmd.huji.ac.il/home/Agriculture/AGR13-2021]
Actuality: no


## Restore-MihzurStudentFolder.ps1

Restore items and [applicants] Document Libraries  from Mihzur Archive
Actuality: no

## test-cred.ps1

Test

## test-CurrentSystem.ps1

Test

## test-EmptyTemplate.ps1

Empty Template

## Test-GetAllWP.ps1

Get all web part properties on page to JSON format

Output 
[
    {
        "Title":  "UploadFilesWP - VisualWebPart1",
        "Properties":  {
                           "Description":  "My Visual Web Part",
                           "Direction":  0,
                           "ChromeType":  2,
                           "ExportMode":  0,
                           "ChromeState":  0,
                           "AllowEdit":  true,
                           "AllowHide":  true,
                           "AllowClose":  true,
                           "AllowConnect":  true,
                           "AuthorizationFilter":  "",
                           "CatalogIconImageUrl":  "",
                           "AllowMinimize":  true,
                           "AllowZoneChange":  true,
                           "TitleUrl":  "",
                           "Title":  "UploadFilesWP - VisualWebPart1",
                           "TitleIconImageUrl":  "",
                           "Hidden":  false,
                           "HelpMode":  2,
                           "HelpUrl":  "",
                           "ImportErrorMessage":  "Cannot import this Web Part.",
                           "Config_Name":  "UploadFilesEn.xml",
                           "Config_Path":  "\\\\ekeksql00\\SP_Resources$\\HSS\\UploadFiles\\",
                           "Language":  2,
                           "AD_Config_Path":  null,
                           "Debug":  false,
                           "CSS_Path":  null,
                           "AD_Config_Name":  null
                       }
    },
    {
        "Title":  "LoaderWP - VisualWebPart1",
        "Properties":  {
                           "Description":  "My Visual Web Part",
                           "Direction":  0,
                           "ChromeType":  2,
                           "ExportMode":  0,
                           "ChromeState":  0,
                           "AllowEdit":  true,
                           "AllowHide":  true,
                           "AllowClose":  true,
                           "AllowConnect":  true,
                           "AuthorizationFilter":  "",
                           "CatalogIconImageUrl":  "",
                           "AllowMinimize":  true,
                           "AllowZoneChange":  true,
                           "TitleUrl":  "",
                           "Title":  "LoaderWP - VisualWebPart1",
                           "TitleIconImageUrl":  "",
                           "Hidden":  false,
                           "HelpMode":  2,
                           "HelpUrl":  "",
                           "ImportErrorMessage":  "Cannot import this Web Part.",
                           "Language":  0,
                           "LoaderText":  null
                       }
    }
]


## test-GetItemsPageRights.ps1

Get Roles on list

## Test-InteractIE.ps1

Test Invoke-RestMethod procedure

## Test-ListAssignPermissions.ps1

test Set Permission to list

## test-ListPermissions.ps1

Example:
URL: https://grs2.ekmd.huji.ac.il/home/socialSciences/SOC46-2022
Collect ListPermissions: /home/socialSciences/SOC46-2022/interviewPDF/Forms/AllItems.aspx
Permissions role Count: 3
  0

Name                                              Type PermissionLevels
   ----                                              ---- ----------------
GRS_SOC46-2022_AdminSP                 SharePointGroup Full Control
EKMD\grs_soc46-2022_judges-interviewug   SecurityGroup Read
System Account                                    User Full Control


## test-logGen.ps1

Test Log Generator for site

## test-navig.ps1
Test Create Navigation menu

## test-navig1.ps1
Test Create Navigation menu

## test-orderFields.ps1
Test-Reorder fields in form


## test-Rest.ps1

Test Rest query to page

## test-SaveAttachements.ps1

Test Save Attachement from List

## test-Subsites.ps1

Test is exists subsite

## Test-WebRequestForm.ps1

Test Invoke-WebRequest

## Test-windowsForm.ps1

Test Create Windows Form from PowerShell

## Utils-DualLanguage.ps1

More than 100 utils and functions

## Utils-Request.ps1
More than 100 utils and functions

## wokfl-parallel.ps1
Test Windows workflow


## Gen-Documents\Gen-Readme.ps1
documentation Generator.
This document created by [Gen-Readme.ps1] procedure

            ---=== THE END ===---