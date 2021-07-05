
	Param
	(
		[Parameter(Mandatory=$false)]
		[ValidateSet("He", "En")]
		
		
		[string[]]$Language = "He"
	)
	
	write-host $Language
