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
}
