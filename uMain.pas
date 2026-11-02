{ ============================================================================
  ENHED (UNIT): uMain.pas
  BESKRIVELSE:  Indeholder den komplette forretningslogik:
                1. Token-baseret kontrol af Administratorrettigheder.
                2. Dynamisk opbygning af faneblade med parametre.
                3. Læsning og skrivning i 64-bit Windows Registry uden redirection.
                4. Processtyring mod System32 med timeout og pipe-tømning.
                5. Eksport af fuld UTF-16LE .reg-sikkerhedskopi med BOM.
                6. Rettighedstildeling (SeShutdownPrivilege) og genstart af pc.
                7. Åbning af det udvidede hjælpevindue (uHelp).
                8. Event-guarding (FUpdatingUI) mod rekursive LCL OnClick-kald.
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
  I registreringsdatabasen hedder rod-nøglerne internt nogle tal (f.eks. HKEY_CURRENT_USER).
  Når vi skal gemme en tekstbaseret .reg-fil, skal Windows kende navnet som tekst.
  Denne funktion oversætter tallet til dets officielle tekstnavn.
  ---------------------------------------------------------------------------- }
function RootKeyToStr(Root: HKEY): String;
begin
  case Root of
    HKEY_CURRENT_USER:   Result := 'HKEY_CURRENT_USER';
    HKEY_LOCAL_MACHINE:  Result := 'HKEY_LOCAL_MACHINE';
    HKEY_CLASSES_ROOT:   Result := 'HKEY_CLASSES_ROOT';
    HKEY_USERS:          Result := 'HKEY_USERS';
    HKEY_CURRENT_CONFIG: Result := 'HKEY_CURRENT_CONFIG';
    0:                   Result := 'HKEY_UNKNOWN'; // Sikrer mod undtagelse hvis RootKey er 0
  else
    raise Exception.CreateFmt('Ukendt RootKey værdi: $%x', [Root]);
  end;
end;

{ ----------------------------------------------------------------------------
  EscapeRegString
  I en Windows .reg-fil har visse tegn en særlig betydning. En omvendt skråstreg
  '\' angiver en undermappe, og anførselstegn '"' angiver start/slut på en værdi.
  Hvis vi vil gemme stien 'C:\Programmer\App', skal den skrives som
  'C:\\Programmer\\App' i filen. Denne funktion gennemgår enhver tekst og
  tilføjer de nødvendige beskyttelsestegn.
  ---------------------------------------------------------------------------- }
function EscapeRegString(const S: String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    case S[i] of
      '\': Result := Result + '\\'; // Gør en skråstreg til to
      '"': Result := Result + '\"'; // Beskytter anførselstegn
      #13: Result := Result + '\r'; // Linjeskift (Carriage Return)
      #10: Result := Result + '\n'; // Linjeskift (Line Feed)
      #0:  Result := Result + '\0'; // Nultegn
      #9:  Result := Result + '\t'; // Tabulator
    else
      Result := Result + S[i];
    end;
  end;
end;

{ ----------------------------------------------------------------------------
  DeleteKeyTree
  Windows tillader ikke, at man sletter en registreringsmappe, hvis den indeholder
  undermapper. Hvis man f.eks. vil slette MappeA, som indeholder MappeB, fejler
  et almindeligt slettekald.
  Denne funktion er rekursiv (den kalder sig selv): Den kravler ned i den
  dybeste undermappe, sletter den, går et skridt op, sletter næste, indtil hele
  træet er væk. Hvis nøglen allerede er væk, returnerer den straks 'True' uden fejl.
  ---------------------------------------------------------------------------- }
function DeleteKeyTree(AReg: TRegistry; const APath: String): Boolean;
var
  SubKeys: TStringList;
  i: Integer;
begin
  // Hvis nøglen slet ikke findes, er opgaven allerede løst med succes:
  if not AReg.KeyExists(APath) then Exit(True);

  SubKeys := TStringList.Create;
  try
    // Åbn mappen uden at oprette den hvis den mangler (False):
    if AReg.OpenKey(APath, False) then
    begin
      try
        // Find alle undermapper i denne mappe:
        AReg.GetKeyNames(SubKeys);
      finally
        AReg.CloseKey;
      end;

      // Slet hver enkelt undermappe én efter én:
      for i := 0 to SubKeys.Count - 1 do
        DeleteKeyTree(AReg, APath + '\' + SubKeys[i]);

      // Når alle undermapper er tomme og slettede, kan selve hovedmappen slettes:
      Result := AReg.DeleteKey(APath);
    end
    else
      Result := True;
  finally
    SubKeys.Free; // Frigør hukommelsen der blev brugt til listen
  end;
end;

{ ----------------------------------------------------------------------------
  RunCommandCapture
  Afvikler et eksternt konsolprogram (f.eks. powercfg.exe) helt usynligt i
  baggrunden uden at vise et sort kommandoprompt-vindue.
  Funktionen opfanger alt, hvad programmet skriver ud (både normal tekst og fejl),
  og læser det ind i en tekststreng.
  Den indeholder beskyttelse mod, at computeren fryser, hvis et program går i stå
  (maksimal ventetid sat til 30 sekunder).
  ---------------------------------------------------------------------------- }
function RunCommandCapture(const Cmd: String; const Params: array of String; out Output: String): Integer;
const
  MAX_WAIT_MS = 30000; // 30 sekunders sikkerhedstimeout
var
  AProcess: TProcess;
  MemStream: TMemoryStream;
  RawBytes: TBytes;
  BytesAvailable, BytesToRead, BytesRead: Integer;
  Buffer: array[0..4095] of Byte; // 4 KB midlertidig læse-buffer
  StartTime: QWord;
  UStr: UnicodeString;
  i: Integer;
begin
  Result := -1;
  Output := '';
  RawBytes := nil;
  FillChar(Buffer, SizeOf(Buffer), 0);

  // Opret proces-styreren:
  AProcess := TProcess.Create(nil);
  // Opret en hukommelsesstrøm til at opsamle de rå databytes:
  MemStream := TMemoryStream.Create;
  try
    AProcess.Executable := Cmd;
    // Tilføj hvert argument (f.eks. '-h' og 'off') som separate elementer:
    for i := Low(Params) to High(Params) do
      AProcess.Parameters.Add(Params[i]);

    // Indstillinger for processen:
    // poNoConsole: Vis intet sort DOS-vindue.
    // poUsePipes: Opret rørledninger (pipes) så vi kan læse hvad programmet svarer.
    // poStderrToOutPut: Saml fejlbeskeder sammen med normal tekst.
    // poNewProcessGroup: Isoler processen så den ikke trækker vores app med ned ved fejl.
    AProcess.Options := [poNoConsole, poUsePipes, poStderrToOutPut, poNewProcessGroup];
    AProcess.Execute;

    // Gem tidspunktet for opstart:
    StartTime := GetTickCount64;

    // Løkke: Bliv ved med at læse data så længe programmet kører, ELLER hvis der
    // stadig ligger ubehandlede bytes i røret:
    while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do
    begin
      BytesAvailable := AProcess.Output.NumBytesAvailable;
      if BytesAvailable > 0 then
      begin
        BytesToRead := BytesAvailable;
        if BytesToRead > SizeOf(Buffer) then
          BytesToRead := SizeOf(Buffer);

        // Læs rå bytes ud af rørledningen:
        BytesRead := AProcess.Output.Read(Buffer, BytesToRead);
        if BytesRead > 0 then
          MemStream.Write(Buffer, BytesRead); // Skriv dem i vores hukommelse
      end
      else
        Sleep(15); // Giv processoren en lille pause hvis røret er tomt lige nu

      // Sikkerhedstjek: Hvis programmet har hængt i over 30 sekunder, tvinges det ned:
      if GetTickCount64 - StartTime > MAX_WAIT_MS then
      begin
        AProcess.Terminate(1);
        WaitForSingleObject(AProcess.Handle, 5000);
        Break;
      end;
    end;

    // Når programmet er færdigt, oversættes de rå bytes til læselig tekst:
    if MemStream.Size > 0 then
    begin
      SetLength(RawBytes, MemStream.Size);
      MemStream.Position := 0;
      MemStream.ReadBuffer(RawBytes[0], MemStream.Size);
      try
        // Prøv først at læse teksten som moderne UTF-8:
        UStr := TEncoding.UTF8.GetString(RawBytes);
      except
        on E: Exception do
          // Hvis teksten var kodet i ældre Windows-1252/ANSI, læses den sådan i stedet:
          UStr := TEncoding.ANSI.GetString(RawBytes);
      end;
      Output := UTF8Encode(UStr); // Gør strengen klar til brugerfladen
    end;

    Result := AProcess.ExitCode; // 0 betyder som regel succes i Windows
  finally
    MemStream.Free;
    AProcess.Free;
  end;
end;

{ ----------------------------------------------------------------------------
  Konstruktører for TTweakItem klassen
  Disse procedurer initialiserer og opretter et nyt optimeringsobjekt i hukommelsen
  afhængigt af hvilken type data det indeholder.
  ---------------------------------------------------------------------------- }

constructor TTweakItem.CreateDWord(ACat: Integer; const ATitle: String;
  ARoot: HKEY; const ASubKey, AValName: String; AOpt, ADef: Cardinal;
  const APros, ACons: String);
begin
  inherited Create;
  CategoryIndex := ACat;
  Title := ATitle;
  RootKey := ARoot;
  SubKey := ASubKey;
  ValueName := AValName;
  ValKind := vkDWord;          // Typen er et 32-bit heltal
  OptimizedDWord := AOpt;      // Den hurtige/sikre værdi
  DefaultDWord := ADef;        // Fabriksindstillingen
  Pros := APros;
  Cons := ACons;
end;

constructor TTweakItem.CreateString(ACat: Integer; const ATitle: String;
  ARoot: HKEY; const ASubKey, AValName: String; const AOpt, ADef: String;
  const APros, ACons: String);
begin
  inherited Create;
  CategoryIndex := ACat;
  Title := ATitle;
  RootKey := ARoot;
  SubKey := ASubKey;
  ValueName := AValName;
  ValKind := vkString;         // Typen er en tekststreng
  OptimizedStr := AOpt;
  DefaultStr := ADef;
  Pros := APros;
  Cons := ACons;
end;

constructor TTweakItem.CreateEmptyKey(ACat: Integer; const ATitle: String;
  ARoot: HKEY; const ASubKey, ADeleteKeyPath: String; const APros,
  ACons: String);
begin
  inherited Create;
  CategoryIndex := ACat;
  Title := ATitle;
  RootKey := ARoot;
  SubKey := ASubKey;
  DeleteKeyPath := ADeleteKeyPath;
  ValKind := vkEmptyKey;       // Typen er en tom nøglestruktur
  Pros := APros;
  Cons := ACons;
end;

constructor TTweakItem.CreateHibernate(ACat: Integer; const ATitle, APros, ACons: String);
begin
  inherited Create;
  CategoryIndex := ACat;
  Title := ATitle;
  RootKey := HKEY_LOCAL_MACHINE;                     // Initialiseret så RootKey aldrig er $0
  SubKey := 'SYSTEM\CurrentControlSet\Control\Power'; // Reference til strømstyringens placering
  ValKind := vkHibernate;                            // Typen styres via Windows strømstyring
  Pros := APros;
  Cons := ACons;
end;

{ ----------------------------------------------------------------------------
  IsProcessElevated
  Undersøger om brugeren kørte programmet som almindelig bruger eller som Administrator.
  Windows benytter et "Access Token" til enhver proces. Denne funktion udspørger
  kernen via 'GetTokenInformation' om 'TokenElevation'.
  Hvis programmet ikke er forhøjet (elevated), kan det ikke skrive til HKEY_LOCAL_MACHINE.
  ---------------------------------------------------------------------------- }
function TFormMain.IsProcessElevated: Boolean;
type
  TTokenElevation = record
    TokenIsElevated: DWORD; // 0 = Standardbruger, 1 = Administrator
  end;
const
  TokenElevationClass = 20; // Windows intern ID for TokenElevation forespørgsler
var
  hToken: THandle;
  Elevation: TTokenElevation;
  retLen: DWORD;
begin
  Result := False;
  retLen := 0;
  FillChar(Elevation, SizeOf(Elevation), 0);

  // Åbn processens sikkerheds-token med forespørgselsrettighed (TOKEN_QUERY):
  if OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, @hToken) then
  begin
    try
      if GetTokenInformation(hToken, TTokenInformationClass(TokenElevationClass), @Elevation, SizeOf(Elevation), retLen) then
        Result := (Elevation.TokenIsElevated <> 0);
    finally
      CloseHandle(hToken); // Luk altid håndtaget så systemet ikke lækker ressourcer
    end;
  end;
end;

{ ----------------------------------------------------------------------------
  FormCreate
  Køres automatisk i det øjeblik programmet åbnes.
  1. Tjekker straks om vi har Administratorrettigheder.
  2. Opretter listen til vores tweaks.
  3. Indlæser alle optimeringsdata med fordele og ulemper.
  4. Genererer de visuelle faner og tjekbokse på skærmen.
  5. Scanner Windows-registreringsdatabasen for at sætte flueben i de aktive tweaks.
  ---------------------------------------------------------------------------- }
procedure TFormMain.FormCreate(Sender: TObject);
begin
  // Hvis brugeren ikke kørte som Administrator, advares der straks, og programmet lukkes pænt:
  if not IsProcessElevated then
  begin
    MessageDlg('Administratorrettigheder påkrævet',
      'Dette værktøj skal afvikles som Administrator for at kunne justere systemindstillinger.' + sLineBreak + sLineBreak +
      'Højreklik på programmet og vælg "Kør som administrator".',
      mtError, [mbOK], 0);
    Application.ShowMainForm := False;
    Application.Terminate;
    Exit;
  end;

  FUpdatingUI := False; // Initialiserer event-guard
  FLastHoverItem := nil;
  StatusBar1.SimplePanel := True;
  // Opretter vores hurtige pointer-liste (TFPList) i computerens RAM:
  FTweaks := TFPList.Create;
  try
    PopulateAllTweaks; // Udfyld listen med de 46 optimeringer
    BuildUI;           // Byg skærmbilledet
    ReadRegistryStatus;// Læs hvad computeren aktuelt er indstillet til
  except
    on E: Exception do
      MessageDlg('Initialiseringsfejl', E.Message, mtError, [mbOK], 0);
  end;
end;

{ ----------------------------------------------------------------------------
  FormDestroy
  Køres automatisk når programmet lukkes.
  Sikrer 100% mod hukommelseslækager og nedbrud:
  1. Frakobler alle mus- og klik-hændelser på tjekboksene, så der ikke kaldes
     døde funktioner under lukningen.
  2. Frigør fanebladene bagfra.
  3. Frigør hvert eneste TTweakItem objekt og til sidst selve listen.
  ---------------------------------------------------------------------------- }
procedure TFormMain.FormDestroy(Sender: TObject);
var
  i: Integer;
  Item: TTweakItem;
begin
  // Frakobl kontrolbokse for at forhindre use-after-free:
  if Assigned(FTweaks) then
  begin
    for i := 0 to FTweaks.Count - 1 do
    begin
      Item := TTweakItem(FTweaks[i]);
      if Assigned(Item.CheckBox) then
      begin
        Item.CheckBox.OnMouseMove := nil;
        Item.CheckBox.OnEnter := nil;
        Item.CheckBox.OnClick := nil;
        Item.CheckBox := nil;
      end;
    end;
  end;

  FLastHoverItem := nil;
  PageControl1.ActivePage := nil;
  // Frigør alle faner bagfra:
  while PageControl1.PageCount > 0 do
    PageControl1.Pages[PageControl1.PageCount - 1].Free;

  // Frigør hvert tweak i listen:
  if Assigned(FTweaks) then
  begin
    for i := 0 to FTweaks.Count - 1 do
      TTweakItem(FTweaks[i]).Free;
    FreeAndNil(FTweaks); // Frigør selve listen og sætter variablen til nil
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
  Genererer automatisk brugergrænsefladen:
  - Opretter de 10 faneblade.
  - Opretter et rullepanel (TScrollBox) på hver fane.
  - Indsætter afkrydsningsfelter (TCheckBox) for de tweaks, der hører til fanen.
  - Forankrer elementerne mod venstre og højre, så teksten skalerer perfekt ved
    skærmskift og høj DPI.
  ---------------------------------------------------------------------------- }
procedure TFormMain.BuildUI;
var
  i, j: Integer;
  Tab: TTabSheet;
  ScrollBox: TScrollBox;
  Item: TTweakItem;
  CB: TCheckBox;
  TopOffset: Integer;
begin
  PageControl1.ActivePage := nil;
  // Frigør eksisterende faner bagfra hvis funktionen kaldes igen:
  while PageControl1.PageCount > 0 do
    PageControl1.Pages[PageControl1.PageCount - 1].Free;

  // Gennemgå de 10 kategorier:
  for i := 0 to High(CAT_NAMES) do
  begin
    // Opret fanebladet:
    Tab := PageControl1.AddTabSheet;
    Tab.Caption := CAT_NAMES[i];
    Tab.Tag := i; // Gem kategoriens nummer i fanens Tag-egenskab

    // Opret rullefeltet der fylder hele fanebladet:
    ScrollBox := TScrollBox.Create(Tab);
    ScrollBox.Align := alClient;
    ScrollBox.BorderStyle := bsNone;
    ScrollBox.AutoScroll := True;
    ScrollBox.Parent := Tab;

    TopOffset := 12; // Startposition fra toppen i pixels

    // Gennemgå alle oprettede tweaks og find dem der matcher dette faneblad:
    for j := 0 to FTweaks.Count - 1 do
    begin
      Item := TTweakItem(FTweaks[j]);
      if Item.CategoryIndex = i then
      begin
        // Opret afkrydsningsfeltet:
        CB := TCheckBox.Create(ScrollBox);
        CB.Left := 16;
        CB.Top := TopOffset;
        CB.AutoSize := True;
        CB.Parent := ScrollBox; // Tildel forælder før forankring
        CB.Anchors := [akTop, akLeft, akRight]; // Stræk pænt til højre kant
        CB.Caption := Item.Title;
        CB.Font.Name := 'Segoe UI';
        CB.Font.Size := 10;
        CB.Tag := PtrInt(Item); // Kobl kontrolboksen direkte til vores objekt i RAM
        CB.OnMouseMove := @CheckBoxMouseMove;
        CB.OnEnter := @CheckBoxEnter;
        CB.OnClick := @CheckBoxClick;

        Item.CheckBox := CB;
        Inc(TopOffset, 32); // Flyt 32 pixels ned til næste linje
      end;
    end;
  end;

  // Vælg det første faneblad som aktivt ved opstart:
  if PageControl1.PageCount > 0 then
    PageControl1.ActivePageIndex := 0;
end;

{ ----------------------------------------------------------------------------
  ReadSingleTweakStatus
  Undersøger Windows-registreringsdatabasen for ét specifikt tweak og afgør,
  om det i forvejen er slået TIL (Checked := True) eller FRA (Checked := False).
  - Tvinger altid 64-bit visning (KEY_WOW64_64KEY).
  - Validerer datatyper for at forhindre exceptions.
  - Sikrer mod signed integer-fejl ved tallet $FFFFFFFF.
  - Bruger FUpdatingUI så opdatering af boksens Checked-egenskab ikke udløser OnClick.
  ---------------------------------------------------------------------------- }
procedure TFormMain.ReadSingleTweakStatus(Item: TTweakItem);
var
  Reg: TRegistry;
  DWVal: Cardinal;
  IsOpt: Boolean;
  FoundInReg: Boolean;
  PowerOut: String;
  RegDataType: TRegDataType;
begin
  if Item.CheckBox = nil then Exit;

  // Særlig håndtering af Windows Dvale:
  if Item.ValKind = vkHibernate then
  begin
    IsOpt := False;
    FoundInReg := False;
    Reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKeyReadOnly('SYSTEM\CurrentControlSet\Control\Power') then
      begin
        if Reg.ValueExists('HibernateEnabled') then
        begin
          // 0 betyder dvale er deaktiveret (hvilket er vores optimerede tilstand)
          IsOpt := (Reg.ReadInteger('HibernateEnabled') = 0);
          FoundInReg := True;
        end;
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;

    // Hvis registreringsværdien manglede, tjekkes harddisken og systemoutputtet:
    if not FoundInReg then
    begin
      if not FileExists('C:\hiberfil.sys') then
        IsOpt := True // Hvis filen ikke er på C:, er dvale helt slået fra
      else
      begin
        StatusBar1.SimpleText := 'Undersøger dvalestatus (powercfg)...';
        Application.ProcessMessages;
        RunCommandCapture(GetSafeSystemPath('powercfg.exe'), ['/a'], PowerOut);
        IsOpt := (Pos('(Hibernate)', PowerOut) = 0) and (Pos('(Dvale)', PowerOut) = 0);
      end;
    end;

    // Opdater boksen beskyttet af event-guard:
    FUpdatingUI := True;
    try
      Item.CheckBox.Checked := IsOpt;
    finally
      FUpdatingUI := False;
    end;
    Exit;
  end;

  // Standard registreringstjek (DWORD, Tekst eller Tom nøgle):
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  try
    Reg.RootKey := Item.RootKey;
    IsOpt := False;

    // Tjekker om den tomme nøglestruktur eksisterer:
    if Item.ValKind = vkEmptyKey then
    begin
      IsOpt := Reg.KeyExists(Item.SubKey);
    end
    else if Reg.OpenKeyReadOnly(Item.SubKey) then
    begin
      try
        case Item.ValKind of
          vkDWord:
            if Reg.ValueExists(Item.ValueName) then
            begin
              RegDataType := Reg.GetDataType(Item.ValueName);
              // Håndterer både ægte rdInteger og rdBinary uden fejl:
              if RegDataType = rdInteger then
              begin
                DWVal := Cardinal(Reg.ReadInteger(Item.ValueName));
                IsOpt := (DWVal = Item.OptimizedDWord);
              end
              else if RegDataType = rdBinary then
              begin
                DWVal := 0;
                Reg.ReadBinaryData(Item.ValueName, DWVal, SizeOf(DWVal));
                IsOpt := (DWVal = Item.OptimizedDWord);
              end;
            end;

          vkString:
            if Item.OptimizedStr = '' then
              IsOpt := not Reg.ValueExists(Item.ValueName)
            else
            begin
              if Reg.ValueExists(Item.ValueName) then
              begin
                RegDataType := Reg.GetDataType(Item.ValueName);
                if RegDataType in [rdString, rdExpandString] then
                  // Sammenlign uden hensyn til store/små bogstaver (SameText):
                  IsOpt := SameText(Reg.ReadString(Item.ValueName), Item.OptimizedStr);
              end;
            end;
        end;
      except
        on E: ERegistryException do
          IsOpt := False;
      end;
      Reg.CloseKey;
    end;

    // Beskyttet opdatering så LCL ikke udløser rekursive OnClick-kald:
    FUpdatingUI := True;
    try
      Item.CheckBox.Checked := IsOpt;
    finally
      FUpdatingUI := False;
    end;
  finally
    Reg.Free;
  end;
end;

{ ----------------------------------------------------------------------------
  ReadRegistryStatus
  Gennemgår hele listen af tweaks og aflæser status for hver enkelt,
  mens brugeren informeres via statusbaren.
  ---------------------------------------------------------------------------- }
procedure TFormMain.ReadRegistryStatus;
var
  i: Integer;
begin
  StatusBar1.SimpleText := 'Indlæser status for samtlige parametre...';
  Application.ProcessMessages;

  for i := 0 to FTweaks.Count - 1 do
    ReadSingleTweakStatus(TTweakItem(FTweaks[i]));

  StatusBar1.SimpleText := 'Status for samtlige parametre indlæst med succes.';
end;

{ ----------------------------------------------------------------------------
  SetTweakInRegistry
  Skriver eller sletter en parameter i registreringsdatabasen.
  - Hvis EnableOptimized = True, skrives den optimerede værdi.
  - Hvis EnableOptimized = False, skrives standardværdien tilbage.
  - Sletter forældede datatyper før ny værdi lægges ind.
  - Tvinger altid 64-bit skriveadgang (KEY_WOW64_64KEY).
  ---------------------------------------------------------------------------- }
procedure TFormMain.SetTweakInRegistry(Item: TTweakItem; EnableOptimized: Boolean);
var
  Reg: TRegistry;
  PowerOut: String;
  ExitCode: Integer;
  ValToWrite: Cardinal;
begin
  // Særlig kommando til Dvale:
  if Item.ValKind = vkHibernate then
  begin
    if EnableOptimized then
      ExitCode := RunCommandCapture(GetSafeSystemPath('powercfg.exe'), ['-h', 'off'], PowerOut)
    else
      ExitCode := RunCommandCapture(GetSafeSystemPath('powercfg.exe'), ['-h', 'on'], PowerOut);

    if ExitCode <> 0 then
      raise Exception.CreateFmt('powercfg fejlede med kode %d: %s', [ExitCode, Trim(PowerOut)]);
    Exit;
  end;

  Reg := TRegistry.Create(KEY_WRITE or KEY_WOW64_64KEY);
  try
    Reg.RootKey := Item.RootKey;

    case Item.ValKind of
      vkDWord:
        begin
          if not Reg.OpenKey(Item.SubKey, True) then
            raise Exception.CreateFmt('Kunne ikke åbne nøglen: %s', [Item.SubKey]);

          // Hvis værdien før lå som tekst eller forkert type, slettes den først:
          if Reg.ValueExists(Item.ValueName) and (Reg.GetDataType(Item.ValueName) <> rdInteger) then
            Reg.DeleteValue(Item.ValueName);

          if EnableOptimized then
            ValToWrite := Item.OptimizedDWord
          else
            ValToWrite := Item.DefaultDWord;

          // Skriv altid som ægte 32-bit REG_DWORD:
          Reg.WriteInteger(Item.ValueName, Integer(ValToWrite));
          Reg.CloseKey;
        end;

      vkString:
        begin
          if not Reg.OpenKey(Item.SubKey, True) then
            raise Exception.CreateFmt('Kunne ikke åbne nøglen: %s', [Item.SubKey]);
          if EnableOptimized then
            Reg.WriteString(Item.ValueName, Item.OptimizedStr)
          else
          begin
            if Item.DefaultStr = '' then
            begin
              if Reg.ValueExists(Item.ValueName) then
                Reg.DeleteValue(Item.ValueName);
            end
            else
              Reg.WriteString(Item.ValueName, Item.DefaultStr);
          end;
          Reg.CloseKey;
        end;

      vkEmptyKey:
        begin
          if EnableOptimized then
          begin
            if not Reg.OpenKey(Item.SubKey, True) then
              raise Exception.CreateFmt('Kunne ikke oprette nøglen: %s', [Item.SubKey]);
            Reg.WriteString('', ''); // Skriv tom streng til default-værdien
            Reg.CloseKey;
          end
          else
          begin
            // Slet nøglestrukturen ved tilbagerulning:
            if not DeleteKeyTree(Reg, Item.SubKey) then
              raise Exception.CreateFmt('Kunne ikke slette nøglen: %s', [Item.SubKey]);
          end;
        end;
    end;
  finally
    Reg.Free;
  end;
end;

{ ----------------------------------------------------------------------------
  ShowTweakInfo
  Viser fordele og ulemper i den nederste boks.
  Indeholder 'throttling': Hvis musen rører samme boks flere gange i sekundet,
  springes genopfriskningen over for at undgå flimren på skærmen.
  ---------------------------------------------------------------------------- }
procedure TFormMain.ShowTweakInfo(Item: TTweakItem);
begin
  if Item = nil then Exit;
  if Item = FLastHoverItem then Exit; // Undgå CPU-spild hvis det er samme boks
  FLastHoverItem := Item;

  LblInfoName.Caption := Item.Title;
  MemoPros.Text := Item.Pros;
  MemoCons.Text := Item.Cons;
end;

procedure TFormMain.CheckBoxMouseMove(Sender: TObject; _Shift: TShiftState; _X, _Y: Integer);
begin
  if Sender is TCheckBox then
    ShowTweakInfo(TTweakItem(TCheckBox(Sender).Tag));
end;

procedure TFormMain.CheckBoxEnter(Sender: TObject);
begin
  // Giver samme visning når brugeren taster sig frem med Tabulatortasten:
  CheckBoxMouseMove(Sender, [], 0, 0);
end;

{ ----------------------------------------------------------------------------
  CheckBoxClick
  Køres når brugeren klikker på et flueben.
  Skriver straks ændringen til Windows og genindlæser bagefter den reelle tilstand
  for at bekræfte, at Windows accepterede handlingen.
  Afbrydes hvis FUpdatingUI er sat for at forhindre kaskadekald.
  ---------------------------------------------------------------------------- }
procedure TFormMain.CheckBoxClick(Sender: TObject);
var
  Item: TTweakItem;
begin
  if FUpdatingUI then Exit; // Guard: ignorér programmatic opdateringer

  if Sender is TCheckBox then
  begin
    Item := TTweakItem(TCheckBox(Sender).Tag);
    if not Assigned(Item) then Exit;
    try
      SetTweakInRegistry(Item, TCheckBox(Sender).Checked);
      StatusBar1.SimpleText := Format('Opdateret: %s', [Item.Title]);
      ReadSingleTweakStatus(Item); // Verificer med registeret
    except
      on E: Exception do
      begin
        MessageDlg('Fejl ved opdatering', 'Handlingen fejlede: ' + E.Message, mtError, [mbOK], 0);
        try
          ReadSingleTweakStatus(Item); // Rul visningen tilbage til virkeligheden
        except
        end;
      end;
    end;
  end;
end;

{ ----------------------------------------------------------------------------
  BtnApplyCurrentTabClick
  Aktiverer samtlige tweaks på det aktive faneblad.
  ---------------------------------------------------------------------------- }
procedure TFormMain.BtnApplyCurrentTabClick(Sender: TObject);
var
  i, CurrentCat: Integer;
  Item: TTweakItem;
  SuccessCount, FailCount: Integer;
begin
  if (PageControl1.ActivePage = nil) or 
     (PageControl1.ActivePage.Tag < 0) or 
     (PageControl1.ActivePage.Tag > High(CAT_NAMES)) then Exit;

  CurrentCat := PageControl1.ActivePage.Tag;
  SuccessCount := 0;
  FailCount := 0;

  for i := 0 to FTweaks.Count - 1 do
  begin
    Item := TTweakItem(FTweaks[i]);
    if (Item.CategoryIndex = CurrentCat) and Assigned(Item.CheckBox) and (not Item.CheckBox.Checked) then
    begin
      try
        SetTweakInRegistry(Item, True);
        ReadSingleTweakStatus(Item);
        Inc(SuccessCount);
      except
        Inc(FailCount);
        try
          ReadSingleTweakStatus(Item);
        except
        end;
      end;
    end;
  end;

  if FailCount > 0 then
    MessageDlg('Resultat', Format('%d indstillinger blev aktiveret.' + sLineBreak + '%d fejlede.', [SuccessCount, FailCount]), mtWarning, [mbOK], 0)
  else
    MessageDlg('Succes', Format('%d indstillinger blev opdateret!', [SuccessCount]), mtInformation, [mbOK], 0);
end;

{ ----------------------------------------------------------------------------
  BtnRestoreCurrentTabClick
  Nulstiller samtlige tweaks på det aktive faneblad til standardværdierne.
  ---------------------------------------------------------------------------- }
procedure TFormMain.BtnRestoreCurrentTabClick(Sender: TObject);
var
  i, CurrentCat: Integer;
  Item: TTweakItem;
  SuccessCount, FailCount: Integer;
begin
  if (PageControl1.ActivePage = nil) or 
     (PageControl1.ActivePage.Tag < 0) or 
     (PageControl1.ActivePage.Tag > High(CAT_NAMES)) then Exit;

  CurrentCat := PageControl1.ActivePage.Tag;
  SuccessCount := 0;
  FailCount := 0;

  for i := 0 to FTweaks.Count - 1 do
  begin
    Item := TTweakItem(FTweaks[i]);
    if (Item.CategoryIndex = CurrentCat) and Assigned(Item.CheckBox) and (Item.CheckBox.Checked) then
    begin
      try
        SetTweakInRegistry(Item, False);
        ReadSingleTweakStatus(Item);
        Inc(SuccessCount);
      except
        Inc(FailCount);
        try
          ReadSingleTweakStatus(Item);
        except
        end;
      end;
    end;
  end;

  if FailCount > 0 then
    MessageDlg('Resultat', Format('%d indstillinger blev nulstillet.' + sLineBreak + '%d fejlede.', [SuccessCount, FailCount]), mtWarning, [mbOK], 0)
  else
    MessageDlg('Succes', Format('%d indstillinger blev nulstillet til standard.', [SuccessCount]), mtInformation, [mbOK], 0);
end;

{ ----------------------------------------------------------------------------
  MenuApplyAllClick
  Aktiverer ALLE 46 tweaks i hele systemet på én gang efter klar bekræftelse.
  ---------------------------------------------------------------------------- }
procedure TFormMain.MenuApplyAllClick(Sender: TObject);
var
  i, SuccessCount, FailCount: Integer;
  Item: TTweakItem;
begin
  if MessageDlg('Vigtig bekræftelse',
    'Vil du aktivere ALLE anbefalede optimeringer på én gang?' + sLineBreak + sLineBreak +
    'Bemærk: Sikkerhedshærdning ændrer login- og systemadfærd (kræver f.eks. CTRL+ALT+DEL og skjuler seneste brugernavn).',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    SuccessCount := 0;
    FailCount := 0;

    for i := 0 to FTweaks.Count - 1 do
    begin
      Item := TTweakItem(FTweaks[i]);
      if Assigned(Item.CheckBox) and (not Item.CheckBox.Checked) then
      begin
        try
          SetTweakInRegistry(Item, True);
          ReadSingleTweakStatus(Item);
          Inc(SuccessCount);
        except
          Inc(FailCount);
          try
            ReadSingleTweakStatus(Item);
          except
          end;
        end;
      end;
    end;

    if FailCount > 0 then
      MessageDlg('Gennemført med advarsler', Format('Optimering fuldført:' + sLineBreak + '- Aktiveret: %d' + sLineBreak + '- Fejlet: %d', [SuccessCount, FailCount]), mtWarning, [mbOK], 0)
    else
      MessageDlg('Succes', Format('%d indstillinger blev aktiveret! Genstart computeren for fuld effekt.', [SuccessCount]), mtInformation, [mbOK], 0);
  end;
end;

{ ----------------------------------------------------------------------------
  MenuCreateBackupClick
  Genererer en ægte, komplet Windows .reg sikkerhedskopifil for samtlige parametre:
  1. Finder alle unikke nøglestier.
  2. Udtrækker værdierne med eksakt formatering.
  3. Manglende parametre skrives som '=-' så import sletter dem og genskaber standard.
  4. Gemmer med officiel UTF-16LE Byte Order Mark ($FEFF).
  ---------------------------------------------------------------------------- }
procedure TFormMain.MenuCreateBackupClick(Sender: TObject);
var
  SaveDlg: TSaveDialog;
  RegFile: TStringList;
  KeyList: TStringList;
  Reg: TRegistry;
  Item: TTweakItem;
  CurrentKey, FullKeyStr: String;
  DWVal: Cardinal;
  FileStream: TFileStream;
  UStr: UnicodeString;
  BOM: Word;
  RegDataType: TRegDataType;
  i, j: Integer;
begin
  SaveDlg := TSaveDialog.Create(Self);
  try
    SaveDlg.Title := 'Gem fuld sikkerhedskopi af samtlige tweak-parametre';
    SaveDlg.Filter := 'Registreringsdatabasefiler (*.reg)|*.reg';
    SaveDlg.DefaultExt := 'reg';
    // Generer et unikt filnavn med dato og sekundpræcist klokkeslæt:
    SaveDlg.FileName := 'WinTweaker_Backup_' + FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now) + '.reg';

    if SaveDlg.Execute then
    begin
      RegFile := TStringList.Create;
      KeyList := TStringList.Create;
      Reg := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
      try
        RegFile.Add('Windows Registry Editor Version 5.00');
        RegFile.Add('; Sikkerhedskopi genereret af Windows Registry Tweaker Pro: ' + DateTimeToStr(Now));
        RegFile.Add('');

        // Find alle unikke stier:
        KeyList.Sorted := True;
        KeyList.Duplicates := dupIgnore;
        for i := 0 to FTweaks.Count - 1 do
        begin
          Item := TTweakItem(FTweaks[i]);
          if Item.ValKind <> vkHibernate then
            KeyList.Add(RootKeyToStr(Item.RootKey) + '\' + Item.SubKey);
        end;

        // Gennemgå hver unik nøglesti og udskriv parametrene:
        for i := 0 to KeyList.Count - 1 do
        begin
          CurrentKey := KeyList[i];
          RegFile.Add('[' + CurrentKey + ']');

          for j := 0 to FTweaks.Count - 1 do
          begin
            Item := TTweakItem(FTweaks[j]);
            if Item.ValKind = vkHibernate then Continue; // Spring dvale over i registreringsbackup

            FullKeyStr := RootKeyToStr(Item.RootKey) + '\' + Item.SubKey;

            if FullKeyStr = CurrentKey then
            begin
              Reg.RootKey := Item.RootKey;

              case Item.ValKind of
                vkDWord:
                  begin
                    if Reg.OpenKeyReadOnly(Item.SubKey) then
                    begin
                      try
                        if Reg.ValueExists(Item.ValueName) then
                        begin
                          RegDataType := Reg.GetDataType(Item.ValueName);
                          if RegDataType = rdInteger then
                          begin
                            DWVal := Cardinal(Reg.ReadInteger(Item.ValueName));
                            RegFile.Add(Format('"%s"=dword:%0.8x', [EscapeRegString(Item.ValueName), DWVal]));
                          end
                          else if RegDataType = rdBinary then
                          begin
                            DWVal := 0;
                            Reg.ReadBinaryData(Item.ValueName, DWVal, SizeOf(DWVal));
                            RegFile.Add(Format('"%s"=dword:%0.8x', [EscapeRegString(Item.ValueName), DWVal]));
                          end
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

                vkString:
                  begin
                    if Reg.OpenKeyReadOnly(Item.SubKey) then
                    begin
                      try
                        if Reg.ValueExists(Item.ValueName) then
                        begin
                          RegDataType := Reg.GetDataType(Item.ValueName);
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

                vkEmptyKey:
                  begin
                    if Reg.KeyExists(Item.SubKey) then
                      RegFile.Add('@=""')
                    else
                      RegFile.Add('; [Nøgle ikke aktiv]');
                  end;
              end;
            end;
          end;
          RegFile.Add('');
        end;

        // Gem filen med ægte UTF-16LE indkodning:
        UStr := UTF8Decode(RegFile.Text);
        FileStream := TFileStream.Create(SaveDlg.FileName, fmCreate);
        try
          BOM := $FEFF; // UTF-16LE Byte Order Mark
          FileStream.WriteBuffer(BOM, SizeOf(BOM));
          if Length(UStr) > 0 then
            FileStream.WriteBuffer(UStr[1], Length(UStr) * SizeOf(WideChar));
        finally
          FileStream.Free;
        end;

        MessageDlg('Sikkerhedskopi fuldført',
          'En komplet .reg-sikkerhedskopi er gemt i:' + sLineBreak + SaveDlg.FileName + sLineBreak + sLineBreak +
          'Dobbeltklik på filen i Stifinder for at genskabe præcis denne tilstand.', mtInformation, [mbOK], 0);
      finally
        Reg.Free;
        KeyList.Free;
        RegFile.Free;
      end;
    end;
  finally
    SaveDlg.Free;
  end;
end;

{ ----------------------------------------------------------------------------
  RestartComputer
  Udfører en kontrolleret genstart af Windows:
  1. Spørger Windows-kernen om SeShutdownPrivilege tilladelse.
  2. Justerer processens token med AdjustTokenPrivileges.
  3. Kalder ExitWindowsEx for at genstarte computeren sikkert.
  ---------------------------------------------------------------------------- }
procedure TFormMain.RestartComputer;
var
  hToken: THandle;
  tkp, prevTkp: TOKEN_PRIVILEGES;
  retLen: DWORD;
begin
  hToken := 0;
  retLen := 0;
  tkp := Default(TOKEN_PRIVILEGES);
  prevTkp := Default(TOKEN_PRIVILEGES);

  // Åbn processens sikkerheds-token for at ændre rettigheder:
  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, @hToken) then
  begin
    try
      // Find LUID (lokalt unikt ID) for genstartsrettigheden 'SeShutdownPrivilege':
      if LookupPrivilegeValue(nil, 'SeShutdownPrivilege', @tkp.Privileges[0].Luid) then
      begin
        tkp.PrivilegeCount := 1;
        tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
        // Aktivér rettigheden i Windows-kernen:
        if not AdjustTokenPrivileges(hToken, False, tkp, SizeOf(TOKEN_PRIVILEGES), prevTkp, retLen) or
           (GetLastError = ERROR_NOT_ALL_ASSIGNED) then
        begin
          MessageDlg('Fejl', 'SeShutdownPrivilege kunne ikke tildeles: ' + SysErrorMessage(GetLastError), mtError, [mbOK], 0);
          Exit;
        end;
      end
      else
      begin
        MessageDlg('Fejl', 'SeShutdownPrivilege blev ikke fundet: ' + SysErrorMessage(GetLastError), mtError, [mbOK], 0);
        Exit;
      end;
    finally
      CloseHandle(hToken);
    end;
  end;

  // Genstart Windows (EWX_REBOOT) og gennemtving lukning hvis en app hænger (EWX_FORCEIFHUNG):
  if not ExitWindowsEx(EWX_REBOOT or EWX_FORCEIFHUNG, SHTDN_REASON_MAJOR_OPERATINGSYSTEM or SHTDN_REASON_FLAG_PLANNED) then
    MessageDlg('Genstart mislykkedes', 'Windows afviste anmodningen: ' + SysErrorMessage(GetLastError), mtError, [mbOK], 0);
end;

procedure TFormMain.MenuRestartWindowsClick(Sender: TObject);
begin
  if MessageDlg('Genstart Windows',
    'Er du sikker på, at du vil genstarte computeren nu for at aktivere ændringerne?' + sLineBreak +
    'Husk at gemme alt åbent arbejde først!',
    mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    RestartComputer;
  end;
end;

procedure TFormMain.MenuExitClick(Sender: TObject);
begin
  Close;
end;

{ ----------------------------------------------------------------------------
  MenuUserGuideClick
  Åbner det nye, dedikerede hjælpevindue (FormHelp).
  Hvis hjælpevinduet ikke findes i hukommelsen, oprettes det og vises på skærmen.
  ---------------------------------------------------------------------------- }
procedure TFormMain.MenuUserGuideClick(Sender: TObject);
begin
  if FormHelp = nil then
    Application.CreateForm(TFormHelp, FormHelp);
  FormHelp.Show;
  FormHelp.BringToFront;
end;

procedure TFormMain.MenuAboutClick(Sender: TObject);
begin
  MessageDlg('Om Windows Registry Tweaker Pro',
    'Windows Registry Tweaker Pro' + sLineBreak +
    'Udviklet i Free Pascal / Lazarus.' + sLineBreak + sLineBreak +
    'Professionelt administrationsværktøj til optimering, privatliv og systemstrømlining på Windows 10 og 11.',
    mtInformation, [mbOK], 0);
end;

end.