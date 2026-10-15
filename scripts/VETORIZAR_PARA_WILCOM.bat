@echo off
chcp 65001 >nul
title Auto-Tracer para Wilcom EmbroideryStudio
setlocal enabledelayedexpansion

echo ======================================================================
echo    AUTO-TRACER INTELIGENTE: IMAGEM (PIXEL) -> VETOR LIMPO PARA WILCOM
echo ======================================================================
echo.

if "%~1"=="" (
    echo [INSTRUCAO] Arraste uma imagem (PNG, JPG, JPEG, WEBP) para cima deste icone!
    echo.
    echo Ou digite/cole o caminho da imagem abaixo:
    set /p "INPUT_FILE=Caminho da imagem: "
    set "INPUT_FILE=!INPUT_FILE:"=!"
) else (
    set "INPUT_FILE=%~1"
)

if not exist "!INPUT_FILE!" (
    echo [ERRO] Arquivo nao encontrado: "!INPUT_FILE!"
    pause
    exit /b
)

for %%F in ("!INPUT_FILE!") do (
    set "FILE_DIR=%%~dpF"
    set "FILE_NAME=%%~nF"
)

set "OUT_SVG=!FILE_DIR!!FILE_NAME!_vetor.svg"
set "OUT_EMF=!FILE_DIR!!FILE_NAME!_vetor.emf"

echo.
echo Processando imagem: "!INPUT_FILE!"
echo.
echo Opcoes de Vetorizacao para Bordado:
echo [1] Padrao Bordado (Limpa ruido, suaviza curvas, max 6 cores) - RECOMENDADO
echo [2] Logotipo Simples (Preto e Branco / 2 Cores)
echo [3] Alta Fidelidade (Para imagens com mais detalhes e cores)
echo.
set /p "OPT=Escolha uma opcao [1, 2 ou 3] (padrao 1): "
if "!OPT!"=="" set "OPT=1"

echo.
echo [1/2] Rastreando pixels e suavizando curvas Bezier com VTracer...

if "!OPT!"=="1" (
    "E:\Apps\VTracer\vtracer.exe" --input "!INPUT_FILE!" --output "!OUT_SVG!" --mode spline --hierarchical cutout --filter-speckle 8 --simplify 2.0 --max-colors 6
) else if "!OPT!"=="2" (
    "E:\Apps\VTracer\vtracer.exe" --input "!INPUT_FILE!" --output "!OUT_SVG!" --mode spline --preset bw --filter-speckle 8 --simplify 2.0
) else (
    "E:\Apps\VTracer\vtracer.exe" --input "!INPUT_FILE!" --output "!OUT_SVG!" --mode spline --hierarchical cutout --filter-speckle 4 --simplify 1.2
)

if not exist "!OUT_SVG!" (
    echo [ERRO] Falha ao gerar vetor SVG.
    pause
    exit /b
)

echo [2/2] Convertendo para formato vetorial nativo do Wilcom (.EMF)...
"E:\Apps\VectorCraft\vectorcraft-cli.exe" convert "!OUT_SVG!" "!OUT_EMF!"

echo.
echo ======================================================================
echo  [SUCESSO!] Vetor gerado com sucesso:
echo  - Arquivo EMF: "!OUT_EMF!"
echo  - Arquivo SVG: "!OUT_SVG!"
echo.
echo  COMO USAR NO WILCOM:
echo  1. No Wilcom, aperte Ctrl+I (Arquivo ^> Importar Grafico)
echo  2. Selecione: "!OUT_NAME!_vetor.emf"
echo  3. Ele vai entrar como "Objeto: Vetor" perfeito, pronto para virar
echo     Tatami (Enchimento) ou Ponto Cheio (Satin)!
echo ======================================================================
echo.
pause
