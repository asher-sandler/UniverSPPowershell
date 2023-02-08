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
	   
			public string Title { get; set; } // Title
			public string url { get; set; } // url
			public string ScholarshipName { get; set; } // ScholarshipName
			public string mailSuffix { get; set; } // mailSuffix
			public string adminGroup { get; set; } // adminGroup
			public string deadline { get; set; } // deadline
			public string alert_x0020_date { get; set; } // alert date
			public string template { get; set; } // template
			public string folderName { get; set; } // folderName
			public string language { get; set; } // language
			public string applicantsGroup { get; set; } // applicantsGroup
			public string sort1 { get; set; } // sort1
			public string recommendationsDeadline { get; set; } // recommendationsDeadline
			public string State { get; set; } // State
			public string isCreated { get; set; } // isCreated
			public string SiteTitle { get; set; } // SiteTitle
			public string SiteDescription { get; set; } // SiteDescription
			public string AdminPermissions { get; set; } // AdminPermissions
			public string GlobalAapplicantGroup { get; set; } // GlobalAapplicantGroup
			public string Target_x0020_Audiences { get; set; } // Target Audiences
			public string _x05d4__x05d6__x05e0__x05ea__x00 { get; set; } // הזנת תכנים
			public string _x05d9__x05e6__x05d9__x05e8__x05 { get; set; } // יצירת תבנית לתיק מועמד
			public string _x05d1__x05d3__x05d9__x05e7__x05 { get; set; } // בדיקה עם משתמש
			public string _x05de__x05d5__x05db__x05df__x00 { get; set; } // מוכן לפרסום
			public string _x05d4__x05d2__x05d3__x05e8__x05 { get; set; } // הגדרת WP
			public string _x05d8__x05d5__x05e4__x05e1_ { get; set; } // טופס
			public string ScholarshipStartDate { get; set; } // ScholarshipStartDate
			public string mailContactDeleted { get; set; } // mailContactDeleted
			public string folderLink { get; set; } // folderLink
			public string contactEMail { get; set; } // contactEMail
			public string contactPhone { get; set; } // contactPhone
			public string faculty { get; set; } // faculty
			public string destinationList { get; set; } // destinationList
			public string relativeURL { get; set; } // relativeURL
			public string docType { get; set; } // docType
			public string adminGroupSP { get; set; } // adminGroupSP
			public string applicantsGroupSP { get; set; } // applicantsGroupSP
			public string Archive_Waiting_for_Archivation { get; set; } // Archive_Waiting_for_Archivation
			public string Archive_Archivation_Date { get; set; } // Archive_Archivation_Date
			public string Archive_URL { get; set; } // Archive_URL
			public string Archive_Site_Checked { get; set; } // Archive_Site_Checked
			public string Archive_Waiting_for_Cleanup { get; set; } // Archive_Waiting_for_Cleanup
			public string Archive_Cleanup_Date { get; set; } // Archive_Cleanup_Date
			public string Archive_Lists_Clear { get; set; } // Archive_Lists_Clear
			public string Archive_Lists_Delete { get; set; } // Archive_Lists_Delete
			public string Archive_Lists_Final { get; set; } // Archive_Lists_Final
			public string Attachments { get; set; } // Attachments


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow.url = (string)spItem["url"];
			ItemRow.ScholarshipName = (string)spItem["ScholarshipName"];
			ItemRow.mailSuffix = (string)spItem["mailSuffix"];
			ItemRow.adminGroup = (string)spItem["adminGroup"];
			ItemRow.deadline = (string)spItem["deadline"];
			ItemRow.alert_x0020_date = (string)spItem["alert_x0020_date"];
			ItemRow.template = (string)spItem["template"];
			ItemRow.folderName = (string)spItem["folderName"];
			ItemRow.language = (string)spItem["language"];
			ItemRow.applicantsGroup = (string)spItem["applicantsGroup"];
			ItemRow.sort1 = (string)spItem["sort1"];
			ItemRow.recommendationsDeadline = (string)spItem["recommendationsDeadline"];
			ItemRow.State = (string)spItem["State"];
			ItemRow.isCreated = (string)spItem["isCreated"];
			ItemRow.SiteTitle = (string)spItem["SiteTitle"];
			ItemRow.SiteDescription = (string)spItem["SiteDescription"];
			ItemRow.AdminPermissions = (string)spItem["AdminPermissions"];
			ItemRow.GlobalAapplicantGroup = (string)spItem["GlobalAapplicantGroup"];
			ItemRow.Target_x0020_Audiences = (string)spItem["Target_x0020_Audiences"];
			ItemRow._x05d4__x05d6__x05e0__x05ea__x00 = (string)spItem["_x05d4__x05d6__x05e0__x05ea__x00"];
			ItemRow._x05d9__x05e6__x05d9__x05e8__x05 = (string)spItem["_x05d9__x05e6__x05d9__x05e8__x05"];
			ItemRow._x05d1__x05d3__x05d9__x05e7__x05 = (string)spItem["_x05d1__x05d3__x05d9__x05e7__x05"];
			ItemRow._x05de__x05d5__x05db__x05df__x00 = (string)spItem["_x05de__x05d5__x05db__x05df__x00"];
			ItemRow._x05d4__x05d2__x05d3__x05e8__x05 = (string)spItem["_x05d4__x05d2__x05d3__x05e8__x05"];
			ItemRow._x05d8__x05d5__x05e4__x05e1_ = (string)spItem["_x05d8__x05d5__x05e4__x05e1_"];
			ItemRow.ScholarshipStartDate = (string)spItem["ScholarshipStartDate"];
			ItemRow.mailContactDeleted = (string)spItem["mailContactDeleted"];
			ItemRow.folderLink = (string)spItem["folderLink"];
			ItemRow.contactEMail = (string)spItem["contactEMail"];
			ItemRow.contactPhone = (string)spItem["contactPhone"];
			ItemRow.faculty = (string)spItem["faculty"];
			ItemRow.destinationList = (string)spItem["destinationList"];
			ItemRow.relativeURL = (string)spItem["relativeURL"];
			ItemRow.docType = (string)spItem["docType"];
			ItemRow.adminGroupSP = (string)spItem["adminGroupSP"];
			ItemRow.applicantsGroupSP = (string)spItem["applicantsGroupSP"];
			ItemRow.Archive_Waiting_for_Archivation = (string)spItem["Archive_Waiting_for_Archivation"];
			ItemRow.Archive_Archivation_Date = (string)spItem["Archive_Archivation_Date"];
			ItemRow.Archive_URL = (string)spItem["Archive_URL"];
			ItemRow.Archive_Site_Checked = (string)spItem["Archive_Site_Checked"];
			ItemRow.Archive_Waiting_for_Cleanup = (string)spItem["Archive_Waiting_for_Cleanup"];
			ItemRow.Archive_Cleanup_Date = (string)spItem["Archive_Cleanup_Date"];
			ItemRow.Archive_Lists_Clear = (string)spItem["Archive_Lists_Clear"];
			ItemRow.Archive_Lists_Delete = (string)spItem["Archive_Lists_Delete"];
			ItemRow.Archive_Lists_Final = (string)spItem["Archive_Lists_Final"];
			ItemRow.Attachments = (string)spItem["Attachments"];
           return ItemRow;
    }

    }
}
