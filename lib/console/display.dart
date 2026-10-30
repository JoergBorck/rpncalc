import '../helper.dart';
import '../rpnapi.dart';


/// Die Bereiche der zeichenweisen Eingabe, zwischen denen Tab wechselt.
enum Bereich { stack, verlauf, variablen, funktionen }

/// Was die zeichenweise Eingabe gerade zeigt: gewählter Bereich und wie weit darin geblättert bzw. der
/// Inhalt seitlich geschoben ist (Tab und Pfeiltasten, doc/api.md Kapitel 7).
class Ansicht {
  Bereich bereich = Bereich.stack;
  int stackVersatz = 0;       // erste angezeigte Stack-Position
  int verlaufVersatz = 0;     // so viele Zeilen ist der Verlauf zurückgeblättert
  int variablenVersatz = 0;   // erste angezeigte Variable bzw. Funktion
  int funktionenVersatz = 0;
  /// So viele Zeichen ist der Inhalt einer Variablen bzw. Funktion nach links geschoben, je Name (Kopf).
  final Map<String, int> geschoben = {};
  bool funktionen = false;    // die zweite Spalte der Übersicht zeigt Funktionen statt Variablen und Tags

  /// So viele Zeilen zeigen Stack und zweite Spalte der Übersicht.
  static const int zeilen = 8;
}

/// Darstellung eines Zustands als Text für die Konsole.
///
/// Die Anzeige rechnet nichts selbst, sie formatiert nur den Zustand aus der RpnApi.
class Anzeige {

  /// Vor der Eingabe, damit klar ist, dass man im Rechner tippt. "RPN" in Orange wie der Cursor.
  static const String prompt = "RPN> ";
  static String farbigerPrompt([bool farbe = true]) => farbe ? "\x1B[38;5;208mRPN\x1B[0m> " : prompt;

  /// Der Tos, hellorange hinterlegt.
  static String _tos(String s, bool farbe) => farbe ? "\x1B[48;5;223;30m$s\x1B[0m" : s;

  static final RegExp _ansi = RegExp(r"\x1B\[[0-9;?]*[A-Za-z]");

  /// Länge ohne die unsichtbaren ANSI-Steuerfolgen (Farben).
  static int sichtbar(String s) => s.replaceAll(_ansi, "").length;

  /// Kürzt [s] auf [breite] sichtbare Zeichen, ohne eine Farb-Steuerfolge zu zerschneiden.
  static String kuerzen(String s, int breite) {
    if (sichtbar(s) <= breite) return s;
    StringBuffer out = StringBuffer();
    int n = 0, i = 0;
    while (i < s.length && n < breite) {
      final m = _ansi.matchAsPrefix(s, i);
      if (m != null) {
        out.write(m[0]);
        i = m.end;
      } else {
        out.write(s[i++]);
        n++;
      }
    }
    return "$out\x1B[0m"; // eine abgeschnittene Farbe nicht in die nächste Zeile tragen
  }

  /// Kompakte Zeile: Modi, Variablen und Tags, dann der Stack mit dem Tos rechts.
  /// Sinnvoll für wenige Stack-Elemente und wenige Variablen. Mit [farbe] = false ohne ANSI-Farben.
  /// Ab [versatz] werden die tieferen Werte gezeigt, rechts steht dann "…" für die oberen.
  static String kompakt(Zustand z, {int zeilen = 4, bool farbe = true, int versatz = 0}) {
    String stack = [
      for (StackZeile s in z.stack.skip(versatz).take(zeilen).toList().reversed)
        "${s.position == 0 ? _tos("[${zahl(s.wert)}]", farbe) : "[${zahl(s.wert)}]"}${s.tags.join(",")}"
    ].join(" ");
    if (z.tiefe > versatz + zeilen) stack = "… $stack";
    if (versatz > 0) stack = "$stack …";
    if (z.tiefe == 0) stack = "[ ]"; // leerer Stack
    final offen = versatz == 0 ? _offenesToken(z) : null;
    return [
      _modi(z).join(" "),
      if (z.speicher.isNotEmpty) [for (Speicher s in z.speicher) _speicher(s)].join("  "),
      if (z.argumente.isNotEmpty) "args ${_argumente(z).join(" ")}",
      if (z.codeStack.isNotEmpty) "Code ${z.codeStack.length}",
      "$stack<tos${offen == null ? "" : " ${_grau(">:$offen", farbe)}"}",
    ].join(" │ ");
  }

  /// Das offene Token für die Zeile über dem Tos (doc/api.md Kapitel 7), gekürzt auf [breite] mit dem Ende
  /// sichtbar; null, wenn keins offen ist oder ein Fehler die Zeile markiert.
  static String? _offenesToken(Zustand z, {int breite = 16}) {
    if (z.offen.isEmpty || z.fehler != null || z.zeileFertig) return null;
    final t = z.offen.replaceAll("\n", "↵");
    return t.length > breite ? "…${t.substring(t.length - breite + 1)}" : t;
  }

  /// Die graue Zeile `>:` über Position 0, ausgerichtet wie die Stackzeilen.
  static String _offeneZeile(String token, bool farbe) => _grau(" >: ${token.padLeft(16)}", farbe);

  static String _grau(String s, bool farbe) => farbe ? "\x1B[2m$s\x1B[0m" : s;

  /// Übersicht in Spalten: Stack (Tos oben) │ Variablen und Tags │ Einstellungen, Tiefe und Argumente.
  /// Mit einer [ansicht] zeigen Stack und zweite Spalte einen Ausschnitt mit höchstens Ansicht.zeilen Zeilen;
  /// die zweite Spalte zeigt dann entweder Variablen und Tags oder Funktionen, den Inhalt vollständig und
  /// seitlich verschoben. Dafür muss der Zustand genug Stack-Zeilen enthalten.
  static String uebersicht(Zustand z, {bool farbe = true, Ansicht? ansicht}) {
    if (ansicht != null) return _uebersicht(z, farbe, ansicht);
    String wert(StackZeile s) {
      String w = zahl(s.wert);
      return "${" " * (16 - w.length).clamp(0, 16)}${s.position == 0 ? _tos(w, farbe) : w}";
    }
    // ein offenes Token steht grau über dem Tos und zählt zu den 8 Zeilen
    final offen = _offenesToken(z);
    final gezeigt = offen != null && z.stack.length >= Ansicht.zeilen ? z.stack.take(Ansicht.zeilen - 1).toList() : z.stack;
    List<String> stack = [
      if (offen != null) _offeneZeile(offen, farbe),
      for (StackZeile s in gezeigt) "${s.position.toString().padLeft(2)}: ${wert(s)}  ${s.tags.join(",")}",
      if (z.tiefe > gezeigt.length) " … ${z.tiefe - gezeigt.length} weitere",
      if (z.tiefe == 0 && offen == null) " (leer)",
    ];
    List<String> speicher = [for (Speicher s in z.speicher) _speicher(s)];
    List<String> rechts = [
      ..._modi(z),
      "Tiefe ${z.tiefe}",
      if (z.argumente.isNotEmpty) ...["Args ${z.argumente.length}", ..._argumente(z)],
      if (z.codeStack.isNotEmpty) ...["Code ${z.codeStack.length}", for (String c in z.codeStack) _kurz("{$c}")],
    ];
    return _spalten([stack, speicher, rechts], [32, 24, 12]);
  }

  static String _uebersicht(Zustand z, bool farbe, Ansicht a) {
    String wert(StackZeile s) {
      String w = zahl(s.wert);
      return "${" " * (16 - w.length).clamp(0, 16)}${s.position == 0 ? _tos(w, farbe) : w}";
    }
    // höchstens so weit, dass der unterste Wert in der letzten Zeile steht
    final stackVersatz = a.stackVersatz.clamp(0, (z.tiefe - Ansicht.zeilen).clamp(0, z.tiefe));
    // ein offenes Token steht grau über dem Tos, nur wenn nicht zurückgeblättert ist, und zählt zu den 8 Zeilen
    final offen = stackVersatz == 0 ? _offenesToken(z) : null;
    final sichtbar = z.stack.skip(stackVersatz).take(Ansicht.zeilen - (offen == null ? 0 : 1)).toList();
    final unten = z.tiefe - stackVersatz - sichtbar.length;
    List<String> stack = [
      if (offen != null) _offeneZeile(offen, farbe),
      for (StackZeile s in sichtbar) "${s.position.toString().padLeft(2)}: ${wert(s)}  ${s.tags.join(",")}",
      if (unten > 0) " … $unten weitere",
      if (z.tiefe == 0 && offen == null) " (leer)",
    ];
    const int breite = _speicherBreite;
    final liste = _liste(z, a);
    final versatz = _listenVersatz(liste, a);
    // der Name bleibt stehen, nur der Inhalt (Code bzw. Werte) wird seitlich geschoben
    String geschoben((String, String) teile) {
      final (kopf, inhalt) = teile;
      final platz = breite - kopf.length;
      if (platz < 2) return "${kopf.substring(0, breite - 1)}…";
      final eigener = (a.geschoben[kopf] ?? 0).clamp(0, _maxGeschoben(kopf, inhalt));
      String t = inhalt.substring(eigener);
      if (eigener > 0) t = "…${t.substring(1)}";
      return "$kopf${t.length > platz ? "${t.substring(0, platz - 1)}…" : t}";
    }
    final mehr = liste.length - versatz - Ansicht.zeilen;
    List<String> speicher = [
      if (liste.isEmpty) a.funktionen ? "(keine Funktionen)" : "(keine Variablen)",
      for (final teile in liste.skip(versatz).take(Ansicht.zeilen)) geschoben(teile),
      if (mehr > 0) "… $mehr weitere",
    ];
    List<String> rechts = [
      ..._modi(z),
      "Tiefe ${z.tiefe}",
      if (z.argumente.isNotEmpty) ...["Args ${z.argumente.length}", ..._argumente(z)],
      if (z.codeStack.isNotEmpty) ...["Code ${z.codeStack.length}", for (String c in z.codeStack) _kurz("{$c}")],
    ];
    return _spalten([stack, speicher, rechts], [32, breite, 12]);
  }

  /// Breite der zweiten Spalte (Variablen bzw. Funktionen) in der Übersicht.
  static const int _speicherBreite = 24;

  /// Variablen und Tags bzw. Funktionen als (Name, Inhalt), je nach [Ansicht.funktionen].
  static List<(String, String)> _liste(Zustand z, Ansicht a) => [
        for (Speicher s in z.speicher)
          if ((s.art == SpeicherArt.funktion) == a.funktionen) _teile(s),
      ];

  /// Erste angezeigte Zeile der Liste, höchstens so weit, dass die letzte Zeile gefüllt ist.
  static int _listenVersatz(List<(String, String)> liste, Ansicht a) =>
      (a.funktionen ? a.funktionenVersatz : a.variablenVersatz)
          .clamp(0, (liste.length - Ansicht.zeilen).clamp(0, liste.length));

  /// So weit lässt sich ein Inhalt seitlich schieben: bis sein Ende in der Spalte steht.
  /// 0, wenn er ganz hineinpasst.
  static int _maxGeschoben(String kopf, String inhalt) =>
      (inhalt.length - (_speicherBreite - kopf.length)).clamp(0, inhalt.length);

  /// Schiebt jede sichtbare Zeile der zweiten Spalte um [schritt] Zeichen (positiv nach links),
  /// jede für sich zwischen ihrem Anfang und ihrem Ende. true, wenn sich etwas bewegt hat.
  static bool schieben(Zustand z, Ansicht a, int schritt) {
    final liste = _liste(z, a);
    bool bewegt = false;
    for (final (kopf, inhalt) in liste.skip(_listenVersatz(liste, a)).take(Ansicht.zeilen)) {
      final max = _maxGeschoben(kopf, inhalt);
      final alt = (a.geschoben[kopf] ?? 0).clamp(0, max);
      final neu = (alt + schritt).clamp(0, max);
      a.geschoben[kopf] = neu;
      if (neu != alt) bewegt = true;
    }
    return bewegt;
  }

  static List<String> _modi(Zustand z) => [z.winkel.name, if (z.seed != null) "seed ${z.seed}", if (z.codeOffen) "{ Code offen"];

  /// Variablen als "m = 10", Tags mit "|" davor wie in der Syntax, Vektoren durch Leerzeichen getrennt,
  /// Konstanten mit "!!" und Tags mit Schreibschutz mit "||" davor,
  /// eigene Funktionen mit ihrem (gekürzten) Code.
  static String _speicher(Speicher s) {
    if (s.art == SpeicherArt.funktion) return _kurz("${s.name} {${s.code}}");
    final (kopf, inhalt) = _teile(s);
    return "$kopf$inhalt";
  }

  /// Name und Inhalt getrennt, ungekürzt: ("m = ", "10") bzw. ("f ", "{1+}").
  static (String, String) _teile(Speicher s) {
    if (s.art == SpeicherArt.funktion) return ("${s.name} ", "{${s.code}}".replaceAll("\n", "↵"));
    String werte = s.werte.map(zahl).join(" "); // Vektoren ohne [ ], die sind für Einheiten reserviert
    String praefix = s.art == SpeicherArt.tag ? (s.schreibschutz ? "||" : "|") : (s.schreibschutz ? "!!" : "");
    return ("$praefix${s.name} = ", werte);
  }

  /// Werte für die Zwischenablage, passend zu einem deutschen Excel: Dezimalkomma, getrennt mit ";".
  /// Bei mehreren Werten steht der tiefste zuerst und der Tos zuletzt, wie in der Anzeige.
  static String fuerExcel(Iterable<num> werte) => [for (num w in werte) zahl(w).replaceAll(".", ",")].join(";");

  /// Alle Zahlen aus einem Text (z.B. aus Excel kopiert) in der Schreibweise des Rechners, siehe doc/api.md 7:
  /// Dezimalkomma oder -punkt, Exponent mit e oder E; alles andere wird übersprungen.
  /// Ein Minus ist nur ein Vorzeichen, wenn davor keine Ziffer und kein Buchstabe steht.
  /// Der Fehlerwert #DIV/0! von Excel liefert keine 0.
  static List<String> ausExcel(String text) => [
        for (final m in _zahlImText.allMatches(text.replaceAll("#DIV/0!", "")))
          "${m[1] == "-" ? "~" : ""}${m[2]!.replaceAll(",", ".")}"
              "${m[4] == null ? "" : "ê${m[3] == "-" ? "~" : ""}${int.parse(m[4]!)}"}",
      ];

  static final RegExp _zahlImText =
      RegExp(r"(?:(?<![\p{L}\d])([+-]))?(\d+(?:[.,]\d+)?)(?:[eE]([+-]?)(\d+))?", unicode: true);

  /// Die Eingabezeile bei der Zeicheneingabe (doc/api.md 5.7), höchstens [breite] Zeichen breit.
  ///
  /// Ohne Fehler: das Ende der Zeile, das offene Token unterstrichen, ein vorgemerktes Enter als ENTER↑.
  /// Mit Fehler: einige Zeichen davor, das fehlerhafte Token rot, die nicht ausgeführten Tasten danach blass,
  /// darunter ^ und der Fehlertext. Mit [farbe] = false ohne ANSI-Farben, z.B. für Tests.
  /// Mit [cursor] steht am Ende der Eingabe ein orangefarbener Block; [zusatz] (z.B. ein wartendes "\")
  /// steht davor. Mit [leer] wird nur die leere Eingabezeile gezeigt (gerade wurde Enter gedrückt).
  static List<String> eingabe(Zustand z, {int breite = 79, bool farbe = true, bool cursor = false,
                                          String zusatz = "", bool leer = false}) {
    String rot(String s) => farbe && s.isNotEmpty ? "\x1B[31;7m$s\x1B[0m" : s;
    String blass(String s) => farbe && s.isNotEmpty ? "\x1B[2m$s\x1B[0m" : s;
    String unter(String s) => farbe && s.isNotEmpty ? "\x1B[4m$s\x1B[0m" : s;
    String cur = !cursor ? "" : farbe ? "\x1B[48;5;208m \x1B[0m" : "█";
    String zeile = leer ? "" : z.zeile.replaceAll("\n", "↵");
    final String start = farbigerPrompt(farbe);
    int platz = breite - prompt.length - zusatz.length - (cursor ? 1 : 0);
    Fehler? f = leer ? null : z.fehler;
    if (f == null || f.start < 0 || f.start > zeile.length) {
      String enter = z.enterVorgemerkt ? " ENTER↑" : "";
      int offen = !leer && z.offen.length <= zeile.length ? z.offen.length : 0;
      String fertig = zeile.substring(0, zeile.length - offen);
      int frei = platz - enter.length - offen;
      if (fertig.length > frei) fertig = "…${fertig.substring(fertig.length - frei + 1)}";
      return ["$start$fertig${unter(zeile.substring(zeile.length - offen))}$zusatz$cur${blass(enter)}"];
    }
    int ende = f.start + f.token.length;
    if (ende > zeile.length) ende = zeile.length;
    String davor = zeile.substring(0, f.start);
    String token = zeile.substring(f.start, ende);
    String danach = zeile.substring(ende);
    int maxDavor = platz ~/ 2;
    if (davor.length > maxDavor) davor = "…${davor.substring(davor.length - maxDavor + 1)}";
    int frei = platz - davor.length - token.length;
    if (danach.length > frei) danach = frei > 1 ? "${danach.substring(0, frei - 1)}…" : "";
    return [
      "$start$davor${rot(token)}${blass(danach)}$zusatz$cur",
      "${" " * (prompt.length + davor.length)}^ ${f.text}",
    ];
  }

  /// Eine abgeschlossene Zeile im Verlauf: ab Zeichen [von] so viel, wie in [breite] passt, abgeschnittene
  /// Teile als "…". Ein Fehler ist rot, darunter die Meldung; "^" zeigt auf den Fehler, "←" bzw. "→",
  /// wenn er links bzw. rechts außerhalb liegt. Ohne [von] wie in der Eingabe: um den Fehler bzw. das Ende.
  static List<String> verlauf(Zustand z, {int breite = 79, bool farbe = true, int? von}) {
    String rot(String s) => farbe && s.isNotEmpty ? "\x1B[31;7m$s\x1B[0m" : s;
    String blass(String s) => farbe && s.isNotEmpty ? "\x1B[2m$s\x1B[0m" : s;
    final zeile = z.zeile.replaceAll("\n", "↵");
    final platz = breite - prompt.length;
    final f = _verlaufFehler(z);
    final anfang = (von ?? verlaufStart(z, breite)).clamp(0, verlaufMax(z, breite));
    final ende = (anfang + platz).clamp(0, zeile.length);
    final zeichen = zeile.substring(anfang, ende).split("");
    if (anfang > 0) zeichen[0] = "…";
    if (ende < zeile.length) zeichen[zeichen.length - 1] = "…";
    String teil(int a, int b) => zeichen.sublist((a - anfang).clamp(0, zeichen.length), (b - anfang).clamp(0, zeichen.length)).join();
    if (f == null) return ["${farbigerPrompt(farbe)}${teil(anfang, ende)}"];
    final fEnde = (f.start + f.token.length).clamp(f.start, zeile.length);
    final pos = f.start - anfang;
    return [
      "${farbigerPrompt(farbe)}${teil(anfang, f.start)}${rot(teil(f.start, fEnde))}${blass(teil(fEnde, ende))}",
      pos < 0 ? "${" " * prompt.length}← ${f.text}"
          : pos >= platz ? "${" " * prompt.length}→ ${f.text}"
          : "${" " * (prompt.length + pos)}^ ${f.text}",
    ];
  }

  /// So weit lässt sich eine Verlaufszeile seitlich schieben: bis ihr Ende sichtbar ist.
  static int verlaufMax(Zustand z, int breite) {
    final laenge = z.zeile.length;
    return (laenge - (breite - prompt.length)).clamp(0, laenge);
  }

  /// Der Anfang einer Verlaufszeile, bevor sie geschoben wird: der Fehler etwa in der Mitte, sonst das Ende.
  static int verlaufStart(Zustand z, int breite) {
    final f = _verlaufFehler(z);
    final max = verlaufMax(z, breite);
    return f == null ? max : (f.start - (breite - prompt.length) ~/ 2).clamp(0, max);
  }

  static Fehler? _verlaufFehler(Zustand z) {
    final f = z.fehler;
    return f != null && f.start >= 0 && f.start <= z.zeile.length ? f : null;
  }

  /// Kürzt langen Code für die Anzeige, Zeilenumbrüche werden als ↵ dargestellt.
  static String _kurz(String text, [int max = 20]) {
    text = text.replaceAll("\n", "↵");
    return (text.length <= max) ? text : "${text.substring(0, max - 2)}…}";
  }

  /// Argumente ab 1 nummeriert, passend zum Argument-Zugriff '1 bis '9 in Code-Blöcken.
  static List<String> _argumente(Zustand z) => [for (int i = 0; i < z.argumente.length; i++) "${i + 1}:${zahl(z.argumente[i])}"];

  /// Wie padRight, zählt aber nur die sichtbaren Zeichen.
  static String _auffuellen(String s, int breite) => s + " " * (breite - sichtbar(s)).clamp(0, breite);

  /// Setzt mehrere Spalten zeilenweise nebeneinander.
  static String _spalten(List<List<String>> spalten, List<int> breiten) {
    int zeilen = spalten.map((s) => s.length).reduce((a, b) => a > b ? a : b);
    return [
      for (int i = 0; i < zeilen; i++)
        [
          for (int k = 0; k < spalten.length; k++)
            _auffuellen(i < spalten[k].length ? spalten[k][i] : "", k < spalten.length - 1 ? breiten[k] : 0)
        ].join(" │ ").trimRight()
    ].join("\n");
  }
}
