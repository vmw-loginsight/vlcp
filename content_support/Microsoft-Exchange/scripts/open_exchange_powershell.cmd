@echo OFF

set COMMAND_DESTINATION=%~dp0%1
:: Try Exchange 2010
set KEY_NAME="HKEY_LOCAL_MACHINE\Software\Microsoft\ExchangeServer\v14\Setup"
CALL :TRY_TO_OPEN_EXSHELL
:: Try Exchange 2013
set KEY_NAME="HKEY_LOCAL_MACHINE\Software\Microsoft\ExchangeServer\v15\Setup"
if not defined SUCCESS CALL :TRY_TO_OPEN_EXSHELL
:: Return empty-handed.
GOTO :EOF


:TRY_TO_OPEN_EXSHELL
set VALUE_NAME=MsiInstallPath

FOR /F "tokens=2* delims=^T " %%A IN ('REG QUERY %KEY_NAME% /v %VALUE_NAME%') DO (
    set PATH_TO_EXCHANGE=%%B
)

if defined PATH_TO_EXCHANGE (
    PowerShell -PSConsoleFile "%PATH_TO_EXCHANGE%\bin\exshell.psc1" -Command ". '%COMMAND_DESTINATION%'"
    set SUCCESS=True
) else (
    @echo %KEY_NAME%\%VALUE_NAME% not found.
)
GOTO :EOF

