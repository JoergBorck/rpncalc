/// Aufgabe: alle deutschen Texte der Hilfe der App: die Einträge zur Bedienung (`app:…`, Ergänzungen zu `#`,
/// `~`, `|`, `'`), die Tabellen für die Tooltips (Präfixe, PC-Tastatur, reservierte Tasten), die kurzen
/// Beschriftungen in Tooltips und die erzeugten Einträge zu Stack-Werten und Zeilen im Verlauf. Für eine weitere
/// Sprache kommt eine Datei mit demselben Aufbau daneben (z.B. help_texts_en.dart).
///
/// Abgrenzung: Wie die Texte zu Hilfeseiten und Tooltips zusammengesetzt werden, steht in help_texts.dart; nur
/// darüber werden sie gelesen. Die Texte der Sprache selbst liefert der Rechner (`RpnApi.hilfe`).
///
/// Siehe auch: doc/app.md Kapitel 5, help_texts.dart.
library;

import 'package:rpncalc/rpnapi.dart';

import 'keys.dart';

/// Einträge der App, gelesen über `AppHilfe.eintraege`. Unter einer Kennung des Rechners (`#`, `~`, `|`, `'`)
/// ergänzen sie dessen Eintrag.
const Map<String, Hilfe> eintraege = {
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
    Verwendung("Wischen", "senkrecht schiebt zeilenweise, mit Schwung läuft es nach; am PC auch das Mausrad"),
    Verwendung("◄ ►", "schieben lange Zeilen seitlich"),
    Verwendung("Rechtsklick", "Zeile, ab hier oder Verlauf kopieren, Text einfügen, Hilfe; am Handy langes Drücken"),
    Verwendung("Strg+V", "fügt Text ein, als wäre er getippt"),
  ], "Oben die aktuelle Zeile, darunter die älteren. Ein Fehler ist rot markiert. Ein vorgemerktes Enter steht "
      "als ENTER↑ auf dem Rahmen. Weiter: [[app:stack]]."),
  "app:cl": Hilfe("app:cl", "Eingabezeile löschen (CL) und alles löschen (AC)", [
    Verwendung("CL", "leert die aktuelle Eingabezeile, der Stack bleibt; ist sie leer, löscht es die Zeile darunter"),
    Verwendung("Shift+AC", "löscht Eingabe, Verlauf und Stack mit allen Tags; Variablen und Funktionen bleiben"),
    Verwendung("Esc", "am PC wie CL"),
  ], "Was in der Eingabezeile schon ausgeführt ist, bleibt wirksam: CL verwirft nur das offene Token und nach einem "
      "Fehler die Tasten danach. Variablen und eigene Funktionen löscht man mit '~name. Siehe [[app:eingabe]], "
      "[[app:loeschen]]."),
  "app:stack": Hilfe("app:stack", "Anzeige: Stack", [
    Verwendung("▲ ▼", "blättern zu tieferen Werten"),
    Verwendung("Wischen", "senkrecht schiebt zeilenweise, mit Schwung läuft es nach; am PC auch das Mausrad"),
    Verwendung("◄ ►", "schieben lange Werte seitlich"),
    Verwendung("Rechtsklick", "Wert, ab hier oder Stack kopieren, Werte einfügen, Hilfe; am Handy langes Drücken"),
    Verwendung("Strg+C", "kopiert x, mit Shift den Stack; Strg+V fügt die Zahlen aus der Zwischenablage ein"),
  ], "Die Werte; x ist hinterlegt, darunter y, z, t, ≡₄ … Ein offenes Token steht grau mit >: darüber. "
      "Siehe [[#stack]]. Weiter: [[app:funktionen]]."),
  "app:funktionen": Hilfe("app:funktionen", "Anzeige: Funktionen", [
    Verwendung("▲ ▼", "wechseln die Seite der Funktionstasten: Domäne, eigene Funktionen; wie das Mausrad"),
    Verwendung("◄ ►", "ebenso, im Kreis"),
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

/// Was die Präfix-Tasten als Präfix bewirken: Schreibweise (Beispiele) und Beschreibung.
const Map<Aktion, List<(String, String)>> praefix = {
  Aktion.tilde: [("~sin ~² ~/ …", "als Präfix: Umkehrung der nächsten Funktion")],
  Aktion.strich: [("|/ |% |: …", "als Präfix: Variante der nächsten Funktion, oft mit mehreren Ergebnissen")],
  Aktion.apostroph: [("'name …", "vor einem Namen: Variable, Konstante, Tag oder Funktion")],
};

/// Hinweis am Ende des Tooltips der Präfix-Tasten: woran man sieht, wo der Präfix wirkt.
const Map<Aktion, String> praefixHinweis = {
  Aktion.tilde: "ein kleines ~ oben rechts an den Tasten, auf die ~ wirkt",
  Aktion.strich: "ein kleines | oben rechts an den Tasten, auf die | wirkt",
};

/// So tippt man die Zeichen einer Taste an der PC-Tastatur (deutsche Belegung), wenn sie dort nicht direkt
/// liegen; letzter Bereich im Tooltip, wie die Kürzel neben Menüeinträgen (doc/app.md 5.1).
const Map<String, Object> pcTastatur = {
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
const Map<String, String> reserviert = {
  "( )": "reserviert für Vektoren, Matrizen und Tabellen",
  "[ ]": "reserviert für Einheiten",
  "": "noch frei",
};

/// Titel der Seite „Bibliotheken“.
const bibliotheken = "Bibliotheken";

/// Text der Seite „Bibliotheken“ mit Verweisen auf die Übersichten der Bibliotheken [namen].
String bibliothekenText(List<String> namen) =>
    "Übersichten: ${[for (final n in namen) "[[#$n]]"].join(", ")}. Lesen geht auch, bevor eine Bibliothek "
    "geladen ist; laden mit MENÜ, dann die Bibliothek wählen. Zurück zur Startseite: [[#]].";

/// Tooltip einer Bibliothek ohne `beschreibung`.
const bibliothek = "Bibliothek";
String version(String v) => "Version $v";
String funktionen(int n) => "$n Funktionen";

/// Beschriftungen vorn in Zeilen des Tooltips.
const alpha = "Alpha", hinweis = "Hinweis", pcTastaturTitel = "PC-Tastatur";

/// Text zu den Ziffern 0–9 im Tooltip.
const ziffer = "Ziffer einer Zahl";

/// So beginnen Verwendungen in [eintraege], die zu Shift bzw. Alpha gehören; der Tooltip sortiert sie danach ein.
const shiftPlus = "Shift+", alphaKomma = "ALPHA, ";

/// Hilfe zu einem Wert auf dem Stack: der volle Wert und seine Tags.
Hilfe stackWert(StackZeile s) => Hilfe("app:wert", "Stack-Wert an Position ${s.position}", [
      Verwendung(zahl(s.wert), s.position == 0 ? "x, der oberste Wert" : "${positionsName(s.position)} (Position ${s.position})"),
      for (final t in s.tags) Verwendung("'$t", "Tag auf dieser Zelle"),
    ], "Siehe [[app:stack]].");

/// Hilfe zu einer Zeile im Verlauf: die ganze Zeile, auch wenn sie in der Anzeige gekürzt ist.
Hilfe verlaufszeile(String text) =>
    Hilfe("app:zeile", "Zeile im Verlauf", [Verwendung(text.replaceAll("\n", "↵"), "so wurde sie eingegeben")],
        "Siehe [[app:eingabe]], [[app:umbruch]].");
