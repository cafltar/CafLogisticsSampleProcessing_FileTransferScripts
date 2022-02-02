@ECHO OFF
SET /p init= "Enter Initials: "

Powershell.exe -ExecutionPolicy bypass -File %CD%\scripts\download-det.ps1 -Directory %cd% -Initials "%init%" -MasterDetUrl "{BLOB_URL_WITH_SAS_IF_NEEDED}" -DetBaseName "{NAME_OF_DET_WITHOUT_INI_YYYYMMDD}"