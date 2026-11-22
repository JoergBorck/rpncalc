/// Aufgabe: die Zeilen der Tastentabelle (DG-7) aus der Belegung: je Taste, was sie normal, nach den Präfixen, mit
/// Shift, im Alpha-Modus und am PC zeigt bzw. tut; dazu Hauptmenü und Modi aus dem Menübaum. Reines Dart, damit
/// tool/keytable.dart daraus doc/keys.md schreibt und die App dieselben Zeilen als Hilfeseite „Alle Tasten“ zeigt.
///
/// Abgrenzung: Geplantes (doc/keys_planned.txt) und Markdown kennt nur das Werkzeug; gezeichnet wird die Hilfeseite
/// in display/key_table_view.dart.
///
/// Siehe auch: doc/keys.md, process/requirements/DG-7.md, keys.dart, menu_tree.dart.
library;

import 'keys.dart';
import 'menu_tree.dart';

/// Die Spalten der Tabellen, in der Reihenfolge der Tabelle; die Namen wie in doc/keys_planned.txt.
const tastenSpalten = ["normal", "tilde", "strich", "beide", "shift", "shiftTilde", "shiftStrich", "shiftBeide", "alpha",
    "symbol", "pc"];

/// Die Köpfe der Spalten, wie sie über der Tabelle stehen.
const tastenKoepfe = ["normal", "~", "|", "~|", "⇧", "⇧~", "⇧|", "⇧~|", "Alpha", "Symbole", "PC"];

/// Eine Zeile: die Taste und ihre Zellen je Spalte (fehlend oder leer: nicht belegt).
typedef Tastenzeile = ({String taste, Map<String, String> zellen});

/// Steht in der Zeile der Funktionstasten in der Spalte normal: Verweis auf die Domänen.
const domaenenVerweis = "→ Domänen";

/// Der obere Block: R1, dann R2–R5; die Funktionstasten als eine Zeile an der Stelle von F1.
List<Tastenzeile> get obererBlock => [for (final t in _r1) zeileVon(t), _kreuz, _ecke,
    for (final r in obereTasten) for (final t in r)
      if (t.funktion == null) zeileVon(t) else if (t.funktion == 0) _funktionstasten];

/// Der untere Block, R6–R9.
List<Tastenzeile> get untererBlock => [for (final r in untereTasten) for (final t in r) zeileVon(t)];

/// Die eingebauten Domänen der Funktionstasten, je Domäne ihre Tasten.
Map<String, List<Tastenzeile>> get domaenenTabellen => {
      for (final d in domaenen.entries) d.key: [for (final t in d.value) if (t != null) zeileVon(t)],
    };

/// Das Hauptmenü: Kopf und je Bereich Taste, Bereich, PC.
({List<String> kopf, List<List<String>> zeilen}) get menueHauptTabelle => (
      kopf: ["Taste", "Bereich", "PC"],
      zeilen: [for (final p in menueHauptpunkte) [p.taste, p.name, p.taste]],
    );

/// Der Bereich Modi: je Funktionstaste Modus (Platzhalter mit dem Eintrag, mit dem er kommt), Werte, PC.
({List<String> kopf, List<List<String>> zeilen}) get menueModiTabelle => (
      kopf: ["Taste", "Modus", "Werte", "PC"],
      zeilen: [
        for (final (i, f) in modusFelder.indexed)
          [
            "F${i + 1}",
            f == null ? "–" : "${f.name}${f.aktiv ? "" : " (kommt mit ${f.spaeter})"}",
            f == null ? "" : f.werte.map((w) => w.replaceAll("\u202F", " ")).join(" · "),
            funktionsBuchstaben[i],
          ],
      ],
    );

/// Die Tasten von R1 in der Tabelle (das Cursorkreuz und seine Ecken folgen als eigene Zeilen).
const _r1 = [tasteShift, tasteAlpha, tasteTab, tasteMenue];
final _kreuz = (taste: "◄ ▲ ► ▼", zellen: {"normal": "Cursorkreuz", "pc": "Pfeiltasten"});
final _ecke = (taste: "□ / ◫", zellen: {"normal": "maximieren / teilen", "pc": "–"});
/// Die Funktionstasten als eine Zeile; [domaenenVerweis] in der Zelle normal verweist auf die Domänen.
final _funktionstasten = (taste: "F1 … F10", zellen: {
  "normal": domaenenVerweis,
  "alpha": "f–j, l–p",
  "pc": "Namen tippen (Domänen)",
});

/// Die Zeile einer Taste aus keys.dart: was auf der Taste steht und, wenn es abweicht, was eingegeben wird.
Tastenzeile zeileVon(Taste t) {
  String mit(String? beschriftung, String? eingabe) {
    if (beschriftung == null) return "";
    if (eingabe == null || eingabe == beschriftung || t.aktion != Aktion.schreiben) return beschriftung;
    return "$beschriftung (${eingabe == " " ? "Leerzeichen" : eingabe})";
  }
  final name = t == tasteMaximieren ? "□ / ◫" : t.text;
  return (taste: name, zellen: {
    "normal": t.reserviert ? "reserviert" : mit(t.text, t.eingabe),
    "tilde": t.tilde ?? "",
    "strich": t.strich ?? "",
    "beide": t.beide ?? "",
    "shift": mit(t.shift, t.shiftEingabe),
    "shiftTilde": mit(t.shiftTilde, t.shiftTildeEingabe),
    "alpha": t.buchstabe ?? "",
    "pc": t.name ? _pcName(t) : _pc(t),
  });
}

/// Eine Funktion tippt man am PC mit ihrem Namen, auch Umkehrung und Shift-Belegung (asin, sinh): dann steht nur
/// der getippte Name mit „…“ da (sin…, pi… für π, deg… für DEG; Großbuchstaben auf der Taste zählen nicht als
/// Ausnahme). Wo eine andere Belegung anders getippt wird, folgen die Ausnahmen (ln…, außer ~ln für eˣ).
String _pcName(Taste t) {
  bool tippbar(String s) => RegExp(r"^[A-Za-z][A-Za-z0-9.]*$").hasMatch(s);
  final ausnahmen = <String>[];
  void pruefe(String? beschriftung, String getippt) {
    if (beschriftung != null && beschriftung.toLowerCase() != getippt.toLowerCase()) {
      ausnahmen.add("$getippt für $beschriftung");
    }
  }
  pruefe(t.shift, t.shiftEingabe ?? t.shift ?? "");
  // nach ~ schreibt die Taste ~ und ihre Eingabe; ein Name wie asin lässt sich auch direkt tippen
  if (t.tilde != null && !tippbar(t.tilde!)) pruefe(t.tilde, "~${t.tildeEingabe ?? t.eingabe}");
  if (t.shiftTilde != null && !tippbar(t.shiftTilde!)) pruefe(t.shiftTilde, t.shiftTildeEingabe ?? "~${t.shiftEingabe}");
  return ausnahmen.isEmpty ? "${t.eingabe}…" : "${t.eingabe}…, außer ${ausnahmen.join(", ")}";
}

/// Was man auf einer deutschen PC-Tastatur für die normale Belegung tippt.
String _pc(Taste t) {
  switch (t.aktion) {
    case Aktion.enter:
      return "Leertaste, Enter (Ziffernblock)";
    case Aktion.loeschen:
      return "Backspace";
    case Aktion.zeileLoeschen:
      return "Esc";
    case Aktion.menue:
      return "F10, \\m";
    case Aktion.tab:
      return "Tab";
    case Aktion.tilde:
      return "AltGr++";
    case Aktion.strich:
      return "AltGr+<";
    case Aktion.apostroph:
      return "⇧+#";
    case Aktion.shift:
      return "steckt im Zeichen";
    case Aktion.alpha || Aktion.maximieren:
      return "–";
    default:
  }
  if (t.reserviert) return "–";
  final e = t.eingabe;
  return _pcZeichen[e] ?? e;
}

const _pcZeichen = {"²": "AltGr+2", "³": "AltGr+3", "{": "AltGr+7", "ê": "^ e", "°": "⇧+^", "%": "⇧+5", "!": "⇧+1",
    ":": "⇧+.", "D": "⇧+d", "S": "⇧+s"};
