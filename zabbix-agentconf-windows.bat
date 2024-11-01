@echo off

REM Define the log file in a writable directory
set "LOG_FILE=%USERPROFILE%\Desktop\zabbix_agent_config.log"

REM Set the path to the Zabbix Agent configuration file
set "ZABBIX_AGENT_CONF=C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf"

REM Start log and check write permissions
echo [%date% %time%]: Starting Zabbix Agent configuration update. > "%LOG_FILE%" || (
    echo Unable to write to log file at "%LOG_FILE%". Please check permissions.
    exit /b 1
)

REM Check if the configuration file exists
if not exist "%ZABBIX_AGENT_CONF%" (
    echo [%date% %time%]: Configuration file not found at "%ZABBIX_AGENT_CONF%". >> "%LOG_FILE%"
    exit /b 1
)

REM Update Zabbix agent configuration
powershell -Command "(Get-Content -Path '%ZABBIX_AGENT_CONF%') -replace '^Hostname=.*', 'Hostname=%COMPUTERNAME%' | Set-Content -Path '%ZABBIX_AGENT_CONF%'" >> "%LOG_FILE%" 2>&1
powershell -Command "(Get-Content -Path '%ZABBIX_AGENT_CONF%') -replace '^Server=.*', 'Server=184.127.0.66' | Set-Content -Path '%ZABBIX_AGENT_CONF%'" >> "%LOG_FILE%" 2>&1
powershell -Command "(Get-Content -Path '%ZABBIX_AGENT_CONF%') -replace '^ServerActive=.*', 'ServerActive=184.127.0.66' | Set-Content -Path '%ZABBIX_AGENT_CONF%'" >> "%LOG_FILE%" 2>&1
powershell -Command "(Get-Content -Path '%ZABBIX_AGENT_CONF%') -replace '^# UnsafeUserParameters=0', 'UnsafeUserParameters=1' | Set-Content -Path '%ZABBIX_AGENT_CONF%'" >> "%LOG_FILE%" 2>&1
powershell -Command "(Get-Content -Path '%ZABBIX_AGENT_CONF%') -replace '^# UserParameter=.*', 'UserParameter=usercmd[*],%%1' | Set-Content -Path '%ZABBIX_AGENT_CONF%'" >> "%LOG_FILE%" 2>&1

REM Check if AllowKey=system.run[*] is already in the configuration file
findstr /C:"AllowKey=system.run[*]" "%ZABBIX_AGENT_CONF%" >nul
if errorlevel 1 (
    echo AllowKey=system.run[*] >> "%ZABBIX_AGENT_CONF%"
    echo [%date% %time%]: Added AllowKey=system.run[*] to configuration. >> "%LOG_FILE%"
) else (
    echo [%date% %time%]: AllowKey=system.run[*] already exists in the configuration. >> "%LOG_FILE%"
)

echo [%date% %time%]: Configuration updated successfully. >> "%LOG_FILE%"

REM Restart the Zabbix Agent 2 service and capture any errors
echo [%date% %time%]: Attempting to restart Zabbix Agent 2. >> "%LOG_FILE%"
net stop "Zabbix Agent 2" > "%USERPROFILE%\temp_restart.log" 2>&1
net start "Zabbix Agent 2" >> "%USERPROFILE%\temp_restart.log" 2>&1
if %errorlevel% equ 0 (
    echo [%date% %time%]: Zabbix Agent 2 restarted successfully. >> "%LOG_FILE%"
) else (
    echo [%date% %time%]: Error restarting Zabbix Agent 2. >> "%LOG_FILE%"
    echo [%date% %time%]: Restart error details: >> "%LOG_FILE%"
    type "%USERPROFILE%\temp_restart.log" >> "%LOG_FILE%"
)

REM Cleanup temporary log
del "%USERPROFILE%\temp_restart.log" >nul 2>&1

echo [%date% %time%]: Zabbix Agent configuration update completed. >> "%LOG_FILE%"
