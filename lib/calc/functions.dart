import 'dart:convert';
import 'dart:math' as math;

import '../helper.dart';
import 'arguments.dart';
import 'core.dart';
import 'value.dart';
import '../version.dart';

enum AngleMode { deg, rad, grad }

/// Funktionen: Konstanten, Logarithmen, Winkelfunktionen, Zufallszahlen, Runden.
/// Ein "~" vor dem Namen bildet die Umkehrfunktion.
mixin Funktionen on Kern {
  AngleMode angleMode = AngleMode.deg;

  // Zufallszahlen: "s seed" setzt den Startwert, danach liefert rnd eine reproduzierbare Folge.
  math.Random _zufall = math.Random();
  int? seed; // gesetzter Startwert, null = echte Zufallszahlen

  // rpnjson (doc/reference.md 10.5): abgelegte Hilfen (Kennung → JSON wie Hilfe.toJson) und Versionsangaben
  // von Bibliotheken (Name → JSON); Hinweise, z.B. auf unbekannte Schlüssel.
  final Map<String, Map<String, Object?>> eigeneHilfen = {};
  final Map<String, Map<String, Object?>> versionen = {};
  final List<String> hinweise = [];

  /// Version der Oberfläche (App), wenn sie sie mitgeteilt hat; sonst wird `app` in rpnjson übergangen.
  String? appVersion;

  @override
  void reset() {
    super.reset();
    angleMode = AngleMode.deg;
    seed = null;
    _zufall = math.Random();
    eigeneHilfen.clear();
    versionen.clear();
  }

  /// {json}rpnjson: den obersten Block als JSON-Objekt lesen und auswerten. Unbekannte Schlüssel werden
  /// übergangen und als Hinweis gemeldet, damit ältere Versionen neuere Bibliotheken laden können.
  void _rpnjson() {
    final String? code = codeStack.pull();
    if (code == null) {
      error("code0", "für rpnjson");
      return;
    }
    Object? j;
    try {
      j = jsonDecode(code);
    } on FormatException catch (e) {
      error("json", e.message);
      return;
    }
    if (j is! Map<String, Object?>) {
      error("json", "erwartet wird ein Objekt { … }");
      return;
    }
    for (final e in j.entries) {
      switch (e.key) {
        case "version":
          if (!_version(e.value)) return; // passt nicht: der Rest des Blocks wird nicht ausgeführt
        case "hilfe":
          _hilfen(e.value);
        default:
          hinweise.add("Unbekannter Schlüssel in rpnjson: ${e.key}");
      }
    }
  }

  /// Prüft die Versionsangabe einer Bibliothek gegen Rechner und App und merkt sie sich.
  bool _version(Object? v) {
    if (v is! Map<String, Object?> || v["name"] is! String) {
      error("json", "version braucht einen name");
      return false;
    }
    final name = v["name"] as String;
    for (final (schluessel, wer, vorhanden) in [("rechner", "den Rechner", rechnerVersion), ("app", "die App", appVersion)]) {
      final verlangt = v[schluessel];
      if (verlangt is! String || vorhanden == null) continue;
      final passt = versionPasst(vorhanden, verlangt);
      if (passt == null) {
        error("version", "ungültige Versionsangabe $schluessel: $verlangt");
        return false;
      }
      if (!passt) {
        error("version", "$name braucht $wer $verlangt, vorhanden ist $vorhanden");
        return false;
      }
    }
    versionen[name] = v;
    return true;
  }

  /// Legt Hilfeeinträge ab; ein Eintrag braucht eine kennung.
  void _hilfen(Object? liste) {
    if (liste is! List) {
      hinweise.add("hilfe in rpnjson muss eine Liste sein");
      return;
    }
    for (final h in liste) {
      if (h is Map<String, Object?> && h["kennung"] is String) {
        eigeneHilfen[h["kennung"] as String] = h;
      } else {
        hinweise.add("Hilfeeintrag ohne kennung übergangen");
      }
    }
  }

  late final Map<String, Aktion> funktionen = {
    // Konstanten
    "pi"   : (a) { ops=0; result(math.pi); },
    "e"    : (a) { ops=0; result(math.e); },
    // Exponential und Logarithmus
    "ln"   : (a) { ops=1; result(math.log(x)); },
    "exp"  : (a) { ops=1; result(math.exp(x)); },
    "~ln"  : (a) { ops=1; result(math.exp(x)); },
    "log"  : (a) { ops=1; result(math.log(x) / math.log(a.zahl(0, 10))); }, // b:log, Standard Basis 10
    "~log" : (a) { ops=1; result(math.pow(a.zahl(0, 10), x)); },          // b:~log = b^x
    // Zufallszahlen
    "rnd"  : zufall,
    "seed" : (a) { ops=1; seed = x.toInt(); _zufall = math.Random(seed); },
    "~seed": (a) { seed = null; _zufall = math.Random(); }, // Seed aufheben, wieder echte Zufallszahlen
    // Runden: stellen:art:round, siehe runden() in helper.dart
    "round": (a) { ops=1; Wert? r = runden(x, a.ganz(0, 0), a.ganz(1, 0));
                   r == null ? error("round", "${a.ganz(1, 0)}") : result(r); },
    // Winkelfunktionen
    "deg"  : (a) { angleMode = AngleMode.deg; },
    "rad"  : (a) { angleMode = AngleMode.rad; },
    "grd"  : (a) { angleMode = AngleMode.grad; },
    "sin"  : (a) { ops=1; result(sinus(x)); },
    "cos"  : (a) { ops=1; result(cosinus(x)); },
    "tan"  : (a) { ops=1; result(tangens(x)); },
    "asin" : (a) { ops=1; result(angle(math.asin(x),true)); },
    "~sin" : (a) { ops=1; result(angle(math.asin(x),true)); },
    "acos" : (a) { ops=1; result(angle(math.acos(x),true)); },
    "~cos" : (a) { ops=1; result(angle(math.acos(x),true)); },
    "atan" : (a) { ops=1; result(angle(math.atan(x),true)); },
    "~tan" : (a) { ops=1; result(angle(math.atan(x),true)); },
    "dms"  : (a) { ops=1; var [d,m,s] = dms(angle(x)); result(d,m,s); },
    // Erweiterungen: Versionsangaben und Hilfetexte aus einem JSON-Block (doc/reference.md 10.5)
    "rpnjson": (a) { _rpnjson(); },
    // Kontrollstrukturen: Blöcke vom Code-Stack, Wahrheitswert vom Stack (0 = falsch, sonst wahr)
    "if"   : (a) { if (!_bloecke(1, "if")) return;
                   ops=1; if (fehlerCode.isNotEmpty) return;
                   String dann = codeStack.pull()!;
                   if (x != 0) codeAusfuehren("if", dann, a); },
    "ifel" : (a) { if (!_bloecke(2, "ifel")) return;
                   ops=1; if (fehlerCode.isNotEmpty) return;
                   String sonst = codeStack.pull()!;
                   String dann  = codeStack.pull()!;
                   codeAusfuehren("ifel", x != 0 ? dann : sonst, a); },
    "loop" : schleife,
    "times": wiederholen,
    // Befehle für den Code-Stack, wie D, S und Y für den Werte-Stack (Position 0 = oberster Block)
    "codedrop": (a) { _code(codeStack.drop(a.ganz(0, 1)), "codedrop"); },                           // n:codedrop
    "codeswap": (a) { _code(codeStack.swap(a.ganz(0, 1), a.ganz(1, 0), a.ganz(2, 1)), "codeswap"); }, // tgt:src:len:codeswap
    "codedup" : (a) { _code(codeStack.kopieren(0, a.ganz(0, 1)), "codedup"); },                      // n:codedup
    "codeover": (a) { _code(codeStack.kopieren(a.ganz(0, 1), a.ganz(1, 1)), "codeover"); },          // quelle:anzahl:codeover
  };

  /// Fehler, wenn eine Operation auf dem Code-Stack nicht möglich war (zu wenige Blöcke).
  void _code(bool ok, String name) {
    if (!ok) error("code2", "für $name (es gibt ${codeStack.length})");
  }

  /// Prüft, ob mindestens [n] Blöcke auf dem Code-Stack liegen.
  bool _bloecke(int n, String name) {
    if (codeStack.length >= n) return true;
    error(n == 1 ? "code0" : "code2", "für $name");
    return false;
  }

  /// {code}loop: führt den Block aus, nimmt danach einen Wert vom Stack und wiederholt, solange er wahr ist.
  void schleife(Argumente a) {
    if (!_bloecke(1, "loop")) return;
    String code = codeStack.pull()!;
    for (int i = 1; ; i++) {
      if (i > maxSchleife) {
        error("schleife", "loop: mehr als $maxSchleife");
        return;
      }
      codeAusfuehren("loop", code, a);
      if (fehlerCode.isNotEmpty) return;
      ops=1;
      if (fehlerCode.isNotEmpty || x == 0) return;
    }
  }

  /// n:{code}times: führt den Block n-mal aus; der Index (ab 0) ist das einzige Argument eines Durchlaufs.
  void wiederholen(Argumente a) {
    if (!_bloecke(1, "times")) return;
    if (a.isEmpty || !a[0].isFinite || a[0] != a[0].truncate()) {
      error("anzahl", "für times");
      return;
    }
    if (a[0] > maxSchleife) {
      error("schleife", "times: mehr als $maxSchleife");
      return;
    }
    String code = codeStack.pull()!;
    for (int i = 0; i < a[0]; i++) {
      codeAusfuehren("times", code, Argumente([i]));
      if (fehlerCode.isNotEmpty) return;
    }
  }

  /// (sin, cos) exakt, wenn [phi] ein Vielfaches eines Viertelkreises ist (90°, 100 gon, π/2), sonst null.
  /// Wie beim HP: sonst bliebe z.B. von cos 90° ein Rest von 6e-17 statt 0.
  (int, int)? _viertelkreis(num phi) {
    num viertel = switch (angleMode) { AngleMode.deg => 90, AngleMode.grad => 100, AngleMode.rad => math.pi / 2 };
    num q = phi / viertel;
    if (!q.isFinite || q != q.roundToDouble()) return null;
    return const [(0, 1), (1, 0), (0, -1), (-1, 0)][q.round() % 4];
  }

  num sinus(num phi) => _viertelkreis(phi)?.$1 ?? math.sin(angle(phi));
  num cosinus(num phi) => _viertelkreis(phi)?.$2 ?? math.cos(angle(phi));

  /// Bei 90° und 270° (Polstellen) ±unendlich, bei 0° und 180° exakt 0.
  num tangens(num phi) {
    final v = _viertelkreis(phi);
    if (v == null) return math.tan(angle(phi));
    return v.$1 == 0 ? 0 : v.$1 / v.$2;
  }

  /// Rechnet den Wert in rad um oder mit [rev] zurück.
  num angle(num phi, [bool rev = false]) {
    num factor=1;
    switch (angleMode) {
      case AngleMode.deg : factor = math.pi / 180;
      case AngleMode.grad: factor = math.pi / 200;
      case AngleMode.rad : return phi;
    }
    return rev ? phi/factor : phi * factor;
  }

  /// Wandelt einen Winkel in Grad / Minute / Sekunde um.
  List<num> dms(num phi, [num? min, num? sec]) {
    if (min != null) {
      sec=sec??0;
      return [ (phi.sign == 0 ? 1 : phi.sign) // Vorzeichen
            * (phi.abs() + (min.abs() / 60) + (sec.abs() / 3600)) // zusammenfassen
            * (math.pi / 180) ]; // Umrechnen in rad
    }
    num sign = phi == 0 ? 1 : phi.sign;
    num d = round(phi.abs() * (180 / math.pi), 10);
    num m = round((d%1) * 60, 10); d=d.truncate();
    num s = round((m%1) * 60,  6); m=m.truncate();
    return [sign * d, m, s];
  }

  /// rnd: Zahl in [0, 1); n:rnd: ganze Zahl von 1 bis n; a:b:rnd: ganze Zahl von a bis b.
  void zufall(Argumente a) {
    if (a.isEmpty) {
      result(_zufall.nextDouble());
      return;
    }
    int von = (a.length == 1) ? 1 : a.ganz(0, 1);
    int bis = (a.length == 1) ? a.ganz(0, 1) : a.ganz(1, 1);
    if (bis < von) {
      error("rnd", "$von bis $bis");
      return;
    }
    result(von + _zufall.nextInt(bis - von + 1));
  }
}
