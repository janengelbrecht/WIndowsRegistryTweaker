🚀 Windows Registry Tweaker Pro
https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-blue.svg
https://img.shields.io/badge/Language-Free%20Pascal%20%2F%20Lazarus-orange.svg
https://img.shields.io/badge/License-MIT-yellow.svg
https://img.shields.io/badge/Build-Passing-brightgreen.svg

Et professionelt open source-administrations- og hærdningsværktøj til Microsoft Windows 10 og Windows 11, udviklet i Free Pascal og Lazarus IDE.

Programmet giver en overskuelig, grafisk kontrol over 46 dybdegående systemparametre opdelt i 10 kategorier – med dynamisk visning af fordele og risici samt integreret genstarts- og backup-motor.

📑 Indholdsfortegnelse
Hvad er Windows Registry Tweaker Pro?

Nøglefunktioner

Programmets 10 kategorier og 46 tweaks

Systemkrav

Installation – trin for trin

Sådan bygger du projektet fra kildekode

Kørsel af programmet – med Administratorrettigheder

Sådan bruges programmet

Sikkerhed – læs dette før du begynder

Hvad gør man, hvis noget ikke virker efter tweaking?

Konkrete symptomer og løsninger

Nødhjælp – hvis intet virker

Sådan undgår du problemer fremover

Teknisk arkitektur

Fejlfinding under bygning

Bidrag og licens

1. Hvad er Windows Registry Tweaker Pro?
Windows Registry Tweaker Pro er et administrationsværktøj, der samler en lang række gennemprøvede systemindstillinger i én enkelt, sikker og overskuelig brugerflade. I stedet for manuelt at navigere rundt i regedit, gpedit.msc, powercfg, services.msc og andre spredte systemværktøjer kan du med få klik optimere, hærde og strømline Windows 10 og Windows 11.

Programmet er bevidst designet efter fire principper:

Sikkerhed først – alle ændringer kan rulles tilbage, og der kan tages en fuld .reg-sikkerhedskopi inden ændringer.

Gennemsigtighed – hver tweak viser præcis, hvad den gør, hvilke fordele den giver, og hvilke risici den medfører.

Robusthed – programmet validerer rettigheder, datatyper og proceskald, så det ikke crasher eller efterlader systemet i en uheldig tilstand.

Tilgængelighed – både mus- og tastaturnavigation understøttes, og brugerfladen skalerer korrekt ved høj DPI og forskellige skærmstørrelser.

Programmet er udviklet i Free Pascal / Lazarus og er 100 % open source under MIT-licensen.

2. Nøglefunktioner
10 specialiserede kategorier med i alt 46 tweaks, der dækker alt fra UI-responsivitet og telemetri til kerneindstillinger og sikkerhedshærdning.

Realtidsinspektion: Når musen holdes over et tweak, forklares fordele og ulemper straks i infopanelet nederst.

Fuld sikkerhedskopi: Eksporterer en komplet, officiel UTF-16LE .reg-fil med Byte Order Mark ($FEFF), som kan flettes ind igen når som helst.

Integreret genstart: Beder automatisk kernen om SeShutdownPrivilege og udfører en ren systemgenstart direkte fra menuen.

Batch-handlinger: Aktivér eller gendan alle tweaks på en hel fane med ét klik – eller alle 46 på én gang via menuen.

Hærdet arkitektur: 100 % 64-bit registreringsdatabaseadgang (KEY_WOW64_64KEY), ægte UAC-håndhævelse og race condition-fri proceseksekvering.

Dansk brugerflade og dansk dokumentation.

3. Programmets 10 kategorier og 46 tweaks
Programmet er organiseret i ti faneblade, der hver især samler beslægtede indstillinger. Hver kategori kan aktiveres eller rulles tilbage samlet via knapperne i bunden, eller enkeltvis via de individuelle afkrydsningsfelter.

1. Hurtigere Windows
Tweaks, der reducerer ventetid ved opstart, nedlukning og menuåbning.

WaitToKillAppTimeout – hurtigere lukning af apps ved nedlukning.

MenuShowDelay – reduceret ventetid på menuer.

AutoEndTasks – afslut fastlåste opgaver automatisk.

SeparateProcess – kør Stifinder-mapper i separate processer.

NetworkThrottlingIndex – deaktiver unødvendig netværks-throttling.

2. Sikkerhed & Privatliv
Grundlæggende beskyttelse mod telemetri, uautoriseret USB-adgang, AutoRun-malware og fjernadgang til registreringsdatabasen.

AllowTelemetry – deaktiver Windows-telemetri.

USBSTOR Start – forhindr uautoriseret USB-lageradgang.

RemoteRegistry Start – deaktiver Remote Registry.

NoDriveTypeAutoRun – slå AutoRun/AutoPlay helt fra.

VoiceActivationEnableAboveLockscreen – deaktiver stemmestyring over låseskærmen.

DontDisplayLastUserName – fjern senest loggede brugernavn på låseskærmen.

3. System & Ydeevne
Kerneindstillinger som Prefetcher, Win32PrioritySeparation, VBS-deaktivering, DisablePagingExecutive og NTFS-tidsstempler. Inkluderer også dvale-tweaket (via powercfg).

Dvale fra (powercfg -h off).

EnablePrefetcher – deaktiver Prefetcher (kun SSD).

Win32PrioritySeparation – forøg forgrunds-CPU-prioritet.

EnableVirtualizationBasedSecurity – slå VBS fra.

DisablePagingExecutive – behold kernen i RAM.

NtfsDisableLastAccessUpdate – slå NTFS fil-adgangsstempler fra.

4. Netværk & Gaming
Netværks- og GPU-prioritering for spillere.

GPU Priority – prioriter spilgrafik.

Priority (Tasks) – prioriter spilprocesser.

TcpTimedWaitDelay – hurtigere lukning af døde TCP-forbindelser.

NonBestEffortLimit – deaktiver QoS-båndbreddereservation.

5. Sikkerhedshærdning (Del 1)
Avancerede sikkerhedspolitikker.

ConsentPromptBehaviorAdmin – UAC på Secure Desktop.

Windows Script Host Enabled – bloker WSH mod ransomware.

DisableCAD – tving sikker CTRL+ALT+DEL ved login.

ClearPageFileAtShutdown – tøm sidefilen ved nedlukning.

RestrictAnonymous – deaktiver anonym adgang til delinger.

EncryptionMethodWithXtsOs – BitLocker 256-bit XTS-AES.

SMB1 – deaktiver SMBv1 (WannaCry-værn).

6. Sikkerhedshærdning (Del 2)
App-specifikke sikkerhedstiltag.

BlockMacrosFromInternet – bloker makroer fra internettet (Word).

fDenyTSConnections – bloker RDP.

InactivityTimeoutSecs – lås computeren efter 15 minutters inaktivitet.

LetAppsAccessCamera – bloker webkamera for UWP-apps.

LetAppsAccessMicrophone – bloker mikrofon for UWP-apps.

7. Privatliv & Telemetri
DisableSearchBoxSuggestions – slå Bing-søgninger fra i Start.

AdvertisingInfo Enabled – deaktiver reklame-ID.

SubscribedContent-338387Enabled – slå reklameforslag fra på låseskærmen.

DisableLocation – slå lokationssporing fra.

NumberOfHeartbeatsAllowed – slå feedback-påmindelser fra.

SilentInstalledAppsEnabled – forhindr promoverede apps.

Klassisk Win 11-kontekstmenu (tom nøgle under CLSID\{86ca1aa0-...}).

8. Avanceret Kerne & GPU
CPU Core Parking synlighed.

HAGS (HwSchMode).

LargeSystemCache.

WER-deaktivering.

NtfsDisable8dot3NameCreation.

9. Hardware & Strømstyring
PCIe Link State synlighed.

HDD-timeout synlighed.

DiagTrack Start – deaktiver Diagnostics Tracking Service.

10. UI & Systemstrømlining
AllowWidgets – fjern Widget-panelet.

LaunchTo – åbn Stifinder i "Denne pc".

StickyKeys Flags – slå Sticky Keys-popup fra.

DisableStartupSound – deaktiver opstartslyd.

ThisPCPolicy – fjern "3D-objekter"-mappen.

💡 Bemærk: Nogle tweaks (f.eks. CPU Core Parking og PCIe Link State) gør kun indstillingen synlig i Kontrolpanel → Strømstyring. Du skal selv efterfølgende åbne Kontrolpanel og vælge den ønskede værdi.

4. Systemkrav
Minimum:

Styresystem: Windows 10 (1809) eller Windows 11

Arkitektur: 64-bit

Rettigheder: Administrator

RAM: 4 GB

Diskplads: ca. 50 MB

Skærm: 1280×720

Anbefalet:

Styresystem: Windows 11 23H2 eller nyere

Arkitektur: 64-bit

Rettigheder: Administrator

RAM: 16 GB (for RAM-krævende tweaks)

Diskplads: ca. 100 MB

Skærm: 1920×1080 eller højere

Bemærk: Programmet kan ikke køre på Windows 7, 8 eller 8.1. Det kræver Windows 10 eller nyere.

5. Installation – trin for trin
5.1 Hent programmet
Der er to måder at anskaffe programmet på:

A. Download en færdigbygget .exe-fil (anbefalet for almindelige brugere):

Gå til projektets Releases-side på GitHub.

Download den nyeste .zip-fil (f.eks. WinRegistryTweaker_v1.0.zip).

Pak .zip-filen ud i en mappe efter eget valg – f.eks. C:\Værktøjer\WinRegistryTweaker\.

Undgå at placere programmet i C:\Program Files\, fordi mappen kræver forhøjede rettigheder ved hver opdatering.

B. Byg programmet selv fra kildekode – se afsnit 6.

5.2 Første opstart – vigtigt
Naviger til den mappe, hvor du udpakkede programmet.

Højreklik på WinRegistryTweaker.exe.

Vælg "Kør som administrator".

Windows viser en UAC-dialog ("Vil du tillade, at denne app foretager ændringer på denne pc?"). Klik "Ja".

Programmets hovedvindue åbnes.

⚠️ Vigtigt: Hvis du starter programmet ved at dobbeltklikke på .exe-filen, vil Windows ikke give det administratorrettigheder – heller ikke selv om din brugerkonto er Administrator. Programmet vil derfor vise en fejlmeddelelse og afslutte sig selv. Dette er en bevidst sikkerhedsforanstaltning: Uden forhøjede rettigheder kan programmet ikke skrive til HKEY_LOCAL_MACHINE, og halvdelen af tweaksene ville fejle med "Access Denied".

5.3 Opret en genvej med administratorrettigheder (anbefalet)
For at undgå at skulle højreklikke hver gang kan du oprette en genvej, der altid kører som administrator:

Højreklik på skrivebordet → Ny → Genvej.

Angiv placeringen af .exe-filen, f.eks.:

text
C:\Værktøjer\WinRegistryTweaker\WinRegistryTweaker.exe
Klik Næste, giv genvejen et navn (f.eks. "Registry Tweaker Pro"), klik Udfør.

Højreklik på den nye genvej → Egenskaber → fanen Genvej → knappen Avanceret.

Sæt flueben i "Kør som administrator", klik OK → OK.

Herefter starter et dobbeltklik på genvejen programmet med de nødvendige rettigheder (Windows viser stadig UAC-bekræftelsen).

6. Sådan bygger du projektet fra kildekode
6.1 Forudsætninger
Lazarus IDE version 2.2.6 eller nyere (anbefalet).

Free Pascal Compiler (FPC 3.2.2 eller nyere) – følger med Lazarus.

Git (valgfrit, men anbefalet til at hente kilden).

6.2 Trin for trin
Klon repository'et:

bash
git clone https://github.com/DIT-BRUGERNAVN/WinRegistryTweaker.git
cd WinRegistryTweaker
Åbn projektet i Lazarus:

Start Lazarus.

Vælg Fil → Åbn og naviger til WinRegistryTweaker.lpr.

Klik Åbn.

Kontrollér projektindstillinger:

Vælg Projekt → Projektindstillinger.

Under Compilerindstillinger → Mål, vælg Win64.

Under Compilerindstillinger → Oversættelse, sæt flueben i "Byg med de samme indstillinger som Lazarus selv" (anbefalet).

Byg projektet:

Vælg Kør → Byg (eller tryk Shift+F9).

Hvis bygningen lykkes, findes .exe-filen i projektmappen (typisk WinRegistryTweaker.exe).

Kør programmet:

Vælg Kør → Kør (F9).

Lazarus starter programmet med de nødvendige rettigheder, hvis Lazarus selv kører som administrator. Ellers start programmet manuelt som beskrevet i afsnit 5.2.

6.3 Fejlfinding under bygning
Fatal: Can't find unit Interfaces
Lazarus' LCL-pakke er ikke installeret korrekt. Geninstaller Lazarus med LCL-pakken.

Fatal: Dette program understøtter udelukkende Microsoft Windows styresystemet
Du bygger på Linux/macOS. Skift til Windows, eller opsæt et krydskompileringsmiljø.

Error: Identifier not found "TTokenInformationClass"
Forældet Free Pascal-version. Opdater til FPC 3.2.2 eller nyere.

Error: resource compiler not found
windres mangler. Sørg for, at Lazarus' fpc\bin-mappe er i PATH.

7. Kørsel af programmet – med Administratorrettigheder
7.1 Hvorfor kræver programmet Administratorrettigheder?
Programmet ændrer indstillinger under både HKEY_CURRENT_USER og HKEY_LOCAL_MACHINE. Sidstnævnte er systemets globale konfigurationsdatabase, som kræver forhøjede rettigheder at skrive til. Programmet undersøger derfor ved opstart, om processen kører med et forhøjet token (via OpenProcessToken og GetTokenInformation med TokenElevation). Hvis ikke, vises en fejlmeddelelse, og programmet afslutter sig selv.

7.2 De tre måder at starte programmet korrekt på
1. Højreklik-metoden (anbefalet til engangsbrug):

Højreklik på WinRegistryTweaker.exe → "Kør som administrator" → "Ja" i UAC-dialogen.

2. Genvejsmetoden (anbefalet til daglig brug):

Opret en genvej med "Kør som administrator" som beskrevet i afsnit 5.3.

3. Kommandolinje-metoden (til avancerede brugere):

Åbn en Kommandoprompt som administrator og skriv:

text
"C:\Værktøjer\WinRegistryTweaker\WinRegistryTweaker.exe"
7.3 Hvad sker der, hvis man starter uden Administratorrettigheder?
Programmet viser følgende meddelelse og afslutter sig selv:

Administratorrettigheder påkrævet
Dette værktøj skal afvikles som Administrator for at kunne justere systemindstillinger.
Højreklik på programmet og vælg "Kør som administrator".

Dette er en bevidst "fail-fast"-mekanisme: Det er bedre at stoppe med en klar besked end at lade brugeren klikke rundt i en brugerflade, hvor halvdelen af handlingerne alligevel ville fejle med "Access Denied".

8. Sådan bruges programmet
Trin 1 – Start programmet som Administrator
Se afsnit 7.

Trin 2 – Tag en sikkerhedskopi (stærkt anbefalet)
Vælg Filer → Gem fuld sikkerhedskopi... og gem .reg-filen et sikkert sted – f.eks. på et USB-drev eller i skyen. Filen kan genskabe hele tilstanden, hvis noget går galt.

Trin 3 – Gennemgå kategorierne
Klik gennem fanebladene, læs fordele og ulemper i infopanelet nederst, og sæt flueben ved de ønskede optimeringer. Eller brug "Aktivér alle på denne fane" for en hel kategori.

Trin 4 – Anvend ændringerne
Ændringer skrives straks til registreringsdatabasen, når du klikker. Mange kræver dog en genstart for fuld effekt.

Trin 5 – Genstart computeren
Vælg Filer → Genstart Windows nu (eller genstart manuelt), så indstillingerne træder i kraft.

Tips til daglig brug
Brug musen eller tastaturet: Hvert afkrydsningsfelt kan nås med Tab-tasten, og fordele/ulemper vises automatisk, når feltet får fokus.

Hold musen over et tweak for at læse den detaljerede beskrivelse i infopanelet.

Brug statuslinjen nederst til at følge med i, hvad programmet laver.

Tag en ny sikkerhedskopi, hver gang du har aktiveret en større batch ændringer.

9. Sikkerhed – læs dette før du begynder
9.1 Programmet er ikke en "magisk optimeringsknap"
Programmet ændrer systemkritiske indstillinger i Windows. Nogle tweaks påvirker sikkerheden, login-adfærd, netværksfunktioner eller hardwareadfærd. Derfor er det afgørende, at du:

Læser beskrivelserne i infopanelet, før du slår et tweak til.

Aktiverer tweaks gradvist – ikke alle 46 på én gang.

Tager en sikkerhedskopi før større ændringer.

9.2 Hvad gør programmet for at beskytte dig?
Alle ændringer kan rulles tilbage – både enkeltvis, pr. fane og globalt.

Fuld .reg-backup med korrekt UTF-16LE-kodning og BOM, som kan importeres af Windows' egen regedit.

Batch-bekræftelse: "Anvend alle" kræver en eksplicit bekræftelse, fordi det ændrer login-adfærd.

64-bit registeradgang (KEY_WOW64_64KEY) forhindrer, at 32-bit og 64-bit visninger blandes sammen.

Race condition-fri proceseksekvering: powercfg.exe hentes altid fra den ægte C:\Windows\System32 via GetSafeSystemPath, så et PATH-angreb forhindres.

Event-guard (FUpdatingUI) forhindrer uendelige rekursive kald mellem CheckBoxClick, SetTweakInRegistry og ReadSingleTweakStatus.

Fejlhåndtering: Hvis et tweak fejler, vises en præcis fejlmeddelelse, og brugerfladen ruller tilbage til den faktiske tilstand.

9.3 Hvad programmet IKKE gør
Det gemmer ikke dine data eller sender dem til Microsoft eller tredjepart.

Det installerer ikke drivere eller baggrundstjenester.

Det ændrer ikke filer uden for registreringsdatabasen – bortset fra powercfg -h off, som sletter C:\hiberfil.sys (og dermed frigør diskplads).

Det kræver ikke internetadgang.

9.4 Før du aktiverer sikkerhedshærdning
Sikkerhedshærdningstweaksene (kategori 5 og 6) ændrer login- og systemadfærd:

CTRL+ALT+DEL ved login – du skal trykke denne kombination hver gang.

Skjult seneste brugernavn – du skal indtaste både brugernavn og adgangskode hver gang.

Blokeret RDP – du kan ikke fjernstyre computeren via Windows Fjernskrivebord.

Blokeret USB-lager – USB-stik og eksterne diske virker ikke (tastatur og mus påvirkes ikke).

Tøm sidefilen ved nedlukning – forlænger nedlukningstiden markant på maskiner med meget RAM.

Hvis du er i tvivl, så slå disse tweaks til én ad gangen og test, at alt stadig virker, før du fortsætter.

10. Hvad gør man, hvis noget ikke virker efter tweaking?
Selv om programmet er testet grundigt, kan visse tweaks have utilsigtede bivirkninger på den enkelte computer på grund af hardwareforskelle, driverversioner eller tredjepartssoftware. Her er en systematisk fremgangsmåde til at identificere og løse problemet.

10.1 Generel fremgangsmåde (uanset symptom)
1. Identificér det seneste tweak
Hvis problemet opstod lige efter, du aktiverede en bestemt tweak eller en hel kategori, er det sandsynligvis den, der er årsagen. Tænk tilbage: Hvad aktiverede du, lige før problemet opstod?

2. Rul tilbage kategorivis
Gå til det relevante faneblad, og klik "Gendan standard på denne fane". Dette ruller alle tweaks i den kategori tilbage til Windows' fabriksværdier – én handling, ingen manuel registerredigering.

3. Rul alt tilbage (sidste udvej)
Hvis du ikke kan identificere årsagen, og problemet er alvorligt, kan du rulle alle 46 tweaks tilbage:

Gå til hvert faneblad og klik "Gendan standard", eller

Importér den .reg-backup, du tog i trin 2 ovenfor (dobbeltklik filen i Stifinder).

4. Genstart computeren
Mange tweaks ændrer kerneadfærd og kræver genstart for at blive fuldt tilbagerullet. Genstart maskinen, før du konkluderer, at problemet varer ved.

5. Brug en hvilepunkt-genopretning
Hvis intet andet virker, kan du bruge Windows' indbyggede Systemgendannelse (Windows + R → rstrui.exe). Vælg et gendannelsespunkt fra før tweakingen.

11. Konkrete symptomer og løsninger
11.1 USB-drev kan ikke tilgås efter tweaking
Årsag: Tweaket "Forhindr uautoriseret USB-lageradgang (USBSTOR)" i kategorien "Sikkerhed & Privatliv" sætter USBSTOR-tjenesten til Start=4 (deaktiveret). Dette blokerer alle USB-lagerenheder (USB-stik, eksterne diske, kortlæsere) – men påvirker ikke USB-tastatur og USB-mus.

Løsning:

Åbn fanebladet "2. Sikkerhed & Privatliv".

Fjern fluebenet ud for "Forhindr uautoriseret USB-lageradgang".

Genstart computeren (vigtigt! USBSTOR-tjenesten skal genstartes).

USB-drevet er nu tilgængeligt igen.

Hvis det stadig ikke virker:

Åbn PowerShell som administrator.

Kør: Get-Service USBSTOR

Status skal vise Stopped (hvilket er normalt, indtil et drev tilsluttes), og StartType skal være Manual eller Automatic.

Hvis StartType stadig er Disabled, kør:

powershell
Set-Service USBSTOR -StartupType Manual
Alternativt: Åbn regedit → gå til
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\USBSTOR
og sæt Start til 3 (Manual).

11.2 Kan ikke logge ind på Windows efter tweaking
Årsag: Tweaket "Tving sikker CTRL+ALT+DEL ved login" eller "Fjern senest loggede brugernavn på låseskærm" kan ændre login-adfærden. I sjældne tilfælde kan en forkert kombination af sikkerhedspolitikker blokere normal pålogning.

Løsning (fra en anden konto eller via Sikker Tilstand):

Genstart i Sikker Tilstand (hold Shift nede under genstart, eller tryk F8 under opstart).

Log ind med en administratorkonto.

Åbn programmet (kør som administrator).

Gå til fanebladet "5. Sikkerhedshærdning (Del 1)" og rul alle tweaks tilbage.

Genstart normalt.

Hvis ingen konto virker:

Brug en Windows-installations-USB til at åbne Kommandoprompten via "Reparer computeren → Fejlfinding → Kommandoprompt" og gendan registreringsdatabasen fra en backup, eller brug Systemgendannelse.

11.3 Programmet starter ikke (adgangsfejl ved opstart)
Årsag: Manglende administratorrettigheder, eller UAC er blevet ændret af en tweak.

Løsning:

Højreklik på .exe-filen og vælg "Kør som administrator".

Hvis dette ikke virker, er UAC måske blevet deaktiveret. Åbn Kontrolpanel → Brugerkonti → Skift indstillinger for Brugerkonti, og sæt skyderen tilbage til standard (næstøverste niveau). Genstart.

11.4 Netværket virker ikke (ingen internetforbindelse)
Årsag: Tweaket "TcpTimedWaitDelay" eller "Deaktiver QoS-båndbreddereservation" kan i sjældne tilfælde påvirke netværket på specifikke hardwarekonfigurationer.

Løsning:

Åbn fanebladet "4. Netværk & Gaming".

Klik "Gendan standard på denne fane".

Genstart computeren.

Hvis problemet varer ved, kontrollér netværksdriveren i Enhedshåndtering (der kan være behov for en opdatering).

11.5 Spil kører dårligere efter tweaking
Årsag: Nogle GPU-tweaks (f.eks. HAGS) kan give micro-stuttering på ældre drivere. Ligeledes kan Win32PrioritySeparation påvirke baggrundsprocesser, som nogle spil afhænger af.

Løsning:

Åbn fanebladet "8. Avanceret Kerne & GPU".

Rul HAGS-tweaket tilbage (fjern fluebenet).

Åbn fanebladet "3. System & Ydeevne".

Rul Win32PrioritySeparation tilbage.

Genstart computeren.

11.6 Windows bliver meget langsom ved nedlukning
Årsag: Tweaket "Tøm sidefilen (Pagefile) ved nedlukning" forlænger nedlukningstiden betydeligt på computere med meget RAM, fordi hele sidefilen (typisk 4–16 GB) skal overskrives.

Løsning:

Åbn fanebladet "5. Sikkerhedshærdning (Del 1)".

Fjern fluebenet ud for "Tøm sidefilen (Pagefile) ved nedlukning".

Genstart computeren.

Bemærk: Dette tweak er kun relevant, hvis du har behov for at beskytte følsomme data mod fysisk udlæsning af disken.

11.7 Dvalefunktionen virker ikke mere
Årsag: Tweaket "Slå dvale fra (Sletter hiberfil.sys via powercfg)" har deaktiveret dvale og Hurtig Start (Fast Startup).

Løsning:

Åbn fanebladet "3. System & Ydeevne".

Fjern fluebenet ud for "Slå dvale fra".

Genstart computeren.

Hiberfil.sys genskabes automatisk af powercfg ved genstart.

11.8 Windows opfører sig underligt efter "Anvend alle"
Årsag: "Anvend alle" aktiverer alle 46 tweaks – inklusive sikkerhedshærdning, der ændrer login-adfærd, blokerer USB-lager og deaktiverer telemetri. Hvis du ikke har læst beskrivelserne, kan nogle af ændringerne virke overraskende.

Løsning:

Brug "Gendan standard" på hvert faneblad, eller importér din .reg-backup.

Genstart computeren.

Aktiver herefter tweaks gradvist – én kategori ad gangen – så du kan identificere eventuelle bivirkninger.

12. Nødhjælp – hvis intet virker
12.1 Start i Sikker Tilstand
Hold Shift nede under genstart, eller tryk F8 under opstart. Dette indlæser Windows med minimale drivere, så du kan tilgå programmet og rulle tweaks tilbage.

12.2 Brug .reg-backup
Dobbeltklik på den .reg-fil, du gemte i trin 2 ovenfor. Windows importerer den automatisk og genskaber den gemte tilstand. Husk at genstarte bagefter.

12.3 Systemgendannelse
Windows + R → rstrui.exe. Vælg et gendannelsespunkt fra før tweakingen. Dette ruller hele systemet tilbage (ikke kun registreringsdatabasen).

12.4 Windows-reparationsmiljø
Hvis Windows ikke kan starte, kan du bruge en Windows-installations-USB: "Reparer computeren → Fejlfinding → Kommandoprompt". Her kan du køre:

cmd
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
eller importere .reg-filen via:

cmd
reg import <filnavn>.reg
12.5 Sidste udvej – ny installation
Hvis ingen af ovenstående virker (yderst sjældent), kan en "Nulstil denne pc" fra Indstillinger → System → Gendannelse genskabe Windows. Vælg "Behold mine filer" for at undgå datatab.

13. Sådan undgår du problemer fremover
Tag altid en backup, før du aktiverer mange tweaks på én gang.

Aktivér tweaks gradvist, så du kan identificere årsagen, hvis noget går galt (i stedet for at slå alle 46 til på én gang).

Læs beskrivelserne i infopanelet – de advarer om kendte risici.

Brug "Anvend alle" med forsigtighed – den aktiverer alle tweaks, inklusive sikkerhedshærdning, der ændrer login-adfærd.

Hold styr på, hvad du aktiverer – noter eventuelt, hvilke tweaks du slår til, så du senere kan rulle dem tilbage, hvis problemer opstår.

Test på en ikke-produktionsmaskine først, hvis du administrerer flere computere.

14. Teknisk arkitektur
14.1 Overordnet struktur
WinRegistryTweaker.lpr – Programmets indgangspunkt. Initialiserer Application, opretter FormMain og starter event-loopet.

uMain.pas – Hjertet i programmet. Indeholder al forretningslogik, UI-generering, registeradgang, backup, genstart og fejlhåndtering.

uMain.lfm – Lazarus' designfil for hovedvinduet (layout, komponenter, egenskaber).

uHelp.pas – Hjælpeenheden med det udvidede hjælpevindue.

uHelp.lfm – Designfil for hjælpevinduet.

WinRegistryTweaker.res – Ressourcefil med ikon, versionsinformation og UAC-manifest.

14.2 Centrale dele af uMain.pas
Token-baseret kontrol af administratorrettigheder (IsProcessElevated) – undersøger via OpenProcessToken og GetTokenInformation, om processen kører med forhøjede rettigheder.

Dynamisk opbygning af faneblade med parametre (PopulateAllTweaks, BuildUI) – genererer hele brugerfladen ud fra TTweakItem-listen FTweaks. Tilføjer man et nyt tweak til listen, dukker det automatisk op på det korrekte faneblad.

Læsning og skrivning i 64-bit Windows Registry (ReadSingleTweakStatus, SetTweakInRegistry) – anvender altid KEY_WOW64_64KEY, validerer datatyper (rdInteger, rdBinary, rdString, rdExpandString) og håndterer både ægte DWORD-værdier og binært lagrede DWORD.

Processtyring mod System32 med timeout og pipe-tømning (RunCommandCapture, GetSafeSystemPath) – afvikler eksterne værktøjer (powercfg.exe) usynligt med 30-sekunders timeout og fuld opsamling af stdout+stderr.

Eksport af fuld UTF-16LE .reg-sikkerhedskopi med BOM (MenuCreateBackupClick) – genererer en komplet .reg-fil med korrekt UTF-16LE-kodning og BOM ($FEFF), så regedit kan importere den.

Rettighedstildeling (SeShutdownPrivilege) og genstart af pc (RestartComputer) – erhverver SeShutdownPrivilege via OpenProcessToken, LookupPrivilegeValue og AdjustTokenPrivileges, før den kalder ExitWindowsEx med EWX_REBOOT, EWX_FORCEIFHUNG og en planlagt årsagskode.

Åbning af det udvidede hjælpevindue (MenuUserGuideClick) – opretter FormHelp ved første klik og bringer vinduet i forgrunden ved efterfølgende klik.

Event-guarding (FUpdatingUI) – beskytter mod, at programmatiske opdateringer af CheckBox.Checked udløser OnClick og dermed skaber uendelige rekursive kald.

14.3 Datamodel
Hvert tweak repræsenteres af et TTweakItem-objekt med følgende felter:

CategoryIndex – Hvilket faneblad (0–9) tweaket hører til.

Title – Den synlige overskrift ud for afkrydsningsfeltet.

RootKey – HKEY_CURRENT_USER eller HKEY_LOCAL_MACHINE.

SubKey – Mappestien i registreringsdatabasen.

ValueName – Parameterens navn.

ValKind – vkDWord, vkString, vkEmptyKey eller vkHibernate.

OptimizedDWord / OptimizedStr – Den optimerede værdi.

DefaultDWord / DefaultStr – Fabriksstandardværdien.

DeleteKeyPath – Sti der skal slettes rekursivt ved tilbagerulning (vkEmptyKey).

Pros / Cons – Forklarende fordele og ulemper.

CheckBox – Reference til det visuelle afkrydsningsfelt.

14.4 De fire tweak-typer
vkDWord
Eksempel: AllowTelemetry = 0. Skrives som REG_DWORD via Reg.WriteInteger.

vkString
Eksempel: MenuShowDelay = "20". Skrives som REG_SZ via Reg.WriteString.

vkEmptyKey
Eksempel: Win11-kontekstmenu. Nøglens eksistens er tweaket; slettes rekursivt via DeleteKeyTree.

vkHibernate
Eksempel: Dvale. Styres via powercfg.exe -h off/on – ikke via registret.

15. Fejlfinding under bygning
15.1 Kompileringsadvarsler
Programmet undertrykker bevidst følgende advarsler for en ren byggeproces:

WARN 4055 – typekonvertering mellem pointere og ordinals på 64-bit.

WARN 5024 – ubrugte parametre (f.eks. _Shift, _X, _Y i CheckBoxMouseMove).

WARN 5057 – lokale variable, der ikke synes initialiseret.

WARN 6018 – implicit strengtypekonvertering med potentielt datatab.

Disse advarsler er ikke fejl, og de påvirker ikke programmets funktion.

15.2 Platformtjek
uMain.pas indeholder en {$IFNDEF MSWINDOWS}-blok, der stopper kompileringen med en FATAL-fejl, hvis man forsøger at bygge på et ikke-Windows-styresystem. Dette er bevidst: Programmet bruger Windows-specifikke API-kald (OpenProcessToken, ExitWindowsEx, GetSystemDirectory), som ikke findes på Linux eller macOS.

15.3 UAC-manifest
WinRegistryTweaker.res indeholder et UAC-manifest, der beder Windows om administratorrettigheder ved opstart. Hvis manifestet mangler, vil Windows ikke vise UAC-dialogen, og programmet vil starte uden forhøjede rettigheder – hvilket får det til at afvise at køre. Sørg derfor for, at .res-filen er inkluderet i bygningen.

16. Bidrag og licens
16.1 Licens
Dette projekt er udgivet under MIT-licensen. Se LICENSE-filen for detaljer. Du må frit bruge, ændre og distribuere programmet – også kommercielt – så længe ophavsretsmeddelelsen bevares.

16.2 Bidrag
Bidrag er velkomne! Hvis du finder en fejl eller har en idé til en forbedring:

Opret et issue på GitHub med en klar beskrivelse af problemet eller forslaget.

Indsend en pull request med din ændring. Sørg for, at:

Koden følger Free Pascal's stilguide.

Nye tweaks tilføjes til PopulateAllTweaks med præcise fordele/ulemper.

Ændringer i brugerfladen respekterer høj DPI og tastaturnavigation.

Der tages højde for både HKEY_CURRENT_USER og HKEY_LOCAL_MACHINE.

Fejlhåndtering følger programmets eksisterende mønstre (try/except, FUpdatingUI-guard).

16.3 Kontakt
Spørgsmål, ros eller kritik kan rettes til projektets issue-tracker på GitHub.

God fornøjelse med Windows Registry Tweaker Pro – og husk altid at tage en sikkerhedskopi, før du begynder at tweake! 🚀


## 🛠️ Sådan bygger du projektet fra kildekode

### Forudsætninger
* [Lazarus IDE](https://www.lazarus-ide.org/) (version 2.2.6 eller nyere anbefales)
* Free Pascal Compiler (FPC 3.2.2 eller nyere)

### Trin-for-trin
1. Klon dette repository:
   ```bash
   git clone https://github.com/DIT-BRUGERNAVN/WinRegistryTweaker.git
   cd WinRegistryTweaker
