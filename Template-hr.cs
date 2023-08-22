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
	   
			public string Title { get; set; } // כותרת
			public string hospital { get; set; } // ביה"ח
			public string department { get; set; } // מחלקה
			public string AcademicField { get; set; } // AcademicField
			public string employeeStatus { get; set; } // סטטוס
			public string rank { get; set; } // דרגה
			public string position { get; set; } // היקף התקן
			public string facultyCouncil { get; set; } // מועצת פקולטה
			public string appointmentsCommitteeDate { get; set; } // תאריך ישיבת ועדת מינויים
			public string academicSecretaryApproval { get; set; } // אישור מזכירות אקדמית/אמ"א
			public string hadassahApproval { get; set; } // אישור הדסה
			public string deanRequest { get; set; } // פנייה מדיקן
			public string appointmentBeforeDate { get; set; } // מינוי מתאריך
			public string appointmentUntilDate { get; set; } // מינוי עד תאריך
			public string employeeID { get; set; } // מספר זהות
			public string extensionAttribute5 { get; set; } // שם פרטי
			public string extensionAttribute6 { get; set; } // שם משפחה
			public string givenName { get; set; } // First Name
			public string sn { get; set; } // Surname
			public string sex { get; set; } // מין
			public string _x05ea__x05d0__x05e8__x05d9__x05 { get; set; } // תאריך לידה
			public string mail { get; set; } // מייל
			public string telephoneNumber { get; set; } // טלפון
			public string cn { get; set; } // cn
			public string verification { get; set; } // verification
			public string _x05d4__x05e2__x05e8__x05d4__x00 { get; set; } // הערה 1
			public string _x05d4__x05e2__x05e8__x05d4__x000 { get; set; } // הערה 2
			public string EKMD { get; set; } // EKMD
			public string _x05e0__x05d1__x05d3__x05e7_ { get; set; } // נבדק
			public string physicalDeliveryOfficeName { get; set; } // physicalDeliveryOfficeName
			public string _x05d8__x05dc__x05e4__x05d5__x05 { get; set; } // טלפון 1
			public string _x05d8__x05dc__x05e4__x05d5__x050 { get; set; } // טלפון 2
			public string _x05db__x05ea__x05d5__x05d1__x05 { get; set; } // כתובת
			public string _x05d4__x05e2__x05e8__x05d4__x001 { get; set; } // הערה 0
			public string _x0049_D9 { get; set; } // ID9
			public string _x05ea__x05d5__x05d0__x05e8_ { get; set; } // תואר
			public string semel_derug { get; set; } // semel_derug
			public string folderLink { get; set; } // folderLink
			public string Attachments { get; set; } // קבצים מצורפים


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow.hospital = (string)spItem["hospital"];
			ItemRow.department = (string)spItem["department"];
			ItemRow.AcademicField = (string)spItem["AcademicField"];
			ItemRow.employeeStatus = (string)spItem["employeeStatus"];
			ItemRow.rank = (string)spItem["rank"];
			ItemRow.position = (string)spItem["position"];
			ItemRow.facultyCouncil = (string)spItem["facultyCouncil"];
			ItemRow.appointmentsCommitteeDate = (string)spItem["appointmentsCommitteeDate"];
			ItemRow.academicSecretaryApproval = (string)spItem["academicSecretaryApproval"];
			ItemRow.hadassahApproval = (string)spItem["hadassahApproval"];
			ItemRow.deanRequest = (string)spItem["deanRequest"];
			ItemRow.appointmentBeforeDate = (string)spItem["appointmentBeforeDate"];
			ItemRow.appointmentUntilDate = (string)spItem["appointmentUntilDate"];
			ItemRow.employeeID = (string)spItem["employeeID"];
			ItemRow.extensionAttribute5 = (string)spItem["extensionAttribute5"];
			ItemRow.extensionAttribute6 = (string)spItem["extensionAttribute6"];
			ItemRow.givenName = (string)spItem["givenName"];
			ItemRow.sn = (string)spItem["sn"];
			ItemRow.sex = (string)spItem["sex"];
			ItemRow._x05ea__x05d0__x05e8__x05d9__x05 = (string)spItem["_x05ea__x05d0__x05e8__x05d9__x05"];
			ItemRow.mail = (string)spItem["mail"];
			ItemRow.telephoneNumber = (string)spItem["telephoneNumber"];
			ItemRow.cn = (string)spItem["cn"];
			ItemRow.verification = (string)spItem["verification"];
			ItemRow._x05d4__x05e2__x05e8__x05d4__x00 = (string)spItem["_x05d4__x05e2__x05e8__x05d4__x00"];
			ItemRow._x05d4__x05e2__x05e8__x05d4__x000 = (string)spItem["_x05d4__x05e2__x05e8__x05d4__x000"];
			ItemRow.EKMD = (string)spItem["EKMD"];
			ItemRow._x05e0__x05d1__x05d3__x05e7_ = (string)spItem["_x05e0__x05d1__x05d3__x05e7_"];
			ItemRow.physicalDeliveryOfficeName = (string)spItem["physicalDeliveryOfficeName"];
			ItemRow._x05d8__x05dc__x05e4__x05d5__x05 = (string)spItem["_x05d8__x05dc__x05e4__x05d5__x05"];
			ItemRow._x05d8__x05dc__x05e4__x05d5__x050 = (string)spItem["_x05d8__x05dc__x05e4__x05d5__x050"];
			ItemRow._x05db__x05ea__x05d5__x05d1__x05 = (string)spItem["_x05db__x05ea__x05d5__x05d1__x05"];
			ItemRow._x05d4__x05e2__x05e8__x05d4__x001 = (string)spItem["_x05d4__x05e2__x05e8__x05d4__x001"];
			ItemRow._x0049_D9 = (string)spItem["_x0049_D9"];
			ItemRow._x05ea__x05d5__x05d0__x05e8_ = (string)spItem["_x05ea__x05d5__x05d0__x05e8_"];
			ItemRow.semel_derug = (string)spItem["semel_derug"];
			ItemRow.folderLink = (string)spItem["folderLink"];
			ItemRow.Attachments = (string)spItem["Attachments"];
           return ItemRow;
    }

    }
}
