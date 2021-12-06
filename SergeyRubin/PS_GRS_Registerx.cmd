rem Sergey Rubin 21 Jan 2021
rem operates Application webs basing on registered requests
rem do not change - runs ps script from cmd

powershell.exe -nologo -command "C:\MOSS_Batches\ps_grs_sql_importx00.ps1"

powershell.exe -nologo -command "C:\MOSS_Batches\ps_grs_sql_flags00.ps1"

powershell.exe -nologo -command "C:\MOSS_Batches\ps_grs_sql_updates00.ps1"

powershell.exe -nologo -command "C:\MOSS_Batches\ps_grs_sql_action01.ps1"

powershell.exe -nologo -command "C:\MOSS_Batches\ps_grs_sql_action03.ps1"
