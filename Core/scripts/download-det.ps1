<#
.SYNOPSIS
Downloads a CAF Excel data entry template, renames to inputted initials and current date (YYYYMMDD), and opens the file for editing.
.PARAMETER Directory
The directory the script was called from. Intended to be a level above where script is run from.
.PARAMETER Initials
Initials of the person responsible for data entry, will be set to uppercase
.PARAMETER MasterDetUrl
URL of the master DET to be downloaded.
.PARAMETER DetBaseName
Basename of the DET. The initials and current date will be appended to the base name, preceeded by a "_". E.g. "GrainSubSample01_2021_GP-ART-Lime" will result in a file similar to: "GrainSubSample01_2021_GP-ART-Lime_BRC_20220102.xlsm"
.DESCRIPTION
Version 0.2.0
Author: Bryan Carlson
Contact: bryan.carlson@usda.gov
Last Update: 02/02/2022
Dependencies
  * An Excel data entry template located in a Azure Blob Storage location as described by $url variables
.NOTES
This script is intended to be called by a .bat file located a directory level above it. 
.EXAMPLE
Powershell.exe -ExecutionPolicy bypass -File %CD%\scripts\download-det.ps1 -Directory %cd% -Initials "%init%" -MasterDetUrl "https://cafltardatalake.blob.core.windows.net/work/CafPlantGridPointSurvey/SampleProcessing_GrainSubSample01/GrainSubSample01_2021_GP-ART-Lime_INT_YYYYMMDD.xlsm" -DetBaseName "GrainSubSample01_2021_GP-ART-Lime"
.LINK
https://github.com/cafltar/CafLogisticsSampleProcessing_UploadDownloadScripts
#>

param(
	[Parameter(Mandatory=$true)][string]$Directory, 
	[Parameter(Mandatory=$true)][string]$Initials,
	[Parameter(Mandatory=$true)][string]$MasterDetUrl,
	[Parameter(Mandatory=$true)][string]$DetBaseName
)

$version = "0.2.0"

Write-Host("----------------------------")
Write-Host("Version: $($version)")
Write-Host("MasterDetUrl: $($MasterDetUrl)")
Write-Host("----------------------------")

$files = (Get-Item "$($DetBaseName)*" -ErrorAction Ignore)
if($files)
{
	Write-Warning("Found the following DET(s) in the download directory. Files in the download directory indicate work that may not have been submitted to the master DET. Please deal with the file(s) before running this script again.")
	Write-Host("")
	foreach ($file in $files)
	{
		Write-Host "* $($file)" -Foregroundcolor Yellow
	}
	Write-Host("")
	Write-Host -NoNewLine "Press any key to continue..."
	$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	Exit
}

$date = Get-Date -Format "yyyyMMdd"
$output = "$($Directory)\$($DetBaseName)_$($Initials.ToUpper())_$($date).xlsm"

Write-Host("Downloading file...")

New-Item -ItemType File -Path $output -Force
Invoke-WebRequest -Uri $MasterDetUrl -OutFile $output

Invoke-Item -Path $output