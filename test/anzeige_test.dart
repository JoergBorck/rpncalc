import 'package:rpncalc/console/display.dart';
import 'package:rpncalc/console/screen.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Anzeige der Eingabezeile bei der Zeicheneingabe, siehe doc/api.md 5.7.
void main() {
  List<String> anzeige(String tasten, {int breite = 79}) {
    final api = RpnApi();
    for (final c in tasten.split("")) {
      api.taste(c);
    }
    return Anzeige.eingabe(api.zustand(), breite: breite, farbe: false);
  }

  test('ohne Fehler: die Zeile und ein vorgemerktes Enter', () {
    expect(anzeige("3 4+"), ["RPN> 3 4+"]);
    expect(anzeige("5 "), ["RPN> 5  ENTER↑"]);
  });

  test('mit Fehler: ^ unter dem Anfang des fehlerhaften Tokens', () {
    expect(anzeige("7 3+ 1q2 5"), [
      "RPN> 7 3+ 1q2 5",
      "           ^ Unbekannte Funktion: q",
    ]);
  });

  test('lange Zeilen: nur ein Ausschnitt um den Fehler', () {
    final zeilen = anzeige("${"1 2+ " * 20}q 4 5 6 7 8 9 ${"1 " * 20}", breite: 40);
    expect(zeilen[0].length, lessThanOrEqualTo(40));
    expect(zeilen[0], startsWith("RPN> …"));
    expect(zeilen[0], endsWith("…"));
    final stelle = zeilen[1].indexOf("^");
    expect(zeilen[0][stelle], "q");
  });

  test('lange Zeilen ohne Fehler: das Ende bleibt sichtbar', () {
    final zeilen = anzeige("${"1 " * 50}23", breite: 30);
    expect(zeilen.single.length, lessThanOrEqualTo(30));
    expect(zeilen.single, endsWith("1 23 ENTER↑")); // das Leerzeichen vor 23 wartet noch
  });

  test('Cursor am Ende der Eingabe, vor ENTER und nach einem wartenden Zusatz', () {
    final api = RpnApi();
    for (final c in "2++ 3".split("")) {
      api.taste(c);
    }
    expect(Anzeige.eingabe(api.zustand(), farbe: false, cursor: true), ["RPN> 2++ 3█ ENTER↑"]);
    expect(Anzeige.eingabe(api.zustand(), farbe: false, cursor: true, zusatz: "\\"), ["RPN> 2++ 3\\█ ENTER↑"]);
    expect(Anzeige.eingabe(api.zustand(), farbe: false, cursor: true, leer: true), ["RPN> █ ENTER↑"]);
  });

  test('Zwischenablage: Dezimalkomma, getrennt mit Semikolon, der Tos zuletzt', () {
    expect(Anzeige.fuerExcel([4, 2.25, 26.75, -3]), "4;2,25;26,75;-3");
    expect(Anzeige.fuerExcel([7]), "7");
    expect(Anzeige.fuerExcel([4.11032e-19, 0.1 + 0.2]), "4,11032e-19;0,3"); // kleine Zahlen nicht als 0
  });

  test('Einfügen: Zahlen aus Excel oder Text in der Schreibweise des Rechners', () {
    expect(Anzeige.ausExcel("3,4e-6"), ["3.4ê~6"]);
    expect(Anzeige.ausExcel("3.4"), ["3.4"]);
    expect(Anzeige.ausExcel("1;2,25;-3\t4,5E+03\r\n1e05"), ["1", "2.25", "~3", "4.5ê3", "1ê5"]);
    expect(Anzeige.ausExcel("Messung\tWert\nA\t#DIV/0!\nB\t-0,5"), ["~0.5"]);
    expect(Anzeige.ausExcel("2026-10-29"), ["2026", "10", "29"]); // Minus nach einer Ziffer ist kein Vorzeichen
    expect(Anzeige.ausExcel("1.5,2.5,3.5"), ["1.5", "2.5", "3.5"]);   // höchstens ein Dezimalzeichen je Zahl
    expect(Anzeige.ausExcel("x-1 -2"), ["1", "~2"]);
    expect(Anzeige.ausExcel(""), isEmpty);
    // Kommas (BA-3): einzeln Dezimalkomma, in einer Folge oder neben einem Dezimalpunkt Trennzeichen
    expect(Anzeige.ausExcel("4,5,6,7"), ["4", "5", "6", "7"]);
    expect(Anzeige.ausExcel("4,5;6"), ["4.5", "6"]);
    expect(Anzeige.ausExcel("1.5,2"), ["1.5", "2"]);
    expect(Anzeige.ausExcel("1,5 2,5 3,5"), ["1.5", "2.5", "3.5"]);
  });

  test('Einfügen: die umgeschriebenen Zahlen versteht der Rechner', () {
    final api = RpnApi();
    expect(api.eingabe(Anzeige.ausExcel("3,4e-6;-2\n1,5E+2").join("_")).fehler, isNull);
    expect(api.calculator.stack[0], 150);
    expect(api.calculator.stack[1], -2);
    expect(api.calculator.stack[2], closeTo(3.4e-6, 1e-20));
  });

  test('vor dem Kopieren wird ein offenes Token abgeschlossen, wenn es geht', () async {
    for (final (tasten, tos, offen) in [("2.25", 2.25, ""), ("3 2.25", 2.25, ""), ("1'", 1, "'"), ("1 2+", 3, "")]) {
      final api = RpnApi();
      for (final c in tasten.split("")) {
        api.taste(c);
      }
      final z = await Bildschirm(LokalerRechner(api), () async => -1).tokenAbschliessen();
      expect(api.calculator.stack[0], tos, reason: tasten);
      expect(z.offen, offen, reason: tasten);
      expect(z.fehler, isNull, reason: tasten);
    }
  });

  test('der Tos ist hellorange hinterlegt, Spalten und Kürzen zählen nur sichtbare Zeichen', () {
    final z = RpnApi().eingabe("1 22 333");
    expect(Anzeige.kompakt(z, farbe: false), "deg │ [1] [22] [333]<tos");
    expect(Anzeige.kompakt(z), contains("\x1B[48;5;223;30m[333]\x1B[0m<tos"));
    final zeilen = Anzeige.uebersicht(z).split("\n");
    final ohne = Anzeige.uebersicht(z, farbe: false).split("\n");
    expect(Anzeige.sichtbar(zeilen[0]), ohne[0].length, reason: "Spalten bleiben ausgerichtet");
    expect(Anzeige.kuerzen("ab\x1B[31mcdef\x1B[0mgh", 4), "ab\x1B[31mcd\x1B[0m");
    expect(Anzeige.kuerzen("abc", 4), "abc");
  });

  group('Offenes Token über dem Stack (doc/api.md Kapitel 7)', () {
    Zustand getippt(String tasten, {int zeilen = 8}) {
      final api = RpnApi();
      Zustand z = api.zustand();
      for (final c in tasten.split("")) {
        z = api.taste(c, zeilen: zeilen);
      }
      return z;
    }

    test('grau über dem Tos, nur solange ein Token offen ist', () {
      final zeilen = Anzeige.uebersicht(getippt("1 22 333"), farbe: false, ansicht: Ansicht()).split("\n");
      expect(zeilen.take(3).map((z) => z.split("│").first.trimRight()), [" >:              333", " x:               22", " y:                1"]);
      expect(Anzeige.uebersicht(getippt("1 22 333+"), farbe: false, ansicht: Ansicht()), isNot(contains(">:")));
      expect(Anzeige.uebersicht(getippt("4 "), farbe: false, ansicht: Ansicht()), isNot(contains(">:")),
          reason: "ein vorgemerktes Enter allein ist kein offenes Token");
      expect(Anzeige.uebersicht(getippt("7 3+ 1q2"), farbe: false, ansicht: Ansicht()), isNot(contains(">:")),
          reason: "nach einem Fehler markiert die Eingabezeile");
      expect(Anzeige.uebersicht(getippt("1 22 333")), contains("\x1B[2m >:"), reason: "grau");
    });

    test('Namen, Präfixe und Code; zu lange Token behalten ihr Ende', () {
      String offen(String tasten) => Anzeige.uebersicht(getippt(tasten), farbe: false, ansicht: Ansicht())
          .split("\n").first.split("│").first.trim().replaceAll(RegExp(" +"), " "); // rechtsbündig
      expect(offen("2 si"), ">: si");
      expect(offen("5'!a"), ">: '!a");
      expect(offen("~3.5ê~"), ">: ~3.5ê~");
      expect(offen("{1 2 3 4 5 6 7 8 9 10"), ">: … 4 5 6 7 8 9 10", reason: "16 Zeichen, das Ende bleibt");
    });

    test('zählt zu den 8 Zeilen, nicht zurückgeblättert', () {
      final z = getippt("1 2 3 4 5 6 7 8 9 10 11", zeilen: 20);
      final zeilen = Anzeige.uebersicht(z, farbe: false, ansicht: Ansicht()).split("\n");
      expect(zeilen.first, startsWith(" >:"));
      expect(zeilen[7], startsWith(" ₆:"), reason: "eine Stackzeile weniger");
      expect(zeilen[8], startsWith(" … 3 weitere"));
      final geblaettert = Anzeige.uebersicht(z, farbe: false, ansicht: Ansicht()..stackVersatz = 1);
      expect(geblaettert, isNot(contains(">:")));
    });

    test('kompakt hinter dem Tos', () {
      expect(Anzeige.kompakt(getippt("1 22 333"), farbe: false), "deg │ [1] [22]<tos >:333");
      expect(Anzeige.kompakt(getippt("3"), farbe: false), "deg │ [ ]<tos >:3");
      expect(Anzeige.kompakt(getippt("1 22 333"), farbe: false, versatz: 1), isNot(contains(">:")));
    });
  });

  group('Navigation: Ausschnitte für Tab und Pfeiltasten', () {
    late RpnApi api;
    setUp(() {
      api = RpnApi();
      api.eingabe("1 2 3 4 5 6 7 8 9 10 11 12");
      api.eingabe("{1+}':inc_{2*}':dbl_{~:~:~:~:R*+rw_cos*}':hx_7'!a");
    });

    test('Stack ab einer tieferen Position', () {
      final zeilen = Anzeige.uebersicht(api.zustand(zeilen: 20), farbe: false, ansicht: Ansicht()..stackVersatz = 3)
          .split("\n");
      expect(zeilen.first, startsWith(" t:"), reason: "Position 3 heißt t");
      expect(zeilen[7], startsWith("₁₀:"));
      expect(zeilen[8], startsWith(" … 1 weitere"));
      // nicht weiter als bis der unterste Wert (Position 11) in der letzten Zeile steht
      final ende = Anzeige.uebersicht(api.zustand(zeilen: 20), farbe: false, ansicht: Ansicht()..stackVersatz = 10)
          .split("\n");
      expect([ende.first.substring(0, 3), ende[7].substring(0, 3), ende.length], [" ₄:", "₁₁:", 8]);
      expect(Anzeige.kompakt(api.zustand(zeilen: 20), farbe: false, versatz: 3), endsWith("… [6] [7] [8] [9] …<tos"));
    });

    test('zweite Spalte: Variablen oder Funktionen, Name bleibt beim Schieben stehen', () {
      String spalte(Ansicht a) => Anzeige.uebersicht(api.zustand(), farbe: false, ansicht: a)
          .split("\n").map((z) => z.split("│")[1].trim()).where((t) => t.isNotEmpty).join(" / ");
      expect(spalte(Ansicht()), "a = 7");
      expect(spalte(Ansicht()..funktionen = true), "inc {1+} / dbl {2*} / hx {~:~:~:~:R*+rw_cos*}");
      // alles passt in die Spalte: nichts bewegt sich
      final kurz = Ansicht()..funktionen = true;
      expect(Anzeige.schieben(api.zustand(), kurz, 5), isFalse);
      expect(spalte(kurz), "inc {1+} / dbl {2*} / hx {~:~:~:~:R*+rw_cos*}");
      // jede Zeile für sich: was ganz passt, bleibt stehen; nach rechts höchstens bis zum Ende
      api.eingabe("{1 2 3 4 5 6 7 8 9 10 11 12 13 14}':lang");
      api.eingabe("{1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17}':mehr");
      final a = Ansicht()..funktionen = true;
      String zeile(String name) => spalte(a).split(" / ").firstWhere((t) => t.startsWith("$name "));
      for (int i = 0; i < 10; i++) {
        Anzeige.schieben(api.zustand(), a, 5);
      }
      expect(Anzeige.schieben(api.zustand(), a, 5), isFalse, reason: "alle am Ende");
      expect([zeile("inc"), zeile("lang"), zeile("mehr")],
          ["inc {1+}", "lang … 9 10 11 12 13 14}", "mehr …12 13 14 15 16 17}"]);
      expect(zeile("lang").length, 24, reason: "füllt die Spalte genau");
      // nach links bewegen sich alle sofort wieder, die kürzere kommt nur früher am Anfang an
      Anzeige.schieben(api.zustand(), a, -5);
      expect([zeile("lang"), zeile("mehr")], ["lang …6 7 8 9 10 11 12 …", "mehr …0 11 12 13 14 15 …"]);
      for (int i = 0; i < 2; i++) {
        Anzeige.schieben(api.zustand(), a, -5);
      }
      expect([zeile("lang"), zeile("mehr")], ["lang {1 2 3 4 5 6 7 8 9…", "mehr … 6 7 8 9 10 11 12…"]);
    });
  });

  test('Verlauf: jede Zeile lässt sich seitlich schieben, bis ihr Anfang bzw. Ende sichtbar ist', () {
    List<String> zeile(String text, {int? von}) =>
        Anzeige.verlauf(RpnApi().eingabe(text), breite: 20, farbe: false, von: von);
    expect(zeile("1 2+"), ["RPN> 1 2+"]);
    // ohne Fehler zuerst das Ende, ganz links der Anfang, über die Grenzen hinaus nicht weiter
    expect(zeile("1 2 3 4 5 6 7 8 9 10"), ["RPN> …4 5 6 7 8 9 10"]);
    expect(zeile("1 2 3 4 5 6 7 8 9 10", von: 0), ["RPN> 1 2 3 4 5 6 7 …"]);
    expect(zeile("1 2 3 4 5 6 7 8 9 10", von: 99), zeile("1 2 3 4 5 6 7 8 9 10"));
    expect(Anzeige.verlaufMax(RpnApi().eingabe("1 2+"), 20), 0);
    // mit Fehler: "^" darunter, liegt er außerhalb, zeigt ein Pfeil die Richtung
    expect(zeile("1 2 3 4 5 6 7 8 q"), ["RPN> … 3 4 5 6 7 8 q", "                   ^ Unbekannte Funktion: q"]);
    expect(zeile("1 2 3 4 5 6 7 8 q", von: 0), ["RPN> 1 2 3 4 5 6 7 …", "     → Unbekannte Funktion: q"]);
  });
}
