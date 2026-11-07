/// Aufgabe: der Code-Stack. [CodeStack] nimmt die Code-Blöcke {…} als Text auf, getrennt vom Werte-Stack, und
/// bietet die Grundoperationen, auf denen die Befehle für den Code-Stack aufbauen (drop, swap, kopieren).
///
/// Abgrenzung: Wer Blöcke herunternimmt und ausführt (':name, X, if, ifel, loop, times, rpnjson), steht in
/// storage.dart, stack_commands.dart und functions.dart; die Befehle codedrop, codeswap, codedup und codeover
/// in functions.dart.
///
/// Siehe auch: doc/reference.md 10.1 und 10.4, core.dart.
library;

/// Stack für Code-Blöcke, vollständig getrennt vom Werte-Stack.
///
/// Ein Block {…} wird hier abgelegt. Von hier holen ihn ':name (als Funktion ablegen), X, die Kontrollstrukturen
/// (if, ifel, loop, times), rpnjson und die Befehle codedrop, codeswap, codedup, codeover. Positionen zählen ab 0
/// (oberster Block).
class CodeStack {
  final List<String> _bloecke = [];

  int get length => _bloecke.length;
  bool get isEmpty => _bloecke.isEmpty;

  /// Alle Blöcke, der oberste zuerst (z.B. für die Anzeige).
  List<String> get inhalt => List.unmodifiable(_bloecke.reversed);

  void push(String code) => _bloecke.add(code);

  /// Nimmt den obersten Block herunter; null, wenn der Code-Stack leer ist.
  String? pull() => _bloecke.isEmpty ? null : _bloecke.removeLast();

  void reset() => _bloecke.clear();

  /// Index in der Liste zu einer Position (0 = oberster Block).
  int _index(int pos) => _bloecke.length - 1 - pos;

  /// Entfernt die obersten [n] Blöcke. false, wenn es nicht genug gibt.
  bool drop(int n) {
    if (n < 0 || n > length) return false;
    _bloecke.removeRange(length - n, length);
    return true;
  }

  /// Tauscht [len] Blöcke ab Position [src] mit [len] Blöcken ab Position [tgt].
  bool swap(int tgt, int src, int len) {
    if (tgt < 0 || src < 0 || len < 1 || tgt + len > length || src + len > length) return false;
    for (int i = 0; i < len; i++) {
      int a = _index(src + i), b = _index(tgt + i);
      String t = _bloecke[a];
      _bloecke[a] = _bloecke[b];
      _bloecke[b] = t;
    }
    return true;
  }

  /// Kopiert [anzahl] Blöcke ab Position [quelle] nach oben, die Reihenfolge bleibt erhalten.
  bool kopieren(int quelle, int anzahl) {
    if (quelle < 0 || anzahl < 1 || quelle + anzahl > length) return false;
    var kopie = [for (int p = quelle + anzahl - 1; p >= quelle; p--) _bloecke[_index(p)]];
    _bloecke.addAll(kopie);
    return true;
  }
}
