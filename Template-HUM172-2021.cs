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
	   
			public string ContentTypeId { get; set; } // מזהה סוג תוכן
			public string ContentType { get; set; } // סוג תוכן
			public string Title { get; set; } // כותרת
			public string Modified { get; set; } // השתנה
			public string Created { get; set; } // נוצר
			public string Author { get; set; } // נוצר על-ידי
			public string Editor { get; set; } // השתנה על-ידי
			public string _HasCopyDestinations { get; set; } // בעל יעדי העתקה
			public string _CopySource { get; set; } // מקור העתקה
			public string owshiddenversion { get; set; } // owshiddenversion
			public string WorkflowVersion { get; set; } // גירסת זרימת עבודה
			public string _UIVersion { get; set; } // גירסת ממשק משתמש
			public string _UIVersionString { get; set; } // גירסה
			public string Attachments { get; set; } // קבצים מצורפים
			public string _ModerationStatus { get; set; } // מצב אישור
			public string _ModerationComments { get; set; } // הערות המאשר
			public string Edit { get; set; } // ערוך
			public string LinkTitleNoMenu { get; set; } // כותרת
			public string LinkTitle { get; set; } // כותרת
			public string LinkTitle2 { get; set; } // כותרת
			public string SelectTitle { get; set; } // בחר
			public string InstanceID { get; set; } // מזהה מופע
			public string Order { get; set; } // סדר
			public string GUID { get; set; } // GUID
			public string WorkflowInstanceID { get; set; } // מזהה מופע של זרימת עבודה
			public string FileRef { get; set; } // נתיב כתובת URL
			public string FileDirRef { get; set; } // נתיב
			public string Last_x0020_Modified { get; set; } // השתנה
			public string Created_x0020_Date { get; set; } // נוצר
			public string FSObjType { get; set; } // סוג פריט
			public string SortBehavior { get; set; } // סוג מיון
			public string PermMask { get; set; } // מסיכת הרשאות אפקטיביות
			public string FileLeafRef { get; set; } // שם
			public string UniqueId { get; set; } // מזהה ייחודי
			public string SyncClientId { get; set; } // מזהה לקוח
			public string ProgId { get; set; } // ProgId
			public string ScopeId { get; set; } // ScopeId
			public string File_x0020_Type { get; set; } // סוג קובץ
			public string HTML_x0020_File_x0020_Type { get; set; } // סוג קובץ HTML
			public string _EditMenuTableStart { get; set; } // תחילת טבלה של תפריט עריכה
			public string _EditMenuTableStart2 { get; set; } // תחילת טבלה של תפריט עריכה
			public string _EditMenuTableEnd { get; set; } // סוף טבלה של תפריט עריכה
			public string LinkFilenameNoMenu { get; set; } // שם
			public string LinkFilename { get; set; } // שם
			public string LinkFilename2 { get; set; } // שם
			public string DocIcon { get; set; } // סוג
			public string ServerUrl { get; set; } // כתובת URL יחסית של השרת
			public string EncodedAbsUrl { get; set; } // כתובת URL מוחלטת מקודדת
			public string BaseName { get; set; } // שם הקובץ
			public string MetaInfo { get; set; } // חבילת מאפיינים
			public string _Level { get; set; } // רמה
			public string _IsCurrentVersion { get; set; } // הגירסה הנוכחית
			public string ItemChildCount { get; set; } // ספירת צאצאי פריטים
			public string FolderChildCount { get; set; } // ספירת צאצאי תיקיה
			public string AppAuthor { get; set; } // היישום נוצר על-ידי
			public string AppEditor { get; set; } // היישום השתנה על-ידי
			public string Required { get; set; } // Required
			public string FilesNumber { get; set; } // FilesNumber
			public string fromMail { get; set; } // fromMail
			public string source_field { get; set; } // source_field


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.ContentTypeId = (string)spItem["ContentTypeId"];
			ItemRow.ContentType = (string)spItem["ContentType"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow.Modified = (string)spItem["Modified"];
			ItemRow.Created = (string)spItem["Created"];
			ItemRow.Author = (string)spItem["Author"];
			ItemRow.Editor = (string)spItem["Editor"];
			ItemRow._HasCopyDestinations = (string)spItem["_HasCopyDestinations"];
			ItemRow._CopySource = (string)spItem["_CopySource"];
			ItemRow.owshiddenversion = (string)spItem["owshiddenversion"];
			ItemRow.WorkflowVersion = (string)spItem["WorkflowVersion"];
			ItemRow._UIVersion = (string)spItem["_UIVersion"];
			ItemRow._UIVersionString = (string)spItem["_UIVersionString"];
			ItemRow.Attachments = (string)spItem["Attachments"];
			ItemRow._ModerationStatus = (string)spItem["_ModerationStatus"];
			ItemRow._ModerationComments = (string)spItem["_ModerationComments"];
			ItemRow.Edit = (string)spItem["Edit"];
			ItemRow.LinkTitleNoMenu = (string)spItem["LinkTitleNoMenu"];
			ItemRow.LinkTitle = (string)spItem["LinkTitle"];
			ItemRow.LinkTitle2 = (string)spItem["LinkTitle2"];
			ItemRow.SelectTitle = (string)spItem["SelectTitle"];
			ItemRow.InstanceID = (string)spItem["InstanceID"];
			ItemRow.Order = (string)spItem["Order"];
			ItemRow.GUID = (string)spItem["GUID"];
			ItemRow.WorkflowInstanceID = (string)spItem["WorkflowInstanceID"];
			ItemRow.FileRef = (string)spItem["FileRef"];
			ItemRow.FileDirRef = (string)spItem["FileDirRef"];
			ItemRow.Last_x0020_Modified = (string)spItem["Last_x0020_Modified"];
			ItemRow.Created_x0020_Date = (string)spItem["Created_x0020_Date"];
			ItemRow.FSObjType = (string)spItem["FSObjType"];
			ItemRow.SortBehavior = (string)spItem["SortBehavior"];
			ItemRow.PermMask = (string)spItem["PermMask"];
			ItemRow.FileLeafRef = (string)spItem["FileLeafRef"];
			ItemRow.UniqueId = (string)spItem["UniqueId"];
			ItemRow.SyncClientId = (string)spItem["SyncClientId"];
			ItemRow.ProgId = (string)spItem["ProgId"];
			ItemRow.ScopeId = (string)spItem["ScopeId"];
			ItemRow.File_x0020_Type = (string)spItem["File_x0020_Type"];
			ItemRow.HTML_x0020_File_x0020_Type = (string)spItem["HTML_x0020_File_x0020_Type"];
			ItemRow._EditMenuTableStart = (string)spItem["_EditMenuTableStart"];
			ItemRow._EditMenuTableStart2 = (string)spItem["_EditMenuTableStart2"];
			ItemRow._EditMenuTableEnd = (string)spItem["_EditMenuTableEnd"];
			ItemRow.LinkFilenameNoMenu = (string)spItem["LinkFilenameNoMenu"];
			ItemRow.LinkFilename = (string)spItem["LinkFilename"];
			ItemRow.LinkFilename2 = (string)spItem["LinkFilename2"];
			ItemRow.DocIcon = (string)spItem["DocIcon"];
			ItemRow.ServerUrl = (string)spItem["ServerUrl"];
			ItemRow.EncodedAbsUrl = (string)spItem["EncodedAbsUrl"];
			ItemRow.BaseName = (string)spItem["BaseName"];
			ItemRow.MetaInfo = (string)spItem["MetaInfo"];
			ItemRow._Level = (string)spItem["_Level"];
			ItemRow._IsCurrentVersion = (string)spItem["_IsCurrentVersion"];
			ItemRow.ItemChildCount = (string)spItem["ItemChildCount"];
			ItemRow.FolderChildCount = (string)spItem["FolderChildCount"];
			ItemRow.AppAuthor = (string)spItem["AppAuthor"];
			ItemRow.AppEditor = (string)spItem["AppEditor"];
			ItemRow.Required = (string)spItem["Required"];
			ItemRow.FilesNumber = (string)spItem["FilesNumber"];
			ItemRow.fromMail = (string)spItem["fromMail"];
			ItemRow.source_field = (string)spItem["source_field"];
           return ItemRow;
    }

    }
}
