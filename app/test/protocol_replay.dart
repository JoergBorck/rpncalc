/// Aufgabe: ein Tastenprotokoll der App (PA-1, lib/model/protocol.dart) auf einem frischen Modell abspielen und
/// nach jeder Bedienung den Zustand mit dem aufgezeichneten vergleichen.
///
/// Abgrenzung: Abgespielt wird am Modell, ohne Widgets. Die Breite der Anzeige (Zeichen je Zeile, Zahl der Zeilen)
/// stellt [abspielen] vor jeder Bedienung so ein, wie sie beim Aufnehmen war; Hilfeseiten werden über ihre Kennung
/// neu nachgeschlagen. Zeitabhängiges (Doppelklick) steht als Ergebnis im Protokoll.
///
/// Siehe auch: replay_test.dart, process/requirements/PA-1.md.
library;

import 'dart:convert';

import 'package:flutter/widgets.dart' show AxisDirection;
import 'package:rpncalc_app/help_texts.dart';
import 'package:rpncalc_app/keys.dart';
import 'package:rpncalc_app/model/model.dart';
import 'package:rpncalc_app/model/protocol.dart';

/// Diese Felder setzt das Abspielen selbst, sie werden nicht verglichen.
const Set<String> _nichtVergleichen = {"breite", "zeilen"};

/// Spielt [text] auf [m] ab und liefert die Abweichungen, je eine Zeile; leer, wenn alles passt.
List<String> abspielen(RechnerModell m, String text) {
  final abweichungen = <String>[];
  Map<String, String>? vorher;
  for (final roh in text.split("\n")) {
    final e = Protokoll.zerlege(roh.trimRight());
    if (e == null) continue;
    _anzeige(m, vorher ?? e.zustand);
    final f = e.felder;
    Bereich bereich(String name) => Bereich.values.byName(name);
    switch (e.art) {
      case "taste": m.druecke(Taste.fromJson(jsonDecode(f[1]) as Map<String, Object?>));
      case "zeichen": m.tippeZeichen(f[0]);
      case "return": m.tastaturReturn();
      case "umbruch": m.tastaturZeilenumbruch();
      case "loeschen": m.tastaturLoeschen();
      case "tab": m.tastaturTab(rueckwaerts: f[0] == "true");
      case "f1": m.tastaturHilfe();
      case "esc": m.tastaturEsc();
      case "f10": m.tastaturMenue();
      case "pfeil": m.pfeil(AxisDirection.values.byName(f[0]));
      case "bereich": m.waehleBereich(bereich(f[0]));
      case "tastenblock": m.waehleTastenblock();
      case "tipp": m.tippeBereichMit(bereich(f[0]), doppelt: f[1] == "true");
      case "schieben": m.schiebeZeilen(bereich(f[0]), int.parse(f[1]));
      case "fseite": m.zeigeFunktionsSeite(int.parse(f[0]));
      case "auswahl": m.uebernimmAuswahl(f[0].isEmpty ? {} : f[0].split(",").toSet());
      case "hilfe": m.zeigeHilfe(f[0].isEmpty ? const [] : AppHilfe.nachschlagen(m.api, f[0]));
      case "hilfeLesen": m.oeffneHilfe(f[0].isEmpty ? const [] : AppHilfe.nachschlagen(m.api, f[0]));
      case "hilfeZu": m.hilfeSchliessen();
      case "kopie": m.kopierText(Kopie.values.byName(f[0]), int.parse(f[1]));
      case "einfuegen": m.fuegeTextEin(f[1], werte: f[0] == "true");
      case "ausnahme": abweichungen.add("Zeile ${e.nummer}: Ausnahme beim Aufnehmen: ${f.first}");
      default: abweichungen.add("Zeile ${e.nummer}: unbekannte Bedienung ${e.art}");
    }
    if (e.zustand.isNotEmpty) {
      final ist = m.protokollZustand;
      for (final soll in e.zustand.entries) {
        if (_nichtVergleichen.contains(soll.key)) continue;
        final wert = "${ist[soll.key]}";
        if (wert != soll.value) {
          abweichungen.add("Zeile ${e.nummer} (${e.art} ${f.isEmpty ? "" : f.first}): ${soll.key} erwartet "
              "„${soll.value}“, ist „$wert“");
        }
      }
      vorher = e.zustand;
    }
  }
  return abweichungen;
}

/// Breite und Zeilen der Anzeige wie beim Aufnehmen.
void _anzeige(RechnerModell m, Map<String, String> z) {
  final breite = int.tryParse(z["breite"] ?? "") ?? m.zeichenProZeile;
  m.zeichenProZeile = breite;
  final zeilen = (z["zeilen"] ?? "").split("/").map(int.tryParse).toList();
  if (zeilen.length == 2 && zeilen[0] != null && zeilen[1] != null) {
    m.platzEingabe = List.filled(zeilen[0]!, breite);
    m.platzStack = List.filled(zeilen[1]!, breite);
  }
}
