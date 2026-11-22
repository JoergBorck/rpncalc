/// Aufgabe: das Anzeigeformat der Zahlen (FR-3), gemeinsam für App und Konsole. [Anzeigeformat] hält Format,
/// Stellen, Trenner und Bruch; [formatiere] schreibt einen Wert danach und sagt, ob er gerundet ist und welcher
/// SI-Vorsatz dazugehört.
///
/// Abgrenzung: Nur Anzeige, gerechnet wird weiter mit dem vollen Wert. Die Zwischenablage (format.dart) und das
/// Skript (engine/session.dart) schreiben Zahlen weiter mit `zahl()` aus helper.dart. Eingestellt wird das Format
/// im Calculator (engine/functions.dart, Befehle `rpn.format.*` …), gemeldet im Zustand (api/state.dart).
///
/// Siehe auch: process/requirements/FR-3.md (Regeln und Beispiele), doc/reference.md (Befehle), doc/api.md 3.1.
library;

import 'dart:math' as math;

import 'helper.dart';

/// Das Format der Zahlen: Std wie bisher, Fix mit n Nachkommastellen, Sci mit Exponent, Eng mit einem Exponenten
/// als Vielfaches von 3, SI mit Vorsatz statt Exponent.
enum Zahlformat { std, fix, sci, eng, si }

/// Tausendertrenner: keiner, Komma, Apostroph, schmales geschütztes Leerzeichen (U+202F).
enum Trenner {
  none(""), comma(","), apos("'"), space(" ");

  final String zeichen;
  const Trenner(this.zeichen);
}

/// Brüche: aus (#.#), unecht (#/#), gemischt (# #/#).
enum Bruch { off, improper, mixed }

/// Die Einstellungen der Anzeige (FR-3). [stellen] gilt für Fix, Sci, Eng und SI und bleibt bei Std erhalten.
class Anzeigeformat {
  final Zahlformat format;
  final int stellen;
  final Trenner trenner;
  final Bruch bruch;
  const Anzeigeformat({this.format = Zahlformat.std, this.stellen = 4, this.trenner = Trenner.none, this.bruch = Bruch.off});

  /// Standard: Std, ohne Trenner und Bruch; Stellen 4 für den ersten Wechsel auf Fix usw.
  static const standard = Anzeigeformat();

  /// Größte Stellenzahl: mit double rund 15 sichere Stellen (FR-3).
  static const maxStellen = 15;

  Anzeigeformat mit({Zahlformat? format, int? stellen, Trenner? trenner, Bruch? bruch}) => Anzeigeformat(
        format: format ?? this.format,
        stellen: (stellen ?? this.stellen).clamp(0, maxStellen),
        trenner: trenner ?? this.trenner,
        bruch: bruch ?? this.bruch,
      );

  bool get istStandard => format == Zahlformat.std && trenner == Trenner.none && bruch == Bruch.off;

  @override
  bool operator ==(Object other) =>
      other is Anzeigeformat && other.format == format && other.stellen == stellen && other.trenner == trenner &&
      other.bruch == bruch;

  @override
  int get hashCode => Object.hash(format, stellen, trenner, bruch);

  @override
  String toString() => "${format.name} $stellen ${trenner.name} ${bruch.name}";
}

/// Ein formatierter Wert: die Zahl als Text, der SI-Vorsatz (sonst leer), und ob die Zahl gerundet ist (dann
/// zeigt die Oberfläche blass „…“).
typedef Formatiert = ({String zahl, String vorsatz, bool gerundet});

/// Ein formatierter Wert als ein Text, wie ihn Konsole und App zeigen.
extension FormatiertText on Formatiert {
  /// Zahl, „…“ wenn gerundet, abgesetzt der SI-Vorsatz. Das „…“ steht vor dem Exponenten (1.235…ê6) wie vor dem
  /// Vorsatz (123.5… k), damit es bei der Mantisse steht, die gerundet ist.
  String get text {
    final s = this.zahl; // this: sonst wäre es die Funktion zahl() aus helper.dart
    final e = s.indexOf("ê");
    final punkte = gerundet ? "…" : "";
    final z = e < 0 ? "$s$punkte" : "${s.substring(0, e)}$punkte${s.substring(e)}";
    return vorsatz.isEmpty ? z : "$z $vorsatz";
  }
}

/// Die SI-Vorsätze von a (10⁻¹⁸) bis E (10¹⁸), je Exponent; 0 hat keinen.
const Map<int, String> _vorsaetze = {
  -18: "a", -15: "f", -12: "p", -9: "n", -6: "µ", -3: "m", 3: "k", 6: "M", 9: "G", 12: "T", 15: "P", 18: "E",
};

/// Schreibt [w] im Format [f] (FR-3): Zahl, Vorsatz und ob gerundet.
Formatiert formatiere(num w, Anzeigeformat f) {
  final x = w.toDouble();
  if (x.isNaN || x.isInfinite) return (zahl: zahl(w), vorsatz: "", gerundet: false);
  final dezimal = _dezimal(x, f);
  if (f.bruch != Bruch.off && x != 0) {
    final b = _alsBruch(x, f, dezimal);
    if (b != null) return (zahl: _trennen(b.text, f.trenner), vorsatz: "", gerundet: b.gerundet);
  }
  return (zahl: _trennen(dezimal.text, f.trenner), vorsatz: dezimal.vorsatz, gerundet: dezimal.gerundet);
}

/// Die Dezimalschreibweise: Text ohne Trenner, Vorsatz, gerundet, und die halbe Einheit der letzten gezeigten
/// Stelle (für den Bruch).
typedef _Dezimal = ({String text, String vorsatz, bool gerundet, double halbeEinheit});

_Dezimal _dezimal(double x, Anzeigeformat f) {
  switch (f.format) {
    case Zahlformat.std:
      final text = _exponent(zahl(x));
      return (text: text, vorsatz: "", gerundet: _gerundet(x, text), halbeEinheit: _halbeEinheitVon(text));
    case Zahlformat.fix:
      if (x.abs() >= 1e15) return _dezimal(x, f.mit(format: Zahlformat.sci));
      final ganz = x.abs() < 1 ? 1 : x.abs().floor().toString().length;
      final n = math.min(f.stellen, math.max(0, Anzeigeformat.maxStellen - ganz));
      final text = _ohneMinusNull(x.toStringAsFixed(n));
      return (text: text, vorsatz: "", gerundet: (n < f.stellen && x != 0) || _gerundet(x, text), halbeEinheit: 0.5 * _zehnHoch(-n));
    case Zahlformat.sci:
      // höchstens 15 gültige Ziffern wie bei Fix, mehr wäre Rauschen von double (1ê23 nicht als 9.999…ê22)
      final n = math.min(f.stellen, Anzeigeformat.maxStellen - 1);
      final text = _exponent(x.toStringAsExponential(n));
      final e = x == 0 ? 0 : int.parse(x.toStringAsExponential(n).split("e")[1]);
      return (text: text, vorsatz: "", gerundet: (n < f.stellen && x != 0) || _gerundet(x, text), halbeEinheit: 0.5 * _zehnHoch(e - n));
    case Zahlformat.eng || Zahlformat.si:
      if (f.stellen >= Anzeigeformat.maxStellen) {
        final d = _dezimal(x, f.mit(stellen: Anzeigeformat.maxStellen - 1));
        return (text: d.text, vorsatz: d.vorsatz, gerundet: x != 0 || d.gerundet, halbeEinheit: d.halbeEinheit);
      }
      if (x == 0) {
        final text = 0.0.toStringAsFixed(f.stellen);
        return (text: text, vorsatz: "", gerundet: false, halbeEinheit: 0.5 * _zehnHoch(-f.stellen));
      }
      // n + 1 gültige Ziffern wie bei Sci; der Exponent ein Vielfaches von 3, die Mantisse zwischen 1 und 999
      var e = int.parse(x.toStringAsExponential(f.stellen).split("e")[1]);
      var e3 = (e / 3).floor() * 3;
      final nachkomma = math.max(0, f.stellen - (e - e3));
      var mantisse = (x / _zehnHoch(e3)).toStringAsFixed(nachkomma);
      final vorsatz = f.format == Zahlformat.si && e3 != 0 ? _vorsaetze[e3] : null;
      final halbe = 0.5 * _zehnHoch(e3 - nachkomma);
      if (e3 == 0) return (text: mantisse, vorsatz: "", gerundet: _gerundet(x, mantisse), halbeEinheit: halbe);
      final gerundet = _gerundet(x, "$mantisse" "e$e3");
      if (vorsatz != null) return (text: mantisse, vorsatz: vorsatz, gerundet: gerundet, halbeEinheit: halbe);
      return (text: "$mantisseê${_minus(e3)}", vorsatz: "", gerundet: gerundet, halbeEinheit: halbe);
  }
}

/// Ob der gezeigte Text vom Wert abweicht, mehr als die Ungenauigkeit von double (0.1+0.2 zeigt 0.3 ohne „…“).
bool _gerundet(double x, String text) {
  final gezeigt = double.tryParse(text.replaceAll("ê", "e").replaceAll("−", "-"));
  if (gezeigt == null) return false;
  return (gezeigt - x).abs() > x.abs() * 1e-14 + 1e-300;
}

/// Die halbe Einheit der letzten Stelle einer Dezimalzahl in der Schreibweise von zahl().
double _halbeEinheitVon(String text) {
  final t = text.replaceAll("−", "-");
  final teile = t.split("ê");
  final e = teile.length > 1 ? int.parse(teile[1]) : 0;
  final punkt = teile[0].indexOf(".");
  final nachkomma = punkt < 0 ? 0 : teile[0].length - punkt - 1;
  return 0.5 * _zehnHoch(e - nachkomma);
}

/// 10 hoch [e] als double; mit int liefe math.pow ab 10¹⁹ über.
double _zehnHoch(int e) => math.pow(10.0, e).toDouble();

/// Der Exponent wie in der Sprache mit ê, ein negativer mit echtem Minuszeichen: 1.5e+20 → 1.5ê20, 1e-7 → 1ê−7.
String _exponent(String s) => s.replaceFirstMapped(RegExp(r"e([+-]?)(\d+)"), (m) => "ê${m[1] == "-" ? "−" : ""}${m[2]}");

String _minus(int e) => e < 0 ? "−${-e}" : "$e";

/// toStringAsFixed schreibt −0.00 für kleine negative Werte; die Anzeige zeigt 0.00.
String _ohneMinusNull(String s) => RegExp(r"^-0\.?0*$").hasMatch(s) ? s.substring(1) : s;

/// Setzt den Trenner in Dreiergruppen vor dem Punkt, in jede Ziffernfolge, die nicht nach einem Punkt oder ê steht.
String _trennen(String s, Trenner t) {
  if (t == Trenner.none) return s;
  return s.replaceAllMapped(RegExp(r"(?<![.\dê−])\d{4,}"), (m) {
    final z = m[0]!;
    final b = StringBuffer();
    for (var i = 0; i < z.length; i++) {
      if (i > 0 && (z.length - i) % 3 == 0) b.write(t.zeichen);
      b.write(z[i]);
    }
    return b.toString();
  });
}

/// Die echten Stellen einer ganzen Zahl: Ziffern ohne führende und folgende Nullen (100 hat 1, 25 hat 2).
int _echte(int n) {
  final s = n.abs().toString().replaceAll(RegExp(r"0+$"), "");
  return s.isEmpty ? 0 : s.length;
}

/// Die echten Stellen des Nachkommateils einer Dezimalzahl in der Schreibweise der Anzeige (".05" hat 1).
int _echteNachkomma(String text) {
  final t = text.split("ê")[0];
  final punkt = t.indexOf(".");
  if (punkt < 0) return 0;
  return t.substring(punkt + 1).replaceAll(RegExp(r"^0+|0+$"), "").length;
}

/// Ob [q] eine Zehnerpotenz ist (1, 10, 100 …): dann wäre der Bruch nur die Dezimalzahl.
bool _zehnerpotenz(int q) => RegExp(r"^10*$").hasMatch(q.toString());

/// Der Bruch mit dem kleinsten Nenner im Intervall [lo, hi] (0 ≤ lo ≤ hi), über Kettenbrüche; null, wenn der
/// Nenner zu groß würde.
(int, int)? _einfachster(double lo, double hi, [int tiefe = 0]) {
  if (tiefe > 40) return null;
  final fl = lo.floorToDouble();
  if (fl == lo) return (fl.toInt(), 1);
  if (fl + 1 <= hi) return (fl.toInt() + 1, 1);
  final r = _einfachster(1 / (hi - fl), 1 / (lo - fl), tiefe + 1);
  if (r == null) return null;
  final (p, q) = r;
  final zaehler = fl.toInt() * p + q;
  if (p > 1e12 || zaehler > 1e15) return null;
  return (zaehler, p);
}

/// Der Wert als Bruch nach der Grundregel (FR-3), sonst null. [d] ist die Dezimalschreibweise, die sonst gezeigt
/// würde: der Bruch ist mindestens so genau wie sie, und er erscheint nur, wenn er nicht länger ist.
({String text, bool gerundet})? _alsBruch(double x, Anzeigeformat f, _Dezimal d) {
  final neg = x < 0;
  final a = x.abs();
  final vz = neg ? "-" : "";
  final toleranz = _toleranz(x, d);
  // Eng und SI: ein Bruch nur ohne Exponent bzw. Vorsatz (unter 1000)
  if ((f.format == Zahlformat.eng || f.format == Zahlformat.si) && a >= 1000) return null;
  if (f.format == Zahlformat.sci && a >= 1) return _sciGanz(x, f, d);
  final ganz = a.floor();
  final rest = a - ganz;
  if (a >= 1e15) return null;
  if (rest <= toleranz) return null; // ganze Zahl: die Dezimalschreibweise zeigt sie schon
  if (1 - rest <= toleranz) return null;
  final r = _einfachster(math.max(0, rest - toleranz), math.min(1, rest + toleranz));
  if (r == null) return null;
  var (p, q) = r;
  if (p == 0 || p == q) return null;
  // Sci unter 1: die Zehnerpotenz aus dem Nenner herausziehen (617/50000 → 617/5ê4)
  var k = 0;
  if (f.format == Zahlformat.sci) {
    while (q % 10 == 0 && q > 1) {
      q ~/= 10;
      k++;
    }
  }
  if (q == 1 || _zehnerpotenz(q)) return null;
  // Eng und SI: keine Zehnerpotenz im Nenner (617/50000 bleibt 12.34ê−3 bzw. 12.34 m)
  if ((f.format == Zahlformat.eng || f.format == Zahlformat.si) && q % 10 == 0) return null;
  // die echten Stellen des Nachkommateils, so genau, wie die Dezimalschreibweise ihn zeigen würde
  final stellen = math.max(0, (-math.log(2 * (d.gerundet ? d.halbeEinheit : toleranz)) / math.ln10).round());
  final echteDezimal = f.format == Zahlformat.sci ? _echteMantisse(d.text) : _echteNachkomma(a.toStringAsFixed(math.min(stellen, 20)));
  if (_echte(p) + _echte(q) > echteDezimal + 1) return null;
  final wert = ganz + p / (q * _zehnHoch(k));
  final gerundet = (wert - a).abs() > a * 1e-14;
  final hoch = k > 0 ? "ê$k" : "";
  if (ganz == 0) return (text: "$vz$p/$q$hoch", gerundet: gerundet);
  if (f.bruch == Bruch.improper) return (text: "$vz${ganz * q + p}/$q", gerundet: gerundet);
  return (text: "$vz$ganz $p/$q", gerundet: gerundet);
}

/// Wie weit ein Bruch vom Wert abweichen darf. Ist die Dezimalzahl exakt, muss es der Bruch auch sein (bis auf
/// die Ungenauigkeit von double); ist sie gerundet, muss er um eine Stelle genauer sein als sie, also höchstens
/// ein Zehntel ihrer halben Einheit abweichen (123.4567 bei SI 3 bleibt 123.5…, nicht 123 1/2…; π bei Fix 1 wird
/// 3 1/7…).
double _toleranz(double x, _Dezimal d) => d.gerundet ? d.halbeEinheit / 10 : math.max(x.abs(), 1) * 1e-13;

/// Die echten Stellen der Mantisse einer Zahl in Sci (1.234ê−2 hat 4).
int _echteMantisse(String text) =>
    text.split("ê")[0].replaceAll(RegExp(r"[-.]"), "").replaceAll(RegExp(r"^0+|0+$"), "").length;

/// Sci ab 1 mit Bruch: eine ganze Zahl mit Zehnerpotenz als Exponent (1234000 → 1234ê3), mit Bruchteil wie sonst
/// (1.5 → 1 1/2); sonst null.
({String text, bool gerundet})? _sciGanz(double x, Anzeigeformat f, _Dezimal d) {
  final a = x.abs();
  final vz = x < 0 ? "-" : "";
  if (a >= 1e15) return null;
  final ganz = a.round();
  final toleranz = _toleranz(x, d);
  if ((ganz - a).abs() <= toleranz && _echte(ganz) <= _echteMantisse(d.text)) {
    var g = ganz, k = 0;
    while (g % 10 == 0 && g > 0) {
      g ~/= 10;
      k++;
    }
    final gerundet = (ganz - a).abs() > a * 1e-14;
    return (text: "$vz$g${k > 0 ? "ê$k" : ""}", gerundet: gerundet);
  }
  return _alsBruch(x, f.mit(format: Zahlformat.fix, stellen: f.stellen), d);
}

/// Die Befehle, die [f] wieder einstellen, für die Zeile der Einstellungen im Skript (FR-3); nur, was nicht auf
/// Standard steht: z.B. `4:rpn.format.fix`, `rpn.sep.apos`.
List<String> anzeigeBefehle(Anzeigeformat f) => [
      if (f.format != Zahlformat.std || f.stellen != Anzeigeformat.standard.stellen) "${f.stellen}:rpn.format.${f.format.name}",
      if (f.trenner != Trenner.none) "rpn.sep.${f.trenner.name}",
      if (f.bruch != Bruch.off) "rpn.frac.${f.bruch.name}",
    ];
