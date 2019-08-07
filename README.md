# README

## Purpose

Scripts for uploading and downloading CAF Excel Data Entry Template (DET) files. These scripts are intended to be used with serverless processes that manage merging submitted DETs with a "master" DET, or merge into a proper database. These scripts are only concerned with downloading the "master" DET (the current DET with all available information) and pushing a DET with new information to blob storage to be managed by the serverless process.

## Intended Use

Sub-folders (e.g. Harvest01_2019) are to be copied to a PC that is used to collected sample processing information.

## Files

* Sub-folders are organized by DET template name, version, and date the template was used.
* Within sub-folders a Download-DET.bat and Submit-DET.bat files are used to call powershell scripts to upload/download files.
  
## License

As a work of the United States government, this project is in the public domain within the United States.

Additionally, we waive copyright and related rights in the work worldwide through the CC0 1.0 Universal public domain dedication.
