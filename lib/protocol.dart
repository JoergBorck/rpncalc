import 'dart:convert';

import 'rpnapi.dart';

/// Nachrichten zwischen Client und Server: eine Zeile pro Nachricht, jede ein JSON-Objekt mit einem
/// Schlüssel, der die Art angibt (doc/api.md 6.1). Reines JSON, ohne dart:io, damit auch die Flutter-App
/// es benutzen kann.
class Nachricht {
  // Client -> Server
  static String taste(String zeichen) => jsonEncode({"taste": zeichen});
  static String zeilenende() => jsonEncode({"zeilenende": true});
  static String loeschen() => jsonEncode({"loeschen": true});
  static String eingabe(String zeile) => jsonEncode({"eingabe": zeile});
  static String zustandAbfragen({int zeilen = 8}) => jsonEncode({"zustand": true, "zeilen": zeilen});
  static String stopp() => jsonEncode({"stopp": true});
  static String hilfeAbfragen(String kennung) => jsonEncode({"hilfe": kennung});
  static String bibliothekenAbfragen() => jsonEncode({"bibliotheken": true});
  static String ladeBibliothek(String name) => jsonEncode({"ladeBibliothek": name});

  // Server -> Client
  static String zustand(Zustand z) => jsonEncode({"zustand": z});
  static String protokollfehler(String text) => jsonEncode({"protokollfehler": text});
  static String ende(String text) => jsonEncode({"ende": text});
  static String hilfe(Hilfe? h) => jsonEncode({"hilfe": h});
  static String bibliotheken(List<({String name, bool mitgeliefert})> liste) => jsonEncode({
    "bibliotheken": [
      for (final b in liste) {"name": b.name, "mitgeliefert": b.mitgeliefert},
    ],
  });
}

/// Antwort des Servers auf eine Zeile des Clients. Bei [stopp] gibt es keine Antwortzeile,
/// der Server schickt statt dessen allen Clients {"ende":…}.
typedef Antwort = ({String? zeile, bool stopp});

/// Führt eine Nachricht des Clients auf [api] aus und liefert die Antwort.
/// Ungültige Nachrichten ändern den Rechner nicht und ergeben einen Protokollfehler.
Antwort beantworte(RpnApi api, String zeile) {
  Antwort fehler(String text) => (zeile: Nachricht.protokollfehler(text), stopp: false);
  Object? j;
  try {
    j = jsonDecode(zeile);
  } on FormatException {
    return fehler("Kein gültiges JSON: $zeile");
  }
  if (j is! Map<String, Object?>) return fehler("Erwartet wird ein JSON-Objekt: $zeile");
  final zeilen = j["zeilen"];
  final n = zeilen is int ? zeilen : 8;
  final arten = [
    for (final k in j.keys)
      if (k != "zeilen") k,
  ];
  if (arten.length != 1) return fehler("Erwartet wird genau ein Schlüssel für die Art der Nachricht: $zeile");
  final wert = j[arten.single];
  final Zustand z;
  switch (arten.single) {
    case "taste" when wert is String:
      z = api.taste(wert, zeilen: n);
    case "zeilenende":
      z = api.zeilenende(zeilen: n);
    case "loeschen":
      z = api.loeschen(zeilen: n);
    case "eingabe" when wert is String:
      z = api.eingabe(wert, zeilen: n);
    case "zustand":
      z = api.zustand(zeilen: n);
    case "stopp":
      return (zeile: null, stopp: true);
    case "hilfe" when wert is String:
      return (zeile: Nachricht.hilfe(api.hilfe(wert)), stopp: false); // ändert den Rechner nicht
    case "bibliotheken":
      return (zeile: Nachricht.bibliotheken(api.bibliotheken()), stopp: false);
    case "ladeBibliothek" when wert is String:
      // eine unbekannte Bibliothek ist ein Protokollfehler, ein Fehler beim Laden steht im Zustand
      if (api.bibliothek(wert) == null) return fehler("Unbekannte Bibliothek: $wert");
      api.ladeBibliothek(wert);
      z = api.zustand(zeilen: n);
    default:
      return fehler("Unbekannte Nachricht: $zeile");
  }
  return (zeile: Nachricht.zustand(z), stopp: false);
}
