# 🚀 Windows Registry Tweaker Pro

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-blue.svg)](https://www.microsoft.com/windows)
[![Language](https://img.shields.io/badge/Language-Free%20Pascal%20%2F%20Lazarus-orange.svg)](https://www.lazarus-ide.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()

Et professionelt open-source administrations- og sikkerhedsværktøj til Microsoft Windows 10 og Windows 11, udviklet i **Free Pascal** og **Lazarus IDE**.

Programmet giver en overskuelig, grafisk kontrol over 46 dybdegående systemparametre opdelt i 10 kategorier – med dynamisk visning af fordele og risici samt integreret genstarts- og backup-motor.

---

## ✨ Nøglefunktioner

* **10 Specialiserede Kategorier**:
  1. *Hurtigere Windows* (UI-responsivitet, menuer, Explorer isolation)
  2. *Sikkerhed & Privatliv* (Telemetri-stop, USB-lagerspærring, AutoRun deaktivering)
  3. *System & Ydeevne* (Dvale/hiberfil.sys, SSD Prefetcher, Kernel i RAM)
  4. *Netværk & Gaming* (GPU/Tasks prioritering, TCP sockets, QoS frigivelse)
  5. *Sikkerhedshærdning (Del 1)* (UAC Secure Desktop, WSH blokering mod ransomware, BitLocker 256-bit XTS-AES)
  6. *Sikkerhedshærdning (Del 2)* (Internet makro-blokering, RDP-spærring, inaktivitetslås)
  7. *Privatliv & Telemetri* (Fjern Bing i Start, stop reklame-ID, klassisk Win 11 kontekstmenu)
  8. *Avanceret Kerne & GPU* (HAGS, CPU Core Parking oplåsning, LargeSystemCache)
  9. *Hardware & Strømstyring* (PCIe Link State, HDD timeout oplåsning, DiagTrack)
  10. *UI & Systemstrømlining* (Fjern Windows 11 widgets, åbn i "Denne pc", Sticky Keys fra)
* **Realtids-inspektion**: Når musen holdes over et tweak, forklares fordele og ulemper straks i infopanelet.
* **Fuld Sikkerhedskopi**: Eksporterer en komplet, officiel UTF-16LE `.reg`-fil med Byte Order Mark (`$FEFF`), som kan flettes ind igen når som helst.
* **Integreret Genstart**: Beder automatisk kernen om `SeShutdownPrivilege` og udfører en ren systemgenstart direkte fra menuen.
* **Hærdet Arkitektur**: 100% 64-bit registreringsdatabaseadgang (`KEY_WOW64_64KEY`), ægte UAC-håndhævelse og race condition-fri proceseksekvering.

---

## 🛠️ Sådan bygger du projektet fra kildekode

### Forudsætninger
* [Lazarus IDE](https://www.lazarus-ide.org/) (version 2.2.6 eller nyere anbefales)
* Free Pascal Compiler (FPC 3.2.2 eller nyere)

### Trin-for-trin
1. Klon dette repository:
   ```bash
   git clone https://github.com/DIT-BRUGERNAVN/WinRegistryTweaker.git
   cd WinRegistryTweaker
