import '../parser.dart';
import '../stack.dart';
import 'arguments.dart';
import 'code_stack.dart';
import 'value.dart';

/// Eine Aktion aus einer der Tabellen (Operatoren, Funktionen, Befehle).
typedef Aktion = void Function(Argumente a);

/// Rechenkern: Stack, Operanden, Ergebnis, Fehler und die Gates.
///
/// Die Bausteine (Speicher, Operatoren, Funktionen, Stack-Befehle) sind Mixins auf dem Kern
/// und nutzen dessen kurze Schreibweise, z.B.  ops=2; not0("div0",y) ?? result(x/y);
class Kern {
  final Stack stack = Stack(1000);
  final ArgumentListe args = ArgumentListe();
  final CodeStack codeStack = CodeStack(); // getrennt vom Werte-Stack
  /// Argumente der laufenden Aufrufe eigener Funktionen, der innerste zuletzt. ~: holt daraus von vorn.
  final List<List<Wert>> aufrufArgumente = [];
  int verbosity = 0;

  // Operanden: ops=n holt n Werte vom Stack, der Tos landet im letzten (bei n=2 in y).
  Wert x=0;
  Wert y=0;
  Wert z=0;
  int _geholt = 0; // Anzahl der von ops geholten Werte, damit error() sie zurücklegen kann

  set ops(int n) {
    if (!kannEntfernen(n)) return; // ein Tag blockiert, nichts holen
    if (n>=3) z = stack.pull();
    if (n>=2) y = stack.pull();
    if (n>=1) x = stack.pull();
    _geholt = n;
  }

  bool result([Wert? r1, Wert? r2, Wert? r3]) {
    if (fehlerCode.isNotEmpty) return false; // nach einem Fehler nichts auf den Stack legen
    List<Wert> werte = [?r1, ?r2, ?r3];
    if (!kannAnlegen(werte.length)) return false;
    werte.forEach(stack.push);
    return true;
  }

  // Gates: wenn man möchte, dass Berechnungen in Fehlerfällen (x/0) nicht durchgeführt werden,
  // statt NaN oder Infinity zu liefern. Die Zeile in einer Tabelle sieht dann z.B. so aus:
  //   "/" : (a) { ops=2; not0("div0",y) ?? result(x/y); },
  // Im Fehlerfall legt error() die von ops geholten Werte wieder auf den Stack.
  bool? not0(String msg, Wert x) => (x==0)?error(msg) : null;
  bool? isPos(String msg, Wert x) => (x<0)?error(msg) : null;
  bool? nan(String msg, Wert x, [Wert y=0]) => (x.isNaN || x.isInfinite || y.isNaN || y.isInfinite) ? error(msg) : null;

  final Map<String,String> errorMsg = {
    "div0" : "Division durch 0",
    "NaN"  : "Ungültiger Wert (NaN oder unendlich)",
    "op?"  : "Unbekannter Operator",
    "fkt?" : "Unbekannte Funktion",
    "bef?" : "Unbekannter Befehl",
    "var?" : "Variable ist nicht definiert",
    "varOp": "Operator ist für Variablen nicht erlaubt",
    "arg?" : "Argumente werden im Code mit ~: gelesen",
    "argAus": "Argumente gibt es nur in eigenen Funktionen",
    "arg0" : "Es gibt keine weiteren Argumente",
    "inCode": "Fehler in %",          // % wird durch das Detail ersetzt
    "rekursion": "Zu viele verschachtelte Aufrufe",
    "schleife": "Zu viele Durchläufe in einer Schleife",
    "anzahl": "Die Anzahl muss eine ganze Zahl sein",
    "code2": "Auf dem Code-Stack fehlen Blöcke",
    "tag"  : "Tag blockiert den Stack",
    "voll" : "Stack ist voll, ein Tag würde überschrieben",
    "tagC" : "Es gibt Tags, Stack und Tags löschen mit 'C",
    "elem" : "Element liegt außerhalb von Variable bzw. Tag",
    "rnd"  : "Ungültiger Bereich für rnd",
    "round": "Unbekannte Rundungsart (erlaubt: 0, ±1, ±2, ±3)",
    "k"    : "Als drittes Argument sind nur 0 (je Element ein Wert) oder 1 (ein Wert für alle) erlaubt",
    "block": "Ein Tag-Block darf nur als Ganzes verschoben oder entfernt werden",
    "tiefe": "Nicht genug Elemente auf dem Stack",
    "code0": "Der Code-Stack ist leer",
    "fktName": "Eingebaute Funktionen können nicht überschrieben werden",
    "konst": "Konstante kann nur gelesen werden",
    "schutz": "Tag ist schreibgeschützt",
    "json" : "Ungültiges JSON",
    "version": "Version passt nicht",
    "rpnName": "Namen mit rpn am Anfang sind für das System reserviert",
  };

  // Fehler: error() merkt den Fehler vor, ergebnis() gibt ihn am Ende
  // des Callbacks über das Token an den Parser weiter (wie die Grammatikfehler).
  String fehlerCode = "";
  String fehlerDetail = ""; // z.B. der Name der Variablen, wird an die Meldung angehängt

  bool error(String err, [String detail = ""]) {
    if (fehlerCode.isEmpty) { // der erste Fehler zählt
      fehlerCode = err;
      fehlerDetail = detail;
    }
    // geholte Werte in der ursprünglichen Reihenfolge zurücklegen, der Stack bleibt so erhalten
    for (Wert wert in [x, y, z].take(_geholt)) {
      stack.push(wert);
    }
    _geholt = 0;
    if (verbosity >= 1) {
      String output = errorMsg[err]??"$err has no error message";
      print("calculator.error found $err = $output");
    }
    return false;
  }

  /// Rückgabe für die Callbacks: success oder der vorgemerkte Fehler.
  ParserResult ergebnis(TokenBuilder token) {
    _geholt = 0; // Operation abgeschlossen, nichts mehr zurückzulegen
    if (fehlerCode.isEmpty) return ParserResult.success;
    token.errorCode = fehlerCode;
    String text = errorMsg[fehlerCode] ?? "Unbekannter Fehler $fehlerCode";
    // Das Detail ersetzt ein "%" im Text, sonst wird es mit ":" angehängt
    token.errorMsg = text.contains("%") ? text.replaceAll("%", fehlerDetail)
                   : fehlerDetail.isNotEmpty ? "$text: $fehlerDetail" : text;
    fehlerCode = "";
    fehlerDetail = "";
    return ParserResult.error;
  }

  /// true, wenn [name] eine eingebaute Funktion ist. Der Calculator kennt die Tabellen.
  bool istEingebaut(String name) => false;

  /// Führt Code aus (eigene Funktionen, X, if, ifel, loop). Der Calculator setzt das über den Parser um.
  void codeAusfuehren(String name, String code, Argumente a) => error("code0", "keine Ausführung möglich");

  /// Höchstzahl der Durchläufe von loop und times, danach ein Fehler (Schutz vor Endlosschleifen).
  int maxSchleife = 1000000;

  /// Name des Tags auf einer Adresse, für Fehlermeldungen. Der Speicher liefert den echten Namen.
  String tagNameVon(int adresse) => "Adresse $adresse";

  /// Prüft, ob [n] Elemente entfernt werden dürfen, und meldet sonst den blockierenden Tag.
  bool kannEntfernen(int n) {
    int? a = stack.blockiertEntfernen(n);
    if (a == null) return true;
    error("tag", "${tagNameVon(a)}, entfernen mit 'D");
    return false;
  }

  /// Prüft, ob [n] Elemente angelegt werden dürfen, ohne eine getaggte Zelle zu überschreiben.
  bool kannAnlegen(int n) {
    int? a = stack.blockiertAnlegen(n);
    if (a == null) return true;
    error("voll", tagNameVon(a));
    return false;
  }

  /// Prüft, ob die Werte in den [anzahl] Positionen ab [von] geändert werden dürfen,
  /// ohne den Namen eines Tags mit Schreibschutz zu nennen (z.B. durch S, R oder ~).
  bool kannAendern(int von, int anzahl) {
    for (int p = von; p < von + anzahl; p++) {
      if (stack.schreibgeschuetzt.contains(stack.adr(p))) {
        error("schutz", tagNameVon(stack.adr(p)));
        return false;
      }
    }
    return true;
  }

  /// Setzt den Kern zurück. Die Mixins ergänzen ihre eigenen Teile und rufen super.reset() auf.
  void reset() {
    x=0; y=0; z=0;
    stack.clear();
    args.reset();
    codeStack.reset();
    aufrufArgumente.clear();
  }
}
