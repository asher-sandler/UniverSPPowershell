function FindNotInSource($srcList,$dstList){
	$srcArr = $srcList.Split(",")
	$dstArr = $dstList.Split(",")
	$notFoundList=@()
	foreach($srcItm in $srcArr){
		$notFound = $true
		foreach($dstItm in $dstArr){
			if($srcItm -eq $dstItm){
				$notFound = $false
				break
			}
		}
		if ($notFound){
			$notFoundList += $srcItm
		}
	}
	return $notFoundList
}
$SrcAdmin32 = "SendToRakefet,submit,SugZehut,gender,birthCountry,registrationYear,Semester,israelStreet,israelStreetNumber,israelAppartmentNum,israelPOBox,israelCity,israelPostalCode,postalCode,country,phonePrefix,israelPhone,mobilePrefix,israelMobile,studentId,firstNameHe,surnameHe,israelStatus,birthCountryMother,birthCountryFather,educationMother,educationFather,RegistrationSource,SourceMaktakh,SourceOAU,fatherName,payment,atuda,studyPreferenceWaitingList1,studyPreferenceAppeal1,studyPreferenceTrack1,studyPreferenceWaitingList2,studyPreferenceAppeal2,studyPreferenceTrack2,studyPreferenceWaitingList3,studyPreferenceAppeal3,studyPreferenceTrack3,studyPreferenceWaitingList4,studyPreferenceAppeal4,studyPreferenceTrack4,studyPreferenceWaitingList5,studyPreferenceAppeal5,studyPreferenceTrack5,Title,citizenship,homePhone,workPhone,address,zip,academTitle,city,state,IdHe,userName,folderMail,deadline,folderName,documentsCopyFolder,previousFamilyName,motherName,streetNum,street,phone,guardianName,guardianAddress,guardianPhone,israelContactName,israelContactAddress,israelContactPhone,israelCareOf,careOfPhone,israelArrivalDate,dateOfBirth,A,file number,RakefetDone,psyNitePreviousPlace,psyNitePlannedPlace,psyNitePlannedID,SATReading,GREDate,GRESubject,hebrewSpeaking,hebrewReading,hebrewWriting,englishSpeaking,englishReading,englishWriting,appliedToHUJIYear,confirmationNumber,declaration1,declaration2,declaration3,secondarySchoolType,armyServiceDates,armyServiceCountry,SATEBRW,preparatoryAverage,RALAK,cellPhone,aditionalInfo - advisor"
$DstAdmin31 = "Title,Attachments,gender,citizenship,homePhone,workPhone,address,cellPhone,country,zip,academTitle,city,state,IdHe,userName,folderMail,deadline,folderName,studentId,submit,documentsCopyFolder,previousFamilyName,fatherName,motherName,streetNum,street,postalCode,phone,guardianName,guardianAddress,guardianPhone,israelContactName,israelContactAddress,israelContactPhone,israelPhone,firstNameHe,surnameHe,israelStreet,israelStreetNumber,israelCity,israelPostalCode,israelCareOf,careOfPhone,israelStatus,israelArrivalDate,dateOfBirth,birthCountry,birthCountryMother,birthCountryFather,file number,phonePrefix,mobilePrefix,israelMobile,israelAppartmentNum,israelPOBox,secondarySchoolType,armyServiceCountry,armyServiceDates,atuda,psyNitePreviousPlace,psyNitePlannedPlace,psyNitePlannedID,SATEBRW,GREDate,GRESubject,hebrewSpeaking,hebrewReading,hebrewWriting,englishSpeaking,englishReading,englishWriting,appliedToHUJIYear,confirmationNumber,declaration1,declaration2,declaration3,SugZehut,payment,Semester,RegistrationSource,SourceMaktakh,SourceOAU,registrationYear,educationMother,educationFather,A,SendToRakefet,RakefetDone,studyPreferenceWaitingList1,studyPreferenceWaitingList2,studyPreferenceWaitingList3,studyPreferenceWaitingList4,studyPreferenceWaitingList5,studyPreferenceAppeal1,studyPreferenceAppeal2,studyPreferenceAppeal3,studyPreferenceAppeal4,studyPreferenceAppeal5,studyPreferenceTrack1,studyPreferenceTrack2,studyPreferenceTrack3,studyPreferenceTrack4,studyPreferenceTrack5,letters sent,aditionalInfo - advisor,RakefetEdit,SATReading"

$SrcRakefet32 = "cellPhone,appliedToHUJI,appliedToHUJIStudentNum,aditionalInfo,letters sent,DayofUpdate,preference1Update,preference2Update,preference5Update,preference4Update,preference3Update,secondarySchoolName,secondarySchoolCountry,secondarySchoolGraduation,HighSchoolTrack,DiplomaAverage,HighSchoolDiplomaEquivalency,HighSchoolDiplomaOfficial,universityInstitute,universityCountry,universityDegree,universityDatesAttended,universityYearsNum,universityMajorAreasOfStudy,universityGraduationDate,universityAverage,UniveristyDocumentsOfficial,preparatoryProgramsInstitute,preparatoryProgramsName,preparatoryProgramsDates,PreparatoryTrack,preparatoryConfirmation,AdditionalStudies,psyNitePreviousDate,psyNitePreviousID,psycometricBonus,SAT/ACT,SATMath,SATDate,actCompositeScore,actDate,GMATDate,TOEFL-IELTSDate,TOEFL-IELTSScore,folderLink,Title,citizenship,homePhone,workPhone,address,zip,academTitle,IdHe,userName,folderMail,deadline,folderName,documentsCopyFolder,previousFamilyName,motherName,phone,guardianName,guardianAddress,guardianPhone,israelContactName,israelContactAddress,israelContactPhone,israelCareOf,careOfPhone,israelArrivalDate,dateOfBirth,A,file number,RakefetDone,psyNitePreviousPlace,psyNitePlannedPlace,psyNitePlannedID,SATReading,GREDate,GRESubject,hebrewSpeaking,hebrewReading,hebrewWriting,englishSpeaking,englishReading,englishWriting,appliedToHUJIYear,confirmationNumber,declaration1,declaration2,declaration3,secondarySchoolType,armyServiceDates,armyServiceCountry,SATEBRW,preparatoryAverage,RALAK,aditionalInfo - advisor,SAT EBRW,advisors,Status,letters sent,documentsCopyFolder"
$DstRakefet31 = "Title,Attachments,citizenship,homePhone,workPhone,cellPhone,address,zip,academTitle,IdHe,userName,folderMail,folderLink,deadline,folderName,documentsCopyFolder,previousFamilyName,motherName,phone,guardianName,guardianAddress,guardianPhone,israelContactName,israelContactAddress,israelContactPhone,israelCareOf,careOfPhone,israelArrivalDate,dateOfBirth,file number,secondarySchoolName,secondarySchoolGraduation,secondarySchoolCountry,secondarySchoolType,universityInstitute,universityCountry,universityYearsNum,universityDatesAttended,universityMajorAreasOfStudy,universityDegree,universityGraduationDate,preparatoryProgramsInstitute,preparatoryProgramsName,preparatoryProgramsDates,armyServiceCountry,armyServiceDates,psyNitePreviousDate,psyNitePreviousPlace,psyNitePreviousID,psyNitePlannedPlace,psyNitePlannedID,SATEBRW,SATMath,SATDate,actCompositeScore,actDate,GREDate,GRESubject,GMATDate,hebrewSpeaking,hebrewReading,hebrewWriting,englishSpeaking,englishReading,englishWriting,appliedToHUJI,appliedToHUJIYear,appliedToHUJIStudentNum,confirmationNumber,declaration1,declaration2,declaration3,A,RakefetDone,letters sent,HighSchoolDiplomaEquivalency,HighSchoolDiplomaOfficial,HighSchoolTrack,DiplomaAverage,PreparatoryTrack,AdditionalStudies,psycometricBonus,universityAverage,UniveristyDocumentsOfficial,preference1Update,preference2Update,preference3Update,preference4Update,preference5Update,DayofUpdate,aditionalInfo - advisor,RakefetEdit,SATReading,advisors,Status"


$AdminNotFound = FindNotInSource $SrcAdmin32 $DstAdmin31
write-host ===========================
write-host "Admin Not Found in 31:"
write-host 
$AdminNotFound

$RakefetNotFound = FindNotInSource $SrcRakefet32 $DstRakefet31
write-host
write-host ===========================
write-host "Rakefet Not Found in 31:"
write-host 
$RakefetNotFound


