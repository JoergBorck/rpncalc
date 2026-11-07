/// Aufgabe: die Regel „Leerzeichen als Enter“. [EnterLogik] merkt ein Leerzeichen vor und lässt das nächste
/// Token entscheiden, ob es nur trennt (Zahl ␣ Zahl, Identifier ␣ Identifier) oder als Enter ein dup auslöst.
/// Ihr Zustand lässt sich nach einem fehlerhaften Token wiederherstellen und ein vorgemerktes Enter beim Löschen
/// zurücknehmen. Dazu [TokenTyp], die Art eines Tokens.
///
/// Abgrenzung: Das dup selbst übergibt der Calculator (calculator.dart) als Funktion, damit die Enter-Logik
/// weder Stack noch Tags kennen muss. Welches Zeichen ein Trenner ist, legt ../language/grammar.dart fest.
///
/// Siehe auch: doc/reference.md 3.3 und 3.4, doc/api.md 5.2, calculator.dart.
library;

/// Art des zuletzt verarbeiteten Tokens.
enum TokenTyp { zahl, operator, funktion, befehl, variable, tag, code, trenner }

/// Entscheidet, ob ein Leerzeichen zwei Token nur trennt oder als Enter (dup) wirkt.
///
/// Das Leerzeichen führt das dup nicht sofort aus, sondern merkt es nur vor. Das nächste Token
/// entscheidet: Zahl ␣ Zahl und Identifier ␣ Identifier trennen nur, sonst wirkt es als Enter.
/// Befehle zählen nicht als Identifier, sie brauchen kein trennendes Leerzeichen.
class EnterLogik {
  static const Set<TokenTyp> _identifier = {TokenTyp.funktion, TokenTyp.variable, TokenTyp.tag};

  /// Wird aufgerufen, wenn das Leerzeichen als Enter wirkt.
  final void Function() dup;

  TokenTyp? _letzter;
  bool _vorgemerkt = false;

  EnterLogik(this.dup);

  /// Hat das letzte Leerzeichen das vorher vorgemerkte Enter ausgeführt (z.B. bei zwei Leerzeichen)?
  bool _letztesLeerzeichenHatDup = false;

  /// Ein Leerzeichen wartet auf das nächste Token.
  bool get vorgemerkt => _vorgemerkt;

  /// Vor jedem Token: ein vorgemerktes dup ausführen, außer das Leerzeichen hat nur getrennt.
  /// Liefert true, wenn ein dup ausgeführt wurde.
  bool vorToken(TokenTyp typ) {
    if (!_vorgemerkt) return false;
    _vorgemerkt = false;
    bool nurTrennen = (_letzter == TokenTyp.zahl && typ == TokenTyp.zahl)
                   || (_identifier.contains(_letzter) && _identifier.contains(typ));
    if (!nurTrennen) dup();
    return !nurTrennen;
  }

  /// Der Zustand der Enter-Logik, damit er nach einem fehlerhaften Token wiederhergestellt werden kann.
  (TokenTyp?, bool, bool) merken() => (_letzter, _vorgemerkt, _letztesLeerzeichenHatDup);

  void wiederherstellen((TokenTyp?, bool, bool) z) {
    _letzter = z.$1;
    _vorgemerkt = z.$2;
    _letztesLeerzeichenHatDup = z.$3;
  }

  /// Nimmt ein vorgemerktes Enter zurück (Löschen des Leerzeichens).
  /// Geht nicht, wenn das Leerzeichen schon ein früheres Enter ausgeführt hat.
  bool zuruecknehmen() {
    if (!_vorgemerkt || _letztesLeerzeichenHatDup) return false;
    _vorgemerkt = false;
    return true;
  }

  /// Nach jedem Token: seine Art merken.
  void nachToken(TokenTyp typ) => _letzter = typ;

  /// Ein Leerzeichen: ein vorheriges Leerzeichen wirkt als Enter, dieses wird nur vorgemerkt.
  void leerzeichen() {
    _letztesLeerzeichenHatDup = vorToken(TokenTyp.trenner);
    _vorgemerkt = true;
  }

  /// Zeilenende: schließt wie "_" nur ein Token ab und tut sonst nichts.
  /// Ein vorgemerktes Enter bleibt bestehen, das nächste Token (auch in der nächsten Zeile) entscheidet.
  void zeilenende() {}

  void reset() {
    _letzter = null;
    _vorgemerkt = false;
    _letztesLeerzeichenHatDup = false;
  }
}
