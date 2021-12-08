<#
.SYNOPSIS
Uploads data entry templates from Harvest01_2021 folder to Azure Blob Storage then moves the uploaded file to local folder for archival
.PARAMETER Directory
The directory the script was called from. Intended to be a level above where script is run from.
.DESCRIPTION
Version 0.1.0
Author: Bryan Carlson
Contact: bryan.carlson@usda.gov
Last Update: 12/08/2021
Dependencies
  * Microsoft Azure blob storage account and container
  * A file named "blob-sas.private" with a Shared Access Signature token to the blob storage account located at same directory level as this script. Example: "?st=2019-08-06..."
.NOTES
This script is intended to be called by a .bat file located a directory level above it. 
.EXAMPLE
Powershell.exe -ExecutionPolicy remotesigned -File %CD%\scripts\upload-det.ps1 -Directory %cd%
.LINK
https://github.com/cafltar/CafLogisticsSampleProcessing_UploadDownloadScripts
#>

param(
	[Parameter(Mandatory=$true)][string]$Directory)

# Script expects a file containing a SAS token to the blob container.
$sas = Get-Content $PSScriptRoot\blob-sas.private

# Get all xlsm files in GrainSubSample01_2021, loop through and upload/archive
Get-ChildItem "$($Directory)\GrainSubSample01_2021" -Filter *.xlsm |
ForEach-Object {
    # Get file info
    $filePath = $_.FullName
    Write-Host("Found file: " + $filePath)
    $name = (Get-Item $filePath).Name

    # Prepare for upload
    $uri = "https://cafltardatalake.blob.core.windows.net/transient/CafPlantGridPointSurvey/FromSampleProcessing_GrainSubSample01_2021/$($name)$($sas)"

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
    } catch {
        Write-Host "Error:" $_.GetType().FullName ", " $_.FullyQualifiedErrorId
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
    }
}








