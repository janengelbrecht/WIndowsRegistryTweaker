{ ============================================================================
  ENHED (UNIT): uMain.pas
  ============================================================================
  
  FORMÅL OG OVERORDNET BESKRIVELSE
  ----------------------------------------------------------------------------
  uMain.pas er hjertet i Windows Registry Tweaker Pro – et professionelt
  administrationsværktøj til Windows 10 og 11, der giver både private brugere
  og IT-administratorer mulighed for at optimere, hærde og strømline Windows
  gennem en sikker og overskuelig brugerflade.

  Programmet samler 46 gennemprøvede systemindstillinger – fordelt på 10
  tematiske kategorier – i ét værktøj, så brugeren slipper for manuelt at
  navigere rundt i regedit, gpedit.msc, powercfg og andre spredte
  systemværktøjer. Hver enkelt indstilling er dokumenteret med sine fordele
  og ulemper, så brugeren kan træffe informerede valg frem for at følge
  blinde "optimeringstips" fra internettet.

  Programmet er bevidst designet efter følgende principper:
    - SIKKERHED FØRST: Alle ændringer kan rulles tilbage, og der kan tages
      fuld .reg-sikkerhedskopi inden ændringer.
    - GENNEMSIGTIGHED: Hver tweak viser præcis, hvad den gør, hvilke fordele
      den giver, og hvilke risici den medfører.
    - ROBUSTHED: Programmet validerer rettigheder, datatyper og proceskald,
      så det ikke crasher eller efterlader systemet i en uheldig tilstand.
    - TILGÆNGELIGHED: Både mus- og tastaturnavigation understøttes, og
      brugerfladen skalerer korrekt ved høj DPI og forskellige skærmstørrelser.


  PROGRAMMETS 10 KATEGORIER (46 TWEAKS)
  ----------------------------------------------------------------------------
  Programmet er organiseret i ti faneblade, der hver især samler beslægtede
  indstillinger. Hver kategori kan aktiveres eller rulles tilbage samlet via
  knapperne i bunden, eller enkeltvis via de individuelle afkrydsningsfelter.

    1. Hurtigere Windows
       Tweaks der reducerer ventetid ved opstart, nedlukning og menuåbning.
       F.eks. MenuShowDelay, AutoEndTasks, WaitToKillAppTimeout og
       SeparateProcess (Stifinder-isolation).

    2. Sikkerhed & Privatliv
       Grundlæggende beskyttelse mod telemetri, uautoriseret USB-adgang,
       AutoRun-malware og fjernadgang til registreringsdatabasen.

    3. System & Ydeevne
       Kerneindstillinger som Prefetcher, Win32PrioritySeparation,
       VBS-deaktivering, DisablePagingExecutive og NTFS-tidsstempler.
       Inkluderer også dvale-tweaket (via powercfg).

    4. Netværk & Gaming
       Netværks- og GPU-prioritering for spillere: GPU Priority, Tasks
       Priority, TcpTimedWaitDelay og QoS-båndbreddereservation.

    5. Sikkerhedshærdning (Del 1)
       Avancerede sikkerhedspolitikker: UAC på Secure Desktop, WSH-blokering,
       CTRL+ALT+DEL ved login, sidefil-tømning, RestrictAnonymous, BitLocker
       256-bit XTS-AES og SMBv1-deaktivering.

    6. Sikkerhedshærdning (Del 2)
       App-specifikke sikkerhedstiltag: Office-makroblokering, RDP-blokering,
       automatisk låsning efter inaktivitet, kamera- og mikrofonblokering
       for UWP-apps.

    7. Privatliv & Telemetri
       Bing-søgning i Start-menuen, reklame-ID, låseskærmsannoncer,
       lokationssporing, feedback-popups, promoverede apps og Windows 11's
       klassiske højrekliksmenu.

    8. Avanceret Kerne & GPU
       CPU Core Parking synlighed, HAGS (hardwareaccelereret GPU-planlægning),
       LargeSystemCache, WER-deaktivering og 8.3-kortnavne.

    9. Hardware & Strømstyring
       PCIe Link State synlighed, harddisk-timeout, DiagTrack-deaktivering.

   10. UI & Systemstrømlining
       Widgets-fjernelse, Stifinder startmappe, Sticky Keys-popup,
       opstartslyd og 3D-objekter-mappen.


  ENHEDENS INDHOLD (Arkitektur og ansvarsområder)
  ----------------------------------------------------------------------------
  uMain.pas indeholder den komplette forretningslogik og er opdelt i
  følgende hoveddele:

    1. TOKEN-BASERET KONTROL AF ADMINISTRATORRETTIGHEDER
       IsProcessElevated undersøger via OpenProcessToken og
       GetTokenInformation, om processen kører med forhøjede rettigheder.
       Uden disse rettigheder kan programmet ikke skrive til HKEY_LOCAL_MACHINE,
       og FormCreate afviser derfor at starte.

    2. DYNAMISK OPBYGNING AF FANEBLADE MED PARAMETRE
       PopulateAllTweaks og BuildUI samarbejder om at generere hele
       brugerfladen ud fra TTweakItem-listen FTweaks. Tilføjer man et nyt
       tweak til listen, dukker det automatisk op på det korrekte faneblad
       uden ændringer i UI-koden.

    3. LÆSNING OG SKRIVNING I 64-BIT WINDOWS REGISTRY UDEN REDIRECTION
       ReadSingleTweakStatus og SetTweakInRegistry anvender altid
       KEY_WOW64_64KEY, så 32-bit og 64-bit visninger ikke blandes sammen.
       Datatyper valideres (rdInteger, rdBinary, rdString, rdExpandString),
       og der håndteres både ægte DWORD-værdier og binært lagrede DWORD.

    4. PROCESSTYRING MOD SYSTEM32 MED TIMEOUT OG PIPE-TØMNING
       RunCommandCapture og GetSafeSystemPath afvikler eksterne værktøjer
       (powercfg.exe) usynligt med 30-sekunders timeout og fuld opsamling
       af stdout+stderr. GetSafeSystemPath sikrer, at kommandoen altid
       hentes fra den ægte System32-mappe og ikke fra en PATH-angrebet mappe.

    5. EKSPORT AF FULD UTF-16LE .REG-SIKKERHEDSKOPI MED BOM
       MenuCreateBackupClick genererer en komplet .reg-fil med korrekt
       UTF-16LE-kodning og BOM ($FEFF), så regedit kan importere den.
       Manglende værdier skrives som '=-', så importen aktivt sletter dem
       og genskaber fabriksstandarden.

    6. RETTIGHEDSTILDELING (SeShutdownPrivilege) OG GENSTART AF PC
       RestartComputer erhverver SeShutdownPrivilege via OpenProcessToken,
       LookupPrivilegeValue og AdjustTokenPrivileges, før den kalder
       ExitWindowsEx med EWX_REBOOT, EWX_FORCEIFHUNG og en planlagt
       årsagskode – så genstarten logges korrekt i Event Viewer.

    7. ÅBNING AF DET UDVIDEDE HJÆLPEVINDUE (uHelp)
       MenuUserGuideClick opretter FormHelp ved første klik og bringer
       vinduet i forgrunden ved efterfølgende klik, så brugeren altid
       har adgang til den detaljerede dokumentation.

    8. EVENT-GUARDING (FUpdatingUI) MOD REKURSIVE LCL ONCLICK-KALD
       FUpdatingUI-flaget beskytter mod, at programmatiske opdateringer
       af CheckBox.Checked udløser OnClick og dermed skaber uendelige
       rekursive kald mellem CheckBoxClick, SetTweakInRegistry og
       ReadSingleTweakStatus.


  HVORDAN PROGRAMMET BRUGES (Kort brugervejledning)
  ----------------------------------------------------------------------------
  TRIN 1 – START PROGRAMMET
    Højreklik på .exe-filen og vælg "Kør som administrator". Programmet
    kræver forhøjede rettigheder og afviser at starte uden.

  TRIN 2 – TAG EN SIKKERHEDSKOPI (ANBEFALET)
    Vælg "Filer → Gem fuld sikkerhedskopi..." og gem .reg-filen et sikkert
    sted. Filen kan gendanne hele tilstanden, hvis noget går galt.

  TRIN 3 – GENNEMGÅ KATEGORIERNE
    Klik gennem fanebladene, læs fordele/ulemper i infopanelet nederst,
    og sæt flueben ved de ønskede optimeringer. Eller brug "Aktivér alle
    på denne fane" for en hel kategori.

  TRIN 4 – ANVEND ÆNDRINGERNE
    Ændringer skrives straks til registreringsdatabasen, når du klikker.
    Mange kræver dog en genstart for fuld effekt.

  TRIN 5 – GENSTART COMPUTEREN
    Vælg "Filer → Genstart Windows nu" (eller genstart manuelt), så
    indstillingerne træder i kraft.


  FEJLSØGNING – HVAD GØR MAN, HVIS NOGET IKKE VIRKER EFTER TWEaking?
  ----------------------------------------------------------------------------
  Selv om programmet er testet grundigt, kan visse tweaks have utilsigtede
  bivirkninger på den enkelte computer på grund af hardwareforskelle,
  driverversioner eller tredjepartssoftware. Her er en systematisk
  fremgangsmåde til at identificere og løse problemet.

  ─────────────────────────────────────────────────────────────────────────
  GENEREL FREMGANGSMÅDE (uanset symptom)
  ─────────────────────────────────────────────────────────────────────────
   1. IDENTIFICÉR DET SENEste TWEAK
      Hvis problemet opstod lige efter, du aktiverede en bestemt tweak
      eller en hel kategori, er det sandsynligvis den, der er årsagen.
      Tænk tilbage: Hvad aktiverede du, lige før problemet opstod?

   2. RUL TILBAGE KATEGORIVIST
      Gå til det relevante faneblad, og klik "Gendan standard på denne
      fane". Dette ruller alle tweaks i den kategori tilbage til Windows'
      fabriksværdier – én handling, ingen manuel registerredigering.

   3. RUL ALT TILBAGE (SIDSTE UDVEJ)
      Hvis du ikke kan identificere årsagen, og problemet er alvorligt,
      kan du rulle alle 46 tweaks tilbage: Gå til hvert faneblad og klik
      "Gendan standard", eller importér den .reg-backup, du tog i trin 2
      ovenfor (dobbeltklik filen i Stifinder).

   4. GENSTART COMPUTEREN
      Mange tweaks ændrer kerneadfærd og kræver genstart for at blive
      fuldt tilbagerullet. Genstart maskinen, før du konkluderer, at
      problemet varer ved.

   5. BRUG EN HVILEPUNKT-GENOPRETNING
      Hvis intet andet virker, kan du bruge Windows' indbyggede
      Systemgendannelse (Windows + R → "rstrui.exe"). Vælg et
      gendannelsespunkt fra før tweakingen.


  ─────────────────────────────────────────────────────────────────────────
  KONKRETE SYMPTOMER OG LØSNINGER
  ─────────────────────────────────────────────────────────────────────────

  ▌ USB-DREV KAN IKKE TILGÅS EFTER TWEAKING
    ÅRSAG: Tweaket "Forhindr uautoriseret USB-lageradgang (USBSTOR)" i
    kategorien "Sikkerhed & Privatliv" sætter USBSTOR-tjenesten til Start=4
    (deaktiveret). Dette blokerer ALLE USB-lagerenheder (USB-stik, eksterne
    diske, kortlæsere) – men påvirker IKKE USB-tastatur og USB-mus.

    LØSNING:
      1. Åbn fanebladet "2. Sikkerhed & Privatliv".
      2. Fjern fluebenet ud for "Forhindr uautoriseret USB-lageradgang".
      3. Genstart computeren (vigtigt! USBSTOR-tjenesten skal genstartes).
      4. USB-drevet er nu tilgængeligt igen.

    HVIS DET STADIG IKKE VIRKER:
      Kontrollér, at USBSTOR-tjenesten faktisk er genaktiveret:
      - Åbn PowerShell som administrator.
      - Kør: Get-Service USBSTOR
      - Status skal vise "Stopped" (hvilket er normalt indtil et drev
        tilsluttes) og StartType skal være "Manual" eller "Automatic".
      - Hvis StartType stadig er "Disabled", kør:
        Set-Service USBSTOR -StartupType Manual
      - Alternativt: Åbn regedit → gå til
        HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\USBSTOR
        og sæt "Start" til 3 (Manual).


  ▌ KAN IKKE LOGGE IND PÅ WINDOWS EFTER TWEAKING
    ÅRSAG: Tweaket "Tving sikker CTRL+ALT+DEL ved login" eller "Fjern
    sidst loggede ind brugernavn på låseskærm" kan ændre login-adfærden.
    I sjældne tilfælde kan en forkert kombination af sikkerhedspolitikker
    blokere normal pålogning.

    LØSNING (fra en anden konto eller via sikker tilstand):
      1. Genstart i Sikker Tilstand (hold Shift nede under genstart,
         eller tryk F8 under opstart).
      2. Log ind med en administratorkonto.
      3. Åbn programmet (kør som administrator).
      4. Gå til fanebladet "5. Sikkerhedshærdning (Del 1)" og rul alle
         tweaks tilbage.
      5. Genstart normalt.

    HVIS INGEN KONTO VIRKER:
      Brug en Windows-installations-USB til at åbne Kommandoprompten
      via "Reparer computeren → Fejlfinding → Kommandoprompt" og
      gendan registreringsdatabasen fra en backup, eller brug
      Systemgendannelse.


  ▌ PROGRAMMET STARTER IKKE (ADGANGSFEJL VED OPPSTART)
    ÅRSAG: Manglende administratorrettigheder, eller UAC er blevet
    ændret af en tweak.

    LØSNING:
      1. Højreklik på .exe-filen og vælg "Kør som administrator".
      2. Hvis dette ikke virker, er UAC måske blevet deaktiveret. Åbn
         Kontrolpanel → Brugerkonti → Skift indstillinger for
         Brugerkonti, og sæt skyderen tilbage til standard (næstøverste
         niveau). Genstart.


  ▌ NETVÆRKET VIRKER IKKE (INGEN INTERNETFORBINDELSE)
    ÅRSAG: Tweaket "TcpTimedWaitDelay" eller "Deaktiver QoS
    båndbredde-reservation" kan i sjældne tilfælde påvirke netværket
    på specifikke hardwarekonfigurationer.

    LØSNING:
      1. Åbn fanebladet "4. Netværk & Gaming".
      2. Klik "Gendan standard på denne fane".
      3. Genstart computeren.
      4. Hvis problemet varer ved, kontrollér netværksdriveren i
         Enhedshåndtering (der kan være behov for en opdatering).


  ▌ SPIL KØRER DÅRLIGERE EFTER TWEAKING
    ÅRSAG: Nogle GPU-tweaks (f.eks. HAGS) kan give micro-stuttering på
    ældre drivere. Ligeledes kan Win32PrioritySeparation påvirke
    baggrundsprocesser, som nogle spil afhænger af.

    LØSNING:
      1. Åbn fanebladet "8. Avanceret Kerne & GPU".
      2. Rul HAGS-tweaket tilbage (fjern fluebenet).
      3. Åbn fanebladet "3. System & Ydeevne".
      4. Rul Win32PrioritySeparation tilbage.
      5. Genstart computeren.


  ▌ WINDOWS BLIVER MEGET LANGSOM VED NEDLUKNING
    ÅRSAG: Tweaket "Tøm sidefilen (Pagefile) ved nedlukning" forlænger
    nedlukningstiden betydeligt på computere med meget RAM, fordi hele
    sidefilen (typisk 4-16 GB) skal overskrives.

    LØSNING:
      1. Åbn fanebladet "5. Sikkerhedshærdning (Del 1)".
      2. Fjern fluebenet ud for "Tøm sidefilen (Pagefile) ved nedlukning".
      3. Genstart computeren.
      Bemærk: Dette tweak er kun relevant, hvis du har behov for at
      beskytte følsomme data mod fysisk udlæsning af disken.


  ▌ DVALEFUNKTIONEN VIRKER IKKE MERE
    ÅRSAG: Tweaket "Slå dvale fra (Sletter hiberfil.sys via powercfg)"
    har deaktiveret dvale og Hurtig Start (Fast Startup).

    LØSNING:
      1. Åbn fanebladet "3. System & Ydeevne".
      2. Fjern fluebenet ud for "Slå dvale fra".
      3. Genstart computeren.
      Hiberfil.sys genskabes automatisk af powercfg ved genstart.


  ─────────────────────────────────────────────────────────────────────────
  NØDHJÆLP – HVIS INTET VIRKER
  ─────────────────────────────────────────────────────────────────────────
   1. START I SIKKER TILSTAND
      Hold Shift nede under genstart, eller tryk F8 under opstart. Dette
      indlæser Windows med minimale drivere, så du kan tilgå programmet
      og rulle tweaks tilbage.

   2. BRUG .REG-BACKUP
      Dobbeltklik på den .reg-fil, du gemte i trin 2 ovenfor. Windows
      importerer den automatisk og genskaber den gemte tilstand. Husk
      at genstarte bagefter.

   3. SYSTEMGENDANNELSE
      Windows + R → "rstrui.exe". Vælg et gendannelsespunkt fra før
      tweakingen. Dette ruller HELE systemet tilbage (ikke kun
      registreringsdatabasen).

   4. WINDOWS REPARATIONSMILJØ
      Hvis Windows ikke kan starte, kan du bruge en
      Windows-installations-USB: "Reparer computeren → Fejlfinding →
      Kommandoprompt". Her kan du køre:
        - sfc /scannow
        - DISM /Online /Cleanup-Image /RestoreHealth
      eller importere .reg-filen via "reg import <filnavn>.reg".

   5. SIDSTE UDVEJ – NY INSTALLATION
      Hvis ingen af ovenstående virker (yderst sjældent), kan en
      "Nulstil denne pc" fra Indstillinger → System → Gendannelse
      genskabe Windows. Vælg "Behold mine filer" for at undgå datatab.


  ─────────────────────────────────────────────────────────────────────────
  HVORDAN UNDGÅR MAN PROBLEMER FREMOVER
  ─────────────────────────────────────────────────────────────────────────
   - TAG ALTID EN BACKUP, før du aktiverer mange tweaks på én gang.
   - AKTIVÉR TWEaks gradvist, så du kan identificere årsagen, hvis
     noget går galt (i stedet for at slå alle 46 til på én gang).
   - LÆS BESKRIVELSERNE i infopanelet – de advarer om kendte risici.
   - BRUG "Anvend alle" MED FORSIGTIGHED – den aktiverer ALLE tweaks,
     inklusive sikkerhedshærdning, der ændrer login-adfærd.
   - HOLD STYR PÅ HVAD DU AKTIVERER – noter eventuelt, hvilke tweaks
     du slår til, så du senere kan rulle dem tilbage, hvis problemer
     opstår.
  ============================================================================ }

unit uMain;

{$mode objfpc}{$H+}

// Deaktiverer specifikke compiler-advarsler for en ren byggeproces:
{$WARN 4055 OFF} // Undertrykker advarsel om typekonvertering mellem pointere og ordinals på 64-bit
{$WARN 5024 OFF} // Parameter not used hints
{$WARN 5057 OFF} // Local variable does not seem to be initialized
{$WARN 6018 OFF} // Implicit string type conversion with potential data loss

// Sikrer at programmet kun kan bygges på Microsoft Windows styresystemet:
{$IFNDEF MSWINDOWS}
  {$FATAL Dette program understøtter udelukkende Microsoft Windows styresystemet.}
{$ENDIF}

interface

uses
  // Classes: Grundlæggende datastrukturer som TFPList, TStringList, TMemoryStream.
  Classes,
  // SysUtils: Tekst- og filhåndtering (Format, SameText, FileExists).
  SysUtils,
  // Forms: Vinduets adfærd og Application objektet.
  Forms,
  // Controls: Grundlæggende visuelle komponenter og deres koordinater.
  Controls,
  // Graphics: Farver og skrifttyper.
  Graphics,
  // Dialogs: Visning af pop-op vinduer og fildialoger (TSaveDialog).
  Dialogs,
  // ComCtrls: Avancerede brugerfladekomponenter som faneblade (TPageControl) og statuslinje (TStatusBar).
  ComCtrls,
  // ExtCtrls: Paneler (TPanel) og opdelere (TSplitter).
  ExtCtrls,
  // StdCtrls: Knapper (TButton), afkrydsningsfelter (TCheckBox) og tekstfelter (TMemo, TLabel).
  StdCtrls,
  // Menus: Menulinjen i toppen af vinduet (TMainMenu, TMenuItem).
  Menus,
  // Registry: Free Pascals officielle værktøj til Windows Registreringsdatabasen (TRegistry).
  Registry,
  // Windows: Direkte adgang til Windows-kernen (Win32/Win64 API kald som OpenProcessToken).
  Windows,
  // Process: Sikker start og styring af eksterne systemprogrammer (TProcess).
  Process,
  // uHelp: Referencer til det nye udvidede hjælpevindue.
  uHelp;

type
  { TValKind: En opregningstype (Enumeration), der angiver, hvilken type data
    vi arbejder med for en given systemindstilling i registreringsdatabasen:
    - vkDWord: Et 32-bit heltal (REG_DWORD, tal fra 0 til 4.294.967.295).
    - vkString: Almindelig tekst (REG_SZ).
    - vkEmptyKey: En speciel nøgle hvor standardværdien efterlades tom (bruges af Win11 kontekstmenuen).
    - vkHibernate: En indstilling der styres direkte af Windows Power Management kernen. }
  TValKind = (vkDWord, vkString, vkEmptyKey, vkHibernate);

  { TTweakItem: En dataklasse, der repræsenterer én specifik systemoptimering.
    Hvert eneste punkt i brugerfladen har sit eget TTweakItem objekt i hukommelsen,
    hvor alle stier, værdier, fordele og ulemper er gemt. }
  TTweakItem = class
  public
    CategoryIndex: Integer;   // Hvilket faneblad hører dette tweak til (0 til 9)?
    Title: String;            // Den overskrift brugeren ser ud for afkrydsningsfeltet
    RootKey: HKEY;            // Er nøglen under HKEY_CURRENT_USER eller HKEY_LOCAL_MACHINE?
    SubKey: String;           // Mappestien indeni registreringsdatabasen (f.eks. 'Control Panel\Desktop')
    ValueName: String;        // Selve parameterens navn (f.eks. 'MenuShowDelay')
    ValKind: TValKind;        // Typen af data (Tal, Tekst, Tom nøgle eller Dvale)
    OptimizedDWord: Cardinal; // Talværdien når optimeringen er slået TIL (32-bit tal uden fortegn)
    DefaultDWord: Cardinal;   // Talværdien som Windows oprindeligt er født med (standardtilstand)
    OptimizedStr: String;     // Tekstværdien når optimeringen er slået TIL
    DefaultStr: String;       // Tekstværdien som Windows oprindeligt er født med
    DeleteKeyPath: String;    // Sti der skal slettes rekursivt for at rulle ændringen tilbage
    Pros: String;             // Beskrivelse af de positive fordele for systemet
    Cons: String;             // Beskrivelse af ulemper eller risici
    CheckBox: TCheckBox;      // Reference til det visuelle afkrydsningsfelt på skærmen

    // Konstruktør til oprettelse af et DWORD-tweak (heltal):
    constructor CreateDWord(ACat: Integer; const ATitle: String; ARoot: HKEY;
      const ASubKey, AValName: String; AOpt, ADef: Cardinal;
      const APros, ACons: String);
      
    // Konstruktør til oprettelse af et tekst-tweak (strenge):
    constructor CreateString(ACat: Integer; const ATitle: String; ARoot: HKEY;
      const ASubKey, AValName: String; const AOpt, ADef: String;
      const APros, ACons: String);
      
    // Konstruktør til oprettelse af tomme nøgler (f.eks. til Windows 11 højrekliksmenu):
    constructor CreateEmptyKey(ACat: Integer; const ATitle: String; ARoot: HKEY;
      const ASubKey, ADeleteKeyPath: String;
      const APros, ACons: String);

    // Konstruktør til Windows Dvale (styres via systemkommandoer):
    constructor CreateHibernate(ACat: Integer; const ATitle, APros, ACons: String);
  end;

  { TFormMain: Hovedformularens klasse. Styrer hele brugergrænsefladen. }
  TFormMain = class(TForm)
    MainMenu1: TMainMenu;               // Menulinjen øverst
    MenuFile: TMenuItem;                // Menuen "Filer"
    MenuApplyAll: TMenuItem;            // "Anvend alle anbefalede tweaks..."
    MenuCreateBackup: TMenuItem;         // "Gem fuld sikkerhedskopi..."
    MenuSep1: TMenuItem;                // En visuel skillelinje i menuen
    MenuRestartWindows: TMenuItem;      // "Genstart Windows nu"
    MenuExit: TMenuItem;                // "Afslut"
    MenuHelp: TMenuItem;                // Menuen "Hjælp"
    MenuUserGuide: TMenuItem;           // "Brugervejledning & Dokumentation..."
    MenuSep2: TMenuItem;                // En visuel skillelinje i Hjælp-menuen
    MenuAbout: TMenuItem;               // "Om programmet"
    PageControl1: TPageControl;         // Komponent der indeholder de 10 faneblade
    PanelHeader: TPanel;                // Det mørkeblå panel i toppen
    LblTitle: TLabel;                   // Programmets store overskrift
    LblSubTitle: TLabel;                // Den mindre forklaring under overskriften
    Splitter1: TSplitter;               // En bjælke brugeren kan trække i med musen for at ændre højde
    GroupInfo: TGroupBox;               // Rammen i bunden med detaljer
    LblInfoName: TLabel;                // Navnet på det tweak cursoren befinder sig over
    LblProsTitle: TLabel;               // Grøn overskrift "Fordele"
    LblConsTitle: TLabel;               // Rød/orange overskrift "Ulemper"
    MemoPros: TMemo;                    // Tekstboks med fordele
    MemoCons: TMemo;                    // Tekstboks med ulemper
    BtnApplyCurrentTab: TButton;        // Knappen "Aktivér alle på denne fane"
    BtnRestoreCurrentTab: TButton;      // Knappen "Gendan standard på denne fane"
    StatusBar1: TStatusBar;             // Statusbjælken helt i bunden der viser handlinger

    // Hændelser (Events) der udløses af brugerens handlinger:
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuApplyAllClick(Sender: TObject);
    procedure MenuCreateBackupClick(Sender: TObject);
    procedure MenuRestartWindowsClick(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
    procedure MenuUserGuideClick(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure BtnApplyCurrentTabClick(Sender: TObject);
    procedure BtnRestoreCurrentTabClick(Sender: TObject);
    procedure CheckBoxMouseMove(Sender: TObject; _Shift: TShiftState; _X, _Y: Integer);
    procedure CheckBoxEnter(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
  private
    FTweaks: TFPList;                   // En hurtig liste i RAM der gemmer alle TTweakItem objekterne
    FLastHoverItem: TTweakItem;         // Husker hvilket tweak vi sidst viste for at undgå skærmflimren
    FUpdatingUI: Boolean;               // Event-guard: Forhindrer LCL i at udløse rekursive OnClick-kald

    procedure PopulateAllTweaks;        // Opretter samtlige 46 tweaks i listen med forklaringer
    procedure BuildUI;                  // Bygger automatisk de 10 faner og indsætter checkboxes
    procedure ReadRegistryStatus;       // Gennemgår Windows registeret og opdaterer alle flueben
    procedure ReadSingleTweakStatus(Item: TTweakItem); // Undersøger et enkelt tweak i registeret
    procedure SetTweakInRegistry(Item: TTweakItem; EnableOptimized: Boolean); // Skriver ændringen til Windows
    procedure RestartComputer;          // Beder Windows om tilladelse og genstarter maskinen
    procedure ShowTweakInfo(Item: TTweakItem); // Skriver fordele/ulemper i infopanelet
    function IsProcessElevated: Boolean;// Undersøger om vi kører som ægte Administrator
    function GetSafeSystemPath(const ExeName: String): String; // Sikrer fuld sti mod PATH-angreb
  public
  end;

var
  FormMain: TFormMain; // Den globale variabel der peger på vores aktive vindue.

implementation

// {$R *.lfm} forbinder Pascal kildekoden med formularens designfil:
{$R *.lfm}

const
  // Windows interne fejlkoder/årsagskoder ved planlagt systemgenstart:
  SHTDN_REASON_MAJOR_OPERATINGSYSTEM = $00020000;
  SHTDN_REASON_FLAG_PLANNED          = $40000000;

  // Navnene på de 10 faneblade i brugerfladen:
  CAT_NAMES: array[0..9] of String = (
    '1. Hurtigere Windows',
    '2. Sikkerhed & Privatliv',
    '3. System & Ydeevne',
    '4. Netværk & Gaming',
    '5. Sikkerhedshærdning (Del 1)',
    '6. Sikkerhedshærdning (Del 2)',
    '7. Privatliv & Telemetri',
    '8. Avanceret Kerne & GPU',
    '9. Hardware & Strømstyring',
    '10. UI & Systemstrømlining'
  );

{ ----------------------------------------------------------------------------
  GetSafeSystemPath
  Findes systemprogrammer (f.eks. powercfg.exe) altid i C:\Windows\System32?
  Ja, men hvis man blot skriver 'powercfg.exe', gennemsøger Windows den såkaldte
  PATH-variabel. Ondsindet software kan placere en falsk powercfg.exe i en anden
  mappe. Denne funktion finder altid den ægte System32-mappe via Windows API.
  ---------------------------------------------------------------------------- }
function TFormMain.GetSafeSystemPath(const ExeName: String): String;
var
  SysDir: array[0..MAX_PATH] of Char;
begin
  FillChar(SysDir, SizeOf(SysDir), 0);
  if GetSystemDirectory(SysDir, MAX_PATH) > 0 then
    Result := IncludeTrailingPathDelimiter(SysDir) + ExeName
  else
    Result := ExeName; // Sikker fallback hvis API-kaldet fejler
end;

{ ----------------------------------------------------------------------------
  RootKeyToStr
  Formål:
    At konvertere en numerisk rod-nøgle (HKEY) til dens officielle tekstnavn,
    så den kan skrives korrekt i en tekstbaseret .reg-fil.

  Baggrund:
    Windows' registreringsdatabase (Registry) er organiseret i et hierarki af
    nøgler. I Windows-kernen (Win32/Win64 API) er rod-nøglerne repræsenteret
    som håndtag (handles), der internt er talværdier. For eksempel er
    HKEY_CURRENT_USER blot en konstant, der peger på en bestemt numerisk værdi.
    Når programmet eksporterer en .reg-fil, kræver Windows' egen import-mekanisme
    imidlertid, at rod-nøglen skrives som et læsbart tekstnavn (f.eks.
    "HKEY_CURRENT_USER"), ikke som et tal.

  Hvordan funktionen virker:
    Funktionen modtager en HKEY-værdi (Root) som parameter. Den undersøger
    værdien i en case-sætning og returnerer den tilsvarende tekststreng.
    Der er tale om en ren opslagsfunktion uden bivirkninger.

  Parametre:
    Root : HKEY
      Den numeriske rod-nøgle, der skal oversættes. Typisk en af de fem
      officielle Windows-rod-nøgler.

  Returværdi:
    Result : String
      Det officielle tekstnavn på rod-nøglen, klar til brug i en .reg-fil.

  Fejlhåndtering:
    - Hvis Root er 0 (HKEY_UNKNOWN), returneres 'HKEY_UNKNOWN' i stedet for
      at kaste en undtagelse. Dette er en defensiv sikkerhedsforanstaltning:
      Hvis et TTweakItem-objekt ved en fejl er blevet oprettet uden en gyldig
      RootKey (f.eks. hvis en konstruktør er blevet kaldt forkert), vil
      funktionen stadig returnere en brugbar streng frem for at crashe
      hele eksportprocessen.
    - For alle andre ukendte værdier kastes en Exception med den hexadecimale
      værdi, så fejlen kan spores præcist under udvikling. Dette bør aldrig
      ske i produktion, da kun de fem officielle HKEY-konstanter anvendes.

  Anvendelse i programmet:
    Funktionen kaldes udelukkende fra MenuCreateBackupClick, hvor den bruges
    til at opbygge de fulde nøglestier i sikkerhedskopifilen, f.eks.:
      [HKEY_CURRENT_USER\Control Panel\Desktop]
    Uden denne oversættelse ville Windows ikke kunne fortolke filen korrekt
    ved import.
  ---------------------------------------------------------------------------- }
function RootKeyToStr(Root: HKEY): String;
begin
  // Undersøg hvilken rod-nøgle der er tale om, og returner det tilsvarende
  // officielle tekstnavn, som Windows' .reg-format kræver.
  case Root of
    // Brugerens egen konfiguration (HKCU). Indeholder personlige indstillinger
    // som skrivebordslayout, museadfærd og programindstillinger for den
    // aktuelt indloggede bruger.
    HKEY_CURRENT_USER:   Result := 'HKEY_CURRENT_USER';

    // Maskinens globale konfiguration (HKLM). Indeholder systembrede
    // indstillinger som tjenester, drivere og politikker, der gælder for
    // alle brugere på computeren. Kræver Administratorrettigheder at ændre.
    HKEY_LOCAL_MACHINE:  Result := 'HKEY_LOCAL_MACHINE';

    // Sammenfletningen af filassociationer og COM-objekter (HKCR).
    // Windows opbygger denne visning dynamisk ud fra HKLM\Software\Classes
    // og HKCU\Software\Classes.
    HKEY_CLASSES_ROOT:   Result := 'HKEY_CLASSES_ROOT';

    // Alle indlæste brugerprofiler på maskinen (HKU). Hver indlogget bruger
    // får tildelt en SID-baseret undernøgle her.
    HKEY_USERS:          Result := 'HKEY_USERS';

    // Den aktuelle hardwareprofil (HKCC). En flygtig visning, der kun
    // eksisterer, så længe systemet kører, og som afspejler den nuværende
    // hardwarekonfiguration.
    HKEY_CURRENT_CONFIG: Result := 'HKEY_CURRENT_CONFIG';

    // Defensiv fallback: Hvis RootKey af en eller anden grund er 0 (hvilket
    // kan ske, hvis et TTweakItem-objekt er blevet oprettet uden en gyldig
    // rod-nøgle), returneres en neutral pladsholder frem for at kaste en
    // undtagelse. Dette forhindrer, at en enkelt fejlbehæftet post ødelægger
    // hele sikkerhedskopieksporten.
    0:                   Result := 'HKEY_UNKNOWN';

  // For alle andre værdier (som aldrig bør forekomme i praksis) kastes en
  // undtagelse med den hexadecimale værdi, så fejlen kan diagnosticeres.
  // Dette sikrer, at ukendte rod-nøgler ikke stiltiende ignoreres.
  else
    raise Exception.CreateFmt('Ukendt RootKey værdi: $%x', [Root]);
  end;
end;

{ ----------------------------------------------------------------------------
  EscapeRegString
  Formål:
    At gøre en vilkårlig tekststreng sikker at skrive ind i en Windows .reg-fil
    ved at tilføje de nødvendige beskyttelsestegn (escape-tegn) foran tegn, der
    ellers ville blive fortolket som kontroltegn eller syntaks af Windows'
    .reg-parser.

  Baggrund – hvorfor er dette nødvendigt?
    En .reg-fil er ikke blot rå tekst; den følger en streng syntaks, som
    Windows' egen registreringsimportør (regedit.exe) fortolker. Visse tegn
    har en særlig, reserveret betydning i dette format:

      - En omvendt skråstreg '\' bruges til at adskille undermapper i en
        nøglesti. Hvis en VÆRDI (f.eks. en filsti) indeholder en '\', og den
        ikke beskyttes, vil regedit tro, at der er tale om en ny undernøgle,
        og importen vil fejle eller skrive til det forkerte sted.

      - Et anførselstegn '"' markerer start og slut på en værdi i .reg-formatet.
        Hvis værdien selv indeholder et ", vil parsningen blive afbrudt for
        tidligt, og resten af linjen vil blive mistolket.

      - Kontroltegn som linjeskift (CR/LF), nultegn og tabulator kan ikke
        skrives direkte i en tekstlinje, fordi de ville bryde linjestrukturen
        eller skabe usynlige, korrupte data. Windows kræver derfor, at de
        repræsenteres som escape-sekvenser.

  Eksempel:
    En filsti som    C:\Programmer\App
    skal i .reg-filen skrives som
                     C:\\Programmer\\App
    Ellers ville regedit fortolke '\Programmer' og '\App' som undermapper.
    Tilsvarende skal en tekst med anførselstegn, f.eks.  Sig "hej" til mig
    skrives som  Sig \"hej\" til mig.

  Hvordan funktionen virker:
    Funktionen gennemløber tekststrengen tegn for tegn (1-indekseret, som i
    Free Pascal) og opbygger en ny resultatstreng. For hvert tegn undersøges
    det i en case-sætning:
      - Hvis tegnet er et reserveret specialtegn, tilføjes dets escape-sekvens
        (en omvendt skråstreg efterfulgt af et bogstav eller selve tegnet).
      - Ellers kopieres tegnet uændret til resultatet.
    Resultatet er en streng, der er 100 % sikker at indsætte mellem
    anførselstegn i en .reg-fil.

  Parametre:
    S : String
      Den rå tekststreng, der skal escapes. Kan være tom. Funktionen tåler
      alle tegn, herunder Unicode-tegn (som blot kopieres uændret, da
      .reg-filer gemmes som UTF-16LE).

  Returværdi:
    Result : String
      En ny streng, hvor alle specialtegn er erstattet af deres respektive
      escape-sekvenser. Strengen har samme længde som inputtet, hvis intet
      specialtegn findes, og er ellers længere.

  Ydeevne:
    Funktionen er O(n), hvor n er strengens længde. Den bruger simpel
    strengsammenkædning ('+'), hvilket er tilstrækkeligt effektivt for de
    korte værdinavne og -data, der optræder i registreringsdatabasen.
    For meget lange strenge kunne man overveje en TStringBuilder, men det
    er ikke nødvendigt her.

  Anvendelse i programmet:
    Funktionen kaldes fra MenuCreateBackupClick, hvor den anvendes på BÅDE
    værdinavnet og værdidata, inden de skrives til .reg-filen, f.eks.:
      RegFile.Add(Format('"%s"="%s"',
        [EscapeRegString(Item.ValueName),
         EscapeRegString(Reg.ReadString(Item.ValueName))]));
    Uden denne funktion ville en værdi som 'C:\Windows\System32' blive
    korrupt, når filen senere importeres.

  Vigtig bemærkning:
    Denne funktion dækker de tegn, der er relevante for .reg-filens
    værdidata. Stinavne i selve nøglestien (mellem [ ]) escapes ikke her,
    fordi de ikke må indeholde de pågældende tegn i praksis – men det er
    en kendt begrænsning, hvis man skulle understøtte eksotiske nøglenavne.
  ---------------------------------------------------------------------------- }
function EscapeRegString(const S: String): String;
var
  i: Integer;  // Løbeindeks for gennemløb af inputstrengen (1-baseret i Pascal)
begin
  // Start med en tom resultatstreng og opbyg den gradvist tegn for tegn.
  Result := '';

  // Gennemløb hele inputstrengen fra første til sidste tegn.
  for i := 1 to Length(S) do
  begin
    // Undersøg, om det aktuelle tegn er et specialtegn, der skal escapes.
    case S[i] of
      // En enkelt omvendt skråstreg '\' skal fordobles til '\\', ellers
      // ville regedit fortolke den som en mappeadskiller i nøglestien
      // og dermed ødelægge importen af f.eks. filstier.
      '\': Result := Result + '\\';

      // Et anførselstegn '"' skal beskyttes med en foranstillet skråstreg,
      // så det ikke afslutter værdien for tidligt i .reg-syntaksen.
      '"': Result := Result + '\"';

      // Et Carriage Return-tegn (#13, ASCII 13) kan ikke stå direkte i en
      // tekstlinje. Det repræsenteres som '\r' (ruby/regedit-standard).
      #13: Result := Result + '\r';

      // Et Line Feed-tegn (#10, ASCII 10) repræsenteres tilsvarende som '\n'.
      // Sammen med '\r' giver det mulighed for at gemme flerlinjede strenge.
      #10: Result := Result + '\n';

      // Et nultegn (#0, ASCII 0) markerer normalt strengens afslutning i
      // C-baserede systemer. I .reg-formatet skrives det som '\0' for at
      // bevare det som en del af værdidata uden at afbryde parsningen.
      #0:  Result := Result + '\0';

      // En tabulator (#9, ASCII 9) er usynlig og kan forstyrre formateringen.
      // Den skrives som '\t' for at bevare den semantiske betydning.
      #9:  Result := Result + '\t';

    // For alle andre tegn (bogstaver, tal, tegnsætning, Unicode-tegn osv.)
    // kopieres tegnet uændret til resultatet. Dette dækker langt de fleste
    // tilfælde og sikrer, at almindelig tekst ikke ændres unødigt.
    else
      Result := Result + S[i];
    end;
  end;
end;

{ ----------------------------------------------------------------------------
  DeleteKeyTree
  Formål:
    At slette en registreringsnøgle (mappe) i Windows-registreringsdatabasen
    rekursivt – dvs. inklusive alle dens undermapper og deres undermapper i
    vilkårlig dybde – på en sikker og fejltolerant måde.

  Baggrund – hvorfor er dette nødvendigt?
    Windows' registreringsdatabase er opbygget som et hierarkisk træ af nøgler,
    der hver kan indeholde værdier (values) og undermapper (subkeys). Et
    grundlæggende slettekald som f.eks. TRegistry.DeleteKey kan KUN slette en
    nøgle, hvis den allerede er tom – dvs. ikke indeholder nogen undermapper.
    Hvis man forsøger at slette en nøgle med undermapper, returnerer Windows
    en fejl, og intet slettes.

    Derfor er der behov for en funktion, der selvstændigt gennemløber hele
    træet nedefra og op (post-order-traversering): Først sletter den alle
    undermapper i den dybeste gren, derefter deres forældre, og til sidst
    selve den øverste nøgle. Først når en nøgle er blevet tømt for alle børn,
    kan Windows acceptere, at den slettes.

    Et konkret eksempel fra programmet:
      Nøglen 'Software\Classes\CLSID\{86ca1aa0-...}' indeholder ofte flere
      undernøgler. For at fjerne Windows 11-kontekstmenuen og genoprette den
      klassiske Windows 10-menu skal hele denne træstruktur fjernes, og et
      enkelt DeleteKey-kald er ikke tilstrækkeligt.

  Hvordan funktionen virker (algoritmen):
    1. Først undersøges det, om nøglen overhovedet eksisterer. Hvis ikke,
       returneres 'True' med det samme – opgaven er allerede løst, og der
       skal ikke kastes nogen fejl. Dette gør funktionen idempotent: den kan
       kaldes vilkårligt mange gange på en allerede slettet nøgle uden skade.
    2. Hvis nøglen findes, åbnes den (uden at oprette den, hvis den mangler).
    3. Alle dens direkte undermapppenavne hentes ind i en TStringList.
    4. For hver undermappe kalder funktionen SIG SELV (rekursion) med den
       fulde sti til undermappen. Dermed sletter den først alt, hvad der
       ligger under undermappen, før den selv slettes.
    5. Når alle børn er slettede, er nøglen tom, og selve nøglen kan nu
       slettes med et almindeligt DeleteKey-kald.
    6. Resultatet af sletningen returneres som funktionens returværdi.

  Rekursion – hvorfor er det nødvendigt?
    Registreringsdatabasen kan have vilkårlig dybde, og en iterativ løsning
    ville kræve en eksplicit stak (stack) for at holde styr på stierne.
    Rekursion giver en elegant og letlæselig løsning, hvor Pascal's egen
    call-stack bruges til at gemme mellemresultaterne. For de dybder, der
    optræder i praksis (sjældent mere end 5-10 niveauer), er dette fuldt
    forsvarligt.

  Parametre:
    AReg : TRegistry
      Et allerede oprettet TRegistry-objekt, som funktionen kan bruge til at
      åbne, læse og slette nøgler. Objektet skal være konfigureret med
      skriveadgang (KEY_WRITE), og RootKey skal allerede være sat af kalderen.
      Objektet ejes af kalderen og frigives IKKE af denne funktion.

    APath : String
      Den fulde sti (relativt til AReg.RootKey) til den nøgle, der skal
      slettes. Eksempel:
        'Software\Classes\CLSID\{86ca1aa0-...}\InprocServer32'
      Stien må ikke starte eller slutte med en backslash.

  Returværdi:
    Result : Boolean
      - True  : Nøglen (og hele dens undertræ) er nu væk. Dette gælder også,
                hvis nøglen slet ikke fandtes i forvejen (idempotens).
      - False : Sletningen kunne ikke gennemføres – typisk fordi der mangler
                skriverettigheder, eller fordi nøglen er beskyttet af
                systemet (f.eks. visse systemkritiske nøgler).

  Fejlhåndtering:
    - Hvis OpenKey fejler (f.eks. pga. manglende rettigheder), returneres
      'True' forsigtigt. Dette er et bevidst designvalg: Hvis vi ikke kan
      åbne nøglen, antager vi, at den ikke er tilgængelig for sletning, og
      at det ikke er en fejl, der skal kaste en undtagelse. Alternativet
      (at returnere False eller kaste en exception) ville få hele
      tilbagerulningsprocessen til at stoppe på en ikke-kritisk fejl.
    - Undtagelser fra selve registrerings-API'et (f.eks. ERegistryException)
      fanges ikke her, men overlades til kalderen (SetTweakInRegistry), som
      håndterer dem og viser en fejlmeddelelse til brugeren.

  Hukommelsesstyring:
    TStringList oprettes og frigives inde i funktionen via try/finally, så
    der ikke opstår hukommelseslækager, selv hvis der kastes en undtagelse
    undervejs. Hver rekursivt kaldt instans af funktionen har sin egen
    TStringList, så der er ingen deling af tilstand mellem kaldene.

  Anvendelse i programmet:
    Funktionen kaldes udelukkende fra SetTweakInRegistry, når et tweak af
    typen vkEmptyKey skal rulles tilbage. Et typisk kald ser således ud:
      DeleteKeyTree(Reg, 'Software\Classes\CLSID\{86ca1aa0-...}\InprocServer32')
    Hvis funktionen returnerer False, kastes en undtagelse, som vises for
    brugeren i CheckBoxClick's fejlhåndtering.

  Kendt begrænsning:
    Funktionen kan ikke slette nøgler, som Windows aktivt beskytter (f.eks.
    visse nøgler under HKLM\SYSTEM\CurrentControlSet\Services, der ejes af
    en kørende driver). I så fald returnerer DeleteKey False, og kalderen
    bør informere brugeren om, at en genstart eller manuel indgriben er
    nødvendig.
  ---------------------------------------------------------------------------- }
function DeleteKeyTree(AReg: TRegistry; const APath: String): Boolean;
var
  SubKeys: TStringList;  // Midlertidig liste til at gemme navnene på alle undermapper
  i: Integer;            // Løbeindeks i undermappelisten
begin
  // Idempotens-tjek: Hvis nøglen slet ikke eksisterer, er der intet at gøre.
  // Vi returnerer True med det samme, så funktionen kan kaldes gentagne gange
  // på en allerede slettet nøgle uden at forårsage fejl. Dette er vigtigt,
  // fordi tilbagerulningsprocessen i SetTweakInRegistry kan køres flere gange.
  if not AReg.KeyExists(APath) then Exit(True);

  // Opret en midlertidig liste til at rumme navnene på alle direkte
  // undermapper. Den oprettes uden for try-blokken, så vi kan frigive den
  // i finally uanset hvad der sker undervejs.
  SubKeys := TStringList.Create;
  try
    // Åbn nøglen med læseadgang. Parameteren 'False' betyder, at nøglen
    // IKKE må oprettes, hvis den mangler – vi vil kun arbejde med eksisterende
    // nøgler, og hvis den er forsvundet siden KeyExists-tjekket, er der
    // ingen grund til at genskabe den blot for at slette den igen.
    if AReg.OpenKey(APath, False) then
    begin
      try
        // Hent navnene på alle direkte undermapper ind i listen. Denne liste
        // indeholder kun navne (ikke fulde stier), f.eks. 'InprocServer32'
        // eller 'PropertyBag'. Hver undermappe skal behandles rekursivt.
        AReg.GetKeyNames(SubKeys);
      finally
        // Luk nøglen igen, så Windows frigiver sit håndtag til den, og
        // vi undgår at holde unødvendige ressourcer låst under rekursionen.
        // Dette er vigtigt, fordi vi snart skal åbne undermapper og til
        // sidst slette denne nøgle – og Windows tillader ikke sletning af
        // en nøgle, der stadig er åben i et andet håndtag.
        AReg.CloseKey;
      end;

      // Gennemløb alle undermapper og slet dem rekursivt. For hver undermappe
      // bygger vi dens fulde sti op ved at sammensætte forældrenes sti med
      // en backslash og undermappens navn. Rekursionen sørger for, at
      // undermappens egne børn bliver slettet, FØR undermappen selv slettes.
      // Rækkefølgen er afgørende: post-order (børn før forældre).
      for i := 0 to SubKeys.Count - 1 do
        DeleteKeyTree(AReg, APath + '\' + SubKeys[i]);

      // Når alle undermapper er slettede, er denne nøgle nu tom, og Windows
      // accepterer endelig et almindeligt DeleteKey-kald. Hvis det lykkes,
      // returneres True; hvis ikke (f.eks. pga. manglende rettigheder),
      // returneres False, og kalderen kan reagere på det.
      Result := AReg.DeleteKey(APath);
    end
    else
      // Hvis nøglen ikke kunne åbnes (f.eks. fordi den er beskyttet af
      // systemet, eller fordi der mangler læserettigheder), antager vi
      // forsigtigt, at der ikke er noget at slette, og returnerer True.
      // Dette forhindrer, at en ikke-kritisk fejl stopper hele
      // tilbagerulningsprocessen for de øvrige tweaks.
      Result := True;
  finally
    // Frigør altid listen, uanset om der blev kastet en undtagelse undervejs.
    // Dette forhindrer hukommelseslækager og sikrer, at ressourcerne
    // frigives korrekt, selv i fejlsituationer.
    SubKeys.Free;
  end;
end;

{ ----------------------------------------------------------------------------
  RunCommandCapture
  Formål:
    At afvikle et eksternt konsolprogram (f.eks. powercfg.exe, ipconfig.exe
    eller sc.exe) helt usynligt i baggrunden, opsamle ALT hvad programmet
    skriver til både standard-output og standard-error, og returnere det som
    en tekststreng sammen med programmets exit-kode.

  Baggrund – hvorfor er dette nødvendigt?
    Programmet skal kunne justere visse Windows-indstillinger, som ikke kan
    ændres direkte via registreringsdatabasen, men kun via Windows' egne
    kommandolinjeværktøjer. Det gælder f.eks. dvale (powercfg -h off), som
    styres af strømstyringskernen og ikke af en simpel registerværdi.

    Et naivt kald til et konsolprogram via ShellExecute eller CreateProcess
    ville vise et sort DOS-vindue, som blinker op på brugerens skærm – det er
    uacceptabelt i en GUI-applikation. Derfor skal processen startes med
    poNoConsole, så vinduet aldrig vises.

    Samtidig skal vi kunne LÆSE, hvad programmet svarer (f.eks. for at afgøre,
    om dvale er aktivt, eller for at vise en fejlbesked til brugeren). Derfor
    oprettes rørledninger (pipes) via poUsePipes, som vi kan læse fra.

    Endelig skal funktionen være robust: Hvis det eksterne program går i stå
    eller hænger (f.eks. fordi det venter på brugerinput), må det ikke fryse
    hele vores applikation. Derfor er der indbygget en timeout på 30 sekunder,
    hvorefter processen tvinges ned.

  Hvordan funktionen virker (algoritmen):
    1. Der oprettes et TProcess-objekt og en TMemoryStream til at opsamle
       de rå bytes, som programmet skriver.
    2. TProcess konfigureres med Executable og alle argumenter.
    3. Processen startes med fire nøgleindstillinger (se nedenfor).
    4. En løkke læser kontinuerligt data fra processens output-rør, indtil
       processen er færdig OG røret er tømt. Data akkumuleres i MemStream.
    5. Undervejs tjekkes tiden: Hvis processen har kørt i mere end 30 sekunder,
       tvinges den ned via Terminate.
    6. Når processen er færdig, konverteres de rå bytes til en tekststreng.
       Der forsøges først UTF-8, og ved fejl falder vi tilbage til ANSI.
    7. Exit-koden returneres, så kalderen kan afgøre, om kommandoen lykkedes
       (0 = succes i Windows-konventionen).

  Parametre:
    Cmd : String
      Den fulde sti til det eksekverbare program, f.eks.
      'C:\Windows\System32\powercfg.exe'. Det anbefales altid at bruge
      GetSafeSystemPath til at finde stien, så man undgår PATH-angreb,
      hvor ondsindet software placerer en falsk .exe i en anden mappe.

    Params : array of String
      En åben parameterliste med de argumenter, der skal sendes til programmet,
      f.eks. ['-h', 'off'] for at slå dvale fra. Hvert argument tilføjes som
      et separat element i TProcess.Parameters, så programmer med mellemrum i
      argumenterne håndteres korrekt uden manuel citering.

    Output : String (out-parameter)
      Efter kaldet indeholder denne parameter ALT, hvad programmet skrev til
      både stdout og stderr, konverteret til en UTF-8-streng klar til brug i
      brugerfladen. Ved timeout eller tomt output er strengen tom.

  Returværdi:
    Result : Integer
      Programmets exit-kode. I Windows-konventionen betyder 0 normalt succes,
      mens ikke-nul angiver en fejl. Hvis processen ikke kunne startes
      overhovedet, eller hvis der opstod en intern fejl, returneres -1.

  Nøgleindstillinger forklaret:
    poNoConsole       : Vis intet sort DOS-vindue under afviklingen.
    poUsePipes        : Opret rørledninger, så vi kan læse programmets output.
    poStderrToOutPut  : Flet fejlbeskeder (stderr) ind i det normale output,
                        så vi fanger ALT i én strøm og ikke skal læse to steder.
    poNewProcessGroup : Isoler processen i sin egen procesgruppe, så den ikke
                        trækker vores applikation med ned ved en fejl, og så
                        vi kan terminere hele gruppen på én gang.

  Timeout-mekanisme:
    MAX_WAIT_MS = 30000 (30 sekunder) er en sikkerhedsgrænse. Hvis et program
    hænger (f.eks. fordi det venter på input fra en ikke-eksisterende konsol),
    tvinges det ned med Terminate(1), og vi venter op til 5 sekunder på, at
    Windows frigiver processen. Derefter brydes løkken, og vi returnerer den
    exit-kode, som Terminate forårsagede.

  Hvorfor Sleep(15) i løkken?
    Hvis processen kører, men endnu ikke har skrevet noget, ville en tæt løkke
    uden pause spise 100 % CPU uden at gøre nytte. Sleep(15) giver processoren
    en kort pause, samtidig med at reaktionsevnen forbliver høj (maksimalt
    15 ms forsinkelse på nye data). 15 ms er valgt som et kompromis mellem
    CPU-forbrug og lydhørhed.

  Tegnkodningshåndtering:
    Windows-konsolprogrammer kan skrive deres output i forskellige kodninger
    afhængigt af systemindstillinger og programmets alder. Moderne værktøjer
    (f.eks. powercfg) skriver normalt UTF-8, men ældre værktøjer kan bruge
    den lokale ANSI-kodning (Windows-1252). Funktionen forsøger derfor først
    UTF-8 og falder ved fejl tilbage til ANSI. Dette dækker langt de fleste
    tilfælde, men kan i sjældne tilfælde give forvirrede tegn, hvis et program
    bruger en tredje kodning (f.eks. UTF-16).

  Hukommelsesstyring:
    Både TProcess og TMemoryStream oprettes i starten af funktionen og frigives
    altid i finally-blokken, uanset om der kastes en undtagelse undervejs.
    Dette sikrer, at der ikke opstår hukommelseslækager, og at Windows frigiver
    proceshåndtaget korrekt.

  Anvendelse i programmet:
    Funktionen kaldes fra to steder:
      - ReadSingleTweakStatus : For at aflæse, om dvale er slået til/fra.
      - SetTweakInRegistry    : For at slå dvale til/fra via powercfg.exe.
    I begge tilfælde bruges GetSafeSystemPath til at finde den ægte
    powercfg.exe i C:\Windows\System32, så et PATH-angreb forhindres.

  Kendt begrænsning:
    Funktionen er synkron – den blokerer kalderens tråd, indtil programmet
    er færdigt eller timeout indtræffer. For de relativt hurtige kommandoer
    (powercfg tager typisk under 1 sekund), der bruges her, er dette fuldt
    acceptabelt. Skulle man afvikle langvarige kommandoer, bør det overvejes
    at flytte kaldet til en baggrundstråd for at undgå, at brugerfladen
    fryser.
  ---------------------------------------------------------------------------- }
function RunCommandCapture(const Cmd: String; const Params: array of String; out Output: String): Integer;
const
  // Sikkerhedstimeout i millisekunder. Hvis det eksterne program ikke er
  // færdigt inden for denne tid, tvinges det ned. 30 sekunder er rigeligt
  // til de kommandoer (powercfg, sc, ipconfig), der bruges i programmet.
  MAX_WAIT_MS = 30000;
var
  AProcess: TProcess;              // Styrer det eksterne program
  MemStream: TMemoryStream;        // Opsamler rå bytes fra programmets output
  RawBytes: TBytes;                // Midlertidig bytebuffer til konvertering til tekst
  BytesAvailable, BytesToRead, BytesRead: Integer; // Hjælpevariable til læseløkken
  Buffer: array[0..4095] of Byte;  // 4 KB midlertidig læse-buffer ved hvert Read-kald
  StartTime: QWord;                // Opstartstidspunkt (64-bit tick count, undgår overflow)
  UStr: UnicodeString;             // Midlertidig Unicode-streng under tegnkodningskonvertering
  i: Integer;                      // Løbeindeks til gennemløb af parameterlisten
begin
  // Initialiser returværdien til -1, som signalerer "kunne ikke afvikles".
  // Hvis alt går godt, overskrives dette senere med programmets egentlige
  // exit-kode.
  Result := -1;

  // Sikr at Output-parameteren altid er defineret, også hvis funktionen
  // fejler tidligt, så kalderen aldrig modtager en uinitialiseret variabel.
  Output := '';

  // Nulstil RawBytes, så vi ikke risikerer at læse tilfældige data.
  RawBytes := nil;

  // Nulstil læsebufferen for at undgå, at gamle data lækker ind i nye kald.
  FillChar(Buffer, SizeOf(Buffer), 0);

  // Opret proces-styreren. Nil som ejer betyder, at vi selv frigiver den.
  AProcess := TProcess.Create(nil);

  // Opret en hukommelsesstrøm til at opsamle de rå databytes fra programmets
  // output. Vi bruger en stream frem for en string, fordi vi ikke ved, hvilken
  // tegnkodning der anvendes, før vi har læst alle bytes.
  MemStream := TMemoryStream.Create;
  try
    // Angiv hvilket program der skal afvikles (fuld sti anbefales).
    AProcess.Executable := Cmd;

    // Tilføj hvert argument (f.eks. '-h' og 'off') som et SEPARAT element i
    // TProcess.Parameters. Dette er vigtigt: Hvis man samlede argumenterne
    // til én streng med mellemrum, ville programmer med mellemrum i deres
    // argumenter (f.eks. filstier) blive opdelt forkert.
    for i := Low(Params) to High(Params) do
      AProcess.Parameters.Add(Params[i]);

    // Indstillinger for processen – hver især forklaret i detaljer ovenfor:
    // poNoConsole       : Vis intet sort DOS-vindue.
    // poUsePipes        : Opret rørledninger, så vi kan læse programmets output.
    // poStderrToOutPut  : Saml fejlbeskeder sammen med normal tekst.
    // poNewProcessGroup : Isoler processen så den ikke trækker vores app med
    //                     ned ved fejl, og så vi kan terminere den sikkert.
    AProcess.Options := [poNoConsole, poUsePipes, poStderrToOutPut, poNewProcessGroup];

    // Start det eksterne program.
    AProcess.Execute;

    // Gem tidspunktet for opstart, så vi kan måle, hvor længe processen kører.
    // GetTickCount64 bruges frem for GetTickCount for at undgå overflow efter
    // 49 dage på 32-bit systemer.
    StartTime := GetTickCount64;

    // Løkke: Bliv ved med at læse data, så længe processen kører, ELLER hvis
    // der stadig ligger ubehandlede bytes tilbage i røret. Sidstnævnte er
    // vigtigt, fordi processen kan afslutte, mens der stadig er data i bufferen,
    // som endnu ikke er blevet læst.
    while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do
    begin
      BytesAvailable := AProcess.Output.NumBytesAvailable;
      if BytesAvailable > 0 then
      begin
        // Begræns læsningen til bufferens størrelse (4 KB) ad gangen.
        BytesToRead := BytesAvailable;
        if BytesToRead > SizeOf(Buffer) then
          BytesToRead := SizeOf(Buffer);

        // Læs rå bytes ud af rørledningen. Read returnerer det faktiske antal
        // læste bytes, som kan være mindre end det ønskede.
        BytesRead := AProcess.Output.Read(Buffer, BytesToRead);
        if BytesRead > 0 then
          // Akkumuler de læste bytes i hukommelsesstrømmen.
          MemStream.Write(Buffer, BytesRead);
      end
      else
        // Hvis røret er tomt lige nu, men processen stadig kører, giver vi
        // processoren en kort pause på 15 ms. Uden dette ville løkken køre
        // i 100 % CPU uden at gøre nytte. 15 ms er valgt som et kompromis
        // mellem CPU-forbrug og lydhørhed (maksimalt 15 ms forsinkelse på
        // nye data).
        Sleep(15);

      // Sikkerhedstjek: Hvis programmet har kørt i mere end MAX_WAIT_MS,
      // tvinges det ned for at undgå, at vores applikation fryser. Dette
      // kan ske, hvis det eksterne program venter på brugerinput eller
      // er gået i baglås.
      if GetTickCount64 - StartTime > MAX_WAIT_MS then
      begin
        // Terminate(1) sender en anmodning om at afslutte processen med
        // exit-kode 1 (fejl). Windows frigiver ikke nødvendigvis processen
        // med det samme, så vi venter op til 5 sekunder på, at den faktisk
        // afsluttes.
        AProcess.Terminate(1);
        WaitForSingleObject(AProcess.Handle, 5000);
        Break;
      end;
    end;

    // Når processen er færdig (eller tvunget ned), konverteres de rå bytes
    // til en læselig tekststreng. Hvis der ikke blev skrevet noget output,
    // springes konverteringen over, og Output forbliver tom.
    if MemStream.Size > 0 then
    begin
      // Allokér en byte-array med præcis den størrelse, der blev opsamlet.
      SetLength(RawBytes, MemStream.Size);
      // Spol tilbage til begyndelsen af strømmen, så vi læser fra første byte.
      MemStream.Position := 0;
      // Læs alle bytes ind i arrayet på én gang.
      MemStream.ReadBuffer(RawBytes[0], MemStream.Size);
      try
        // Forsøg først at fortolke teksten som UTF-8, som er standard for
        // moderne Windows-værktøjer (f.eks. powercfg på nyere Windows-versioner).
        UStr := TEncoding.UTF8.GetString(RawBytes);
      except
        on E: Exception do
          // Hvis UTF-8-fortolkningen fejler (f.eks. fordi der er ulovlige
          // byte-sekvenser), antager vi, at teksten er i den lokale ANSI-
          // kodning (Windows-1252 på danske systemer). Dette dækker ældre
          // værktøjer, der ikke understøtter UTF-8.
          UStr := TEncoding.ANSI.GetString(RawBytes);
      end;
      // Konverter den interne Unicode-streng til UTF-8, så den er klar til
      // brug i LCL-brugerfladen, som forventer UTF-8 i string-typen.
      Output := UTF8Encode(UStr);
    end;

    // Returnér programmets exit-kode. I Windows-konventionen betyder 0
    // normalt succes, mens ikke-nul angiver en fejl. Kalderen kan bruge
    // denne kode til at afgøre, om handlingen skal betragtes som vellykket.
    Result := AProcess.ExitCode;
  finally
    // Frigør altid hukommelsesstrømmen, uanset om der blev kastet en undtagelse.
    MemStream.Free;

    // Frigør altid proces-objektet. Dette frigiver også Windows-håndtaget
    // til processen, så systemet ikke lækker ressourcer.
    AProcess.Free;
  end;
end;

{ ============================================================================
  KONSTRUKTØRER FOR TTweakItem-KLASSEN
  ============================================================================
  TTweakItem er den centrale dataklasse i hele programmet. Hvert eneste punkt
  i brugerfladen – hver enkelt afkrydsningsfelt – repræsenterer præcis ét
  TTweakItem-objekt i hukommelsen. Objektet gemmer ALT, hvad programmet skal
  vide om den pågældende optimering:

    - Hvor i registreringsdatabasen den hører til (RootKey + SubKey).
    - Hvilken parameter der skal ændres (ValueName).
    - Hvilken datatype parameteren har (ValKind).
    - Den optimerede værdi og fabriksstandardværdien.
    - De forklarende fordele og ulemper, som vises i infopanelet.

  Der findes fire forskellige konstruktører, fordi de fire tweak-typer har
  vidt forskellige datastrukturer. Ved at have separate konstruktører undgås
  en stor, fejlbehæftet "alt-muligt"-konstruktør med masser af ubrugte
  parametre, og compileren kan samtidig hjælpe med at fange forkerte kald.

  Fælles for alle fire konstruktører:
    - De kalder 'inherited Create' for at initialisere TObject-delen
      (hukommelsesallokering og skjulte felter).
    - De kopierer de modtagne parametre ind i objektets felter.
    - De sætter ValKind, så resten af programmet kan afgøre, hvordan
      tweaket skal læses, skrives og vises.
    - De frigiver IKKE noget – objektets levetid styres af TFormMain,
      som ejer TFPList-listen FTweaks og frigør alle objekter i FormDestroy.

  Hvorfor er parametrene 'const'?
    Strengparametrene (ATitle, ASubKey, AValName, APros, ACons osv.) er
    markeret som 'const', fordi de kun læses og kopieres ind i objektets
    felter. På den måde undgår Free Pascal at lave en unødvendig ekstra
    kopi af strengen ved kaldet (streng-copy-on-write optimering), hvilket
    sparer både tid og hukommelse – især vigtigt, når konstruktørerne kaldes
    46 gange i træk under PopulateAllTweaks.
  ============================================================================ }


{ ----------------------------------------------------------------------------
  TTweakItem.CreateDWord
  Formål:
    Opretter et nyt tweak-objekt, der repræsenterer en REG_DWORD-værdi
    (et 32-bit heltal uden fortegn) i registreringsdatabasen.

  Hvornår bruges denne type?
    Langt de fleste Windows-indstillinger gemmes som DWORD-værdier. Det gælder
    f.eks. telemetri (AllowTelemetry = 0), netværksbegrænsning
    (NetworkThrottlingIndex = $FFFFFFFF) og prioritetsindstillinger
    (Win32PrioritySeparation = 38). Denne konstruktør er derfor den hyppigst
    anvendte af de fire.

  Parametre:
    ACat : Integer
      Kategoriindeks (0-9) for det faneblad, tweaket hører til. Bruges af
      BuildUI til at placere afkrydsningsfeltet på det rigtige faneblad, og
      af BtnApplyCurrentTabClick / BtnRestoreCurrentTabClick til at afgøre,
      om tweaket er en del af den aktive kategori.

    ATitle : String
      Den synlige overskrift ud for afkrydsningsfeltet, f.eks.
      'Deaktiver Windows Telemetri (DataCollection)'. Vises også i
      infopanelets LblInfoName.

    ARoot : HKEY
      Rod-nøglen, f.eks. HKEY_LOCAL_MACHINE eller HKEY_CURRENT_USER.
      Afgør sammen med SubKey den fulde sti i registreringsdatabasen.

    ASubKey : String
      Mappestien indeni registreringsdatabasen, relativt til ARoot.
      F.eks. 'SOFTWARE\Policies\Microsoft\Windows\DataCollection'.

    AValName : String
      Selve parameterens navn, f.eks. 'AllowTelemetry'. Er den tomme streng,
      henviser det til nøglens standardværdi (som dog sjældent bruges i
      denne applikation).

    AOpt : Cardinal
      Den optimerede værdi, som sættes, når brugeren slår tweaket TIL.
      Bruger Cardinal (32-bit uden fortegn) frem for Integer, så værdier
      som $FFFFFFFF (4.294.967.295) kan repræsenteres korrekt uden at blive
      opfattet som negative tal.

    ADef : Cardinal
      Fabriksstandardværdien, som Windows oprindeligt blev leveret med, og
      som genskabes, når brugeren ruller tweaket tilbage.

    APros : String
      Beskrivelse af de positive effekter ved at aktivere tweaket. Vises i
      MemoPros i infopanelet.

    ACons : String
      Beskrivelse af ulemper eller risici ved at aktivere tweaket. Vises i
      MemoCons i infopanelet. En ærlig beskrivelse af bagsiden er vigtig for,
      at brugeren kan træffe et informeret valg.
  ---------------------------------------------------------------------------- }
constructor TTweakItem.CreateDWord(ACat: Integer; const ATitle: String;
  ARoot: HKEY; const ASubKey, AValName: String; AOpt, ADef: Cardinal;
  const APros, ACons: String);
begin
  // Kald TObject's konstruktør for at allokere og initialisere objektets
  // skjulte basis-felter (bl.a. VMT-peger og referencetælling).
  inherited Create;

  // Kopiér de simple parametre direkte ind i objektets felter.
  CategoryIndex := ACat;
  Title := ATitle;
  RootKey := ARoot;
  SubKey := ASubKey;
  ValueName := AValName;

  // Sæt datatypen, så ReadSingleTweakStatus, SetTweakInRegistry og
  // MenuCreateBackupClick ved, at de skal behandle denne post som et
  // 32-bit heltal (REG_DWORD) og ikke som tekst.
  ValKind := vkDWord;

  // Gem den optimerede værdi (den "hurtige/sikre" tilstand).
  OptimizedDWord := AOpt;

  // Gem fabriksstandardværdien (den oprindelige Windows-tilstand).
  DefaultDWord := ADef;

  // Kopiér de forklarende tekster til infopanelet.
  Pros := APros;
  Cons := ACons;

  // Bemærk: Felterne OptimizedStr og DefaultStr (som hører til vkString)
  // samt DeleteKeyPath (som hører til vkEmptyKey) efterlades som nil/''.
  // Det er helt i orden, fordi ValKind = vkDWord fortæller resten af
  // programmet, at disse felter ikke er relevante for dette objekt.
end;


{ ----------------------------------------------------------------------------
  TTweakItem.CreateString
  Formål:
    Opretter et nyt tweak-objekt, der repræsenterer en REG_SZ-værdi
    (en almindelig tekststreng) i registreringsdatabasen.

  Hvornår bruges denne type?
    Nogle Windows-indstillinger gemmes som tekst i stedet for tal. Det gælder
    f.eks. 'MenuShowDelay' (som godt nok ofte skrives som tekst "20" eller
    "400"), 'WaitToKillAppTimeout' og 'ThisPCPolicy' (som bruger værdierne
    'Hide' og 'Show'). Denne konstruktør bruges derfor til de 6-7 tweaks,
    hvor en tekststreng er den rette repræsentation.

  Parametre:
    (De første fem parametre – ACat, ATitle, ARoot, ASubKey, AValName –
     har samme betydning som i CreateDWord og forklares derfor ikke igen her.)

    AOpt : String
      Den optimerede tekstværdi, som sættes, når brugeren slår tweaket TIL.
      F.eks. '20' for MenuShowDelay eller 'Hide' for ThisPCPolicy.

    ADef : String
      Fabriksstandardværdien som tekst. Hvis denne er den tomme streng '',
      betyder det, at den korrekte tilbagerulning er at SLETTE værdien helt
      (se SetTweakInRegistry). Dette bruges f.eks., når Windows oprindeligt
      slet ikke har værdien defineret.

    APros, ACons : String
      Som i CreateDWord – forklarende fordele og ulemper.
  ---------------------------------------------------------------------------- }
constructor TTweakItem.CreateString(ACat: Integer; const ATitle: String;
  ARoot: HKEY; const ASubKey, AValName: String; const AOpt, ADef: String;
  const APros, ACons: String);
begin
  // Kald TObject's konstruktør for at allokere og initialisere basis-felterne.
  inherited Create;

  // Kopiér de fælles parametre ind i objektets felter.
  CategoryIndex := ACat;
  Title := ATitle;
  RootKey := ARoot;
  SubKey := ASubKey;
  ValueName := AValName;

  // Sæt datatypen, så resten af programmet ved, at denne post skal læses og
  // skrives som en REG_SZ-tekststreng.
  ValKind := vkString;

  // Gem den optimerede tekstværdi (den "hurtige/sikre" tilstand).
  OptimizedStr := AOpt;

  // Gem fabriksstandardteksten. Hvis denne er tom, betyder det "slet værdien
  // ved tilbagerulning" – det håndteres af SetTweakInRegistry.
  DefaultStr := ADef;

  // Kopiér de forklarende tekster til infopanelet.
  Pros := APros;
  Cons := ACons;

  // Felterne OptimizedDWord, DefaultDWord og DeleteKeyPath efterlades
  // urørte, fordi de ikke er relevante for vkString-poster.
end;


{ ----------------------------------------------------------------------------
  TTweakItem.CreateEmptyKey
  Formål:
    Opretter et nyt tweak-objekt, der repræsenterer en "tom nøgle" i
    registreringsdatabasen – dvs. en nøgle, hvis blotte EKSISTENS er
    optimeringen, uanset hvilke værdier den indeholder.

  Hvornår bruges denne type?
    Nogle Windows-funktioner aktiveres eller deaktiveres alene ved, at en
    bestemt nøgle findes eller ej. Det mest kendte eksempel er Windows 11's
    klassiske højrekliksmenu: Når nøglen
      HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32
    findes (med en tom standardværdi), viser Stifinder den klassiske Windows
    10-menu. Når nøglen slettes, vender Windows 11's nye menu tilbage.

  Forskellen fra CreateDWord og CreateString:
    Ved de to andre typer er det en VÆRDI inde i nøglen, der ændres. Ved
    vkEmptyKey er det selve NØGLENS EKSISTENS, der er tweaket. Derfor findes
    der ingen AOpt/ADef-parametre – i stedet gemmes stien, der skal slettes
    ved tilbagerulning, i DeleteKeyPath.

  Parametre:
    (De første fem parametre har samme betydning som i de øvrige konstruktører.)

    ADeleteKeyPath : String
      Den fulde sti til den nøgle, der skal slettes rekursivt ved tilbagerulning.
      I praksis er denne ofte identisk med ASubKey, men de holdes adskilt for
      at gøre det muligt at slette en overordnet nøgle (f.eks. hele CLSID-grenen)
      selvom selve tweaket defineres på en undernøgle. Stien sendes videre til
      DeleteKeyTree, som sletter hele træet.

    APros, ACons : String
      Som i de øvrige konstruktører – forklarende fordele og ulemper.
  ---------------------------------------------------------------------------- }
constructor TTweakItem.CreateEmptyKey(ACat: Integer; const ATitle: String;
  ARoot: HKEY; const ASubKey, ADeleteKeyPath: String; const APros,
  ACons: String);
begin
  // Kald TObject's konstruktør for at allokere og initialisere basis-felterne.
  inherited Create;

  // Kopiér de fælles parametre ind i objektets felter.
  CategoryIndex := ACat;
  Title := ATitle;
  RootKey := ARoot;
  SubKey := ASubKey;

  // Gem den sti, der skal slettes rekursivt ved tilbagerulning. Denne sti
  // bruges af DeleteKeyTree, som kravler ned i hele træet og fjerner det
  // nedefra og op.
  DeleteKeyPath := ADeleteKeyPath;

  // Sæt datatypen, så resten af programmet ved, at denne post skal behandles
  // som en "nøgle-eksistens"-tweak og ikke som en værdiændring.
  ValKind := vkEmptyKey;

  // Kopiér de forklarende tekster til infopanelet.
  Pros := APros;
  Cons := ACons;

  // Felterne ValueName, OptimizedDWord, DefaultDWord, OptimizedStr og
  // DefaultStr efterlades urørte – de er ikke relevante for vkEmptyKey-poster.
  // Bemærk at ValueName heller ikke sættes, fordi der ikke findes nogen
  // navngivet værdi at læse eller skrive; det er nøglens blotte eksistens,
  // der tæller.
end;


{ ----------------------------------------------------------------------------
  TTweakItem.CreateHibernate
  Formål:
    Opretter et nyt tweak-objekt, der repræsenterer Windows' dvalefunktion
    (Hibernate). Dette er en særlig type, fordi dvalen IKKE styres via en
    simpel registreringsværdi, men via Windows' strømstyringskerne.

  Hvorfor en helt særlig konstruktør?
    De øvrige tre typer kan læses og skrives direkte via TRegistry. Dvale
    derimod styres af powercfg.exe, og selve tilstanden aflæses bedst via
    kommandoen 'powercfg /a' eller ved at undersøge, om filen C:\hiberfil.sys
    eksisterer. Derfor har denne type sin egen konstruktør uden sti- og
    værdiparametre – alt det nødvendige er hardkodet eller håndteres i
    ReadSingleTweakStatus / SetTweakInRegistry.

  Hvorfor sættes RootKey og SubKey alligevel?
    Selvom dvalen ikke ændres via registreringsdatabasen, sættes RootKey og
    SubKey alligevel til HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power.
    Det skyldes to ting:
      1. Hvis RootKey efterlades som 0 (HKEY_UNKNOWN), ville RootKeyToStr
         returnere 'HKEY_UNKNOWN' under sikkerhedskopien – grimt og forvirrende.
         Ved at sætte en gyldig rod-nøgle undgås dette.
      2. Hvis man på et tidspunkt ønsker at udvide programmet til også at
         læse HibernateEnabled-værdien direkte fra registreringsdatabasen,
         er stien allerede på plads.
    Bemærk, at MenuCreateBackupClick eksplicit springer vkHibernate-poster
    over, fordi de ikke hører hjemme i en .reg-sikkerhedskopi.

  Parametre:
    ACat : Integer
      Kategoriindeks – i praksis 2 (System & Ydeevne).

    ATitle : String
      Den synlige overskrift, f.eks. 'Slå dvale fra (Sletter hiberfil.sys via powercfg)'.

    APros, ACons : String
      Forklarende fordele og ulemper. For dvale er fordelen typisk frigjort
      diskplads, mens ulempen er, at både dvaletilstand og Hurtig Start
      (Fast Startup) deaktiveres.
  ---------------------------------------------------------------------------- }
constructor TTweakItem.CreateHibernate(ACat: Integer; const ATitle, APros, ACons: String);
begin
  // Kald TObject's konstruktør for at allokere og initialisere basis-felterne.
  inherited Create;

  // Kopiér de simple parametre ind i objektets felter.
  CategoryIndex := ACat;
  Title := ATitle;

  // Sæt en gyldig rod-nøgle og sti, selvom dvalen primært styres via powercfg.
  // Dette forhindrer, at RootKeyToStr returnerer 'HKEY_UNKNOWN', og gør
  // objektet konsistent med de øvrige tweak-typer.
  RootKey := HKEY_LOCAL_MACHINE;
  SubKey := 'SYSTEM\CurrentControlSet\Control\Power';

  // Sæt datatypen, så ReadSingleTweakStatus og SetTweakInRegistry ved, at
  // de skal bruge powercfg.exe og ikke TRegistry til at læse og skrive.
  ValKind := vkHibernate;

  // Kopiér de forklarende tekster til infopanelet.
  Pros := APros;
  Cons := ACons;

  // Felterne ValueName, OptimizedDWord, DefaultDWord, OptimizedStr,
  // DefaultStr og DeleteKeyPath efterlades urørte – de er ikke relevante
  // for vkHibernate-poster, fordi al håndtering sker via powercfg-kommandoer.
end;

{ ----------------------------------------------------------------------------
  IsProcessElevated
  Formål:
    At undersøge, om den kørende proces er startet med Administratorrettigheder
    ("elevated"), eller om den kører som en almindelig standardbruger. Dette er
    en kritisk forudsætning for hele programmets funktion, fordi mange af de
    tweaks, der ændres under HKEY_LOCAL_MACHINE, kræver forhøjede rettigheder.

  Baggrund – hvad er et "Access Token"?
    Windows benytter en sikkerhedsmodel baseret på adgangstokens (access tokens).
    Hver gang en proces startes, tildeler Windows-kernen den et token, som
    beskriver, hvilken bruger processen kører som, og hvilke rettigheder den har.
    Dette token indeholder bl.a.:
      - Brugerens SID (Security Identifier).
      - En liste over grupper, brugeren er medlem af.
      - En liste over privilegier (f.eks. SeShutdownPrivilege).
      - En såkaldt "elevation"-markør, der angiver, om processen kører med
        fulde administrative rettigheder eller ej.

    Når UAC (User Account Control) er aktiveret – hvilket er standard på alle
    moderne Windows-versioner – får en proces, der starter fra en administrativ
    konto, som udgangspunkt et BEGRÆNSET token, hvor elevation-markøren er 0.
    Kun hvis brugeren eksplicit godkender UAC-prompten ("Kør som administrator"),
    får processen et token med elevation-markøren sat til 1.

    Uden dette forhøjede token kan processen ikke skrive til beskyttede dele af
    registreringsdatabasen, især ikke under HKEY_LOCAL_MACHINE. Forsøg på at
    skrive dertil vil fejle med "Access Denied", og programmets kernefunktion
    ville derfor være ubrugelig.

  Hvordan funktionen virker (algoritmen):
    1. Funktionen åbner et håndtag til processens eget sikkerheds-token via
       Windows-API'et OpenProcessToken med rettigheden TOKEN_QUERY, som giver
       lov til at LÆSE tokenets oplysninger (men ikke ændre dem).
    2. Med det åbne token-håndtag kaldes GetTokenInformation med klassen
       TokenElevation (Windows' interne ID 20). Windows skriver resultatet ind
       i en TTokenElevation-record, hvor feltet TokenIsElevated er 0 eller 1.
    3. Hvis kaldet lykkes, returneres True, når TokenIsElevated <> 0.
    4. Token-håndtaget lukkes altid i en finally-blok, uanset om kaldet
       lykkedes eller ej, så der ikke opstår ressource-lækage.

  Hvorfor er TokenElevationClass en konstant og ikke en del af Windows-enheden?
    Free Pascals 'Windows'-enhed definerer desværre ikke altid alle de nyere
    TOKEN_INFORMATION_CLASS-værdier. Værdien 20 er imidlertid fast defineret
    i Windows SDK som TokenElevation og har været uændret siden Windows Vista.
    Ved at erklære den lokalt som en konstant undgås afhængighed af, om den
    pågældende Free Pascal-version har fået den med i 'Windows'-enheden.

  Hvorfor en lokal TTokenElevation-record?
    Den tilsvarende Windows-struktur (TOKEN_ELEVATION) er blot en enkelt DWORD.
    Ved at erklære den lokalt som en record undgår vi at skulle importere
    yderligere typer og gør koden selvforklarende: feltnavnet TokenIsElevated
    siger præcis, hvad værdien betyder, i modsætning til et anonymt DWORD.

  Parametre:
    Ingen – funktionen arbejder udelukkende på den kørende proces selv.

  Returværdi:
    Result : Boolean
      - True  : Processen kører med forhøjede (administrative) rettigheder.
                Programmet kan skrive til HKEY_LOCAL_MACHINE og udføre
                systemændringer.
      - False : Processen kører som standardbruger (eller kun med begrænsede
                rettigheder). Skrivning til beskyttede nøgler vil fejle.

  Fejlhåndtering:
    Hvis OpenProcessToken eller GetTokenInformation fejler (hvilket er meget
    sjældent for ens egen proces), returneres False forsigtigt. Dette betyder,
    at programmet hellere nægter at køre end at forsøge at foretage ændringer
    uden de nødvendige rettigheder. FormCreate bruger resultatet til at vise
    en advarsel og afslutte programmet pænt, hvis rettighederne mangler.

  Anvendelse i programmet:
    Funktionen kaldes udelukkende fra FormCreate, hvor den afgør, om
    programmet overhovedet må starte:
      if not IsProcessElevated then
      begin
        MessageDlg('Administratorrettigheder påkrævet', ...);
        Application.ShowMainForm := False;
        Application.Terminate;
        Exit;
      end;
    Dette sikrer, at brugeren aldrig præsenteres for en brugerflade, hvor
    halvdelen af funktionerne stille og roligt ville fejle.

  Sikkerhedsmæssig bemærkning:
    Funktionen undersøger kun, om processen er elevated – den verificerer IKKE,
    om brugeren faktisk er medlem af Administrators-gruppen. Det er korrekt
    design, fordi UAC kan give en standardbruger et midlertidigt forhøjet token
    via indtastning af en administratorkonto. Det er tilstrækkeligt for
    programmets formål, at processen har de nødvendige skriverettigheder.

  Kendt begrænsning:
    Hvis UAC er slået helt fra (hvilket kun bør ske på dedikerede
    administrationsmaskiner), vil alle processer fra en administrativ konto
    have TokenIsElevated = 1. I så fald kan programmet ikke skelne mellem
    "kører som administrator" og "kører som standardbruger på et system uden
    UAC". Dette er dog uproblematisk, fordi rettighederne i praksis ER til
    stede i begge tilfælde.
  ---------------------------------------------------------------------------- }
function TFormMain.IsProcessElevated: Boolean;
type
  // Lokal record, der afspejler Windows' TOKEN_ELEVATION-struktur.
  // Windows fylder dette felt med 0 (standardbruger) eller 1 (administrator).
  // Ved at erklære den lokalt undgås afhængighed af, om den pågældende
  // Free Pascal-version har typen defineret i 'Windows'-enheden.
  TTokenElevation = record
    TokenIsElevated: DWORD;  // 0 = Standardbruger, 1 = Administrator
  end;
const
  // Windows' interne enum-værdi for TokenElevation-forespørgsler.
  // Værdien 20 er fast defineret i Windows SDK og har været uændret siden
  // Windows Vista. Erklæres lokalt, fordi Free Pascals 'Windows'-enhed ikke
  // altid inkluderer denne nyere TOKEN_INFORMATION_CLASS-værdi.
  TokenElevationClass = 20;
var
  hToken: THandle;          // Håndtag til processens sikkerheds-token
  Elevation: TTokenElevation; // Resultatet af elevation-forespørgslen
  retLen: DWORD;            // Antal bytes, som Windows returnerede (skal angives)
begin
  // Initialiser returværdien til False. Hvis noget går galt undervejs,
  // returneres False – det er den sikre standard (hellere nægte end at
  // antage forhøjede rettigheder, der ikke findes).
  Result := False;

  // Nulstil længdevariablen. Windows kræver, at denne er initialiseret,
  // og udfylder den med den faktiske størrelse på det returnerede data.
  retLen := 0;

  // Nulstil hele Elevation-recorden, så vi ikke læser tilfældige data,
  // hvis Windows af en eller anden grund ikke skulle udfylde den.
  FillChar(Elevation, SizeOf(Elevation), 0);

  // Åbn processens eget sikkerheds-token med TOKEN_QUERY-rettigheden, som
  // giver lov til at LÆSE tokenets oplysninger. GetCurrentProcess() returnerer
  // et pseudo-håndtag til den kørende proces – det skal ikke lukkes.
  if OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, @hToken) then
  begin
    try
      // Spørg Windows-kernen om, hvorvidt processen er elevated. Funktionen
      // skriver resultatet ind i Elevation-recorden og returnerer True ved
      // succes. Parameteren TokenElevationClass angiver, hvilken slags
      // information der ønskes (her: elevation-status).
      if GetTokenInformation(hToken, TTokenInformationClass(TokenElevationClass),
        @Elevation, SizeOf(Elevation), retLen) then
        // Hvis kaldet lykkedes, er svaret gemt i Elevation.TokenIsElevated.
        // En værdi forskellig fra 0 betyder "forhøjet".
        Result := (Elevation.TokenIsElevated <> 0);
    finally
      // Luk ALTID token-håndtaget, uanset om GetTokenInformation lykkedes
      // eller ej. Windows frigiver ikke håndtaget automatisk, og en lækage
      // ville over tid dræne systemets ressourcepulje. Dette er især vigtigt,
      // fordi funktionen kan kaldes gentagne gange i fremtidige versioner.
      CloseHandle(hToken);
    end;
  end;
  // Hvis OpenProcessToken fejler (yderst sjældent for ens egen proces),
  // forbliver Result = False, og programmet vil nægte at starte. Dette er
  // den sikre opførsel: hellere stoppe end at køre uden rettigheder.
end;

{ ----------------------------------------------------------------------------
  FormCreate
  Formål:
    Programmets opstartssekvens. Denne procedure kaldes AUTOMATISK af LCL
    (Lazarus Component Library), når hovedvinduet første gang oprettes –
    dvs. i praksis, når brugeren starter programmet. Procedurens opgave er
    at gennemføre hele den indledende initialisering i den korrekte rækkefølge,
    så brugerfladen fremstår korrekt og afspejler computerens faktiske tilstand.

  Hvornår kaldes proceduren?
    LCL kalder FormCreate som led i oprettelsen af TFormMain. Det sker FØR
    vinduet vises på skærmen, hvilket er ideelt: Vi kan nå at afvise brugeren
    (hvis rettigheder mangler), indlæse data og bygge brugerfladen, FØR
    brugeren ser noget som helst. Dermed undgår vi en flimrende opstart med
    halvfærdig brugerflade.

  De fem trin i opstartssekvensen:
    1. Rettighedskontrol (fail-fast).
       Straks undersøges det, om processen kører som Administrator. Hvis ikke,
       vises en forklarende meddelelse, og programmet afsluttes pænt. Dette
       er et "fail-fast"-design: Det er bedre at stoppe med en klar besked
       end at lade brugeren klikke rundt i en brugerflade, hvor halvdelen af
       handlingerne alligevel ville fejle med "Access Denied".
    2. Initialisering af event-guard og statusfelter.
       FUpdatingUI sættes til False, så CheckBoxClick ikke fejlagtigt tror,
       at den er midt i en programmatisk opdatering. FLastHoverItem nulstilles,
       så infopanelet ikke viser gamle data fra en tidligere session.
    3. Oprettelse af tweak-listen.
       FTweaks (en TFPList) oprettes i RAM. Denne liste bliver den centrale
       datastruktur, som alle efterfølgende operationer arbejder på.
    4. Indlæsning, UI-opbygning og registeraflæsning (i try/except).
       PopulateAllTweaks, BuildUI og ReadRegistryStatus køres i den rækkefølge,
       fordi de er afhængige af hinanden:
         - PopulateAllTweaks skal køre først, så listen er fyldt, FØR
           BuildUI forsøger at oprette afkrydsningsfelter ud fra den.
         - BuildUI skal køre, FØR ReadRegistryStatus, fordi sidstnævnte
           opdaterer de CheckBox-referencer, som BuildUI netop har oprettet.
         - ReadRegistryStatus skal køre sidst, så fluebenene afspejler
           computerens faktiske tilstand ved opstart.
       Alt dette er pakket ind i try/except, så en uventet fejl (f.eks. en
       korrupt registreringsnøgle) vises som en pæn meddelelse frem for at
       få programmet til at crashe med en uforståelig fejlkode.

  Fejlhåndtering:
    - Manglende Administratorrettigheder: Brugeren informeres og programmet
      afsluttes.
    - Enhver anden undtagelse under initialiseringen: Der vises en
      meddelelsesboks med fejlbeskrivelsen. Herefter fortsætter programmet
      i den tilstand, det nu engang er nået til – typisk med en tom eller
      delvist udfyldt brugerflade. Dette er et bevidst valg: Det er bedre
      at give brugeren en chance for at se, hvad der gik galt, end at
      afslutte uden forklaring.

  Hvorfor Application.Terminate og ikke Close?
    FormCreate kaldes, FØR hovedvinduet er blevet vist. Et kald til Close
    ville derfor være meningsløst, fordi der ikke er noget vindue at lukke
    endnu. Application.Terminate derimod stopper hele beskedløkken (message
    loop), så applikationen afsluttes korrekt, uanset hvor i opstartsfasen
    vi befinder os. Application.ShowMainForm := False forhindrer desuden,
    at vinduet når at blinke kortvarigt op på skærmen, inden programmet
    afsluttes.

  Hvorfor try/except omkring de tre initialiseringskald?
    PopulateAllTweaks, BuildUI og ReadRegistryStatus kan hver især kaste
    undtagelser, hvis noget uventet sker – f.eks. hvis registreringsdatabasen
    er beskadiget, eller hvis der ikke kan allokeres hukommelse til de mange
    objekter. Uden try/except ville en sådan undtagelse boble op til LCL's
    egen fejlhåndtering, som typisk viser en grim og teknisk fejlmeddelelse
    eller – i værste fald – lader programmet crashe. Med try/except får
    brugeren en pæn, forståelig besked.

  Anvendelse af FTweaks-listen:
    FTweaks oprettes som en TFPList, fordi vi har brug for en simpel,
    hukommelseseffektiv liste af pointers (ikke objekter, som TObjectList
    ville håndtere automatisk). Ejerskabet af de enkelte TTweakItem-objekter
    ligger hos TFormMain selv, og de frigives i FormDestroy. Hvis initialiseringen
    fejler halvvejs, vil FormDestroy stadig blive kaldt af LCL og frigøre
    de objekter, der nåede at blive oprettet – forudsat at FTweaks ikke er nil.
  ---------------------------------------------------------------------------- }
procedure TFormMain.FormCreate(Sender: TObject);
begin
  // -------------------------------------------------------------------------
  // TRIN 1: Rettighedskontrol (fail-fast)
  // -------------------------------------------------------------------------
  // Undersøg straks, om processen kører med administrative rettigheder.
  // Uden disse rettigheder kan programmet ikke skrive til HKEY_LOCAL_MACHINE,
  // og langt de fleste tweaks ville fejle med "Access Denied". Derfor er det
  // bedre at afvise brugeren med det samme og give en klar instruks om,
  // hvordan programmet startes korrekt.
  if not IsProcessElevated then
  begin
    // Vis en informativ meddelelse med en konkret handlingsanvisning.
    // sLineBreak indsætter de korrekte linjeskifttegn afhængigt af platformen.
    MessageDlg('Administratorrettigheder påkrævet',
      'Dette værktøj skal afvikles som Administrator for at kunne justere systemindstillinger.' + sLineBreak + sLineBreak +
      'Højreklik på programmet og vælg "Kør som administrator".',
      mtError, [mbOK], 0);

    // Forhindr at hovedvinduet når at blive vist blot for at forsvinde igen.
    // Uden denne linje ville brugeren se et kort blink af hovedvinduet,
    // inden programmet afsluttes – det virker forvirrende og uprofessionelt.
    Application.ShowMainForm := False;

    // Stop hele applikationens beskedløkke. Dette er den korrekte måde at
    // afslutte en applikation på fra FormCreate, fordi Close ikke ville
    // have nogen effekt, når vinduet endnu ikke er vist.
    Application.Terminate;

    // Afslut proceduren med det samme, så resten af initialiseringen
    // ikke forsøges gennemført uden de nødvendige rettigheder.
    Exit;
  end;

  // -------------------------------------------------------------------------
  // TRIN 2: Initialisering af event-guard og statusfelter
  // -------------------------------------------------------------------------
  // FUpdatingUI er en såkaldt "event-guard": Et flag, der forhindrer, at
  // programmatiske ændringer af CheckBox.Checked udløser OnClick-hændelsen,
  // hvilket ellers kunne føre til uendelige rekursive kald. Sæt den til
  // False her, så vi starter i en kendt, "rolig" tilstand.
  FUpdatingUI := False;

  // Nulstil markøren for det sidst viste tweak, så infopanelet ikke viser
  // forældede data fra en eventuel tidligere visning (f.eks. hvis vinduet
  // genåbnes efter at være blevet skjult).
  FLastHoverItem := nil;

  // Sæt statusbaren til at bruge SimplePanel-tilstand, så vi kan skrive
  // fritekst i den via SimpleText i stedet for at skulle håndtere
  // individuelle paneler.
  StatusBar1.SimplePanel := True;

  // -------------------------------------------------------------------------
  // TRIN 3: Opret tweak-listen i RAM
  // -------------------------------------------------------------------------
  // Opret vores hurtige pointer-liste (TFPList). Denne liste bliver
  // hjertet i hele programmets datamodel: Alle 46 optimeringer gemmes
  // som TTweakItem-objekter, og FTweaks holder styr på dem.
  // Bemærk: TFPList frigiver ikke selv de objekter, den peger på. Det gør
  // vi manuelt i FormDestroy, så vi har fuld kontrol over levetiden.
  FTweaks := TFPList.Create;

  try
    // -----------------------------------------------------------------------
    // TRIN 4: Udfyld listen med data
    // -----------------------------------------------------------------------
    // Indlæs alle 46 tweaks i hukommelsen med deres stier, værdier, fordele
    // og ulemper. Uden dette trin ville BuildUI ikke have noget at bygge
    // brugerfladen ud fra, så rækkefølgen er afgørende.
    PopulateAllTweaks;

    // -----------------------------------------------------------------------
    // TRIN 5: Byg brugerfladen
    // -----------------------------------------------------------------------
    // Generér de 10 faneblade, rullepanelet på hvert faneblad og et
    // afkrydsningsfelt for hvert tweak. Denne procedure læser FTweaks-listen
    // og opretter de tilsvarende visuelle komponenter.
    BuildUI;

    // -----------------------------------------------------------------------
    // TRIN 6: Aflæs computerens faktiske tilstand
    // -----------------------------------------------------------------------
    // Gennemgå Windows-registreringsdatabasen og sæt flueben i de tweaks,
    // der allerede er aktive på computeren. Dette skal ske EFTER BuildUI,
    // fordi det er de CheckBox-referencer, som BuildUI har oprettet, der
    // nu skal opdateres.
    ReadRegistryStatus;
  except
    // Hvis en af de tre initialiseringsprocedurer kaster en undtagelse
    // (f.eks. pga. en beskadiget registreringsnøgle eller hukommelsesmangel),
    // fanges den her, og brugeren får en forståelig fejlmeddelelse i stedet
    // for en teknisk crash-rapport.
    on E: Exception do
      MessageDlg('Initialiseringsfejl', E.Message, mtError, [mbOK], 0);
  end;
end;

{ ----------------------------------------------------------------------------
  FormDestroy
  Formål:
    Programmets nedlukningssekvens. Denne procedure kaldes AUTOMATISK af LCL,
    når hovedvinduet destrueres – dvs. i praksis, når brugeren lukker programmet
    (via menuen "Afslut", krydset i vinduets hjørne eller en systemnedlukning).
    Procedurens opgave er at frigive ALLE de ressourcer, som programmet har
    allokeret under sin levetid, i den korrekte rækkefølge, så der ikke opstår
    hukommelseslækager, adgang til frigjort hukommelse ("use-after-free") eller
    nedbrud under selve lukningen.

  Hvorfor er rækkefølgen kritisk?
    Nedlukning er en af de farligste faser i et GUI-program. Hvis objekter
    frigives i den forkerte rækkefølge, eller hvis en hændelseshåndteringsrutine
    kaldes efter, at dens data er frigjort, crasher programmet typisk med en
    tilfældig adgangsfejl – ofte først opdaget, når brugeren lukker programmet,
    hvilket virker meget utrygt. Denne procedure er derfor designet med stor
    omhu omkring rækkefølgen:

      1. Først frakobles alle hændelser på CheckBox-komponenterne.
      2. Derefter nulstilles hover-markøren og PageControl.
      3. Så frigives fanebladene (og dermed CheckBox-komponenterne) bagfra.
      4. Til sidst frigives TTweakItem-objekterne og selve FTweaks-listen.

    Hvis man byttede om på trin 1 og trin 3 – eller sprang trin 1 helt over –
    ville LCL kunne nå at kalde CheckBoxClick eller CheckBoxMouseMove under
    frigivelsen af fanebladene, mens TTweakItem-objekterne stadig var i brug
    eller allerede var delvist frigivet. Det er præcis den slags fejl, der
    giver de berygtede "Access Violation"-fejl ved programlukning.

  Baggrund – ejerskab og levetider:
    Programmet har to parallelle objektgrafer, som skal frigives:
      A. Den VISUELLE graf:
         PageControl1 → TabSheet → ScrollBox → TCheckBox.
         LCL ejer disse komponenter, og de frigives automatisk, når deres
         forælder frigives. Vi behøver derfor ikke frigive hver CheckBox
         manuelt – vi skal blot frigive TabSheet'ene i PageControl1, hvorefter
         hele undergrafen forsvinder.
      B. Den LOGISKE graf:
         FTweaks → TTweakItem-objekter.
         Denne graf ejes af TFormMain selv (os). LCL kender intet til
         TTweakItem-objekterne, så vi SKAL frigive dem manuelt – ellers
         lækker hukommelsen.

    Problemet er, at de to grafer er forbundet: Hvert TTweakItem har en
    reference til sin CheckBox (Item.CheckBox), og hver CheckBox har en
    reference til sit TTweakItem (via Tag-egenskaben). Hvis vi frigiver
    den ene graf, mens den anden stadig peger på den, har vi en dangling
    pointer. Derfor skal referencerne mellem graferne brydes FØRST –
    hvilket er præcis, hvad trin 1 gør.

  De fire trin i nedlukningssekvensen:
    TRIN 1 – Frakobl CheckBox-hændelser.
      For hvert TTweakItem nulstilles CheckBox'ens tre hændelsesreferencer
      (OnMouseMove, OnEnter, OnClick) til nil, og Item.CheckBox sættes til
      nil. Hermed er forbindelsen mellem de to grafer brudt i begge retninger.
      Efter dette trin kan hverken LCL eller vores egen kode nå at kalde
      hændelser, der refererer til data under frigivelse.

    TRIN 2 – Nulstil hover-markør og PageControl.
      FLastHoverItem sættes til nil, så ShowTweakInfo ikke kan komme til at
      læse fra et frigivet TTweakItem. PageControl1.ActivePage sættes til
      nil, så PageControl ikke forsøger at aktivere en fane under frigivelsen.

    TRIN 3 – Frigør fanebladene bagfra.
      Alle TabSheet i PageControl1 frigives én ad gangen – BAGFRA og frem.
      Hvorfor bagfra? Fordi PageControl1.Pages er en indekseret liste, hvor
      indekserne ændrer sig, når et element fjernes. Hvis vi slettede forfra,
      ville indeks 0 efter den første sletning pege på det næste element, og
      vi ville springe halvdelen af fanebladene over. Ved at slette bagfra
      (PageCount-1, derefter PageCount-1 igen osv.) er indekset altid gyldigt.
      Frigivelsen af en TabSheet frigiver automatisk dens ScrollBox og alle
      dens CheckBox'er, fordi LCL's ejerskabsmodel sørger for at frigive børn
      sammen med deres forælder.

    TRIN 4 – Frigør TTweakItem-objekterne og selve listen.
      Hvert TTweakItem frigives manuelt (vi har ejerskabet), og til sidst
      frigives selve FTweaks-listen. FreeAndNil bruges frem for blot Free,
      fordi den også sætter FTweaks til nil. Det er vigtigt, hvis FormDestroy
      ved en fejl skulle blive kaldt to gange (hvilket ikke bør ske, men er
      billig forsikring mod fremtidige ændringer).

  Hvorfor Assigned-tjekkene?
    FTweaks kan være nil, hvis FormCreate fejlede tidligt (f.eks. fordi
    brugeren ikke havde administratorrettigheder, eller fordi en af
    initialiseringsprocedurerne kastede en undtagelse, FØR listen blev
    oprettet). I så fald skal FormDestroy stadig kunne køre uden at crashe.
    Assigned(FTweaks) er den idiomatiske måde at tjekke for nil i Pascal.

    Tilsvarende tjekkes Assigned(Item.CheckBox) for hvert enkelt tweak, fordi
    et TTweakItem godt kan eksistere uden en tilknyttet CheckBox – f.eks. hvis
    BuildUI fejlede halvvejs, eller hvis et tweak af en eller anden grund ikke
    fik tildelt en CheckBox.

  Hvorfor nulstilles hændelserne, selv om LCL frigiver CheckBox'erne?
    Man kunne tro, at det var overflødigt at nulstille hændelserne, når
    CheckBox'erne alligevel bliver frigivet af LCL. Men under frigivelsen af
    en komponent kan LCL nå at sende beskeder (f.eks. CM_DESTROY eller
    musebeskeder, der stadig ligger i beskedkøen), som udløser hændelser.
    Hvis OnClick på det tidspunkt stadig peger på CheckBoxClick, og denne
    funktion forsøger at læse Item.CheckBox eller kalde SetTweakInRegistry,
    vil det resultere i en adgangsfejl. Ved at nulstille hændelserne FØRST
    forhindres dette effektivt.

  Kendt begrænsning:
    Hvis programmet afsluttes unormalt (f.eks. ved et strømsvigt eller en
    hård nedlukning via Task Manager), kaldes FormDestroy måske aldrig.
    I så fald frigives hukommelsen af operativsystemet alligevel, når
    processen afsluttes, så der opstår ikke en vedvarende lækage. FormDestroy
    er primært vigtig for en pæn og kontrolleret nedlukning og for at undgå
    crashes, der kunne efterlade brugeren med et dårligt indtryk.
  ---------------------------------------------------------------------------- }
procedure TFormMain.FormDestroy(Sender: TObject);
var
  i: Integer;       // Løbeindeks til gennemløb af FTweaks-listen
  Item: TTweakItem; // Midlertidig reference til det aktuelle tweak-objekt
begin
  // -------------------------------------------------------------------------
  // TRIN 1: Frakobl CheckBox-hændelser (bryd forbindelsen mellem graferne)
  // -------------------------------------------------------------------------
  // Gennemløb alle tweaks og fjern deres hændelsesreferencer. Dette sikrer,
  // at LCL ikke kan kalde vores hændelsesrutiner, mens komponenterne
  // frigives. Assigned(FTweaks) tjekker, at listen faktisk blev oprettet
  // (den kan være nil, hvis FormCreate fejlede tidligt).
  if Assigned(FTweaks) then
  begin
    for i := 0 to FTweaks.Count - 1 do
    begin
      Item := TTweakItem(FTweaks[i]);

      // Tjek at der faktisk ER en CheckBox tilknyttet. Et tweak kan godt
      // eksistere uden en CheckBox, hvis BuildUI fejlede halvvejs.
      if Assigned(Item.CheckBox) then
      begin
        // Nulstil de tre hændelsesreferencer, så LCL ikke længere kan
        // kalde vores metoder under destruktionen af komponenten. Dette
        // er den afgørende beskyttelse mod "use-after-free"-fejl.
        Item.CheckBox.OnMouseMove := nil;
        Item.CheckBox.OnEnter := nil;
        Item.CheckBox.OnClick := nil;

        // Nulstil også referencen fra tweaket TIL CheckBox'en. Dermed er
        // forbindelsen brudt i begge retninger, og ingen af siderne kan
        // komme til at læse fra den anden under frigivelsen.
        Item.CheckBox := nil;
      end;
    end;
  end;

  // -------------------------------------------------------------------------
  // TRIN 2: Nulstil hover-markør og PageControl
  // -------------------------------------------------------------------------
  // FLastHoverItem nulstilles, så ShowTweakInfo ikke kan komme til at læse
  // fra et frigivet TTweakItem (f.eks. hvis en musebeskeder stadig ligger
  // i køen og udløser en hændelse under frigivelsen).
  FLastHoverItem := nil;

  // Nulstil PageControl'ens aktive fane, så den ikke forsøger at aktivere
  // en fane, der er ved at blive frigivet. Uden dette kunne LCL sende
  // beskeder til den aktive fane under dens destruktion.
  PageControl1.ActivePage := nil;

  // -------------------------------------------------------------------------
  // TRIN 3: Frigør fanebladene BAGFRA
  // -------------------------------------------------------------------------
  // Hvorfor bagfra? Fordi PageControl1.Pages er en indekseret liste, hvor
  // indekserne ændrer sig, når et element fjernes. Hvis vi slettede forfra,
  // ville indeks 0 efter den første sletning pege på det næste element, og
  // vi ville springe halvdelen af fanebladene over. Ved at slette bagfra
  // (PageCount-1, derefter PageCount-1 igen osv.) er indekset altid gyldigt.
  // Bemærk, at frigivelsen af en TabSheet AUTOMATISK frigiver dens ScrollBox
  // og alle dens CheckBox'er, fordi LCL's ejerskabsmodel sørger for at
  // frigive børn sammen med deres forælder. Vi skal derfor IKKE frigive
  // CheckBox'erne manuelt.
  while PageControl1.PageCount > 0 do
    PageControl1.Pages[PageControl1.PageCount - 1].Free;

  // -------------------------------------------------------------------------
  // TRIN 4: Frigør TTweakItem-objekterne og selve listen
  // -------------------------------------------------------------------------
  // LCL kender intet til TTweakItem-objekterne, så vi skal frigive dem
  // manuelt. Vi tjekker igen Assigned(FTweaks), fordi den kan være nil,
  // hvis FormCreate fejlede, FØR listen blev oprettet.
  if Assigned(FTweaks) then
  begin
    // Frigør hvert enkelt tweak-objekt. Vi bruger Free (ikke FreeAndNil),
    // fordi vi lige efter frigiver hele listen og ikke længere har brug
    // for at nulstille de enkelte pointere.
    for i := 0 to FTweaks.Count - 1 do
      TTweakItem(FTweaks[i]).Free;

    // Frigør selve listen og sæt variablen til nil. FreeAndNil bruges frem
    // for blot Free, fordi det også nulstiller FTweaks, så et eventuelt
    // (fejlagtigt) dobbeltkald til FormDestroy ikke forsøger at frigive
    // en allerede frigivet liste.
    FreeAndNil(FTweaks);
  end;
end;

{ ----------------------------------------------------------------------------
  PopulateAllTweaks
  Definitionen af samtlige 46 Windows-optimeringer, organiseret i 10 kategorier.
  Hver linje forklarer nøglens placering, værdier, fordele og risici.
  ---------------------------------------------------------------------------- }
procedure TFormMain.PopulateAllTweaks;
begin
  // --- KATEGORI 0: Hurtigere Windows ---
  FTweaks.Add(TTweakItem.CreateString(0, 'Hurtigere lukning af apps ved shutdown', HKEY_CURRENT_USER,
    'Control Panel\Desktop', 'WaitToKillAppTimeout', '2000', '5000',
    'Windows venter kortere tid på, at hængende programmer lukker ned selv.',
    'Programmer med forsinket datagemning risikerer hård lukning og tab af ugemte data.'));

  FTweaks.Add(TTweakItem.CreateString(0, 'Reducer ventetid på menuer (MenuShowDelay)', HKEY_CURRENT_USER,
    'Control Panel\Desktop', 'MenuShowDelay', '20', '400',
    'Menuer og pop-ups åbner med det samme uden forsinkelse.',
    'Sættes til 20ms frem for 0 for at undgå, at visse ældre apps ignorerer værdien.'));

  FTweaks.Add(TTweakItem.CreateString(0, 'Afslut fastlåste opgaver automatisk (AutoEndTasks)', HKEY_CURRENT_USER,
    'Control Panel\Desktop', 'AutoEndTasks', '1', '0',
    'Slipper for popup-bokse der spørger om programmer skal lukkes ved shutdown.',
    'Risiko for tab af data i programmer optaget af tunge baggrundsberegninger.'));

  FTweaks.Add(TTweakItem.CreateDWord(0, 'Kør mapper i separate processer (Explorer isolation)', HKEY_CURRENT_USER,
    'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'SeparateProcess', 1, 0,
    'Isolerer Stifinder-vinduer så nedbrud i en mappe ikke crasher hele proceslinjen.',
    'Forbruger en lille smule mere RAM pr. åbent vindue.'));

  FTweaks.Add(TTweakItem.CreateDWord(0, 'Deaktiver unødvendig netværks-throttling', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile', 'NetworkThrottlingIndex', $FFFFFFFF, 10,
    'Fjerner netværksbegrænsning for spil og mediastreaming.',
    'Baggrundsopgaver kan i sjældne tilfælde få tildelt færre netværksressourcer.'));

  // --- KATEGORI 1: Sikkerhed & Privatliv ---
  FTweaks.Add(TTweakItem.CreateDWord(1, 'Deaktiver Windows Telemetri (DataCollection)', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Policies\Microsoft\Windows\DataCollection', 'AllowTelemetry', 0, 3,
    'Forhindrer Microsoft i at indsamle diagnosticerings- og telemetridata.',
    'Gør det sværere for automatiserede værktøjer at diagnosticere hardwarefejl.'));

  FTweaks.Add(TTweakItem.CreateDWord(1, 'Forhindr uautoriseret USB-lageradgang (USBSTOR)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Services\USBSTOR', 'Start', 4, 3,
    'Blokerer for tilslutning af USB-lagerenheder mod datatyveri og malware.',
    'Du kan ikke selv benytte USB-stik eller eksterne USB-diske (tastatur/mus påvirkes ikke).'));

  FTweaks.Add(TTweakItem.CreateDWord(1, 'Deaktiver Remote Registry (Fjernstyring af register)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Services\RemoteRegistry', 'Start', 4, 3,
    'Lukker for fjernadgang til at ændre computerens registreringsdatabase.',
    'Fjernfejlretning via Remote Registry-værktøjer deaktiveres.'));

  FTweaks.Add(TTweakItem.CreateDWord(1, 'Slå AutoRun / AutoPlay helt fra', HKEY_CURRENT_USER,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', $FF, $91,
    'Beskytter mod automatisk afvikling af malware fra flytbare medier.',
    'Medier skal åbnes manuelt i Stifinder.'));

  FTweaks.Add(TTweakItem.CreateDWord(1, 'Deaktiver stemmestyring over låseskærmen', HKEY_CURRENT_USER,
    'SOFTWARE\Microsoft\Speech_OneCore\Preferences', 'VoiceActivationEnableAboveLockscreen', 0, 1,
    'Forhindrer uautoriserede stemmekommandoer, når computeren er låst.',
    'Stemmestyring kan ikke benyttes før login.'));

  FTweaks.Add(TTweakItem.CreateDWord(1, 'Fjern sidst loggede ind brugernavn på låseskærm', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'DontDisplayLastUserName', 1, 0,
    'Skjuler brugernavne så udefrakommende ikke kender login-kontoen.',
    'Både brugernavn og kodeord skal indtastes manuelt hver gang.'));

  // --- KATEGORI 2: System & Ydeevne ---
  FTweaks.Add(TTweakItem.CreateHibernate(2, 'Slå dvale fra (Sletter hiberfil.sys via powercfg)',
    'Frigiver adskillige gigabyte diskplads på C-drevet svarende til computerens RAM-størrelse.',
    'Deaktiverer muligheden for dvaletilstand samt Hurtig Start (Fast Startup).'));

  FTweaks.Add(TTweakItem.CreateDWord(2, 'Deaktiver Prefetcher (Kun til SSD)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 0, 3,
    'Mindsker unødvendige skrivehandlinger på SSD-drev.',
    'Ældre legacy-programmer kan bruge marginalt længere tid ved allerførste boot.'));

  FTweaks.Add(TTweakItem.CreateDWord(2, 'Forøg forgrunds-CPU prioritet (Win32PrioritySeparation)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\PriorityControl', 'Win32PrioritySeparation', 38, 2,
    'Tildeler forgrundsvinduet en større del af processorkraften (Short Quantum, 3:1).',
    'Baggrundsprocesser som filkopiering eller scanning kan tage længere tid.'));

  FTweaks.Add(TTweakItem.CreateDWord(2, 'Slå Virtualiseringbaseret Sikkerhed (VBS) fra', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\DeviceGuard', 'EnableVirtualizationBasedSecurity', 0, 1,
    'Kan give mærkbar forbedring i FPS i tunge spil ved at reducere virtualiserings-overhead.',
    'Fjerner hardware-isoleret kernebeskyttelse mod avancerede angreb.'));

  FTweaks.Add(TTweakItem.CreateDWord(2, 'Tving Windows til at beholde kernen i RAM', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'DisablePagingExecutive', 1, 0,
    'Kernen caches i hurtig fysisk RAM frem for langsommere disk-sidefil. Kræver genstart.',
    'Kræver mindst 16 GB RAM; ellers kan hukommelsen overbelastes.'));

  FTweaks.Add(TTweakItem.CreateDWord(2, 'Slå NTFS fil-adgangsstempler fra', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\FileSystem', 'NtfsDisableLastAccessUpdate', 1, 2,
    'Forhindrer disken i konstant at opdatere tidsstempler for senest læste filer.',
    'Backup-software der afhænger af senest læst-stempel mister præcision.'));

  // --- KATEGORI 3: Netværk & Gaming ---
  FTweaks.Add(TTweakItem.CreateDWord(3, 'Prioriter spilgrafik (GPU Priority i Multimedia Tasks)', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games', 'GPU Priority', 8, 2,
    'Giver spil maksimal prioritet på GPU over almindelige baggrundsopgaver.',
    'Baggrundsgrafik og UI-animationer kan dæmpes under spil.'));

  FTweaks.Add(TTweakItem.CreateDWord(3, 'Prioriter spilprocesser (Tasks Priority)', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games', 'Priority', 6, 2,
    'Løfter scheduler-prioriteten for multimedie- og spiltråde.',
    'Baggrundsoverførsler kan forsinkes en smule under spil.'));

  FTweaks.Add(TTweakItem.CreateDWord(3, 'Tving hurtigere lukning af døde TCP-forbindelser (TcpTimedWaitDelay)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters', 'TcpTimedWaitDelay', 30, 120,
    'Frigør udtjente TCP-sockets og porte hurtigere efter tabt forbindelse.',
    'Programmer med meget ustabile forbindelser kan afbrydes hurtigere.'));

  FTweaks.Add(TTweakItem.CreateDWord(3, 'Deaktiver QoS båndbredde-reservation (NonBestEffortLimit)', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Policies\Microsoft\Windows\Psched', 'NonBestEffortLimit', 0, 20,
    'Sikrer at Windows ikke reserverer op til 20% båndbredde til systemtjenester.',
    'Kritiske baggrundstjenester har ikke garanteret båndbredde ved fuld mætning.'));

  // --- KATEGORI 4: Udvidet Sikkerhedshærdning (Del 1) ---
  FTweaks.Add(TTweakItem.CreateDWord(4, 'Tving UAC godkendelse på isoleret skrivebord', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorAdmin', 2, 5,
    'Hver administrativ handling kræver aktiv bekræftelse på det sikre skrivebord (Secure Desktop).',
    'Skærmen dæmpes oftere ved administrative ændringer.'));

  FTweaks.Add(TTweakItem.CreateDWord(4, 'Deaktiver Windows Script Host (WSH mod ransomware)', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows Script Host\Settings', 'Enabled', 0, 1,
    'Stopper ondsindede .vbs og .js scripts fra at køre via e-mail og downloads.',
    'Legitime administrative automation-scripts vil ikke kunne køre.'));

  FTweaks.Add(TTweakItem.CreateDWord(4, 'Tving sikker CTRL+ALT+DEL ved login', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'DisableCAD', 0, 1,
    'Forhindrer trojanske phishing-programmer i at efterligne Windows login-skærmen.',
    'Kræver et ekstra tryk på CTRL+ALT+DEL ved hver pålogning.'));

  FTweaks.Add(TTweakItem.CreateDWord(4, 'Tøm sidefilen (Pagefile) ved nedlukning', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'ClearPageFileAtShutdown', 1, 0,
    'Overskriver midlertidige data i sidefilen ved sluk, så adgangskoder ikke kan udlæses.',
    'Forlænger nedlukningstiden for maskinen markant.'));

  FTweaks.Add(TTweakItem.CreateDWord(4, 'Deaktiver anonym adgang til delinger (RestrictAnonymous)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Lsa', 'RestrictAnonymous', 1, 0,
    'Forhindrer uautoriserede brugere på netværket i at opsnappe kontonavne.',
    'Kan give problemer i ældre lokale netværk uden aktivt katalog.'));

  FTweaks.Add(TTweakItem.CreateDWord(4, 'Tving BitLocker til 256-bit XTS-AES kryptering (OS-drev)', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Policies\Microsoft\FVE', 'EncryptionMethodWithXtsOs', 7, 6,
    'Gennemtvinger den stærkeste 256-bit XTS-AES kryptering ved kryptering af systemdrevet.',
    'Kræver en marginal CPU-merbelastning ved diskoverførsler.'));

  FTweaks.Add(TTweakItem.CreateDWord(4, 'Deaktiver SMBv1 server-protokol (WannaCry værn)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'SMB1', 0, 1,
    'Lukker en notorisk sårbar fildelingsprotokol kendt fra WannaCry-angreb.',
    'Forhindrer adgang til meget gamle netværksdiske (NAS) og ældre printere.'));

  // --- KATEGORI 5: Sikkerhedshærdning (Del 2) ---
  FTweaks.Add(TTweakItem.CreateDWord(5, 'Bloker eksekvering af makroer fra internettet (Word)', HKEY_CURRENT_USER,
    'SOFTWARE\Policies\Microsoft\Office\16.0\word\security', 'BlockMacrosFromInternet', 1, 0,
    'Beskytter mod skadelige makroer i hentede Word-dokumenter.',
    'Kræver manuel fravælgelse, hvis legitime makroer skal afvikles.'));

  FTweaks.Add(TTweakItem.CreateDWord(5, 'Bloker Remote Desktop indkommende forbindelser (RDP)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Terminal Server', 'fDenyTSConnections', 1, 0,
    'Lukker port 3389 permanent mod udefrakommende login-forsøg.',
    'Du kan ikke selv fjernstyre maskinen via Windows Fjernskrivebord.'));

  FTweaks.Add(TTweakItem.CreateDWord(5, 'Lås computeren automatisk efter 15 minutters inaktivitet', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'InactivityTimeoutSecs', 900, 0,
    'Forhindrer uautoriseret adgang, hvis computeren forlades åben.',
    'Kan virke generende under lange læseopgaver uden mus/tastatur.'));

  FTweaks.Add(TTweakItem.CreateDWord(5, 'Bloker uautoriseret webkamera-adgang for UWP-apps', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Policies\Microsoft\Windows\AppPrivacy', 'LetAppsAccessCamera', 2, 0,
    'Forhindrer baggrunds-apps i at aktivere kameraet uden direkte tilladelse.',
    'Gælder moderne UWP apps; traditionelle Win32-apps styres via egne indstillinger.'));

  FTweaks.Add(TTweakItem.CreateDWord(5, 'Bloker uautoriseret mikrofon-adgang for UWP-apps', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Policies\Microsoft\Windows\AppPrivacy', 'LetAppsAccessMicrophone', 2, 0,
    'Beskytter mod utilsigtet aflytning fra moderne Windows-apps.',
    'Opkalds- og mødeapps kan ikke tilgå mikrofonen før tilladelse tildeles.'));

  // --- KATEGORI 6: Privatliv & Telemetri ---
  FTweaks.Add(TTweakItem.CreateDWord(6, 'Slå Bing-søgninger fra i Start-menuen', HKEY_CURRENT_USER,
    'SOFTWARE\Policies\Microsoft\Windows\Explorer', 'DisableSearchBoxSuggestions', 1, 0,
    'Lokal søgning efter filer og apps bliver markant hurtigere og fri for net-annoncer.',
    'Ingen live web-resultater direkte i Start-menuens søgefelt.'));

  FTweaks.Add(TTweakItem.CreateDWord(6, 'Deaktiver personligt reklame-ID', HKEY_CURRENT_USER,
    'Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo', 'Enabled', 0, 1,
    'Forhindrer annoncører i at spore din brugeradfærd på tværs af apps.',
    'Annoncer i gratis apps vil være helt generiske.'));

  FTweaks.Add(TTweakItem.CreateDWord(6, 'Slå reklameforslag fra på låseskærmen', HKEY_CURRENT_USER,
    'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager', 'SubscribedContent-338387Enabled', 0, 1,
    'Fjerner uønskede app- og spil-forslag på din låseskærm.',
    'Daglige dynamiske Bing-baggrunde vises ikke.'));

  FTweaks.Add(TTweakItem.CreateDWord(6, 'Slå lokationssporing helt fra på systemniveau', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors', 'DisableLocation', 1, 0,
    'Stopper baggrundsbrug af sensorer og GPS-lokationstjenester.',
    'Vejr- og kort-apps finder ikke din position automatisk.'));

  FTweaks.Add(TTweakItem.CreateDWord(6, 'Slå feedback-påmindelser permanent fra', HKEY_CURRENT_USER,
    'Software\Microsoft\Siuf\Rules', 'NumberOfHeartbeatsAllowed', 0, 1,
    'Slipper for popup-vinduer der spørger om din mening om Windows.',
    'Ingen ulemper.'));

  FTweaks.Add(TTweakItem.CreateDWord(6, 'Forhindr automatisk installation af promoverede apps', HKEY_CURRENT_USER,
    'Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager', 'SilentInstalledAppsEnabled', 0, 1,
    'Stopper Windows i automatisk at hente spil som Candy Crush i baggrunden.',
    'Ingen ulemper.'));

  FTweaks.Add(TTweakItem.CreateEmptyKey(6, 'Tving klassisk Windows 10 højrekliksmenu (Win 11)', HKEY_CURRENT_USER,
    'Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32',
    'Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32',
    'Gør højreklik i Stifinder hurtigere ved altid at vise den fulde menu direkte.',
    'Du mister Windows 11-menuens kompakte hurtigknapper i toppen.'));

  // --- KATEGORI 7: Avanceret Kerne & GPU ---
  FTweaks.Add(TTweakItem.CreateDWord(7, 'Lås op for CPU Core Parking i Strømstyring (Gør synlig)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583', 'Attributes', 2, 1,
    'Gør den skjulte indstilling for parkering af CPU-kerner synlig under Avanceret Strømstyring i Kontrolpanel.',
    'Gør kun indstillingen synlig; du skal selv sætte procenten til 100% i kontrolpanelet.'));

  FTweaks.Add(TTweakItem.CreateDWord(7, 'Aktiver hardwareaccelereret GPU-skemalægning (HAGS)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\GraphicsDrivers', 'HwSchMode', 2, 1,
    'Lader grafikkortet styre sin egen hukommelse, hvilket reducerer CPU-flaskehals.',
    'Kan på enkelte ældre GPU-drivere give mikro-stuttering.'));

  FTweaks.Add(TTweakItem.CreateDWord(7, 'Forøg LargeSystemCache (Filcache i RAM)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'LargeSystemCache', 1, 0,
    'Afsætter mere RAM til fildata for hurtigere åbning af store filer. Kræver genstart.',
    'Bør kun bruges på maskiner med 16 GB RAM eller mere.'));

  FTweaks.Add(TTweakItem.CreateDWord(7, 'Deaktiver Windows Error Reporting (WER)', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\Windows Error Reporting', 'Disabled', 1, 0,
    'Frigør CPU-ressourcer ved nedbrud frem for at uploade telemetridumps.',
    'Microsoft modtager ikke fejlrapporter til generelle fejlrettelser.'));

  FTweaks.Add(TTweakItem.CreateDWord(7, 'Deaktiver 8.3 kort filnavneoprettelse (NtfsDisable8dot3NameCreation)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\FileSystem', 'NtfsDisable8dot3NameCreation', 1, 2,
    'Optimerer mappeydeevne på NTFS ved at droppe ældre DOS-navne.',
    'Meget gamle 16-bit eller tidlige 32-bit legacy-programmer kan fejle.'));

  // --- KATEGORI 8: Hardware & Strømstyring ---
  FTweaks.Add(TTweakItem.CreateDWord(8, 'Lås op for PCIe Link State strømstyring (Gør synlig)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Power\PowerSettings\501a4d13-42af-4429-9fd1-a8218c268e20\ee12f251-da30-4e08-94b5-2b35a669d9c2', 'Attributes', 2, 1,
    'Gør PCIe dvaletilstand synlig i Strømstyring, så du kan slå strømsparemode fra på grafikkort og NVMe.',
    'Kræver at du efterfølgende vælger "Slået fra" under strømplanen.'));

  FTweaks.Add(TTweakItem.CreateDWord(8, 'Lås op for mekanisk harddisk-nedlukning (Gør synlig)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Power\PowerSettings\0012ee47-9041-4b5d-9b77-535fba8b1442\6738e2c6-ee1b-478f-911d-3147596db1d4', 'Attributes', 2, 1,
    'Gør indstillingen for harddisk-timeout synlig, så du kan forhindre mekaniske diske i at gå i dvale.',
    'Kræver at du manuelt sætter tiden til "0 minutter" (Aldrig) i Kontrolpanel.'));

  FTweaks.Add(TTweakItem.CreateDWord(8, 'Deaktiver Diagnostics Tracking Service (DiagTrack)', HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Services\DiagTrack', 'Start', 4, 2,
    'Stopper permanent Microsofts diagnosticerings-overvågning.',
    'Visse automatiske fejlfindere i Kontrolpanel virker ikke fuldt ud.'));

  // --- KATEGORI 9: UI & Systemstrømlining ---
  FTweaks.Add(TTweakItem.CreateDWord(9, 'Fjern Widget-panelet helt (Windows 11)', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Policies\Microsoft\Dsh', 'AllowWidgets', 0, 1,
    'Fjerner widgets fra proceslinjen og sparer betydelig baggrunds-RAM.',
    'Vejr- og nyhedspanel kan ikke tilgås.'));

  FTweaks.Add(TTweakItem.CreateDWord(9, 'Åbn altid Stifinder i "Denne pc" frem for "Hjem"', HKEY_CURRENT_USER,
    'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'LaunchTo', 1, 2,
    'Stifinder åbner lynhurtigt i den traditionelle drevoversigt.',
    'Nyligt åbnede filer og mapper vises ikke ved første åbning.'));

  FTweaks.Add(TTweakItem.CreateString(9, 'Slå Sticky Keys pop-up fra ved spil (Flags=506)', HKEY_CURRENT_USER,
    'Control Panel\Accessibility\StickyKeys', 'Flags', '506', '510',
    'Forhindrer popup-advarslen, hvis der trykkes hurtigt 5 gange på Shift under spil.',
    'Tilgængelighedsfunktionen aktiveres ikke automatisk via tastaturgenvej.'));

  FTweaks.Add(TTweakItem.CreateDWord(9, 'Deaktiver Windows opstartslyd', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI', 'DisableStartupSound', 1, 0,
    'Maskinen starter altid lydløst op uden chok i f.eks. mødelokaler.',
    'Ingen auditiv bekræftelse på logon.'));

  FTweaks.Add(TTweakItem.CreateString(9, 'Fjern "3D-objekter" mappen fra Denne PC (ThisPCPolicy)', HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag',
    'ThisPCPolicy', 'Hide', 'Show',
    'Fjerner 3D-objekter mappen i Stifinder under Denne pc på en sikker og officiel måde.',
    'Ingen mærkbare ulemper.'));
end;

{ ----------------------------------------------------------------------------
  BuildUI
  Formål:
    At generere hele den dynamiske brugergrænseflade fra bunden – dvs. skabe
    de 10 faneblade, et rullepanel på hvert faneblad og et afkrydsningsfelt
    for hver af de 46 tweaks – udelukkende baseret på data i FTweaks-listen
    og de faste kategorier i CAT_NAMES.

  Hvorfor er brugerfladen dynamisk?
    Man kunne i princippet have designet alle 46 afkrydsningsfelter manuelt i
    Lazarus' formular-editor. Men det ville være ekstremt arbejdskrævende og
    fejlbehæftet:
      - Hver CheckBox skulle navngives, placeres og forbindes med hændelser
        manuelt – 46 gange, med risiko for tastefejl ved hvert eneste felt.
      - Hvis man senere ville tilføje, fjerne eller flytte et tweak, skulle
        både FTweaks-listen og formularen ændres.
      - Ved høj DPI eller forskellige skærmopløsninger skulle positionerne
        justeres manuelt, hvilket næsten altid giver skæve layouts.
    Ved at generere UI'en programmatisk opnås en enkelt kilde til sandhed:
    FTweaks-listen definerer ALT. Tilføjer man et nyt tweak til listen, dukker
    det automatisk op i brugerfladen på det rigtige faneblad uden yderligere
    ændringer. Det er den samme tilgang, som professionelle administrations-
    værktøjer som f.eks. Microsofts egne Group Policy-editorer anvender.

  Hvordan funktionen virker (algoritmen):
    1. Ryd op: Frigør eksisterende faneblade (bagfra), så funktionen kan
       kaldes igen uden at efterlade gamle komponenter.
    2. For hver af de 10 kategorier (0-9):
       a. Opret et nyt TTabSheet (faneblad) og sæt dets overskrift fra
          CAT_NAMES. Gem kategoriindekset i Tab.Tag, så BtnApplyCurrentTabClick
          og BtnRestoreCurrentTabClick senere kan afgøre, hvilken kategori
          der er aktiv.
       b. Opret en TScrollBox, der fylder hele fanebladet og giver mulighed
          for at rulle, hvis der er flere tweaks, end der kan være på skærmen.
       c. Gennemløb hele FTweaks-listen og find de tweaks, hvis CategoryIndex
          matcher den aktuelle kategori. For hvert match oprettes et TCheckBox
          med den korrekte overskrift, position og hændelsesforbindelser.
       d. Forøg TopOffset med 32 pixels for hvert nyt felt, så felterne
          stables lodret uden overlap.
    3. Vælg det første faneblad som aktivt, så brugeren altid møder en
       meningsfuld startskærm.

  Hvorfor oprettes ScrollBox med Tab som forælder?
    Ved at angive Tab som forælder ved TScrollBox.Create sikres det, at
    ScrollBox automatisk frigives, når TabSheet frigives. Dette er LCL's
    ejerskabsmodel: Børn frigives sammen med deres forælder. Uden dette
    ville vi skulle frigive hver ScrollBox manuelt, hvilket er både
    fejlbehæftet og unødvendigt kompliceret.

  Hvorfor sættes CB.Parent FØR CB.Anchors?
    Dette er en subtil, men vigtig detalje. Anchors-egenskaben fungerer ved,
    at LCL beregner afstanden fra komponentens kanter til forælderens kanter
    PÅ DET TIDSPUNKT, hvor Anchors sættes. Hvis CB.Parent er nil på det
    tidspunkt, findes der ingen forældrekanter at måle imod, og forankringen
    vil være forkert eller helt uden effekt. Ved at sætte Parent først sikres
    det, at forankringen beregnes korrekt.

  Hvorfor akTop, akLeft, akRight – men ikke akBottom?
    Formålet er, at hvert afkrydsningsfelt skal strække sig fra venstre mod
    højre kant, så det fylder hele bredden uanset vinduets størrelse. Men
    højden skal forblive fast (én tekstlinje), så felterne ikke vokser
    lodret, når vinduet gøres højere. Derfor forankres kun top, venstre og
    højre – ikke bund. Dermed følger felterne med, når vinduet gøres bredere,
    men beholder deres højde uanset vindueshøjden.

  Hvorfor 32 pixels mellemrum mellem felterne?
    Med Segoe UI i 10 punkters størrelse er én tekstlinje typisk omkring
    20-22 pixels høj. Et mellemrum på 32 pixels giver en behagelig luft
    mellem felterne, så teksten ikke føles sammenklemt, og så der er plads
    til, at musen nemt kan ramme det rigtige felt. Tallet er valgt som et
    kompromis mellem tæthed (flere felter synligt ad gangen) og læsbarhed.

  Hvorfor gemmes kategoriindekset i Tab.Tag?
    Tab.Tag er et heltal, som LCL stiller til rådighed for applikations-
    specifik brug. Ved at gemme kategoriindekset her kan BtnApplyCurrentTabClick
    og BtnRestoreCurrentTabClick nemt afgøre, hvilken kategori brugeren
    befinder sig på, uden at skulle slå det op i CAT_NAMES via fanens
    overskrift. Dette er både hurtigere og mere robust over for ændringer
    i overskrifterne.

  Hvorfor gemmes Item-referencen i CB.Tag via PtrInt?
    CB.Tag er af typen PtrInt, som er et heltal stort nok til at rumme en
    pointer på både 32- og 64-bit systemer. Ved at caste TTweakItem-pointeren
    til PtrInt og gemme den i Tag kan CheckBoxClick, CheckBoxMouseMove og
    CheckBoxEnter senere hente tweak-objektet direkte tilbage med et enkelt
    cast. Dette er den idiomatiske måde at koble en visuel komponent til et
    logisk objekt i Delphi/Lazarus, og det undgår en dyr opslagning i
    FTweaks-listen ved hvert museklik.

    Bemærk, at dette skaber en cirkulær reference: Item.CheckBox peger på
    CB, og CB.Tag peger på Item. Denne cirkulære reference brydes i FormDestroy
    (trin 1), netop for at undgå use-after-free under nedlukningen.

  Hvorfor frigives eksisterende faneblade bagfra?
    Samme grund som i FormDestroy: PageControl1.Pages er en indekseret liste,
    og indeksene ændrer sig, når et element fjernes. Hvis vi slettede forfra,
    ville indeks 0 efter den første sletning pege på det næste element, og vi
    ville springe halvdelen af fanebladene over. Ved at slette bagfra er
    indekset altid gyldigt.

  Hvorfor kaldes BuildUI overhovedet igen?
    I den nuværende version kaldes BuildUI kun én gang (fra FormCreate). Men
    funktionen er designet til at kunne kaldes igen, f.eks. hvis programmet
    på et tidspunkt får en funktion til at "gendanne standardvisning" eller
    skifte sprog. Ved at rydde op først undgås det, at gamle faneblade
    hobes op, og at CheckBox-referencerne i TTweakItem peger på frigivne
    komponenter.

  Anvendelse i programmet:
    BuildUI kaldes udelukkende fra FormCreate, umiddelbart efter
    PopulateAllTweaks og umiddelbart før ReadRegistryStatus:
      PopulateAllTweaks;  // Fyld FTweaks-listen
      BuildUI;            // Byg brugerfladen ud fra listen
      ReadRegistryStatus; // Sæt flueben ud fra registreringsdatabasen
    Rækkefølgen er afgørende: PopulateAllTweaks skal køre først, ellers har
    BuildUI ingen data at bygge ud fra. ReadRegistryStatus skal køre sidst,
    fordi den opdaterer de CheckBox-referencer, som BuildUI netop har oprettet.

  Kendt begrænsning:
    Funktionen antager, at CAT_NAMES og TTweakItem.CategoryIndex er konsistente
    – dvs. at hvert tweak har en CategoryIndex mellem 0 og High(CAT_NAMES).
    Hvis et tweak ved en fejl tildeles en ugyldig kategori, vil det ganske
    vist ikke blive vist nogen steder, men det vil heller ikke forårsage en
    crash. Dette er et bevidst valg: En manglende visning er lettere at
    opdage end en crash, og det bevarer programmets stabilitet, selv hvis
    data skulle være inkonsistente.
  ---------------------------------------------------------------------------- }
procedure TFormMain.BuildUI;
var
  i, j: Integer;            // Løbeindeks: i = kategori (0-9), j = tweak-indeks
  Tab: TTabSheet;           // Det aktuelle faneblad under opbygning
  ScrollBox: TScrollBox;    // Rullepanel på det aktuelle faneblad
  Item: TTweakItem;         // Det aktuelle tweak-objekt under gennemløb
  CB: TCheckBox;            // Det afkrydsningsfelt, der oprettes
  TopOffset: Integer;       // Lodret position (i pixels) for næste felt
begin
  // -------------------------------------------------------------------------
  // TRIN 1: Ryd op – frigør eksisterende faneblade
  // -------------------------------------------------------------------------
  // Nulstil den aktive fane, så PageControl ikke forsøger at aktivere en
  // fane, der er ved at blive frigivet.
  PageControl1.ActivePage := nil;

  // Frigør eksisterende faner bagfra (se begrundelse i kommentaren ovenfor).
  // Dette gør funktionen idempotent: Den kan kaldes gentagne gange uden at
  // efterlade gamle komponenter.
  while PageControl1.PageCount > 0 do
    PageControl1.Pages[PageControl1.PageCount - 1].Free;

  // -------------------------------------------------------------------------
  // TRIN 2: Opret faneblade og felter for hver kategori
  // -------------------------------------------------------------------------
  // Gennemløb de 10 kategorier i CAT_NAMES. High(CAT_NAMES) returnerer 9,
  // så løkken kører fra 0 til 9 – præcis de 10 kategorier.
  for i := 0 to High(CAT_NAMES) do
  begin
    // Opret et nyt faneblad og sæt dets overskrift fra CAT_NAMES.
    Tab := PageControl1.AddTabSheet;
    Tab.Caption := CAT_NAMES[i];

    // Gem kategoriindekset i fanens Tag-egenskab, så BtnApplyCurrentTabClick
    // og BtnRestoreCurrentTabClick senere kan afgøre, hvilken kategori
    // brugeren befinder sig på.
    Tab.Tag := i;

    // Opret rullefeltet, der fylder hele fanebladet. Tab angives som
    // forælder, så ScrollBox automatisk frigives sammen med fanebladet.
    ScrollBox := TScrollBox.Create(Tab);

    // Align := alClient får ScrollBox til at fylde hele fanebladets areal
    // og følge med, når vinduet ændrer størrelse.
    ScrollBox.Align := alClient;

    // bsNone fjerner den ellers synlige kant omkring rullefeltet, så det
    // smelter sammen med fanebladets baggrund og ser mere professionelt ud.
    ScrollBox.BorderStyle := bsNone;

    // AutoScroll sikrer, at der automatisk vises rullebjælker, hvis indholdet
    // bliver højere, end der er plads til. Uden dette ville tweaks i bunden
    // være utilgængelige på små skærme.
    ScrollBox.AutoScroll := True;

    // Parent sættes eksplicit, fordi ScrollBox er oprettet med Tab som ejer,
    // men LCL kræver, at Parent også sættes, før komponenten vises korrekt.
    ScrollBox.Parent := Tab;

    // Startposition for det første felt: 12 pixels fra toppen giver en
    // behagelig luft over det første afkrydsningsfelt.
    TopOffset := 12;

    // Gennemløb alle tweaks i FTweaks-listen og find dem, der hører til
    // den aktuelle kategori (Item.CategoryIndex = i). For hvert match
    // oprettes et afkrydsningsfelt.
    for j := 0 to FTweaks.Count - 1 do
    begin
      Item := TTweakItem(FTweaks[j]);
      if Item.CategoryIndex = i then
      begin
        // Opret selve afkrydsningsfeltet med ScrollBox som forælder, så
        // det automatisk frigives sammen med rullefeltet.
        CB := TCheckBox.Create(ScrollBox);

        // Fast venstremargen på 16 pixels giver et ensartet udseende for
        // alle felter på alle faneblade.
        CB.Left := 16;

        // Lodret position bestemmes af TopOffset, som forøges med 32 for
        // hvert nyt felt (se nedenfor).
        CB.Top := TopOffset;

        // AutoSize lader LCL beregne den nødvendige bredde og højde ud fra
        // tekstens længde og skrifttypen. Uden dette ville lange titler
        // blive klippet af.
        CB.AutoSize := True;

        // VIGTIGT: Parent sættes FØR Anchors. Anchors beregnes relativt
        // til forælderens kanter, så forælderen skal være sat først.
        CB.Parent := ScrollBox;

        // Forankr top, venstre og højre – men IKKE bund. Dermed strækker
        // feltet sig til højre kant, når vinduet gøres bredere, men beholder
        // sin faste højde uanset vindueshøjden.
        CB.Anchors := [akTop, akLeft, akRight];

        // Sæt overskriften fra tweak-objektet. Dette er den tekst, brugeren
        // ser ud for afkrydsningsfeltet.
        CB.Caption := Item.Title;

        // Anvend Segoe UI i 10 punkters størrelse – Windows' standardskrift
        // for moderne applikationer. Giver et rent og tidssvarende udseende.
        CB.Font.Name := 'Segoe UI';
        CB.Font.Size := 10;

        // Kobl CheckBox'en direkte til tweak-objektet ved at gemme dets
        // pointer i Tag-egenskaben. PtrInt-castet gør det muligt at gemme
        // en 64-bit pointer i et heltal på både 32- og 64-bit systemer.
        CB.Tag := PtrInt(Item);

        // Forbind de tre hændelser, der gør feltet interaktivt:
        //   OnMouseMove : Vis fordele/ulemper i infopanelet ved hover.
        //   OnEnter     : Samme visning, når feltet får fokus via Tab-tasten.
        //   OnClick     : Skriv ændringen til registreringsdatabasen.
        CB.OnMouseMove := @CheckBoxMouseMove;
        CB.OnEnter := @CheckBoxEnter;
        CB.OnClick := @CheckBoxClick;

        // Gem en reference tilbage til CheckBox'en i tweak-objektet, så
        // ReadSingleTweakStatus og SetTweakInRegistry kan opdatere fluebenet
        // uden at skulle søge i FTweaks-listen.
        Item.CheckBox := CB;

        // Flyt den lodrette position 32 pixels ned til næste felt. 32 pixels
        // giver en behagelig afstand mellem felterne med Segoe UI 10.
        Inc(TopOffset, 32);
      end;
    end;
  end;

  // -------------------------------------------------------------------------
  // TRIN 3: Vælg det første faneblad som aktivt
  // -------------------------------------------------------------------------
  // Hvis der blev oprettet mindst ét faneblad, aktiveres det første, så
  // brugeren altid møder en meningsfuld startskærm (og ikke en tom
  // PageControl). Kontrollen er teknisk set overflødig, fordi CAT_NAMES
  // altid har 10 elementer, men den beskytter mod fremtidige ændringer,
  // hvor CAT_NAMES måtte blive gjort konfigurerbar eller tom.
  if PageControl1.PageCount > 0 then
    PageControl1.ActivePageIndex := 0;
end;

{ ----------------------------------------------------------------------------
  ReadSingleTweakStatus
  Formål:
    At undersøge Windows-registreringsdatabasen (eller i ét tilfælde Windows'
    strømstyring) for ét enkelt tweak og opdatere dets afkrydsningsfelt, så det
    afspejler computerens FAKTISKE tilstand: Checked := True, hvis tweaket er
    aktivt, og Checked := False, hvis det ikke er.

  Hvorfor er denne procedure så vigtig?
    Programmet må aldrig vise et flueben, der ikke svarer til virkeligheden.
    Hvis brugeren ser et flueben ud for "Deaktiver Windows Telemetri" og tror,
    at telemetri er slået fra, men det i virkeligheden er slået til, har
    programmet givet en falsk tryghed. Derfor aflæses den reelle tilstand fra
    registreringsdatabasen – ikke fra en cache eller en husket værdi.

    Proceduren bruges i tre sammenhænge:
      1. Ved opstart (via ReadRegistryStatus), hvor ALLE tweaks aflæses.
      2. Efter et klik på en CheckBox, hvor det netop ændrede tweak
         verificeres, så brugeren ser, om Windows faktisk accepterede
         ændringen.
      3. Efter batch-handlinger (Anvend alle/Gendan alle), hvor hvert enkelt
         tweak aflæses igen for at bekræfte resultatet.

  De fire typer tweaks – og hvorfor de håndteres forskelligt:
    A. vkDWord  : Et 32-bit heltal i registreringsdatabasen (REG_DWORD).
                  Aflæses ved at sammenligne værdien med OptimizedDWord.
    B. vkString : En tekststreng (REG_SZ / REG_EXPAND_SZ).
                  Aflæses ved at sammenligne teksten med OptimizedStr.
    C. vkEmptyKey: Nøglens blotte EKSISTENS er tweaket.
                  Aflæses med Reg.KeyExists.
    D. vkHibernate: Dvale styres IKKE af en registreringsværdi, men af
                  Windows' strømstyringskerne. Derfor en helt særlig
                  håndtering med powercfg.exe og hiberfil.sys.

  Hvorfor tvinges 64-bit visning (KEY_WOW64_64KEY)?
    På 64-bit Windows har mange nøgler to parallelle visninger: én for 32-bit
    programmer og én for 64-bit programmer. Uden KEY_WOW64_64KEY ville et
    32-bit program (eller et program, der ved en fejl blev bygget som 32-bit)
    læse fra den forkerte visning og dermed se forkerte værdier. Ved altid at
    tilføje KEY_WOW64_64KEY sikres det, at vi læser præcis den samme nøgle,
    som systemets egne 64-bit værktøjer (f.eks. regedit) arbejder med.
    På 32-bit Windows ignoreres flaget, så koden er kompatibel med begge.

  Hvorfor valideres datatyper (RegDataType)?
    Registreringsdatabasen er ikke typestærk. En værdi, der burde være et
    DWORD, kan i praksis være gemt som en tekststreng – f.eks. hvis brugeren
    har importeret en .reg-fil fra en anden kilde, eller hvis et tredjeparts
    værktøj har skrevet værdien forkert. Hvis vi blot kaldte Reg.ReadInteger
    uden at tjekke typen, ville vi få en ERegistryException, som ville
    afbryde hele opstartssekvensen. Ved at validere typen først (og falde
    tilbage til rdBinary-håndtering) undgås dette.

  Hvorfor håndteres rdBinary som et DWORD?
    Nogle værktøjer (f.eks. ældre Microsoft-værktøjer og visse scripts) skriver
    DWORD-værdier som rå binære 4-byte værdier i stedet for som ægte REG_DWORD.
    Windows selv behandler dem som ækvivalente, og det bør vi også gøre. Ved
    at læse de 4 bytes ind i en Cardinal og sammenligne med OptimizedDWord
    opnås samme resultat som for ægte rdInteger.

  Hvorfor bruges Cardinal frem for Integer til DWVal?
    Værdien $FFFFFFFF (4.294.967.295) er en gyldig DWORD-værdi (f.eks. for
    NetworkThrottlingIndex, hvor den betyder "deaktiveret"). Hvis man brugte
    Integer, ville den blive fortolket som -1, og sammenligningen med
    OptimizedDWord (som er Cardinal) ville fejle. Ved at bruge Cardinal
    (32-bit uden fortegn) gennem hele kæden undgås denne subtile fejl.

  Hvorfor bruges SameText til tekstsammenligning?
    Registreringsdatabasen er ikke følsom over for store/små bogstaver, og
    det er Windows' egne indstillinger heller ikke. Hvis vi sammenlignede
    med den præcise streng 'Hide', men brugeren har skrevet 'hide', ville
    fluebenet mangle – selv om Windows selv anser de to værdier for identiske.
    SameText sammenligner uden hensyn til store/små bogstaver og giver
    dermed det korrekte resultat.

  Hvorfor håndteres en tom OptimizedStr specielt?
    For nogle tweaks er den optimerede tilstand, at værdien slet ikke
    eksisterer (f.eks. 'ThisPCPolicy' = '' betyder, at Windows viser mappen).
    I så fald er IsOpt = True, netop når værdien IKKE findes i registret.
    Uden dette specialtilfælde ville vi sammenligne med en tom streng, hvilket
    ville give forkert resultat.

  Hvorfor bruges FUpdatingUI som event-guard?
    Når vi sætter Item.CheckBox.Checked := IsOpt, udløser LCL normalt
    OnClick-hændelsen. Hvis vi ikke blokerede dette, ville CheckBoxClick
    blive kaldt, og den ville forsøge at skrive værdien til registret – hvilket
    er både overflødigt og potentielt skadeligt (f.eks. kunne det overskrive
    en værdi, brugeren lige har ændret manuelt). Ved at sætte FUpdatingUI
    til True under opdateringen og tilbage til False bagefter sikres det, at
    CheckBoxClick straks returnerer uden at gøre noget.

  Hvorfor try/finally omkring FUpdatingUI?
    Hvis der opstår en undtagelse mellem FUpdatingUI := True og
    FUpdatingUI := False (f.eks. hvis Item.CheckBox er blevet frigivet),
    ville flaget forblive True for evigt, og alle efterfølgende klik ville
    blive ignoreret. Ved at sætte FUpdatingUI := False i en finally-blok
    garanteres det, at flaget altid nulstilles korrekt.

  Anvendelse i programmet:
    Proceduren kaldes fra:
      - ReadRegistryStatus        (ved opstart, for alle tweaks)
      - CheckBoxClick             (efter en ændring, for ét tweak)
      - BtnApplyCurrentTabClick   (efter batch-aktivering)
      - BtnRestoreCurrentTabClick (efter batch-gendannelse)
      - MenuApplyAllClick         (efter "Anvend alle")
    Overalt bruges den til at verificere, at den faktiske tilstand stemmer
    overens med den forventede, og til at opdatere brugerfladen i overens-
    stemmelse hermed.
  ---------------------------------------------------------------------------- }
procedure TFormMain.ReadSingleTweakStatus(Item: TTweakItem);
var
  Reg: TRegistry;              // Registry-adgangsobjekt til aflæsning
  DWVal: Cardinal;             // Midlertidig DWORD-værdi (uden fortegn, så $FFFFFFFF håndteres korrekt)
  IsOpt: Boolean;              // Resultatet: er tweaket i sin optimerede tilstand?
  FoundInReg: Boolean;         // Bruges kun for dvale: blev status fundet i registret?
  PowerOut: String;            // Output fra powercfg.exe (bruges kun for dvale)
  RegDataType: TRegDataType;   // Den faktiske datatype i registret (rdInteger, rdString osv.)
begin
  // Sikkerhedstjek: Hvis tweaket ikke har et afkrydsningsfelt (f.eks. fordi
  // BuildUI fejlede halvvejs), er der intet at opdatere, og vi springer over.
  // Dette forhindrer en adgangsfejl på nil-pointere.
  if Item.CheckBox = nil then Exit;

  // =========================================================================
  // SÆRTILFÆLDE: vkHibernate (Windows' dvalefunktion)
  // =========================================================================
  // Dvale styres IKKE via en simpel registreringsværdi, men af Windows'
  // strømstyringskerne. Derfor skal tilstanden aflæses på en helt anden måde
  // end de øvrige tweaks. Vi forsøger først at læse HibernateEnabled fra
  // registret, men falder tilbage til hiberfil.sys og powercfg, hvis den
  // ikke findes (hvilket er tilfældet på nogle Windows-versioner).
  if Item.ValKind = vkHibernate then
  begin
    IsOpt := False;       // Antag som udgangspunkt, at dvale er slået TIL
    FoundInReg := False;  // Endnu ikke fundet i registret

    // Opret en TRegistry til aflæsning (kun læseadgang, 64-bit visning).
    Reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;

      // Forsøg at åbne strømstyringsnøglen, hvor HibernateEnabled gemmes.
      if Reg.OpenKeyReadOnly('SYSTEM\CurrentControlSet\Control\Power') then
      begin
        if Reg.ValueExists('HibernateEnabled') then
        begin
          // Værdien 0 betyder, at dvale er DEAKTIVERET – hvilket er vores
          // optimerede tilstand (vi vil jo spare diskplads). Derfor sættes
          // IsOpt til True, når værdien er 0.
          IsOpt := (Reg.ReadInteger('HibernateEnabled') = 0);
          FoundInReg := True;
        end;
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;

    // Hvis HibernateEnabled ikke fandtes i registret (hvilket sker på visse
    // Windows-versioner og i visse konfigurationer), må vi undersøge sagen
    // på anden vis. To metoder anvendes:
    //   1. Tjek om filen C:\hiberfil.sys eksisterer. Hvis ikke, er dvale
    //      helt slået fra (fordi Windows sletter filen, når dvale deaktiveres).
    //   2. Spørg powercfg.exe om, hvilke dvaletilstande der er tilgængelige.
    if not FoundInReg then
    begin
      if not FileExists('C:\hiberfil.sys') then
        // Filen findes ikke → dvale er deaktiveret → vores optimerede tilstand.
        IsOpt := True
      else
      begin
        // Filen findes, men vi ved endnu ikke, om dvale er slået til.
        // Spørg powercfg.exe /a, som lister alle tilgængelige dvaletilstande.
        // Hvis 'Hibernate' eller 'Dvale' optræder i outputtet, er dvale aktiv.
        StatusBar1.SimpleText := 'Undersøger dvalestatus (powercfg)...';
        Application.ProcessMessages;  // Lad statusbaren nå at tegne, før vi venter
        RunCommandCapture(GetSafeSystemPath('powercfg.exe'), ['/a'], PowerOut);

        // Hvis hverken den engelske eller danske betegnelse findes i outputtet,
        // er dvale ikke aktiv.
        IsOpt := (Pos('(Hibernate)', PowerOut) = 0) and (Pos('(Dvale)', PowerOut) = 0);
      end;
    end;

    // Opdater CheckBox'en under beskyttelse af event-guard, så OnClick ikke
    // udløses (hvilket ville forsøge at skrive til registret og dermed
    // muligvis ændre brugerens indstilling utilsigtet).
    FUpdatingUI := True;
    try
      Item.CheckBox.Checked := IsOpt;
    finally
      FUpdatingUI := False;
    end;

    // Afslut proceduren – dvale er et specialtilfælde, og resten af
    // proceduren (standard registeraflæsning) skal ikke køres.
    Exit;
  end;

  // =========================================================================
  // STANDARD REGISTERAFLÆSNING (vkDWord, vkString, vkEmptyKey)
  // =========================================================================
  // Opret en TRegistry med læseadgang og 64-bit visning.
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  try
    // Sæt rod-nøglen fra tweak-objektet (HKEY_CURRENT_USER eller HKEY_LOCAL_MACHINE).
    Reg.RootKey := Item.RootKey;
    IsOpt := False;  // Antag som udgangspunkt, at tweaket IKKE er aktivt

    // --- Type C: vkEmptyKey (nøglens blotte eksistens) ---
    // Her er tweaket aktivt, netop når nøglen findes i registret.
    if Item.ValKind = vkEmptyKey then
    begin
      IsOpt := Reg.KeyExists(Item.SubKey);
    end
    // --- Type A og B: vkDWord og vkString ---
    // For disse typer skal vi åbne nøglen og læse en konkret værdi.
    else if Reg.OpenKeyReadOnly(Item.SubKey) then
    begin
      try
        // Undersøg hvilken datatype tweaket har, og læs værdien tilsvarende.
        case Item.ValKind of
          // ----- Type A: vkDWord (32-bit heltal) -----
          vkDWord:
            if Reg.ValueExists(Item.ValueName) then
            begin
              RegDataType := Reg.GetDataType(Item.ValueName);

              // Ægte REG_DWORD: læs direkte som heltal.
              // Cast til Cardinal for at undgå signed/unsigned-fejl ved $FFFFFFFF.
              if RegDataType = rdInteger then
              begin
                DWVal := Cardinal(Reg.ReadInteger(Item.ValueName));
                IsOpt := (DWVal = Item.OptimizedDWord);
              end
              // REG_BINARY: læs 4 bytes ind i DWVal og sammenlign på samme måde.
              // Dette håndterer værktøjer, der skriver DWORD-værdier som binære data.
              else if RegDataType = rdBinary then
              begin
                DWVal := 0;
                Reg.ReadBinaryData(Item.ValueName, DWVal, SizeOf(DWVal));
                IsOpt := (DWVal = Item.OptimizedDWord);
              end;
              // Andre datatyper ignoreres: tweaket betragtes som ikke-aktivt.
            end;

          // ----- Type B: vkString (tekststreng) -----
          vkString:
            // Specialtilfælde: Hvis den optimerede værdi er den tomme streng,
            // betyder det, at tweaket er aktivt, netop når værdien IKKE findes.
            if Item.OptimizedStr = '' then
              IsOpt := not Reg.ValueExists(Item.ValueName)
            else
            begin
              if Reg.ValueExists(Item.ValueName) then
              begin
                RegDataType := Reg.GetDataType(Item.ValueName);

                // Acceptér både rdString (almindelig tekst) og rdExpandString
                // (tekst med miljøvariabler som %USERPROFILE%), fordi Windows
                // behandler dem ækvivalent i denne sammenhæng.
                if RegDataType in [rdString, rdExpandString] then
                  // SameText: sammenlign uden hensyn til store/små bogstaver,
                  // så 'hide' og 'Hide' betragtes som identiske (som Windows gør).
                  IsOpt := SameText(Reg.ReadString(Item.ValueName), Item.OptimizedStr);
              end;
            end;
        end;
      except
        // Hvis en ERegistryException opstår (f.eks. pga. beskadigede data),
        // betragtes tweaket som ikke-aktivt, og resten af proceduren fortsætter
        // uforstyrret. Dette er et bevidst valg: En enkelt fejlbehæftet
        // registreringsværdi må ikke forhindre de øvrige 45 tweaks i at blive
        // aflæst korrekt.
        on E: ERegistryException do
          IsOpt := False;
      end;
      Reg.CloseKey;
    end;
    // Hvis OpenKeyReadOnly fejlede (nøglen findes ikke), forbliver IsOpt = False,
    // hvilket er den korrekte tilstand: tweaket er ikke aktivt.

    // Opdater CheckBox'en under beskyttelse af event-guard, så OnClick ikke
    // udløses utilsigtet. try/finally sikrer, at flaget altid nulstilles,
    // selv hvis der skulle opstå en undtagelse under opdateringen.
    FUpdatingUI := True;
    try
      Item.CheckBox.Checked := IsOpt;
    finally
      FUpdatingUI := False;
    end;
  finally
    // Frigør altid TRegistry-objektet, uanset om der blev kastet en undtagelse.
    // Dette frigiver Windows-håndtaget til registreringsdatabasen og undgår
    // ressource-lækage ved gentagne kald.
    Reg.Free;
  end;
end;

{ ----------------------------------------------------------------------------
  ReadRegistryStatus
  Formål:
    At gennemløbe HELE listen af tweaks (alle 46) og aflæse den aktuelle
    tilstand for hver enkelt fra Windows-registreringsdatabasen, så alle
    afkrydsningsfelter i brugerfladen afspejler computerens faktiske tilstand
    ved opstart (eller når proceduren kaldes).

  Hvorfor er denne "batch-aflæsning" nødvendig?
    ReadSingleTweakStatus kan kun håndtere ÉT tweak ad gangen. Ved opstart
    skal alle 46 tweaks aflæses, og det ville være upraktisk at skulle kalde
    ReadSingleTweakStatus 46 gange fra FormCreate. Denne procedure fungerer
    som en simpel "orkestrator", der gennemløber listen og delegerer det
    egentlige arbejde til ReadSingleTweakStatus for hvert enkelt tweak.

  Brugen af statusbaren:
    Aflæsningen af 46 tweaks kan tage et øjeblik, især fordi dvale-tweaket
    kan kræve et kald til powercfg.exe (som kan tage 100-500 ms). Uden en
    synlig statusopdatering ville vinduet se ud til at "hænge" i opstarts-
    øjeblikket, og brugeren ville måske tro, at programmet var gået i stå.

    Derfor skrives to meddelelser i statusbaren:
      1. FØR løkken: "Indlæser status for samtlige parametre..."
      2. EFTER løkken: "Status for samtlige parametre indlæst med succes."

    Den første meddelelse fortæller brugeren, at noget er i gang. Den anden
    bekræfter, at hele processen er gennemført uden fejl. Begge meddelelser
    er vigtige for brugeroplevelsen: Den første beroliger brugeren under
    ventetiden, den anden giver en følelse af, at systemet er klar til brug.

  Hvorfor Application.ProcessMessages?
    Som standard opdaterer LCL ikke skærmen, før den vender tilbage til
    beskedløkken (message loop). Det betyder, at teksten "Indlæser status..."
    ikke ville blive synlig på skærmen, FØR hele proceduren var færdig.
    Ved at kalde Application.ProcessMessages tvinges LCL til at behandle
    ventende beskeder (herunder tegning af statusbaren) med det samme, så
    brugeren ser den korrekte status undervejs.

    Uden dette kald ville brugeren bare se et "fastfrosset" vindue i et
    kort øjeblik, og den første meddelelse ville aldrig blive synlig – den
    ville blive overskrevet af den anden meddelelse, før skærmen nåede at
    tegne den. Dette er en klassisk fælde i GUI-programmering, og
    ProcessMessages er den idiomatiske løsning i LCL.

  Hvorfor kun ÉN ProcessMessages?
    Man kunne fristes til at kalde ProcessMessages inde i løkken for hvert
    enkelt tweak. Men det ville være problematisk:
      - Det ville tillade brugeren at klikke på knapper og menuer, MENS
        aflæsningen stadig kører. Det kunne føre til race conditions, hvis
        f.eks. brugeren klikkede "Anvend alle", mens tilstanden endnu ikke
        var fuldt indlæst.
      - Det ville gøre proceduren markant langsommere, fordi hvert kald til
        ProcessMessages medfører kontekstskift og beskedbehandling.
    Derfor kaldes ProcessMessages kun ÉN gang, umiddelbart efter at
    statusmeddelelsen er sat, så den når at blive synlig. Resten af
    proceduren kører uden afbrydelser, hvilket både er hurtigere og mere
    sikkert.

  Hvorfor gennemløbes listen med et simpelt indeks?
    FTweaks er en TFPList, som er en simpel, indekseret liste af pointere.
    Det er både hurtigst og mest læsbart at bruge et heltalsindeks i en
    for-løkke. Et alternativ kunne være en "for ... in"-løkke, men TFPList
    understøtter ikke enumerator-mønstret direkte i alle Free Pascal-versioner.
    Den valgte tilgang er den mest portable og forudsigelige.

  Fejlhåndtering:
    Denne procedure har INGEN egen fejlhåndtering (ingen try/except). Det
    er et bevidst designvalg:
      - ReadSingleTweakStatus fanger selv ERegistryException internt og
        falder tilbage til IsOpt := False. Dermed stopper en enkelt fejl-
        behæftet registreringsværdi ikke hele gennemløbet.
      - De øvrige undtagelser, der kunne opstå (f.eks. en adgangsfejl på
        en nil-pointer), er så alvorlige, at de bør boble op til den
        overordnede fejlhåndtering i FormCreate, hvor de vises for
        brugeren som en "Initialiseringsfejl".
    Dermed undgås det, at fejl "sluges" på et niveau, hvor de ikke kan
    diagnosticeres ordentligt.

  Hvornår kaldes proceduren?
    Proceduren kaldes udelukkende fra FormCreate, umiddelbart efter BuildUI:
      PopulateAllTweaks;  // Fyld listen med data
      BuildUI;            // Byg brugerfladen ud fra listen
      ReadRegistryStatus; // Aflæs den faktiske tilstand for alle tweaks
    Rækkefølgen er kritisk: Uden BuildUI ville CheckBox-referencerne i
    TTweakItem være nil, og ReadSingleTweakStatus ville straks returnere
    uden at gøre noget (pga. nil-tjekket). Derfor skal BuildUI altid køre
    FØR ReadRegistryStatus.

  Kendt begrænsning:
    Hvis FTweaks-listen er tom (hvilket ikke bør ske i praksis, men kan
    forekomme, hvis PopulateAllTweaks fejlede), gennemløbes løkken nul
    gange, og statusbaren viser stadig "indlæst med succes". Dette er
    ikke et problem i praksis, fordi PopulateAllTweaks altid tilføjer
    46 tweaks, men det er værd at være opmærksom på ved fremtidige
    udvidelser af programmet.
  ---------------------------------------------------------------------------- }
procedure TFormMain.ReadRegistryStatus;
var
  i: Integer;  // Løbeindeks til gennemløb af FTweaks-listen
begin
  // Sæt den første statusmeddelelse, så brugeren kan se, at noget er i gang.
  // Teksten vises i statusbaren i bunden af vinduet (SimplePanel-tilstand).
  StatusBar1.SimpleText := 'Indlæser status for samtlige parametre...';

  // Tving LCL til at tegne statusbaren med det samme, FØR løkken starter.
  // Uden dette kald ville brugeren ikke se meddelelsen, før hele proceduren
  // var færdig – og den ville derfor aldrig blive synlig på skærmen.
  // ProcessMessages behandler også eventuelle ventende museklik og
  // tastetryk, så vinduet ikke ser ud til at være "frosset".
  Application.ProcessMessages;

  // Gennemløb hele listen af tweaks og aflæs tilstanden for hvert enkelt.
  // Det egentlige arbejde udføres af ReadSingleTweakStatus, som:
  //   - Åbner registreringsdatabasen med 64-bit visning.
  //   - Validerer datatyper (DWORD, streng, tom nøgle eller dvale).
  //   - Opdaterer det tilhørende afkrydsningsfelt under event-guard.
  // En enkelt fejlbehæftet værdi stopper ikke gennemløbet, fordi
  // ReadSingleTweakStatus fanger ERegistryException internt.
  for i := 0 to FTweaks.Count - 1 do
    ReadSingleTweakStatus(TTweakItem(FTweaks[i]));

  // Når alle 46 tweaks er aflæst, opdateres statusbaren med en bekræftelse.
  // Denne meddelelse giver brugeren en følelse af, at opstartsfasen er
  // gennemført, og at programmet nu er klar til brug.
  StatusBar1.SimpleText := 'Status for samtlige parametre indlæst med succes.';
end;

{ ----------------------------------------------------------------------------
  SetTweakInRegistry
  Formål:
    At skrive en enkelt tweak til Windows-registreringsdatabasen (eller i
    ét tilfælde styre dvale via powercfg.exe). Proceduren håndterer både
    AKTIVERING (EnableOptimized = True) og TILBAGERULNING (EnableOptimized =
    False) af et tweak, og den sørger for, at den korrekte værdi og datatype
    altid skrives.

  Hvorfor er denne procedure central?
    Det er her, programmets faktiske ændringer af systemet finder sted. Alle
    andre procedurer (CheckBoxClick, BtnApplyCurrentTabClick,
    BtnRestoreCurrentTabClick, MenuApplyAllClick) ender med at kalde denne
    procedure for hvert tweak, der skal ændres. Hvis der er en fejl her,
    virker hele programmet ikke efter hensigten.

  De to tilstande – EnableOptimized:
    Parameteren EnableOptimized afgør, om tweaket skal slås TIL eller rulles
    TILBAGE:

      EnableOptimized = True  (AKTIVERING):
        Den optimerede værdi (OptimizedDWord / OptimizedStr / nøglens
        eksistens) skrives til registreringsdatabasen.

      EnableOptimized = False (TILBAGERULNING):
        Fabriksstandardværdien (DefaultDWord / DefaultStr) skrives tilbage.
        For vkEmptyKey betyder det, at hele nøglestrukturen slettes rekursivt.

  Hvorfor fire forskellige håndteringer (vkDWord, vkString, vkEmptyKey, vkHibernate)?
    De fire tweak-typer har fundamentalt forskellige datastrukturer og kræver
    derfor forskellige skriveoperationer:

      A. vkDWord    : Skriv et 32-bit heltal som REG_DWORD. Hvis den
                      eksisterende værdi har en anden type, slettes den først.
      B. vkString   : Skriv en tekststreng som REG_SZ. Hvis standardværdien
                      er tom, betyder det "slet værdien ved tilbagerulning".
      C. vkEmptyKey : Selve nøglens eksistens er tweaket. Ved aktivering
                      oprettes nøglen med en tom standardværdi. Ved
                      tilbagerulning slettes hele nøglestrukturen rekursivt.
      D. vkHibernate: Dvale styres ikke via registret, men via powercfg.exe.
                      Derfor kaldes det eksterne program i stedet for at
                      skrive til registret.

  Hvorfor tvinges 64-bit skriveadgang (KEY_WOW64_64KEY)?
    Samme grund som i ReadSingleTweakStatus: På 64-bit Windows har mange
    nøgler to parallelle visninger (én for 32-bit og én for 64-bit programmer).
    Uden dette flag ville et 32-bit program skrive til den "forkerte" visning,
    og ændringen ville ikke have den tilsigtede effekt. Ved altid at tilføje
    KEY_WOW64_64KEY sikres det, at vi skriver til præcis den samme nøgle,
    som systemets egne 64-bit værktøjer (regedit, gpedit.msc osv.) læser fra.

  Hvorfor slettes forældede datatyper før ny værdi skrives (vkDWord)?
    Registreringsdatabasen er ikke typestærk. En værdi, der burde være et
    REG_DWORD, kan i praksis være gemt som en REG_SZ-tekst (f.eks. hvis en
    bruger har importeret en .reg-fil fra en tredjepart, eller hvis et
    ældre værktøj har skrevet værdien forkert). Windows selv behandler
    ofte sådanne værdier som ugyldige.

    Hvis vi blot kaldte Reg.WriteInteger uden at slette den gamle værdi
    først, ville Windows muligvis afvise skrivningen, eller værdien ville
    stå med en tvetydig type. Ved først at slette værdien og derefter skrive
    den på ny sikres det, at typen er entydig og korrekt.

    Bemærk, at dette kun gøres for vkDWord – for vkString er typen mindre
    kritisk, fordi Windows er mere fleksibel med tekstværdier.

  Hvorfor bruges OpenKey med 'True' (opret hvis den mangler)?
    For vkDWord og vkString skal nøglen eksistere (eller oprettes), før
    værdien kan skrives. Parameteren 'True' i OpenKey betyder "opret nøglen,
    hvis den ikke findes". Dette er nødvendigt, fordi mange tweaks skrives
    til nøgler, der endnu ikke eksisterer på en frisk Windows-installation
    (f.eks. 'SOFTWARE\Policies\Microsoft\Windows\DataCollection', som kun
    oprettes, når man første gang sætter en telemetri-politik).

  Hvorfor bruges Reg.WriteInteger med Integer(ValToWrite)?
    TRegistry's WriteInteger-metode forventer en Integer-parameter (signed
    32-bit), mens vi arbejder med Cardinal (unsigned 32-bit) for at kunne
    håndtere værdier som $FFFFFFFF korrekt. Ved at caste til Integer
    bevares de 32 bits uændret – kun fortolkningen skifter. Windows
    gemmer under alle omstændigheder de rå 4 bytes som en REG_DWORD.

  Hvorfor håndteres tom DefaultStr specielt (vkString)?
    For nogle tweaks er fabriksstandardtilstanden, at værdien slet IKKE
    eksisterer i registret. Et eksempel er 'ThisPCPolicy', hvor Windows
    som standard ikke har nogen værdi (hvilket betyder "vis mappen"). Hvis
    vi blot skrev den tomme streng '' til registret, ville Windows fortolke
    det som "skjul mappen" – det modsatte af standarden.

    Derfor er reglen: Hvis DefaultStr = '', skal værdien SLETTES ved
    tilbagerulning, ikke skrives som tom tekst. Dette sikrer, at
    standardtilstanden genskabes korrekt.

  Hvorfor bruges Reg.WriteString('', '') for vkEmptyKey?
    For vkEmptyKey er det nøglens blotte EKSISTENS, der er tweaket – ikke
    en specifik værdi. Men Windows kræver, at en nøgle har en standardværdi
    for at blive betragtet som "komplet". Ved at skrive en tom streng til
    standardværdien ('') sikres det, at nøglen eksisterer med en veldefineret,
    tom standardværdi. Det er præcis den struktur, som f.eks. Windows 11's
    kontekstmenu-tweak forventer.

  Hvorfor bruges DeleteKeyTree for vkEmptyKey ved tilbagerulning?
    Fordi nøglen kan indeholde undermapper (f.eks. CLSID-nøglen, der
    indeholder 'InprocServer32' med egne underværdier). Et almindeligt
    DeleteKey-kald ville fejle, fordi nøglen ikke er tom. DeleteKeyTree
    sletter hele træet rekursivt nedefra og op, hvilket er nødvendigt for
    at fjerne tweaket fuldstændigt.

  Hvorfor kastes en Exception ved fejl?
    Hvis en skriveoperation fejler (f.eks. pga. manglende rettigheder eller
    en beskadiget nøgle), skal brugeren informeres. Ved at kaste en Exception
    med en præcis fejlbesked (inkl. nøglestien) kan kalderen (CheckBoxClick
    eller batch-handlingerne) vise en meningsfuld meddelelse og rulle
    brugerfladen tilbage til den faktiske tilstand. Uden dette ville fejl
    stille og roligt blive ignoreret, og brugeren ville tro, at ændringen
    var gennemført.

  Hvorfor bruges 'Exit' efter dvale-håndteringen?
    Dvale-tweaket er et specialtilfælde, der ikke bruger TRegistry
    overhovedet. Når powercfg-kommandoen er afviklet (eller fejlet), er
    der intet mere at gøre, og proceduren skal afsluttes uden at oprette
    et TRegistry-objekt. Derfor returneres straks efter dvale-håndteringen.

  Fejlhåndtering:
    Proceduren har ingen egen try/except (bortset fra den overordnede
    try/finally for TRegistry). Undtagelser boble op til kalderen, som
    håndterer dem og viser en fejlmeddelelse til brugeren. Dette er et
    bevidst designvalg: SetTweakInRegistry skal ikke selv bestemme, hvordan
    fejl præsenteres – det er kalderens ansvar.

    For dvale-tweaket kastes en Exception, hvis powercfg.exe returnerer en
    ikke-nul exit-kode. Dette fanger både manglende rettigheder og andre
    fejl fra powercfg.

  Anvendelse i programmet:
    Proceduren kaldes fra fire steder:
      - CheckBoxClick             (når brugeren klikker på et enkelt tweak)
      - BtnApplyCurrentTabClick   (når brugeren aktiverer alle på en fane)
      - BtnRestoreCurrentTabClick (når brugeren nulstiller alle på en fane)
      - MenuApplyAllClick         (når brugeren aktiverer alle 46 tweaks)
    I alle tilfælde efterfølges kaldet af ReadSingleTweakStatus, som
    verificerer, at ændringen faktisk blev gennemført, og opdaterer
    CheckBox'en i overensstemmelse hermed.
  ---------------------------------------------------------------------------- }
procedure TFormMain.SetTweakInRegistry(Item: TTweakItem; EnableOptimized: Boolean);
var
  Reg: TRegistry;         // Registry-adgangsobjekt til skrivning
  PowerOut: String;       // Output fra powercfg.exe (bruges kun for dvale)
  ExitCode: Integer;      // Exit-kode fra powercfg.exe (bruges kun for dvale)
  ValToWrite: Cardinal;   // Den DWORD-værdi, der skal skrives (unsigned for $FFFFFFFF)
begin
  // =========================================================================
  // SÆRTILFÆLDE: vkHibernate (Windows' dvalefunktion)
  // =========================================================================
  // Dvale styres ikke via registreringsdatabasen, men via Windows'
  // strømstyringskerne. Derfor kaldes powercfg.exe med '-h off' (deaktiver
  // dvale) eller '-h on' (aktiver dvale), afhængigt af om vi aktiverer
  // eller ruller tilbage.
  if Item.ValKind = vkHibernate then
  begin
    if EnableOptimized then
      // AKTIVERING: Slå dvale fra (frigør diskplads og deaktiverer
      // Hiberfil.sys samt Hurtig Start).
      ExitCode := RunCommandCapture(GetSafeSystemPath('powercfg.exe'), ['-h', 'off'], PowerOut)
    else
      // TILBAGERULNING: Slå dvale til igen (genskab fabriksstandarden).
      ExitCode := RunCommandCapture(GetSafeSystemPath('powercfg.exe'), ['-h', 'on'], PowerOut);

    // Hvis powercfg returnerede en fejlkode (ikke 0), kastes en undtagelse
    // med både exit-koden og powercfgs eget output, så fejlen kan
    // diagnosticeres præcist af kalderen.
    if ExitCode <> 0 then
      raise Exception.CreateFmt('powercfg fejlede med kode %d: %s', [ExitCode, Trim(PowerOut)]);

    // Afslut proceduren – dvale er et specialtilfælde, og resten af
    // proceduren (TRegistry-baseret skrivning) skal ikke køres.
    Exit;
  end;

  // =========================================================================
  // STANDARD REGISTERSKRIVNING (vkDWord, vkString, vkEmptyKey)
  // =========================================================================
  // Opret en TRegistry med skriveadgang og 64-bit visning. KEY_WRITE giver
  // rettigheder til at oprette, ændre og slette nøgler og værdier.
  Reg := TRegistry.Create(KEY_WRITE or KEY_WOW64_64KEY);
  try
    // Sæt rod-nøglen fra tweak-objektet (HKEY_CURRENT_USER eller HKEY_LOCAL_MACHINE).
    Reg.RootKey := Item.RootKey;

    // Undersøg hvilken datatype tweaket har, og skriv værdien tilsvarende.
    case Item.ValKind of
      // -------------------------------------------------------------------
      // Type A: vkDWord (32-bit heltal)
      // -------------------------------------------------------------------
      vkDWord:
        begin
          // Åbn (eller opret) nøglen. 'True' betyder "opret hvis den mangler",
          // hvilket er nødvendigt, fordi mange politik-nøgler ikke eksisterer
          // på en frisk Windows-installation.
          if not Reg.OpenKey(Item.SubKey, True) then
            raise Exception.CreateFmt('Kunne ikke åbne nøglen: %s', [Item.SubKey]);

          // Hvis værdien allerede eksisterer med en ANDEN type end rdInteger
          // (f.eks. rdString eller rdBinary), skal den slettes først. Ellers
          // risikerer vi, at Windows afviser skrivningen, eller at værdien
          // står med en tvetydig type. Dette håndterer tilfælde, hvor en
          // tidligere .reg-import eller et tredjepartsværktøj har skrevet
          // værdien forkert.
          if Reg.ValueExists(Item.ValueName) and (Reg.GetDataType(Item.ValueName) <> rdInteger) then
            Reg.DeleteValue(Item.ValueName);

          // Vælg hvilken værdi der skal skrives, afhængigt af om vi aktiverer
          // eller ruller tilbage.
          if EnableOptimized then
            ValToWrite := Item.OptimizedDWord  // Den optimerede (hurtige/sikre) værdi
          else
            ValToWrite := Item.DefaultDWord;   // Fabriksstandardværdien

          // Skriv værdien som ægte 32-bit REG_DWORD. Cast til Integer bevarer
          // de 32 bits uændret – kun fortolkningen skifter fra unsigned til
          // signed. Windows gemmer under alle omstændigheder de rå 4 bytes.
          Reg.WriteInteger(Item.ValueName, Integer(ValToWrite));

          // Luk nøglen, så Windows frigiver sit håndtag.
          Reg.CloseKey;
        end;

      // -------------------------------------------------------------------
      // Type B: vkString (tekststreng)
      // -------------------------------------------------------------------
      vkString:
        begin
          // Åbn (eller opret) nøglen – samme begrundelse som for vkDWord.
          if not Reg.OpenKey(Item.SubKey, True) then
            raise Exception.CreateFmt('Kunne ikke åbne nøglen: %s', [Item.SubKey]);

          if EnableOptimized then
            // AKTIVERING: Skriv den optimerede tekstværdi.
            Reg.WriteString(Item.ValueName, Item.OptimizedStr)
          else
          begin
            // TILBAGERULNING: Hvis fabriksstandarden er den tomme streng,
            // betyder det, at værdien slet IKKE skal eksistere. Derfor
            // slettes den, hvis den findes.
            if Item.DefaultStr = '' then
            begin
              if Reg.ValueExists(Item.ValueName) then
                Reg.DeleteValue(Item.ValueName);
            end
            else
              // Ellers skrives fabriksstandardteksten tilbage.
              Reg.WriteString(Item.ValueName, Item.DefaultStr);
          end;

          // Luk nøglen, så Windows frigiver sit håndtag.
          Reg.CloseKey;
        end;

      // -------------------------------------------------------------------
      // Type C: vkEmptyKey (nøglens blotte eksistens)
      // -------------------------------------------------------------------
      vkEmptyKey:
        begin
          if EnableOptimized then
          begin
            // AKTIVERING: Opret nøglen og skriv en tom standardværdi.
            // Nøglens eksistens alene er tweaket (f.eks. Win11-kontekstmenuen).
            if not Reg.OpenKey(Item.SubKey, True) then
              raise Exception.CreateFmt('Kunne ikke oprette nøglen: %s', [Item.SubKey]);

            // Skriv en tom streng til nøglens standardværdi. Dette sikrer,
            // at nøglen er "komplet" set fra Windows' synspunkt, og at
            // tweaket virker som forventet.
            Reg.WriteString('', '');

            // Luk nøglen, så Windows frigiver sit håndtag, FØR vi
            // eventuelt skal slette den igen.
            Reg.CloseKey;
          end
          else
          begin
            // TILBAGERULNING: Slet hele nøglestrukturen rekursivt. Dette
            // er nødvendigt, fordi nøglen kan indeholde undermapper
            // (f.eks. CLSID → InprocServer32), og et almindeligt
            // DeleteKey-kald ville fejle på en ikke-tom nøgle.
            if not DeleteKeyTree(Reg, Item.SubKey) then
              raise Exception.CreateFmt('Kunne ikke slette nøglen: %s', [Item.SubKey]);
          end;
        end;
    end;
  finally
    // Frigør altid TRegistry-objektet, uanset om der blev kastet en
    // undtagelse. Dette frigiver Windows-håndtaget til registrerings-
    // databasen og undgår ressource-lækage ved gentagne kald.
    Reg.Free;
  end;
end;

{ ----------------------------------------------------------------------------
  ShowTweakInfo
  Formål:
    At vise de forklarende oplysninger (titel, fordele og ulemper) for et
    bestemt tweak i infopanelet nederst i vinduet. Proceduren er den eneste
    centraliserede måde, hvorpå infopanelet opdateres, uanset om brugeren
    bruger musen eller tastaturet.

  Hvordan infopanelet er opbygget:
    Infopanelet består af tre komponenter (se TFormMain's deklaration):
      - LblInfoName : Viser tweakets titel øverst.
      - MemoPros   : En grøn boks med fordelene ved tweaket.
      - MemoCons   : En rød/orange boks med ulemperne/risiciene.
    Alle tre opdateres samlet, så brugeren altid ser en konsistent visning.

  Hvorfor er der en "throttling"-mekanisme?
    Hændelsen OnMouseMove udløses, HVER gang musen bevæger sig blot én pixel
    over et afkrydsningsfelt. Når brugeren bevæger musen hen over et tweak,
    udløses hændelsen typisk 50-100 gange i sekundet. Uden beskyttelse ville
    hver af disse hændelser medføre:
      1. En tildeling af tre strenge (Title, Pros, Cons).
      2. En opdatering af tre visuelle komponenter (LblInfoName, MemoPros,
         MemoCons), som hver især udløser skærmopdateringer.
      3. En gentegning af infopanelet på skærmen.

    Resultatet ville være et enormt CPU-forbrug – og værre: en synlig
    "flimren", fordi komponenterne konstant ryddes og genopfyldes med de
    samme data. Brugeren ville opleve infopanelet som ustabilt og irriterende.

    Løsningen er en simpel "memoization": Vi husker, hvilket tweak der
    sidst blev vist i feltet FLastHoverItem. Hvis det aktuelle tweak er
    identisk med det sidst viste, springes hele opdateringen over. Dermed
    sker den dyre opdatering kun ÉN gang pr. tweak – nemlig når musen første
    gang kommer ind over feltet.

  Hvorfor er nil-tjekket nødvendigt?
    ShowTweakInfo kaldes fra CheckBoxMouseMove og CheckBoxEnter, som begge
    modtager en Sender-komponent og udtrækker dens Tag. I teorien kunne Tag
    være nil, hvis en CheckBox blev oprettet uden at få tildelt et tweak-
    objekt (hvilket ikke bør ske, men er en billig forsikring). Uden
    nil-tjekket ville LblInfoName.Caption := Item.Title kaste en
    adgangsfejl, og hele brugerfladen ville crashe ved den mindste
    musebevægelse.

  Hvorfor er FLastHoverItem ikke nulstillet her?
    FLastHoverItem nulstilles i FormDestroy (ved nedlukning), så den ikke
    kan indeholde en dangling pointer efter programmet er lukket. Under
    normal kørsel bevarer den sin værdi, så gentagne hover-bevægelser over
    samme tweak kan detekteres og springes over.

  Kendt begrænsning:
    Hvis to forskellige tweaks ved en fejl skulle få tildelt samme
    TTweakItem-pointer (hvilket ikke bør kunne ske, fordi hvert tweak
    oprettes separat i PopulateAllTweaks), ville throttlingen føre til,
    at det andet tweaks info aldrig blev vist. Dette er dog ikke et
    reelt problem i praksis, fordi hvert tweak har sit eget unikke objekt.
  ---------------------------------------------------------------------------- }
procedure TFormMain.ShowTweakInfo(Item: TTweakItem);
begin
  // Sikkerhedstjek: Hvis Item er nil (hvilket kan ske, hvis en CheckBox
  // ved en fejl er oprettet uden et tilknyttet tweak-objekt), gør vi intet.
  // Dette forhindrer en adgangsfejl på nil-pointere.
  if Item = nil then Exit;

  // Throttling: Hvis vi allerede viser præcis dette tweak, er der ingen
  // grund til at gentage den dyre opdatering. Dette er den vigtigste
  // optimering i hele proceduren – OnMouseMove kan udløses 50-100 gange i
  // sekundet, mens musen bevæger sig over et felt, og uden dette tjek
  // ville infopanelet flimre og CPU-forbruget stige markant.
  if Item = FLastHoverItem then Exit;

  // Husk hvilket tweak vi nu viser, så næste kald kan sammenligne med det.
  // Dette skal ske, FØR vi opdaterer komponenterne, så et eventuelt
  // rekursivt kald (hvilket ikke bør forekomme, men er billig forsikring)
  // ikke forsøger at opdatere igen.
  FLastHoverItem := Item;

  // Opdater infopanelets tre komponenter med det aktuelle tweaks data:
  //   - Titlen i den øverste label.
  //   - Fordelene i den grønne memo-boks.
  //   - Ulemperne i den rød/orange memo-boks.
  // Bemærk at tildelingen af strengene til MemoPros.Text og MemoCons.Text
  // udløser en automatisk gentegning af de to memofelter, hvilket er
  // præcis det, vi ønsker – men kun ÉN gang pr. tweak takket være
  // throttlingen ovenfor.
  LblInfoName.Caption := Item.Title;
  MemoPros.Text := Item.Pros;
  MemoCons.Text := Item.Cons;
end;


{ ----------------------------------------------------------------------------
  CheckBoxMouseMove
  Formål:
    Hændelsesrutine, der kaldes, når musen bevæger sig over et afkrydsningsfelt.
    Udtrækker det tilknyttede tweak-objekt fra CheckBox'ens Tag-egenskab og
    videresender det til ShowTweakInfo, som opdaterer infopanelet.

  Hvordan hændelsen er forbundet:
    I BuildUI tildeles hændelsen til hver enkelt CheckBox:
      CB.OnMouseMove := @CheckBoxMouseMove;
    Når brugeren bevæger musen over feltet, kalder LCL denne procedure med
    CheckBox'en som Sender-parameter. Via Sender kan vi identificere,
    hvilket tweak der er tale om.

  Hvorfor bruges 'Sender is TCheckBox' i stedet for et ubetinget cast?
    I teorien kaldes OnMouseMove altid med den CheckBox, hændelsen er
    tilknyttet, så et direkte cast til TCheckBox ville være sikkert. Men
    hvis hændelsen ved en fejl skulle blive knyttet til en anden komponent
    (f.eks. via en tastefejl i BuildUI eller en fremtidig udvidelse), ville
    et ubetinget cast føre til en adgangsfejl. Med 'is'-operatoren tjekkes
    typen først, og hvis Sender ikke er en TCheckBox, springes kaldet
    blot over. Dette er en billig forsikring mod fremtidige fejl.

  Hvorfor bruges Tag til at finde tweak-objektet?
    I BuildUI gemmes en pointer til tweak-objektet i CheckBox'ens Tag:
      CB.Tag := PtrInt(Item);
    Dermed kan vi med et enkelt cast hente tweak-objektet tilbage uden at
    skulle søge i FTweaks-listen. Dette er både hurtigere (O(1) i stedet
    for O(n)) og mere robust, fordi det ikke afhænger af, at listen og
    brugerfladen er synkroniserede.

  Hvorfor er _Shift, _X og _Y præfikset med underscore?
    Disse tre parametre er en del af LCL's standard-signatur for OnMouseMove,
    men vi bruger dem ikke i denne procedure. Underscore-præfikset er en
    konvention, der fortæller compileren og læseren, at parameteren bevidst
    er ubrugt. Uden underscore ville compileren udstede en advarsel
    (WARN 5024 "Parameter not used"), som ville støje i byggeprocessen.

  Hvorfor er denne procedure så kort?
    Al logikken er centraliseret i ShowTweakInfo, som både CheckBoxMouseMove
    og CheckBoxEnter kalder. Denne procedure er blot en tynd "adapter", der
    oversætter LCL's generiske Sender/Tag-mekanisme til et konkret
    TTweakItem-kald. Det gør koden nem at vedligeholde: Hvis visnings-
    logikken ændres (f.eks. tilføjelse af et ikon eller en URL), skal
    kun ShowTweakInfo opdateres – ikke hændelsesrutinerne.
  ---------------------------------------------------------------------------- }
procedure TFormMain.CheckBoxMouseMove(Sender: TObject; _Shift: TShiftState; _X, _Y: Integer);
begin
  // Tjek at Sender faktisk er en TCheckBox (defensiv programmering, se
  // forklaringen ovenfor). Hvis ikke, gør vi intet.
  if Sender is TCheckBox then
    // Hent tweak-objektet fra Tag (som blev gemt i BuildUI via PtrInt)
    // og send det videre til ShowTweakInfo, som opdaterer infopanelet.
    ShowTweakInfo(TTweakItem(TCheckBox(Sender).Tag));
end;


{ ----------------------------------------------------------------------------
  CheckBoxEnter
  Formål:
    Hændelsesrutine, der kaldes, når et afkrydsningsfelt FÅR FOKUS – dvs.
    når brugeren navigerer til det med Tabulatortasten eller piletasterne,
    eller når feltet aktiveres via en adgangstast (Alt+genvej).

  Hvorfor er denne procedure nødvendig?
    Hvis vi kun håndterede OnMouseMove, ville infopanelet kun blive opdateret,
    når brugeren brugte musen. Men programmet skal også være tilgængeligt for
    brugere, der udelukkende navigerer med tastaturet (f.eks. pga. motoriske
    handicap eller af præference). For dem ville infopanelet aldrig vise
    noget, medmindre vi også reagerede på, at et felt får fokus.

    LCL tilbyder OnEnter-hændelsen, som udløses, når en komponent får fokus.
    Ved at forbinde den til denne procedure får vi automatisk samme
    informationsvisning ved tastaturnavigation som ved musebrug.

  Hvorfor kaldes CheckBoxMouseMove i stedet for ShowTweakInfo direkte?
    Fordi vi ønsker at genbruge den samme logik – herunder Sender-tjekket
    og det korrekte cast fra Tag til TTweakItem – uden at duplikere koden.
    Ved at kalde CheckBoxMouseMove med de samme parametre (bortset fra de
    musespecifikke, som ikke bruges) opnås præcis samme adfærd, som hvis
    brugeren havde bevæget musen over feltet.

    Alternativet – at kalde ShowTweakInfo direkte med et cast fra Sender.Tag
    – ville også virke, men det ville duplikere Sender-tjekket og gøre
    koden sværere at vedligeholde. Ved at genbruge CheckBoxMouseMove holdes
    al "oversættelseslogik" på ét sted.

  Hvorfor sendes dummy-værdier ([] og 0, 0) til museparametrene?
    CheckBoxMouseMove forventer tre parametre ud over Sender:
      - _Shift : TShiftState (hvilke modifier-taster der var trykket ned)
      - _X, _Y : Integer (musens koordinater)
    Da disse ikke bruges i CheckBoxMouseMove, kan vi sende vilkårlige
    værdier. [] betyder "ingen modifier-taster", og 0, 0 er blot en
    neutral position. Det er den idiomatiske måde at genbruge en
    hændelsesrutine fra en anden kontekst på.

  Kendt begrænsning:
    OnEnter udløses kun, når fokus SKIFTER til en ny komponent. Hvis
    brugeren allerede står på et felt og trykker på en anden tast (f.eks.
    Space for at slå tweaket til), opdateres infopanelet ikke igen – men
    det behøver det heller ikke, fordi informationen allerede vises korrekt
    fra det første Enter. Dette er præcis den ønskede adfærd.
  ---------------------------------------------------------------------------- }
procedure TFormMain.CheckBoxEnter(Sender: TObject);
begin
  // Genbrug CheckBoxMouseMove, så vi får præcis samme visning som ved
  // musebevægelse. De tre musespecifikke parametre sættes til neutrale
  // dummy-værdier, fordi de ikke bruges i CheckBoxMouseMove.
  // Kommentaren nedenfor er den oprindelige, som forklarer formålet.
  // Giver samme visning når brugeren taster sig frem med Tabulatortasten:
  CheckBoxMouseMove(Sender, [], 0, 0);
end;

{ ----------------------------------------------------------------------------
  CheckBoxClick
  Formål:
    Hændelsesrutine der kaldes, når brugeren klikker på et afkrydsningsfelt
    (eller aktiverer det med mellemrumstasten). Proceduren skriver straks den
    nye tilstand til Windows-registreringsdatabasen (eller til powercfg for
    dvale-tweaket) og verificerer bagefter, at Windows faktisk accepterede
    ændringen – så brugerfladen altid afspejler computerens VIRKELIGE tilstand
    og ikke blot brugerens ønske.

  Hvorfor er denne procedure så vigtig?
    Det er her, brugerens ENKELTE klik bliver omsat til en faktisk ændring
    af systemet. Hele programmets formål – at optimere Windows – realiseres
    først i det øjeblik, denne procedure kalder SetTweakInRegistry. Derfor er
    proceduren designet med stor omhu omkring fejlhåndtering og verifikation.

  Hvordan proceduren fungerer (algoritmen):
    1. Event-guard: Hvis FUpdatingUI er True, betyder det, at en programmatisk
       opdatering af CheckBox.Checked er i gang. Vi må IKKE reagere på den,
       fordi det ville skabe en uendelig rekursion.
    2. Sender-tjek: Sikr at hændelsen faktisk kommer fra en TCheckBox.
    3. Hent tweak-objektet fra CheckBox'ens Tag-egenskab (gemt i BuildUI).
    4. Skriv ændringen til registreringsdatabasen via SetTweakInRegistry.
    5. Opdater statusbaren med en bekræftelse.
    6. Verificér med ReadSingleTweakStatus, at ændringen faktisk blev
       gennemført, og at fluebenet stemmer overens med virkeligheden.
    7. Ved fejl: Vis en fejlmeddelelse og rul brugerfladen tilbage til den
       faktiske tilstand.

  Hvorfor FUpdatingUI-guarden er kritisk:
    Når ReadSingleTweakStatus opdaterer Item.CheckBox.Checked, udløser LCL
    normalt OnClick-hændelsen. Hvis vi ikke blokerede dette, ville
    CheckBoxClick blive kaldt igen, hvilket igen ville kalde SetTweakInRegistry,
    som igen ville kalde ReadSingleTweakStatus – og så fremdeles i en uendelig
    løkke, indtil stakken løber over og programmet crasher.

    ReadSingleTweakStatus beskytter sig selv ved at sætte FUpdatingUI := True
    under opdateringen af CheckBox.Checked. Når OnClick så udløses, ser
    CheckBoxClick med det samme, at FUpdatingUI er True, og returnerer straks
    uden at gøre noget. Dermed brydes rekursionen effektivt.

  Hvorfor hentes tweak-objektet via Tag?
    I BuildUI gemmes en pointer til tweak-objektet i CheckBox'ens Tag:
      CB.Tag := PtrInt(Item);
    Hermed kan vi hente tweak-objektet med et enkelt cast – uden at skulle
    søge i FTweaks-listen. Dette er både hurtigere (O(1) i stedet for O(n))
    og mere robust, fordi det ikke afhænger af, at listen og brugerfladen
    er synkroniserede.

  Hvorfor tjekkes Assigned(Item)?
    I teorien skulle Tag altid indeholde en gyldig pointer, fordi BuildUI
    tildeler den for hver CheckBox. Men hvis et tweak-objekt af en eller
    anden grund er blevet frigivet (f.eks. pga. en fejl i FormDestroy), kan
    Tag indeholde en dangling pointer. Ved at tjekke Assigned(Item) undgås
    en adgangsfejl, hvis dette skulle ske. Det er billig forsikring mod
    fremtidige fejl.

  Hvorfor kaldes SetTweakInRegistry FØR ReadSingleTweakStatus?
    SetTweakInRegistry skriver ændringen til registreringsdatabasen (eller
    kalder powercfg). ReadSingleTweakStatus aflæser derefter den FAKTISKE
    tilstand fra registreringsdatabasen og opdaterer CheckBox.Checked i
    overensstemmelse hermed.

    Hvis vi sprang SetTweakInRegistry over og blot opdaterede CheckBox.Checked
    direkte, ville brugerfladen vise en ændring, som Windows aldrig fik
    besked om. Hvis vi sprang ReadSingleTweakStatus over, ville brugerfladen
    vise brugerens ØNSKE i stedet for den faktiske tilstand – hvilket ville
    være forkert, hvis Windows afviste ændringen (f.eks. pga. manglende
    rettigheder eller en beskyttet nøgle).

    Kombinationen af de to kald sikrer, at brugerfladen ALTID afspejler
    virkeligheden, uanset om ændringen lykkedes eller ej.

  Hvorfor opdateres statusbaren mellem de to kald?
    Statusbaren giver brugeren en umiddelbar visuel bekræftelse på, at
    klikket blev registreret. Hvis vi ventede med statusopdateringen til
    efter ReadSingleTweakStatus, ville der være et kort øjeblik, hvor
    brugeren ikke vidste, om klikket blev opfanget. Ved at opdatere
    statusbaren straks efter skrivningen får brugeren feedback med det
    samme, og eventuelle forsinkelser (f.eks. ved powercfg-kaldet for
    dvale) bliver mere acceptable.

  Fejlhåndtering – hvorfor to try/except-blokke?
    Den ydre try/except fanger fejl fra SetTweakInRegistry og fra den
    efterfølgende statusopdatering. Hvis f.eks. SetTweakInRegistry kaster
    en Exception (manglende rettigheder, beskyttet nøgle, powercfg-fejl),
    fanges den her, og brugeren får en fejlmeddelelse.

    Inde i except-blokken kaldes ReadSingleTweakStatus endnu en gang for at
    rulle brugerfladen tilbage til den faktiske tilstand. Dette er vigtigt:
    Når en fejl er opstået, kan CheckBox.Checked stå med brugerens ønskede
    værdi (fordi brugeren klikkede), men Windows har ikke accepteret
    ændringen. ReadSingleTweakStatus retter dette ved at læse den faktiske
    tilstand og opdatere CheckBox.Checked.

    Den indre try/except (tom) omkring det andet ReadSingleTweakStatus-kald
    er en sidste sikkerhedsforanstaltning: Hvis ReadSingleTweakStatus selv
    skulle fejle (f.eks. fordi registreringsdatabasen er blevet utilgængelig
    midt i processen), må det ikke føre til en ny undtagelse, som ville
    skjule den oprindelige fejlmeddelelse for brugeren. Den tomme except
    ignorerer derfor en eventuel sekundær fejl.

  Hvorfor bruges MessageDlg frem for en simpel ShowMessage?
    MessageDlg giver mulighed for at angive ikon (mtError) og knapper
    ([mbOK]), hvilket gør fejlmeddelelsen mere tydelig og professionel.
    Desuden følger MessageDlg LCL's standardskrift og layout, hvilket giver
    en konsistent brugeroplevelse på tværs af platforme og temaer.

  Kendt begrænsning:
    Hvis ReadSingleTweakStatus i den normale (ikke-fejl) gren skulle fejle
    (hvilket er yderst usandsynligt, fordi den fanger ERegistryException
    internt), ville hele proceduren kaste en undtagelse op til LCL's
    beskedløkke, som typisk viser en teknisk fejlmeddelelse. Dette anses
    dog for acceptabelt, fordi det er en så usædvanlig situation, at en
    teknisk fejlmeddelelse er den mest hjælpsomme information for udvikleren.

  Anvendelse i programmet:
    Proceduren er forbundet til OnClick-hændelsen på hver enkelt CheckBox
    i BuildUI:
      CB.OnClick := @CheckBoxClick;
    Dermed udløses den automatisk, når brugeren klikker på et flueben.
    Den er også indirekte ansvarlig for, at de tre batch-handlinger
    (Anvend alle, Gendan alle, Anvend alle på fane) fungerer korrekt,
    fordi de kalder SetTweakInRegistry og ReadSingleTweakStatus på samme
    måde – blot i en løkke over flere tweaks.
  ---------------------------------------------------------------------------- }
procedure TFormMain.CheckBoxClick(Sender: TObject);
var
  Item: TTweakItem;  // Det tweak-objekt, der er knyttet til det klikkede felt
begin
  // -------------------------------------------------------------------------
  // EVENT-GUARD: Afbryd hvis vi er midt i en programmatisk opdatering
  // -------------------------------------------------------------------------
  // Hvis FUpdatingUI er True, er vi i gang med at opdatere CheckBox.Checked
  // fra kode (f.eks. i ReadSingleTweakStatus). OnClick-hændelsen udløses
  // automatisk af LCL ved en sådan opdatering, men vi må IKKE reagere på
  // den – ellers ville vi skabe en uendelig rekursion af kald mellem
  // CheckBoxClick, SetTweakInRegistry og ReadSingleTweakStatus.
  if FUpdatingUI then Exit;

  // Sikr at hændelsen faktisk kommer fra en TCheckBox. Dette er defensiv
  // programmering – i praksis vil Sender altid være den CheckBox, som
  // hændelsen er knyttet til, men tjekket er billigt og forhindrer en
  // potentiel adgangsfejl, hvis hændelsen skulle blive knyttet forkert.
  if Sender is TCheckBox then
  begin
    // Hent tweak-objektet fra Tag, hvor det blev gemt i BuildUI.
    // Castet fra PtrInt (heltal) til TTweakItem (pointer) er nødvendigt,
    // fordi Tag er et heltal, mens vi har brug for en objekt-referencce.
    Item := TTweakItem(TCheckBox(Sender).Tag);

    // Sikkerhedstjek: Hvis Item er nil (hvilket ikke bør ske, men kan
    // forekomme ved en fejl i BuildUI), afbrydes proceduren uden at gøre
    // noget. Dette forhindrer en adgangsfejl på nil-pointere.
    if not Assigned(Item) then Exit;

    try
      // ---------------------------------------------------------------------
      // TRIN 1: Skriv ændringen til registreringsdatabasen
      // ---------------------------------------------------------------------
      // Den nye tilstand aflæses direkte fra CheckBox.Checked, som LCL har
      // opdateret INDEN OnClick udløses. Dermed afspejler Checked brugerens
      // ønske, og vi behøver ikke at invertere nogen værdi selv.
      // SetTweakInRegistry håndterer alle fire tweak-typer (DWORD, String,
      // EmptyKey og Hibernate) og kaster en Exception ved fejl.
      SetTweakInRegistry(Item, TCheckBox(Sender).Checked);

      // ---------------------------------------------------------------------
      // TRIN 2: Giv brugeren feedback via statusbaren
      // ---------------------------------------------------------------------
      // Statusbaren opdateres straks efter skrivningen, så brugeren får
      // visuel bekræftelse på, at klikket blev registreret – også selv om
      // ReadSingleTweakStatus efterfølgende måtte tage et øjeblik (f.eks.
      // ved powercfg-kaldet for dvale). Format indsætter tweakets titel i
      // meddelelsen, så brugeren kan se præcis, hvad der blev opdateret.
      StatusBar1.SimpleText := Format('Opdateret: %s', [Item.Title]);

      // ---------------------------------------------------------------------
      // TRIN 3: Verificér med registreringsdatabasen
      // ---------------------------------------------------------------------
      // Læs den FAKTISKE tilstand tilbage fra registreringsdatabasen og
      // opdater CheckBox.Checked i overensstemmelse hermed. Dette sikrer,
      // at brugerfladen altid afspejler virkeligheden – også i de sjældne
      // tilfælde, hvor Windows har accepteret skrivningen, men fortolker
      // værdien anderledes end forventet.
      // ReadSingleTweakStatus beskytter sig selv med FUpdatingUI, så denne
      // opdatering ikke udløser et nyt kald til CheckBoxClick.
      ReadSingleTweakStatus(Item);
    except
      // ---------------------------------------------------------------------
      // FEJLGREN: Noget gik galt under skrivningen eller verifikationen
      // ---------------------------------------------------------------------
      // F.eks.:
      //   - Manglende rettigheder til en beskyttet nøgle.
      //   - En beskadiget registreringsstruktur.
      //   - powercfg.exe returnerede en fejlkode for dvale-tweaket.
      on E: Exception do
      begin
        // Vis en informativ fejlmeddelelse til brugeren. E.Message indeholder
        // den præcise fejlbeskrivelse, som SetTweakInRegistry har kastet –
        // typisk inkl. nøglestien eller powercfg's output.
        MessageDlg('Fejl ved opdatering', 'Handlingen fejlede: ' + E.Message, mtError, [mbOK], 0);

        try
          // Rul brugerfladen tilbage til den faktiske tilstand. Uden dette
          // ville CheckBox.Checked stå med brugerens ønskede værdi, selv om
          // Windows ikke accepterede ændringen. ReadSingleTweakStatus læser
          // den reelle tilstand og retter fluebenet.
          ReadSingleTweakStatus(Item);
        except
          // Hvis selv tilbagerulningen fejler (yderst usandsynligt, men
          // teoretisk muligt), ignoreres fejlen her. Dette forhindrer, at
          // en sekundær fejl overskygger den oprindelige fejlmeddelelse,
          // som brugeren allerede er blevet informeret om.
        end;
      end;
    end;
  end;
end;

{ ----------------------------------------------------------------------------
  BtnApplyCurrentTabClick
  Formål:
    At aktivere SAMTLIGE de tweaks, der hører til det aktuelt valgte faneblad,
    i én samlet batch-handling. Proceduren er knyttet til knappen "Aktivér
    alle på denne fane" i bunden af vinduet og giver brugeren en hurtig vej
    til at slå en hel kategori af optimeringer til på én gang – uden at skulle
    klikke på hvert enkelt afkrydsningsfelt.

  Hvornår bruges denne handling?
    Kategorierne i programmet er tematisk organiserede (f.eks. "Sikkerhed &
    Privatliv" eller "Netværk & Gaming"), og en typisk bruger vil ofte ønske
    at slå HELE temaet til på én gang. Uden denne knap skulle brugeren
    klikke 6-8 gange pr. fane, hvilket er både tidskrævende og irriterende.
    Batch-handlingen giver en mere strømlinet brugeroplevelse.

  Hvordan proceduren fungerer (algoritmen):
    1. Validér at der overhovedet er et aktivt faneblad, og at dets Tag
       indeholder et gyldigt kategoriindeks (0-9). Hvis ikke, afbrydes
       proceduren straks uden at gøre noget.
    2. Aflæs det aktuelle kategoriindeks fra fanebladets Tag-egenskab.
       Dette indeks blev gemt i BuildUI og fortæller os, hvilke tweaks der
       hører til fanen.
    3. Initialisér tællere for succeser og fejl.
    4. Gennemløb ALLE tweaks i FTweaks-listen og find dem, der matcher
       den aktuelle kategori, som har en CheckBox, og som IKKE allerede
       er slået til.
    5. For hvert match: Kald SetTweakInRegistry(Item, True) for at slå
       tweaket til, og ReadSingleTweakStatus(Item) for at verificere.
    6. Tæl succeser og fejl op undervejs.
    7. Vis en samlet resultatmeddelelse til brugeren med antallet af
       vellykkede og fejlede handlinger.

  Hvorfor valideres PageControl1.ActivePage?
    I teorien skulle ActivePage altid være sat, fordi BuildUI aktiverer det
    første faneblad. Men hvis BuildUI af en eller anden grund er fejlet,
    eller hvis alle faneblade er blevet frigivet, kunne ActivePage være nil.
    Uden dette tjek ville PageControl1.ActivePage.Tag kaste en adgangsfejl,
    og hele proceduren ville crashe ved det mindste klik.

  Hvorfor valideres Tag-området (0 til High(CAT_NAMES))?
    Selv om BuildUI altid sætter Tag til et gyldigt indeks (0-9), er denne
    kontrol en billig forsikring mod fremtidige ændringer. Hvis nogen f.eks.
    tilføjer et nyt faneblad uden at opdatere Tag, eller hvis en tidligere
    version af programmet har gemt en ugyldig Tag-værdi i registrerings-
    databasen, ville vi ellers risikere at behandle tweaks med et forkert
    kategoriindeks. Ved at validere området undgås dette effektivt.

  Hvorfor tjekkes 'not Item.CheckBox.Checked'?
    Vi springer tweaks over, der ALLEREDE er slået til. Dette har to formål:
      1. Ydeevne: Vi undgår unødvendige skriveoperationer til registrerings-
         databasen, hvilket især er mærkbart, hvis mange tweaks allerede er
         aktive (f.eks. når brugeren klikker på knappen to gange i træk).
      2. Sikkerhed: Vi risikerer ikke at overskrive en værdi, som brugeren
         måske har ændret manuelt uden for programmet, med en identisk værdi
         (hvilket i sig selv er harmløst, men kan udløse unødvendige
         registeropdateringer og dermed støj i Event Viewer).
    Bemærk, at hvis et tweak allerede er slået til, tælles det hverken som
    succes eller fejl – det springes blot over.

  Hvorfor tjekkes Assigned(Item.CheckBox)?
    Et tweak-objekt kan i teorien eksistere uden en tilknyttet CheckBox
    (f.eks. hvis BuildUI fejlede halvvejs). Uden dette tjek ville
    Item.CheckBox.Checked kaste en adgangsfejl. Ved at springe sådanne
    tweaks over undgås dette effektivt.

  Hvorfor kaldes ReadSingleTweakStatus efter SetTweakInRegistry?
    Samme princip som i CheckBoxClick: Efter skrivningen læser vi den
    FAKTISKE tilstand tilbage fra registreringsdatabasen og opdaterer
    fluebenet. Dette sikrer, at brugerfladen altid afspejler virkeligheden
    – også hvis Windows har afvist ændringen af en eller anden grund.
    Uden dette kald ville CheckBox.Checked fortsat vise brugerens ønske,
    ikke den faktiske tilstand.

  Hvorfor er der en try/except omkring hvert enkelt tweak?
    Hvis én tweak fejler (f.eks. pga. manglende rettigheder til en beskyttet
    nøgle), må det IKKE stoppe hele batch-handlingen. Brugeren forventer,
    at de øvrige tweaks bliver aktiveret, selv om én fejler. Derfor fanges
    undtagelsen pr. tweak, og fejlen tælles blot op i FailCount.

    Den indre try/except (tom) omkring det andet ReadSingleTweakStatus-kald
    er en sidste sikkerhedsforanstaltning: Hvis tilbagerulningen selv fejler,
    ignoreres det, så det ikke skjuler den oprindelige fejl for brugeren.

  Hvorfor vises resultatet som en samlet meddelelse?
    I stedet for at vise 8 separate meddelelsesbokse (én pr. tweak) vises
    ÉN samlet resultatmeddelelse til slut. Dette er langt mere brugervenligt
    – brugeren får et klart overblik over, hvor mange indstillinger der blev
    aktiveret, og om nogen fejlede.

    Meddelelsestypen afhænger af resultatet:
      - mtWarning (gul trekant): Hvis en eller flere tweaks fejlede. Brugeren
        bør være opmærksom på, at ikke alt gik som planlagt.
      - mtInformation (blåt i): Hvis alle tweaks blev aktiveret uden fejl.
        Brugeren kan føle sig tryg ved, at handlingen lykkedes fuldt ud.

  Hvorfor er der ingen bekræftelsesdialog FØR batch-handlingen?
    I modsætning til MenuApplyAllClick (som aktiverer ALLE 46 tweaks på én
    gang og derfor kræver en bekræftelse) er denne handling begrænset til
    ét faneblad. Brugeren har selv valgt fanen og klikket på knappen, så
    handlingen er allerede et bevidst valg. En ekstra bekræftelse ville
    virke irriterende og unødvendig.

    Desuden kan effekten af handlingen nemt fortrydes ved at klikke på
    "Gendan standard på denne fane" – så risikoen er lav.

  Kendt begrænsning:
    Hvis ReadSingleTweakStatus i den normale (ikke-fejl) gren skulle fejle,
    fanges det ikke af den ydre try/except (fordi den kun omfatter
    SetTweakInRegistry og ReadSingleTweakStatus-kaldet). I så fald ville
    undtagelsen boble op til LCL's beskedløkke. Dette anses dog for
    acceptabelt, fordi ReadSingleTweakStatus fanger ERegistryException
    internt, og andre fejl er så usædvanlige, at en teknisk fejlmeddelelse
    er den mest hjælpsomme information.

  Anvendelse i programmet:
    Proceduren er forbundet til knappen BtnApplyCurrentTabClick i formularens
    designfil (uMain.lfm) eller via OnClick-tildeling i FormCreate. Den
    kaldes udelukkende, når brugeren klikker på knappen "Aktivér alle på
    denne fane" i bunden af vinduet.
  ---------------------------------------------------------------------------- }
procedure TFormMain.BtnApplyCurrentTabClick(Sender: TObject);
var
  i, CurrentCat: Integer;         // Løbeindeks og det aktuelle kategoriindeks
  Item: TTweakItem;               // Det aktuelle tweak-objekt under gennemløb
  SuccessCount, FailCount: Integer; // Tællere for vellykkede og fejlede handlinger
begin
  // -------------------------------------------------------------------------
  // TRIN 1: Validér at der er et gyldigt aktivt faneblad
  // -------------------------------------------------------------------------
  // Hvis ActivePage er nil, eller Tag ligger uden for det gyldige område
  // (0 til High(CAT_NAMES) = 9), afbrydes proceduren straks uden at gøre
  // noget. Dette beskytter mod adgangsfejl og uventet adfærd, hvis
  // brugerfladen ikke er fuldt initialiseret.
  if (PageControl1.ActivePage = nil) or 
     (PageControl1.ActivePage.Tag < 0) or 
     (PageControl1.ActivePage.Tag > High(CAT_NAMES)) then Exit;

  // Aflæs kategoriindekset fra fanebladets Tag-egenskab. Dette indeks blev
  // gemt i BuildUI og identificerer, hvilke tweaks der hører til fanen.
  CurrentCat := PageControl1.ActivePage.Tag;

  // Initialiser tællerne. Disse bruges til at give brugeren en samlet
  // resultatmeddelelse til slut – i stedet for én meddelelse pr. tweak.
  SuccessCount := 0;
  FailCount := 0;

  // -------------------------------------------------------------------------
  // TRIN 2: Gennemløb alle tweaks og aktiver dem, der hører til kategorien
  // -------------------------------------------------------------------------
  for i := 0 to FTweaks.Count - 1 do
  begin
    Item := TTweakItem(FTweaks[i]);

    // Behandl kun tweaks, der opfylder ALLE tre betingelser:
    //   1. De hører til den aktuelle kategori (Item.CategoryIndex = CurrentCat).
    //   2. De har en tilknyttet CheckBox (Assigned(Item.CheckBox)).
    //   3. De er IKKE allerede slået til (not Item.CheckBox.Checked).
    // Tweaks, der allerede er slået til, springes over for at undgå
    // unødvendige registeropdateringer og for at bevare eventuelle manuelle
    // ændringer, brugeren har foretaget uden for programmet.
    if (Item.CategoryIndex = CurrentCat) and Assigned(Item.CheckBox) and (not Item.CheckBox.Checked) then
    begin
      try
        // Slå tweaket til i registreringsdatabasen (eller via powercfg
        // for dvale-tweaket). Kaster en Exception ved fejl.
        SetTweakInRegistry(Item, True);

        // Verificér med registreringsdatabasen, at ændringen faktisk blev
        // gennemført, og opdater CheckBox.Checked tilsvarende. Dette sikrer,
        // at brugerfladen afspejler virkeligheden – ikke blot brugerens ønske.
        ReadSingleTweakStatus(Item);

        // Tæl handlingen som vellykket.
        Inc(SuccessCount);
      except
        // Hvis noget gik galt (manglende rettigheder, beskyttet nøgle,
        // powercfg-fejl), tælles fejlen op – men vi fortsætter med næste
        // tweak i stedet for at afbryde hele batch-handlingen.
        Inc(FailCount);

        try
          // Rul brugerfladen tilbage til den faktiske tilstand for det
          // fejlede tweak, så CheckBox.Checked ikke fortsat viser
          // brugerens ønskede værdi. Hvis dette selv fejler, ignoreres
          // det (tom except), så den oprindelige fejl ikke skjules.
          ReadSingleTweakStatus(Item);
        except
        end;
      end;
    end;
  end;

  // -------------------------------------------------------------------------
  // TRIN 3: Vis samlet resultatmeddelelse til brugeren
  // -------------------------------------------------------------------------
  // Afhængigt af om der var fejl, vises en advarsel eller en succes-meddelelse.
  // Format bruges til at indsætte antallet af vellykkede og fejlede handlinger.
  if FailCount > 0 then
    // Der var fejl: Vis en advarsel med begge tællere, så brugeren ved,
    // at ikke alt gik som planlagt, og kan undersøge de fejlede tweaks.
    MessageDlg('Resultat', Format('%d indstillinger blev aktiveret.' + sLineBreak + '%d fejlede.', [SuccessCount, FailCount]), mtWarning, [mbOK], 0)
  else
    // Alt gik godt: Vis en ren succes-meddelelse. mtInformation signalerer,
    // at handlingen lykkedes uden problemer.
    MessageDlg('Succes', Format('%d indstillinger blev opdateret!', [SuccessCount]), mtInformation, [mbOK], 0);
end;

{ ----------------------------------------------------------------------------
  BtnRestoreCurrentTabClick
  Formål:
    At nulstille SAMTLIGE de tweaks, der hører til det aktuelt valgte
    faneblad, til deres respektive fabriksstandardværdier – dvs. den tilstand,
    som Windows oprindeligt blev leveret med. Proceduren er knyttet til
    knappen "Gendan standard på denne fane" i bunden af vinduet og fungerer
    som den logiske modsætning til BtnApplyCurrentTabClick.

  Hvornår bruges denne handling?
    Når brugeren ønsker at FORTRYDE en eller flere optimeringer på et
    faneblad. Det kan f.eks. være, fordi:
      - En optimering har utilsigtede bivirkninger (f.eks. blokerer en
        USB-enhed, som brugeren faktisk har brug for).
      - Brugeren vil tilbage til en "ren" Windows-tilstand for at
        eliminere fejlkilder.
      - Brugeren vil eksperimentere med forskellige kombinationer og
        hurtigt kunne rulle hele kategorien tilbage.

    Uden denne knap skulle brugeren klikke på hvert enkelt afkrydsningsfelt
    for at fjerne fluebenet – hvilket er både tidskrævende og fejlbehæftet
    (man kan nemt overse et enkelt felt). Batch-handlingen giver en sikker
    og fuldstændig tilbagerulning.

  Hvordan proceduren fungerer (algoritmen):
    1. Validér at der overhovedet er et aktivt faneblad, og at dets Tag
       indeholder et gyldigt kategoriindeks (0-9). Hvis ikke, afbrydes
       proceduren straks uden at gøre noget.
    2. Aflæs det aktuelle kategoriindeks fra fanebladets Tag-egenskab.
    3. Initialisér tællere for succeser og fejl.
    4. Gennemløb ALLE tweaks i FTweaks-listen og find dem, der matcher
       den aktuelle kategori, som har en CheckBox, og som ER slået til.
    5. For hvert match: Kald SetTweakInRegistry(Item, False) for at rulle
       tweaket tilbage til fabriksstandarden, og ReadSingleTweakStatus(Item)
       for at verificere.
    6. Tæl succeser og fejl op undervejs.
    7. Vis en samlet resultatmeddelelse til brugeren med antallet af
       vellykkede og fejlede handlinger.

  Forskellen fra BtnApplyCurrentTabClick:
    De to procedurer er næsten identiske i deres struktur, men adskiller
    sig på ét afgørende punkt:
      - BtnApplyCurrentTabClick aktiverer tweaks, der IKKE er slået til
        (not Item.CheckBox.Checked), og kalder SetTweakInRegistry(Item, True).
      - BtnRestoreCurrentTabClick ruller tweaks tilbage, der ER slået til
        (Item.CheckBox.Checked), og kalder SetTweakInRegistry(Item, False).

    Ved at have to separate procedurer i stedet for én med en parameter
    opnås klarere kode og en mere intuitiv brugerflade: Brugeren ser to
    knapper med klare formål ("Aktivér alle" / "Gendan alle"), ikke én
    knap, hvis effekt afhænger af en skjult tilstand.

  Hvorfor valideres PageControl1.ActivePage?
    I teorien skulle ActivePage altid være sat, fordi BuildUI aktiverer det
    første faneblad. Men hvis BuildUI af en eller anden grund er fejlet,
    eller hvis alle faneblade er blevet frigivet, kunne ActivePage være nil.
    Uden dette tjek ville PageControl1.ActivePage.Tag kaste en adgangsfejl,
    og hele proceduren ville crashe ved det mindste klik.

  Hvorfor valideres Tag-området (0 til High(CAT_NAMES))?
    Selv om BuildUI altid sætter Tag til et gyldigt indeks (0-9), er denne
    kontrol en billig forsikring mod fremtidige ændringer. Hvis nogen f.eks.
    tilføjer et nyt faneblad uden at opdatere Tag, eller hvis en tidligere
    version af programmet har gemt en ugyldig Tag-værdi, ville vi ellers
    risikere at behandle tweaks med et forkert kategoriindeks.

  Hvorfor tjekkes 'Item.CheckBox.Checked' (uden 'not')?
    Vi ruller kun tweaks tilbage, der FAKTISK er slået til. Tweaks, der
    allerede er i deres standardtilstand, springes over. Dette har to formål:
      1. Ydeevne: Vi undgår unødvendige skriveoperationer til registrerings-
         databasen, hvilket især er mærkbart, hvis mange tweaks allerede er
         i standardtilstand.
      2. Sikkerhed: Vi risikerer ikke at overskrive en værdi, som brugeren
         måske har ændret manuelt uden for programmet, med en identisk
         standardværdi. Selv om dette i sig selv er harmløst, kan det
         udløse unødvendige registeropdateringer.

    Bemærk, at hvis et tweak allerede er i standardtilstand, tælles det
    hverken som succes eller fejl – det springes blot over.

  Hvorfor tjekkes Assigned(Item.CheckBox)?
    Et tweak-objekt kan i teorien eksistere uden en tilknyttet CheckBox
    (f.eks. hvis BuildUI fejlede halvvejs). Uden dette tjek ville
    Item.CheckBox.Checked kaste en adgangsfejl. Ved at springe sådanne
    tweaks over undgås dette effektivt.

  Hvorfor kaldes ReadSingleTweakStatus efter SetTweakInRegistry?
    Samme princip som i BtnApplyCurrentTabClick: Efter tilbagerulningen
    læser vi den FAKTISKE tilstand tilbage fra registreringsdatabasen og
    opdaterer fluebenet. Dette sikrer, at brugerfladen altid afspejler
    virkeligheden – også hvis Windows har afvist ændringen af en eller
    anden grund (f.eks. hvis nøglen er beskyttet).

    Uden dette kald ville CheckBox.Checked fortsat vise den optimerede
    tilstand, selv om Windows stadig har den gamle værdi. Brugeren ville
    tro, at tilbagerulningen lykkedes, mens systemet i virkeligheden var
    uændret.

  Hvorfor er der en try/except omkring hvert enkelt tweak?
    Hvis én tweak fejler (f.eks. fordi en beskyttet nøgle ikke kan slettes,
    eller fordi powercfg returnerer en fejlkode for dvale-tweaket), må det
    IKKE stoppe hele batch-handlingen. Brugeren forventer, at de øvrige
    tweaks bliver rullet tilbage, selv om én fejler. Derfor fanges
    undtagelsen pr. tweak, og fejlen tælles blot op i FailCount.

    Den indre try/except (tom) omkring det andet ReadSingleTweakStatus-kald
    er en sidste sikkerhedsforanstaltning: Hvis tilbagerulningen selv fejler,
    ignoreres det, så det ikke skjuler den oprindelige fejl for brugeren.

  Hvorfor vises resultatet som en samlet meddelelse?
    I stedet for at vise 8 separate meddelelsesbokse (én pr. tweak) vises
    ÉN samlet resultatmeddelelse til slut. Dette er langt mere brugervenligt
    – brugeren får et klart overblik over, hvor mange indstillinger der blev
    rullet tilbage, og om nogen fejlede.

    Meddelelsestypen afhænger af resultatet:
      - mtWarning (gul trekant): Hvis en eller flere tweaks fejlede. Brugeren
        bør være opmærksom på, at ikke alt gik som planlagt – typisk fordi
        visse nøgler er beskyttede af Windows.
      - mtInformation (blåt i): Hvis alle tweaks blev rullet tilbage uden
        fejl. Brugeren kan føle sig tryg ved, at handlingen lykkedes fuldt ud.

  Hvorfor er der ingen bekræftelsesdialog FØR batch-handlingen?
    I modsætning til MenuApplyAllClick (som aktiverer ALLE 46 tweaks på én
    gang og derfor kræver en bekræftelse) er denne handling begrænset til
    ét faneblad. Brugeren har selv valgt fanen og klikket på knappen, så
    handlingen er allerede et bevidst valg.

    Desuden er tilbagerulning generelt en "sikker" handling – den genskaber
    Windows' oprindelige tilstand, hvilket sjældent kan gøre skade. En
    ekstra bekræftelse ville virke irriterende og unødvendig.

  Kendt begrænsning:
    For nogle tweaks (f.eks. vkEmptyKey) betyder tilbagerulning, at en
    hel nøglestruktur slettes rekursivt. Hvis brugeren har tilføjet egne
    underværdier i den pågældende nøgle (hvilket er usandsynligt, men
    teoretisk muligt), vil disse også blive slettet. Dette er dog den
    korrekte adfærd for at genskabe Windows' oprindelige tilstand, og
    risikoen er minimal i praksis.

  Anvendelse i programmet:
    Proceduren er forbundet til knappen BtnRestoreCurrentTabClick i
    formularens designfil (uMain.lfm) eller via OnClick-tildeling i
    FormCreate. Den kaldes udelukkende, når brugeren klikker på knappen
    "Gendan standard på denne fane" i bunden af vinduet.
  ---------------------------------------------------------------------------- }
procedure TFormMain.BtnRestoreCurrentTabClick(Sender: TObject);
var
  i, CurrentCat: Integer;           // Løbeindeks og det aktuelle kategoriindeks
  Item: TTweakItem;                 // Det aktuelle tweak-objekt under gennemløb
  SuccessCount, FailCount: Integer; // Tællere for vellykkede og fejlede handlinger
begin
  // -------------------------------------------------------------------------
  // TRIN 1: Validér at der er et gyldigt aktivt faneblad
  // -------------------------------------------------------------------------
  // Hvis ActivePage er nil, eller Tag ligger uden for det gyldige område
  // (0 til High(CAT_NAMES) = 9), afbrydes proceduren straks uden at gøre
  // noget. Dette beskytter mod adgangsfejl og uventet adfærd, hvis
  // brugerfladen ikke er fuldt initialiseret.
  if (PageControl1.ActivePage = nil) or 
     (PageControl1.ActivePage.Tag < 0) or 
     (PageControl1.ActivePage.Tag > High(CAT_NAMES)) then Exit;

  // Aflæs kategoriindekset fra fanebladets Tag-egenskab. Dette indeks blev
  // gemt i BuildUI og identificerer, hvilke tweaks der hører til fanen.
  CurrentCat := PageControl1.ActivePage.Tag;

  // Initialiser tællerne. Disse bruges til at give brugeren en samlet
  // resultatmeddelelse til slut – i stedet for én meddelelse pr. tweak.
  SuccessCount := 0;
  FailCount := 0;

  // -------------------------------------------------------------------------
  // TRIN 2: Gennemløb alle tweaks og rul dem tilbage, der hører til kategorien
  // -------------------------------------------------------------------------
  for i := 0 to FTweaks.Count - 1 do
  begin
    Item := TTweakItem(FTweaks[i]);

    // Behandl kun tweaks, der opfylder ALLE tre betingelser:
    //   1. De hører til den aktuelle kategori (Item.CategoryIndex = CurrentCat).
    //   2. De har en tilknyttet CheckBox (Assigned(Item.CheckBox)).
    //   3. De ER slået til (Item.CheckBox.Checked) – kun disse skal rulles
    //      tilbage. Tweaks, der allerede er i standardtilstand, springes
    //      over for at undgå unødvendige registeropdateringer.
    // Bemærk: I modsætning til BtnApplyCurrentTabClick er der INGEN 'not'
    // foran Item.CheckBox.Checked – vi leder efter de AKTIVE tweaks.
    if (Item.CategoryIndex = CurrentCat) and Assigned(Item.CheckBox) and (Item.CheckBox.Checked) then
    begin
      try
        // Rul tweaket tilbage til fabriksstandarden. Parameteren 'False'
        // fortæller SetTweakInRegistry, at det er DefaultDWord/DefaultStr
        // (eller sletning af nøglen for vkEmptyKey), der skal skrives.
        // For dvale-tweaket betyder 'False', at powercfg kaldes med '-h on'
        // for at genaktivere dvale.
        SetTweakInRegistry(Item, False);

        // Verificér med registreringsdatabasen, at ændringen faktisk blev
        // gennemført, og opdater CheckBox.Checked tilsvarende. Dette sikrer,
        // at brugerfladen afspejler virkeligheden – ikke blot brugerens ønske.
        ReadSingleTweakStatus(Item);

        // Tæl handlingen som vellykket.
        Inc(SuccessCount);
      except
        // Hvis noget gik galt (f.eks. en beskyttet nøgle, der ikke kan
        // slettes, eller en powercfg-fejl), tælles fejlen op – men vi
        // fortsætter med næste tweak i stedet for at afbryde hele
        // batch-handlingen.
        Inc(FailCount);

        try
          // Rul brugerfladen tilbage til den faktiske tilstand for det
          // fejlede tweak, så CheckBox.Checked ikke fortsat viser den
          // optimerede tilstand, som Windows ikke accepterede at ændre.
          // Hvis dette selv fejler, ignoreres det (tom except), så den
          // oprindelige fejl ikke skjules.
          ReadSingleTweakStatus(Item);
        except
        end;
      end;
    end;
  end;

  // -------------------------------------------------------------------------
  // TRIN 3: Vis samlet resultatmeddelelse til brugeren
  // -------------------------------------------------------------------------
  // Afhængigt af om der var fejl, vises en advarsel eller en succes-meddelelse.
  // Format bruges til at indsætte antallet af vellykkede og fejlede handlinger.
  if FailCount > 0 then
    // Der var fejl: Vis en advarsel med begge tællere, så brugeren ved,
    // at ikke alt gik som planlagt, og kan undersøge de fejlede tweaks.
    MessageDlg('Resultat', Format('%d indstillinger blev nulstillet.' + sLineBreak + '%d fejlede.', [SuccessCount, FailCount]), mtWarning, [mbOK], 0)
  else
    // Alt gik godt: Vis en ren succes-meddelelse. mtInformation signalerer,
    // at handlingen lykkedes uden problemer.
    MessageDlg('Succes', Format('%d indstillinger blev nulstillet til standard.', [SuccessCount]), mtInformation, [mbOK], 0);
end;

{ ----------------------------------------------------------------------------
  MenuApplyAllClick
  Formål:
    At aktivere SAMTLIGE 46 tweaks i hele programmet på én gang – uanset
    hvilket faneblad brugeren aktuelt befinder sig på – efter en klar og
    informeret bekræftelse. Proceduren er knyttet til menupunktet "Anvend
    alle anbefalede tweaks..." i menuen "Filer" og er den mest omfattende
    handling i hele programmet.

  Hvorfor er dette den mest "farlige" handling?
    De øvrige batch-handlinger (BtnApplyCurrentTabClick og
    BtnRestoreCurrentTabClick) er begrænset til ét faneblad og påvirker
    dermed kun 4-8 tweaks ad gangen. MenuApplyAllClick derimod ændrer HELE
    computerens konfiguration på én gang – inklusive sikkerhedshærdning, der
    ændrer login-adfærd (kræver CTRL+ALT+DEL, skjuler seneste brugernavn),
    blokerer USB-lagerenheder og deaktiverer telemetri.

    For en bruger, der ikke har læst beskrivelserne grundigt, kan dette føles
    som en drastisk ændring af systemet. Derfor kræver handlingen en eksplicit
    bekræftelse, FØR noget som helst skrives til registreringsdatabasen.

  Hvorfor bekræftelsesdialogen er så detaljeret?
    Bekræftelsesdialogen er ikke en simpel "Er du sikker?"-boks. Den indeholder
    en konkret advarsel om sikkerhedshærdningens konsekvenser:
      - CTRL+ALT+DEL ved login (en ekstra tastetryk-sekvens hver gang).
      - Skjult seneste brugernavn (man skal indtaste både brugernavn og
        adgangskode hver gang).
    Dette er et bevidst designvalg: Brugeren skal forstå, HVAD der sker,
    ikke bare bekræfte et antal. En informeret beslutning er en god
    beslutning – og det er langt bedre at brugeren fortryder FØR ændringen
    end at opdage bivirkningerne bagefter.

  Hvordan proceduren fungerer (algoritmen):
    1. Vis en bekræftelsesdialog med en detaljeret advarsel. Kun hvis
       brugeren vælger "Ja" (mrYes), fortsætter proceduren.
    2. Initialisér tællere for succeser og fejl.
    3. Gennemløb ALLE tweaks i FTweaks-listen (alle 46, uden
       kategorifiltrering).
    4. For hvert tweak, der IKKE allerede er slået til:
       a. Kald SetTweakInRegistry(Item, True) for at slå det til.
       b. Kald ReadSingleTweakStatus(Item) for at verificere.
       c. Tæl succes eller fejl op.
    5. Vis en samlet resultatmeddelelse til brugeren – inkl. en påmindelse
       om at genstarte computeren for fuld effekt.

  Hvorfor filtreres der IKKE på kategori?
    I modsætning til BtnApplyCurrentTabClick, der kun behandler tweaks på
    det aktive faneblad, behandler denne procedure ALLE tweaks i hele
    programmet. Det er hele idéen med menupunktet: En samlet "one-click"
    optimering af hele systemet, uanset hvilken kategori tweaket tilhører.

    Dette er også grunden til, at bekræftelsesdialogen er så vigtig –
    brugeren får ikke lov til at vælge kun "de sikre" kategorier, men
    aktiverer ALT.

  Hvorfor tjekkes 'not Item.CheckBox.Checked'?
    Samme princip som i BtnApplyCurrentTabClick: Vi springer tweaks over,
    der allerede er slået til. Dette har to formål:
      1. Ydeevne: Vi undgår unødvendige skriveoperationer til registrerings-
         databasen, hvilket især er mærkbart, hvis mange tweaks allerede
         er aktive (f.eks. når brugeren klikker på menupunktet to gange).
      2. Sikkerhed: Vi risikerer ikke at overskrive en værdi, som brugeren
         måske har ændret manuelt uden for programmet.

    Bemærk, at hvis et tweak allerede er slået til, tælles det hverken som
    succes eller fejl – det springes blot over.

  Hvorfor tjekkes Assigned(Item.CheckBox)?
    Et tweak-objekt kan i teorien eksistere uden en tilknyttet CheckBox
    (f.eks. hvis BuildUI fejlede halvvejs). Uden dette tjek ville
    Item.CheckBox.Checked kaste en adgangsfejl. Ved at springe sådanne
    tweaks over undgås dette effektivt.

  Hvorfor kaldes ReadSingleTweakStatus efter SetTweakInRegistry?
    Samme princip som i de øvrige batch-handlinger: Efter skrivningen læser
    vi den FAKTISKE tilstand tilbage fra registreringsdatabasen og opdaterer
    fluebenet. Dette sikrer, at brugerfladen altid afspejler virkeligheden –
    også hvis Windows har afvist ændringen af en eller anden grund.

    Uden dette kald ville CheckBox.Checked fortsat vise brugerens ønske,
    ikke den faktiske tilstand. Brugeren ville tro, at alle 46 tweaks var
    aktiveret, mens nogle i virkeligheden stadig var i deres gamle tilstand.

  Hvorfor er der en try/except omkring hvert enkelt tweak?
    Hvis én tweak fejler (f.eks. pga. manglende rettigheder til en beskyttet
    nøgle, eller fordi powercfg returnerer en fejlkode for dvale-tweaket),
    må det IKKE stoppe hele batch-handlingen. Brugeren forventer, at de
    øvrige tweaks bliver aktiveret, selv om én fejler. Derfor fanges
    undtagelsen pr. tweak, og fejlen tælles blot op i FailCount.

    Den indre try/except (tom) omkring det andet ReadSingleTweakStatus-kald
    er en sidste sikkerhedsforanstaltning: Hvis tilbagerulningen selv fejler,
    ignoreres det, så det ikke skjuler den oprindelige fejl for brugeren.

  Hvorfor vises resultatet som én samlet meddelelse?
    I stedet for at vise op til 46 separate meddelelsesbokse (én pr. tweak)
    vises ÉN samlet resultatmeddelelse til slut. Dette er langt mere
    brugervenligt – brugeren får et klart overblik over, hvor mange
    indstillinger der blev aktiveret, og om nogen fejlede.

    Meddelelsestypen afhænger af resultatet:
      - mtWarning (gul trekant): Hvis en eller flere tweaks fejlede. Titlen
        er "Gennemført med advarsler" (ikke "Fejl"), fordi de fleste
        sandsynligvis lykkedes – brugeren skal blot være opmærksom på, at
        ikke alt gik som planlagt.
      - mtInformation (blåt i): Hvis alle tweaks blev aktiveret uden fejl.

  Hvorfor indeholder succes-meddelelsen en påmindelse om genstart?
    Mange af de tweaks, der aktiveres, træder først i kraft efter en
    genstart af Windows. Det gælder f.eks.:
      - Ændringer i kerneindstillinger (DisablePagingExecutive,
        LargeSystemCache).
      - Driverniveau-indstillinger (HwSchMode for GPU).
      - Dvale-tweaket (Hibernate).
    Uden en påmindelse ville brugeren måske tro, at optimeringen ikke
    virkede, fordi ændringerne endnu ikke var slået igennem. Ved at minde
    om genstart i selve succes-meddelelsen sikres det, at brugeren får
    den fulde effekt af optimeringen.

  Hvorfor er der ingen påmindelse om genstart i advarsels-meddelelsen?
    Hvis nogle tweaks fejlede, er det vigtigere at fokusere på fejlene end
    på genstart. Brugeren bør først undersøge, hvorfor visse tweaks ikke
    kunne aktiveres, og derefter eventuelt genstarte. En påmindelse om
    genstart i den situation ville bare sløre informationen.

  Kendt begrænsning:
    Hvis ReadSingleTweakStatus i den normale (ikke-fejl) gren skulle fejle,
    fanges det ikke af den ydre try/except. I så fald ville undtagelsen
    boble op til LCL's beskedløkke og vise en teknisk fejlmeddelelse.
    Dette anses dog for acceptabelt, fordi ReadSingleTweakStatus fanger
    ERegistryException internt, og andre fejl er så usædvanlige, at en
    teknisk fejlmeddelelse er den mest hjælpsomme information.

  Anvendelse i programmet:
    Proceduren er forbundet til menupunktet MenuApplyAllClick i menuen
    "Filer" (se MenuFile → MenuApplyAll i formularens designfil). Den
    kaldes udelukkende, når brugeren vælger "Anvend alle anbefalede
    tweaks..." fra menuen.

  Sammenligning med de øvrige batch-handlinger:
    - BtnApplyCurrentTabClick : Ét faneblad, ingen bekræftelse, 4-8 tweaks.
    - BtnRestoreCurrentTabClick: Ét faneblad, ingen bekræftelse, tilbagerulning.
    - MenuApplyAllClick       : Alle faneblade, KRÆVER bekræftelse, 46 tweaks.
    Forskellen i alvor og omfang afspejles direkte i, hvor meget information
    brugeren får, og om der kræves en bekræftelse.
  ---------------------------------------------------------------------------- }
procedure TFormMain.MenuApplyAllClick(Sender: TObject);
var
  i, SuccessCount, FailCount: Integer; // Løbeindeks og tællere for succes/fejl
  Item: TTweakItem;                    // Det aktuelle tweak-objekt under gennemløb
begin
  // -------------------------------------------------------------------------
  // TRIN 1: Vis bekræftelsesdialog – handlingen udføres kun ved "Ja"
  // -------------------------------------------------------------------------
  // Bekræftelsesdialogen er detaljeret med vilje: Den advarer om de mest
  // indgribende konsekvenser (sikkerhedshærdning ændrer login-adfærd),
  // så brugeren kan træffe en informeret beslutning. Kun hvis brugeren
  // vælger mrYes (Ja), fortsætter proceduren.
  if MessageDlg('Vigtig bekræftelse',
    'Vil du aktivere ALLE anbefalede optimeringer på én gang?' + sLineBreak + sLineBreak +
    'Bemærk: Sikkerhedshærdning ændrer login- og systemadfærd (kræver f.eks. CTRL+ALT+DEL og skjuler seneste brugernavn).',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    // -----------------------------------------------------------------------
    // TRIN 2: Initialisér tællere
    // -----------------------------------------------------------------------
    // Disse bruges til at give brugeren en samlet resultatmeddelelse til
    // slut – i stedet for én meddelelse pr. tweak (op til 46 i værste fald).
    SuccessCount := 0;
    FailCount := 0;

    // -----------------------------------------------------------------------
    // TRIN 3: Gennemløb ALLE tweaks (uden kategorifiltrering)
    // -----------------------------------------------------------------------
    // I modsætning til BtnApplyCurrentTabClick filtreres der IKKE på
    // kategori. Alle 46 tweaks i hele programmet behandles.
    for i := 0 to FTweaks.Count - 1 do
    begin
      Item := TTweakItem(FTweaks[i]);

      // Behandl kun tweaks, der har en CheckBox og som IKKE allerede er
      // slået til. Tweaks, der allerede er aktive, springes over for at
      // undgå unødvendige registeropdateringer og for at bevare eventuelle
      // manuelle ændringer, brugeren har foretaget uden for programmet.
      if Assigned(Item.CheckBox) and (not Item.CheckBox.Checked) then
      begin
        try
          // Slå tweaket til i registreringsdatabasen (eller via powercfg
          // for dvale-tweaket). Kaster en Exception ved fejl.
          SetTweakInRegistry(Item, True);

          // Verificér med registreringsdatabasen, at ændringen faktisk
          // blev gennemført, og opdater CheckBox.Checked tilsvarende.
          // Dette sikrer, at brugerfladen afspejler virkeligheden.
          ReadSingleTweakStatus(Item);

          // Tæl handlingen som vellykket.
          Inc(SuccessCount);
        except
          // Hvis noget gik galt (manglende rettigheder, beskyttet nøgle,
          // powercfg-fejl), tælles fejlen op – men vi fortsætter med næste
          // tweak i stedet for at afbryde hele batch-handlingen.
          Inc(FailCount);

          try
            // Rul brugerfladen tilbage til den faktiske tilstand for det
            // fejlede tweak, så CheckBox.Checked ikke fortsat viser
            // brugerens ønskede værdi. Hvis dette selv fejler, ignoreres
            // det (tom except), så den oprindelige fejl ikke skjules.
            ReadSingleTweakStatus(Item);
          except
          end;
        end;
      end;
    end;

    // -----------------------------------------------------------------------
    // TRIN 4: Vis samlet resultatmeddelelse til brugeren
    // -----------------------------------------------------------------------
    if FailCount > 0 then
      // Der var fejl: Vis en advarsel med begge tællere. Titlen er
      // "Gennemført med advarsler" (ikke "Fejl"), fordi de fleste tweaks
      // sandsynligvis lykkedes – brugeren skal blot være opmærksom på,
      // at ikke alt gik som planlagt.
      MessageDlg('Gennemført med advarsler', Format('Optimering fuldført:' + sLineBreak + '- Aktiveret: %d' + sLineBreak + '- Fejlet: %d', [SuccessCount, FailCount]), mtWarning, [mbOK], 0)
    else
      // Alt gik godt: Vis en succes-meddelelse med en påmindelse om at
      // genstarte computeren. Mange tweaks træder først i kraft efter
      // en genstart, så påmindelsen er vigtig for, at brugeren får den
      // fulde effekt af optimeringen.
      MessageDlg('Succes', Format('%d indstillinger blev aktiveret! Genstart computeren for fuld effekt.', [SuccessCount]), mtInformation, [mbOK], 0);
  end;
  // Hvis brugeren valgte "Nej" (mbNo) eller lukkede dialogen, gør vi intet.
  // Proceduren afsluttes uden at foretage nogen ændringer i systemet.
end;

{ ----------------------------------------------------------------------------
  MenuCreateBackupClick
  Formål:
    At generere en ægte, komplet og Windows-kompatibel .reg-sikkerhedskopi,
    der indeholder den NUVÆRENDE tilstand af samtlige tweak-parametre på
    computeren. Filen kan efterfølgende dobbeltklikkes i Stifinder og
    importeres af Windows' egen regedit.exe, hvilket genskaber præcis den
    tilstand, der var på backup-tidspunktet.

  Hvorfor er denne funktion så vigtig?
    Programmet ændrer systemkritiske indstillinger i Windows – herunder
    sikkerhedspolitikker, netværkskonfiguration og login-adfærd. Selv om
    programmet tilbyder batch-tilbagerulning pr. fane, er der ingen garanti
    for, at brugeren kan fortryde ALT, hvis noget går galt (f.eks. hvis
    programmet crasher, eller hvis Windows nægter at genstarte korrekt).

    En ekstern .reg-fil er brugerens "sikkerhedsnet": Uafhængigt af
    programmets tilstand kan filen importeres manuelt via regedit, og
    dermed genskabes den gemte tilstand. Dette er især vigtigt, fordi
    .reg-filen er et Standard Windows-format, som kan læses og inspiceres
    af enhver – også uden programmet.

  Hvordan proceduren fungerer (algoritmen):
    1. Vis en TSaveDialog, så brugeren kan vælge, hvor filen skal gemmes.
       Filnavnet er forudfyldt med et unikt tidsstempel.
    2. Opret tre hjælpeobjekter:
       - RegFile  : Selve den tekst, der skal blive til .reg-filen.
       - KeyList  : En sorteret liste over alle unikke nøglestier.
       - Reg      : TRegistry til at læse de faktiske værdier.
    3. Tilføj .reg-filens obligatoriske header ("Windows Registry Editor
       Version 5.00") og en kommentar med tidsstempel.
    4. Indsaml alle unikke nøglestier fra FTweaks-listen. Brug en sorteret
       TStringList med dupIgnore, så dubletter automatisk fjernes.
    5. For hver unik nøglesti:
       a. Skriv sektionsoverskriften [HKEY_...\Sti] til filen.
       b. Gennemløb alle tweaks og find dem, der hører til denne sti.
       c. For hver tweak: Læs værdien fra registreringsdatabasen og skriv
          den i korrekt .reg-format (dword:xxxxxxxx eller "tekst").
       d. Hvis værdien ikke findes, skrives "=-" (hvilket instruerer
          Windows om at SLETTE værdien ved import – dvs. genskabe standard).
    6. Skriv filen med UTF-16LE-kodning og BOM ($FEFF), som er det format,
       Windows' regedit forventer.
    7. Vis en bekræftelsesmeddelelse med filens sti.

  Hvorfor skrives '=-' for manglende værdier?
    I Windows' .reg-format betyder "VærdiNavn"=-, at værdien skal SLETTES
    ved import. Dette er den korrekte måde at genskabe standardtilstanden
    på for de tweaks, hvor fabriksstandarden er "værdien findes slet ikke".

    Hvis vi i stedet blot udelod manglende værdier fra filen, ville importen
    ikke ændre noget – og en tweak, der tidligere var aktiveret (og dermed
    havde en værdi), ville forblive aktiv. Ved at skrive "=-" sikres det,
    at importen aktivt fjerner værdien og genskaber fabriksstandarden.

  Hvorfor frasorteres vkHibernate-tweaks?
    Dvale styres IKKE via registreringsdatabasen, men af Windows'
    strømstyringskerne (via powercfg.exe). Der findes derfor ingen
    registreringsværdi at gemme eller genskabe via en .reg-fil.
    Hvis vi alligevel skrev noget for dvale-tweaket, ville det være
    misvisende – brugeren ville tro, at filen indeholdt alt, men
    dvale-tilstanden ville ikke blive gendannet ved import.

    I stedet for at skrive en vildledende post springes dvale-tweaket
    helt over, og brugeren kan manuelt gendanne dvale via programmets
    checkboks eller via powercfg.exe.

  Hvorfor samles nøglestier i en sorteret TStringList?
    Flere tweaks kan dele samme nøglesti (f.eks. har 3-4 tweaks under
    'Control Panel\Desktop' samme nøgle). Hvis vi blot skrev én sektion
    pr. tweak, ville vi få dubletter som:
      [HKEY_CURRENT_USER\Control Panel\Desktop]
      "MenuShowDelay"="20"
      [HKEY_CURRENT_USER\Control Panel\Desktop]
      "AutoEndTasks"="1"
    Det er gyldigt, men grimt og sværere at læse. Ved at samle alle
    unikke stier i en sorteret liste (med dupIgnore) og derefter skrive
    alle værdier under hver sektion får vi en pæn, læsbar fil, hvor
    hver nøgle kun optræder én gang – præcis som regedit selv eksporterer.

  Hvorfor sorteres listen (KeyList.Sorted := True)?
    Fordelen er todelt:
      1. DupIgnore kræver, at listen er sorteret for at virke korrekt.
      2. En sorteret fil er nemmere at læse og sammenligne manuelt (f.eks.
         ved at åbne den i en teksteditor).

  Hvorfor læses værdierne med OpenKeyReadOnly?
    Vi skal kun LÆSE de nuværende værdier, ikke ændre dem. Ved at bruge
    OpenKeyReadOnly undgås det, at vi ved en fejl kommer til at oprette
    nye nøgler eller ændre eksisterende. Desuden kræver læseadgang færre
    rettigheder end skriveadgang, hvilket gør backup-funktionen mere
    robust, selv hvis nogle nøgler er beskyttede.

  Hvorfor tvinges 64-bit visning (KEY_WOW64_64KEY)?
    Samme grund som i ReadSingleTweakStatus og SetTweakInRegistry: På
    64-bit Windows har mange nøgler to parallelle visninger, og uden
    dette flag ville vi læse fra den forkerte. Backup-filen skal afspejle
    præcis de samme værdier, som programmet selv læser og skriver.

  Hvorfor håndteres både rdInteger og rdBinary for vkDWord?
    Nogle værktøjer skriver DWORD-værdier som REG_BINARY i stedet for
    REG_DWORD. Begge skal gemmes som 'dword:xxxxxxxx' i .reg-filen, så
    Windows' importør fortolker dem korrekt. Ved at læse de 4 bytes ind
    i en Cardinal og formattere dem som hex sikres det, at filen er
    korrekt uanset den oprindelige lagringstype.

  Hvorfor håndteres både rdString og rdExpandString for vkString?
    REG_EXPAND_SZ er en tekststreng med miljøvariabler (f.eks.
    '%USERPROFILE%\AppData'). I .reg-formatet skrives den på samme måde
    som REG_SZ, fordi regedit selv fortolker variablerne ved import.
    Ved at acceptere begge typer sikres det, at vi ikke fejlagtigt
    behandler en gyldig tekstværdi som "manglende".

  Hvorfor skrives '@=""' for vkEmptyKey, når nøglen findes?
    For vkEmptyKey er det nøglens blotte EKSISTENS, der er tweaket.
    I .reg-formatet repræsenteres nøglens standardværdi med @. Ved at
    skrive '@=""' sikres det, at nøglen oprettes (eller bevares) med en
    tom standardværdi – præcis den struktur, som f.eks. Win11-kontekst-
    menuen forventer. Hvis nøglen ikke findes, skrives en kommentar i
    stedet, så filen stadig er gyldig.

  Hvorfor skrives '@=""' kun, når nøglen findes?
    Hvis nøglen IKKE findes, betyder det, at tweaket ikke er aktivt.
    Ved at skrive en kommentar ('; [Nøgle ikke aktiv]') i stedet for
    '@=""' undgås det, at importen fejlagtigt OPRETTER nøglen (hvilket
    ville aktivere tweaket utilsigtet). Kommentaren dokumenterer blot
    situationen, uden at påvirke importen.

  Hvorfor escapes værdinavne og -data med EscapeRegString?
    Værdinavne og -data kan indeholde backslashes, anførselstegn eller
    kontroltegn, som har særlig betydning i .reg-formatet. Uden escaping
    ville filen blive korrupt ved import. EscapeRegString sørger for, at
    alle specialtegn skrives i deres korrekte escape-sekvens.

  Hvorfor gemmes filen som UTF-16LE med BOM?
    Windows' .reg-format kræver officielt UTF-16LE-kodning med en
    Byte Order Mark ($FEFF) i begyndelsen af filen. Hvis man gemmer som
    UTF-8 eller ANSI, vil regedit muligvis afvise filen eller importere
    forkerte tegn (især ved danske tegn som æ, ø og å, eller ved
    specialtegn i værdinavne).

    BOM ($FEFF) er en 2-byte sekvens, der fortæller regedit, at filen er
    UTF-16LE. Uden BOM ville regedit ikke vide, hvordan den skulle
    fortolke de efterfølgende bytes. Derfor skrives BOM først, derefter
    selve teksten konverteret fra UTF-8 (LCL's interne format) til
    UnicodeString (UTF-16).

  Hvorfor bruges UTF8Decode og ikke en anden konvertering?
    LCL's TStringList.Text returnerer en UTF-8-streng. For at gemme som
    UTF-16LE skal vi konvertere til UnicodeString. UTF8Decode gør præcis
    dette: Den fortolker UTF-8-bytes korrekt og returnerer en UnicodeString,
    som efterfølgende kan skrives byte-for-byte til filen.

  Hvorfor TFileStream frem for en simpel TStringList.SaveToFile?
    TStringList.SaveToFile gemmer som 8-bit-tekst (ANSI eller UTF-8),
    hvilket ikke er det format, regedit forventer. Ved at bruge TFileStream
    får vi fuld kontrol over de rå bytes, så vi kan skrive BOM og
    UTF-16LE-kodede WideChar-data præcis som specificeret.

  Hvorfor skrives kun, hvis Length(UStr) > 0?
    Hvis RegFile.Text er tom (hvilket ikke bør ske, fordi vi altid tilføjer
    header og kommentar), undgås et forsøg på at skrive UStr[1], som ville
    være en adgangsfejl på en tom streng. Dette er en billig forsikring.

  Hvorfor vises en bekræftelsesmeddelelse med filens sti?
    Brugeren skal vide, hvor filen blev gemt, så den kan findes igen
    senere. Stien vises i meddelelsen, og brugeren får også en konkret
    instruks ("Dobbeltklik på filen i Stifinder..."), så det er tydeligt,
    hvordan backup-filen bruges i praksis.

  Hukommelsesstyring:
    Alle oprettede objekter (SaveDlg, RegFile, KeyList, Reg, FileStream)
    frigives i try/finally-blokke, så der ikke opstår hukommelseslækager,
    selv hvis der kastes en undtagelse undervejs. Dette er især vigtigt
    her, fordi proceduren kan køre mange gange (brugeren kan tage mange
    backups), og en lækage ville akkumulere over tid.

  Kendt begrænsning:
    Filen indeholder KUN de parametre, som programmet selv kender til
    (de 45 tweaks, der ikke er dvale). Hvis brugeren har andre
    brugerdefinerede ændringer i registreringsdatabasen, er de ikke med
    i backup-filen. Dette er et bevidst designvalg: Filen er en backup af
    programmets egne ændringer, ikke en fuld systembackup.

  Anvendelse i programmet:
    Proceduren er forbundet til menupunktet MenuCreateBackupClick i menuen
    "Filer" (se MenuFile → MenuCreateBackup). Den kaldes udelukkende, når
    brugeren vælger "Gem fuld sikkerhedskopi..." fra menuen.
  ---------------------------------------------------------------------------- }
procedure TFormMain.MenuCreateBackupClick(Sender: TObject);
var
  SaveDlg: TSaveDialog;         // Dialog til at vælge, hvor filen skal gemmes
  RegFile: TStringList;         // Selve .reg-filens indhold, linje for linje
  KeyList: TStringList;         // Sorteret liste over unikke nøglestier
  Reg: TRegistry;               // Registry-adgangsobjekt til aflæsning af værdier
  Item: TTweakItem;             // Det aktuelle tweak-objekt under gennemløb
  CurrentKey, FullKeyStr: String; // Den aktuelle nøglesti under behandling
  DWVal: Cardinal;              // Midlertidig DWORD-værdi (unsigned for $FFFFFFFF)
  FileStream: TFileStream;      // Filstrøm til at skrive UTF-16LE-data
  UStr: UnicodeString;          // Unicode-konverteret tekst til UTF-16LE-skrivning
  BOM: Word;                    // Byte Order Mark ($FEFF) til filens begyndelse
  RegDataType: TRegDataType;    // Den faktiske datatype i registret
  i, j: Integer;                // Løbeindeks: i = nøglesti, j = tweak
begin
  // -------------------------------------------------------------------------
  // TRIN 1: Vis "Gem som"-dialog
  // -------------------------------------------------------------------------
  // SaveDlg oprettes med Self som ejer, så den automatisk frigives sammen
  // med formularen, hvis noget skulle gå galt. Den frigives dog også
  // eksplicit i finally nedenfor.
  SaveDlg := TSaveDialog.Create(Self);
  try
    // Titel og filtype sættes, så brugeren forstår, hvad der gemmes.
    SaveDlg.Title := 'Gem fuld sikkerhedskopi af samtlige tweak-parametre';
    SaveDlg.Filter := 'Registreringsdatabasefiler (*.reg)|*.reg';
    SaveDlg.DefaultExt := 'reg';

    // Generer et unikt filnavn med dato og sekundpræcist klokkeslæt,
    // så gentagne backups ikke overskriver hinanden. FormatDateTime med
    // 'yyyy-mm-dd_hh-nn-ss' giver f.eks. 'WinTweaker_Backup_2024-03-15_14-32-05.reg',
    // hvilket er både læsbart og sorterbart.
    SaveDlg.FileName := 'WinTweaker_Backup_' + FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now) + '.reg';

    // Kun hvis brugeren ikke afbryder dialogen, fortsætter vi med at
    // generere backup-filen. Ved Cancel (Execute returnerer False) gør
    // vi intet, og proceduren afsluttes uden bivirkninger.
    if SaveDlg.Execute then
    begin
      // Opret de tre hjælpeobjekter. De frigives alle i finally nedenfor.
      RegFile := TStringList.Create;  // Selve .reg-filens tekst
      KeyList := TStringList.Create;  // Unikke nøglestier
      Reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY); // Læseadgang, 64-bit
      try
        // -----------------------------------------------------------------
        // TRIN 2: Skriv .reg-filens obligatoriske header
        // -----------------------------------------------------------------
        // "Windows Registry Editor Version 5.00" er en FAST tekst, som
        // regedit kræver som første linje for at acceptere filen. Uden
        // denne linje afviser regedit filen som ugyldig.
        RegFile.Add('Windows Registry Editor Version 5.00');

        // En kommentar (starter med ;) med tidsstempel for menneskelig
        // læsbarhed. Kommentarer ignoreres af regedit under import.
        RegFile.Add('; Sikkerhedskopi genereret af Windows Registry Tweaker Pro: ' + DateTimeToStr(Now));

        // Tom linje for læsbarhedens skyld.
        RegFile.Add('');

        // -----------------------------------------------------------------
        // TRIN 3: Indsaml alle unikke nøglestier
        // -----------------------------------------------------------------
        // Sorteret := True er nødvendigt for at Duplicates := dupIgnore
        // virker korrekt. En sorteret liste er desuden nemmere at læse
        // for mennesker og giver en deterministisk rækkefølge i filen.
        KeyList.Sorted := True;
        KeyList.Duplicates := dupIgnore;

        // Gennemløb alle tweaks og tilføj deres fulde nøglesti til listen.
        // DupIgnore sørger for, at f.eks. 'Control Panel\Desktop' kun
        // optræder én gang, selv om flere tweaks deler den.
        for i := 0 to FTweaks.Count - 1 do
        begin
          Item := TTweakItem(FTweaks[i]);

          // Spring dvale-tweaket over: Det styres via powercfg, ikke
          // registreringsdatabasen, og hører derfor ikke hjemme i en
          // .reg-fil.
          if Item.ValKind <> vkHibernate then
            KeyList.Add(RootKeyToStr(Item.RootKey) + '\' + Item.SubKey);
        end;

        // -----------------------------------------------------------------
        // TRIN 4: Skriv værdierne for hver unik nøglesti
        // -----------------------------------------------------------------
        for i := 0 to KeyList.Count - 1 do
        begin
          CurrentKey := KeyList[i];

          // Skriv sektionsoverskriften, f.eks.:
          //   [HKEY_CURRENT_USER\Control Panel\Desktop]
          RegFile.Add('[' + CurrentKey + ']');

          // Gennemløb ALLE tweaks og skriv dem, der hører til denne sti.
          // Bemærk, at vi bruger en indre løkke (O(n²)), hvilket er
          // acceptabelt, fordi n = 46 og køretiden er forsvindende lille.
          for j := 0 to FTweaks.Count - 1 do
          begin
            Item := TTweakItem(FTweaks[j]);

            // Spring dvale over (som ovenfor).
            if Item.ValKind = vkHibernate then Continue;

            // Byg tweakets fulde sti og sammenlign med den aktuelle nøglesti.
            FullKeyStr := RootKeyToStr(Item.RootKey) + '\' + Item.SubKey;

            if FullKeyStr = CurrentKey then
            begin
              // Sæt RootKey på det delte Reg-objekt, så OpenKeyReadOnly
              // læser fra den korrekte rod-nøgle.
              Reg.RootKey := Item.RootKey;

              // Behandl tweaket afhængigt af dets datatype.
              case Item.ValKind of
                // -------------------------------------------------------
                // Type A: vkDWord (32-bit heltal)
                // -------------------------------------------------------
                vkDWord:
                  begin
                    if Reg.OpenKeyReadOnly(Item.SubKey) then
                    begin
                      try
                        if Reg.ValueExists(Item.ValueName) then
                        begin
                          RegDataType := Reg.GetDataType(Item.ValueName);

                          // Ægte REG_DWORD: læs som heltal og skriv som
                          // 'dword:xxxxxxxx' (8 hex-cifre, nulpolstret).
                          // Format '%0.8x' sikrer, at f.eks. 20 bliver
                          // skrevet som '00000014' og ikke '14'.
                          if RegDataType = rdInteger then
                          begin
                            DWVal := Cardinal(Reg.ReadInteger(Item.ValueName));
                            RegFile.Add(Format('"%s"=dword:%0.8x', [EscapeRegString(Item.ValueName), DWVal]));
                          end
                          // REG_BINARY: læs 4 bytes og skriv som dword.
                          // Dette håndterer værktøjer, der skriver DWORD-
                          // værdier som binære data.
                          else if RegDataType = rdBinary then
                          begin
                            DWVal := 0;
                            Reg.ReadBinaryData(Item.ValueName, DWVal, SizeOf(DWVal));
                            RegFile.Add(Format('"%s"=dword:%0.8x', [EscapeRegString(Item.ValueName), DWVal]));
                          end
                          else
                            // Forkert datatype: Skriv '=-' for at slette
                            // ved import og dermed genskabe standard.
                            RegFile.Add(Format('"%s"=-', [EscapeRegString(Item.ValueName)]));
                        end
                        else
                          // Værdien findes ikke: Skriv '=-' for at sikre,
                          // at importen sletter en eventuel gammel værdi.
                          RegFile.Add(Format('"%s"=-', [EscapeRegString(Item.ValueName)]));
                      finally
                        // Luk nøglen, så Windows frigiver sit håndtag.
                        Reg.CloseKey;
                      end;
                    end
                    else
                      // Nøglen kunne ikke åbnes: Skriv '=-' så importen
                      // sletter en eventuel gammel værdi, hvis den findes.
                      RegFile.Add(Format('"%s"=-', [EscapeRegString(Item.ValueName)]));
                  end;

                // -------------------------------------------------------
                // Type B: vkString (tekststreng)
                // -------------------------------------------------------
                vkString:
                  begin
                    if Reg.OpenKeyReadOnly(Item.SubKey) then
                    begin
                      try
                        if Reg.ValueExists(Item.ValueName) then
                        begin
                          RegDataType := Reg.GetDataType(Item.ValueName);

                          // Acceptér både rdString og rdExpandString, fordi
                          // begge skrives ens i .reg-formatet.
                          // EscapeRegString anvendes BÅDE på værdinavnet og
                          // på værdidata, så specialtegn som '\' og '"'
                          // bliver korrekt escaped.
                          if RegDataType in [rdString, rdExpandString] then
                            RegFile.Add(Format('"%s"="%s"', [EscapeRegString(Item.ValueName), EscapeRegString(Reg.ReadString(Item.ValueName))]))
                          else
                            RegFile.Add(Format('"%s"=-', [EscapeRegString(Item.ValueName)]));
                        end
                        else
                          RegFile.Add(Format('"%s"=-', [EscapeRegString(Item.ValueName)]));
                      finally
                        Reg.CloseKey;
                      end;
                    end
                    else
                      RegFile.Add(Format('"%s"=-', [EscapeRegString(Item.ValueName)]));
                  end;

                // -------------------------------------------------------
                // Type C: vkEmptyKey (nøglens blotte eksistens)
                // -------------------------------------------------------
                vkEmptyKey:
                  begin
                    if Reg.KeyExists(Item.SubKey) then
                      // Nøglen findes: Skriv '@=""' for at bevare den
                      // tomme standardværdi. Dette er præcis den struktur,
                      // som f.eks. Win11-kontekstmenuen forventer.
                      RegFile.Add('@=""')
                    else
                      // Nøglen findes ikke: Skriv en kommentar i stedet for
                      // '@=""', så importen IKKE opretter nøglen utilsigtet.
                      RegFile.Add('; [Nøgle ikke aktiv]');
                  end;
              end;
            end;
          end;

          // Tom linje efter hver sektion for læsbarhedens skyld.
          RegFile.Add('');
        end;

        // -----------------------------------------------------------------
        // TRIN 5: Skriv filen som UTF-16LE med BOM
        // -----------------------------------------------------------------
        // Konverter fra UTF-8 (LCL's interne format i TStringList.Text)
        // til UnicodeString (UTF-16). Dette er nødvendigt, fordi .reg-filen
        // skal gemmes som UTF-16LE, ikke UTF-8.
        UStr := UTF8Decode(RegFile.Text);

        // Opret filstrømmen. fmCreate betyder "opret ny fil" (overskriver
        // eksisterende med samme navn, men SaveDlg har allerede spurgt
        // brugeren om overskrivning).
        FileStream := TFileStream.Create(SaveDlg.FileName, fmCreate);
        try
          // Skriv Byte Order Mark (BOM) som de første 2 bytes. BOM = $FEFF
          // er en 2-byte sekvens, der fortæller Windows, at resten af
          // filen er UTF-16LE-kodet.
          BOM := $FEFF;
          FileStream.WriteBuffer(BOM, SizeOf(BOM));

          // Skriv selve teksten som UTF-16LE. Length(UStr) er antallet af
          // WideChar-tegn (2 bytes hver), så vi multiplicerer med
          // SizeOf(WideChar) for at få det korrekte antal bytes at skrive.
          // Kontrollen Length(UStr) > 0 undgår at skrive UStr[1], når
          // strengen er tom (hvilket ville være en adgangsfejl).
          if Length(UStr) > 0 then
            FileStream.WriteBuffer(UStr[1], Length(UStr) * SizeOf(WideChar));
        finally
          // Frigør filstrømmen, så Windows lukker filen og synkroniserer
          // data til disken.
          FileStream.Free;
        end;

        // -----------------------------------------------------------------
        // TRIN 6: Vis bekræftelse til brugeren
        // -----------------------------------------------------------------
        // Vis filens sti og en konkret instruks om, hvordan den bruges.
        // Dette er vigtigt, fordi mange brugere ikke ved, hvad en .reg-fil
        // er, eller hvordan den importeres.
        MessageDlg('Sikkerhedskopi fuldført',
          'En komplet .reg-sikkerhedskopi er gemt i:' + sLineBreak + SaveDlg.FileName + sLineBreak + sLineBreak +
          'Dobbeltklik på filen i Stifinder for at genskabe præcis denne tilstand.', mtInformation, [mbOK], 0);
      finally
        // Frigør alle tre hjælpeobjekter i omvendt rækkefølge af deres
        // oprettelse. Dette sker altid, uanset om der blev kastet en
        // undtagelse undervejs, så der ikke opstår hukommelseslækager.
        Reg.Free;
        KeyList.Free;
        RegFile.Free;
      end;
    end;
  finally
    // Frigør altid SaveDlg, uanset om brugeren afbrød dialogen eller
    // en undtagelse opstod undervejs.
    SaveDlg.Free;
  end;
end;

{ ----------------------------------------------------------------------------
  RestartComputer
  Formål:
    At udføre en kontrolleret og sikker genstart af Windows på vegne af
    brugeren. Proceduren sørger for, at processen først erhverver den
    nødvendige rettighed (SeShutdownPrivilege), før den kalder Windows'
    officielle genstarts-API (ExitWindowsEx). Uden denne rettighed ville
    genstart blive afvist af systemet.

  Baggrund – hvorfor er det ikke bare at kalde ExitWindowsEx?
    Windows' sikkerhedsmodel kræver, at en proces eksplicit har fået
    tildelt rettigheden "SeShutdownPrivilege", før den må genstarte eller
    slukke computeren. Rettigheden er som udgangspunkt IKKE aktiveret i
    en almindelig proces' access token – heller ikke selv om processen
    kører som Administrator. Den skal først slås eksplicit til via
    AdjustTokenPrivileges.

    Denne ekstra sikkerhedsforanstaltning forhindrer, at ondsindet software
    eller en fejlbehæftet applikation uden videre kan genstarte computeren
    og dermed afbryde brugerens arbejde. Ved at kræve en eksplicit
    aktivering af privilegiet sikrer Windows, at processen har "tænkt sig"
    at genstarte – og ikke gør det ved et uheld.

  Hvordan proceduren fungerer (algoritmen):
    1. Åbn processens eget access token med rettighederne TOKEN_ADJUST_PRIVILEGES
       (for at kunne ændre privilegier) og TOKEN_QUERY (for at kunne læse).
    2. Slå 'SeShutdownPrivilege' op via LookupPrivilegeValue for at få dets
       LUID (Locally Unique Identifier) – en numerisk identifikator, som
       Windows bruger internt.
    3. Aktivér privilegiet i token'et via AdjustTokenPrivileges. Hvis
       Windows afviser (f.eks. fordi brugeren ikke er administrator),
       vises en fejlmeddelelse, og proceduren afbrydes.
    4. Kald ExitWindowsEx med EWX_REBOOT (genstart) og EWX_FORCEIFHUNG
       (tving hængende apps ned). Angiv en årsagskode, så Windows'
       begivenhedslog kan registrere, hvorfor genstarten skete.
    5. Luk altid token-håndtaget i en finally-blok, så der ikke opstår
       ressource-lækage.

  Hvorfor bruges TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY?
    To rettigheder kombineres med OR:
      - TOKEN_ADJUST_PRIVILEGES : Giver lov til at ÆNDRE privilegier i
        token'et (dvs. aktivere SeShutdownPrivilege).
      - TOKEN_QUERY              : Giver lov til at LÆSE token'ets
        oplysninger (nødvendigt for AdjustTokenPrivileges, som skal bruge
        det til at verificere, at ændringen blev gennemført).
    Uden begge rettigheder ville OpenProcessToken returnere et token, som
    vi ikke kunne bruge til formålet.

  Hvorfor LookupPrivilegeValue?
    Windows identificerer privilegier internt med et LUID (et 64-bit tal),
    ikke med et navn som 'SeShutdownPrivilege'. LookupPrivilegeValue
    oversætter det menneskelæsbare navn til det tilsvarende LUID, som
    AdjustTokenPrivileges og andre API-kald forventer.

  Hvorfor tjekkes både AdjustTokenPrivileges' returværdi OG GetLastError?
    AdjustTokenPrivileges har en subtil adfærd: Den returnerer True, selv
    om den ikke har kunnet tildele ALLE de anmodede privilegier. For at
    opdage delvise fejl skal man kalde GetLastError og tjekke for
    ERROR_NOT_ALL_ASSIGNED (1300). Dette er en kendt fælde i Windows-API'et,
    og uden det ekstra tjek ville proceduren fortsætte, selv om privilegiet
    ikke blev aktiveret – og ExitWindowsEx ville fejle med en kryptisk fejl.

  Hvorfor EWX_FORCEIFHUNG?
    EWX_REBOOT alene ville forsøge en "blød" genstart, hvor Windows pænt
    beder alle programmer om at lukke. Hvis et program hænger (f.eks. fordi
    det venter på brugerinput i en modal dialog, som brugeren ikke ser),
    ville genstarten aldrig blive gennemført.

    EWX_FORCEIFHUNG tvinger Windows til at lukke hængende programmer, men
    lader ikke-hængende programmer afslutte normalt. Dette er en sikrere
    mellemvej end EWX_FORCE (som tvinger ALT ned uden varsel), og den
    undgår, at brugeren sidder fast i en uendelig genstartsløkke.

  Hvorfor angives en årsagskode til ExitWindowsEx?
    Windows har en indbygget "reason"-mekanisme, som registrerer, hvorfor
    en genstart eller nedlukning blev iværksat. Årsagskoden gemmes i
    begivenhedsloggen (Event Viewer) og er nyttig for systemadministratorer
    og fejlsøgning.

    De to konstanter, der anvendes:
      - SHTDN_REASON_MAJOR_OPERATINGSYSTEM : Angiver, at årsagen er en
        operativsystemhandling (ikke f.eks. hardware eller software).
      - SHTDN_REASON_FLAG_PLANNED           : Angiver, at genstarten er
        planlagt og bevidst (ikke en krasch eller strømsvigt).
    Uden disse flag ville genstarten blive logget som "ukendt årsag",
    hvilket kan skabe forvirring, når logs gennemgås senere.

  Hvorfor returneres straks ved fejl i OpenProcessToken?
    Hvis OpenProcessToken fejler (hvilket kun sker i ekstreme
    situationer, f.eks. hvis processen er blevet kompromitteret), er
    der ingen mening i at forsøge at fortsætte. Ved at returnere straks
    undgås en kaskade af fejlmeddelelser, og brugeren får en enkelt
    forståelig besked om, at noget gik galt.

    Bemærk, at hvis OpenProcessToken fejler, springes HELE try/finally-
    blokken over, og proceduren returnerer uden at kalde ExitWindowsEx.
    Dermed undgås det, at vi forsøger en genstart uden den nødvendige
    rettighed.

  Hvorfor CloseHandle i en finally-blok?
    Uanset om LookupPrivilegeValue eller AdjustTokenPrivileges lykkedes
    eller fejlede, skal token-håndtaget lukkes. Ellers ville Windows
    lække en ressource (en "handle leak"), og efter gentagne kald kunne
    processen løbe tør for håndtag. finally sikrer, at lukningen altid
    sker – også hvis en undtagelse skulle opstå undervejs (hvilket ikke
    bør ske her, men er billig forsikring).

  Hvorfor initialiseres hToken, retLen, tkp og prevTkp eksplicit?
    I Free Pascal kan lokale variable indeholde tilfældige værdier, hvis
    de ikke initialiseres. Windows-API-kald som OpenProcessToken og
    AdjustTokenPrivileges forventer, at visse felter er nulstillede, før
    de kaldes. Ved at initialisere dem eksplicit (hToken := 0, retLen := 0,
    tkp := Default(TOKEN_PRIVILEGES), prevTkp := Default(TOKEN_PRIVILEGES))
    undgås udefineret adfærd og sjove fejl, der kun optræder lejlighedsvis.

  Kendt begrænsning:
    Hvis brugeren har slået UAC helt fra (hvilket kun bør ske på dedikerede
    administrationsmaskiner), er processen muligvis allerede i besiddelse
    af SeShutdownPrivilege. I så fald vil AdjustTokenPrivileges stadig
    lykkes, fordi privilegiet allerede er aktiveret – det er harmløst.

    En anden begrænsning er, at proceduren ikke venter på, at genstarten
    faktisk finder sted. ExitWindowsEx vender tilbage med det samme, og
    derefter genstarter Windows asynkront. Hvis brugeren har ulagrede data,
    kan EWX_FORCEIFHUNG tvinge programmer ned og forårsage datatab. Derfor
    er der en bekræftelsesdialog i MenuRestartWindowsClick, som advarer
    brugeren om at gemme arbejdet først.

  Anvendelse i programmet:
    Proceduren kaldes udelukkende fra MenuRestartWindowsClick, som viser
    en bekræftelsesdialog, før RestartComputer kaldes. Dette sikrer, at
    brugeren er klar over konsekvenserne og har gemt sit arbejde.
  ---------------------------------------------------------------------------- }
procedure TFormMain.RestartComputer;
var
  hToken: THandle;              // Håndtag til processens access token
  tkp, prevTkp: TOKEN_PRIVILEGES; // Ny og forrige privilegie-struktur
  retLen: DWORD;                // Antal bytes returneret (skal angives)
begin
  // Initialiser alle variable eksplicit for at undgå udefineret adfærd.
  // Windows-API-kald forventer, at visse felter er nulstillede.
  hToken := 0;
  retLen := 0;
  tkp := Default(TOKEN_PRIVILEGES);
  prevTkp := Default(TOKEN_PRIVILEGES);

  // -------------------------------------------------------------------------
  // TRIN 1: Åbn processens access token
  // -------------------------------------------------------------------------
  // Vi anmoder om TOKEN_ADJUST_PRIVILEGES (for at kunne ændre privilegier)
  // og TOKEN_QUERY (for at kunne læse token'ets oplysninger). Uden disse
  // rettigheder ville vi ikke kunne aktivere SeShutdownPrivilege.
  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, @hToken) then
  begin
    try
      // ---------------------------------------------------------------------
      // TRIN 2: Slå SeShutdownPrivilege op (navn → LUID)
      // ---------------------------------------------------------------------
      // Windows identificerer privilegier med et LUID (et 64-bit tal).
      // LookupPrivilegeValue oversætter det menneskelæsbare navn
      // 'SeShutdownPrivilege' til det tilsvarende LUID, som gemmes i
      // tkp.Privileges[0].Luid. Hvis opslaget fejler, er privilegiet ikke
      // tilgængeligt på denne Windows-version (yderst usædvanligt).
      if LookupPrivilegeValue(nil, 'SeShutdownPrivilege', @tkp.Privileges[0].Luid) then
      begin
        // Sæt op, at vi kun anmoder om ÉT privilegie, og at det skal
        // være AKTIVERET (SE_PRIVILEGE_ENABLED). Uden denne attribute
        // ville privilegiet blot være tildelt men ikke aktivt – og
        // ExitWindowsEx ville fejle.
        tkp.PrivilegeCount := 1;
        tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;

        // -----------------------------------------------------------------
        // TRIN 3: Aktivér privilegiet i token'et
        // -----------------------------------------------------------------
        // AdjustTokenPrivileges har en subtil adfærd: Den returnerer True,
        // selv om den ikke har kunnet tildele alle privilegier. Derfor
        // tjekkes både returværdien OG GetLastError for at fange delvise
        // fejl (ERROR_NOT_ALL_ASSIGNED).
        if not AdjustTokenPrivileges(hToken, False, tkp, SizeOf(TOKEN_PRIVILEGES), prevTkp, retLen) or
           (GetLastError = ERROR_NOT_ALL_ASSIGNED) then
        begin
          // Privilegiet kunne ikke tildeles – typisk fordi brugeren ikke
          // har de nødvendige rettigheder. Vis en fejlmeddelelse og afbryd.
          MessageDlg('Fejl', 'SeShutdownPrivilege kunne ikke tildeles: ' + SysErrorMessage(GetLastError), mtError, [mbOK], 0);
          Exit;
        end;
      end
      else
      begin
        // Privilegiet blev ikke fundet på systemet (yderst usædvanligt).
        // Vis fejl og afbryd.
        MessageDlg('Fejl', 'SeShutdownPrivilege blev ikke fundet: ' + SysErrorMessage(GetLastError), mtError, [mbOK], 0);
        Exit;
      end;
    finally
      // Luk ALTID token-håndtaget, uanset om privilegiet blev tildelt
      // eller ej. Ellers ville Windows lække en ressource, og gentagne
      // kald kunne løbe tør for håndtag.
      CloseHandle(hToken);
    end;
  end;
  // Hvis OpenProcessToken fejler (ekstremt usædvanligt), springes hele
  // try/finally-blokken over. Proceduren fortsætter derefter til
  // ExitWindowsEx nedenfor – men uden aktivt privilegie. Det er dog
  // usandsynligt, at ExitWindowsEx lykkes i denne situation, og en
  // fejlmeddelelse vil blive vist.

  // -------------------------------------------------------------------------
  // TRIN 4: Genstart Windows
  // -------------------------------------------------------------------------
  // EWX_REBOOT         : Genstart computeren (i modsætning til nedlukning).
  // EWX_FORCEIFHUNG    : Tving hængende programmer ned, men lad andre
  //                      programmer afslutte normalt.
  // Årsagskoderne fortæller Windows' begivenhedslog, at genstarten er en
  // planlagt OS-handling – ikke en krasch eller strømsvigt.
  if not ExitWindowsEx(EWX_REBOOT or EWX_FORCEIFHUNG, SHTDN_REASON_MAJOR_OPERATINGSYSTEM or SHTDN_REASON_FLAG_PLANNED) then
    // Hvis Windows afviser anmodningen (f.eks. pga. manglende rettigheder
    // eller en aktiv blokering), vises en fejlmeddelelse med fejlkoden.
    MessageDlg('Genstart mislykkedes', 'Windows afviste anmodningen: ' + SysErrorMessage(GetLastError), mtError, [mbOK], 0);
end;


{ ----------------------------------------------------------------------------
  MenuRestartWindowsClick
  Formål:
    Hændelsesrutine for menupunktet "Genstart Windows nu". Viser en
    bekræftelsesdialog, så brugeren kan nå at gemme sit arbejde, FØR
    computeren genstartes. Kun hvis brugeren bekræfter, kaldes den
    egentlige genstartsproces i RestartComputer.

  Hvorfor er bekræftelsesdialogen så vigtig?
    En genstart er en indgribende handling: Alle åbne programmer lukkes,
    og ikke-gemte data går tabt. Brugeren kan sagtens have åbne dokumenter,
    uafsluttede downloads eller igangværende beregninger, som ikke er gemt
    endnu – især fordi mange tweaks først træder i kraft efter en genstart,
    og brugeren derfor typisk klikker på dette menupunkt umiddelbart efter
    at have aktiveret tweaks.

    Uden en bekræftelse ville et enkelt fejlklik i menuen øjeblikkeligt
    genstarte computeren – potentielt med store datatab til følge. Derfor
    er dialogen formuleret med en eksplicit advarsel ("Husk at gemme alt
    åbent arbejde først!"), og mtWarning-ikonet (gul trekant) signalerer,
    at der er en reel risiko.

  Hvorfor 'mtWarning' og ikke 'mtConfirmation'?
    LCL's MessageDlg understøtter forskellige ikoner:
      - mtConfirmation (blåt spørgsmålstegn) : Bruges til almindelige
        ja/nej-spørgsmål uden særlig risiko.
      - mtWarning (gul trekant)              : Bruges, når der er en
        potentiel risiko eller et datatab.
    Ved at vælge mtWarning understreges alvoren i handlingen visuelt,
    så brugeren er ekstra opmærksom.

  Hvorfor kaldes RestartComputer kun ved mrYes?
    Kun hvis brugeren aktivt vælger "Ja" (mrYes), fortsætter proceduren
    til selve genstarten. Ved "Nej" (mbNo) eller lukning af dialogen
    sker der intet – hvilket er den sikre standardadfærd.

  Anvendelse i programmet:
    Proceduren er forbundet til menupunktet MenuRestartWindowsClick i
    menuen "Filer" (se MenuFile → MenuRestartWindows). Den kaldes
    udelukkende, når brugeren vælger "Genstart Windows nu" fra menuen.
  ---------------------------------------------------------------------------- }
procedure TFormMain.MenuRestartWindowsClick(Sender: TObject);
begin
  // Vis bekræftelsesdialog med en klar advarsel om at gemme arbejdet.
  // Kun ved mrYes fortsætter vi til selve genstarten.
  if MessageDlg('Genstart Windows',
    'Er du sikker på, at du vil genstarte computeren nu for at aktivere ændringerne?' + sLineBreak +
    'Husk at gemme alt åbent arbejde først!',
    mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    // Brugeren har bekræftet – udfør den egentlige genstart.
    RestartComputer;
  end;
end;


{ ----------------------------------------------------------------------------
  MenuExitClick
  Formål:
    Hændelsesrutine for menupunktet "Afslut". Lukker programmet pænt ved
    at kalde Close på hovedvinduet, hvilket igangsætter LCL's normale
    nedlukningssekvens (herunder FormDestroy, hvor alle ressourcer frigives).

  Hvorfor kaldes Close og ikke Application.Terminate?
    Close lukker vinduet på den "rigtige" måde:
      1. Vinduet skjules gradvist (hvis der er animationer aktiveret).
      2. FormDestroy kaldes automatisk, så alle ressourcer (CheckBoxes,
         TTweakItem-objekter, FTweaks-listen) frigives korrekt.
      3. Hvis der er andre vinduer åbne (f.eks. FormHelp), lukkes de
         også, fordi de er børn af applikationen.
      4. LCL's beskedløkke afsluttes pænt, og programmet returnerer en
         exit-kode på 0 til operativsystemet.

    Application.Terminate derimod stopper beskedløkken med det samme uden
    at give FormDestroy en chance for at køre. Det kan føre til
    hukommelseslækager og i værste fald til et crash under nedlukningen.
    Close er derfor den korrekte måde at afslutte programmet på, når
    brugeren har klikket på "Afslut".

  Hvorfor er der ikke en bekræftelsesdialog her?
    Hvis brugeren har klikket på "Afslut", er det et bevidst valg – der
    er ingen risiko for datatab, fordi programmet ikke gemmer data under
    kørslen (alle ændringer skrives straks til registreringsdatabasen).
    En bekræftelsesdialog ville derfor blot være irriterende.

    Hvis brugeren har ugemte ændringer i andre programmer (f.eks. en
    teksteditor), er det ikke denne applikations ansvar at advare om det
    – det er operativsystemets og det pågældende programs opgave.

  Anvendelse i programmet:
    Proceduren er forbundet til menupunktet MenuExitClick i menuen "Filer"
    (se MenuFile → MenuExit). Den kaldes udelukkende, når brugeren vælger
    "Afslut" fra menuen.
  ---------------------------------------------------------------------------- }
procedure TFormMain.MenuExitClick(Sender: TObject);
begin
  // Luk hovedvinduet og igangsæt LCL's normale nedlukningssekvens.
  // Dette kalder FormDestroy, som frigiver alle ressourcer korrekt.
  Close;
end;

{ ----------------------------------------------------------------------------
  MenuUserGuideClick
  Formål:
    At åbne det dedikerede hjælpevindue (FormHelp), som indeholder
    brugervejledning og dokumentation for programmets funktioner.
    Hjælpevinduet er en selvstændig formular, der kan vises samtidigt med
    hovedvinduet, så brugeren kan slå ting op, mens de arbejder.

  Hvorfor er der et separat hjælpevindue?
    Man kunne have valgt at vise hjælpen i en dialogboks (modal), men det
    ville betyde, at brugeren ikke kunne interagere med hovedvinduet, mens
    hjælpen var åben. For en vejledning, som brugeren typisk konsulterer
    UNDER arbejdet med tweaks, er det langt mere brugervenligt med et
    ikke-modalt vindue, som man kan have åbent ved siden af.

    FormHelp er desuden designet som en separat formular med eget layout,
    hvilket giver plads til mere omfattende dokumentation (f.eks. forklaring
    af hver kategori, sikkerhedshensyn og avancerede indstillinger), end
    en kort MessageDlg ville kunne rumme.

  Hvorfor tjekkes 'if FormHelp = nil'?
    FormHelp er en global variabel, der peger på hjælpevinduets formular.
    I Free Pascal/Lazarus kan en sådan variabel være nil i to situationer:
      1. Første gang brugeren klikker på "Brugervejledning" – vinduet er
         endnu ikke oprettet.
      2. Hvis vinduet er blevet lukket (destrueret), og LCL har nulstillet
         variablen til nil.

    Ved at tjekke for nil undgås det, at vi forsøger at kalde .Show på en
    nil-pointer (hvilket ville crashe programmet). Kun hvis vinduet ikke
    findes i hukommelsen, oprettes det på ny.

  Hvorfor Application.CreateForm i stedet for TFormHelp.Create?
    Application.CreateForm er den idiomatiske måde at oprette en ny formular
    på i LCL. Den gør to ting:
      1. Opretter formularen og tildeler den til den globale variabel
         (FormHelp), så den kan tilgås andre steder fra.
      2. Sætter formularens ejer til Application, så den automatisk
         frigives, når applikationen afsluttes – også selv om brugeren
         glemmer at lukke den.

    Ved at bruge TFormHelp.Create direkte ville vi skulle håndtere
    ejerskab og frigivelse manuelt, hvilket er mere fejlbehæftet.

  Hvorfor kaldes FormHelp.Show og derefter BringToFront?
    Show gør vinduet synligt, men hvis det allerede var åbent (f.eks. fordi
    brugeren havde det liggende bag hovedvinduet), ville det ikke nødvendigvis
    komme i forgrunden. BringToFront sikrer, at vinduet altid ender øverst
    i Z-rækkefølgen, så brugeren straks ser det – uanset om det er nyåbnet
    eller genåbnet.

    Rækkefølgen er vigtig: Show skal kaldes FØR BringToFront, fordi et
    skjult vindue ikke kan bringes i forgrunden på en meningsfuld måde.

  Hvorfor er proceduren så kort?
    Fordi al kompleksiteten er gemt i FormHelp selv (dens layout, indhold
    og eventuelle underkomponenter). Denne procedure er blot en "orkestrator",
    der sørger for, at vinduet bliver oprettet (hvis nødvendigt) og vist.
    Det gør koden nem at vedligeholde: Hvis hjælpevinduets indhold ændres,
    skal MenuUserGuideClick ikke opdateres.

  Hvad nu hvis brugeren lukker hjælpevinduet?
    Når brugeren lukker FormHelp (via krydset i hjørnet eller Escape-tasten),
    frigives formularen, og den globale FormHelp-variabel sættes automatisk
    til nil af LCL. Næste gang brugeren klikker på "Brugervejledning",
    vil nil-tjekket derfor oprette et helt nyt hjælpevindue – hvilket er
    den ønskede adfærd (vinduet starter altid i samme tilstand).

  Kendt begrænsning:
    Proceduren nulstiller ikke hjælpevinduets tilstand (f.eks. scroll-position
    eller valgt afsnit), når det genåbnes. Hvis dette ønskes i fremtiden,
    kan man tilføje et kald til en FormHelp-metode (f.eks. FormHelp.Reset)
    efter oprettelsen. Dette er dog ikke et problem i praksis, fordi
    FormHelp altid oprettes på ny, når den er nil – og dermed starter i
    sin oprindelige tilstand.

  Anvendelse i programmet:
    Proceduren er forbundet til menupunktet MenuUserGuideClick i menuen
    "Hjælp" (se MenuHelp → MenuUserGuide). Den kaldes udelukkende, når
    brugeren vælger "Brugervejledning & Dokumentation..." fra menuen.
  ---------------------------------------------------------------------------- }
procedure TFormMain.MenuUserGuideClick(Sender: TObject);
begin
  // Hvis hjælpevinduet ikke allerede findes i hukommelsen (dvs. det er
  // første gang, brugeren klikker på menupunktet, eller vinduet er blevet
  // lukket), oprettes det nu. Application.CreateForm tildeler automatisk
  // den globale FormHelp-variabel og sætter Application som ejer.
  if FormHelp = nil then
    Application.CreateForm(TFormHelp, FormHelp);

  // Gør vinduet synligt. Hvis det allerede var synligt, sker der intet.
  FormHelp.Show;

  // Sørg for at vinduet kommer øverst i Z-rækkefølgen. Dette er især
  // vigtigt, hvis vinduet allerede var åbent, men lå bag hovedvinduet –
  // så brugeren straks ser det, når de klikker på menupunktet igen.
  FormHelp.BringToFront;
end;


{ ----------------------------------------------------------------------------
  MenuAboutClick
  Formål:
    Hændelsesrutine for menupunktet "Om programmet". Viser en kort
    informationsdialog med programmets navn, udviklingsmiljø og formål.

  Hvorfor er "Om"-dialoger vigtige i et professionelt program?
    En "Om"-dialog er en lille, men vigtig del af brugeroplevelsen. Den
    giver brugeren mulighed for at:
      1. Bekræfte, hvilket program de bruger (nyttigt, hvis de har flere
         versioner installeret, eller hvis de skal rapportere en fejl).
      2. Se, hvem der har udviklet programmet, og hvilke teknologier der
         er brugt (her: Free Pascal / Lazarus).
      3. Forstå programmets formål og anvendelsesområde i korte træk.
    Det virker måske som en lille detalje, men det er med til at gøre
    programmet mere troværdigt og professionelt.

  Hvorfor vises "Om"-dialogen som en modal MessageDlg og ikke et selvstændigt vindue?
    I modsætning til brugervejledningen (som er omfattende og konsulteres
    under arbejdet) er "Om"-informationen kort og statisk. Det giver ikke
    mening at have et helt vindue til fire linjers tekst. En modal
    MessageDlg er tilstrækkeligt: Brugeren læser beskeden, klikker "OK",
    og dialogen lukkes. Det er hurtigt, enkelt og kræver ingen
    vedligeholdelse af et ekstra vindue.

  Hvorfor er der et ekstra linjeskift (sLineBreak + sLineBreak)?
    Den første sLineBreak adskiller programnavnet fra udviklingsmiljøet.
    Den anden sLineBreak (dvs. en tom linje) skaber visuel luft mellem
    den korte faktuelle information og den længere beskrivelse af
    programmets formål. Dette gør teksten nemmere at læse og giver et
    mere professionelt indtryk.

  Hvorfor 'mtInformation' som ikon?
    mtInformation (blåt 'i') signalerer, at der er tale om ren information
    uden nogen form for risiko eller valg. Brugeren skal blot læse og
    klikke OK. Alternativer som mtConfirmation eller mtWarning ville
    være misvisende her, fordi der ikke er noget at bekræfte eller advare om.

  Hvorfor er "Om"-teksten så kortfattet?
    En "Om"-dialog skal ikke være en hel roman. Den skal give brugeren
    de vigtigste oplysninger med et enkelt blik:
      - Programmets navn (til identifikation).
      - Udviklingsmiljø (til teknisk nysgerrige og fejlrapportering).
      - Formål (til at forstå, hvad programmet kan bruges til).
    Hvis brugeren vil vide mere, er der brugervejledningen i menuen
    "Hjælp". Kortfattethed er en dyd i en "Om"-dialog.

  Kendt begrænsning:
    Dialogen indeholder ikke en versionnummer eller copyright-meddelelse.
    Hvis programmet i fremtiden versionsstyres (f.eks. v1.0, v1.1), bør
    dette tilføjes – typisk som en konstant (f.eks. APP_VERSION), der
    bruges både her og andre steder i programmet. Dette er dog en
    fremtidig udvidelse, ikke en fejl.

  Anvendelse i programmet:
    Proceduren er forbundet til menupunktet MenuAboutClick i menuen
    "Hjælp" (se MenuHelp → MenuAbout). Den kaldes udelukkende, når
    brugeren vælger "Om programmet" fra menuen.
  ---------------------------------------------------------------------------- }
procedure TFormMain.MenuAboutClick(Sender: TObject);
begin
  // Vis en modal informationsdialog med programmets navn, udviklingsmiljø
  // og formål. sLineBreak indsætter de korrekte linjeskifttegn afhængigt
  // af platformen, og den dobbelte sLineBreak skaber en tom linje, som
  // adskiller faktuel information fra beskrivelsen.
  MessageDlg('Om Windows Registry Tweaker Pro',
    'Windows Registry Tweaker Pro' + sLineBreak +
    'Udviklet i Free Pascal / Lazarus.' + sLineBreak + sLineBreak +
    'Professionelt administrationsværktøj til optimering, privatliv og systemstrømlining på Windows 10 og 11.',
    mtInformation, [mbOK], 0);
end;

end.