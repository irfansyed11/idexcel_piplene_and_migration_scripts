taskkill /f /im dsa.exe

taskkill /f /im Notifier.exe

taskkill /f /im coreServiceShell.exe

taskkill /f /im coreFrameworkHost.exe

taskkill /f /im ds_monitor.exe



sc stop ds_agent

sc stop ds_notifier

sc stop Amsp

sc stop tmactmon

sc stop tmevtmgr

sc stop tmcomm

sc stop ds_monitor

sc stop tmumh

sc stop tmebc

sc stop tbimdsa

sc stop tmeyes



sc delete ds_agent

sc delete ds_monitor

sc delete ds_notifier

sc delete Amsp

sc delete tmactmon

sc delete tmevtmgr

sc delete tmcomm

sc delete tmumh

sc delete tmebc

sc delete monitor

sc delete tbimdsa

sc delete tmeyes



reg delete HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\AEGIS /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\AMSP /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\AMSPStatus /f

reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\Deep Security Agent" /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\Falcon /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\TrendMicro\WL /f



reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Amsp /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ds_agent /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ds_notifier /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\tbimdsa /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\tmactmon /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\tmcomm /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\tmevtmgr /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\tmumh /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TMEBC /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\tmeyes /f

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application\Deep Security Agent" /f

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application\Deep Security Relay" /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System\tbimdsa /f



reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Amsp /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ds_agent /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ds_notifier /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\tbimdsa /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\tmactmon /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\tmcomm /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\tmevtmgr /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\tmumh /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\tmeyes /f

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\services\eventlog\Application\Deep Security Agent" /f

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\services\eventlog\Application\Deep Security Relay" /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\services\eventlog\System\tbimdsa /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\TMEBC /f



reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\Amsp /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\ds_agent /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\ds_notifier /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\tbimdsa /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\tmactmon /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\tmcomm /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\tmevtmgr /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\tmumh /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\tmeyes /f

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\services\eventlog\Application\Deep Security Agent" /f

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\services\eventlog\Application\Deep Security Relay" /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\services\eventlog\System\tbimdsa /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\TMEBC /f



reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\Amsp /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\ds_agent /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\ds_notifier /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\tbimdsa /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\tmactmon /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\tmcomm /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\tmevtmgr /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\tmumh /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\tmeyes /f

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\services\eventlog\Application\Deep Security Agent" /f

reg delete "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\services\eventlog\Application\Deep Security Relay" /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\services\eventlog\System\tbimdsa /f

reg delete HKEY_LOCAL_MACHINE\SYSTEM\ControlSet003\Services\TMEBC /f



reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Features\80E7CC013A4CD8F44AC9B49EB061392B] /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\80E7CC013A4CD8F44AC9B49EB061392B] /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\UpgradeCodes\689D08D76B5A47A4FB59D97D2C4B9308] /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\689D08D76B5A47A4FB59D97D2C4B9308] /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{10CC7E08-C4A3-4F8D-A49C-4BE90B1693B2}] /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Features\C4AF20E48325C454BBBE163E418FCEA9 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\C4AF20E48325C454BBBE163E418FCEA9 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\UpgradeCodes\689D08D76B5A47A4FB59D97D2C4B9308 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\689D08D76B5A47A4FB59D97D2C4B9308 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4E02FA4C-5238-454C-BBEB-61E314F8EC9A} /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Features\C576B4AC76DEBD7428E62A20748B5BEE /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\C576B4AC76DEBD7428E62A20748B5BEE /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\UpgradeCodes\9595A43D099883B49B6A1D3194B54E48 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\9595A43D099883B49B6A1D3194B54E48 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CA4B675C-ED67-47DB-826E-A20247B8B5EE} /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Features\8AD1116DC93642C4F9032F4EFE4F1425 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\8AD1116DC93642C4F9032F4EFE4F1425 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\UpgradeCodes\9595A43D099883B49B6A1D3194B54E48 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\9595A43D099883B49B6A1D3194B54E48 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{D6111DA8-639C-4C24-9F30-F2E4EFF44152} /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Features\C2B7CFB8EB0E6FC4CA6C5E010B7B4298 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\C2B7CFB8EB0E6FC4CA6C5E010B7B4298 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\UpgradeCodes\FD7DF71DF377E464F8F59FDA68339BD0 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\FD7DF71DF377E464F8F59FDA68339BD0 /f

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8BFC7B2C-E0BE-4CF6-ACC6-E510B0B72489} /f

reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\Deep Security Notifier" /f



@RD /S /Q "C:\ProgramData\Trend Micro\Deep Security Agent"

@RD /S /Q "C:\ProgramData\Trend Micro\Deep Security Notifier"

@RD /S /Q "C:\ProgramData\Trend Micro\AMSP"

@RD /S /Q "C:\Documents and Settings\All Users\Application Data\Trend Micro"

@RD /S /Q "C:\Program Files\Trend Micro\Deep Security Agent"

@RD /S /Q "C:\Program Files\Trend Micro\Deep Security Notifier"

@RD /S /Q "C:\Program Files\Trend Micro\AMSP"

@RD /S /Q "C:\WINDOWS\System32\LogFiles\ds_agent"



del /F /Q "C:\Windows\System32\drivers\tbimdsa.sys"

del /F /Q "C:\Windows\System32\drivers\tmactmon.sys"

del /F /Q "C:\Windows\System32\drivers\tmcomm.sys"

del /F /Q "C:\Windows\System32\drivers\TMEBC64.sys"

del /F /Q "C:\Windows\System32\drivers\TMEBC32.sys"

del /F /Q "C:\Windows\System32\drivers\tmevtmgr.sys"

del /F /Q "C:\Windows\System32\drivers\TMUMH.sys"

del /F /Q "C:\Windows\System32\drivers\tmeyes.sys"



@echo off



sc delete ds_agent

sc delete ds_monitor

sc delete ds_notifier

sc delete Amsp

sc delete tmactmon

sc delete tmevtmgr

sc delete tmcomm

sc delete tmumh

sc delete tmebc

sc delete monitor

sc delete tbimdsa

sc delete tmeyes



echo Manual remove done. Reboot machine then delete Trend Micro folder/s.

pause
