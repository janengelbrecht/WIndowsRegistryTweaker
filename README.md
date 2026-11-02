<div align="center">

# 🚀 Windows Registry Tweaker Pro

**Professionelt, hærdet og modulært administrationsværktøj til Microsoft Windows 10 & 11**

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20(64--bit)-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Engine](https://img.shields.io/badge/Language-Free%20Pascal%20%2F%20Lazarus-E95420?style=for-the-badge&logo=delphi&logoColor=white)](https://www.lazarus-ide.org/)
[![Architecture](https://img.shields.io/badge/Arch-x86__64%20(Win64)-4A154B?style=for-the-badge&logo=target&logoColor=white)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Build](https://img.shields.io/badge/Build-Passing-brightgreen.svg?style=for-the-badge)]()

<p align="center">
  <a href="#-nøglefunktioner">Nøglefunktioner</a> •
  <a href="#-oversigt-over-tweaks">De 46 Tweaks</a> •
  <a href="#-installation-og-brug">Installation</a> •
  <a href="#-kildekode--kompilering">Kompilering</a> •
  <a href="#-sikkerhed-og-ansvar">Sikkerhed & Backup</a> •
  <a href="#-fejlfinding-og-recovery">Nødhjælp</a>
</p>

---

</div>

## 📖 Om Windows Registry Tweaker Pro

**Windows Registry Tweaker Pro** samler 46 gennemtestede, dybdegående optimeringer, sikkerhedshærdninger og privatlivsparametre i én samlet, krystalklar brugerflade. 

I stedet for risikabel manuel redigering i `regedit`, lokale gruppepolitikker (`gpedit.msc`) eller spredte PowerShell- og CMD-scripts, får du en deterministisk platform med:

* **Sikkerhed i højsædet:** Automatisk generering af fulde, importerbare `.reg`-sikkerhedskopier med UTF-16LE og BOM.
* **Fuld gennemsigtighed:** Live-inspektion af enhver systemindstilling med fordele, risici og teknisk effekt.
* **Robust 64-bit motor:** Tvinger adgang til 64-bit registreringsdatabasen via `KEY_WOW64_64KEY`, hvilket forhindrer forkert WOW64-omdirigering.
* **Zero Overhead:** Udviklet i ren compiled Object Pascal (FPC/Lazarus) uden runtime-afhængigheder som .NET Runtime, Electron eller Python.

---

## ✨ Nøglefunktioner

| Funktion | Beskrivelse |
| :--- | :--- |
| **10 Tematiske Faner** | 46 tweaks opdelt efter formål: Responsivitet, Sikkerhed, Kerne, Netværk m.fl. |
| **Realtidsinspektion** | Hold musen over en boks, eller brug <kbd>Tab</kbd>, for at få en grundig teknisk forklaring. |
| **Fuld Sikkerhedskopi** | Eksporterer maskinens tilstand til en standardiseret `.reg`-fil (UTF-16LE med `$FEFF` BOM). |
| **Ren Systemgenstart** | Sikker tildeling af `SeShutdownPrivilege` i Windows-kernen med efterfølgende genstart via menuen. |
| **Batch-automatisering** | Aktivér eller nulstil hele faneblade med ét klik — eller hele pakken på én gang. |
| **DPI & Layout Sikring** | Skalerer fejlfrit fra almindelige 1080p-skærme til 4K High-DPI skærme med forstørrelse. |

---

## 🗂️ Oversigt over Tweaks

Nedenfor kan du folde de enkelte kategorier ud for at inspicere de 46 inkluderede tweaks:

<details>
<summary><b>1. Hurtigere Windows (5 tweaks)</b></summary>
<br>

| Parameter | Registreringsnøgle / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **WaitToKillAppTimeout** | `HKCU\Control Panel\Desktop` | `5000` | `2000` | Lukker hængende programmer hurtigere ved shutdown. |
| **MenuShowDelay** | `HKCU\Control Panel\Desktop` | `400` | `20` | Fjerner forsinkelse når menuer og underpunkter foldes ud. |
| **AutoEndTasks** | `HKCU\Control Panel\Desktop` | `0` | `1` | Lukker automatisk fastlåste opgaver ved nedlukning. |
| **SeparateProcess** | `HKCU\...\Explorer\Advanced` | `0` | `1` | Kører Stifinder-mapper adskilt fra proceslinjen. |
| **NetworkThrottlingIndex** | `HKLM\...\SystemProfile` | `10` | `0xFFFFFFFF` | Fjerner båndbreddebegrænsning for spil og mediastreaming. |

</details>

<details>
<summary><b>2. Sikkerhed & Privatliv (6 tweaks)</b></summary>
<br>

| Parameter | Registreringsnøgle / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **AllowTelemetry** | `HKLM\...\Windows\DataCollection` | `3` | `0` | Deaktiverer Windows telemetri- og brugsdataindsamling. |
| **USBSTOR Start** | `HKLM\SYSTEM\...\Services\USBSTOR` | `3` | `4` | Blokerer fremmede USB-lagermedier mod malware og tyveri. |
| **RemoteRegistry Start** | `HKLM\SYSTEM\...\Services\RemoteRegistry`| `3` | `4` | Lukker for fjernadgang til computerens registreringsdatabase. |
| **NoDriveTypeAutoRun** | `HKCU\...\Policies\Explorer` | `0x91` | `0xFF` | Blokerer automatisk kørsel af kode/scripts på tilsluttede medier. |
| **VoiceActivationAboveLock**| `HKCU\...\Speech_OneCore\Preferences` | `1` | `0` | Slår stemmeaktivering fra når maskinen er låst. |
| **DontDisplayLastUserName**| `HKLM\...\Policies\System` | `0` | `1` | Skjuler forrige brugernavn på loginskærmen. |

</details>

<details>
<summary><b>3. System & Ydeevne (6 tweaks)</b></summary>
<br>

| Parameter | Type / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **Dvaletilstand** | `powercfg -h off` | Aktiv | Deaktiveret | Frigiver RAM-størrelse i diskplads på C: (`hiberfil.sys`). |
| **EnablePrefetcher** | `HKLM\...\PrefetchParameters` | `3` | `0` | Skåner SSD-drev mod unødige skrivehandlinger. |
| **Win32PrioritySeparation**| `HKLM\...\PriorityControl` | `2` | `38` | Giver aktivt forgrundsvindue maksimal CPU-tid (3:1). |
| **VBS Deaktivering** | `HKLM\...\DeviceGuard` | `1` | `0` | Fjerner virtualiserings-overhead for maksimal gaming FPS. |
| **DisablePagingExecutive** | `HKLM\...\Memory Management` | `0` | `1` | Tvinger Windows-kernen til at forblive i hurtig fysisk RAM. |
| **NtfsDisableLastAccess** | `HKLM\...\FileSystem` | `2` | `1` | Stopper konstante opdateringer af fil-adgangsstempler. |

</details>

<details>
<summary><b>4. Netværk & Gaming (4 tweaks)</b></summary>
<br>

| Parameter | Registreringsnøgle / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **GPU Priority** | `HKLM\...\Tasks\Games` | `2` | `8` | Giver spilgrafik førsteprioritet i GPU-skemalæggeren. |
| **Priority** | `HKLM\...\Tasks\Games` | `2` | `6` | Prioriterer spiltråde over baggrundsprocesser. |
| **TcpTimedWaitDelay** | `HKLM\...\Tcpip\Parameters` | `120` | `30` | Frigiver lukkede TCP-porte markant hurtigere. |
| **NonBestEffortLimit** | `HKLM\...\Policies\Windows\Psched` | `20` | `0` | Frigiver de 20% båndbredde, Windows reserverer til QoS. |

</details>

<details>
<summary><b>5. Sikkerhedshærdning Del 1 (7 tweaks)</b></summary>
<br>

| Parameter | Registreringsnøgle / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **ConsentPromptBehaviorAdmin**| `HKLM\...\Policies\System` | `5` | `2` | Kræver aktiv godkendelse på isoleret skrivebord (UAC). |
| **Windows Script Host** | `HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings` | `1` | `0` | Spærrer `.vbs`/`.js` scripts (primært ransomware-værn). |
| **DisableCAD** | `HKLM\...\Policies\System` | `1` | `0` | Tvinger tryk på <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>Del</kbd> mod falske loginskærme. |
| **ClearPageFileAtShutdown** | `HKLM\...\Memory Management` | `0` | `1` | Overskriver sidefilen ved sluk mod dataudlæsning. |
| **RestrictAnonymous** | `HKLM\SYSTEM\CurrentControlSet\Control\Lsa` | `0` | `1` | Forhindrer anonyme brugere i at opliste netværksdelinger. |
| **EncryptionMethodWithXtsOs**| `HKLM\SOFTWARE\Policies\Microsoft\FVE` | `6` | `7` | Gennemtvinger BitLocker 256-bit XTS-AES kryptering. |
| **SMB1 Server** | `HKLM\...\LanmanServer\Parameters` | `1` | `0` | Lukker den usikre SMBv1-protokol (kendt fra WannaCry). |

</details>

<details>
<summary><b>6. Sikkerhedshærdning Del 2 (5 tweaks)</b></summary>
<br>

| Parameter | Registreringsnøgle / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **BlockMacrosFromInternet** | `HKCU\...\word\security` | `0` | `1` | Blokerer kørsel af makroer i hentede Office-filer. |
| **fDenyTSConnections** | `HKLM\...\Terminal Server` | `0` | `1` | Lukker port 3389 permanent mod Remote Desktop angreb. |
| **InactivityTimeoutSecs** | `HKLM\...\Policies\System` | `0` | `900` | Låser maskinen automatisk efter 15 minutters inaktivitet. |
| **LetAppsAccessCamera** | `HKLM\...\Windows\AppPrivacy` | `0` | `2` | Nægter moderne apps adgang til webkameraet. |
| **LetAppsAccessMicrophone** | `HKLM\...\Windows\AppPrivacy` | `0` | `2` | Nægter moderne apps adgang til mikrofonen. |

</details>

<details>
<summary><b>7. Privatliv & Telemetri (7 tweaks)</b></summary>
<br>

| Parameter | Registreringsnøgle / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **DisableSearchBoxSuggestions**| `HKCU\...\Policies\Explorer` | `0` | `1` | Fjerner net- og Bing-forslag i Startmenuens søgning. |
| **AdvertisingInfo Enabled** | `HKCU\...\AdvertisingInfo` | `1` | `0` | Deaktiverer det personlige reklame-ID. |
| **SubscribedContent-338387** | `HKCU\...\ContentDeliveryManager` | `1` | `0` | Stopper promoverede forslag på låseskærmen. |
| **DisableLocation** | `HKLM\...\LocationAndSensors` | `0` | `1` | Afbryder alle baggrundslokationstjenester. |
| **NumberOfHeartbeatsAllowed** | `HKCU\...\Siuf\Rules` | `1` | `0` | Slår konstante feedback-popups fra. |
| **SilentInstalledAppsEnabled**| `HKCU\...\ContentDeliveryManager` | `1` | `0` | Blokerer automatisk download af bloatware-apps. |
| **Klassisk Kontekstmenu** | `HKCU\Software\Classes\CLSID\{86ca1aa0...}` | Ny | Aktiv | Gendanner Windows 10 højrekliksmenuen i Windows 11. |

</details>

<details>
<summary><b>8. Avanceret Kerne & GPU (5 tweaks)</b></summary>
<br>

| Parameter | Registreringsnøgle / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **CPU Core Parking Visibility**| `HKLM\...\0cc5b647-c1df...` | `1` | `2` | Låser op for CPU Core Parking i Avanceret Strømstyring. |
| **HwSchMode (HAGS)** | `HKLM\...\GraphicsDrivers` | `1` | `2` | Aktiverer Hardwareaccelereret GPU-skemalægning. |
| **LargeSystemCache** | `HKLM\...\Memory Management` | `0` | `1` | Allokerer en større RAM-buffer til fildata (kræver 16GB+). |
| **WER Disabled** | `HKLM\...\Windows Error Reporting` | `0` | `1` | Slår Microsofts automatiske fejllogning fra ved nedbrud. |
| **NtfsDisable8dot3NameCreation**| `HKLM\...\FileSystem` | `2` | `1` | Stopper oprettelse af korte DOS-navne på NTFS-drev. |

</details>

<details>
<summary><b>9. Hardware & Strømstyring (3 tweaks)</b></summary>
<br>

| Parameter | Registreringsnøgle / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **PCIe Link State Synlighed** | `HKLM\...\ee12f251-da30...` | `1` | `2` | Gør PCIe strømsparemode synlig i Kontrolpanel. |
| **HDD-Timeout Synlighed** | `HKLM\...\6738e2c6-ee1b...` | `1` | `2` | Gør mekanisk harddisk-dvale synlig i Kontrolpanel. |
| **DiagTrack Start** | `HKLM\SYSTEM\...\Services\DiagTrack` | `2` | `4` | Stopper permanent Microsofts diagnosticeringstjeneste. |

</details>

<details>
<summary><b>10. UI & Systemstrømlining (5 tweaks)</b></summary>
<br>

| Parameter | Registreringsnøgle / Sti | Standard | Optimeret | Formål |
| :--- | :--- | :--- | :--- | :--- |
| **AllowWidgets** | `HKLM\SOFTWARE\Policies\Microsoft\Dsh`| `1` | `0` | Fjerner Widgets-panelet og sparer baggrunds-RAM. |
| **LaunchTo** | `HKCU\...\Explorer\Advanced` | `2` | `1` | Åbner altid Stifinder i "Denne pc" frem for "Hjem". |
| **StickyKeys Flags** | `HKCU\Control Panel\Accessibility\StickyKeys`| `510` | `506` | Deaktiverer genvejen (5× Shift) ved hurtige tastetryk i spil. |
| **DisableStartupSound** | `HKLM\...\Authentication\LogonUI` | `0` | `1` | Slår Windows-opstartslyden permanent fra. |
| **Fjern 3D-objekter** | `HKLM\...\FolderDescriptions\...` | `Show` | `Hide` | Fjerner mappen 3D-objekter fra oversigten i "Denne pc". |

</details>

---

## 💻 Systemkrav

> [!NOTE]
> Programmet er bygget specifikt til 64-bit Windows og kan ikke afvikles på Windows 7, 8 eller 32-bit udgaver.

| Komponent | Minimumskrav | Anbefalet |
| :--- | :--- | :--- |
| **Styresystem** | Windows 10 (Build 1809 eller nyere) | Windows 11 (23H2 / 24H2) |
| **Arkitektur** | 64-bit (x86_64 / amd64) | 64-bit |
| **Rettigheder** | Lokale Administratorrettigheder | Administrator (UAC aktiv) |
| **RAM** | 4 GB | 16 GB+ *(for tweaks som PagingExecutive/LargeCache)* |
| **Skærm** | 1280 × 720 | 1920 × 1080 eller højere |

---

## 🚀 Installation og Brug

### 1. Download
1. Gå til [Releases](../../releases) sektionen her på GitHub.
2. Hent den seneste zip-pakke: `WinRegistryTweaker_vX.X.zip`.
3. Udpak mappen et sikkert sted på din computer (f.eks. `C:\Værktøjer\WinRegistryTweaker\`).

### 2. Kørsel med Administratorrettigheder
Programmet konfigurerer parametre i `HKEY_LOCAL_MACHINE` og kalder operativsystemets kerne. 

> [!WARNING]
> Programmet **skal** køre som administrator. Hvis det startes uden forhøjede rettigheder, lukker det proaktivt ned med en advarsel for at forhindre delvise eller korrupte skrivninger.

1. Højreklik på `WinRegistryTweaker.exe`.
2. Vælg **Kør som administrator**.
3. Tryk **Ja** i Windows UAC-prompterne.

*(Tip: Opret en genvej på skrivebordet, gå til **Egenskaber** → **Genvej** → **Avanceret...** og sæt flueben i **Kør som administrator**).*

---

## 🛡️ Sikkerhed og Ansvar

### Tag altid en sikkerhedskopi som det første!
Inden du aktiverer eller ændrer indstillinger, bør du tage en fuld backup:

1. Klik på **Filer** i menulinjen.
2. Vælg **Gem fuld sikkerhedskopi af samtlige tweak-parametre...**.
3. Vælg placering (filen navngives automatisk med dato og sekundpræcist tidsstempel, f.eks. `WinTweaker_Backup_2026-11-02_14-30-00.reg`).

Filen gemmes med officiel **UTF-16LE og Byte Order Mark (`$FEFF`)**. Du kan altid nulstille dit system ved blot at dobbeltklikke på denne fil i Windows Stifinder.