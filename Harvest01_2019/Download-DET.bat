@ECHO OFF
SET /p init= "Enter Initials: "

Powershell.exe -ExecutionPolicy remotesigned -File %CD%\scripts\download-det.ps1 -Directory %cd% -Initials "%init%"