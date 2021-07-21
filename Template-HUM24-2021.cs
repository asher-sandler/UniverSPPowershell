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
			public string Attachments { get; set; } // Attachments
			public string firstName { get; set; } // firstName
			public string surname { get; set; } // surname
			public string gender { get; set; } // gender
			public string citizenship { get; set; } // citizenship
			public string email { get; set; } // email
			public string homePhone { get; set; } // homePhone
			public string workPhone { get; set; } // workPhone
			public string cellPhone { get; set; } // cellPhone
			public string address { get; set; } // address
			public string country { get; set; } // country
			public string zip { get; set; } // zip
			public string academTitle { get; set; } // academTitle
			public string city { get; set; } // city
			public string state { get; set; } // state
			public string academTitleHe { get; set; } // academTitleHe
			public string firstNameHe { get; set; } // firstNameHe
			public string surnameHe { get; set; } // surnameHe
			public string IdHe { get; set; } // IdHe
			public string addressHe { get; set; } // addressHe
			public string countryHe { get; set; } // countryHe
			public string cityHe { get; set; } // cityHe
			public string zipHe { get; set; } // zipHe
			public string citizenshipHe { get; set; } // citizenshipHe
			public string userName { get; set; } // userName
			public string folderMail { get; set; } // folderMail
			public string genderHe { get; set; } // genderHe
			public string folderLink { get; set; } // folderLink
			public string birthYear { get; set; } // birthYear
			public string folderName { get; set; } // folderName
			public string studentId { get; set; } // studentId
			public string deadline { get; set; } // deadline
			public string mobile { get; set; } // mobile
			public string submit { get; set; } // submit
			public string documentsCopyFolder { get; set; } // documentsCopyFolder
			public string cvTitle { get; set; } // cvTitle
			public string birthDate { get; set; } // birthDate
			public string birthCountry { get; set; } // birthCountry
			public string nationality { get; set; } // nationality
			public string maritalStatus { get; set; } // maritalStatus
			public string immigrationDate { get; set; } // immigrationDate
			public string phone { get; set; } // phone
			public string specialization { get; set; } // specialization
			public string specialization2 { get; set; } // specialization2
			public string teachingSurveys { get; set; } // teachingSurveys
			public string hearAbout { get; set; } // hearAbout


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.Title = (string)spItem["Title"];
			ItemRow.Attachments = (string)spItem["Attachments"];
			ItemRow.firstName = (string)spItem["firstName"];
			ItemRow.surname = (string)spItem["surname"];
			ItemRow.gender = (string)spItem["gender"];
			ItemRow.citizenship = (string)spItem["citizenship"];
			ItemRow.email = (string)spItem["email"];
			ItemRow.homePhone = (string)spItem["homePhone"];
			ItemRow.workPhone = (string)spItem["workPhone"];
			ItemRow.cellPhone = (string)spItem["cellPhone"];
			ItemRow.address = (string)spItem["address"];
			ItemRow.country = (string)spItem["country"];
			ItemRow.zip = (string)spItem["zip"];
			ItemRow.academTitle = (string)spItem["academTitle"];
			ItemRow.city = (string)spItem["city"];
			ItemRow.state = (string)spItem["state"];
			ItemRow.academTitleHe = (string)spItem["academTitleHe"];
			ItemRow.firstNameHe = (string)spItem["firstNameHe"];
			ItemRow.surnameHe = (string)spItem["surnameHe"];
			ItemRow.IdHe = (string)spItem["IdHe"];
			ItemRow.addressHe = (string)spItem["addressHe"];
			ItemRow.countryHe = (string)spItem["countryHe"];
			ItemRow.cityHe = (string)spItem["cityHe"];
			ItemRow.zipHe = (string)spItem["zipHe"];
			ItemRow.citizenshipHe = (string)spItem["citizenshipHe"];
			ItemRow.userName = (string)spItem["userName"];
			ItemRow.folderMail = (string)spItem["folderMail"];
			ItemRow.genderHe = (string)spItem["genderHe"];
			ItemRow.folderLink = (string)spItem["folderLink"];
			ItemRow.birthYear = (string)spItem["birthYear"];
			ItemRow.folderName = (string)spItem["folderName"];
			ItemRow.studentId = (string)spItem["studentId"];
			ItemRow.deadline = (string)spItem["deadline"];
			ItemRow.mobile = (string)spItem["mobile"];
			ItemRow.submit = (string)spItem["submit"];
			ItemRow.documentsCopyFolder = (string)spItem["documentsCopyFolder"];
			ItemRow.cvTitle = (string)spItem["cvTitle"];
			ItemRow.birthDate = (string)spItem["birthDate"];
			ItemRow.birthCountry = (string)spItem["birthCountry"];
			ItemRow.nationality = (string)spItem["nationality"];
			ItemRow.maritalStatus = (string)spItem["maritalStatus"];
			ItemRow.immigrationDate = (string)spItem["immigrationDate"];
			ItemRow.phone = (string)spItem["phone"];
			ItemRow.specialization = (string)spItem["specialization"];
			ItemRow.specialization2 = (string)spItem["specialization2"];
			ItemRow.teachingSurveys = (string)spItem["teachingSurveys"];
			ItemRow.hearAbout = (string)spItem["hearAbout"];
           return ItemRow;
    }

    }
}
