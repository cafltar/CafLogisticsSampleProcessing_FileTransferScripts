<#
.SYNOPSIS
Uploads data entry templates from a DET folder to Azure Blob Storage then moves the uploaded file to local folder for archival
.PARAMETER Directory
The directory the script was called from. Intended to be a level above where script is run from.
.PARAMETER UploadDir
The URL to the blob directory where the uploaded file will be written to. This is usually in the 'transient' zone of the data lake, e.g. "https://cafltardatalake.blob.core.windows.net/transient/{ProjectName}/From{ScriptOrProcessName}"
.DESCRIPTION
Version 0.2.0
Author: Bryan Carlson
Contact: bryan.carlson@usda.gov
Last Update: 02/03/2022
Dependencies
  * Microsoft Azure blob storage account and container
  * A file named "blob-sas.private" with a Shared Access Signature token to the blob storage account located at same directory level as this script. Example: "?st=2019-08-06..."
.NOTES
This script is intended to be called by a .bat file located a directory level above it. 
.EXAMPLE
Powershell.exe -ExecutionPolicy remotesigned -File %CD%\scripts\upload-det.ps1 -Directory %cd% -UploadDir https://cafltardatalake.blob.core.windows.net/transient/CafPlantGridPointSurvey/FromSampleProcessing_GrainSubSample01_2021
.LINK
https://github.com/cafltar/CafLogisticsSampleProcessing_UploadDownloadScripts
#>

param(
	[Parameter(Mandatory=$true)][string]$Directory,
    [Parameter(Mandatory=$true)][string]$UploadDir
)

$version = "0.2.0"

Write-Host("----------------------------")
Write-Host("Version: $($version)")
Write-Host("UploadDir: $($UploadDir)")
Write-Host("----------------------------")

# Script expects a file containing a SAS token to the blob container.
$sas = Get-Content $PSScriptRoot\blob-sas.private

# Get all xlsm files in directory, warn if there's more than one, then upload
$files = (Get-Item "*.xlsm" -ErrorAction Ignore)
if($files.Count -gt 1) {
    Write-Warning "More than one file was found, are you sure you want to upload them all?"
    $response = Read-Host "Continue? (Y/N)"
    if($response -ne "Y") {
        Exit
    }
}
foreach($file in $files)
{
    # Get file info
    $filePath = $file.FullName
    Write-Host "Found file: " + $filePath
    $name = (Get-Item $filePath).Name

    # Prepare for upload
    $uri = "$($UploadDir)/$($name)$($sas)"

    $headers = @{
        'x-ms-blob-type' = 'BlockBlob'
    }

    Write-Host("Uploading file...")

    try {
        # Upload the file
        $Response = Invoke-WebRequest -Uri $uri -Method Put -Headers $headers -InFile $filePath
        Write-Host("Response: $($Response)")
        # If upload successful, archive DET
        if($Response.StatusCode -eq 201) {
            Write-Host("Success")

            # Create archived destination path using datetime
            $datePath = "{0:yyyy-MM-dd_HH-mm-ss-fff}" -f (Get-Date)
            $targetPath = "$($Directory)\Archives\$($datePath)\$($name)"

            # Create archived folder if needed, move file
            Write-Host("Moving file...")
            New-Item -ItemType File -Path $targetPath -Force
            Move-Item -Path $filePath -Destination $targetPath -Force
			
			# Set file to readonly
			$file = Get-Item -Path $targetPath
			$file.IsReadOnly = $true
        }
        else {
            Write-Warning "There was a potential problem uploading the file. Please confirm the upload. StatusCode: " $Response.StatusCode
            Write-Host ""
	        Write-Host -NoNewLine "Press any key to continue..."
	        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	        Exit
        }
    } catch {
        Write-Error "There was a problem uploading the file."
        Write-Host "Error:" $_.GetType().FullName ", " $_.FullyQualifiedErrorId
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription

        Write-Host ""
	    Write-Host -NoNewLine "Press any key to continue..."
	    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	    Exit
    }
}