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
			public string IdHe { get; set; } // IdHe
			public string userName { get; set; } // userName
			public string folderMail { get; set; } // folderMail
			public string folderLink { get; set; } // folderLink
			public string deadline { get; set; } // deadline
			public string folderName { get; set; } // folderName
			public string mobile { get; set; } // mobile
			public string studentId { get; set; } // studentId
			public string submit { get; set; } // submit
			public string documentsCopyFolder { get; set; } // documentsCopyFolder
			public string A { get; set; } // A
			public string firstNameHe { get; set; } // firstNameHe
			public string surnameHe { get; set; } // surnameHe
			public string genderEn { get; set; } // genderEn
			public string zipHe { get; set; } // zipHe
			public string phoneHe { get; set; } // phoneHe
			public string department1 { get; set; } // department1
			public string department2 { get; set; } // department2
			public string department3 { get; set; } // department3
			public string advisorName { get; set; } // advisorName
			public string firstDegreeInstitute { get; set; } // firstDegreeInstitute
			public string firstDegreeDepartment { get; set; } // firstDegreeDepartment
			public string firstDegreeGraduation { get; set; } // firstDegreeGraduation
			public string firstDegreeGrades { get; set; } // firstDegreeGrades
			public string declaration1 { get; set; } // declaration1
			public string declaration2 { get; set; } // declaration2
			public string genderHe { get; set; } // genderHe
			public string addressHe { get; set; } // addressHe
			public string cityHe { get; set; } // cityHe
			public string _x05d7__x05d5__x05d2__x0020__x05 { get; set; } // חוג קבלה 1
			public string _x05d7__x05d5__x05d2__x0020__x050 { get; set; } // חוג קבלה 2
			public string _x05e1__x05d8__x05d8__x05d5__x05 { get; set; } // סטטוס
			public string _x05d4__x05d7__x05dc__x05d8__x05 { get; set; } // החלטת החוג 1
			public string _x05d1__x05d5__x05e6__x05e2__x00 { get; set; } // בוצע רישום מקוון
			public string _x05d4__x05d7__x05dc__x05d8__x050 { get; set; } // החלטת החוג 2
			public string _x05ea__x05d0__x05e8__x05d9__x05 { get; set; } // תאריך העברה לחוג
			public string lastSubmit { get; set; } // lastSubmit
			public string _x05ea__x05e0__x05d0__x05d9__x00 { get; set; } // תנאי קבלה
			public string _x05d4__x05e2__x05e8__x05d5__x05 { get; set; } // הערות
			public string _x05ea__x05e0__x05d0__x05d9__x000 { get; set; } // תנאי קבלה - חוג 2
			public string academTitleHe { get; set; } // academTitleHe
			public string countryHe { get; set; } // countryHe
			public string citizenshipHe { get; set; } // citizenshipHe
			public string birthYear { get; set; } // birthYear
			public string department4 { get; set; } // department4
			public string _x05de__x05e0__x05d7__x05d4__x00 { get; set; } // מנחה חוג 1
			public string _x05de__x05e0__x05d7__x05d4__x000 { get; set; } // מנחה חוג 2
			public string _x05d0__x05d9__x05de__x05d5__x05 { get; set; } // אימות מסמכים
			public string _x05e2__x05d3__x05db__x05d5__x05 { get; set; } // עדכון הלשמות
			public string _x05e4__x05d8__x05d5__x05e8__x00 { get; set; } // פטור מאנגלית
			public string Attachments { get; set; } // Attachments
			public string _x05db__x05d5__x05ea__x05e8__x05 { get; set; } // כותרת


   public static Applicant bindItem(SPListItem spItem){
			Applicant ItemRow = new Applicant();

          ItemRow.ID = (int)spItem["ID"];
			ItemRow.Title = (string)spItem["Title"];
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
			ItemRow.IdHe = (string)spItem["IdHe"];
			ItemRow.userName = (string)spItem["userName"];
			ItemRow.folderMail = (string)spItem["folderMail"];
			ItemRow.folderLink = (string)spItem["folderLink"];
			ItemRow.deadline = (string)spItem["deadline"];
			ItemRow.folderName = (string)spItem["folderName"];
			ItemRow.mobile = (string)spItem["mobile"];
			ItemRow.studentId = (string)spItem["studentId"];
			ItemRow.submit = (string)spItem["submit"];
			ItemRow.documentsCopyFolder = (string)spItem["documentsCopyFolder"];
			ItemRow.A = (string)spItem["A"];
			ItemRow.firstNameHe = (string)spItem["firstNameHe"];
			ItemRow.surnameHe = (string)spItem["surnameHe"];
			ItemRow.genderEn = (string)spItem["genderEn"];
			ItemRow.zipHe = (string)spItem["zipHe"];
			ItemRow.phoneHe = (string)spItem["phoneHe"];
			ItemRow.department1 = (string)spItem["department1"];
			ItemRow.department2 = (string)spItem["department2"];
			ItemRow.department3 = (string)spItem["department3"];
			ItemRow.advisorName = (string)spItem["advisorName"];
			ItemRow.firstDegreeInstitute = (string)spItem["firstDegreeInstitute"];
			ItemRow.firstDegreeDepartment = (string)spItem["firstDegreeDepartment"];
			ItemRow.firstDegreeGraduation = (string)spItem["firstDegreeGraduation"];
			ItemRow.firstDegreeGrades = (string)spItem["firstDegreeGrades"];
			ItemRow.declaration1 = (string)spItem["declaration1"];
			ItemRow.declaration2 = (string)spItem["declaration2"];
			ItemRow.genderHe = (string)spItem["genderHe"];
			ItemRow.addressHe = (string)spItem["addressHe"];
			ItemRow.cityHe = (string)spItem["cityHe"];
			ItemRow._x05d7__x05d5__x05d2__x0020__x05 = (string)spItem["_x05d7__x05d5__x05d2__x0020__x05"];
			ItemRow._x05d7__x05d5__x05d2__x0020__x050 = (string)spItem["_x05d7__x05d5__x05d2__x0020__x050"];
			ItemRow._x05e1__x05d8__x05d8__x05d5__x05 = (string)spItem["_x05e1__x05d8__x05d8__x05d5__x05"];
			ItemRow._x05d4__x05d7__x05dc__x05d8__x05 = (string)spItem["_x05d4__x05d7__x05dc__x05d8__x05"];
			ItemRow._x05d1__x05d5__x05e6__x05e2__x00 = (string)spItem["_x05d1__x05d5__x05e6__x05e2__x00"];
			ItemRow._x05d4__x05d7__x05dc__x05d8__x050 = (string)spItem["_x05d4__x05d7__x05dc__x05d8__x050"];
			ItemRow._x05ea__x05d0__x05e8__x05d9__x05 = (string)spItem["_x05ea__x05d0__x05e8__x05d9__x05"];
			ItemRow.lastSubmit = (string)spItem["lastSubmit"];
			ItemRow._x05ea__x05e0__x05d0__x05d9__x00 = (string)spItem["_x05ea__x05e0__x05d0__x05d9__x00"];
			ItemRow._x05d4__x05e2__x05e8__x05d5__x05 = (string)spItem["_x05d4__x05e2__x05e8__x05d5__x05"];
			ItemRow._x05ea__x05e0__x05d0__x05d9__x000 = (string)spItem["_x05ea__x05e0__x05d0__x05d9__x000"];
			ItemRow.academTitleHe = (string)spItem["academTitleHe"];
			ItemRow.countryHe = (string)spItem["countryHe"];
			ItemRow.citizenshipHe = (string)spItem["citizenshipHe"];
			ItemRow.birthYear = (string)spItem["birthYear"];
			ItemRow.department4 = (string)spItem["department4"];
			ItemRow._x05de__x05e0__x05d7__x05d4__x00 = (string)spItem["_x05de__x05e0__x05d7__x05d4__x00"];
			ItemRow._x05de__x05e0__x05d7__x05d4__x000 = (string)spItem["_x05de__x05e0__x05d7__x05d4__x000"];
			ItemRow._x05d0__x05d9__x05de__x05d5__x05 = (string)spItem["_x05d0__x05d9__x05de__x05d5__x05"];
			ItemRow._x05e2__x05d3__x05db__x05d5__x05 = (string)spItem["_x05e2__x05d3__x05db__x05d5__x05"];
			ItemRow._x05e4__x05d8__x05d5__x05e8__x00 = (string)spItem["_x05e4__x05d8__x05d5__x05e8__x00"];
			ItemRow.Attachments = (string)spItem["Attachments"];
			ItemRow._x05db__x05d5__x05ea__x05e8__x05 = (string)spItem["_x05db__x05d5__x05ea__x05e8__x05"];
           return ItemRow;
    }

    }
}
