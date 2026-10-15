# enable_graphics_engine.ps1
# Script para desbloquear as funções de conversão de vetor e a integração gráfica no Wilcom EmbroideryStudio e4.2

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Ativando Engine Grafica para Wilcom EmbroideryStudio e4.2" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Configurar chaves no Registro do Windows
$corelX7Dir = "C:\Program Files\Corel\CorelDRAW Graphics Suite X7\Programs64\"
$configDir = "C:\Program Files\Corel\CorelDRAW Graphics Suite X7\Config\"

$versions = @("18.0", "19.0", "20.0")

foreach ($v in $versions) {
    $keyPath = "HKLM:\SOFTWARE\Corel\CorelDRAW\$v"
    if (!(Test-Path $keyPath)) {
        New-Item -Path $keyPath -Force | Out-Null
        Write-Host "[+] Criada chave de compatibilidade: CorelDRAW $v" -ForegroundColor Green
    }
    Set-ItemProperty -Path $keyPath -Name "ProgramsDir" -Value $corelX7Dir -Force
    Set-ItemProperty -Path $keyPath -Name "ConfigDir" -Value $configDir -Force
    Set-ItemProperty -Path $keyPath -Name "SuiteVersion" -Value "$v.0.0" -Force
    
    # PremiumFeatures que o COREL.DLL do Wilcom checa
    $ipmKey = "$keyPath\IPM_CDGS\PremiumFeatures"
    if (!(Test-Path $ipmKey)) {
        New-Item -Path $ipmKey -Force | Out-Null
    }
    Set-ItemProperty -Path $ipmKey -Name "{5F18CC22-B399-48EC-BB9D-E92510E218EF}" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $ipmKey -Name "{03E21392-CE4A-4FC6-B593-370E7A7E345A}" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $ipmKey -Name "{ECFAF1D6-342D-4AE2-B6BF-82B22F9FE8DE}" -Value 1 -Type DWord -Force
}

# 2. Copiar plugin CorelWPL para a pasta do CorelDRAW
$pluginSrc = "C:\Program Files\Wilcom\EmbroideryStudio_e4.2\BIN\CorelWPLx64_Wilcom_e4.x.cpg"
$pluginsDir = "C:\Program Files\Corel\CorelDRAW Graphics Suite X7\Draw\Plugins64"

if (!(Test-Path $pluginsDir)) {
    New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
    Write-Host "[+] Criado diretorio de plugins: $pluginsDir" -ForegroundColor Green
}

if (Test-Path $pluginSrc) {
    Copy-Item -Path $pluginSrc -Destination "$pluginsDir\CorelWPLx64_Wilcom_e4.x.cpg" -Force
    Write-Host "[+] Plugin Wilcom copiado para o CorelDRAW com sucesso!" -ForegroundColor Green
}

Write-Host "`n[SUCESSO] Configuracao concluida! Feche o Wilcom e abra novamente para aplicar." -ForegroundColor Yellow
