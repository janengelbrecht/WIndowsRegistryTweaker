{ ============================================================================
  PROJEKT: Windows Registry Tweaker Pro
  FILNAVN: WinRegistryTweaker.lpr (Lazarus Program Resource)
  FORMÅL:  Dette er programmets allerførste indgangspunkt (Main entry point).
           Når styresystemet starter den eksekverbare fil (.exe), begynder
           læsningen her.
  ============================================================================ }

program WinRegistryTweaker;

// {$mode objfpc} fortæller Free Pascal compileren, at vi benytter moderne
// Object Pascal syntaks med klasser, objekter og udvidet typekontrol.
// {$H+} aktiverer dynamiske lange strenge (AnsiString/UnicodeString),
// så tekststrenge ikke begrænses til forældede 255-tegns strenge.
{$mode objfpc}{$H+}

uses
  // Håndtering af tråde hvis koden afvikles under Unix/Linux miljøer.
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  // 'Interfaces' er hjertet i Lazarus LCL (Lazarus Component Library).
  // Den forbinder Pascal-koden med Windows' grafiske motor (Win32/Win64 GUI).
  Interfaces,
  // 'Forms' styrer oprettelse, visning og levetid for programmets vinduer.
  Forms,
  // 'SysUtils' indeholder hjælpefunktioner til strenge, fejlhåndtering og konvertering.
  SysUtils,
  // 'Dialogs' gør det muligt at åbne pop-op advarsler og informationsbokse.
  Dialogs,
  // 'uMain' er vores hovedenhed, der indeholder selve brugerfladen og registreringslogikken.
  uMain,
  // 'uHelp' er hjælpeenheden, der indeholder programmets udvidede brugervejledning.
  uHelp;

// {$R *.res} instruerer compileren i at indlejre programmets ressourcefil (.res),
// som indeholder programmets ikon, versionsinformation samt UAC-manifestet,
// der beder Windows om administrator-tilladelse ved opstart.
{$R *.res}

begin
  // Kræver at formularens grafiske layout indlæses fra .lfm filen.
  RequireDerivedFormResource := True;

  // 'Application.Scaled := True' aktiverer automatisk High-DPI skalering,
  // så knapper og skrifttyper fremstår skarpe på 4K skærme og bærbare med 125%/150% skalering.
  Application.Scaled := True;

  // Forbereder det interne event-loop (hændelsesløkke) for Windows.
  Application.Initialize;

  // Sætter programmets officielle titel på proceslinjen.
  Application.Title := 'Windows Registry Tweaker Pro';

  // Opretter hovedvinduet (FormMain). Selve formularens oprettelse udløser
  // FormCreate-hændelsen inde i uMain.pas.
  Application.CreateForm(TFormMain, FormMain);

  // Starter det uendelige event-loop. Programmet afventer her brugerens klik,
  // musetastetryk og tastaturhandlinger, indtil vinduet lukkes.
  Application.Run;
end.