/// Belegung des Tastenfelds, siehe doc/app.md Kapitel 3.
library;

/// Was eine Taste tut, außer Text zu schreiben.
enum Aktion { schreiben, shift, alpha, tab, menue, loeschen, apostroph, tilde, strich, enter, funktion, maximieren }

/// Eine Taste mit ihren Beschriftungen. Ohne eigene Eingabe schreibt sie ihre Beschriftung.
/// [tilde], [strich] und [beide] sind die Beschriftungen nach den Präfixen `~`, `|` und `~|`;
/// geschrieben wird dann [eingabe] bzw. [tildeEingabe] hinter den Präfix.
class Taste {
  final String text;
  final String? _eingabe;
  final String? shift;
  final String? _shiftEingabe;
  final String? tilde;
  final String? tildeEingabe;
  final String? shiftTilde; // Beschriftung von ~ mit der Shift-Funktion, z.B. ≤ für ~>
  final String? shiftTildeEingabe; // statt ~ und Shift-Funktion geschrieben, z.B. ≤ (sonst ~ und shift)
  final String? strich;
  final String? beide;
  final String? buchstabe; // im Alpha-Modus
  final Aktion aktion;
  final bool reserviert;
  final int? funktion;     // Platz einer Funktionstaste F1–F10 (0–9)
  final bool name;         // schreibt einen Namen, der mit "_" abgeschlossen wird (doc/app.md 4.1)

  const Taste(this.text, {this._eingabe, this.shift, this._shiftEingabe, this.tilde, this.tildeEingabe, this.shiftTilde, this.shiftTildeEingabe,
      this.strich, this.beide, this.buchstabe, this.aktion = Aktion.schreiben, this.reserviert = false,
      this.funktion, this.name = false});

  /// Platzhalter für eine Funktionstaste, die Belegung kommt aus der Domäne.
  const Taste.f(int nr, String buchstabe) : this("", funktion: nr, buchstabe: buchstabe);

  /// Eine Funktion: schreibt ihren Namen, Shift und `~` wie angegeben.
  const Taste.fn(String text, {String? eingabe, String? shift, String? shiftEingabe, String? tilde, String? tildeEingabe})
      : this(text, eingabe: eingabe, shift: shift, shiftEingabe: shiftEingabe, tilde: tilde, tildeEingabe: tildeEingabe,
             name: true);

  String get eingabe => _eingabe ?? text;
  String? get shiftEingabe => _shiftEingabe ?? shift;
  bool get erlaubtTilde => tilde != null || beide != null || shiftTilde != null;
  bool get erlaubtStrich => strich != null || beide != null;
}

/// Oberer Block, Reihen R2 bis R5 (R1 mit Shift, Alpha, Cursorkreuz, Tab und Menü baut das Tastenfeld selbst).
const List<List<Taste>> obereTasten = [
  [
    Taste("'", aktion: Aktion.apostroph, buchstabe: r"\"),
    Taste("( )", reserviert: true, buchstabe: "a"),
    Taste("[ ]", reserviert: true, buchstabe: "b"),
    Taste("{ }", eingabe: "{", shift: "}", buchstabe: "c"),
    Taste("", reserviert: true, buchstabe: "d"),
    Taste("⌫", aktion: Aktion.loeschen, shift: "C"),
  ],
  [
    Taste("D", shift: "Y", buchstabe: "e"),
    Taste.f(0, "f"), Taste.f(1, "g"), Taste.f(2, "h"), Taste.f(3, "i"), Taste.f(4, "j"),
  ],
  [
    Taste("S", shift: "R", tilde: "~R", tildeEingabe: "R", buchstabe: "k"),
    Taste.f(5, "l"), Taste.f(6, "m"), Taste.f(7, "n"), Taste.f(8, "o"), Taste.f(9, "p"),
  ],
  [
    Taste("!", buchstabe: "q"),
    Taste("yˣ", eingabe: "^", tilde: "ˣ√y", buchstabe: "r"),
    Taste("x²", eingabe: "²", tilde: "√x", buchstabe: "s"),
    Taste("x³", eingabe: "³", tilde: "∛x", buchstabe: "t"),
    Taste("°", tilde: "→kart", buchstabe: "u"),
    Taste("%", tilde: "~%", strich: "|%", beide: "~|%", buchstabe: "v"),
  ],
];

/// Unterer Block, Reihen R6 bis R9.
const List<List<Taste>> untereTasten = [
  [
    Taste("ENTER", eingabe: " ", shift: "_", aktion: Aktion.enter),
    Taste("7"), Taste("8"), Taste("9"),
    Taste("÷", eingabe: "/", tilde: "1/x", strich: "|/", shift: ">", shiftTilde: "≤", shiftTildeEingabe: "≤", buchstabe: "w"),
  ],
  [
    Taste(":", tilde: "~:", strich: "|:", beide: "~|:"),
    Taste("4"), Taste("5"), Taste("6"),
    Taste("×", eingabe: "*", shift: "&", shiftTilde: "oder", buchstabe: "x"), // und wie das Produkt: 1·1 = 1
  ],
  [
    Taste("|", aktion: Aktion.strich, strich: "|x|"),
    Taste("1"), Taste("2"), Taste("3"),
    Taste("−", eingabe: "-", shift: "<", shiftTilde: "≥", shiftTildeEingabe: "≥", buchstabe: "y"),
  ],
  [
    Taste("~", aktion: Aktion.tilde),
    Taste("ê"), Taste("0"), Taste("."),
    Taste("+", shift: "=", shiftTilde: "≠", shiftTildeEingabe: "≠", buchstabe: "z"), // = wie auf Taschenrechnern bei +
  ],
];

/// Domänen für die Funktionstasten F1–F10; null ist eine freie Taste.
const Map<String, List<Taste?>> domaenen = {
  "Grundfunktionen": [
    Taste.fn("π", eingabe: "pi", shift: "e"),
    Taste.fn("rnd", shift: "seed", tilde: "~seed", tildeEingabe: "seed"),
    Taste.fn("round"),
    Taste.fn("dms"),
    Taste.fn("DEG", eingabe: "deg"),
    Taste.fn("sin", shift: "sinh", tilde: "asin"),
    Taste.fn("cos", shift: "cosh", tilde: "acos"),
    Taste.fn("tan", shift: "tanh", tilde: "atan"),
    Taste.fn("ln", shift: "log", tilde: "eˣ"),
    Taste.fn("RAD", eingabe: "rad", shift: "GRD", shiftEingabe: "grd"),
  ],
  "Programm": [
    Taste.fn("X", eingabe: "X"),
    Taste.fn("if"),
    Taste.fn("ifel"),
    Taste.fn("loop"),
    Taste.fn("times"),
    null, // < > = & liegen auf Shift der Rechenspalte (doc/app.md 3.1)
    null,
    null,
    null,
    null,
  ],
};
