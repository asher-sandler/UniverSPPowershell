rem Asher Sandler 09 of March 2022
rem Please add brief description
rem do not change - runs ps script from cmd


powershell.exe -nologo -command  "C:\MOSS_Batches\SendToRakefet\Do-SendRakefet.ps1" "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\CRS_asher\crsExemptToSap.xml"
powershell.exe -nologo -command  "C:\MOSS_Batches\SendToRakefet\Do-SendRakefet.ps1" "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\CRS_asher\crsMursheToSap.xml"
powershell.exe -nologo -command  "C:\MOSS_Batches\SendToRakefet\Do-SendRakefet.ps1" "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\CRS_asher\crsServicesToSap.xml"

powershell.exe -nologo -command  "C:\MOSS_Batches\SendToRakefet\Do-SendRCopyFiles.ps1"
