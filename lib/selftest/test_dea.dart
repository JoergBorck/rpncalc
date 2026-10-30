
import '../dea.dart';
import '../gramma.dart';
import 'pruefung.dart';

class UnittestDea {

// Test-Eingaben für den DEA Unit-Test (mit KI erstellt)

// Eine Liste aus Records mit den Typen: (int id, String eingabe, String blockAusgabe)
final List<(int, String, String)> data = [
  // ==========================================
  // --- BASIS-TESTFÄLLE (Teil 1) ---
  // ==========================================
  (1, "42 ", 
   "*_+z____" "+z______" "!Z?_____" "*_!T____"), // 1. Integer mit Trenner
   
  (2, "3.14 ", 
   "*_+z____" "Sd______" "+z______" "+z______" "!Z?_____" "*_!T____"), // 2. Real mit Vorkomma
   
  (3, ".5 ", 
   "*_Sd____" "+z______" "!Z?_____" "*_!T____"), // 3. Real ohne Vorkomma
   
  (4, "6.02ê~23 ", 
   "*_+z____" "Sd______" "+z______" "+z______" "Se______" "Sm______" "+e______" "+e______" "!Z?_____" "*_!T____"), // 4. Exponent
   
  (5, "sin ", 
   "*_+n____" "+n______" "+n______" "!F?_____" "*_!T____"), // 5. Funktion (Name)
   
  (6, "P", 
   "*_+n!B__"), // 6. Nackter Befehl (Großbuchstabe)
   
  (7, "~15 ", 
   "*_______" "Ss+z____" "+z______" "!Z?_____" "*_!T____"), // 7. Invers-Zahl (negative Ganzzahl)
   
  (8, "~+", 
   "*_______" "+~+o!O__"), // 8. Invers-Operator (~+)
   
  (9, "~~", 
   "*_______" "+~+o!O__"), // 9. Doppel-Invers (~~)
   
  (10, "|+", 
   "*_______" "+|+o!O__"), // 10. Split-Operator (|+)
   
  (11, "~|+", 
   "*_______" "________" "+~+|+o!O"), // 11. Invers-Split (~|+)

  (12, ":",
   "*_+o!O__"), // 12. Argument-Operator (:)

  (22, "~:",
   "*_______" "+~+o!O__"), // 22. Invers-Argument-Operator (~:)

  (23, "|:",
   "*_______" "+|+o!O__"), // 23. Split-Argument-Operator (|:)

  (24, "~|:",
   "*_______" "________" "+~+|+o!O"), // 24. Invers-Split-Argument-Operator (~|:)

  (35, "'|3",
   "*_______" "________" "XB______"), // 35. Fehler XB: Tag-Argumente kommen jetzt über ":"

  (13, "'X", 
   "*_______" "+'+n!B__"), // 13. Großbuchstabe nach ' ist ein Befehl mit Tags
   
  (14, "'myvar ", 
   "*_______" "+v______" "+v______" "+v______" "+v______" "+v______" "!V?_____" "*_!T____"), // 14. Lange Variable
   
  (15, "'12 ", 
   "*_______" "+v!V____" "*_+z____" "!Z?_____" "*_!T____"), // 15. Argument-Zugriff '1, danach die Zahl 2
   
  (16, "'~abc ", 
   "*_______" "+v______" "+v______" "+v______" "+v______" "!V?_____" "*_!T____"), // 16. Variable mit Invers-Präfix
   
  (17, "{", 
   "*_S{____"), // 17. Start Code-Block (Wechsel zu q_Code, äußere Klammer nicht im Puffer)
   
  (18, ". ", 
   "*_Sd____" "X2______"), // 18. Fehler X2 (Ziffer nach Dezimalpunkt fehlt)
   
  (19, "5ê ", 
   "*_+z____" "Se______" "X3______"), // 19. Fehler X3 (Exponent-Wert fehlt)
   
  (20, "'~ ", 
   "*_______" "+v______" "XA______"), // 20. Fehler XA (Bezeichner nach Variablen-Präfix fehlt)


  // ==========================================
  // --- STACK-TAGS & BEZEICHNER ---
  // ==========================================
  (21, "'|tmp ", 
   "*_______" "________" "St+v____" "+v______" "+v______" "!S?_____" "*_!T____"), // 21. Tag ohne Argumente direkt mit Name
   
   


  // ==========================================
  // --- COMPLEX OPERATORS & ARGUMENTS ---
  // ==========================================
  (25, "||", 
   "*_______" "+|+o!O__"), // 25. Doppel-Split als Operator (||)
   
  (26, "|+", 
   "*_______" "+|+o!O__"), // 26. Split-Operator mit Plus (|op)
   
  (27, "~|+", 
   "*_______" "________" "+~+|+o!O"), // 27. Invers-Split mit Operator (~|op)


  // ==========================================
  // --- VARIABLEN VARIATIONEN ---
  // ==========================================
  (30, "'2", 
   "*_______" "+v!V____"), // 30. Argument-Zugriff ist nach einer Ziffer fertig
   
  (31, "'a ", 
   "*_______" "+v______" "!V?_____" "*_!T____"), // 31. Einbuchstabige Variable (klein) mit Trenner


  // ==========================================
  // --- EXTREME EXPONENTEN & REALS ---
  // ==========================================
  (32, "1ê234 ", 
   "*_+z____" "Se______" "+e______" "+e______" "+e______" "!Z?_____" "*_!T____"), // 32. Mehrstelliger Exponent
   
  (33, "1.ê2 ", 
   "*_+z____" "Sd______" "Se______" "+e______" "!Z?_____" "*_!T____"), // 33. Real direkt in Exponent
   
  (34, "5ê~ ", 
   "*_+z____" "Se______" "Sm______" "X4______"), // 34. Fehler X4: Vorzeichen im Exponent ohne folgende Ziffer


  // ==========================================
  // --- FEHLERZUSTÄNDE (Tag & Argument-Struktur)
  // ==========================================



  (38, "'| ",
   "*_______" "________" "XB______"), // 38. Fehler XB: Trenner direkt nach Tag-Start

  // ==========================================
  // --- KONSTANTEN UND TAGS MIT SCHREIBSCHUTZ ---
  // ==========================================
  (46, "'!x ",
   "*_______" "+v______" "+v______" "!V?_____" "*_!T____"), // 46. Variable anlegen
  (47, "'!!x ",
   "*_______" "+v______" "+v______" "+v______" "!V?_____" "*_!T____"), // 47. Konstante anlegen
  (48, "'||t ",
   "*_______" "________" "+v______" "St+v____" "!S?_____" "*_!T____"), // 48. Tag mit Schreibschutz
  (49, "'!!1",
   "*_______" "+v______" "+v______" "XA______"), // 49. Fehler XA: Name fehlt nach '!!

  // ==========================================
  // --- CODE-BLÖCKE ---
  // Das ETX (\x03) schiebt im Parser der RpnToken nach; hier steht es direkt in der Eingabe.
  // ==========================================
  (43, "{1}\x03x ",
   "*_S{____" "+c______" "C}+c____" "!K______" "*_+n____" "!F?_____" "*_!T____"), // 43. Block, danach Funktion x
  (44, "{{}}\x03 ",
   "*_S{____" "S{+c____" "C}+c____" "C}+c____" "!K______" "*_!T____"), // 44. verschachtelt
  (45, "{\n}\x03y ",
   "*_S{____" "+c______" "C}+c____" "!K______" "*_+n____" "!F?_____" "*_!T____"), // 45. Zeilenumbruch im Block




];



  /// Füttert den Automaten Zeichen für Zeichen und vergleicht die gesamte Ausgabe.
  /// Enthält eine Ausgabe das Kommando "?", wird das Zeichen wie im Parser noch einmal verarbeitet.
  List<Pruefung> pruefe() {
    Dea automat = Dea.init(rpnSymbols, rpnGramma);
    return [
      for ((int, String, String) entry in data) () {
        automat.restart();
        String ausgabe = "";
        for (String c in entry.$2.split("")) {
          String o = automat.step(c);
          ausgabe += o;
          if (_wiederholen(o)) ausgabe += automat.step(c);
        }
        return Pruefung("${entry.$1}", entry.$2, entry.$3, ausgabe);
      }()
    ];
  }

  /// true, wenn eines der Kommandos (gerade Positionen) ein "?" ist.
  bool _wiederholen(String ausgabe) {
    for (int i = 0; i < ausgabe.length; i += 2) {
      if (ausgabe[i] == "?") return true;
    }
    return false;
  }

  bool test() => ausgeben("DEA", pruefe());

}