import '../rpntoken.dart';
import '../parser.dart';
import 'pruefung.dart';


// Unittests
class UnittestParser {
  /// Testfälle für die Grammatik: Eingabe und erwartete Token-Ausgabe (ohne den abschließenden Trenner).
  final List<List<String>> data = [
    // === 1. ZAHLEN (Z) ===
    ["42", "Z‖42.0"],
    ["3.1415", "Z‖3.1415"],
    [".5", "Z‖0.5"],
    ["~7", "Z‖-7.0"],
    ["~.25", "Z‖-0.25"],
    ["~12.34", "Z‖-12.34"],
    ["1ê6", "Z‖1000000.0"],
    ["5ê~2", "Z‖0.05"],
    ["~2.5ê3", "Z‖-2500.0"],
    ["~0.1ê~1", "Z‖-0.01"],

    // === 2. OPERATOREN (O) ===
    ["+", "O‖+"],
    ["-", "O‖-"],
    ["*", "O‖*"],
    ["/", "O‖/"],
    ["^", "O‖^"],
    ["~", "O‖~"],
    ["~~", "O‖~~"],
    ["~+", "O‖~+"],
    ["|", "O‖|"],
    ["||", "O‖||"],
    ["|+", "O‖|+"],
    ["~|+", "O‖~|+"],

    // mit Präfixen
    
    // q_Inv, ops: Wechselt von q_Inv bei einem Operator direkt nach q0 (Aktion: +~+o!O__)
    ["~-",     "O‖~-"],
    ["~*",     "O‖~*"],
    ["~/ ",    "O‖~/\tT‖_"],
    ["~^",     "O‖~^"],
    ["~!",     "O‖~!"],

    // q_Split, ops: Wechselt von q_Split bei einem Operator direkt nach q0 (Aktion: +|+o!O__)
    ["|-",     "O‖|-"],
    ["|*",     "O‖|*"],
    ["|/",     "O‖|/"],
    ["|^",     "O‖|^"],
    ["|% ",    "O‖|%\tT‖_"],

    // q_InvSplit, ops: Sequenz ~| gefolgt von einem Operator wechselt nach q0 (Aktion: +~+|+o!O)
    ["~|-",    "O‖~|-"],
    ["~|*",    "O‖~|*"],
    ["~|/",    "O‖~|/"],
    ["~|^",    "O‖~|^"],
    ["~|% ",   "O‖~|%\tT‖_"],

    // === 3. BEFEHLE / EINZELBUCHSTABEN (B) ===
    ["A", "B‖A"],
    ["P", "B‖P"],
    ["~X", "B‖~X"],

    // === 4. FUNKTIONEN (F) ===
    ["sin", "F‖sin"],
    ["sqrt", "F‖sqrt"],
    ["~log", "F‖~log"],

    // === 5. ARGUMENTE ÜBER DEN OPERATOR ":" ===
    // Für den Parser ist ":" ein normaler Operator, die Argumentliste verwaltet der Calculator.
    [":",           "O‖:"],
    ["~:",          "O‖~:"],
    ["|:",          "O‖|:"],
    ["~|:",         "O‖~|:"],
    ["3:S",         "Z‖3.0\tO‖:\tB‖S"],
    ["3:7:4:S",     "Z‖3.0\tO‖:\tZ‖7.0\tO‖:\tZ‖4.0\tO‖:\tB‖S"],
    ["4 7 3:::S",   "Z‖4.0\tT‖_\tZ‖7.0\tT‖_\tZ‖3.0\tO‖:\tO‖:\tO‖:\tB‖S"],
    ["8 4 5 3: S",  "Z‖8.0\tT‖_\tZ‖4.0\tT‖_\tZ‖5.0\tT‖_\tZ‖3.0\tO‖:\tT‖_\tB‖S"],
    ["2:sin",       "Z‖2.0\tO‖:\tF‖sin"],
    ["1:~sqrt",     "Z‖1.0\tO‖:\tF‖~sqrt"],
    ["1:'x",        "Z‖1.0\tO‖:\tV‖x"],
    ["3:'|tmp",     "Z‖3.0\tO‖:\tS‖tmp"],
    ["|3S",         "O‖|\tZ‖3.0\tB‖S"], // | leitet keine Argumente mehr ein
    ["':x",         "V‖:x"],            // erlaubt, weil ":" ein Operator ist; Bedeutung legt der Calculator fest

    // === 6. VARIABLEN (V) ===
    ["'a", "V‖a"],
    ["'~b", "V‖~b"],
    ["'+c", "V‖+c"],
    // Großbuchstaben nach ' sind Befehle mit Tags, keine Variablen
    ["'D", "B‖'D"],
    ["'~R", "B‖'~R"],
    ["3:'D", "Z‖3.0\tO‖:\tB‖'D"],
    ["'+R", "X‖A"],  // nur ~ ist als Präfix für Befehle erlaubt
    ["'5", "V‖5"],
    ["'123", "V‖1\tZ‖23.0"], // Argument-Zugriff hat genau eine Ziffer, danach folgt die Zahl 23
    ["'x", "V‖x"],
    ["'myvar", "V‖myvar"],
    ["'~abc", "V‖~abc"],
    ["'!x", "V‖!x"],
    ["'!!x", "V‖!!x"],     // Konstante
    ["'!!", "X‖A"],
    ["4!", "Z‖4.0	O‖!"],  // ! bleibt außerhalb von ' die Fakultät

    // === 7. STACK-TAGS (V) ===
    ["'|tmp", "S‖tmp"],
    ["'|A", "X‖B"],
    ["'||tmp", "S‖|tmp"],  // Tag mit Schreibschutz
    ["'||", "X‖B"],

    // === 8. TRENNER & KOMBINATIONEN (T / Gemischt) ===
    [" ", "T‖_"],
    ["\n", "T‖\\n"],
    ["10 20 +", "Z‖10.0\tT‖_\tZ‖20.0\tT‖_\tO‖+"],
    ["'x sin", "V‖x\tT‖_\tF‖sin"],
    ["~5.2 3ê2 *", "Z‖-5.2\tT‖_\tZ‖300.0\tT‖_\tO‖*"],
    ["A B +", "B‖A\tT‖_\tB‖B\tT‖_\tO‖+"],

    // === 9. FEHLER (X) ===
    // Bei einem Fehler bricht die Zeile ab, daher folgt kein abschließendes T‖\n
    [".",      "X‖2"],
    ["1 .",    "Z‖1.0\tT‖_\tX‖2"],
    ["5ê",     "X‖3"],
    ["5ê~",    "X‖4"],
    ["~|5",    "X‖5"],
    ["'",      "X‖9"],
    ["'~",     "X‖A"],
    ["'|",     "X‖B"],
    ["'|3x",   "X‖B"], // Argumente für Tags kommen jetzt über ":"
    ["§",      "X‖Z"], // unbekanntes Zeichen (Dea)
    ["1\x03",  "X‖Z"],    // ETX ist als Eingabe nicht erlaubt, nur per inject

    // === 10. CODE-BLÖCKE (K) ===
    // Ausgabe: {Inhalt} ohne die äußeren Klammern; Blöcke sind immer anonym, benannt wird mit ':name
    ["{1 2+}",         "K‖{1 2+}"],
    ["{1 {2} +}",      "K‖{1 {2} +}"],     // verschachtelt
    ["{{}}",           "K‖{{}}"],
    ["{a}{b}ifel",     "K‖{a}\tK‖{b}\tF‖ifel"], // zwei Blöcke, danach ein Aufruf
    ["{1 2+}':pq",     "K‖{1 2+}\tV‖:pq"], // Block als Funktion pq ablegen
    ["5{1}x 3",        "Z‖5.0\tK‖{1}\tF‖x\tT‖_\tZ‖3.0"],
    ["}",              "X‖1"],             // } ohne {

    // === 11. TRENNER _ ===
    // _ beendet ein Token, erzeugt aber selbst keins (auch kein Enter)
    ["1_2",            "Z‖1.0\tZ‖2.0"],
    ["pi_sin",         "F‖pi\tF‖sin"],
    ["5_{1}",          "Z‖5.0\tK‖{1}"],
    ["{1_2}",          "K‖{1_2}"],         // im Code bleibt _ erhalten
  ];


  /// Testet nur die Grammatik. Dafür wird ein eigener Parser ohne Calculator verwendet,
  /// damit Rechenfehler (z.B. "|/" auf leerem Stack) die Grammatiktests nicht beeinflussen.
  List<Pruefung> pruefe() {
    Parser<RpnToken> parser = rpnParser();
    parser.onToken("!", "", (token, name) => ParserResult.success); // jedes fertige Token akzeptieren
    return [
      for (int i=0; i<data.length; i++) () {
        String input = data[i][0];
        // Fehler brechen die Zeile ab, dann kommt kein abschließender Trenner mehr
        String expected = data[i][1].contains("X‖") ? data[i][1] : "${data[i][1]}\tT‖\\n";
        parser.reset();
        parser.feedLine(input);
        return Pruefung("${i+1}", input, expected, parser.tokenOutput);
      }()
    ];
  }

  bool test() => ausgeben("Parser", pruefe());
}

