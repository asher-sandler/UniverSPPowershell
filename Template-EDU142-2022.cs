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
			public string bi_Currency { get; set; } // bi_Currency
			public string bi_IsWinner { get; set; } // bi_IsWinner
			public string bi_Notes { get; set; } // bi_Notes
			public string bi_Reason { get; set; } // bi_Reason
			public string bi_ScholarshipReportDate { get; set; } // bi_ScholarshipReportDate
			public string bi_SumDistributed { get; set; } // bi_SumDistributed
			public string lastSubmit { get; set; } // lastSubmit
			public string BACurrentGradeAverage { get; set; } // BACurrentGradeAverage
			public string MAYearAMajor { get; set; } // MAYearAMajor
			public string MATrack { get; set; } // MATrack
			public string MACurrentGradeAverage { get; set; } // MACurrentGradeAverage
			public string MASeniorMajor { get; set; } // MASeniorMajor
			public string MASeniorTrack { get; set; } // MASeniorTrack
			public string MAPreviousYearScope { get; set; } // MAPreviousYearScope
			public string MASeniorCurrentGradeAverage { get; set; } // MASeniorCurrentGradeAverage
			public string MACurrentYearScope { get; set; } // MACurrentYearScope
			public string courseName { get; set; } // courseName
			public string courseNum { get; set; } // courseNum
			public string courseTeacher { get; set; } // courseTeacher
			public string seminarPaperGrade { get; set; } // seminarPaperGrade
			public string HUJIPast3YearScholarship { get; set; } // HUJIPast3YearScholarship
			public string scholarshipName { get; set; } // scholarshipName
			public string scholarshipYear { get; set; } // scholarshipYear
			public string scholarshipSum { get; set; } // scholarshipSum
			public string scholarshipName2 { get; set; } // scholarshipName2
			public string scholarshipYear2 { get; set; } // scholarshipYear2
			public string scholarshipSum2 { get; set; } // scholarshipSum2
			public string scholarshipName3 { get; set; } // scholarshipName3
			public string scholarshipYear3 { get; set; } // scholarshipYear3
			public string scholarshipSum3 { get; set; } // scholarshipSum3
			public string scholarshipName4 { get; set; } // scholarshipName4
			public string scholarshipYear4 { get; set; } // scholarshipYear4
			public string scholarshipSum4 { get; set; } // scholarshipSum4
			public string scholarshipName5 { get; set; } // scholarshipName5
			public string scholarshipYear5 { get; set; } // scholarshipYear5
			public string scholarshipSum5 { get; set; } // scholarshipSum5
			public string notes { get; set; } // notes
			public string thesisTitle { get; set; } // thesisTitle
			public string thesisAdviser { get; set; } // thesisAdviser
			public string stageAB { get; set; } // stageAB
			public string studyTitle { get; set; } // studyTitle
			public string studyAdviser { get; set; } // studyAdviser
			public string articleTitle { get; set; } // articleTitle
			public string articleSubject { get; set; } // articleSubject
			public string journalName { get; set; } // journalName
			public string publishDate { get; set; } // publishDate
			public string additionalAuthors { get; set; } // additionalAuthors


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
			ItemRow.bi_Currency = (string)spItem["bi_Currency"];
			ItemRow.bi_IsWinner = (string)spItem["bi_IsWinner"];
			ItemRow.bi_Notes = (string)spItem["bi_Notes"];
			ItemRow.bi_Reason = (string)spItem["bi_Reason"];
			ItemRow.bi_ScholarshipReportDate = (string)spItem["bi_ScholarshipReportDate"];
			ItemRow.bi_SumDistributed = (string)spItem["bi_SumDistributed"];
			ItemRow.lastSubmit = (string)spItem["lastSubmit"];
			ItemRow.BACurrentGradeAverage = (string)spItem["BACurrentGradeAverage"];
			ItemRow.MAYearAMajor = (string)spItem["MAYearAMajor"];
			ItemRow.MATrack = (string)spItem["MATrack"];
			ItemRow.MACurrentGradeAverage = (string)spItem["MACurrentGradeAverage"];
			ItemRow.MASeniorMajor = (string)spItem["MASeniorMajor"];
			ItemRow.MASeniorTrack = (string)spItem["MASeniorTrack"];
			ItemRow.MAPreviousYearScope = (string)spItem["MAPreviousYearScope"];
			ItemRow.MASeniorCurrentGradeAverage = (string)spItem["MASeniorCurrentGradeAverage"];
			ItemRow.MACurrentYearScope = (string)spItem["MACurrentYearScope"];
			ItemRow.courseName = (string)spItem["courseName"];
			ItemRow.courseNum = (string)spItem["courseNum"];
			ItemRow.courseTeacher = (string)spItem["courseTeacher"];
			ItemRow.seminarPaperGrade = (string)spItem["seminarPaperGrade"];
			ItemRow.HUJIPast3YearScholarship = (string)spItem["HUJIPast3YearScholarship"];
			ItemRow.scholarshipName = (string)spItem["scholarshipName"];
			ItemRow.scholarshipYear = (string)spItem["scholarshipYear"];
			ItemRow.scholarshipSum = (string)spItem["scholarshipSum"];
			ItemRow.scholarshipName2 = (string)spItem["scholarshipName2"];
			ItemRow.scholarshipYear2 = (string)spItem["scholarshipYear2"];
			ItemRow.scholarshipSum2 = (string)spItem["scholarshipSum2"];
			ItemRow.scholarshipName3 = (string)spItem["scholarshipName3"];
			ItemRow.scholarshipYear3 = (string)spItem["scholarshipYear3"];
			ItemRow.scholarshipSum3 = (string)spItem["scholarshipSum3"];
			ItemRow.scholarshipName4 = (string)spItem["scholarshipName4"];
			ItemRow.scholarshipYear4 = (string)spItem["scholarshipYear4"];
			ItemRow.scholarshipSum4 = (string)spItem["scholarshipSum4"];
			ItemRow.scholarshipName5 = (string)spItem["scholarshipName5"];
			ItemRow.scholarshipYear5 = (string)spItem["scholarshipYear5"];
			ItemRow.scholarshipSum5 = (string)spItem["scholarshipSum5"];
			ItemRow.notes = (string)spItem["notes"];
			ItemRow.thesisTitle = (string)spItem["thesisTitle"];
			ItemRow.thesisAdviser = (string)spItem["thesisAdviser"];
			ItemRow.stageAB = (string)spItem["stageAB"];
			ItemRow.studyTitle = (string)spItem["studyTitle"];
			ItemRow.studyAdviser = (string)spItem["studyAdviser"];
			ItemRow.articleTitle = (string)spItem["articleTitle"];
			ItemRow.articleSubject = (string)spItem["articleSubject"];
			ItemRow.journalName = (string)spItem["journalName"];
			ItemRow.publishDate = (string)spItem["publishDate"];
			ItemRow.additionalAuthors = (string)spItem["additionalAuthors"];
           return ItemRow;
    }

    }
}
