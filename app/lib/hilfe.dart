import 'package:rpncalc/helper.dart' show zahl;
import 'package:rpncalc/rpnapi.dart';

import 'tasten.dart';

/// Hilfe der App (doc/app.md Kapitel 5): eigene Einträge für die Bedienung, die Hilfe zu einer Taste aus
/// allen ihren Belegungen und die Kurztexte für die Tooltips. Die Sprache erklärt der Rechner (api.md Kapitel 8).
abstract final class AppHilfe {
  /// Einträge der App. Unter einer Kennung des Rechners (`#`, `~`, `|`, `'`) ergänzen sie dessen Eintrag.
  static const Map<String, Hilfe> eintraege = {
    "#": Hilfe("#", "Hilfe zur App", [
      Verwendung("Shift+MENÜ", "Hilfe-Modus an; dann eine Taste oder ein Element der Anzeige antippen"),
      Verwendung("MENÜ", "Einzelheiten zum gezeigten Eintrag, ohne Eintrag diese Startseite"),
      Verwendung("◄", "zurück zum vorigen Eintrag"),
      Verwendung("⌫", "beendet den Hilfe-Modus"),
    ], "Die Anzeigen: [[app:eingabe]], [[app:stack]], [[app:funktionen]], [[app:variablen]]. Bedienung: "
        "[[app:shift]], [[app:alpha]], [[app:tab]], [[app:cursorkreuz]], [[app:maximieren]], [[app:enter]], "
        "[[app:umbruch]], [[app:hilfe]]."),
    "~": Hilfe("~", "Die Taste ~", [Verwendung("~", "schreibt ~ und zeigt auf den Tasten, was mit ~ davor geschieht")],
        "Erlaubt ist ~ dort, wo die Taste rechts oben ein kleines ~ trägt. Zusammen mit | ergibt es ~|."),
    "|": Hilfe("|", "Die Taste |", [Verwendung("|", "schreibt | und zeigt auf den Tasten die Varianten mit |")],
        "Erlaubt ist | dort, wo die Taste rechts oben ein kleines | trägt. Zweimal | ist der Betrag."),
    "'": Hilfe("'", "Die Taste '", [Verwendung("'", "schreibt ' und zeigt die Variablen und Tags auf den Funktionstasten")],
        "Ein Tipp auf eine Variable schreibt ihren Namen. Siehe [[app:variablen]]."),
    "app:shift": Hilfe("app:shift", "Shift", [Verwendung("SHIFT", "die zweite Funktion, klein links oben auf der Taste")],
        "Gilt für einen Tastendruck. Shift+ALPHA schaltet auf Großbuchstaben, Shift+TAB geht rückwärts, Shift+MENÜ "
        "ist die Hilfe."),
    "app:alpha": Hilfe("app:alpha", "Alpha", [
      Verwendung("ALPHA", "Kleinbuchstaben, bis ALPHA oder ein Nicht-Buchstabe gedrückt wird"),
      Verwendung("Shift+ALPHA", "Großbuchstaben; ist Alpha schon an, wechselt SHIFT zwischen klein und groß"),
    ], "Das Alphabet beginnt bei ( ) und läuft zeilenweise durch den oberen Block, w x y z liegen auf ÷ × − +. "
        "ALPHA und ENTER ist ein Zeilenumbruch. Siehe [[app:enter]]."),
    "app:tab": Hilfe("app:tab", "Bereiche", [
      Verwendung("TAB", "wechselt den Bereich: Eingabe, Stack, Funktionen, Variablen"),
      Verwendung("Shift+TAB", "rückwärts"),
    ], "Der gewählte Bereich hat einen orangen Rahmen. Siehe [[app:cursorkreuz]], [[app:maximieren]]."),
    "app:menue": Hilfe("app:menue", "Menü", [
      Verwendung("MENÜ", "wählt die Domäne der Funktionstasten"),
      Verwendung("Shift+MENÜ", "Hilfe-Modus"),
    ], "Siehe [[app:hilfe]], [[app:funktionen]]."),
    "app:hilfe": Hilfe("app:hilfe", "Hilfe-Modus", [
      Verwendung("Shift+MENÜ", "Hilfe-Modus an, oben steht HILFE"),
      Verwendung("Taste", "zeigt die Hilfe zu allen Belegungen der Taste, eingegeben wird nichts"),
      Verwendung("Anzeige", "ein Tipp auf einen Wert, eine Variable oder eine Zeile zeigt deren Hilfe"),
      Verwendung("MENÜ", "Einzelheiten zum gezeigten Eintrag"),
      Verwendung("◄", "zurück"),
      Verwendung("⌫", "beendet den Hilfe-Modus"),
    ], "Ein Tipp auf den Hilfeschirm schließt ihn, der Hilfe-Modus bleibt. Startseite: [[#]]."),
    "app:cursorkreuz": Hilfe("app:cursorkreuz", "Cursorkreuz", [
      Verwendung("▲ ▼", "blättern in Eingabe (Verlauf) und Stack"),
      Verwendung("◄ ►", "schieben lange Zeilen und Werte seitlich, bei den Funktionen wechseln sie die Seite"),
    ], "Orange Pfeile am Rahmen zeigen, wohin sich etwas schieben lässt. Siehe [[app:tab]]."),
    "app:maximieren": Hilfe("app:maximieren", "Maximieren", [
      Verwendung("[ ]", "gibt Eingabe bzw. Stack die ganze Breite"),
      Verwendung("[|]", "teilt die Anzeige wieder"),
    ], "Bei maximiertem Stack zeigt die graue Zeile >: was man tippt, bei maximierter Eingabe steht der Tos in "
        "der Statuszeile. Siehe [[app:stack]], [[app:eingabe]]."),
    "app:enter": Hilfe("app:enter", "ENTER", [
      Verwendung("ENTER", "Leerzeichen: trennt und legt eine Kopie des Tos an"),
      Verwendung("Shift+ENTER", "Trenner _, trennt nur"),
      Verwendung("ALPHA, ENTER", "Zeilenumbruch, z.B. in Code"),
    ], "Siehe [[ ]], [[_]], [[app:umbruch]]."),
    "app:loeschen": Hilfe("app:loeschen", "Löschen", [
      Verwendung("⌫", "nimmt das zuletzt eingegebene Zeichen zurück"),
      Verwendung("Shift+⌫", "C: löscht den Stack"),
    ], "Ausgeführte Token bleiben, dafür braucht es später das Undo. Siehe [[C]]."),
    "app:umbruch": Hilfe("app:umbruch", "Zeilen der Eingabe", [],
        "Ab 80 % der Zeilenbreite bricht die Zeile nach der nächsten Operation um, nach ENTER ab 90 %, im Code beim "
        "nächsten Leerzeichen. Die Zeile wandert dann in den Verlauf. Siehe [[app:eingabe]]."),
    "app:eingabe": Hilfe("app:eingabe", "Anzeige: Eingabe", [
      Verwendung("▲ ▼", "blättern im Verlauf"),
      Verwendung("◄ ►", "schieben lange Zeilen seitlich"),
    ], "Oben die aktuelle Zeile, darunter die älteren. Ein Fehler ist rot markiert. Ein vorgemerktes Enter steht "
        "als ENTER↑ auf dem Rahmen. Weiter: [[app:stack]]."),
    "app:stack": Hilfe("app:stack", "Anzeige: Stack", [
      Verwendung("▲ ▼", "blättern zu tieferen Werten"),
      Verwendung("◄ ►", "schieben lange Werte seitlich"),
    ], "Oben der Tos, hellorange hinterlegt. Ein offenes Token steht grau mit >: darüber. Siehe [[#stack]]. "
        "Weiter: [[app:funktionen]]."),
    "app:funktionen": Hilfe("app:funktionen", "Anzeige: Funktionen", [
      Verwendung("◄ ►", "wechseln die Seite der Funktionstasten: Domäne, eigene Funktionen"),
    ], "Die Seite listet die eigenen Funktionen mit ihrem Code, die Domäne wählt MENÜ. Siehe [[#funktionen]]. "
        "Weiter: [[app:variablen]]."),
    "app:variablen": Hilfe("app:variablen", "Anzeige: Variablen", [
      Verwendung("Funktionstasten", "zeigen die Variablen und Tags, ein Tipp liest sie"),
    ], "Die Seite listet Variablen, Konstanten und Tags mit ihrem Inhalt. Siehe [[#variablen]], [[#tags]]. "
        "Weiter: [[app:eingabe]]."),
  };

  /// Einträge zu einer Kennung: zuerst der App, dann des Rechners (doc/api.md 8.4).
  static List<Hilfe> nachschlagen(RpnApi api, String kennung) {
    final eigene = eintraege[kennung];
    final vomRechner = kennung.startsWith("app:") ? null : api.hilfe(kennung);
    return [?eigene, ?vomRechner];
  }

  /// Titel eines Verweisziels.
  static String titel(RpnApi api, String kennung) => eintraege[kennung]?.titel ?? api.hilfe(kennung)?.titel ?? kennung;

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

  /// Kurztexte aller Belegungen einer Taste für den Tooltip, je eine Zeile.
  static List<String> kurztexte(RpnApi api, Taste t) {
    final kennung = _bedienung(t);
    if (kennung != null && kennung.startsWith("app:")) {
      return [for (final v in eintraege[kennung]!.verwendungen) _zeile(v)];
    }
    final zeilen = <String>[];
    for (final tok in token(t)) {
      final h = api.hilfe(tok);
      if (h == null) continue;
      final v = h.verwendungen.where((v) => v.schreibweise == tok || v.schreibweise.endsWith("}$tok")).firstOrNull;
      zeilen.add(v == null ? "${tok.trim().isEmpty ? "␣" : tok}  ${h.titel}" : _zeile(v));
    }
    return zeilen;
  }

  static String _zeile(Verwendung v) => [v.schreibweise, if (v.stack.isNotEmpty) v.stack, v.kurz].join("  ");

  /// Hilfe zu einem Wert auf dem Stack: der volle Wert und seine Tags, dazu der Stack im Rechner.
  static List<Hilfe> stackWert(RpnApi api, StackZeile s) => [
        Hilfe("app:wert", "Stack-Wert an Position ${s.position}", [
          Verwendung(zahl(s.wert), s.position == 0 ? "der Tos" : "Position ${s.position}, 0 ist der Tos"),
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
