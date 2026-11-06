import 'package:rpncalc/helper.dart' show positionsName, zahl;
import 'package:rpncalc/rpnapi.dart';

import 'tasten.dart';

/// Art einer Zeile im Tooltip: bestimmt das Zeichen und die Farbe vorn (doc/app.md 5.1).
enum ZeilenArt { normal, shift, alpha, pc }

/// Eine Zeile im Tooltip: eine Funktion mit Schreibweise, Wirkung auf den Stack und Beschreibung.
typedef TippZeile = ({ZeilenArt art, String schreibweise, String stack, String text});

/// Hilfe der App (doc/app.md Kapitel 5): eigene Einträge für die Bedienung, die Hilfe zu einer Taste aus
/// allen ihren Belegungen und die Kurztexte für die Tooltips. Die Sprache erklärt der Rechner (api.md Kapitel 8).
abstract final class AppHilfe {
  /// Einträge der App. Unter einer Kennung des Rechners (`#`, `~`, `|`, `'`) ergänzen sie dessen Eintrag.
  static const Map<String, Hilfe> eintraege = {
    // die Startseite: Hilfe zur Hilfe, Hilfe zur App, dann die des Rechners (nachschlagen)
    "#": Hilfe("#", "Hilfe zur Hilfe", [
      Verwendung("Shift+MENÜ", "Hilfe an; dann eine Taste oder ein Element der Anzeige antippen"),
      Verwendung("Tipp in die Anzeige", "zeigt deren Hilfe"),
      Verwendung("LESEN (ALPHA)", "Lese-Modus: ganzer Text, ▲ ▼ blättern, TAB und ENTER folgen den Verweisen"),
      Verwendung("◄", "zurück zum vorigen Eintrag"),
      Verwendung("BEENDEN (MENÜ)", "beendet die Hilfe"),
    ]),
    "app:start": Hilfe("app:start", "Hilfe zur App", [],
        "Oben die Anzeige mit den Seiten Rechnen, Variablen und Tags, Funktionen; darunter das Tastenfeld. Unten die "
        "Anzeigen, die Bedienung und die Bibliotheken.", [
      "app:eingabe", "app:stack", "app:funktionen", "app:variablen", "app:shift", "app:alpha", "app:tab",
      "app:cursorkreuz", "app:maximieren", "app:enter", "app:umbruch", "app:hilfe", "app:bibliotheken",
    ]),
    "~": Hilfe("~", "Die Taste ~", [Verwendung("~", "schreibt ~ und zeigt auf den Tasten, was mit ~ davor geschieht")],
        "Erlaubt ist ~ dort, wo die Taste rechts oben ein kleines ~ trägt. Zusammen mit | ergibt es ~|."),
    "|": Hilfe("|", "Die Taste |", [Verwendung("|", "schreibt | und zeigt auf den Tasten die Varianten mit |")],
        "Erlaubt ist | dort, wo die Taste rechts oben ein kleines | trägt. Zweimal | ist der Betrag."),
    "'": Hilfe("'", "Die Taste '", [Verwendung("'", "schreibt ' und zeigt die Variablen und Tags auf den Funktionstasten")],
        "Ein Tipp auf eine Variable schreibt ihren Namen. Siehe [[app:variablen]]."),
    "app:shift": Hilfe("app:shift", "Shift", [Verwendung("SHIFT", "die zweite Belegung der nächsten Taste (orange, links oben)")],
        "Gilt für einen Tastendruck. Shift+ALPHA schaltet auf Großbuchstaben, Shift+TAB geht rückwärts, Shift+MENÜ "
        "ist die Hilfe."),
    "app:alpha": Hilfe("app:alpha", "Alpha", [
      Verwendung("ALPHA", "Kleinbuchstaben, bis ALPHA oder eine Ziffer eingegeben wird"),
      Verwendung("Shift+ALPHA", "Großbuchstaben; bei Alpha wechselt Shift zwischen klein und groß"),
    ], "Das Alphabet beginnt bei ( ) und läuft zeilenweise durch den oberen Block, w x y z liegen auf ÷ × − +. "
        "ALPHA und ENTER ist ein Zeilenumbruch. Siehe [[app:enter]]."),
    "app:tab": Hilfe("app:tab", "Bereiche", [
      Verwendung("TAB", "nächster Bereich: Eingabe → Stack → Funktionen → Variablen"),
      Verwendung("Shift+TAB", "voriger Bereich"),
    ], "Der gewählte Bereich hat einen orangen Rahmen. Siehe [[app:cursorkreuz]], [[app:maximieren]]."),
    "app:menue": Hilfe("app:menue", "Menü", [
      Verwendung("MENÜ", "wählt die Domäne der Funktionstasten"),
      Verwendung("Shift+MENÜ", "Hilfe an; im Hilfe-Modus heißt die Taste BEENDEN"),
    ], "Siehe [[app:hilfe]], [[app:funktionen]]."),
    "app:hilfe": Hilfe("app:hilfe", "Hilfe-Modus", [
      Verwendung("Shift+MENÜ", "Hilfe an, im Inspekt-Modus; oben steht HILFE"),
      Verwendung("Taste", "Inspekt-Modus: zeigt die Hilfe zu allen Belegungen der Taste, eingegeben wird nichts"),
      Verwendung("Anzeige", "Inspekt-Modus: ein Tipp auf einen Wert, eine Variable oder eine Zeile zeigt deren Hilfe"),
      Verwendung("LESEN (ALPHA)", "Lese-Modus an und aus: ganzer Text, Tasten lösen keine Hilfe aus"),
      Verwendung("▲ ▼", "Lese-Modus: blättern"),
      Verwendung("TAB, ENTER", "Lese-Modus: Verweis wählen, ihm folgen"),
      Verwendung("ANFANG (MENÜ)", "Lese-Modus: die Startseite"),
      Verwendung("◄", "zurück"),
      Verwendung("BEENDEN", "beendet die Hilfe: MENÜ im Inspekt-Modus, ⌫ im Lese-Modus"),
    ], "Die Hilfe startet mit der Seite des letzten Tooltips, wenn er höchstens 10 s her ist, sonst mit der "
        "Startseite. Ein Tipp auf den Hilfeschirm schließt ihn, der Hilfe-Modus bleibt. Startseite: [[#]]."),
    "app:cursorkreuz": Hilfe("app:cursorkreuz", "Cursorkreuz", [
      Verwendung("▲ ▼", "blättern in Eingabe (Verlauf) und Stack"),
      Verwendung("◄ ►", "schieben lange Zeilen und Werte seitlich, bei den Funktionen wechseln sie die Seite"),
    ], "Orange Pfeile am Rahmen zeigen, wohin sich etwas schieben lässt. Siehe [[app:tab]]."),
    "app:maximieren": Hilfe("app:maximieren", "Maximieren", [
      Verwendung("□", "gibt Eingabe bzw. Stack die ganze Breite"),
      Verwendung("◫", "teilt die Anzeige wieder"),
    ], "Bei maximiertem Stack zeigt die graue Zeile >: was man tippt, bei maximierter Eingabe steht x in der "
        "Statuszeile. Siehe [[app:stack]], [[app:eingabe]]."),
    "app:enter": Hilfe("app:enter", "ENTER", [
      Verwendung("ENTER", "Leerzeichen: trennt und kopiert x; jedes weitere ENTER verdoppelt x", stack: "x → x x"),
      Verwendung("Shift+ENTER", "Trenner _: trennt ohne Kopie, z.B. für bessere Lesbarkeit"),
      Verwendung("ALPHA, ⏎", "im Alpha-Modus: Zeilenumbruch, z.B. in Code; weitere ⏎ geben leere Zeilen"), // ⏎ wie auf der Taste
    ], "Siehe [[ ]], [[_]], [[app:umbruch]]."),
    "app:loeschen": Hilfe("app:loeschen", "Löschen", [
      Verwendung("⌫", "nimmt das zuletzt eingegebene Zeichen zurück"),
      Verwendung("Shift+C", "löscht den Stack"),
      Verwendung("Shift+'C", "löscht Stack und Tags"),
    ], "Ausgeführte Token bleiben, dafür braucht es später das Undo. Siehe [[C]]."),
    "app:umbruch": Hilfe("app:umbruch", "Zeilen der Eingabe", [],
        "Ab 80 % der Zeilenbreite bricht die Zeile nach der nächsten Operation um, nach ENTER ab 90 %, im Code beim "
        "nächsten Leerzeichen. Die Zeile wandert dann in den Verlauf. Siehe [[app:eingabe]]."),
    "app:eingabe": Hilfe("app:eingabe", "Anzeige: Eingabe", [
      Verwendung("▲ ▼", "blättern im Verlauf"),
      Verwendung("◄ ►", "schieben lange Zeilen seitlich"),
      Verwendung("Rechtsklick", "Zeile, ab hier oder Verlauf kopieren, Text einfügen, Hilfe; am Handy langes Drücken"),
      Verwendung("Strg+V", "fügt Text ein, als wäre er getippt"),
    ], "Oben die aktuelle Zeile, darunter die älteren. Ein Fehler ist rot markiert. Ein vorgemerktes Enter steht "
        "als ENTER↑ auf dem Rahmen. Weiter: [[app:stack]]."),
    "app:stack": Hilfe("app:stack", "Anzeige: Stack", [
      Verwendung("▲ ▼", "blättern zu tieferen Werten"),
      Verwendung("◄ ►", "schieben lange Werte seitlich"),
      Verwendung("Rechtsklick", "Wert, ab hier oder Stack kopieren, Werte einfügen, Hilfe; am Handy langes Drücken"),
      Verwendung("Strg+C", "kopiert x, mit Shift den Stack; Strg+V fügt die Zahlen aus der Zwischenablage ein"),
    ], "Die Werte; x ist hinterlegt, darunter y, z, t, ≡₄ … Ein offenes Token steht grau mit >: darüber. "
        "Siehe [[#stack]]. Weiter: [[app:funktionen]]."),
    "app:funktionen": Hilfe("app:funktionen", "Anzeige: Funktionen", [
      Verwendung("◄ ►", "wechseln die Seite der Funktionstasten: Domäne, eigene Funktionen"),
      Verwendung("Wischen", "über die Funktionstasten blättert ebenso, am PC auch das Mausrad"),
    ], "Die Seite listet die eigenen Funktionen und je geladener Bibliothek deren Funktionen, jeweils mit ihrem Code; "
        "blättern die Tasten auf eine Bibliothek, springt sie zu deren Abschnitt. Die Domäne wählt MENÜ. "
        "Siehe [[#funktionen]]. "
        "Weiter: [[app:variablen]]."),
    "app:variablen": Hilfe("app:variablen", "Anzeige: Variablen", [
      Verwendung("Funktionstasten", "zeigen die Variablen und Tags, ein Tipp liest sie"),
    ], "Die Seite listet Variablen, Konstanten und Tags mit ihrem Inhalt. Siehe [[#variablen]], [[#tags]]. "
        "Weiter: [[app:eingabe]]."),
  };

  /// Die Seite „Bibliotheken“: je Bibliothek ihr Satz aus `beschreibung` und ein Verweis auf ihre Übersicht.
  static Hilfe bibliothekenSeite(RpnApi api) {
    final namen = [for (final b in api.bibliotheken()) b.name];
    return Hilfe("app:bibliotheken", "Bibliotheken", [
      for (final n in namen) Verwendung(n, api.bibliotheksInfo(n)?.beschreibung ?? ""),
    ], "Übersichten: ${[for (final n in namen) "[[#$n]]"].join(", ")}. Lesen geht auch, bevor eine Bibliothek "
        "geladen ist; laden mit MENÜ, dann die Bibliothek wählen. Zurück zur Startseite: [[#]].");
  }

  /// Einträge zu einer Kennung: zuerst der App, dann des Rechners (doc/api.md 8.4).
  static List<Hilfe> nachschlagen(RpnApi api, String kennung) {
    if (kennung == "app:bibliotheken") return [bibliothekenSeite(api)];
    final eigene = eintraege[kennung];
    final vomRechner = kennung.startsWith("app:") ? null : api.hilfe(kennung);
    return [?eigene, if (kennung == "#") eintraege["app:start"]!, ?vomRechner];
  }

  /// Titel eines Verweisziels.
  static String titel(RpnApi api, String kennung) =>
      kennung == "app:bibliotheken" ? "Bibliotheken" : eintraege[kennung]?.titel ?? api.hilfe(kennung)?.titel ?? kennung;

  /// Der Eintrag der App zu einer Bedientaste, sonst null.
  static String? _bedienung(Taste t) => switch (t.aktion) {
        Aktion.shift => "app:shift",
        Aktion.alpha => "app:alpha",
        Aktion.tab => "app:tab",
        Aktion.menue => "app:menue",
        Aktion.loeschen => "app:loeschen",
        Aktion.enter => "app:enter",
        Aktion.maximieren => "app:maximieren",
        Aktion.tilde => "~",
        Aktion.strich => "|",
        Aktion.apostroph => "'",
        _ => null,
      };

  /// Die Token, die eine Taste schreiben kann: normal, Shift, mit ~, mit |, mit ~|.
  static List<String> token(Taste t) {
    if (t.reserviert || t.text.isEmpty) return const [];
    switch (t.aktion) {
      case Aktion.enter:
        return const [" ", "_"];
      case Aktion.tilde || Aktion.strich || Aktion.apostroph:
        return [t.text];
      case Aktion.schreiben || Aktion.funktion:
        if (RegExp(r"^[0-9]$").hasMatch(t.text)) return const ["#zahlen"];
        return [
          t.eingabe,
          if (t.shift != null) t.shiftEingabe!,
          if (t.tilde != null) "~${t.tildeEingabe ?? t.eingabe}",
          if (t.shiftTilde != null) t.shiftTildeEingabe ?? "~${t.shiftEingabe}",
          if (t.strich != null) "|${t.eingabe}",
          if (t.beide != null) "~|${t.eingabe}",
        ];
      default:
        return const [];
    }
  }

  /// Die Hilfe zu einer Taste: der Eintrag der App (bei Bedientasten), dann jeder Eintrag des Rechners zu
  /// einem ihrer Token, jeder nur einmal (x² und √x stehen beide bei ²).
  static List<Hilfe> fuerTaste(RpnApi api, Taste t) {
    final kennung = _bedienung(t);
    final eigene = kennung == null ? null : eintraege[kennung];
    final kern = <String, Hilfe>{};
    for (final tok in [if (kennung != null && !kennung.startsWith("app:")) kennung, ...token(t)]) {
      final h = api.hilfe(tok);
      if (h != null) kern.putIfAbsent(h.kennung, () => h);
    }
    return [?eigene, ...kern.values];
  }

  /// Was die Präfix-Tasten als Präfix bewirken: Schreibweise (Beispiele) und Beschreibung.
  static const Map<Aktion, List<(String, String)>> _praefix = {
    Aktion.tilde: [("~sin ~² ~/ …", "als Präfix: Umkehrung der nächsten Funktion")],
    Aktion.strich: [("|/ |% |: …", "als Präfix: Variante der nächsten Funktion, oft mit mehreren Ergebnissen")],
    Aktion.apostroph: [("'name …", "vor einem Namen: Variable, Konstante, Tag oder Funktion")],
  };

  /// Hinweis am Ende des Tooltips der Präfix-Tasten: woran man sieht, wo der Präfix wirkt.
  static const Map<Aktion, String> _praefixHinweis = {
    Aktion.tilde: "ein kleines ~ oben rechts an den Tasten, auf die ~ wirkt",
    Aktion.strich: "ein kleines | oben rechts an den Tasten, auf die | wirkt",
  };

  /// So tippt man die Zeichen einer Taste an der PC-Tastatur (deutsche Belegung), wenn sie dort nicht direkt
  /// liegen; letzter Bereich im Tooltip, wie die Kürzel neben Menüeinträgen (doc/app.md 5.1).
  static const Map<String, Object> _pcTastatur = {
    "ALPHA": "Buchstaben direkt tippen",
    "TAB": "Tab, Shift+Tab",
    "MENÜ": "F1 Hilfe-Modus, Esc beendet ihn",
    "⌫": "Backspace",
    "{ }": "AltGr+7, AltGr+0",
    "yˣ": "^, danach Leertaste",
    "x²": "AltGr+2",
    "x³": "AltGr+3",
    "°": "Shift+^",
    // drei Tasten der PC-Tastatur für zwei Funktionen der App: je Zeile PC-Taste und Gegenstück
    "ENTER": [
      ("PC-Tastatur", "rpncalc"),
      ("Leertaste", "ENTER"),
      ("Return", "ALPHA ⏎"),
      ("Enter auf dem Ziffernblock", "ENTER, ALPHA ⏎"),
    ],
    "÷": "/ ; ≤ als ~>",
    "×": "* ; oder als ~&",
    "−": "- ; ≥ als ~<",
    "+": "+ ; ≠ als ~=",
    "|": "AltGr+<",
    "~": "AltGr++",
    "ê": "^, dann e",
  };

  /// Tasten ohne eigene Funktion: wofür sie reserviert sind; die leere Taste ist noch frei.
  static const Map<String, String> _reserviert = {
    "( )": "reserviert für Vektoren, Matrizen und Tabellen",
    "[ ]": "reserviert für Einheiten",
    "": "noch frei",
  };

  /// Tooltip einer Bibliothek, z.B. im Menü: wofür sie gedacht ist, darunter Version und Zahl der Funktionen;
  /// die Funktionen selbst stehen in den Tooltips ihrer Tasten (doc/app.md 5.1).
  static List<List<TippZeile>> tippBibliothek(RpnApi api, String name) {
    final info = api.bibliotheksInfo(name);
    if (info == null) return const [];
    return [
      [(art: ZeilenArt.normal, schreibweise: name, stack: "", text: info.beschreibung.isEmpty ? "Bibliothek" : info.beschreibung)],
      [(art: ZeilenArt.pc, schreibweise: "Version ${info.version}", stack: "", text: "${info.funktionen} Funktionen")],
    ];
  }

  /// Tooltip für ein Element der Anzeige aus einem Eintrag der App: was es ist (der erste Satz des Textes, ohne
  /// Verweise), seine Verwendungen, dazu [zusatz].
  static List<List<TippZeile>> tippEintrag(String kennung, String name, {List<(String, String)> zusatz = const []}) => [
        [
          (
            art: ZeilenArt.normal,
            schreibweise: name,
            stack: "",
            text: eintraege[kennung]!.textMit((k) => titel(RpnApi(), k)).split(RegExp(r"(?<=[.…]) ")).first,
          ),
        ],
        [
          for (final v in eintraege[kennung]!.verwendungen)
            (art: ZeilenArt.normal, schreibweise: v.schreibweise, stack: v.stack, text: v.kurz),
        ],
        [for (final (s, text) in zusatz) (art: ZeilenArt.normal, schreibweise: s, stack: "", text: text)],
      ].where((b) => b.isNotEmpty).toList();

  /// Die Zeilen des Tooltips einer Taste, gegliedert in Bereiche (doc/app.md 5.1): Präfix, Grundfunktion mit
  /// ihren Varianten ~ | ~|, Shift mit seinen Varianten, Alpha. Leere Bereiche fallen weg.
  static List<List<TippZeile>> tippBereiche(RpnApi api, Taste t) {
    TippZeile zeile(String s, String text, {String stack = "", ZeilenArt art = ZeilenArt.normal}) =>
        (art: art, schreibweise: s, stack: stack, text: text);
    final praefix = [for (final (s, text) in _praefix[t.aktion] ?? const <(String, String)>[]) zeile(s, text)];
    final grund = <TippZeile>[], namen = <TippZeile>[], shift = <TippZeile>[], alpha = <TippZeile>[];
    final argumente = <ZeilenArt, Verwendung>{};
    final namenArgumente = <Verwendung>[]; // je Form mit ' und Argumenten ein eigener Bereich

    final kennung = _bedienung(t);
    if (kennung != null && kennung.startsWith("app:")) {
      // Bedientasten: die Verwendungen des App-Eintrags, nach Umschaltung einsortiert
      for (final v in eintraege[kennung]!.verwendungen) {
        if (v.schreibweise.startsWith("Shift+")) {
          shift.add(zeile(v.schreibweise.substring(6), v.kurz, art: ZeilenArt.shift));
        } else if (v.schreibweise.startsWith("ALPHA, ")) {
          alpha.add(zeile("Alpha ${v.schreibweise.substring(7)}", v.kurz, art: ZeilenArt.alpha));
        } else {
          grund.add(zeile(v.schreibweise, v.kurz));
        }
      }
    } else if (t.reserviert || t.text.isEmpty) {  
      final text = _reserviert[t.text];
      if (text != null) grund.add(zeile(t.text.isEmpty ? "–" : t.text, text));
    } else if (t.aktion == Aktion.apostroph) {
      // die Übersicht aller Formen mit ': Variablen, dann Tags, Funktionen und Stackbefehle
      for (final v in api.hilfe("'")?.verwendungen ?? const <Verwendung>[]) {
        final weitere = RegExp(r"^'(\||:|[A-Z])").hasMatch(v.schreibweise);
        (weitere ? namen : grund).add(zeile(v.schreibweise, v.kurz, stack: v.stack));
      }
    } else {
      // Zeichen und Funktionen: je Token die passende Verwendung aus der Hilfe des Rechners
      TippZeile ausVerwendung(Verwendung v, ZeilenArt art, {bool mitArgumenten = true}) {
        if (mitArgumenten && v.argumentListe.isNotEmpty) argumente[art] ??= v; // je Bereich die erste mit Argumenten
        return zeile(v.schreibweise, v.kurz, stack: v.stack, art: art);
      }
      List<TippZeile> ausRechner(String tok, {ZeilenArt art = ZeilenArt.normal}) {
        if (tok == "#zahlen") return [zeile(t.text, "Ziffer einer Zahl")];
        final h = api.hilfe(tok);
        if (h == null) return const [];
        final v = h.verwendungen.where((v) => v.schreibweise == tok || v.schreibweise.endsWith("}$tok")).firstOrNull;
        if (v != null) return [ausVerwendung(v, art)];
        // keine Verwendung mit genau dieser Schreibweise (ê): dann alle, sie sind Beispiele für die Taste
        if (h.kennung == tok && h.verwendungen.isNotEmpty) return [for (final v in h.verwendungen) ausVerwendung(v, art)];
        return [zeile(tok.trim().isEmpty ? "␣" : tok, h.titel, art: art)];
      }

      final shiftToken = t.shift == null ? null : t.shiftEingabe;
      for (final tok in token(t)) {
        // eine Variante mit ~ gehört zu Shift, wenn sie die Shift-Funktion umkehrt (rnd: ~seed, S: ~R)
        final zuShift = tok == shiftToken || (shiftToken != null && tok == "~$shiftToken") || tok == t.shiftTildeEingabe;
        final zeilen = ausRechner(tok, art: zuShift ? ZeilenArt.shift : ZeilenArt.normal);
        // ≤ ≥ ≠ tippt man mit ~ vor Shift: das ~ gehört in die Zeile, sonst sähe ⇧ ≠ aus wie ⇧ =
        if (tok == t.shiftTildeEingabe) {
          for (var i = 0; i < zeilen.length; i++) {
            zeilen[i] = (art: zeilen[i].art, schreibweise: "~${zeilen[i].schreibweise}", stack: zeilen[i].stack, text: zeilen[i].text);
          }
        }
        (zuShift ? shift : grund).addAll(zeilen);
      }
      if (t.aktion == Aktion.strich) grund.addAll(ausRechner("||")); // zweimal | ist der Betrag
      // nach ' wirkt das Zeichen auf Namen ('!name, '+name, ':name …): eigener Bereich, Argumente je Form;
      // bei der Shift-Belegung ebenso ('=name auf Shift+)
      for (final (zeichen, art) in [(t.eingabe, ZeilenArt.normal), if (shiftToken != null) (shiftToken, ZeilenArt.shift)]) {
        if (!const ["!", "~", "|", "=", "+", "-", "*", "/", ":"].contains(zeichen)) continue;
        for (final v in api.hilfe(zeichen)?.verwendungen ?? const <Verwendung>[]) {
          if (!v.schreibweise.startsWith("'")) continue;
          (art == ZeilenArt.shift ? shift : namen).add(ausVerwendung(v, art, mitArgumenten: false));
          // dieselben Argumente wie eine Form davor ('!!name wie '!name) nur einmal
          if (v.argumentListe.isNotEmpty && !namenArgumente.any((w) => w.argumente == v.argumente)) namenArgumente.add(v);
        }
      }
      if (t.aktion == Aktion.tilde) {
        // ~ in Zahlen: negative Zahl und negativer Exponent (~3, 1ê~2)
        for (final v in api.hilfe("~")?.verwendungen ?? const <Verwendung>[]) {
          if (RegExp(r"^~\d|ê~").hasMatch(v.schreibweise)) grund.add(ausVerwendung(v, ZeilenArt.normal));
        }
      }
    }

    final b = t.buchstabe;
    if (b != null && b.isNotEmpty) {
      final klein = RegExp(r"^[a-z]$").hasMatch(b);
      alpha.insert(0, zeile("Alpha", klein ? "$b / ${b.toUpperCase()}" : b, art: ZeilenArt.alpha));
    }
    // Argumente: je Argument eine Zeile mit den schon erklärten als Kästen, zuletzt das ganze Beispiel
    List<TippZeile> argumentBereich(Verwendung? v) {
      if (v == null) return const [];
      final l = v.argumentListe;
      final einzeln = l.length == 1 && v.beispiel.isNotEmpty; // ein Argument: nur die Beispielzeile
      return [
        if (!einzeln)
          for (var i = 0; i < l.length; i++)
            zeile([for (var k = 0; k < i; k++) "▢", l[i].beispiel, v.schreibweise].join(":"), l[i].wirkung, stack: l[i].stack),
        if (v.beispiel.isNotEmpty) zeile(v.beispielEingabe, v.beispiel, stack: v.beispielStack),
      ];
    }

    final pc = _pcTastatur[t.text];
    return [
      praefix,
      grund,
      argumentBereich(argumente[ZeilenArt.normal]),
      namen,
      for (final v in namenArgumente) argumentBereich(v),
      shift,
      argumentBereich(argumente[ZeilenArt.shift]),
      alpha,
      if (_praefixHinweis[t.aktion] case final hinweis?) [zeile("Hinweis", hinweis, art: ZeilenArt.pc)],
      if (pc is String) [zeile("PC-Tastatur", pc, art: ZeilenArt.pc)],
      // die erste Zeile ist die Überschrift (blass), die PC-Tasten darunter dunkel wie die übrigen Zeilen
      if (pc is List<(String, String)>)
        [for (final (i, (taste, gegenstueck)) in pc.indexed) zeile(taste, gegenstueck, art: i == 0 ? ZeilenArt.pc : ZeilenArt.normal)],
    ]
        .where((z) => z.isNotEmpty)
        .toList();
  }

  /// Hilfe zu einem Wert auf dem Stack: der volle Wert und seine Tags, dazu der Stack im Rechner.
  static List<Hilfe> stackWert(RpnApi api, StackZeile s) => [
        Hilfe("app:wert", "Stack-Wert an Position ${s.position}", [
          Verwendung(zahl(s.wert), s.position == 0 ? "x, der oberste Wert" : "${positionsName(s.position)} (Position ${s.position})"),
          for (final t in s.tags) Verwendung("'$t", "Tag auf dieser Zelle"),
        ], "Siehe [[app:stack]]."),
        ?api.hilfe("#stack"),
      ];

  /// Hilfe zu einer Zeile im Verlauf: die ganze Zeile, auch wenn sie in der Anzeige gekürzt ist.
  static List<Hilfe> zeile(String text) => [
        Hilfe("app:zeile", "Zeile im Verlauf", [Verwendung(text.replaceAll("\n", "↵"), "so wurde sie eingegeben")],
            "Siehe [[app:eingabe]], [[app:umbruch]]."),
      ];
}
