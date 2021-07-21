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
			public string Created { get; set; } // נוצר
			public string Author { get; set; } // נוצר על-ידי
			public string Modified { get; set; } // השתנה
			public string Editor { get; set; } // השתנה על-ידי
			public string _HasCopyDestinations { get; set; } // בעל יעדי העתקה
			public string _CopySource { get; set; } // מקור העתקה
			public string _ModerationStatus { get; set; } // מצב אישור
			public string _ModerationComments { get; set; } // הערות המאשר
			public string FileRef { get; set; } // נתיב כתובת URL
			public string FileDirRef { get; set; } // נתיב
			public string Last_x0020_Modified { get; set; } // השתנה
			public string Created_x0020_Date { get; set; } // נוצר
			public string File_x0020_Size { get; set; } // גודל הקובץ
			public string FSObjType { get; set; } // סוג פריט
			public string SortBehavior { get; set; } // סוג מיון
			public string PermMask { get; set; } // מסיכת הרשאות אפקטיביות
			public string CheckedOutUserId { get; set; } // מזהה של המשתמש שהוציא את הפריט
			public string IsCheckedoutToLocal { get; set; } // הוצא למקומי
			public string CheckoutUser { get; set; } // הוצא אל
			public string FileLeafRef { get; set; } // שם
			public string UniqueId { get; set; } // מזהה ייחודי
			public string SyncClientId { get; set; } // מזהה לקוח
			public string ProgId { get; set; } // ProgId
			public string ScopeId { get; set; } // ScopeId
			public string VirusStatus { get; set; } // מצב וירוס
			public string CheckedOutTitle { get; set; } // הוצא אל
			public string _CheckinComment { get; set; } // הערה לגבי הכנסת קבצים
			public string LinkCheckedOutTitle { get; set; } // הוצא אל
			public string Modified_x0020_By { get; set; } // המסמך שונה על-ידי
			public string Created_x0020_By { get; set; } // המסמך נוצר על-ידי
			public string File_x0020_Type { get; set; } // סוג קובץ
			public string HTML_x0020_File_x0020_Type { get; set; } // סוג קובץ HTML
			public string _SourceUrl { get; set; } // כתובת URL של המקור
			public string _SharedFileIndex { get; set; } // אינדקס קבצים משותפים
			public string _EditMenuTableStart { get; set; } // תחילת טבלה של תפריט עריכה
			public string _EditMenuTableStart2 { get; set; } // תחילת טבלה של תפריט עריכה
			public string _EditMenuTableEnd { get; set; } // סוף טבלה של תפריט עריכה
			public string LinkFilenameNoMenu { get; set; } // שם
			public string LinkFilename { get; set; } // שם
			public string LinkFilename2 { get; set; } // שם
			public string DocIcon { get; set; } // סוג
			public string ServerUrl { get; set; } // כתובת URL יחסית של השרת
			public string EncodedAbsUrl { get; set; } // כתובת URL מוחלטת מקודדת
			public string BaseName { get; set; } // שם
			public string FileSizeDisplay { get; set; } // גודל הקובץ
			public string MetaInfo { get; set; } // חבילת מאפיינים
			public string _Level { get; set; } // רמה
			public string _IsCurrentVersion { get; set; } // הגירסה הנוכחית
			public string ItemChildCount { get; set; } // ספירת צאצאי פריטים
			public string FolderChildCount { get; set; } // ספירת צאצאי תיקיה
			public string AppAuthor { get; set; } // היישום נוצר על-ידי
			public string AppEditor { get; set; } // היישום השתנה על-ידי
			public string SelectTitle { get; set; } // בחר
			public string SelectFilename { get; set; } // בחר
			public string Edit { get; set; } // ערוך
			public string owshiddenversion { get; set; } // owshiddenversion
			public string _UIVersion { get; set; } // גירסת ממשק משתמש
			public string _UIVersionString { get; set; } // גירסה
			public string InstanceID { get; set; } // מזהה מופע
			public string Order { get; set; } // סדר
			public string GUID { get; set; } // GUID
			public string WorkflowVersion { get; set; } // גירסת זרימת עבודה
			public string WorkflowInstanceID { get; set; } // מזהה מופע של זרימת עבודה
			public string ParentVersionString { get; set; } // גירסת מקור (מסמך שהומר)
			public string ParentLeafName { get; set; } // שם מקור (מסמך שהומר)
			public string DocConcurrencyNumber { get; set; } // מספר שיתוף פעולה של מסמך
			public string Title { get; set; } // כותרת
			public string TemplateUrl { get; set; } // קישור לתבנית
			public string xd_ProgID { get; set; } // קישור קובץ HTML
			public string xd_Signature { get; set; } // חתום
			public string Combine { get; set; } // מזג
			public string RepairDocument { get; set; } // קשר מחדש
			public string sentResponse { get; set; } // sentResponse
			public string _x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_ { get; set; } // תוכן קובץ


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.ContentTypeId = (string)spItem["ContentTypeId"];
			ItemRow.ContentType = (string)spItem["ContentType"];
			ItemRow.Created = (string)spItem["Created"];
			ItemRow.Author = (string)spItem["Author"];
			ItemRow.Modified = (string)spItem["Modified"];
			ItemRow.Editor = (string)spItem["Editor"];
			ItemRow._HasCopyDestinations = (string)spItem["_HasCopyDestinations"];
			ItemRow._CopySource = (string)spItem["_CopySource"];
			ItemRow._ModerationStatus = (string)spItem["_ModerationStatus"];
			ItemRow._ModerationComments = (string)spItem["_ModerationComments"];
			ItemRow.FileRef = (string)spItem["FileRef"];
			ItemRow.FileDirRef = (string)spItem["FileDirRef"];
			ItemRow.Last_x0020_Modified = (string)spItem["Last_x0020_Modified"];
			ItemRow.Created_x0020_Date = (string)spItem["Created_x0020_Date"];
			ItemRow.File_x0020_Size = (string)spItem["File_x0020_Size"];
			ItemRow.FSObjType = (string)spItem["FSObjType"];
			ItemRow.SortBehavior = (string)spItem["SortBehavior"];
			ItemRow.PermMask = (string)spItem["PermMask"];
			ItemRow.CheckedOutUserId = (string)spItem["CheckedOutUserId"];
			ItemRow.IsCheckedoutToLocal = (string)spItem["IsCheckedoutToLocal"];
			ItemRow.CheckoutUser = (string)spItem["CheckoutUser"];
			ItemRow.FileLeafRef = (string)spItem["FileLeafRef"];
			ItemRow.UniqueId = (string)spItem["UniqueId"];
			ItemRow.SyncClientId = (string)spItem["SyncClientId"];
			ItemRow.ProgId = (string)spItem["ProgId"];
			ItemRow.ScopeId = (string)spItem["ScopeId"];
			ItemRow.VirusStatus = (string)spItem["VirusStatus"];
			ItemRow.CheckedOutTitle = (string)spItem["CheckedOutTitle"];
			ItemRow._CheckinComment = (string)spItem["_CheckinComment"];
			ItemRow.LinkCheckedOutTitle = (string)spItem["LinkCheckedOutTitle"];
			ItemRow.Modified_x0020_By = (string)spItem["Modified_x0020_By"];
			ItemRow.Created_x0020_By = (string)spItem["Created_x0020_By"];
			ItemRow.File_x0020_Type = (string)spItem["File_x0020_Type"];
			ItemRow.HTML_x0020_File_x0020_Type = (string)spItem["HTML_x0020_File_x0020_Type"];
			ItemRow._SourceUrl = (string)spItem["_SourceUrl"];
			ItemRow._SharedFileIndex = (string)spItem["_SharedFileIndex"];
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
			ItemRow.FileSizeDisplay = (string)spItem["FileSizeDisplay"];
			ItemRow.MetaInfo = (string)spItem["MetaInfo"];
			ItemRow._Level = (string)spItem["_Level"];
			ItemRow._IsCurrentVersion = (string)spItem["_IsCurrentVersion"];
			ItemRow.ItemChildCount = (string)spItem["ItemChildCount"];
			ItemRow.FolderChildCount = (string)spItem["FolderChildCount"];
			ItemRow.AppAuthor = (string)spItem["AppAuthor"];
			ItemRow.AppEditor = (string)spItem["AppEditor"];
			ItemRow.SelectTitle = (string)spItem["SelectTitle"];
			ItemRow.SelectFilename = (string)spItem["SelectFilename"];
			ItemRow.Edit = (string)spItem["Edit"];
			ItemRow.owshiddenversion = (string)spItem["owshiddenversion"];
			ItemRow._UIVersion = (string)spItem["_UIVersion"];
			ItemRow._UIVersionString = (string)spItem["_UIVersionString"];
			ItemRow.InstanceID = (string)spItem["InstanceID"];
			ItemRow.Order = (string)spItem["Order"];
			ItemRow.GUID = (string)spItem["GUID"];
			ItemRow.WorkflowVersion = (string)spItem["WorkflowVersion"];
			ItemRow.WorkflowInstanceID = (string)spItem["WorkflowInstanceID"];
			ItemRow.ParentVersionString = (string)spItem["ParentVersionString"];
			ItemRow.ParentLeafName = (string)spItem["ParentLeafName"];
			ItemRow.DocConcurrencyNumber = (string)spItem["DocConcurrencyNumber"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow.TemplateUrl = (string)spItem["TemplateUrl"];
			ItemRow.xd_ProgID = (string)spItem["xd_ProgID"];
			ItemRow.xd_Signature = (string)spItem["xd_Signature"];
			ItemRow.Combine = (string)spItem["Combine"];
			ItemRow.RepairDocument = (string)spItem["RepairDocument"];
			ItemRow.sentResponse = (string)spItem["sentResponse"];
			ItemRow._x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_ = (string)spItem["_x05ea__x05d5__x05db__x05df__x0020__x05e7__x05d5__x05d1__x05e5_"];
           return ItemRow;
    }

    }
}
