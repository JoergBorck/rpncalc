/// Aufgabe: die Verarbeitung der Eingabe. [Interpreter] hält Parser und Calculator zusammen und führt die
/// aktuelle Zeile: Zeichen für Zeichen (`taste`), ganze Zeilen und mehrzeiligen Text (`eingabe`, `importieren`),
/// das Zeilenende, das Löschen des letzten Zeichens und den ersten Fehler der Zeile ([Eingabefehler]).
///
/// Abgrenzung: Was ein Token bewirkt, entscheidet der Calculator; wie Zeichen zu Tokens werden, der Parser
/// (language/). Den Zustand für die Oberflächen baut api/state.dart daraus, die Tür ist rpnapi.dart.
///
/// Siehe auch: doc/architecture.md 2.1, calculator.dart, language/parser.dart, lib/rpnapi.dart.
library;

import '../language/parser.dart';
import '../language/token.dart';
import 'calculator.dart';

/// Der erste Fehler einer Zeile: Code und Text, das Zeichen, bei dem er erkannt wurde, dazu Anfang und Text des
/// fehlerhaften Tokens zum Markieren.
typedef Eingabefehler = ({String code, String text, int position, int start, String token});

/// Parser und Calculator mit der aktuellen Zeile und ihrem ersten Fehler.
class Interpreter {
  final Parser<RpnToken> parser;
  final Calculator calculator; // muss sofort entstehen, damit seine Callbacks beim Parser registriert sind

  /// Der erste Fehler der aktuellen Zeile oder null.
  Eingabefehler? get fehler => _fehler;
  Eingabefehler? _fehler;

  /// Die bisher eingegebene Zeile.
  String get zeile => _zeile;
  String _zeile = "";

  Interpreter() : this._(rpnParser());
  Interpreter._(this.parser) : calculator = Calculator(parser);

  /// Ein Code-Block ist noch nicht abgeschlossen; die nächste Zeile setzt ihn fort.
  bool get codeOffen => parser.currentToken.codeTiefe > 0;

  /// Text mit Zeilenumbrüchen wirkt wie mehrere Zeilen nacheinander: je Zeile [taste] für jedes Zeichen, dann
  /// [zeilenende]. Ein Fehler bricht den restlichen Text ab, damit sich der Stack danach nicht unbemerkt weiter
  /// verändert.
  void eingabe(String text) {
    for (var teil in text.split("\n")) {
      parser.neueZeile();
      _neueZeile();
      for (var c in teil.split("")) {
        _taste(c);
      }
      _ausfuehren("\n");
      if (_fehler != null) break;
    }
  }

  /// Gibt Zeichen an den Parser; ein Token wird ausgeführt, sobald feststeht, dass es zu Ende ist.
  void taste(String zeichen) {
    if (zeichen == "\n") return zeilenende();
    for (var c in zeichen.split("")) {
      _taste(c);
    }
  }

  /// Schließt die Zeile ab; ein offener Code-Block bleibt über das Zeilenende hinweg erhalten.
  void zeilenende() {
    if (parser.zeileFertig) _neueZeile();
    _ausfuehren("\n");
  }

  /// Nimmt das letzte Zeichen zurück: im offenen Token oder ein vorgemerktes Enter. Nach einem Fehler zuerst alle
  /// Tasten danach auf einmal, dann die auslösende Taste; ist das fehlerhafte Token wieder offen, ist der Fehler weg.
  void loeschen() {
    if (!parser.zeileFertig && parser.tastenNachFehler) {
      while (parser.tastenNachFehler && parser.zurueck()) {
        _zeile = _zeile.substring(0, _zeile.length - 1);
      }
      return;
    }
    if (!parser.zeileFertig && _zeile.isNotEmpty) {
      if (parser.zurueck()) {
        _zeile = _zeile.substring(0, _zeile.length - 1);
        if (!parser.abgebrochen) _fehler = null; // repariert: das fehlerhafte Token ist wieder offen
      } else if (_zeile.endsWith(" ") && calculator.enter.zuruecknehmen()) {
        parser.zurueckTrenner();
        _zeile = _zeile.substring(0, _zeile.length - 1);
      }
    }
  }

  /// Verwirft, was in der Zeile noch nicht ausgeführt ist (wie [loeschen], bis sich nichts mehr ändert), und
  /// schließt sie ab; schon ausgeführte Token bleiben wirksam (doc/api.md 5.4).
  void verwerfen() {
    final hoechstens = _zeile.length + 1; // je Schritt mindestens ein Zeichen, sonst Ende
    for (var i = 0; i < hoechstens; i++) {
      final vorher = (_zeile, parser.offen, calculator.enter.vorgemerkt);
      loeschen();
      if ((_zeile, parser.offen, calculator.enter.vorgemerkt) == vorher) break;
    }
    zeilenende();
  }

  /// Führt ein Skript Zeile für Zeile aus,mit [ersetzen] nach einem [reset]. Liefert null oder den ersten
  /// Fehler mit der Nummer der Zeile.
  String? importieren(String text, {bool ersetzen = true}) {
    if (ersetzen) reset();
    final zeilen = text.replaceAll("\r\n", "\n").split("\n");
    for (int i = 0; i < zeilen.length; i++) {
      eingabe(zeilen[i]);
      if (_fehler != null) return "Zeile ${i + 1}: ${_fehler!.text}";
    }
    return codeOffen ? "Ein Code-Block ist am Ende nicht abgeschlossen" : null;
  }

  /// Setzt Stack, Variablen, Tags, Einstellungen und einen offenen Code-Block zurück.
  void reset() {
    calculator.reset();
    parser.reset();
    _neueZeile();
  }

  /// Hinweise seit dem letzten Abruf, z.B. unbekannte Schlüssel in rpnjson; danach leer.
  List<String> hinweise() {
    final h = List.of(calculator.hinweise);
    calculator.hinweise.clear();
    return h;
  }

  void _taste(String c) {
    if (parser.zeileFertig) _neueZeile();
    _zeile += c;
    _ausfuehren(c);
  }

  void _ausfuehren(String c) {
    ParserResult result = parser.taste(c);
    if (resultError.contains(result) && _fehler == null) {
      _fehler = (
        code: parser.currentToken.errorCode,
        text: parser.currentToken.errorMsg,
        position: parser.errorPosition,
        start: parser.fehlerStart,
        token: parser.fehlerToken,
      );
    }
  }

  void _neueZeile() {
    _zeile = "";
    _fehler = null;
  }
}
