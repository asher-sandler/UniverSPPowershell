class Xapplicants{
	[string]$Title
	[string]$firstName
	[string]$surname
	[string]$gender
	[string]$citizenship
	[string]$email
	[string]$homePhone
	[string]$workPhone
	[string]$cellPhone
	[string]$address
	[string]$country
	[string]$zip
	[string]$academTitle
	[string]$city
	[string]$state
	[string]$IdHe
	[string]$userName
	[string]$folderMail
	[DateTime]$folderLink
	[DateTime]$deadline
	[string]$folderName
	[string]$mobile
	[string]$studentId
	[Boolean]$submit
	[DateTime]$documentsCopyFolder
	[string]$previousFamilyName
	[string]$israeliId
	[string]$fatherName
	[string]$motherName
	[string]$streetNum
	[string]$street
	[string]$postalCode
	[string]$phone
	[string]$guardianName
	[string]$guardianAddress
	[string]$guardianPhone
	[string]$israelContactName
	[string]$israelContactAddress
	[string]$israelContactPhone
	[string]$israelPhone
	[string]$firstNameHe
	[string]$surnameHe
	[string]$israelStreet
	[string]$israelStreetNumber
	[string]$israelCity
	[string]$israelPostalCode
	[string]$israelCareOf
	[string]$careOfPhone
	[string]$israelStatus
	[string]$israelArrivalDate
	[string]$dateOfBirth
	[string]$lastCountryOfSchooling
	[string]$birthCountry
	[string]$birthCountryMother
	[string]$birthCountryFather
	[string]$SugZehut
	[string]$Semester
	[string]$RegistrationSource
	[string]$SourceMaktakh
	[string]$SourceOAU
	[string]$phonePrefix
	[string]$mobilePrefix
	[DateTime]$lastSubmit
	[DateTime]$lastSubmitDocs
	[string]$registrationYear
	[string]$educationMother
	[string]$educationFather
	[string]$israelAppartmentNum
	[string]$israelPOBox
	[Boolean]$A
	[string]$advisors
	[string]$file_x0020_number
	[string]$Status
	[Boolean]$submit_x0020_docs
	[string]$payment
	[Boolean]$SendToRakefet
	[Boolean]$RakefetDone
	[string]$israelMobile
	[string]$hujiId
	[Boolean]$copeidToExpList


	
	
	Xapplicants($sourceItem){
	
		$this.Title = [string]$sourceItem["Title"]
		$this.firstName = [string]$sourceItem["firstName"]
		$this.surname = [string]$sourceItem["surname"]
		$this.gender = [string]$sourceItem["gender"]
		$this.citizenship = [string]$sourceItem["citizenship"]
		$this.email = [string]$sourceItem["email"]
		$this.homePhone = [string]$sourceItem["homePhone"]
		$this.workPhone = [string]$sourceItem["workPhone"]
		$this.cellPhone = [string]$sourceItem["cellPhone"]
		$this.address = [string]$sourceItem["address"]
		$this.country = [string]$sourceItem["country"]
		$this.zip = [string]$sourceItem["zip"]
		$this.academTitle = [string]$sourceItem["academTitle"]
		$this.city = [string]$sourceItem["city"]
		$this.state = [string]$sourceItem["state"]
		$this.IdHe = [string]$sourceItem["IdHe"]
		$this.userName = [string]$sourceItem["userName"]
		$this.folderMail = [string]$sourceItem["folderMail"]
		# !!! $this.folderLink = [DateTime]$sourceItem["folderLink"]
		$this.deadline = [DateTime]$sourceItem["deadline"]
		$this.folderName = [string]$sourceItem["folderName"]
		$this.mobile = [string]$sourceItem["mobile"]
		$this.studentId = [string]$sourceItem["studentId"]
		$this.submit = [Boolean]$sourceItem["submit"]
		#!!! $this.documentsCopyFolder = [DateTime]$sourceItem["documentsCopyFolder"]
		$this.previousFamilyName = [string]$sourceItem["previousFamilyName"]
		$this.israeliId = [string]$sourceItem["israeliId"]
		$this.fatherName = [string]$sourceItem["fatherName"]
		$this.motherName = [string]$sourceItem["motherName"]
		$this.streetNum = [string]$sourceItem["streetNum"]
		$this.street = [string]$sourceItem["street"]
		$this.postalCode = [string]$sourceItem["postalCode"]
		$this.phone = [string]$sourceItem["phone"]
		$this.guardianName = [string]$sourceItem["guardianName"]
		$this.guardianAddress = [string]$sourceItem["guardianAddress"]
		$this.guardianPhone = [string]$sourceItem["guardianPhone"]
		$this.israelContactName = [string]$sourceItem["israelContactName"]
		$this.israelContactAddress = [string]$sourceItem["israelContactAddress"]
		$this.israelContactPhone = [string]$sourceItem["israelContactPhone"]
		$this.israelPhone = [string]$sourceItem["israelPhone"]
		$this.firstNameHe = [string]$sourceItem["firstNameHe"]
		$this.surnameHe = [string]$sourceItem["surnameHe"]
		$this.israelStreet = [string]$sourceItem["israelStreet"]
		$this.israelStreetNumber = [string]$sourceItem["israelStreetNumber"]
		$this.israelCity = [string]$sourceItem["israelCity"]
		$this.israelPostalCode = [string]$sourceItem["israelPostalCode"]
		$this.israelCareOf = [string]$sourceItem["israelCareOf"]
		$this.careOfPhone = [string]$sourceItem["careOfPhone"]
		$this.israelStatus = [string]$sourceItem["israelStatus"]
		$this.israelArrivalDate = [string]$sourceItem["israelArrivalDate"]
		$this.dateOfBirth = [string]$sourceItem["dateOfBirth"]
		$this.lastCountryOfSchooling = [string]$sourceItem["lastCountryOfSchooling"]
		$this.birthCountry = [string]$sourceItem["birthCountry"]
		$this.birthCountryMother = [string]$sourceItem["birthCountryMother"]
		$this.birthCountryFather = [string]$sourceItem["birthCountryFather"]
		$this.SugZehut = [string]$sourceItem["SugZehut"]
		$this.Semester = [string]$sourceItem["Semester"]
		$this.RegistrationSource = [string]$sourceItem["RegistrationSource"]
		$this.SourceMaktakh = [string]$sourceItem["SourceMaktakh"]
		$this.SourceOAU = [string]$sourceItem["SourceOAU"]
		$this.phonePrefix = [string]$sourceItem["phonePrefix"]
		$this.mobilePrefix = [string]$sourceItem["mobilePrefix"]
		#!!! $this.lastSubmit = [DateTime]$sourceItem["lastSubmit"]
		#!!! $this.lastSubmitDocs = [DateTime]$sourceItem["lastSubmitDocs"]
		$this.registrationYear = [string]$sourceItem["registrationYear"]
		$this.educationMother = [string]$sourceItem["educationMother"]
		$this.educationFather = [string]$sourceItem["educationFather"]
		$this.israelAppartmentNum = [string]$sourceItem["israelAppartmentNum"]
		$this.israelPOBox = [string]$sourceItem["israelPOBox"]
		$this.A = [Boolean]$sourceItem["A"]
		$this.advisors = [string]$sourceItem["advisors"]
		$this.file_x0020_number = [string]$sourceItem["file number"]
		$this.Status = [string]$sourceItem["Status"]
		$this.submit_x0020_docs = [Boolean]$sourceItem["submit docs"]
		$this.payment = [string]$sourceItem["payment"]
		$this.SendToRakefet = [Boolean]$sourceItem["SendToRakefet"]
		$this.RakefetDone = [Boolean]$sourceItem["RakefetDone"]
		$this.israelMobile = [string]$sourceItem["israelMobile"]
		$this.hujiId = [string]$sourceItem["hujiId"]
		$this.copeidToExpList = [Boolean]$sourceItem["copeidToExpList"]
	}
	
	addItem_Xapplicants($siteUrl, $listName){
		$dstweb = Get-SPWeb $siteUrl
		$dstList = $dstweb.Lists[$listName]
        #write-host $listName
		$listItm = $dstList.AddItem()

		$listItm["Title"] = $this.Title
		$listItm["firstName"] = $this.firstName
		$listItm["surname"] = $this.surname
		$listItm["gender"] = $this.gender
		$listItm["citizenship"] = $this.citizenship
		$listItm["email"] = $this.email
		$listItm["homePhone"] = $this.homePhone
		$listItm["workPhone"] = $this.workPhone
		$listItm["cellPhone"] = $this.cellPhone
		$listItm["address"] = $this.address
		$listItm["country"] = $this.country
		$listItm["zip"] = $this.zip
		$listItm["academTitle"] = $this.academTitle
		$listItm["city"] = $this.city
		$listItm["state"] = $this.state
		$listItm["IdHe"] = $this.IdHe
		$listItm["userName"] = $this.userName
		$listItm["folderMail"] = $this.folderMail
		### !!!! $listItm["folderLink"] = $this.folderLink
		$listItm["deadline"] = $this.deadline
		$listItm["folderName"] = $this.folderName
		$listItm["mobile"] = $this.mobile
		$listItm["studentId"] = $this.studentId
		$listItm["submit"] = $this.submit
		# !!!$listItm["documentsCopyFolder"] = $this.documentsCopyFolder
		$listItm["previousFamilyName"] = $this.previousFamilyName
		$listItm["israeliId"] = $this.israeliId
		$listItm["fatherName"] = $this.fatherName
		$listItm["motherName"] = $this.motherName
		$listItm["streetNum"] = $this.streetNum
		$listItm["street"] = $this.street
		$listItm["postalCode"] = $this.postalCode
		$listItm["phone"] = $this.phone
		$listItm["guardianName"] = $this.guardianName
		$listItm["guardianAddress"] = $this.guardianAddress
		$listItm["guardianPhone"] = $this.guardianPhone
		$listItm["israelContactName"] = $this.israelContactName
		$listItm["israelContactAddress"] = $this.israelContactAddress
		$listItm["israelContactPhone"] = $this.israelContactPhone
		$listItm["israelPhone"] = $this.israelPhone
		$listItm["firstNameHe"] = $this.firstNameHe
		$listItm["surnameHe"] = $this.surnameHe
		$listItm["israelStreet"] = $this.israelStreet
		$listItm["israelStreetNumber"] = $this.israelStreetNumber
		$listItm["israelCity"] = $this.israelCity
		$listItm["israelPostalCode"] = $this.israelPostalCode
		$listItm["israelCareOf"] = $this.israelCareOf
		$listItm["careOfPhone"] = $this.careOfPhone
		$listItm["israelStatus"] = $this.israelStatus
		$listItm["israelArrivalDate"] = $this.israelArrivalDate
		$listItm["dateOfBirth"] = $this.dateOfBirth
		$listItm["lastCountryOfSchooling"] = $this.lastCountryOfSchooling
		$listItm["birthCountry"] = $this.birthCountry
		$listItm["birthCountryMother"] = $this.birthCountryMother
		$listItm["birthCountryFather"] = $this.birthCountryFather
		$listItm["SugZehut"] = $this.SugZehut
		$listItm["Semester"] = $this.Semester
		$listItm["RegistrationSource"] = $this.RegistrationSource
		$listItm["SourceMaktakh"] = $this.SourceMaktakh
		$listItm["SourceOAU"] = $this.SourceOAU
		$listItm["phonePrefix"] = $this.phonePrefix
		$listItm["mobilePrefix"] = $this.mobilePrefix
		#!!! $listItm["lastSubmit"] = $this.lastSubmit
		#!!! $listItm["lastSubmitDocs"] = $this.lastSubmitDocs
		$listItm["registrationYear"] = $this.registrationYear
		$listItm["educationMother"] = $this.educationMother
		$listItm["educationFather"] = $this.educationFather
		$listItm["israelAppartmentNum"] = $this.israelAppartmentNum
		$listItm["israelPOBox"] = $this.israelPOBox
		$listItm["A"] = $this.A
		$listItm["advisors"] = $this.advisors
		$listItm["file number"] = $this.file_x0020_number
		$listItm["Status"] = $this.Status
		$listItm["submit docs"] = $this.submit_x0020_docs
		$listItm["payment"] = $this.payment
		$listItm["SendToRakefet"] = $this.SendToRakefet
		$listItm["RakefetDone"] = $this.RakefetDone
		$listItm["israelMobile"] = $this.israelMobile
		$listItm["hujiId"] = $this.hujiId
		$listItm["copeidToExpList"] = $this.copeidToExpList

		$listItm.Update()
	}
	
}


