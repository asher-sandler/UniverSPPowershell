rem Asher Sandler 09 of March 2022
rem Please add brief description
rem do not change - runs ps script from cmd


powershell.exe -nologo -command  "c:\AdminDir\Send2Rakefet\Do-SendRakefet.ps1" "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\CRS\crsExemptToSap.xml"
powershell.exe -nologo -command  "c:\AdminDir\Send2Rakefet\Do-SendRakefet.ps1" "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\CRS\crsMursheToSap.xml"
powershell.exe -nologo -command  "c:\AdminDir\Send2Rakefet\Do-SendRakefet.ps1" "\\ekeksql00\SP_Resources$\WP_Config\SendToRakefet\CRS\crsServicesToSap.xml"

