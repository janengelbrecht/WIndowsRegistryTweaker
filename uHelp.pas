{ ============================================================================
  ENHED (UNIT): uHelp.pas
  BESKRIVELSE:  Dette vindue tilbyder en udtømmende brugervejledning og
                dokumentation.
                Brugeren præsenteres for en emneliste til venstre, og ved
                markering opdateres det store tekstfelt til højre med
                detaljerede instrukser, forklaringer af risici, backup-
                anbefalinger samt vejledning i systemgenstart.
  ============================================================================ }

unit uHelp;

{$mode objfpc}{$H+}

interface

uses
  // Grundlæggende datastrukturer og hukommelseshåndtering
  Classes,
  // Tekstbehandling og formatering
  SysUtils,
  // Vindues- og skærmstyring
  Forms,
  // Visuelle kontroller og koordinater
  Controls,
  // Skrifttyper og farver
  Graphics,
  // Paneler og opdelingsbjælker
  ExtCtrls,
  // Knapper, tekstfelter og lister
  StdCtrls;

type
  { TFormHelp: Klassen for selve hjælpevinduet }
  TFormHelp = class(TForm)
    PanelTop: TPanel;             // Blåt panel i toppen af hjælpevinduet
    LblTitle: TLabel;             // Overskrift: "Brugervejledning & Dokumentation"
    LblSubTitle: TLabel;          // Underoverskrift
    PanelBottom: TPanel;          // Panel i bunden med luk-knap
    BtnClose: TButton;            // Knappen "Luk hjælp"
    PanelLeft: TPanel;            // Panel til venstre der rummer emneoversigten
    LblTopics: TLabel;            // Overskrift over emner
    ListBoxTopics: TListBox;      // Liste over hjælpeemner
    SplitterH: TSplitter;         // Opdeler musen kan trække i for at ændre bredde
    PanelContent: TPanel;         // Område til højre til selve vejledningsteksten
    MemoContent: TMemo;           // Tekstboks der viser den valgte vejledning
    procedure FormCreate(Sender: TObject);
    procedure ListBoxTopicsSelectionChange(Sender: TObject; _User: Boolean);
    procedure BtnCloseClick(Sender: TObject);
  private
    procedure LoadTopic(TopicIndex: Integer); // Indlæser tekst baseret på valgt emne
  public
  end;

var
  FormHelp: TFormHelp;

implementation

{$R *.lfm}

{ ----------------------------------------------------------------------------
  FormCreate
  Køres når hjælpevinduet oprettes i hukommelsen.
  Udfylder listen over emner og indlæser automatisk det første emne.
  ---------------------------------------------------------------------------- }
procedure TFormHelp.FormCreate(Sender: TObject);
begin
  ListBoxTopics.Items.Clear;
  ListBoxTopics.Items.Add('1. Generel introduktion');
  ListBoxTopics.Items.Add('2. Sikkerhedskopi (.reg)');
  ListBoxTopics.Items.Add('3. De 10 kategorier forklaret');
  ListBoxTopics.Items.Add('4. Genstart af computeren');
  ListBoxTopics.Items.Add('5. Administrator & UAC');
  ListBoxTopics.Items.Add('6. Gode råd & Fejlsøgning');

  // Vælg automatisk det første emne:
  ListBoxTopics.ItemIndex := 0;
  LoadTopic(0);
end;

{ ----------------------------------------------------------------------------
  LoadTopic
  Opdaterer MemoContent med den tekst, der matcher det valgte indeks.
  Hvert emne er gennemarbejdet med klare instruktioner og pædagogiske råd.
  ---------------------------------------------------------------------------- }
procedure TFormHelp.LoadTopic(TopicIndex: Integer);
begin
  MemoContent.Lines.BeginUpdate;
  try
    MemoContent.Lines.Clear;
    case TopicIndex of
      0: // Generel introduktion
        begin
          MemoContent.Lines.Add('VELKOMMEN TIL WINDOWS REGISTRY TWEAKER PRO');
          MemoContent.Lines.Add('====================================================');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Hvad er dette program?');
          MemoContent.Lines.Add('Dette værktøj giver dig direkte, grafisk adgang til at optimere, hærde og');
          MemoContent.Lines.Add('strømline Windows 10 og Windows 11.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Hvordan virker det?');
          MemoContent.Lines.Add('Windows gemmer tusindvis af interne parametre i sin såkaldte Registreringsdatabase');
          MemoContent.Lines.Add('(Registry). Mange af disse indstillinger er skjult for almindelige brugere.');
          MemoContent.Lines.Add('Når du sætter et flueben i dette program, opdateres den tilhørende nøgle');
          MemoContent.Lines.Add('øjeblikkeligt i Windows uden behov for komplicerede konsolkommandoer.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Før musen hen over et punkt:');
          MemoContent.Lines.Add('Når du bevæger musemarkøren over en indstilling på et af fanebladene, opdateres');
          MemoContent.Lines.Add('infofeltet i bunden af hovedvinduet automatisk. Her kan du læse præcis hvad fordelen');
          MemoContent.Lines.Add('ved ændringen er, samt hvilke eventuelle ulemper eller risici du skal være opmærksom på.');
        end;

      1: // Sikkerhedskopi (.reg)
        begin
          MemoContent.Lines.Add('SIKKERHEDSKOPIERING OG GENDANNELSE');
          MemoContent.Lines.Add('====================================================');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Det er altid klogt at have en livline!');
          MemoContent.Lines.Add('Før du foretager store ændringer på dit system, bør du altid lave en sikkerhedskopi.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Sådan laver du en sikkerhedskopi:');
          MemoContent.Lines.Add('1. Gå til menulinjen øverst og vælg "Filer".');
          MemoContent.Lines.Add('2. Klik på "Gem fuld sikkerhedskopi af samtlige tweak-parametre...".');
          MemoContent.Lines.Add('3. Vælg hvor filen skal gemmes (f.eks. på dit Skrivebord).');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Hvad indeholder sikkerhedskopien?');
          MemoContent.Lines.Add('Programmet genererer en ægte .reg-fil (i UTF-16LE format med BOM), som indeholder');
          MemoContent.Lines.Add('den nøjagtige tilstand for samtlige parametre lige nu.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Sådan fortryder du ændringer:');
          MemoContent.Lines.Add('- Du kan klikke på "Gendan standard på denne fane" for et enkelt faneblad.');
          MemoContent.Lines.Add('- ELLER du kan finde den gemte .reg-fil frem i Windows Stifinder, dobbeltklikke');
          MemoContent.Lines.Add('  på den og trykke "Ja" til at flette den ind i Windows. Dette nulstiller alt.');
        end;

      2: // De 10 kategorier forklaret
        begin
          MemoContent.Lines.Add('FORKLARING AF DE 10 KATEGORIER');
          MemoContent.Lines.Add('====================================================');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('1. Hurtigere Windows:');
          MemoContent.Lines.Add('   Fokuserer på responsivitet i brugerfladen, kortere ventetid ved nedlukning af apps');
          MemoContent.Lines.Add('   og isolering af proceslinjen, så den ikke går ned hvis en mappe crasher.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('2. Sikkerhed & Privatliv:');
          MemoContent.Lines.Add('   Begrænser baggrunds-telemetri til Microsoft, blokerer for fremmede USB-drev mod');
          MemoContent.Lines.Add('   malware og deaktiverer automatisk kørsel af kode fra CD/USB.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('3. System & Ydeevne:');
          MemoContent.Lines.Add('   Dvalefunktion (frigør RAM-størrelse på disk), SSD-skånsomme indstillinger og');
          MemoContent.Lines.Add('   fastholdelse af Windows-kernen i hurtig fysisk RAM.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('4. Netværk & Gaming:');
          MemoContent.Lines.Add('   Prioritering af grafik- og spilprocesser, hurtigere frigivelse af tabte netværksporte');
          MemoContent.Lines.Add('   og fjernelse af systemets reserverede 20% båndbredde.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('5 & 6. Sikkerhedshærdning (Del 1 & 2):');
          MemoContent.Lines.Add('   Avancerede beskyttelsesforanstaltninger mod ransomware: Blokering af usikre scripts');
          MemoContent.Lines.Add('   (.vbs/.js), BitLocker 256-bit XTS-AES kryptering, låsning ved inaktivitet og');
          MemoContent.Lines.Add('   spærring af uautoriseret webkamera- og mikrofonadgang for apps.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('7. Privatliv & Telemetri:');
          MemoContent.Lines.Add('   Fjerner Bing-søgeresultater i Startmenuen, stopper reklame-ID og slår Microsofts');
          MemoContent.Lines.Add('   automatiske download af promoverede spil (bloatware) fra.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('8. Avanceret Kerne & GPU:');
          MemoContent.Lines.Add('   Aktiverer hardwareaccelereret GPU-skemalægning (HAGS) og låser op for CPU');
          MemoContent.Lines.Add('   Core Parking i Kontrolpanel.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('9. Hardware & Strømstyring:');
          MemoContent.Lines.Add('   Gør PCIe strømspareindstillinger synlige, holder USB-porte vågne og slår');
          MemoContent.Lines.Add('   diagnostiske baggrundstjenester fra.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('10. UI & Systemstrømlining:');
          MemoContent.Lines.Add('    Fjerner Windows 11 widgets, åbner Stifinder direkte i "Denne pc" frem for');
          MemoContent.Lines.Add('    "Hjem", deaktiverer Sticky Keys pop-up under spil og fjerner 3D-objekter.');
        end;

      3: // Genstart af computeren
        begin
          MemoContent.Lines.Add('HVORNÅR SKAL COMPUTERN GENSTARTES?');
          MemoContent.Lines.Add('====================================================');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Nogle ændringer virker med det samme:');
          MemoContent.Lines.Add('Mange indstillinger under HKEY_CURRENT_USER (f.eks. menuforsinkelse eller');
          MemoContent.Lines.Add('åbning af Stifinder i "Denne pc") træder i kraft enten med det samme eller');
          MemoContent.Lines.Add('næste gang det pågældende program åbnes.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Nogle ændringer kræver genstart:');
          MemoContent.Lines.Add('Indstillinger der vedrører Windows-kernen, netværksstakken, tjenester og hardware');
          MemoContent.Lines.Add('(f.eks. fastholdelse af kernen i RAM, netværks-throttling eller VBS) indlæses');
          MemoContent.Lines.Add('udelukkende af Windows under selve boot-processen.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Indbygget genstartsfunktion:');
          MemoContent.Lines.Add('Programmet har en indbygget genstartsfunktion i menuen:');
          MemoContent.Lines.Add('1. Vælg "Filer" i menulinjen.');
          MemoContent.Lines.Add('2. Klik på "Genstart Windows nu".');
          MemoContent.Lines.Add('3. Programmet beder Windows-kernen om SeShutdownPrivilege tilladelse og genstarter');
          MemoContent.Lines.Add('   computeren sikkert og kontrolleret.');
          MemoContent.Lines.Add('   (Husk altid at gemme åbne dokumenter inden du genstarter!)');
        end;

      4: // Administrator & UAC
        begin
          MemoContent.Lines.Add('ADMINISTRATORRETTIGHEDER & UAC (USER ACCOUNT CONTROL)');
          MemoContent.Lines.Add('====================================================');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Hvorfor kræves Administrator?');
          MemoContent.Lines.Add('Windows er opdelt i to overordnede sektioner:');
          MemoContent.Lines.Add('1. HKEY_CURRENT_USER: Dine personlige skrivebordsindstillinger.');
          MemoContent.Lines.Add('2. HKEY_LOCAL_MACHINE: Hele computerens sikkerhed, netværk og operativsystemkerne.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('For at beskytte maskinen mod virus tillader Windows ikke, at almindelige');
          MemoContent.Lines.Add('standardprogrammer ændrer i HKEY_LOCAL_MACHINE.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('Hvordan håndterer programmet dette?');
          MemoContent.Lines.Add('Programmet er forsynet med et indlejret manifest med "requireAdministrator".');
          MemoContent.Lines.Add('Når programmet startes, spørger Windows automatisk:');
          MemoContent.Lines.Add('"Vil du tillade, at denne app foretager ændringer på din enhed?"');
          MemoContent.Lines.Add('Her skal du trykke "Ja". Hvis du starter programmet uden disse rettigheder,');
          MemoContent.Lines.Add('advarer programmet straks og lukker ned for at forhindre fejl.');
        end;

      5: // Gode råd & Fejlsøgning
        begin
          MemoContent.Lines.Add('GODE RÅD, ANBEFALINGER OG FEJLSØGNING');
          MemoContent.Lines.Add('====================================================');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('1. Anvend ikke alt blindt:');
          MemoContent.Lines.Add('   Selvom funktionen "Anvend alle anbefalede tweaks..." er hurtig, bør du');
          MemoContent.Lines.Add('   læse beskrivelserne. Sikkerhedshærdning gør dit system meget sikkert, men');
          MemoContent.Lines.Add('   hvis du f.eks. jævnligt bruger USB-stik eller Remote Desktop, skal du lade');
          MemoContent.Lines.Add('   disse specifikke bokse forblive uden flueben.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('2. Hvis en indstilling ikke vil ændres:');
          MemoContent.Lines.Add('   Visse antivirus- eller virksomhedsprogrammer (Group Policies) kan overstyre');
          MemoContent.Lines.Add('   eller låse specifikke registreringsnøgler. Hvis en indstilling springer');
          MemoContent.Lines.Add('   tilbage efter genstart, skyldes det typisk en central firmapolitik.');
          MemoContent.Lines.Add('');
          MemoContent.Lines.Add('3. Opret et Systemgendannelsespunkt:');
          MemoContent.Lines.Add('   Udover programmets egen .reg-sikkerhedskopi kan du trykke Win + R,');
          MemoContent.Lines.Add('   skrive "sysdm.cpl", gå til fanen "Systembeskyttelse" og oprette et');
          MemoContent.Lines.Add('   officielt Windows Gendannelsespunkt.');
        end;
    end;
  finally
    MemoContent.Lines.EndUpdate;
  end;
end;

{ ----------------------------------------------------------------------------
  ListBoxTopicsSelectionChange
  Når brugeren klikker på et nyt emne i listen til venstre, kaldes denne metode.
  Den undersøger hvilket element der er valgt og indlæser den rette vejledning.
  ---------------------------------------------------------------------------- }
procedure TFormHelp.ListBoxTopicsSelectionChange(Sender: TObject; _User: Boolean);
begin
  if ListBoxTopics.ItemIndex >= 0 then
    LoadTopic(ListBoxTopics.ItemIndex);
end;

{ ----------------------------------------------------------------------------
  BtnCloseClick
  Lukker hjælpevinduet og returnerer fokus til hovedprogrammet.
  ---------------------------------------------------------------------------- }
procedure TFormHelp.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

end.