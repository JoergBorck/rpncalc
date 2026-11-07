/// Aufgabe: die zeichenweise Eingabe in der Konsole, gemeinsam für Menüprogramm und Client. [Rechner] ist die
/// Schnittstelle zum Rechner (`taste`, `zeilenende`, `loeschen`, `zustand`, `hilfe`), [LokalerRechner] ruft die
/// RpnApi direkt auf. [Bildschirm] liest Taste für Taste, schickt die Zeichen an den Rechner und zeichnet Stack,
/// Verlauf und Eingabe an derselben Stelle neu; dazu `\q`, `\c`, `\s`, `\v`, `\?`, Tab und Pfeiltasten.
/// [TastenStrom] liest die Tastatur als Stream, damit der Client nebenher Nachrichten des Servers bekommt.
///
/// Abgrenzung: Die Texte formatiert display.dart, die Hilfe help.dart, die Zwischenablage clipboard.dart,
/// den Modus der Windows-Konsole terminal.dart. Der Rechner über das Netz ist `EntfernterRechner` in net/client.dart.
///
/// Siehe auch: doc/api.md Kapitel 5 und 7, doc/architecture.md 3, console/display.dart, bin/client.dart.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import '../../rpnapi.dart';
import 'clipboard.dart';
import 'display.dart';
import 'help.dart';
import 'terminal.dart';

/// Was die zeichenweise Eingabe vom Rechner braucht (doc/api.md Kapitel 5): im Menüprogramm die RpnApi
/// selbst ([LokalerRechner]), im Client der Server über den Socket.
abstract class Rechner {
  Future<Zustand> taste(String zeichen);
  Future<Zustand> zeilenende();
  Future<Zustand> loeschen();
  Future<Zustand> zustand({int zeilen = 8});
  /// Hilfe zu einer Kennung (doc/api.md Kapitel 8); ändert den Rechner nicht.
  Future<Hilfe?> hilfe(String kennung);
}

/// Der Rechner im selben Programm.
class LokalerRechner implements Rechner {
  final RpnApi api;
  LokalerRechner(this.api);

  @override
  Future<Zustand> taste(String zeichen) async => api.taste(zeichen);
  @override
  Future<Zustand> zeilenende() async => api.zeilenende();
  @override
  Future<Zustand> loeschen() async => api.loeschen();
  @override
  Future<Zustand> zustand({int zeilen = 8}) async => api.zustand(zeilen: zeilen);
  @override
  Future<Hilfe?> hilfe(String kennung) async => api.hilfe(kennung);
}

/// Liest die Tastatur als Stream statt mit readByteSync. So kommen nebenher andere Ereignisse an,
/// z.B. eine Nachricht vom Server. Wird [abbruch] erfüllt, liefert [naechstes] sofort -1 (Ende).
///
/// stdin lässt sich nur einmal abonnieren. Deshalb nur in einem eigenen Programm wie dem Client benutzen,
/// nicht im Menüprogramm, das danach wieder mit readLineSync liest.
///
/// Abonniert wird erst beim ersten [naechstes], also nachdem der Bildschirm den Rohmodus eingeschaltet hat.
/// Unter Windows liefe der erste Lesevorgang sonst noch im Zeilenmodus: Die Zeichen der ersten Zeile kämen
/// erst mit Enter an, und weil das Echo schon aus ist, sähe man sie bis dahin nicht.
class TastenStrom {
  final Stream<List<int>> _eingabe;
  StreamSubscription<List<int>>? _abo;
  final Queue<int> _puffer = Queue();
  Completer<int>? _wartet;
  bool _zu = false;

  TastenStrom(this._eingabe, {Future<void>? abbruch}) {
    abbruch?.then((_) => _schliessen());
  }

  void _abonnieren() {
    _abo ??= _eingabe.listen((bytes) {
      _puffer.addAll(bytes);
      _weiter();
    }, onDone: _schliessen);
  }

  void _schliessen() {
    _zu = true;
    _puffer.clear();
    _weiter();
  }

  void _weiter() {
    final w = _wartet;
    if (w == null || (!_zu && _puffer.isEmpty)) return;
    _wartet = null;
    w.complete(_zu ? -1 : _puffer.removeFirst());
  }

  Future<int> naechstes() async {
    if (_zu) return -1;
    _abonnieren();
    if (_puffer.isNotEmpty) return _puffer.removeFirst();
    _wartet = Completer();
    return _wartet!.future;
  }
}

/// Die zeichenweise Eingabe in der Konsole: Stack oben, darunter der Verlauf und die aktuelle Eingabe,
/// nach jeder Taste an derselben Stelle neu gezeichnet. Gemeinsam für Menüprogramm und Client.
class Bildschirm {
  final Rechner rechner;

  /// Liefert das nächste Byte der Tastatur, -1 am Ende.
  final Future<int> Function() naechstesByte;

  Bildschirm(this.rechner, this.naechstesByte);

  /// Liest Taste für Taste und zeigt nach jeder Taste den Zustand.
  /// Enter schließt die Zeile ab, Backspace löscht, \q beendet, \c und \s kopieren,
  /// \v fügt die Zahlen aus der Zwischenablage an die Zeile an.
  /// Tab wechselt den Bereich, ↑ und ↓ blättern darin, ← und → schieben den Inhalt von Variablen und
  /// Funktionen seitlich (doc/api.md Kapitel 7). Unter Windows schaltet das dafür "Virtual Terminal Input" ein.
  ///
  /// Strg+C beendet unter Windows das ganze Programm (es kommt nicht als Taste an). Deshalb ist \q der Weg
  /// hinaus. Ein "\" wartet auf das nächste Zeichen: bei "q" Ende, sonst gehen beide an den Rechner
  /// (später Sonderzeichen). Ein einzelnes Esc wird überlesen.
  Future<void> eingabe({bool uebersicht = false}) async {
    final vt = virtuellesTerminal(); // vorher merken: Dart dreht beim Rohmodus selbst am Konsolenmodus
    stdin.echoMode = false;
    stdout.write("\x1B[?25l"); // Terminal-Cursor ausblenden, die Anzeige zeichnet einen eigenen
    stdin.lineMode = false;
    if (vt != null) virtuellesTerminalSetzen(true); // damit Pfeiltasten unter Windows ankommen
    _hoehe = 0;
    if (!_bereiche(uebersicht).contains(ansicht.bereich)) ansicht.bereich = KonsolenBereich.stack;
    try {
      bool backslash = false; // ein "\" wartet auf das nächste Zeichen
      await _anzeigen(await rechner.zustand(), uebersicht, backslash);
      List<int> bytes = [];
      bool letztesCr = false;
      while (true) {
        int b = await _byte();
        if (b == -1 || b == 3) break; // Ende oder Strg+C, falls es doch ankommt
        _meldung = ""; // eine Meldung gilt bis zur nächsten Taste
        _hilfeZeilen = const []; // die Hilfe ebenso
        if (_hilfeKennung != null && b != 27) {
          // nach \? sammeln, bis Enter die Hilfe zeigt (doc/api.md Kapitel 7)
          if (b == 13 || (b == 10 && !letztesCr)) {
            final k = _hilfeKennung!;
            _hilfeKennung = null;
            _hilfeZeilen = KonsolenHilfe.zeilen(await KonsolenHilfe.nachschlagen(rechner, k), k.isEmpty ? "#" : k,
                breite: _breite);
          } else if (b == 8 || b == 127) {
            final k = _hilfeKennung!;
            // direkt nach \? bricht Backspace ab, sonst löscht es das letzte Zeichen
            _hilfeKennung = k.isEmpty ? null : String.fromCharCodes(k.runes.toList()..removeLast());
          } else if (b >= 32) {
            bytes.add(b);
            if (bytes.length == _utf8Laenge(bytes.first)) {
              _hilfeKennung = _hilfeKennung! + utf8.decode(bytes, allowMalformed: true);
              bytes.clear();
            }
          }
          letztesCr = b == 13;
          await _anzeigen(_letzter!, uebersicht, backslash);
          continue;
        }
        if (b == 27) {
          // Escape-Folge: Pfeiltasten kommen als Esc [ A … D, andere Folgen werden überlesen
          int b2 = await _byte();
          if (b2 != 91) {
            if (b2 != -1) _zurueck = b2; // einzelnes Esc: die nächste Taste ganz normal verarbeiten
            continue;
          }
          int ende;
          do {
            ende = await _byte();
          } while (ende != -1 && (ende < 0x40 || ende > 0x7E));
          if (_pfeil(ende, uebersicht)) await _anzeigen(_letzter!, uebersicht, backslash);
          continue;
        }
        if (b == 9) {
          final liste = _bereiche(uebersicht);
          ansicht.bereich = liste[(liste.indexOf(ansicht.bereich) + 1) % liste.length];
          if (ansicht.bereich == KonsolenBereich.variablen) ansicht.funktionen = false;
          if (ansicht.bereich == KonsolenBereich.funktionen) ansicht.funktionen = true;
          ansicht.geschoben.clear();
          await _anzeigen(_letzter!, uebersicht, backslash);
          continue;
        }
        Zustand? z;
        if (b == 13 || (b == 10 && !letztesCr)) {
          if (backslash) await rechner.taste("\\");
          backslash = false;
          z = await rechner.zeilenende();
          if (z.zeile.isNotEmpty) {
            _verlauf.add(_Verlaufszeile(z));
            if (_verlauf.length > verlaufMax) _verlauf.removeAt(0);
          }
        } else if (b == 8 || b == 127) {
          z = backslash ? await rechner.zustand() : await rechner.loeschen();
          backslash = false;
        } else if (b >= 32) {
          // UTF-8: ein Zeichen wie ² oder ê besteht aus mehreren Bytes, erst das ganze Zeichen weitergeben
          bytes.add(b);
          if (bytes.length == _utf8Laenge(bytes.first)) {
            String zeichen = utf8.decode(bytes, allowMalformed: true);
            bytes.clear();
            if (backslash) {
              if (zeichen == "q") break;
              if (zeichen == "?") {
                backslash = false;
                _hilfeKennung = ""; // ab jetzt die Kennung sammeln
                await _anzeigen(await rechner.zustand(), uebersicht, backslash);
                continue;
              }
              if (zeichen == "c" || zeichen == "s") {
                backslash = false;
                _meldung = await kopieren(zeichen);
                await _anzeigen(await rechner.zustand(), uebersicht, backslash);
                continue;
              }
              if (zeichen == "v") {
                backslash = false;
                final (zahlen, meldung) = await zahlenEinfuegen();
                // wie getippt, mit "_" davor und danach, damit nichts mit den Zahlen davor oder danach verschmilzt
                z = zahlen.isEmpty ? await rechner.zustand() : await rechner.taste("_${zahlen}_");
                _meldung = meldung;
                await _anzeigen(z, uebersicht, backslash);
                continue;
              }
              await rechner.taste("\\");
              backslash = false;
              z = await rechner.taste(zeichen);
            } else if (zeichen == "\\") {
              backslash = true;
              z = await rechner.zustand();
            } else {
              z = await rechner.taste(zeichen);
            }
          }
        }
        letztesCr = b == 13;
        if (z != null) {
          // nach einer Eingabe wieder Tos und neueste Zeilen zeigen
          ansicht.stackVersatz = 0;
          ansicht.verlaufVersatz = 0;
          for (final v in _verlauf) {
            v.von = null;
          }
          await _anzeigen(z, uebersicht, backslash);
        }
      }
    } finally {
      stdin.lineMode = true;
      stdin.echoMode = true;
      // erst danach, sonst kämen die Pfeiltasten in readLineSync als ^[[A an
      if (vt != null) virtuellesTerminalSetzen(vt);
      stdout.write("\x1B[?25h"); // Terminal-Cursor wieder einblenden
    }
  }

  /// Bereich, Blättern und seitliches Schieben; bleibt erhalten, bis die Eingabe wieder aufgerufen wird.
  final Ansicht ansicht = Ansicht();

  /// Die Bereiche, zwischen denen Tab wechselt; in der kompakten Anzeige gibt es nur Stack und Verlauf.
  static List<KonsolenBereich> _bereiche(bool uebersicht) =>
      uebersicht ? KonsolenBereich.values : const [KonsolenBereich.stack, KonsolenBereich.verlauf];

  /// Ein Byte, das nach einem einzelnen Esc schon gelesen wurde und noch verarbeitet werden muss.
  int? _zurueck;

  Future<int> _byte() async {
    final b = _zurueck;
    if (b == null) return naechstesByte();
    _zurueck = null;
    return b;
  }

  /// Der zuletzt gezeichnete Zustand, für Tab und Pfeiltasten.
  Zustand? _letzter;

  /// Verschiebt die Ansicht nach einer Pfeiltaste (A hoch, B runter, C rechts, D links).
  /// Liefert false, wenn sich nichts ändert.
  bool _pfeil(int taste, bool uebersicht) {
    final z = _letzter!;
    final a = ansicht;
    final alt = (a.stackVersatz, a.verlaufVersatz, a.variablenVersatz, a.funktionenVersatz);
    final hoch = taste == 0x41, runter = taste == 0x42;
    int anzahl(bool funktionen) => z.speicher.where((s) => (s.art == SpeicherArt.funktion) == funktionen).length;
    switch (a.bereich) {
      case KonsolenBereich.stack: // runter zeigt tiefere Werte
        if (runter && a.stackVersatz + (uebersicht ? Ansicht.zeilen : 4) < z.tiefe) a.stackVersatz++;
        if (hoch && a.stackVersatz > 0) a.stackVersatz--;
      case KonsolenBereich.verlauf: // hoch zeigt ältere Zeilen
        if (hoch && _verlauf.length - a.verlaufVersatz > verlaufZeilen) a.verlaufVersatz++;
        if (runter && a.verlaufVersatz > 0) a.verlaufVersatz--;
        // seitlich jede Zeile für sich, wie bei Variablen und Funktionen
        if (taste == 0x43 || taste == 0x44) {
          bool bewegt = false;
          for (final v in _sichtbarerVerlauf) {
            final max = Darstellung.verlaufMax(v.z, _breite - 1);
            final alt = (v.von ?? Darstellung.verlaufStart(v.z, _breite - 1)).clamp(0, max);
            final neu = (alt + (taste == 0x43 ? 1 : -1)).clamp(0, max);
            if (neu != alt) {
              v.von = neu;
              bewegt = true;
            }
          }
          return bewegt;
        }
      case KonsolenBereich.variablen || KonsolenBereich.funktionen:
        final f = a.bereich == KonsolenBereich.funktionen;
        int v = f ? a.funktionenVersatz : a.variablenVersatz;
        if (runter && v + Ansicht.zeilen < anzahl(f)) v++;
        if (hoch && v > 0) v--;
        if (f) {
          a.funktionenVersatz = v;
        } else {
          a.variablenVersatz = v;
        }
        // seitlich jede Zeile für sich, höchstens bis zu ihrem Ende bzw. Anfang
        if (taste == 0x43 || taste == 0x44) return Darstellung.schieben(z, a, taste == 0x43 ? 1 : -1);
    }
    return (a.stackVersatz, a.verlaufVersatz, a.variablenVersatz, a.funktionenVersatz) != alt;
  }

  /// \c kopiert den Tos, \s den ganzen Stack (der tiefste zuerst) in die Zwischenablage,
  /// passend zu einem deutschen Excel. Liefert die Meldung für die Anzeige.
  Future<String> kopieren(String befehl) async {
    await tokenAbschliessen();
    Zustand z = await rechner.zustand(zeilen: (await rechner.zustand()).tiefe);
    if (z.stack.isEmpty) return "Der Stack ist leer, nichts kopiert";
    String text = befehl == "c"
        ? fuerExcel([z.stack.first.wert])
        : fuerExcel(z.stack.reversed.map((s) => s.wert));
    return inZwischenablage(text);
  }

  /// Schließt ein offenes Token mit "_" ab (trennt ohne Enter), wie eine Funktionstaste beim HP die
  /// Zahleneingabe abschließt: Nach "2.25" kopiert \c also die 2,25. Geht das nicht (z.B. bei einem
  /// einzelnen "'"), wird das "_" wieder gelöscht und das Token bleibt offen.
  Future<Zustand> tokenAbschliessen() async {
    Zustand z = await rechner.zustand();
    if (z.offen.isEmpty || z.fehler != null || z.zeileFertig) return z;
    z = await rechner.taste("_");
    return z.fehler == null ? z : await rechner.loeschen();
  }

  /// \v: alle Zahlen aus der Zwischenablage in der Schreibweise des Rechners, getrennt mit "_"
  /// (doc/api.md Kapitel 7), und die Meldung für die Anzeige.
  static Future<(String, String)> zahlenEinfuegen() async {
    String? text = await ausZwischenablage();
    if (text == null) return ("", "Die Zwischenablage lässt sich nicht lesen");
    List<String> zahlen = ausExcel(text);
    if (zahlen.isEmpty) return ("", "Keine Zahlen in der Zwischenablage");
    return (zahlen.join("_"), zahlen.length == 1 ? "1 Zahl eingefügt" : "${zahlen.length} Zahlen eingefügt");
  }

  /// Höhe der zuletzt gezeichneten Anzeige in Zeilen, damit sie überschrieben werden kann.
  int _hoehe = 0;

  /// Kurze Meldung unter der Eingabe (z.B. nach dem Kopieren), bis zur nächsten Taste.
  String _meldung = "";

  /// Nach "\?" die bisher getippte Kennung, sonst null (doc/api.md Kapitel 7).
  String? _hilfeKennung;

  /// Die Hilfe unter der Eingabe, bis zur nächsten Taste.
  List<String> _hilfeZeilen = const [];

  /// Wie viele abgeschlossene Zeilen die zeichenweise Eingabe über der aktuellen Eingabe zeigt.
  static const int verlaufZeilen = 5;

  /// So viele abgeschlossene Zeilen bleiben zum Zurückblättern erhalten.
  static const int verlaufMax = 100;

  /// Die zuletzt abgeschlossenen Zeilen; gezeichnet wird erst beim Anzeigen, damit sie sich schieben lassen.
  final List<_Verlaufszeile> _verlauf = [];

  /// Die Verlaufszeilen, die gerade zu sehen sind.
  List<_Verlaufszeile> get _sichtbarerVerlauf {
    final ende = _verlauf.length - ansicht.verlaufVersatz;
    return _verlauf.sublist((ende - verlaufZeilen).clamp(0, ende), ende);
  }

  int get _breite => stdout.hasTerminal ? stdout.terminalColumns - 1 : 79;

  static int _utf8Laenge(int erstesByte) =>
      erstesByte < 0xC0 ? 1 : erstesByte < 0xE0 ? 2 : erstesByte < 0xF0 ? 3 : 4;

  /// Holt, falls zurückgeblättert ist, genug Stack-Zeilen für den Ausschnitt und zeichnet dann.
  Future<void> _anzeigen(Zustand z, bool uebersicht, bool backslash) async {
    final noetig = ansicht.stackVersatz + (uebersicht ? Ansicht.zeilen : 4);
    if (z.stack.length < noetig && z.tiefe > z.stack.length) z = await rechner.zustand(zeilen: noetig);
    _letzter = z;
    _zeichnen(z, uebersicht, backslash);
  }

  /// Hilfezeile mit den Bereichen, der gewählte in Orange.
  String _hilfe(bool uebersicht) {
    const namen = {KonsolenBereich.stack: "Stack", KonsolenBereich.verlauf: "Verlauf", KonsolenBereich.variablen: "Variablen",
                   KonsolenBereich.funktionen: "Funktionen"};
    final bereiche = [
      for (final b in _bereiche(uebersicht))
        b == ansicht.bereich ? "\x1B[0;38;5;208m${namen[b]}\x1B[0;2m" : namen[b]!,
    ].join(" · ");
    final schieben = ansicht.bereich != KonsolenBereich.stack;
    return "\x1B[2mTab: $bereiche   ↑↓ blättern${schieben ? "  ←→ schieben" : ""}\x1B[0m";
  }

  /// Zeichnet Zustand und Eingabe neu, an derselben Stelle wie vorher.
  /// Ein wartendes "\" ([backslash]) wird am Ende der Eingabezeile angezeigt.
  void _zeichnen(Zustand z, bool uebersicht, bool backslash) {
    int breite = _breite;
    final ende = _verlauf.length - ansicht.verlaufVersatz;
    final anfang = (ende - verlaufZeilen).clamp(0, ende);
    // ein wartendes "\" bzw. die Kennung nach "\?" steht hinter der Eingabezeile
    final zusatz = _hilfeKennung != null ? "\\?$_hilfeKennung" : backslash ? "\\" : "";
    List<String> eingabe = Darstellung.eingabe(z, breite: breite, cursor: true, zusatz: zusatz,
                                           leer: z.zeileFertig); // abgeschlossen: steht schon im Verlauf
    // Stack oben, darunter Verlauf und aktuelle Eingabe zusammen
    List<String> zeilen = [
      // zu lange Zeilen würden umbrechen, dann stimmt die Höhe beim Überschreiben nicht mehr
      for (String s in (uebersicht
              ? Darstellung.uebersicht(z, ansicht: ansicht)
              : Darstellung.kompakt(z, versatz: ansicht.stackVersatz))
          .split("\n"))
        Darstellung.kuerzen(s, breite),
      if (anfang > 0) "\x1B[2m… $anfang ältere\x1B[0m",
      for (final v in _verlauf.sublist(anfang, ende)) ...Darstellung.verlauf(v.z, breite: breite - 1, von: v.von),
      if (ansicht.verlaufVersatz > 0) "\x1B[2m… ${ansicht.verlaufVersatz} neuere\x1B[0m",
      ...eingabe,
      Darstellung.kuerzen(_hilfe(uebersicht), breite),
      if (_meldung.isNotEmpty) "\x1B[2m${_meldung.length > breite ? "${_meldung.substring(0, breite - 1)}…" : _meldung}\x1B[0m",
    ];
    // die Hilfe unter der Eingabe, höchstens so hoch, wie das Fenster noch Platz hat
    if (_hilfeZeilen.isNotEmpty) {
      final platz = (stdout.hasTerminal ? stdout.terminalLines - 1 : 40) - zeilen.length;
      final hilfe = _hilfeZeilen.length <= platz
          ? _hilfeZeilen
          : [..._hilfeZeilen.take((platz - 1).clamp(0, platz)), "\x1B[2m… vollständig in der zeilenweisen Eingabe\x1B[0m"];
      zeilen.addAll([for (final h in hilfe) Darstellung.kuerzen(h, breite)]);
    }
    StringBuffer out = StringBuffer();
    if (_hoehe > 0) out.write("\x1B[${_hoehe}A"); // Cursor an den Anfang der alten Anzeige
    for (String zeile in zeilen) {
      out.write("\x1B[2K$zeile\n"); // Zeile löschen und neu schreiben
    }
    out.write("\x1B[J"); // Rest der alten Anzeige löschen, falls sie höher war
    stdout.write(out);
    _hoehe = zeilen.length;
  }
}

/// Eine abgeschlossene Zeile im Verlauf und wie weit sie seitlich geschoben ist
/// (null: der Ausschnitt um den Fehler bzw. das Ende).
class _Verlaufszeile {
  final Zustand z;
  int? von;
  _Verlaufszeile(this.z);
}
