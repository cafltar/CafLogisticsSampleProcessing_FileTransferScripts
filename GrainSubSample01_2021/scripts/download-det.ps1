﻿<#
.SYNOPSIS
Downloads a CAF Excel data entry template, renames to inputted initials and current date (YYYYMMDD), and opens the file for editing.
.PARAMETER Directory
The directory the script was called from. Intended to be a level above where script is run from.
.PARAMETER Initials
Initials of the person responsible for data entry, will be set to uppercase
.DESCRIPTION
Version 0.1.0
Author: Bryan Carlson
Contact: bryan.carlson@usda.gov
Last Update: 12/06/2021
Dependencies
  * An Excel data entry template located in a Azure Blob Storage location as described by $url variables
.NOTES
This script is intended to be called by a .bat file located a directory level above it. 
.EXAMPLE
Powershell.exe -ExecutionPolicy remotesigned -File %CD%\scripts\download-det.ps1 -Directory %cd% -Initials "%init%"
.LINK
https://github.com/cafltar/CafLogisticsSampleProcessing_UploadDownloadScripts
#>

param(
	[Parameter(Mandatory=$true)][string]$Directory, 
	[Parameter(Mandatory=$true)][string]$Initials
) 

$url = "https://cafltardatalake.blob.core.windows.net/work/CafPlantGridPointSurvey/SampleProcessing_GrainSubSample01/GrainSubSample01_2021_GP-ART-Lime_INT_YYYYMMDD.xlsm?sv=2020-10-02&st=2021-12-07T22%3A32%3A46Z&se=2029-01-08T22%3A32%3A00Z&sr=b&sp=r&sig=Q4rkzJlA9%2Fqa8TLX0o5e3ffMkxn68M7oZ%2BSqOfBq9r0%3D"
$date = Get-Date -Format "yyyyMMdd"
$output = "$($Directory)\GrainSubSample01_2021\GrainSubSample01_2021_GP-ART-Lime_$($Initials.ToUpper())_$($date).xlsm"

Write-Host("Downloading file...")

New-Item -ItemType File -Path $output -Force
Invoke-WebRequest -Uri $url -OutFile $output

Invoke-Item -Path $output