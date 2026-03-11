# ----------------------------------------------------------------------------------
# CONFIGURAÇÃO DE AMBIENTE
# ----------------------------------------------------------------------------------
$LogFile = "C:\Windows\Temp\DsregLeave_$(Get-Date -Format yyyyMMdd_HHmmss).log"
$DSREG_CompletedFlag = "C:\ProgramData\TenantMigration_DSREG_Completed.flag"
$DateSuffix = (Get-Date).ToString('yyyyMMdd')

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogEntry -ErrorAction SilentlyContinue
    
    # Cores para o console interativo
    $Color = "White"
    if($Level -eq "WARN") { $Color = "Yellow" }
    if($Level -eq "ERROR") { $Color = "Red" }
    if($Level -eq "SUCCESS") { $Color = "Green" }
    
    Write-Host $LogEntry -ForegroundColor $Color
}

# ----------------------------------------------------------------------------------
# INTERAÇÃO INICIAL
# ----------------------------------------------------------------------------------
Clear-Host
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "   ASSISTENTE DE DESVINCULACAO AZURE AD (DSREGCMD)" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Este script remove este computador do registro do Azure AD atual."
Write-Host "Utilidade: Resolver problemas de 'Work or School Account' ou Migracoes."
Write-Host "------------------------------------------------------"

$Confirm = Read-Host "Deseja iniciar a verificacao de seguranca? (S/N)"
if ($Confirm -ne "S") { Write-Host "Operação cancelada."; exit }

# ----------------------------------------------------------------------------------
# 1. VERIFICAÇÃO DE MARCADORES (FLAGS)
# ----------------------------------------------------------------------------------
Write-Log "Verificando se este computador ja foi processado anteriormente..."

function Check-All-Markers {
    # Lista de locais onde o script deixa um 'rastro' para não rodar duas vezes
    $GlobalMarkers = @(
        "$env:LOCALAPPDATA\Microsoft\TenantCleanupDone_$DateSuffix.flag",
        "$env:APPDATA\TenantMigrationCleanupCompleted.flag",
        "C:\ProgramData\TenantMigrationCleanupCompleted.flag",
        $DSREG_CompletedFlag
    )

    foreach ($m in $GlobalMarkers) {
        if (Test-Path -Path $m) {
            Write-Log -Message "BLOQUEADO: Marcador encontrado em $m" -Level "WARN"
            return $true
        }
    }
    return $false
}

# ----------------------------------------------------------------------------------
# 2. EXECUÇÃO DO COMANDO DSREGCMD
# ----------------------------------------------------------------------------------
if (Check-All-Markers) {
    Write-Host "`nO sistema identificou que a migracao ja foi feita. Nada a fazer." -ForegroundColor Green
    pause
    exit
}

Write-Host "`nAVANÇANDO: Nenhum marcador encontrado. O comando '/leave' será enviado." -ForegroundColor Yellow
$FinalStep = Read-Host "Confirmar desvinculação AGORA? (Digite 'EXECUTAR' para confirmar)"

if ($FinalStep -eq "EXECUTAR") {
    Write-Log "Iniciando comando: dsregcmd /leave"
    
    try {
        # O comando real que desvincula a máquina
        Start-Process -FilePath "dsregcmd" -ArgumentList "/leave" -Wait -NoNewWindow -ErrorAction Stop
        Write-Log -Message "dsregcmd /leave executado com sucesso." -Level "SUCCESS"

        # Criação da Flag para evitar que o script rode de novo no próximo boot
        Write-Log -Message "Criando marcador de conclusão em: $DSREG_CompletedFlag"
        New-Item -Path $DSREG_CompletedFlag -ItemType File -Force | Out-Null
        
        Write-Host "`nSUCESSO! A máquina foi desvinculada." -ForegroundColor Green
        Write-Host "Log detalhado em: $LogFile"
    } catch {
        Write-Log -Message "ERRO CRÍTICO: Falha ao executar o comando. Verifique privilégios de Administrador." -Level "ERROR"
    }
} else {
    Write-Log "Execução abortada pelo usuário." -Level "WARN"
}

Write-Host "`nFim do processo."
pause