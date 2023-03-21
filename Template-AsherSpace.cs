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
			public string FaqEn { get; set; } // FaqEn
			public string FaqHe { get; set; } // FaqHe
			public string FaqType { get; set; } // FaqType
			public string Attachments { get; set; } // Attachments


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow.FaqEn = (string)spItem["FaqEn"];
			ItemRow.FaqHe = (string)spItem["FaqHe"];
			ItemRow.FaqType = (string)spItem["FaqType"];
			ItemRow.Attachments = (string)spItem["Attachments"];
           return ItemRow;
    }

    }
}
