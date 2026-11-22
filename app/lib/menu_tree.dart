/// Aufgabe: der Menübaum der App als Daten (doc/app.md 3.6): die Bereiche des Hauptmenüs, die Modi mit ihren Werten
/// und die Buchstaben der Funktionstasten. Reines Dart ohne Flutter, damit auch Werkzeuge (tool/keytable.dart, DG-7)
/// und Tests ihn lesen können.
///
/// Abgrenzung: Der Zustand beim Bedienen (was gewählt ist, Rahmen, OK) steht in model/menu.dart, gezeichnet wird in
/// keypad/ und display/menu_page.dart. Die Symbole sind Pfade zu Assets der App; im Menü-Modell des Kerns (RG-5)
/// würden sie eine Kennung.
///
/// Siehe auch: doc/app.md 3.6, doc/keys.md, model/menu.dart, keys.dart.
library;

import 'keys.dart';

/// Wo im Menü man ist; null heißt: das Menü ist zu.
enum MenueBereich { haupt, bibliotheken, modi }

/// Wie eine Taste in einem Bereich des Menüs umrandet ist: was OK bewirken wird (doc/app.md 3.6).
enum MenueRahmen {
  /// Bibliotheken: nicht geladen und bleibt so, auch wenn gewählt; Modi: Platzhalter
  keiner,
  /// gewählt (zuletzt gedrückt) und geladen bzw. wird geladen; Modi: zuletzt gedrückt: orange, breiter
  gewaehlt,
  /// Bibliotheken: wird geladen, nicht gewählt; Modi: Wert geändert: grün
  laden,
  /// wird entladen, auch wenn gewählt: rot mit schrägem Strich
  entladen,
  /// Bibliotheken: geladen und bleibt, nicht gewählt; Modi: Wert unverändert: weiß
  geladen,
}

/// Ein Bereich des Hauptmenüs: seine Taste im Ziffernblock, Name, Symbol (Asset der App) und Hilfe-Kennung.
typedef MenuePunkt = ({String taste, String name, MenueBereich bereich, String symbol, String hilfe});

/// Die Bereiche des Hauptmenüs: Bibliotheken auf 4 (FA-30), Modi auf 8 (FA-32). Die übrigen Tasten bleiben leer.
const List<MenuePunkt> menueHauptpunkte = [
  (taste: "4", name: "Bibliotheken", bereich: MenueBereich.bibliotheken, symbol: "assets/icons/bibliothek.svg",
      hilfe: "menue:bibliotheken"),
  (taste: "8", name: "Modi", bereich: MenueBereich.modi, symbol: "assets/icons/modi.svg", hilfe: "menue:modi"),
];

/// Der Bereich des Hauptmenüs auf der Taste [text], sonst null.
MenuePunkt? menuePunktAuf(String text) => menueHauptpunkte.where((p) => p.taste == text).firstOrNull;

/// Ein Modus im Bereich Modi (FA-32): Name, Symbol, die Werte der Reihe nach (der erste ist der Standard), ob er
/// schon wirkt, und für Platzhalter, womit er kommt.
typedef ModusFeld = ({String name, String symbol, List<String> werte, bool aktiv, String spaeter});

/// Die Modi auf den Funktionstasten F1–F10 (FA-32); null ist eine leere Taste. Aktiv sind Format, Winkel, Trenner
/// und Bruch (FR-3); Trig kommt mit FR-15, Klasse, Domain und Auflösung mit FR-11. Die Werte von Format, Trenner
/// und Bruch stehen in der Reihenfolge von Zahlformat, Trenner und Bruch im Kern.
const List<ModusFeld?> modusFelder = [
  (name: "Format", symbol: "assets/icons/format.svg", werte: ["Std", "Fix", "Sci", "Eng", "SI"], aktiv: true,
      spaeter: ""),
  (name: "Winkel", symbol: "assets/icons/winkel.svg", werte: ["Deg", "Rad", "Grd"], aktiv: true, spaeter: ""),
  (name: "Trig", symbol: "assets/icons/trig.svg", werte: ["CIRC", "HYPR", "CARD", "VERS", "ELLP", "ELLQ"],
      aktiv: false, spaeter: "FR-15"),
  (name: "Klasse", symbol: "assets/icons/klasse.svg", werte: ["ℝ", "𝔻", "ℚ", "ℤ"], aktiv: false, spaeter: "FR-11"),
  null,
  (name: "Trenner", symbol: "assets/icons/trenner.svg", werte: ["1000", "1,000", "1'000", "1\u202F000"], aktiv: true,
      spaeter: ""),
  (name: "Bruch", symbol: "assets/icons/bruch.svg", werte: ["#.#", "#/#", "# #/#"], aktiv: true, spaeter: ""),
  (name: "Domain", symbol: "assets/icons/domain.svg", werte: ["ℝ", "ℂ"], aktiv: false, spaeter: "FR-11"),
  (name: "Auflösung", symbol: "assets/icons/aufloesung.svg", werte: ["simple", "high", "max"], aktiv: false,
      spaeter: "FR-11"),
  null,
];

/// Die Bilder für Bruch je Wert, auf der Taste und im Feld der Menüseite: derselbe Wert in drei Schreibweisen (1.5,
/// 3/2, 1 1/2).
const Map<String, String> bruchBilder = {
  "#.#": "assets/icons/bruch_dezimal.svg",
  "#/#": "assets/icons/bruch_bruch.svg",
  "# #/#": "assets/icons/bruch.svg",
};

/// Die Buchstaben der Funktionstasten F1–F10 aus dem Alpha-Modus (f–j, l–p, keys.dart): am PC drückt ein Buchstabe im
/// Menü die Taste an seinem Platz, ein Großbuchstabe wie Shift.
final List<String> funktionsBuchstaben = [
  for (final t in [for (final r in obereTasten) ...r.where((t) => t.funktion != null)]..sort((a, b) => a.funktion!.compareTo(b.funktion!)))
    t.buchstabe!,
];

/// Der Modus mit dem Namen [name], sonst null.
ModusFeld? modusFeld(String name) => modusFelder.where((f) => f?.name == name).firstOrNull;
