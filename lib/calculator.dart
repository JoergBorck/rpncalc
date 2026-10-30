import 'calc/arguments.dart';
import 'calc/core.dart';
import 'calc/enter.dart';
import 'calc/functions.dart';
import 'calc/operators.dart';
import 'calc/stack_commands.dart';
import 'calc/storage.dart';
import 'parser.dart';
import 'rpntoken.dart';

export 'calc/functions.dart' show AngleMode;

/// Koordinator: nimmt die Tokens vom Parser entgegen und verteilt sie auf die Bausteine.
///
/// Jedes Token durchläuft denselben Ablauf: EnterLogik (Leerzeichen als Trenner oder Enter),
/// Argumente übernehmen, Aktion ausführen, Ergebnis bzw. Fehler an den Parser zurückgeben.
/// Die Aktionen stehen in Tabellen der Mixins; neue Funktionen trägt man dort ein.
class Calculator extends Kern with Speicher, Funktionen, Operatoren, StackBefehle {
  final Parser<RpnToken> parser;
  late final EnterLogik enter = EnterLogik(() { if (kannAnlegen(1)) stack.dup(); });

  Calculator(this.parser) {
    parser.onToken("!", "Z", onNummer  );
    parser.onToken("!", "O", onOperator);
    parser.onToken("!", "F", onFunktion);
    parser.onToken("!", "B", onCommand );
    parser.onToken("!", "T", onTrenner );
    parser.onToken("!", "V", onVariable);
    parser.onToken("!", "S", onStackTag);
    parser.onToken("!", "K", onCode    );
  }

  @override
  void reset() {
    super.reset();
    enter.reset();
  }

  /// Gemeinsamer Ablauf für Operatoren, Funktionen und Befehle.
  /// Unbekannte Namen sind ein Fehler [fehler]. Operatoren verbrauchen keine Argumente.
  ParserResult _ausfuehren(RpnToken token, TokenTyp typ, Map<String, Aktion> tabelle, String name, String fehler) {
    // Operatoren bekommen eine leere Liste, die offenen Argumente bleiben für den nächsten Identifier
    return _schritt(token, typ, (a) {
      Aktion? aktion = tabelle[name];
      aktion == null ? error(fehler, name) : aktion(a);
    }, mitArgumenten: typ != TokenTyp.operator);
  }

  /// Ablauf jedes Tokens: Enter-Logik, Argumente, Aktion, Ergebnis.
  ///
  /// Bricht das Token mit einem Fehler ab, bleibt alles so, wie es vor dem Token war: ein dup durch das
  /// vorgemerkte Enter wird zurückgenommen, die Argumente liegen wieder bereit, das Enter ist wieder vorgemerkt.
  /// (Die Werte, die eine Aktion mit ops geholt hat, legt schon error() zurück. Was der Code einer eigenen
  /// Funktion vor einem Fehler verändert hat, bleibt dagegen; das braucht ein Undo.)
  ParserResult _schritt(RpnToken token, TokenTyp typ, void Function(Argumente a) aktion, {bool mitArgumenten = true}) {
    final enterVorher = enter.merken();
    final argumenteVorher = args.offen;
    bool dup = enter.vorToken(typ) && fehlerCode.isEmpty;
    if (fehlerCode.isEmpty) aktion(mitArgumenten ? args.nimm() : const Argumente([]));
    enter.nachToken(typ);
    if (fehlerCode.isNotEmpty) {
      if (dup) stack.pull();
      enter.wiederherstellen(enterVorher);
      args.zuruecklegen(argumenteVorher);
    }
    return ergebnis(token);
  }

  ParserResult onOperator(RpnToken token, String name) => _ausfuehren(token, TokenTyp.operator, operatoren, name, "op?");
  /// Eingebaute Funktionen aus der Tabelle, sonst eigene Funktionen aus dem Speicher.
  ParserResult onFunktion(RpnToken token, String name) {
    String? code = eigeneFunktionen[name];
    if (funktionen.containsKey(name) || code == null) {
      return _ausfuehren(token, TokenTyp.funktion, funktionen, name, "fkt?");
    }
    return _schritt(token, TokenTyp.funktion, (a) => codeAusfuehren(name, code, a));
  }

  static const int maxAufruftiefe = 100;

  /// Führt den Code einer eigenen Funktion aus: rekursiv über feedLine auf demselben Parser.
  /// Die Argumente stehen im Code über ~:, ~|: und |: zur Verfügung.
  /// Ein Fehler im Code wird zum Fehler des Aufrufs ("Fehler in name: …").
  @override
  void codeAusfuehren(String name, String code, Argumente a) {
    if (aufrufArgumente.length >= maxAufruftiefe) {
      error("rekursion", "$name (mehr als $maxAufruftiefe)");
      return;
    }
    // tokenOutput und errorPosition gehören zur äußeren Zeile
    String tokenOutput = parser.tokenOutput;
    int errorPosition = parser.errorPosition;
    aufrufArgumente.add(a.liste);
    ParserResult r = parser.feedLine(code);
    String fehlerCode = parser.currentToken.errorCode;
    String fehlerText = parser.currentToken.errorMsg;
    aufrufArgumente.removeLast();
    parser.tokenOutput = tokenOutput;
    parser.errorPosition = errorPosition;
    if (r != ParserResult.error) return;
    if (fehlerCode == "rekursion") {
      // nicht bei jeder Ebene einpacken, sonst wird die Meldung 100-mal verschachtelt
      error("rekursion", fehlerText.substring(fehlerText.indexOf(": ") + 2));
    } else {
      error("inCode", "$name: $fehlerText");
    }
  }
  ParserResult onCommand (RpnToken token, String name) => _ausfuehren(token, TokenTyp.befehl,   befehle,    name, "bef?");

  ParserResult onNummer(RpnToken token, String name) {
    return _schritt(token, TokenTyp.zahl, (a) { if (kannAnlegen(1)) stack.push(token.number); },
                    mitArgumenten: false);
  }

  ParserResult onVariable(RpnToken token, String name) {
    return _schritt(token, TokenTyp.variable, (a) => variable(name, a));
  }

  ParserResult onStackTag(RpnToken token, String name) {
    return _schritt(token, TokenTyp.tag, (a) => tagSetzen(name, a));
  }

  ParserResult onTrenner(RpnToken token, String name) {
    switch (name) {
      case " " : enter.leerzeichen();
      case "\n": enter.zeilenende();
    }
    return ergebnis(token); // auch das dup kann an einem Tag scheitern
  }

  /// Code-Blöcke: werden erkannt, aber noch nicht ausgeführt.
  /// Ein Code-Block {…} kommt auf den Code-Stack. Ein Leerzeichen davor oder danach wirkt wie sonst als Enter.
  ParserResult onCode(RpnToken token, String name) {
    return _schritt(token, TokenTyp.code, (a) => codeStack.push(token.code), mitArgumenten: false);
  }

  @override
  bool istEingebaut(String name) => funktionen.containsKey(name);
}
