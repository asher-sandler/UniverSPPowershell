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
	   
			public string Title { get; set; } // Product
			public string productType { get; set; } // productType
			public string Cost { get; set; } // Cost
			public string Attachments { get; set; } // Attachments


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow.productType = (string)spItem["productType"];
			ItemRow.Cost = (string)spItem["Cost"];
			ItemRow.Attachments = (string)spItem["Attachments"];
           return ItemRow;
    }

    }
}
