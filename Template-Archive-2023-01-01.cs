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
			public string Attachments { get; set; } // קבצים מצורפים
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
			public string A { get; set; } // A
			public string lastSubmit { get; set; } // lastSubmit
			public string birthDate { get; set; } // birthDate
			public string birthCountry { get; set; } // birthCountry
			public string immigrationYear { get; set; } // immigrationYear
			public string firstDegreeInstitute { get; set; } // firstDegreeInstitute
			public string firstDegreeGraduationYear { get; set; } // firstDegreeGraduationYear
			public string firstDegreeDepartment1 { get; set; } // firstDegreeDepartment1
			public string firstDegreeDepartmentGrade1 { get; set; } // firstDegreeDepartmentGrade1
			public string firstDegreeDepartment2 { get; set; } // firstDegreeDepartment2
			public string firstDegreeDepartmentGrade2 { get; set; } // firstDegreeDepartmentGrade2
			public string finalDegreeGrade { get; set; } // finalDegreeGrade
			public string firstDegreeExpectedGraduationDat { get; set; } // firstDegreeExpectedGraduationDate
			public string firstDegreeMidGrade { get; set; } // firstDegreeMidGrade
			public string englishExemption { get; set; } // englishExemption
			public string englishExemptionCollege { get; set; } // englishExemptionCollege
			public string englishExemptionAmir { get; set; } // englishExemptionAmir
			public string masterDegreeInstitute { get; set; } // masterDegreeInstitute
			public string masterDegreeGraduationYear { get; set; } // masterDegreeGraduationYear
			public string masterDegreeStudyFields { get; set; } // masterDegreeStudyFields
			public string masterDegreeGrade { get; set; } // masterDegreeGrade
			public string department1 { get; set; } // department1
			public string department2 { get; set; } // department2
			public string department3 { get; set; } // department3
			public string department4 { get; set; } // department4
			public string declaration { get; set; } // declaration
			public string bachelorDegreeCountry { get; set; } // bachelorDegreeCountry
			public string coursesForMasterDegree { get; set; } // coursesForMasterDegree
			public string nonDegreeStudiesApproval { get; set; } // nonDegreeStudiesApproval
			public string _x05e1__x05d8__x05d8__x05d5__x05 { get; set; } // סטטוס
			public string _x05e1__x05d8__x05d8__x05d5__x050 { get; set; } // סטטוס קבלה
			public string _x05d4__x05e9__x05dc__x05de__x05 { get; set; } // השלמות
			public string _x05de__x05d3__x05e8__x05d9__x05 { get; set; } // מדריך
			public string _x05d4__x05d5__x05e2__x05d1__x05 { get; set; } // הועבר לחוג
			public string _x05d4__x05e2__x05d1__x05e8__x05 { get; set; } // העברתי לחוג
			public string digitalinfo { get; set; } // digitalinfo
			public string _x05d7__x05d5__x05d2__x0020__x05 { get; set; } // חוג קבלה למוסמך


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
			ItemRow.A = (string)spItem["A"];
			ItemRow.lastSubmit = (string)spItem["lastSubmit"];
			ItemRow.birthDate = (string)spItem["birthDate"];
			ItemRow.birthCountry = (string)spItem["birthCountry"];
			ItemRow.immigrationYear = (string)spItem["immigrationYear"];
			ItemRow.firstDegreeInstitute = (string)spItem["firstDegreeInstitute"];
			ItemRow.firstDegreeGraduationYear = (string)spItem["firstDegreeGraduationYear"];
			ItemRow.firstDegreeDepartment1 = (string)spItem["firstDegreeDepartment1"];
			ItemRow.firstDegreeDepartmentGrade1 = (string)spItem["firstDegreeDepartmentGrade1"];
			ItemRow.firstDegreeDepartment2 = (string)spItem["firstDegreeDepartment2"];
			ItemRow.firstDegreeDepartmentGrade2 = (string)spItem["firstDegreeDepartmentGrade2"];
			ItemRow.finalDegreeGrade = (string)spItem["finalDegreeGrade"];
			ItemRow.firstDegreeExpectedGraduationDat = (string)spItem["firstDegreeExpectedGraduationDat"];
			ItemRow.firstDegreeMidGrade = (string)spItem["firstDegreeMidGrade"];
			ItemRow.englishExemption = (string)spItem["englishExemption"];
			ItemRow.englishExemptionCollege = (string)spItem["englishExemptionCollege"];
			ItemRow.englishExemptionAmir = (string)spItem["englishExemptionAmir"];
			ItemRow.masterDegreeInstitute = (string)spItem["masterDegreeInstitute"];
			ItemRow.masterDegreeGraduationYear = (string)spItem["masterDegreeGraduationYear"];
			ItemRow.masterDegreeStudyFields = (string)spItem["masterDegreeStudyFields"];
			ItemRow.masterDegreeGrade = (string)spItem["masterDegreeGrade"];
			ItemRow.department1 = (string)spItem["department1"];
			ItemRow.department2 = (string)spItem["department2"];
			ItemRow.department3 = (string)spItem["department3"];
			ItemRow.department4 = (string)spItem["department4"];
			ItemRow.declaration = (string)spItem["declaration"];
			ItemRow.bachelorDegreeCountry = (string)spItem["bachelorDegreeCountry"];
			ItemRow.coursesForMasterDegree = (string)spItem["coursesForMasterDegree"];
			ItemRow.nonDegreeStudiesApproval = (string)spItem["nonDegreeStudiesApproval"];
			ItemRow._x05e1__x05d8__x05d8__x05d5__x05 = (string)spItem["_x05e1__x05d8__x05d8__x05d5__x05"];
			ItemRow._x05e1__x05d8__x05d8__x05d5__x050 = (string)spItem["_x05e1__x05d8__x05d8__x05d5__x050"];
			ItemRow._x05d4__x05e9__x05dc__x05de__x05 = (string)spItem["_x05d4__x05e9__x05dc__x05de__x05"];
			ItemRow._x05de__x05d3__x05e8__x05d9__x05 = (string)spItem["_x05de__x05d3__x05e8__x05d9__x05"];
			ItemRow._x05d4__x05d5__x05e2__x05d1__x05 = (string)spItem["_x05d4__x05d5__x05e2__x05d1__x05"];
			ItemRow._x05d4__x05e2__x05d1__x05e8__x05 = (string)spItem["_x05d4__x05e2__x05d1__x05e8__x05"];
			ItemRow.digitalinfo = (string)spItem["digitalinfo"];
			ItemRow._x05d7__x05d5__x05d2__x0020__x05 = (string)spItem["_x05d7__x05d5__x05d2__x0020__x05"];
           return ItemRow;
    }

    }
}
