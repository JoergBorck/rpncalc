/// Aufgabe: die Tür zum Rechner für alle Oberflächen (Konsole, Socket-Server, App). [RpnApi] nimmt Zeichen
/// und Zeilen entgegen und liefert einen [Zustand] mit [StackZeile], [Speicher] und [Fehler], als reine Daten
/// und als JSON für das Protokoll. Dazu kommen Bibliotheken, Hilfe, Export und Import einer Sitzung als Skript.
/// Die Datei exportiert außerdem, was Oberflächen sonst brauchen: [Hilfetexte], [Hilfe], [Verwendung],
/// [Argument], [AngleMode], [Export], das Excel-Format (`fuerExcel`, `ausExcel`) und die Zahlendarstellung
/// ([zahl], [positionsName]).
///
/// Abgrenzung: Nur Schnittstelle: jede Methode gibt weiter und beschreibt, was sie bewirkt. Die Verarbeitung
/// steht im Interpreter (src/engine/interpreter.dart), Zustand, Bibliotheken und Hilfe in src/api/. Wie der
/// Zustand angezeigt und wo eine Sitzung gespeichert wird, entscheidet die Oberfläche; Konsole und Netz kommen
/// über console.dart und net.dart, die App benutzt nur diese Datei.
///
/// Siehe auch: doc/api.md (Kapitel 2–6, 8 Hilfe, 9.1 Bibliotheken), doc/architecture.md 2 und 5.
library;

import 'src/api/builtin_help.dart';
import 'src/api/help_lookup.dart';
import 'src/api/libraries.dart';
import 'src/api/state.dart';
import 'src/engine/interpreter.dart';
import 'src/engine/session.dart';
import 'src/help/help.dart';
import 'src/version.dart';

export 'src/api/builtin_help.dart' show Hilfetexte;
export 'src/api/state.dart' show Fehler, Speicher, SpeicherArt, StackZeile, Zustand;
export 'src/engine/calculator.dart' show AngleMode;
export 'src/engine/session.dart' show Export;
export 'src/format.dart' show ausExcel, fuerExcel, nurZahlen;
export 'src/help/help.dart' show Argument, Hilfe, Verwendung;
export 'src/helper.dart' show positionsName, zahl;

/// Fassade für alle Oberflächen: Eingabe hinein, Zustand heraus. Was dahinter geschieht, bleibt verborgen.
/// Jede Methode, die etwas eingibt, liefert den neuen Zustand mit höchstens [zeilen] Stack-Zeilen.
class RpnApi {
  final Interpreter _rechner;
  late final Bibliotheksverwaltung _bibliotheken = Bibliotheksverwaltung(_rechner);
  late final HilfeSuche _hilfe = HilfeSuche(_rechner, _bibliotheken);

  RpnApi() : this.mit(Interpreter());

  /// Für Tests und Werkzeuge, die zusätzlich in den Interpreter schauen; Oberflächen nehmen [RpnApi.new].
  RpnApi.mit(this._rechner);

  // ---------- Eingabe (doc/api.md Kapitel 3 und 5) ----------

  /// Verarbeitet eine Zeile; ein offener Code-Block bleibt über das Zeilenende hinweg erhalten. Enthält [zeile]
  /// Zeilenumbrüche, wirkt das wie mehrere Zeilen nacheinander; ein Fehler bricht dann den restlichen Text ab.
  Zustand eingabe(String zeile, {int zeilen = 8}) => _nach(() => _rechner.eingabe(zeile), zeilen);

  /// Verarbeitet ein Zeichen. Ein Token wird ausgeführt, sobald feststeht, dass es zu Ende ist.
  Zustand taste(String zeichen, {int zeilen = 8}) => _nach(() => _rechner.taste(zeichen), zeilen);

  /// Schließt die Zeile ab, wie das Zeilenende bei [eingabe].
  Zustand zeilenende({int zeilen = 8}) => _nach(_rechner.zeilenende, zeilen);

  /// Nimmt das zuletzt eingegebene Zeichen zurück: im offenen Token oder ein vorgemerktes Enter. Nach einem
  /// Fehler erst alle Tasten danach auf einmal, dann die auslösende Taste; dann ist das Token wieder offen. Schon
  /// ausgeführte Token bleiben (dafür braucht es ein Undo, siehe doc/api.md 5.4).
  Zustand loeschen({int zeilen = 8}) => _nach(_rechner.loeschen, zeilen);

  /// Verwirft, was in der Zeile noch nicht ausgeführt ist (offenes Token, vorgemerktes Enter, nach einem Fehler
  /// die Tasten danach), und schließt die Zeile ab. Schon ausgeführte Token bleiben wirksam (doc/api.md 5.4).
  Zustand verwerfen({int zeilen = 8}) => _nach(_rechner.verwerfen, zeilen);

  /// Der aktuelle Zustand.
  Zustand zustand({int zeilen = 8}) => zustandVon(_rechner, zeilen: zeilen);

  Zustand _nach(void Function() schritt, int zeilen) {
    schritt();
    return zustand(zeilen: zeilen);
  }

  /// Setzt Stack, Variablen, Tags, Einstellungen und einen offenen Code-Block zurück.
  void reset() => _rechner.reset();

  /// Hinweise seit dem letzten Abruf, z.B. unbekannte Schlüssel in rpnjson; danach leer.
  List<String> hinweise() => _rechner.hinweise();

  // ---------- Sitzung als Skript (doc/api.md Kapitel 5) ----------

  /// Der Zustand als RPN-Skript (ganze Session oder [nurFunktionen]), z.B. zum Speichern in einer Datei.
  /// Wo der Text gespeichert wird, entscheidet die Oberfläche.
  Export exportieren({bool nurFunktionen = false, Set<String> ohne = const {}}) =>
      SessionSkript().exportieren(_rechner.calculator, nurFunktionen: nurFunktionen, ohne: ohne);

  /// Führt ein RPN-Skript Zeile für Zeile aus, z.B. eine gespeicherte Session oder eine Sammlung von Funktionen.
  /// Mit [ersetzen] wird der Rechner vorher zurückgesetzt. Liefert null oder den ersten Fehler mit der Nummer
  /// der Zeile.
  String? importieren(String text, {bool ersetzen = true}) => _rechner.importieren(text, ersetzen: ersetzen);

  // ---------- Version und Bibliotheken (doc/api.md 9.1) ----------

  /// Version des Rechners (MAJOR.MINOR.PATCH).
  static const String version = rechnerVersion;

  /// Die Oberfläche teilt ihre eigene Version mit; rpnjson prüft dann auch die Angabe `app` einer Bibliothek.
  set appVersion(String? v) => _rechner.calculator.appVersion = v;

  /// Alle Bibliotheken, mitgelieferte zuerst, jeweils nach Namen.
  List<({String name, bool mitgeliefert})> bibliotheken() => _bibliotheken.alle();

  /// Der Text einer Bibliothek oder null.
  String? bibliothek(String name) => _bibliotheken.text(name);

  /// Meldet eine Bibliothek zur Laufzeit an, z.B. eine heruntergeladene Datei. Liefert null oder einen Fehler.
  String? bibliothekHinzufuegen(String name, String text) => _bibliotheken.hinzufuegen(name, text);

  /// Lädt eine Bibliothek in den Rechner. Liefert null oder den Fehler. Gibt es einen ihrer Namen schon
  /// (eigene Funktion oder andere Bibliothek), wird sie gar nicht geladen (doc/reference.md 10.6).
  String? ladeBibliothek(String name) => _bibliotheken.laden(name);

  /// Die Namen der Funktionen einer Bibliothek in der Reihenfolge der Datei; mit [ohneIntern] ohne die internen
  /// (rpnintern), z.B. für die Funktionstasten.
  List<String> bibliotheksFunktionen(String name, {bool ohneIntern = false}) =>
      _bibliotheken.funktionen(name, ohneIntern: ohneIntern);

  /// Die Versionsangabe einer geladenen Bibliothek oder null.
  Map<String, Object?>? bibliotheksVersion(String name) => _bibliotheken.version(name);

  /// Kurzinfo zu einer Bibliothek, auch wenn sie nicht geladen ist, z.B. für einen Tooltip: der Satz aus
  /// `beschreibung` im version-Eintrag (leer, wenn es keinen gibt), die Version und die Zahl der Funktionen.
  ({String beschreibung, String version, int funktionen})? bibliotheksInfo(String name) => _bibliotheken.info(name);

  /// Funktionen aus geladenen Bibliotheken (mit version-Eintrag); „Funktionen speichern“ lässt sie aus.
  Set<String> get geladeneBibliotheksFunktionen => _bibliotheken.geladeneFunktionen;

  /// Die Bibliothek, aus der eine Funktion stammt, oder null bei eigenen Funktionen.
  String? herkunft(String name) => _bibliotheken.herkunft(name);

  /// Die eigenen Funktionen als Bibliothek: ein Block mit Versionsangabe, Funktionen und eigener Hilfe.
  Export exportiereBibliothek(String name, {String version = "1.0.0", Set<String> ohne = const {}}) =>
      _bibliotheken.exportiere(name, version: version, ohne: ohne);

  // ---------- Hilfe (doc/api.md Kapitel 8) ----------

  /// Hilfe zu einem Zeichen, Namen oder Thema, oder null. Eingebaute Einträge gehen vor; für eigene Funktionen,
  /// Variablen, Konstanten und Tags wird ein Eintrag mit dem Inhalt erzeugt; Bibliotheken lassen sich lesen,
  /// bevor sie geladen sind. Verändert den Rechner nicht.
  Hilfe? hilfe(String kennung) => _hilfe.suche(kennung);

  /// Alle eingebauten Kennungen, für eine Übersicht.
  List<String> hilfeKennungen() => Hilfetexte.kennungen;

  /// Text für die Rechner-Tests, im bisherigen Format "Stack: ...[a] [b]<tos".
  String testString({int zeilen = 4}) => _rechner.calculator.stack.show(zeilen);
}
