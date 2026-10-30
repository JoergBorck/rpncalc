import 'bibliotheken.g.dart';
import 'calculator.dart';
import 'helper.dart';
import 'hilfe.dart';
import 'rpntoken.dart';
import 'parser.dart';
import 'session.dart';
import 'version.dart';

export 'calculator.dart' show AngleMode;
export 'session.dart' show Export;
export 'hilfe.dart' show Hilfe, Verwendung;

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
  const Speicher(this.name, this.art, this.werte, [this.code = "", this.schreibschutz = false]);

  Map<String, Object?> toJson() => {
        "name": name,
        "art": art.name,
        "werte": [for (final w in werte) _zahlNachJson(w)],
        "code": code,
        "schreibschutz": schreibschutz,
      };

  factory Speicher.fromJson(Map<String, Object?> j) => Speicher(j["name"] as String,
      SpeicherArt.values.byName(j["art"] as String), _zahlen(j["werte"]), j["code"] as String, j["schreibschutz"] as bool);
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

/// Fassade für alle Oberflächen (Konsole, Socket-Server, später Flutter):
/// Eingabe hinein, Zustand heraus. Parser und Calculator bleiben dahinter verborgen.
class RpnApi {
  final Parser<RpnToken> parser;
  final Calculator calculator; // muss sofort entstehen, damit seine Callbacks beim Parser registriert sind
  Fehler? _letzterFehler;
  String _zeile = "";  // die bisher eingegebene Zeile

  RpnApi() : this._(rpnParser());
  RpnApi._(this.parser) : calculator = Calculator(parser);

  /// Verarbeitet eine Eingabezeile und liefert den neuen Zustand.
  /// Ein offener Code-Block bleibt über das Zeilenende hinweg erhalten.
  /// Das ist dasselbe wie taste() für jedes Zeichen und danach zeilenende().
  /// Enthält [zeile] Zeilenumbrüche, wirkt das wie mehrere Zeilen nacheinander. Ein Fehler bricht aber
  /// den ganzen Text ab, damit sich der Stack danach nicht unbemerkt weiter verändert.
  Zustand eingabe(String zeile, {int zeilen = 8}) {
    for (var teil in zeile.split("\n")) {
      parser.neueZeile();
      _neueZeile();
      for (var c in teil.split("")) {
        _taste(c);
      }
      _ausfuehren("\n");
      if (_letzterFehler != null) break;
    }
    return zustand(zeilen: zeilen);
  }

  /// Verarbeitet ein einzelnes Zeichen. Ein Token wird ausgeführt, sobald feststeht, dass es zu Ende ist.
  Zustand taste(String zeichen, {int zeilen = 8}) {
    if (zeichen == "\n") return zeilenende(zeilen: zeilen);
    for (var c in zeichen.split("")) {
      _taste(c);
    }
    return zustand(zeilen: zeilen);
  }

  /// Schließt die Zeile ab, wie das Zeilenende bei eingabe().
  Zustand zeilenende({int zeilen = 8}) {
    if (parser.zeileFertig) _neueZeile();
    _ausfuehren("\n");
    return zustand(zeilen: zeilen);
  }

  /// Nimmt das zuletzt eingegebene Zeichen zurück: im offenen Token oder ein vorgemerktes Enter.
  /// Nach einem Fehler erst die Tasten danach, dann die auslösende Taste; dann ist das Token wieder offen.
  /// Schon ausgeführte Token bleiben (dafür braucht es ein Undo, siehe doc/api.md 5.4).
  Zustand loeschen({int zeilen = 8}) {
    if (!parser.zeileFertig && _zeile.isNotEmpty) {
      if (parser.zurueck()) {
        _zeile = _zeile.substring(0, _zeile.length - 1);
        if (!parser.abgebrochen) _letzterFehler = null; // repariert: das fehlerhafte Token ist wieder offen
      } else if (_zeile.endsWith(" ") && calculator.enter.zuruecknehmen()) {
        parser.zurueckTrenner();
        _zeile = _zeile.substring(0, _zeile.length - 1);
      }
    }
    return zustand(zeilen: zeilen);
  }

  void _taste(String c) {
    if (parser.zeileFertig) _neueZeile();
    _zeile += c;
    _ausfuehren(c);
  }

  void _ausfuehren(String c) {
    ParserResult result = parser.taste(c);
    if (resultError.contains(result) && _letzterFehler == null) {
      _letzterFehler = Fehler(parser.currentToken.errorCode, parser.currentToken.errorMsg, parser.errorPosition,
                              parser.fehlerStart, parser.fehlerToken);
    }
  }

  void _neueZeile() {
    _zeile = "";
    _letzterFehler = null;
  }

  // ---------- Version und Bibliotheken (doc/api.md 9.1) ----------

  /// Version des Rechners (MAJOR.MINOR.PATCH).
  static const String version = rechnerVersion;

  /// Die Oberfläche teilt ihre eigene Version mit; rpnjson prüft dann auch die Angabe `app` einer Bibliothek.
  set appVersion(String? v) => calculator.appVersion = v;

  final Map<String, String> _hinzugefuegt = {};
  final Set<String> _geladeneBibliotheksFunktionen = {};

  /// Alle Bibliotheken, mitgelieferte zuerst, jeweils nach Namen.
  List<({String name, bool mitgeliefert})> bibliotheken() => [
        for (final n in mitgelieferteBibliotheken.keys.toList()..sort()) (name: n, mitgeliefert: true),
        for (final n in _hinzugefuegt.keys.toList()..sort()) (name: n, mitgeliefert: false),
      ];

  /// Der Text einer Bibliothek oder null.
  String? bibliothek(String name) => mitgelieferteBibliotheken[name] ?? _hinzugefuegt[name];

  /// Meldet eine Bibliothek zur Laufzeit an, z.B. eine heruntergeladene Datei. Liefert null oder einen Fehler.
  String? bibliothekHinzufuegen(String name, String text) {
    if (mitgelieferteBibliotheken.containsKey(name)) return "Eine mitgelieferte Bibliothek heißt schon so: $name";
    final fehler = RpnApi()._ladeText(text); // prüfen, ohne diesen Rechner zu verändern
    if (fehler != null) return fehler;
    _hinzugefuegt[name] = text;
    return null;
  }

  /// Lädt eine Bibliothek in den Rechner. Liefert null oder den Fehler.
  String? ladeBibliothek(String name) {
    final text = bibliothek(name);
    if (text == null) return "Unbekannte Bibliothek: $name";
    final fehler = _ladeText(text);
    if (fehler == null && mitgelieferteBibliotheken.containsKey(name)) {
      _geladeneBibliotheksFunktionen.addAll(bibliotheksFunktionen(name)); // „Funktionen speichern“ lässt sie aus
    }
    return fehler;
  }

  /// Die Namen der Funktionen einer Bibliothek in der Reihenfolge der Datei.
  List<String> bibliotheksFunktionen(String name) {
    final text = bibliothek(name);
    if (text == null) return const [];
    final probe = RpnApi();
    return probe._ladeText(text) == null ? probe.calculator.eigeneFunktionen.keys.toList() : const [];
  }

  /// Die Versionsangabe einer geladenen Bibliothek oder null.
  Map<String, Object?>? bibliotheksVersion(String name) => calculator.versionen[name];

  /// Funktionen aus geladenen mitgelieferten Bibliotheken; „Funktionen speichern“ lässt sie aus.
  Set<String> get geladeneBibliotheksFunktionen => Set.unmodifiable(_geladeneBibliotheksFunktionen);

  /// Hinweise seit dem letzten Abruf, z.B. unbekannte Schlüssel in rpnjson; danach leer.
  List<String> hinweise() {
    final h = List.of(calculator.hinweise);
    calculator.hinweise.clear();
    return h;
  }

  /// Eine Bibliothek ist ein Block, der mit X ausgeführt wird: erst importieren, dann X (doc/api.md 9.1).
  String? _ladeText(String text) {
    final fehler = importieren(text, ersetzen: false);
    if (fehler != null) return fehler;
    final z = eingabe("X");
    return z.fehler?.text;
  }

  /// Die eigenen Funktionen als Bibliothek: ein Block mit Versionsangabe, Funktionen und eigener Hilfe.
  Export exportiereBibliothek(String name, {String version = "1.0.0", Set<String> ohne = const {}}) {
    final c = calculator;
    final funktionen = [for (final f in c.eigeneFunktionen.entries) if (!ohne.contains(f.key)) f];
    final hilfen = [for (final f in funktionen) ?c.eigeneHilfen[f.key]];
    final zeilen = [
      "{",
      "{${jsonFuerBlock({"version": {"name": name, "bibliothek": version, "rechner": rechnerVersion}})}}rpnjson",
      for (final f in funktionen) "{${f.value}}':${f.key}",
      if (hilfen.isNotEmpty) "{${jsonFuerBlock({"hilfe": hilfen})}}rpnjson",
      "}",
    ];
    return (text: zeilen.join("\n"), warnungen: const <String>[]);
  }

  /// Hilfe zu einem Zeichen, Namen oder Thema (doc/api.md Kapitel 8), oder null. Eingebaute Einträge gehen
  /// vor; für eigene Funktionen, Variablen, Konstanten und Tags wird ein Eintrag mit dem Inhalt erzeugt.
  /// Verändert den Rechner nicht.
  Hilfe? hilfe(String kennung) {
    final eingebaut = Hilfetexte.suche(kennung);
    if (eingebaut != null) return eingebaut;
    final eigen = calculator.eigeneHilfen[kennung]; // mit rpnjson abgelegt, z.B. aus einer Bibliothek
    if (eigen != null) return Hilfe.fromJson(eigen);
    return _eigeneHilfe(kennung);
  }

  /// Alle eingebauten Kennungen, für eine Übersicht.
  List<String> hilfeKennungen() => Hilfetexte.kennungen;

  Hilfe? _eigeneHilfe(String name) {
    final s = zustand().speicher.where((s) => s.name == name).firstOrNull;
    if (s == null) return null;
    if (s.art == SpeicherArt.funktion) {
      return Hilfe(name, "Eigene Funktion $name", [
        Verwendung(name, "ruft die Funktion auf"),
        Verwendung("'~$name", "entfernt die Funktion"),
      ], "Code: {${s.code}}\nSiehe [[#funktionen]].");
    }
    final inhalt = s.werte.map(zahl).join(" "); // Vektoren ohne [ ], die sind für Einheiten reserviert
    final tag = s.art == SpeicherArt.tag;
    final art = tag ? (s.schreibschutz ? "Tag mit Schreibschutz" : "Tag") : (s.schreibschutz ? "Konstante" : "Variable");
    return Hilfe(name, "$art $name", [
      Verwendung("'$name", "kopiert Elemente auf den Stack", argumente: "n:m (0:1)"),
      if (tag || !s.schreibschutz) Verwendung("'=$name", "schreibt Werte vom Stack hinein", argumente: "n:m:k (0:1:0)"),
      Verwendung("'~$name", tag ? "entfernt den Tag, die Werte bleiben auf dem Stack" : "entfernt ${s.schreibschutz ? "die Konstante" : "die Variable"}"),
    ], "Inhalt: $inhalt\nSiehe [[${tag ? "#tags" : "#variablen"}]].");
  }

  /// Der aktuelle Zustand mit höchstens [zeilen] Stack-Zeilen.
  Zustand zustand({int zeilen = 8}) {
    final stack = calculator.stack;
    int anzahl = (stack.tiefe < zeilen) ? stack.tiefe : zeilen;
    return Zustand(
      List.unmodifiable([for (int i = 0; i < anzahl; i++) StackZeile(i, stack[i], _tagsAn(stack.adr(i)))]),
      stack.tiefe,
      List.unmodifiable([
        for (var v in calculator.variablen.entries)
          Speicher(v.key, SpeicherArt.variable, List.unmodifiable(v.value), "", calculator.schreibschutz.contains(v.key)),
        for (var t in calculator.tags.entries)
          Speicher(t.key, SpeicherArt.tag, List.unmodifiable([for (int a in t.value) stack.wertAn(a)]), "",
                   calculator.schreibschutz.contains(t.key)),
        for (var f in calculator.eigeneFunktionen.entries) Speicher(f.key, SpeicherArt.funktion, const [], f.value),
      ]),
      List.unmodifiable(calculator.args.offen),
      calculator.angleMode,
      calculator.seed,
      _letzterFehler,
      parser.currentToken.codeTiefe > 0,
      List.unmodifiable(calculator.codeStack.inhalt),
      parser.offen,
      calculator.enter.vorgemerkt,
      _zeile,
      parser.zeileFertig,
    );
  }

  /// Der Zustand als RPN-Skript (ganze Session oder [nurFunktionen]), z.B. zum Speichern in einer Datei.
  /// Wo der Text gespeichert wird, entscheidet die Oberfläche.
  Export exportieren({bool nurFunktionen = false, Set<String> ohne = const {}}) =>
      SessionSkript().exportieren(calculator, nurFunktionen: nurFunktionen, ohne: ohne);

  /// Führt ein RPN-Skript Zeile für Zeile aus, z.B. eine gespeicherte Session oder eine Sammlung
  /// von Funktionen. Mit [ersetzen] wird der Rechner vorher zurückgesetzt.
  /// Liefert null oder den ersten Fehler mit der Nummer der Zeile.
  String? importieren(String text, {bool ersetzen = true}) {
    if (ersetzen) reset();
    List<String> zeilen = text.replaceAll("\r\n", "\n").split("\n");
    for (int i = 0; i < zeilen.length; i++) {
      Zustand z = eingabe(zeilen[i]);
      if (z.fehler != null) return "Zeile ${i + 1}: ${z.fehler!.text}";
    }
    return zustand().codeOffen ? "Ein Code-Block ist am Ende nicht abgeschlossen" : null;
  }

  /// Setzt Stack, Variablen, Tags, Einstellungen und einen offenen Code-Block zurück.
  void reset() {
    calculator.reset();
    parser.reset();
    _geladeneBibliotheksFunktionen.clear(); // die Session ersetzt den ganzen Rechner
    _neueZeile();
  }

  /// Text für die Rechner-Tests, im bisherigen Format "Stack: ...[a] [b]<tos".
  String testString({int zeilen = 4}) => calculator.stack.show(zeilen);

  /// Namen der Tags auf einer Adresse, bei Blöcken mit Elementnummer.
  List<String> _tagsAn(int adresse) => List.unmodifiable([
        for (var t in calculator.tags.entries)
          if (t.value.contains(adresse)) t.value.length == 1 ? t.key : "${t.key}[${t.value.indexOf(adresse)}]",
      ]);
}
