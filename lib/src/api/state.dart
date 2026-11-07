/// Aufgabe: der Zustand des Rechners als reine Daten: [Zustand] mit [StackZeile], [Speicher] und [Fehler], jeweils
/// mit JSON für das Protokoll (doc/api.md Kapitel 6). [zustandVon] baut ihn aus dem Interpreter, [speicherVon]
/// liest Variablen, Tags und eigene Funktionen aus dem Calculator.
///
/// Abgrenzung: Die Klassen sind über rpnapi.dart öffentlich; wie der Zustand angezeigt wird, entscheidet die
/// Oberfläche. Woher die Werte kommen, steht in engine/ (Interpreter, Calculator).
///
/// Siehe auch: doc/api.md Kapitel 4 und 6, engine/interpreter.dart, lib/rpnapi.dart.
library;

import '../engine/calculator.dart' show AngleMode, Calculator;
import '../engine/interpreter.dart';

/// Eine Zeile der Stack-Anzeige.
class StackZeile {
  final int position;       // 0 = Tos, wie bei den Argumenten
  final num wert;
  final List<String> tags;  // Namen der Tags auf dieser Zelle, bei Blöcken mit Element, z.B. "v[1]"
  const StackZeile(this.position, this.wert, this.tags);

  Map<String, Object?> toJson() => {"position": position, "wert": _zahlNachJson(wert), "tags": tags};

  factory StackZeile.fromJson(Map<String, Object?> j) =>
      StackZeile(j["position"] as int, _zahlAusJson(j["wert"]), _texte(j["tags"]));
}

/// NaN und unendlich gibt es in JSON nicht, sie werden als Text geschrieben (doc/api.md Kapitel 6).
/// Ganze Zahlen ohne ".0", soweit sie in JSON (bzw. JavaScript) noch exakt darstellbar sind.
Object _zahlNachJson(num w) =>
    !w.isFinite ? w.toString() : (w == w.truncate() && w.abs() < 9007199254740992) ? w.toInt() : w;

num _zahlAusJson(Object? j) => j is String ? double.parse(j) : j as num;

List<num> _zahlen(Object? j) => List.unmodifiable([for (final w in j as List) _zahlAusJson(w)]);

List<String> _texte(Object? j) => List.unmodifiable((j as List).cast<String>());

enum SpeicherArt { variable, tag, funktion }

/// Eine Variable oder ein Tag mit seinen Werten (Element 0 zuerst), oder eine eigene Funktion mit ihrem Code.
class Speicher {
  final String name;
  final SpeicherArt art;
  final List<num> werte;
  final String code;        // nur bei eigenen Funktionen
  final bool schreibschutz; // Konstante ('!!x) bzw. Tag mit Schreibschutz ('||x)
  final bool intern;        // nur bei Funktionen: mit rpnintern gekennzeichnet, keine Funktionstaste
  const Speicher(this.name, this.art, this.werte, [this.code = "", this.schreibschutz = false, this.intern = false]);

  Map<String, Object?> toJson() => {
        "name": name,
        "art": art.name,
        "werte": [for (final w in werte) _zahlNachJson(w)],
        "code": code,
        "schreibschutz": schreibschutz,
        "intern": intern,
      };

  factory Speicher.fromJson(Map<String, Object?> j) => Speicher(j["name"] as String,
      SpeicherArt.values.byName(j["art"] as String), _zahlen(j["werte"]), j["code"] as String, j["schreibschutz"] as bool,
      j["intern"] as bool? ?? false); // ältere Server schicken intern nicht
}

/// Ein Fehler aus Grammatik oder Calculator.
class Fehler {
  final String code;
  final String text;
  final int position;       // Zeichen der Eingabezeile, bei dem der Fehler erkannt wurde
  final int start;          // erstes Zeichen des fehlerhaften Tokens, zum Markieren
  final String token;       // Text des fehlerhaften Tokens
  const Fehler(this.code, this.text, this.position, [this.start = -1, this.token = ""]);

  Map<String, Object?> toJson() => {"code": code, "text": text, "position": position, "start": start, "token": token};

  factory Fehler.fromJson(Map<String, Object?> j) => Fehler(
      j["code"] as String, j["text"] as String, j["position"] as int, j["start"] as int, j["token"] as String);
}

/// Alles, was eine Anzeige braucht. Reine Daten, die Darstellung übernimmt die Oberfläche.
/// Die Listen sind unveränderlich, ein Zustand bleibt also so, wie er geliefert wurde.
class Zustand {
  final List<StackZeile> stack;     // die obersten belegten Zellen, Tos zuerst
  final int tiefe;                  // Anzahl der belegten Zellen
  final List<Speicher> speicher;    // Variablen, Tags und eigene Funktionen
  final List<num> argumente;        // mit ":" übergeben, noch nicht verbraucht
  final AngleMode winkel;
  final int? seed;                  // null = echte Zufallszahlen
  final Fehler? fehler;             // Fehler der letzten Eingabe oder null
  final bool codeOffen;             // ein Code-Block ist noch nicht abgeschlossen, die nächste Zeile setzt ihn fort
  final List<String> codeStack;     // Blöcke auf dem Code-Stack, der oberste zuerst
  final String offen;               // Text des noch offenen Tokens, "" wenn keins
  final bool enterVorgemerkt;       // ein Leerzeichen wartet auf das nächste Token
  final String zeile;               // die bisher eingegebene Zeile
  final bool zeileFertig;           // die Zeile ist abgeschlossen, die nächste Taste beginnt eine neue
  const Zustand(this.stack, this.tiefe, this.speicher, this.argumente, this.winkel, this.seed, this.fehler,
                this.codeOffen, this.codeStack, this.offen, this.enterVorgemerkt, this.zeile, this.zeileFertig);

  /// Der Zustand als JSON-Objekt, z.B. für den Socket (doc/api.md Kapitel 6). Mit jsonEncode wird daraus
  /// eine einzige Zeile, auch wenn der Code Zeilenumbrüche enthält.
  Map<String, Object?> toJson() => {
        "stack": [for (final z in stack) z.toJson()],
        "tiefe": tiefe,
        "speicher": [for (final s in speicher) s.toJson()],
        "argumente": [for (final a in argumente) _zahlNachJson(a)],
        "winkel": winkel.name,
        "seed": seed,
        "fehler": fehler?.toJson(),
        "codeOffen": codeOffen,
        "codeStack": codeStack,
        "offen": offen,
        "enterVorgemerkt": enterVorgemerkt,
        "zeile": zeile,
        "zeileFertig": zeileFertig,
      };

  factory Zustand.fromJson(Map<String, Object?> j) => Zustand(
        List.unmodifiable([for (final z in j["stack"] as List) StackZeile.fromJson(z as Map<String, Object?>)]),
        j["tiefe"] as int,
        List.unmodifiable([for (final s in j["speicher"] as List) Speicher.fromJson(s as Map<String, Object?>)]),
        _zahlen(j["argumente"]),
        AngleMode.values.byName(j["winkel"] as String),
        j["seed"] as int?,
        j["fehler"] == null ? null : Fehler.fromJson(j["fehler"] as Map<String, Object?>),
        j["codeOffen"] as bool,
        _texte(j["codeStack"]),
        j["offen"] as String,
        j["enterVorgemerkt"] as bool,
        j["zeile"] as String,
        j["zeileFertig"] as bool,
      );
}

/// Der aktuelle Zustand mit höchstens [zeilen] Stack-Zeilen.
Zustand zustandVon(Interpreter i, {int zeilen = 8}) {
  final calculator = i.calculator, parser = i.parser;
  final stack = calculator.stack;
  int anzahl = (stack.tiefe < zeilen) ? stack.tiefe : zeilen;
  final f = i.fehler;
  return Zustand(
    List.unmodifiable([for (int k = 0; k < anzahl; k++) StackZeile(k, stack[k], _tagsAn(calculator, stack.adr(k)))]),
    stack.tiefe,
    speicherVon(calculator),
    List.unmodifiable(calculator.args.offen),
    calculator.angleMode,
    calculator.seed,
    f == null ? null : Fehler(f.code, f.text, f.position, f.start, f.token),
    i.codeOffen,
    List.unmodifiable(calculator.codeStack.inhalt),
    parser.offen,
    calculator.enter.vorgemerkt,
    i.zeile,
    parser.zeileFertig,
  );
}

/// Variablen, Tags (mit den Werten ihrer Zellen) und eigene Funktionen, in dieser Reihenfolge.
List<Speicher> speicherVon(Calculator calculator) => List.unmodifiable([
      for (var v in calculator.variablen.entries)
        Speicher(v.key, SpeicherArt.variable, List.unmodifiable(v.value), "", calculator.schreibschutz.contains(v.key)),
      for (var t in calculator.tags.entries)
        Speicher(t.key, SpeicherArt.tag, List.unmodifiable([for (int a in t.value) calculator.stack.wertAn(a)]), "",
                 calculator.schreibschutz.contains(t.key)),
      for (var f in calculator.eigeneFunktionen.entries)
        Speicher(f.key, SpeicherArt.funktion, const [], f.value, false, calculator.intern.contains(f.key)),
    ]);

/// Namen der Tags auf einer Adresse, bei Blöcken mit Elementnummer.
List<String> _tagsAn(Calculator calculator, int adresse) => List.unmodifiable([
      for (var t in calculator.tags.entries)
        if (t.value.contains(adresse)) t.value.length == 1 ? t.key : "${t.key}[${t.value.indexOf(adresse)}]",
    ]);
