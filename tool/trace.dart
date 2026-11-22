/// Aufgabe: Spur einer Eingabe durch den Rechner (Backlog PR-1), ohne Terminal und ohne Menü, damit auch Claude
/// einen Fehler nachstellen und Schritt für Schritt lesen kann.
///
///   dart run tool/trace.dart "3 4+"                     eine Zeile rechnen, Spur nach stdout
///   dart run tool/trace.dart "{1 2+}':f" "f"            mehrere Argumente sind mehrere Zeilen
///   dart run tool/trace.dart --lib stat "1 2 3mean"     vorher eine mitgelieferte Bibliothek laden (mehrfach)
///   dart run tool/trace.dart --session s.rpn "x 2*"     vorher eine gespeicherte Session laden
///   dart run tool/trace.dart --nur token,stack "3 4+"   nur diese Kategorien
///   dart run tool/trace.dart --max 500 "..."            höchstens 500 Zeilen (Standard 2000, 0 = ohne Grenze, PR-2)
///
/// Je Ereignis eine Zeile, Felder durch Tabulator getrennt, vorn die Kategorie (zeichen, dea, token, rechner,
/// stack, fehler, hinweis); in ausgeführtem Code eingerückt. Nach jeder Zeile der Eingabe folgt eine Zeile
/// „ende“ mit dem Stack und dem ersten Fehler der Zeile. Ist die Grenze erreicht, entfallen weitere Zeilen bis auf
/// „ende“; davor steht „… N weitere Zeilen“.
///
/// Abgrenzung: Die Spur selbst entsteht in lib/src/trace.dart und den Haken in DEA, Parser und Calculator; das
/// Werkzeug rechnet nur über RpnApi und gibt die Zeilen aus.
///
/// Siehe auch: process/requirements/PR-1.md.
library;

import 'dart:io';

import 'package:rpncalc/rpnapi.dart';

void main(List<String> argumente) {
  final bibliotheken = <String>[];
  final eingaben = <String>[];
  String? session;
  Set<String>? nur;
  var max = 2000;
  for (var i = 0; i < argumente.length; i++) {
    final a = argumente[i];
    String wert() {
      if (i + 1 >= argumente.length) _abbruch("$a braucht einen Wert");
      return argumente[++i];
    }
    switch (a) {
      case "--lib":
        bibliotheken.add(wert());
      case "--session":
        session = wert();
      case "--nur":
        nur = wert().split(",").map((k) => k.trim()).where((k) => k.isNotEmpty).toSet();
        final unbekannt = nur.difference({...spurKategorien, "ende"});
        if (unbekannt.isNotEmpty) _abbruch("Unbekannte Kategorie: ${unbekannt.join(", ")} (erlaubt: ${spurKategorien.join(", ")})");
      case "--max":
        final w = wert();
        max = int.tryParse(w) ?? _abbruch("--max braucht eine Zahl, nicht „$w“");
        if (max < 0) _abbruch("--max darf nicht negativ sein");
      case "-h" || "--help":
        _hilfe();
        return;
      default:
        eingaben.add(a);
    }
  }
  if (eingaben.isEmpty) {
    _hilfe();
    exit(64);
  }

  final api = RpnApi();
  if (session != null) {
    final datei = File(session);
    if (!datei.existsSync()) _abbruch("Session nicht gefunden: $session");
    final fehler = api.importieren(datei.readAsStringSync());
    if (fehler != null) _abbruch("Fehler beim Laden der Session: $fehler");
  }
  for (final b in bibliotheken) {
    final fehler = api.ladeBibliothek(b);
    if (fehler != null) _abbruch("Fehler beim Laden der Bibliothek $b: $fehler");
  }
  api.hinweise(); // was beim Laden anfiel, gehört nicht zur Spur

  var geschrieben = 0, weggelassen = 0;
  void ausgabe(String zeile) {
    if (zeile.startsWith("ende\t") || zeile == "ende") { // ende immer, davor die Zahl der weggelassenen
      if (weggelassen > 0) stdout.writeln("… $weggelassen weitere Zeilen");
      weggelassen = 0;
      stdout.writeln(zeile);
    } else if (max == 0 || geschrieben < max) {
      geschrieben++;
      stdout.writeln(zeile);
    } else {
      weggelassen++;
    }
  }
  final spur = Spur(ausgabe, nur: nur == null ? null : {...nur, "ende"}); // ende immer
  api.spur = spur;
  for (final zeile in eingaben) {
    final zustand = api.eingabe(zeile, zeilen: 1000);
    for (final h in api.hinweise()) {
      spur("hinweis", [h]);
    }
    final f = zustand.fehler;
    spur("ende", [zustand.tiefe == 0 ? "leer" : api.testString(zeilen: zustand.tiefe).replaceFirst("Stack: ...", ""), if (f != null) "${f.code}: ${f.text}"]);
  }
}

Never _abbruch(String text) {
  stderr.writeln(text);
  exit(64);
}

void _hilfe() {
  stdout.writeln('''Spur einer Eingabe durch den Rechner (PR-1)
  dart run tool/trace.dart [--lib name]... [--session datei] [--nur kat,kat] [--max zeilen] "eingabe" ["eingabe" ...]
Kategorien: ${spurKategorien.join(", ")}, ende''');
}
