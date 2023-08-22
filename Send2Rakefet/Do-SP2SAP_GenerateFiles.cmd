rem Asher Sandler 09 of March 2022
rem Please add brief description
rem do not change - runs ps script from cmd


powershell.exe -nologo -command  "C:\MOSS_Batches\SendToRakefet\Do-SendRakefet.ps1" "\\ekeksql00\SP_Resources$\WP_Config\SAP\CRS\crsExemptToSap.xml"
powershell.exe -nologo -command  "C:\MOSS_Batches\SendToRakefet\Do-SendRakefet.ps1" "\\ekeksql00\SP_Resources$\WP_Config\SAP\CRS\crsMursheToSap.xml"
powershell.exe -nologo -command  "C:\MOSS_Batches\SendToRakefet\Do-SendRakefet.ps1" "\\ekeksql00\SP_Resources$\WP_Config\SAP\CRS\crsServicesToSap.xml"
