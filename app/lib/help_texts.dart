/// Aufgabe: die Hilfe, die die App selbst beisteuert. [AppHilfe] liefert die Einträge zur Bedienung
/// (`app:…`, Ergänzungen zu `#`, `~`, `|`, `'`), schlägt eine Kennung bei App und Rechner nach, stellt die Hilfe zu
/// einer Taste aus all ihren Belegungen zusammen und baut die Tooltips als Tabellen aus [TippZeile] (Schreibweise,
/// Stack, Beschreibung) mit ihrer [ZeilenArt]. Dazu die Seite „Bibliotheken“ und die Hilfe zu Stack-Werten und
/// Zeilen im Verlauf.
///
/// Abgrenzung: Alle Texte (Einträge, Tabellen der Tooltips, kurze Beschriftungen) stehen in help_texts_de.dart,
/// hier steht nur, wie sie zusammengesetzt werden. Die Sprache erklärt der Rechner (Hilfe über `RpnApi`);
/// gezeichnet werden Tooltips in tooltip.dart, der Hilfeschirm in display/help_screen.dart. Den Ablauf des
/// Hilfe-Modus (Seitenfolge, Verweise) steuert model/help_mode.dart.
///
/// Siehe auch: doc/app.md Kapitel 5, doc/api.md Kapitel 8, keys.dart, tool/hilfe.dart (Prüfseite).
library;

import 'package:rpncalc/rpnapi.dart';

import 'help_texts_de.dart' as de;
import 'keys.dart';

/// Art einer Zeile im Tooltip: bestimmt das Zeichen und die Farbe vorn (doc/app.md 5.1).
enum ZeilenArt { normal, shift, alpha, pc }

/// Eine Zeile im Tooltip: eine Funktion mit Schreibweise, Wirkung auf den Stack und Beschreibung.
typedef TippZeile = ({ZeilenArt art, String schreibweise, String stack, String text});

/// Hilfe der App (doc/app.md Kapitel 5): eigene Einträge für die Bedienung, die Hilfe zu einer Taste aus
/// allen ihren Belegungen und die Kurztexte für die Tooltips. Die Sprache erklärt der Rechner (doc/api.md Kapitel 8).
abstract final class AppHilfe {
  /// Einträge der App (help_texts_de.dart). Unter einer Kennung des Rechners (`#`, `~`, `|`, `'`) ergänzen sie
  /// dessen Eintrag.
  static const Map<String, Hilfe> eintraege = de.eintraege;

  /// Die Seite „Bibliotheken“: je Bibliothek ihr Satz aus `beschreibung` und ein Verweis auf ihre Übersicht.
  static Hilfe bibliothekenSeite(RpnApi api) {
    final namen = [for (final b in api.bibliotheken()) b.name];
    return Hilfe("app:bibliotheken", de.bibliotheken, [
      for (final n in namen) Verwendung(n, api.bibliotheksInfo(n)?.beschreibung ?? ""),
    ], de.bibliothekenText(namen));
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
      kennung == "app:bibliotheken" ? de.bibliotheken : eintraege[kennung]?.titel ?? api.hilfe(kennung)?.titel ?? kennung;

  /// Der Eintrag der App zu einer Bedientaste, sonst null.
  static String? _bedienung(Taste t) => switch (t.aktion) {
        Aktion.shift => "app:shift",
        Aktion.alpha => "app:alpha",
        Aktion.tab => "app:tab",
        Aktion.menue => "app:menue",
        Aktion.loeschen => "app:loeschen",
        Aktion.enter => "app:enter",
        Aktion.maximieren => "app:maximieren",
        Aktion.zeileLoeschen => "app:cl",
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

  /// Tooltip einer Bibliothek, z.B. im Menü: wofür sie gedacht ist, darunter Version und Zahl der Funktionen;
  /// die Funktionen selbst stehen in den Tooltips ihrer Tasten (doc/app.md 5.1).
  static List<List<TippZeile>> tippBibliothek(RpnApi api, String name) {
    final info = api.bibliotheksInfo(name);
    if (info == null) return const [];
    return [
      [(art: ZeilenArt.normal, schreibweise: name, stack: "", text: info.beschreibung.isEmpty ? de.bibliothek : info.beschreibung)],
      [(art: ZeilenArt.pc, schreibweise: de.version(info.version), stack: "", text: de.funktionen(info.funktionen))],
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
    final praefix = [for (final (s, text) in de.praefix[t.aktion] ?? const <(String, String)>[]) zeile(s, text)];
    final grund = <TippZeile>[], namen = <TippZeile>[], shift = <TippZeile>[], alpha = <TippZeile>[];
    final argumente = <ZeilenArt, Verwendung>{};
    final namenArgumente = <Verwendung>[]; // je Form mit ' und Argumenten ein eigener Bereich

    final kennung = _bedienung(t);
    if (kennung != null && kennung.startsWith("app:")) {
      // Bedientasten: die Verwendungen des App-Eintrags, nach Umschaltung einsortiert
      for (final v in eintraege[kennung]!.verwendungen) {
        if (v.schreibweise.startsWith(de.shiftPlus)) {
          shift.add(zeile(v.schreibweise.substring(de.shiftPlus.length), v.kurz, art: ZeilenArt.shift));
        } else if (v.schreibweise.startsWith(de.alphaKomma)) {
          alpha.add(zeile("${de.alpha} ${v.schreibweise.substring(de.alphaKomma.length)}", v.kurz, art: ZeilenArt.alpha));
        } else {
          grund.add(zeile(v.schreibweise, v.kurz));
        }
      }
    } else if (t.reserviert || t.text.isEmpty) {  
      final text = de.reserviert[t.text];
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
        if (tok == "#zahlen") return [zeile(t.text, de.ziffer)];
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
      alpha.insert(0, zeile(de.alpha, klein ? "$b / ${b.toUpperCase()}" : b, art: ZeilenArt.alpha));
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

    final pc = de.pcTastatur[t.text];
    return [
      praefix,
      grund,
      argumentBereich(argumente[ZeilenArt.normal]),
      namen,
      for (final v in namenArgumente) argumentBereich(v),
      shift,
      argumentBereich(argumente[ZeilenArt.shift]),
      alpha,
      if (de.praefixHinweis[t.aktion] case final hinweis?) [zeile(de.hinweis, hinweis, art: ZeilenArt.pc)],
      if (pc is String) [zeile(de.pcTastaturTitel, pc, art: ZeilenArt.pc)],
      // die erste Zeile ist die Überschrift (blass), die PC-Tasten darunter dunkel wie die übrigen Zeilen
      if (pc is List<(String, String)>)
        [for (final (i, (taste, gegenstueck)) in pc.indexed) zeile(taste, gegenstueck, art: i == 0 ? ZeilenArt.pc : ZeilenArt.normal)],
    ]
        .where((z) => z.isNotEmpty)
        .toList();
  }

  /// Hilfe zu einem Wert auf dem Stack: der volle Wert und seine Tags, dazu der Stack im Rechner.
  static List<Hilfe> stackWert(RpnApi api, StackZeile s) => [de.stackWert(s), ?api.hilfe("#stack")];

  /// Hilfe zu einer Zeile im Verlauf: die ganze Zeile, auch wenn sie in der Anzeige gekürzt ist.
  static List<Hilfe> zeile(String text) => [de.verlaufszeile(text)];
}
