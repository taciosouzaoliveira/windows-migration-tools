@echo off
setlocal enabledelayedexpansion
title Utilitario de Limpeza Microsoft 365
cls

echo ======================================================
echo           LIMPEZA DE CACHE E LICENCA OFFICE
echo ======================================================
echo.
echo ATENCAO: Este script ira encerrar processos do Office e
echo remover caches de login e licenciamento.
echo.
echo O que este script faz:
echo 1. Remove tokens de login antigos (IdentityCache/OneAuth).
echo 2. Limpa o cache de arquivos temporarios do Office.
echo 3. Reseta configuracoes de pacotes de autenticacao do Windows.
echo.
set /p confirm="Deseja continuar? (S/N): "
if /i not "%confirm%"=="S" exit

echo.
echo [1/3] Fechando aplicativos do Office para evitar erros...
taskkill /f /im outlook.exe /t >nul 2>&1
taskkill /f /im winword.exe /t >nul 2>&1
taskkill /f /im excel.exe /t >nul 2>&1
taskkill /f /im powerpnt.exe /t >nul 2>&1
taskkill /f /im teams.exe /t >nul 2>&1
taskkill /f /im onedrive.exe /t >nul 2>&1

echo [2/3] Limpando pastas de licenciamento e identidade...
:: Pastas de Licença e Identidade
for %%d in (
    "%LOCALAPPDATA%\Microsoft\Office\16.0\Licensing",
    "%LOCALAPPDATA%\Microsoft\Office\Licenses",
    "%LOCALAPPDATA%\Microsoft\IdentityCache",
    "%LOCALAPPDATA%\Microsoft\OneAuth",
    "%LOCALAPPDATA%\Microsoft\TokenBroker",
    "%APPDATA%\Microsoft\Office\16.0\OfficeFileCache",
    "%APPDATA%\Microsoft\Credentials"
) do (
    if exist %%d (
        rmdir /s /q %%d
        echo  - Removido: %%d
    )
)

echo [3/3] Resetando pacotes de experiencia do Windows...
:: Pastas de pacotes (BrokerPlugin e Contas)
for %%p in (
    "Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy",
    "Microsoft.AccountsControl_cw5n1h2txyewy",
    "Microsoft.Office.OneNote_8wekyb3d8bbwe",
    "Microsoft.OutlookForWindows_8wekyb3d8bbwe"
) do (
    if exist "%LOCALAPPDATA%\Packages\%%~p" (
        rmdir /s /q "%LOCALAPPDATA%\Packages\%%~p"
        echo  - Resetado: %%~p
    )
)

echo.
echo ======================================================
echo              CONCLUIDO COM SUCESSO!
echo ======================================================
echo Proximos passos:
echo 1. Reinicie o computador.
echo 2. Abra o TEAMS e faca login com sua conta Microsoft.
echo 3. Siga o o Guia de Limpeza de Cache e Conexoes da Conta Institucional.
echo.
pause