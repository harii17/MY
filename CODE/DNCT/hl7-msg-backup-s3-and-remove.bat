@echo off

set day=%date:~7,2%
set month=%date:~4,2%
set year=%date:~10,4%
set h=-
set today=%day%%h%%month%%h%%year%

cd C:\Program Files\7-Zip\
7z.exe a -tzip C:\Users\ansibleadm\Desktop\HL7_Processed_Backup_%today%.zip C:\inetpub\wwwroot\spmlive\Content\HL7\Processed

if %ERRORLEVEL% EQU 0 (
	aws s3 cp C:\Users\ansibleadm\Desktop\HL7_Processed_Backup_%today%.zip s3://rss-data-archive/spmlive-content-hl7/HL7_Processed_Backup_%today%.zip 
	ForFiles /p C:\inetpub\wwwroot\spmlive\Content\HL7\Processed\ /s /d -1 /c "cmd /c del @file"
)

if %ERRORLEVEL% EQU 0 (
	del "C:\Users\ansibleadm\Desktop\HL7_Processed_Backup_%today%.zip"
)

7z.exe a -tzip C:\Users\ansibleadm\Desktop\Microsystems_Processed_Backup_%today%.zip C:\inetpub\wwwroot\spmlive\Content\Microsystems\Processed

if %ERRORLEVEL% EQU 0 (
	aws s3 cp C:\Users\ansibleadm\Desktop\Microsystems_Processed_Backup_%today%.zip s3://rss-data-archive/spmlive-content-microsystem/Microsystems_Processed_Backup_%today%.zip
	ForFiles /p C:\inetpub\wwwroot\spmlive\Content\Microsystems\Processed\ /s /d -1 /c "cmd /c del @file"
)

if %ERRORLEVEL% EQU 0 (
	del "C:\Users\ansibleadm\Desktop\Microsystems_Processed_Backup_%today%.zip"
)

ForFiles /p E:\IIS-Logs\W3SVC2\ /s /d -30 /c "cmd /c del @file"

ForFiles /p E:\RSSFileProcessingService\logs\ /s /d -30 /c "cmd /c del @file"

