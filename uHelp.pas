{ ============================================================================
  ENHED (UNIT): uHelp.pas
  BESKRIVELSE:  Dette vindue tilbyder en udtømmende brugervejledning og
                dokumentation.
                Brugeren præsenteres for en emneliste til venstre, og ved
                markering opdateres det store tekstfelt til højre med
                detaljerede instrukser, forklaringer af risici, backup-
                anbefalinger samt vejledning i systemgenstart.

  OVERORDNET FORMÅL:
  Denne enhed udgør et selvstændigt hjælpevindue til hovedprogrammet
  "Windows Registry Tweaker Pro". Vinduet fungerer som en integreret
  brugervejledning, der kan åbnes uden at forlade hovedprogrammet.

  HVAD GØR DEN?
  - Viser en emneliste til venstre og et stort tekstfelt til højre.
  - Når brugeren vælger et emne, opdateres tekstfeltet øjeblikkeligt
    med den tilhørende vejledning.
  - Dækker emner som introduktion, sikkerhedskopiering, kategoriforklaring,
    genstart, UAC og fejlsøgning.

  HVORFOR FINDES DEN?
  - Programmet ændrer direkte i Windows-registreringsdatabasen, hvilket er
    en risikabel operation for ikke-kyndige brugere.
  - Brugeren har derfor brug for pædagogisk, lettilgængelig dokumentation
    lige ved hånden — uden at skulle forlade programmet.
  - Den fungerer også som en risikobegrænsende foranstaltning: Jo bedre
    brugeren forstår konsekvenserne, jo færre fejl.

  HVORDAN ER DET BYGGET OP?
  - En klassisk master-detail-model: TListBox (emneoversigt) styrer en
    TMemo (detaljetekst) via en SelectionChange-hændelse.
  - Al tekst er hardcodet i LoadTopic i stedet for at ligge i eksterne
    filer. Det gør enheden selvstændig (ingen filafhængigheder) og
    garanterer, at vejledningen altid matcher programmets funktioner.
  ============================================================================ }

unit uHelp;

{ {$mode objfpc} sætter compileren til Object Pascal-tilstand (Free Pascal
  Compiler-specifik), som giver bl.a. klasser, undtagelser og strengtyper
  som i Delphi.
  {$H+} aktiverer "long strings" (ansistrenge) i stedet for korte
  Pascal-strenge. Nødvendigt for at kunne håndtere de mange tekstlinjer i
  vejledningen uden længdebegrænsninger. }
{$mode objfpc}{$H+}

interface

{ Alt mellem "interface" og "implementation" er offentligt — det er den
  "kontrakt", andre enheder (især uMain) kan bruge. }

uses
  // Grundlæggende datastrukturer og hukommelseshåndtering
  // (TComponent, TPersistent — fundamentet for alle VCL-kontroller)
  Classes,
  // Tekstbehandling og formatering samt Exception-håndtering
  SysUtils,
  // Vindues- og skærmstyring (TForm — selve vinduesklassen)
  Forms,
  // Visuelle kontroller og koordinater (TControl — basis for TLabel, TPanel)
  Controls,
  // Skrifttyper og farver (TFont, TColor — bruges indirekte af kontrollerne)
  Graphics,
  // Paneler og opdelingsbjælker (TPanel, TSplitter)
  ExtCtrls,
  // Knapper, tekstfelter og lister (TButton, TListBox, TMemo)
  StdCtrls;

{ Uden disse uses ville compileren ikke kende typerne TForm, TListBox,
  TMemo osv., og filen ville ikke kompilere. }

type
  { TFormHelp: Klassen for selve hjælpevinduet.
    TFormHelp arver fra TForm. Det betyder, at den automatisk får alle
    egenskaber ved et Windows-vindue: titelbar, størrelse, position,
    luk-knap, hændelseshåndtering osv. Vi tilføjer kun det specifikke
    for hjælpevinduet: paneler, liste, memo og hændelser. }
  TFormHelp = class(TForm)
    // Blåt panel i toppen af hjælpevinduet — giver et professionelt
    // header-bånd, så brugeren ved, hvor de er.
    PanelTop: TPanel;
    // Overskrift: "Brugervejledning & Dokumentation"
    LblTitle: TLabel;
    // Underoverskrift
    LblSubTitle: TLabel;
    // Panel i bunden med luk-knap — tydelig afslutning på vinduet
    PanelBottom: TPanel;
    // Knappen "Luk hjælp"
    BtnClose: TButton;
    // Panel til venstre der rummer emneoversigten (navigation)
    PanelLeft: TPanel;
    // Overskrift over emner
    LblTopics: TLabel;
    // Liste over hjælpeemner — brugeren vælger her
    ListBoxTopics: TListBox;
    // Opdeler musen kan trække i for at ændre bredde — lader brugeren
    // selv justere, hvor meget plads listen vs. teksten fylder.
    SplitterH: TSplitter;
    // Område til højre til selve vejledningsteksten
    PanelContent: TPanel;
    // Tekstboks der viser den valgte vejledning.
    // TMemo er valgt frem for TLabel, fordi den understøtter scroll,
    // markering og kopiering — brugeren kan kopiere kommandoer ud.
    MemoContent: TMemo;

    { Hændelser (events) — metoder der kaldes automatisk af VCL-
      rammeværket, når bestemte ting sker:
        FormCreate                       → vinduet oprettes i hukommelsen
        ListBoxTopicsSelectionChange     → brugeren vælger et nyt emne
        BtnCloseClick                    → brugeren klikker på "Luk hjælp" }
    procedure FormCreate(Sender: TObject);
    { _User-parameteren fortæller, om ændringen blev udført af brugeren
      (True) eller programmet selv. Vi bruger den ikke her — derfor
      understregningen i navnet, som konvention for "ubrugt parameter".
      Programmet reagerer ens uanset hvem der valgte. }
    procedure ListBoxTopicsSelectionChange(Sender: TObject; _User: Boolean);
    procedure BtnCloseClick(Sender: TObject);
  private
    { LoadTopic er en intern hjælpefunktion — omverdenen skal ikke kunne
      kalde den direkte, de skal bruge ListBoxTopics.ItemIndex.
      TopicIndex er et 0-baseret indeks, der fortæller hvilket emne der
      skal vises. Ved at bruge et tal i stedet for en streng undgår vi
      fejl ved tastefejl og gør koblingen til ListBoxTopics.ItemIndex
      direkte. }
    procedure LoadTopic(TopicIndex: Integer);
  public
  end;

var
  { Global reference til vinduet. Når uMain skal åbne hjælpen, gør den
    typisk FormHelp.Show eller FormHelp.ShowModal. Lazarus'
    formular-designer opretter automatisk denne variabel og instansierer
    klassen ved programstart (medmindre andet er konfigureret). }
  FormHelp: TFormHelp;

implementation

{ implementation — her ligger den faktiske kode. Alt her er privat for
  enheden (medmindre det eksplicit re-eksporteres).

  {$R *.lfm} er et compilerdirektiv, der linker Lazarus'
  formulardefinitionsfil (.lfm) ind i programmet. .lfm er en tekstbaseret
  ressourcefil, der beskriver hvordan vinduet ser ud: komponenternes
  position, størrelse, farver, egenskaber og hvilke hændelser der er
  koblet til hvilke metoder. Uden denne linje ville vinduet være tomt
  ved kørsel. }
{$R *.lfm}

{ ----------------------------------------------------------------------------
  FormCreate
  Køres når hjælpevinduet oprettes i hukommelsen (før det vises).
  Udfylder listen over emner og indlæser automatisk det første emne.

  HVAD: Initialiserer vinduets indhold.
  HVORFOR: Uden dette ville listen være tom og memoen uden tekst.
  HVORDAN: Se de enkelte linjer nedenfor.
  ---------------------------------------------------------------------------- }
procedure TFormHelp.FormCreate(Sender: TObject);
begin
  { Items.Clear sikrer, at listen er tom. Vigtigt, hvis FormCreate
    skulle blive kaldt flere gange (fx ved genbrug af vinduet), så vi
    ikke får dubletter. }
  ListBoxTopics.Items.Clear;

  { Seks Items.Add tilføjer emnerne i fast rækkefølge. Nummereringen i
    teksten ("1.", "2." osv.) giver brugeren en intuitiv fornemmelse af
    progression — start med det grundlæggende, slut med fejlsøgning.
    Emnerne er hardcodet i koden (ikke eksterne filer), hvilket gør det
    umuligt for brugeren at slette eller ændre emner ved en fejl, og
    garanterer at teksten er synkroniseret med programmets funktioner. }
  ListBoxTopics.Items.Add('1. Generel introduktion');
  ListBoxTopics.Items.Add('2. Sikkerhedskopi (.reg)');
  ListBoxTopics.Items.Add('3. De 10 kategorier forklaret');
  ListBoxTopics.Items.Add('4. Genstart af computeren');
  ListBoxTopics.Items.Add('5. Administrator & UAC');
  ListBoxTopics.Items.Add('6. Gode råd & Fejlsøgning');

  // Vælg automatisk det første emne: programmatisk markering af emne 0.
  // Uden dette ville listen starte med "intet valgt", og memoen ville
  // være tom.
  ListBoxTopics.ItemIndex := 0;

  { Manuelt kald for at indlæse teksten. Dette er nødvendigt, fordi
    ItemIndex := 0 *kan* udløse OnSelectionChange, men ikke er garanteret
    i alle VCL-versioner ved opstart. Ved at kalde LoadTopic eksplicit
    garanterer vi, at indholdet vises. }
  LoadTopic(0);
end;

{ ----------------------------------------------------------------------------
  LoadTopic
  Opdaterer MemoContent med den tekst, der matcher det valgte indeks.
  Hvert emne er gennemarbejdet med klare instruktioner og pædagogiske råd.

  Dette er kernen i enheden — den eneste kilde til sandhed for, hvad der
  vises i memoen. Både opstart og brugerinteraktion går gennem den samme
  funktion, hvilket eliminerer risikoen for at de to veje giver
  forskelligt indhold.
  ---------------------------------------------------------------------------- }
procedure TFormHelp.LoadTopic(TopicIndex: Integer);
begin
  { BeginUpdate/EndUpdate er et centralt ydelses- og UX-trick:
    TMemo.Lines er en TStrings-samling. Hver gang man kalder Add eller
    Clear, vil TMemo normalt gentegne sig selv for at vise ændringen.
    Når vi tilføjer 30–40 linjer, ville det betyde 30–40 gentegninger —
    det giver flimren og forsinkelse.
    BeginUpdate fortæller memoen: "Ignorer gentegning indtil jeg siger
    til." EndUpdate (i finally) fortæller: "Nu kan du gentegne — én
    gang, med det endelige indhold." Resultatet er én enkelt,
    øjeblikkelig opdatering af teksten. }
  MemoContent.Lines.BeginUpdate;
  { try...finally garanterer, at EndUpdate ALTID køres, uanset hvad der
    sker i try-blokken. Hvis der skulle opstå en undtagelse under
    opbygningen af teksten (fx EOutOfMemory ved meget store tekster),
    ville EndUpdate ellers aldrig blive kaldt, og memoen ville forblive
    i "opdaterer"-tilstand — den ville fryse visuelt. }
  try
    { Clear kaldes kun én gang, før case. Det er korrekt, fordi alle
      grene skriver til den samme tomme memo — der er ingen grund til at
      rydde igen inde i hver gren. }
    MemoContent.Lines.Clear;
    { case TopicIndex of er en switch-lignende struktur, der vælger den
      rette tekstblok baseret på indekset. TopicIndex kommer fra
      ListBoxTopics.ItemIndex, så der er en direkte 1:1-kobling mellem
      rækkefølgen i FormCreate og sagerne her. Hvis man tilføjer et nyt
      emne i FormCreate, SKAL man også tilføje en ny case-gren — ellers
      vises intet. }
    case TopicIndex of
      0: // Generel introduktion
        { HVAD: Forklarer programmets formål, hvordan det virker
          (registry), og hvordan værktøjstips fungerer.
          HVORFOR: Brugeren skal forstå konteksten, før de begynder at
          ændre indstillinger. Uden denne forståelse er resten af
          vejledningen meningsløs.
          HVORDAN: Opbygget som spørgsmål/svar — en pædagogisk form, der
          matcher brugerens mentale model ("Hvad er det? Hvordan virker
          det?"). }
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
        { HVAD: Trin-for-trin-instruktion i at gemme og gendanne en
          .reg-fil.
          HVORFOR: Dette er den vigtigste sikkerhedsforanstaltning i hele
          programmet. Hvis noget går galt, er dette brugerens redning.
          HVORDAN: Nummererede trin + forklaring af filformatet
          (UTF-16LE med BOM) + to gendannelsesmetoder (per-fane eller
          hel fil). }
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
        { HVAD: En oversigt over de ti faneblade i hovedvinduet.
          HVORFOR: Hjælper brugeren med at navigere og forstå, hvad hver
          kategori indeholder, før de klikker rundt.
          HVORDAN: Nummereret liste, hvor hver kategori får 2–3 linjer med
          konkrete eksempler på, hvad den gør. }
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
        { HVAD: Forklarer hvilke ændringer der kræver genstart, og
          hvordan man genstarter via programmet.
          HVORFOR: Mange brugere tror, at en ændring er "gået i stykker",
          fordi den ikke virker med det samme. Denne tekst forebygger
          unødig forvirring.
          HVORDAN: Opdelt i "virker med det samme" vs. "kræver genstart",
          efterfulgt af trin-for-trin-genvej til genstart. }
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
        { HVAD: Forklarer hvorfor programmet kræver
          administratorrettigheder, og hvad UAC-dialogen betyder.
          HVORFOR: UAC-prompten er det første, brugeren møder — hvis de
          klikker "Nej", virker programmet ikke. Teksten forebygger, at
          brugeren afviser prompten i frygt.
          HVORDAN: Forklarer HKEY_CURRENT_USER vs. HKEY_LOCAL_MACHINE og
          hvordan manifestet med requireAdministrator udløser prompten. }
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
        { HVAD: Praktiske advarsler og løsninger på typiske problemer.
          HVORFOR: Fungerer som "lessons learned" — fx at man ikke skal
          anvende alt blindt, og hvad man gør, hvis en indstilling ikke
          vil ændres (Group Policy).
          HVORDAN: Tre nummererede råd, der hver især adresserer en typisk
          fejl eller bekymring. }
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
    { EndUpdate fortæller memoen, at den nu må gentegne sig — én gang,
      med det endelige indhold. Ligger i finally, så den altid køres. }
    MemoContent.Lines.EndUpdate;
  end;
end;

{ ----------------------------------------------------------------------------
  ListBoxTopicsSelectionChange
  Når brugeren klikker på et nyt emne i listen til venstre, kaldes denne
  metode. Den undersøger hvilket element der er valgt og indlæser den
  rette vejledning.

  HVAD: Reagerer på brugerens valg i listen.
  HVORFOR: Dette er den eneste "rigtige" interaktionslogik — al
  kompleksitet er skjult i LoadTopic. Metoden er bevidst holdt minimal,
  så den kun er en bro mellem UI-begivenheden og forretningslogikken.
  HVORDAN: Tjekker ItemIndex og kalder LoadTopic.
  ---------------------------------------------------------------------------- }
procedure TFormHelp.ListBoxTopicsSelectionChange(Sender: TObject; _User: Boolean);
begin
  { if ItemIndex >= 0 er et sikkerhedstjek. -1 betyder "intet valgt".
    Uden dette tjek ville LoadTopic(-1) blive kaldt, og case-sætningen
    ville ikke matche nogen gren — memoen ville blive ryddet og stå tom.
    Med tjekket undgår vi den uheldige tilstand. }
  if ListBoxTopics.ItemIndex >= 0 then
    { Indlæser den valgte tekst. Bemærk: _User ignoreres, fordi vi altid
      vil indlæse teksten uanset om ændringen kom fra brugeren eller fra
      kode. }
    LoadTopic(ListBoxTopics.ItemIndex);
end;

{ ----------------------------------------------------------------------------
  BtnCloseClick
  Lukker hjælpevinduet og returnerer fokus til hovedprogrammet.

  HVAD: Kalder Close på formen, hvilket lukker vinduet.
  HVORFOR: Close lukker KUN dette vindue og returnerer kontrollen til
  hovedprogrammet. Det er præcis, hvad vi vil — brugeren skal tilbage til
  tweaker-vinduet, ikke afslutte hele programmet.
  Application.Terminate ville afslutte HELE applikationen — en katastrofal
  fejl, hvis brugeren blot ville lukke hjælpen. Halt ville dræbe processen
  øjeblikkeligt uden oprydning — heller ikke ønskværdigt.
  HVORDAN: Close-metoden på TForm.
  ---------------------------------------------------------------------------- }
procedure TFormHelp.BtnCloseClick(Sender: TObject);
begin
  { Close lukker kun dette vindue. X-knappen i titellinjen lukker også
    vinduet, men en eksplicit "Luk hjælp"-knap i bunden er mere synlig og
    intuitiv for brugere, der ikke er vant til Windows-konventioner. Det
    er et tilgængelighedshensyn. }
  Close;
end;

end.