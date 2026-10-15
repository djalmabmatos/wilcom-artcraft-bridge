# Arquitetura de Engenharia: Wilcom Artcraft Bridge

Este documento detalha o funcionamento interno da integração do **Wilcom EmbroideryStudio e4.2** com o CorelDRAW e o plano de engenharia para substituí-lo pelo **VectorCraft (Artcraft)**.

---

## 1. Como o Wilcom se integra ao CorelDRAW

Através da análise de engenharia reversa nos binários do Wilcom (`C:\Program Files\Wilcom\EmbroideryStudio_e4.2\BIN`), mapeamos os seguintes componentes:

```
+-------------------------------------------------------------+
|               Wilcom EmbroideryStudio (ES.EXE)              |
|                                                             |
|  +-------------------------------------------------------+  |
|  |                       COREL.DLL                       |  |
|  |  - ICorelManager / CorelManager                       |  |
|  |  - CorelVectorToEmbroideryConverter                   |  |
|  |  - CorelVectorToAppliqueConverter                     |  |
|  |  - CorelTextToLetteringConverter                      |  |
|  |  - CorelChildFrame / CorelCntrItem (MFC OLE Container)|  |
|  +-------------------------------------------------------+  |
+------------------------------+------------------------------+
                               |
                   OLE / COM & CorelWPLStream
                               |
+------------------------------v------------------------------+
|               CorelWPLx64_Wilcom_e4.x.cpg                   |
|  - Plugin CPG (AttachPlugin) carregado no CorelDRAW         |
+------------------------------+------------------------------+
                               |
+------------------------------v------------------------------+
|                 CorelDRAW Graphics Suite                    |
|  - CorelDRW.EXE / ProgID: CorelDRAW.Graphic                 |
|  - Chaves de registro: HKLM\Software\Corel\CorelDRAW\18..20 |
+-------------------------------------------------------------+
```

### O Fluxo de Dados:
1. **Ativação**: O Wilcom detecta a instalação do CorelDRAW através do Registro do Windows (`Software\Corel\CorelDRAW`).
2. **Container OLE**: O Wilcom cria uma janela filha (`CorelChildFrame` / `CorelCntrItem`) incorporando o canvas vetorial do CorelDRAW via OLE In-Place Activation.
3. **Conversão Vetor -> Ponto**: Quando o usuário clica em "Converter em Bordado", o conversor `CorelVectorToEmbroideryConverter` requisita do CorelDRAW a lista de curvas Bézier (nós, vetores de direção, preenchimentos RGB e contornos).
4. **Geração de Pontos**: O motor geométrico do Wilcom (`Geometry.dll` + `Wessys.dll`) recebe as curvas e calcula os pontos de bordado (Tatami para preenchimento, Satin para colunas e Run para contornos).

---

## 2. A Solução com o VectorCraft (Artcraft)

O **VectorCraft** (desenvolvido pelo time do Artcraft em Rust) possui capacidades sob medida para essa substituição:
* **Precisão Vetorial**: Motor Bézier de alto desempenho nativo.
* **Formatos Suportados**: Exportação para EMF, SVG, DXF, EPS e AI com controle decimal de nós.
* **Canal de Controle (IPC)**:
  * Suporte a `--control <PORT>` para controle via socket em tempo real.
  * Executável de automação `vectorcraft-cli` capaz de inspecionar, exportar e converter documentos em background.

---

## 3. Roteiro de Implementação

### Fase 1: Companion Bridge (Live Sync)
* Um utilitário em segundo plano que monitora projetos abertos no VectorCraft.
* Ao acionar um comando ou atalho (ex: `Ctrl+Shift+E`), os vetores do VectorCraft são exportados em formato de alta precisão (EMF/SVG) e enviados automaticamente para vetorização no Wilcom.

### Fase 2: Emulador COM (Corel Proxy Shim)
* Criação de um servidor COM DLL que responde ao ProgID `CorelDRAW.Graphic`.
* O Wilcom instancia o nosso proxy acreditando ser o CorelDRAW.
* O proxy redireciona os comandos para a instância do VectorCraft aberta, emulando o `CorelWPLStream`.
