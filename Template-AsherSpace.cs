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
	   
			public string ContentTypeId { get; set; } // Content Type ID
			public string Title { get; set; } // שם פרטי
			public string _ModerationComments { get; set; } // Approver Comments
			public string PermMask { get; set; } // Effective Permissions Mask
			public string File_x0020_Type { get; set; } // File Type
			public string LinkTitleNoMenu { get; set; } // שם פרטי
			public string LinkTitle { get; set; } // שם פרטי
			public string LinkTitle2 { get; set; } // שם פרטי
			public string StudentID { get; set; } // תעודת זהות
			public string FamilyName { get; set; } // שם משפחה
			public string Email { get; set; } // דוא"ל
			public string PhoneNumber { get; set; } // טלפון
			public string LinkToPersonalFolder { get; set; } // קישור לתיק אישי
			public string BeginningOfStudies { get; set; } // תחילת לימודים
			public string FirstGrade { get; set; } // תואר ראשון
			public string _x05ea__x05e2__x05d5__x05d3__x05 { get; set; } // תעודת זהות
			public string _x05d8__x05dc__x05e4__x05d5__x05 { get; set; } // טלפון
			public string ContentType { get; set; } // Content Type
			public string Modified { get; set; } // Modified
			public string Created { get; set; } // Created
			public string Author { get; set; } // Created By
			public string Editor { get; set; } // Modified By
			public string _HasCopyDestinations { get; set; } // Has Copy Destinations
			public string _CopySource { get; set; } // Copy Source
			public string owshiddenversion { get; set; } // owshiddenversion
			public string WorkflowVersion { get; set; } // Workflow Version
			public string _UIVersion { get; set; } // UI Version
			public string _UIVersionString { get; set; } // Version
			public string Attachments { get; set; } // Attachments
			public string _ModerationStatus { get; set; } // Approval Status
			public string Edit { get; set; } // Edit
			public string SelectTitle { get; set; } // Select
			public string InstanceID { get; set; } // Instance ID
			public string Order { get; set; } // Order
			public string GUID { get; set; } // GUID
			public string WorkflowInstanceID { get; set; } // Workflow Instance ID
			public string FileRef { get; set; } // URL Path
			public string FileDirRef { get; set; } // Path
			public string Last_x0020_Modified { get; set; } // Modified
			public string Created_x0020_Date { get; set; } // Created
			public string FSObjType { get; set; } // Item Type
			public string SortBehavior { get; set; } // Sort Type
			public string FileLeafRef { get; set; } // Name
			public string UniqueId { get; set; } // Unique Id
			public string SyncClientId { get; set; } // Client Id
			public string ProgId { get; set; } // ProgId
			public string ScopeId { get; set; } // ScopeId
			public string HTML_x0020_File_x0020_Type { get; set; } // HTML File Type
			public string _EditMenuTableStart { get; set; } // Edit Menu Table Start
			public string _EditMenuTableStart2 { get; set; } // Edit Menu Table Start
			public string _EditMenuTableEnd { get; set; } // Edit Menu Table End
			public string LinkFilenameNoMenu { get; set; } // Name
			public string LinkFilename { get; set; } // Name
			public string LinkFilename2 { get; set; } // Name
			public string DocIcon { get; set; } // Type
			public string ServerUrl { get; set; } // Server Relative URL
			public string EncodedAbsUrl { get; set; } // Encoded Absolute URL
			public string BaseName { get; set; } // File Name
			public string MetaInfo { get; set; } // Property Bag
			public string _Level { get; set; } // Level
			public string _IsCurrentVersion { get; set; } // Is Current Version
			public string ItemChildCount { get; set; } // Item Child Count
			public string FolderChildCount { get; set; } // Folder Child Count
			public string AppAuthor { get; set; } // App Created By
			public string AppEditor { get; set; } // App Modified By


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.ContentTypeId = (string)spItem["ContentTypeId"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow._ModerationComments = (string)spItem["_ModerationComments"];
			ItemRow.PermMask = (string)spItem["PermMask"];
			ItemRow.File_x0020_Type = (string)spItem["File_x0020_Type"];
			ItemRow.LinkTitleNoMenu = (string)spItem["LinkTitleNoMenu"];
			ItemRow.LinkTitle = (string)spItem["LinkTitle"];
			ItemRow.LinkTitle2 = (string)spItem["LinkTitle2"];
			ItemRow.StudentID = (string)spItem["StudentID"];
			ItemRow.FamilyName = (string)spItem["FamilyName"];
			ItemRow.Email = (string)spItem["Email"];
			ItemRow.PhoneNumber = (string)spItem["PhoneNumber"];
			ItemRow.LinkToPersonalFolder = (string)spItem["LinkToPersonalFolder"];
			ItemRow.BeginningOfStudies = (string)spItem["BeginningOfStudies"];
			ItemRow.FirstGrade = (string)spItem["FirstGrade"];
			ItemRow._x05ea__x05e2__x05d5__x05d3__x05 = (string)spItem["_x05ea__x05e2__x05d5__x05d3__x05"];
			ItemRow._x05d8__x05dc__x05e4__x05d5__x05 = (string)spItem["_x05d8__x05dc__x05e4__x05d5__x05"];
			ItemRow.ContentType = (string)spItem["ContentType"];
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
			ItemRow.Edit = (string)spItem["Edit"];
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
			ItemRow.FileLeafRef = (string)spItem["FileLeafRef"];
			ItemRow.UniqueId = (string)spItem["UniqueId"];
			ItemRow.SyncClientId = (string)spItem["SyncClientId"];
			ItemRow.ProgId = (string)spItem["ProgId"];
			ItemRow.ScopeId = (string)spItem["ScopeId"];
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
           return ItemRow;
    }

    }
}
