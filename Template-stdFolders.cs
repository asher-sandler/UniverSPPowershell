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
	   
			public string Title { get; set; } // שם פרטי
			public string FamilyName { get; set; } // שם משפחה
			public string StudentID { get; set; } // תעודת זהות
			public string Email { get; set; } // דוא"ל
			public string PhoneNumber { get; set; } // טלפון
			public string TreatmentStatus { get; set; } // סטטוס טיפול
			public string LinkToPersonalFolder { get; set; } // folderLink
			public string StudyStatus { get; set; } // סטטוס לימודים
			public string _x05e9__x05e0__x05ea__x0020__x05 { get; set; } // שנת לימודים
			public string _x05de__x05e7__x05e6__x05d5__x05 { get; set; } // מקצוע קבלה 1
			public string _x05de__x05e7__x05e6__x05d5__x050 { get; set; } // מקצוע קבלה 2
			public string _x05de__x05e7__x05e6__x05d5__x051 { get; set; } // מקצוע קבלה 3
			public string _x05e1__x05d5__x05d2__x0020__x05 { get; set; } // סוג מסלול
			public string _x05de__x05e1__x05dc__x05d5__x05 { get; set; } // מסלול
			public string Attachments { get; set; } // קבצים מצורפים


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow.FamilyName = (string)spItem["FamilyName"];
			ItemRow.StudentID = (string)spItem["StudentID"];
			ItemRow.Email = (string)spItem["Email"];
			ItemRow.PhoneNumber = (string)spItem["PhoneNumber"];
			ItemRow.TreatmentStatus = (string)spItem["TreatmentStatus"];
			ItemRow.LinkToPersonalFolder = (string)spItem["LinkToPersonalFolder"];
			ItemRow.StudyStatus = (string)spItem["StudyStatus"];
			ItemRow._x05e9__x05e0__x05ea__x0020__x05 = (string)spItem["_x05e9__x05e0__x05ea__x0020__x05"];
			ItemRow._x05de__x05e7__x05e6__x05d5__x05 = (string)spItem["_x05de__x05e7__x05e6__x05d5__x05"];
			ItemRow._x05de__x05e7__x05e6__x05d5__x050 = (string)spItem["_x05de__x05e7__x05e6__x05d5__x050"];
			ItemRow._x05de__x05e7__x05e6__x05d5__x051 = (string)spItem["_x05de__x05e7__x05e6__x05d5__x051"];
			ItemRow._x05e1__x05d5__x05d2__x0020__x05 = (string)spItem["_x05e1__x05d5__x05d2__x0020__x05"];
			ItemRow._x05de__x05e1__x05dc__x05d5__x05 = (string)spItem["_x05de__x05e1__x05dc__x05d5__x05"];
			ItemRow.Attachments = (string)spItem["Attachments"];
           return ItemRow;
    }

    }
}
