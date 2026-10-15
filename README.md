# Wilcom Artcraft Bridge

Ponte de integração entre o **VectorCraft (Suite Artcraft)** e o **Wilcom EmbroideryStudio**.

## 🎯 Objetivo

Permitir que usuários do **Wilcom EmbroideryStudio** utilizem o **VectorCraft / Artcraft** como seu motor de design vetorial nativo em substituição ao CorelDRAW Graphics Suite, mantendo o fluxo de trabalho ágil de conversão de curvas Bézier, nós, formas e cores diretamente para pontos de bordado (Tatami, Satin, Run Stitch, Appliqué).

---

## 🏛️ Arquitetura da Integração

O Wilcom EmbroideryStudio (e.g. e4.2) tradicionalmente se conecta ao CorelDRAW através de:
1. **`COREL.DLL`**: Componente OLE/MFC dentro do diretório `BIN` do Wilcom.
2. **`CorelWPLx64_Wilcom_e4.x.cpg`**: Plugin CPG carregado dentro do CorelDRAW que expõe um canal de comunicação IPC (`CorelWPLStream`).
3. **Automação COM**: Interfaces Windows OLE/ActiveX (`CorelDRAW.Application`).

### Estratégia de Portabilidade para o VectorCraft:
* **VectorCraft Control Channel**: O VectorCraft possui suporte nativo a controle de automação via IPC/Socket (`vectorcraft --control <PORT>`) e CLI (`vectorcraft-cli`).
* **Formatos de Alta Precisão**: O VectorCraft exporta nativamente para EMF, SVG, DXF, EPS e AI com retenção total de nós Bézier e precisão decimal configurável.
* **Bridge Service**: Serviço responsável por sincronizar a viewport vetorial do VectorCraft com a área de trabalho do Wilcom e disparar a conversão vetorial direta.

---

## 🚀 Como Executar

### Pré-requisitos
* **VectorCraft Portable x64**: Instalado em `E:\Apps\VectorCraft`.
* **Wilcom EmbroideryStudio**: (e4.2 ou superior).
* **Git & GitHub CLI**: Configurados.

---

## 👥 Autoria & Licença
* Autor: [Djalma Matos (@djalmabmatos)](https://github.com/djalmabmatos)
* Licença: MIT
