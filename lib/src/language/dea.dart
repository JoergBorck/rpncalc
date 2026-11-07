/// Aufgabe: der deterministische endliche Automat, auf dem der Parser aufbaut. [Dea] wird aus einer Grammatik
/// erzeugt (Symbolgruppen als [SymbolListe] und eine [UebergangsTabelle]) und macht für jedes Zeichen einen
/// Schritt: Folgezustand bestimmen, Epsilon-Übergänge nachziehen und die Ausgabe des Übergangs liefern, eine Folge
/// von Kommandos aus je zwei Zeichen. Dazu die Fehlercodes XX bis XZ, die der Automat selbst meldet.
///
/// Abgrenzung: Der Automat kennt keine RPN-Sprache. Die Grammatik des Rechners steht in grammar.dart, die
/// Kommandos der Ausgabe führen parser.dart (Grundkommandos) und token.dart (alle übrigen) aus.
///
/// Siehe auch: grammar.dart, parser.dart, doc/reference.md Anhang A (EBNF), selftest/test_dea.dart.
library;

/// Übergangstabelle einer Grammatik: (Zustand, Symbolgruppe) -> (Folgezustand, Ausgabe)
typedef UebergangsTabelle = Map<(String , String), (String , String)>;

/// Symbolgruppen einer Grammatik: (Name der Gruppe, enthaltene Zeichen)
typedef SymbolListe = List<(String, String)>;

typedef SymbolMap = Map<String, List<String>>;

/// Deterministischer Endlicher Automat
///
/// Der Parser zerlegt mit dem Dea den Eingabestrom.
/// Er bildet die Grammatik ab. Er ist frei konfigurierbar.
/// die Konfiguration besteht aus Zeichengruppen und einer Uebergangstabelle 
/// Ablauf:
/// - Finde alle Gruppen, in denen das Zeichen enthalten ist.
/// - Teste, ob es eine Regel für den aktuellen Zustand und die Gruppe gibt.
///   -- Wenn ja, wende die Regel an: 
///     --- Wechsel den Zustand, 
///     --- füge die Ausgabe der Regel dem Ausgabestring hinzu.
///   -- Wenn nein, melde einen Fehler
///  - Teste Epsilon-Übergänge indem keine Gruppe übergeben wird auf die gleiche Weise
///  - Gibt den Ausgabestring zurück.
/// Der Parser nimmt dann den Ausgabestring und führt ihn Zeichen für Zeichen aus.
/// Wie der Ausgabestring aussieht, bestimmt die Grammatik  
class Dea {

// Beispiel für eine Grammatik (vereinfacht; die echte steht in grammar.dart und füllt jede Ausgabe mit _ auf
// 8 Zeichen auf)
// - Zeichengruppen: 
//   [("ziffer","0123456789"),
//    ("vorzeichen","-"),
//    ("dezimalpunkt","."),
//    ("zahlZeichen","123456789-.")
//    ("trenner"," ")]
// - Übergänge     : 
//    aktueller Eingabe          Neuer    Ausgabe
//    Zustand                    Zustand
//   {("q0"    ,"ziffer"      ):("qzahl" ,"*z+v"), // starte Zahl, Vorkommastelle hinzufügen
//    ("q0"    ,"vorzeichen"  ):("qpzahl","*z+s"), // starte Zahl, Vorzeichen setzen
//    ("qpzahl","ziffer"      ):("qzahl" ,"+v"  ), // nach dem '-' muss eine Zahl kommen
//    ("qzahl" ,"ziffer"      ):("qzahl" ,"+v"  ), // Vorkommastelle hinzufügen
//    ("qzahl" ,"dezimalpunkt"):("qdzahl",""    ), // nichts zu tun für den Parser 
//    ("qdzahl","ziffer"      ):("qdzahl","+n"  ), // Nachkommastelle hinzufügen
//    ("qzahl" ,"trenner"     ):("q0"    ,"!z"  ), // Zahl ist fertig und kann verarbeitet werden
//    ("qdzahl","trenner"     ):("q0"    ,"!z"  ), // Zahl ist fertig und kann verarbeitet werden
//                    
// Im Beispiel haben die Ausgaben folgende Bedeutung:
// Jede Ausgabe besteht aus 2 Zeichen: einem Kommando und einem Parameter je nach Kommando
// Kommando Bedeutung                   Parameter          Kommentar
//     *    Start:  Token-Start         Typ des Tokens
//     +    Append: zum Puffer dazu     Pufferbezeichnung  z.B. eine Ziffer oder ein Buchstabe 
//     !    Emit:   liefert Token       Typ des Tokens     Jetzt kann der Parser das Token auswerten
//     ?    Reconsume: Zeichen nochmal  erstmal ' '        Wenn das Zeichen schon zum nächsten 
//                                                         Token gehörte, soll es nochmal gesendet werden
//     _    nichts tun                                     füllt die Ausgabe auf
//     X    Error:                      Fehlertyp          Das Zeichen kann nicht verarbeitet werden

  final SymbolMap         symbolMap;
  final UebergangsTabelle uebergangsTabelle;
  final String            startState;

// Ich probiere mal einen Factory-Konstruktor, da die angedachte SymbolMap zwar gut zum Parsen
// aber blöd zum Beschreiben ist
  Dea._internal({
    required this.symbolMap,
    required this.uebergangsTabelle, 
    required this.startState,
  });

  factory Dea.init( 
  // init transformiert die Symbolliste zu einer Symboltabelle. 
  //   In der Liste steht Symbol = String mit den Zeichen 
  //   z.B. [("op","+-*/^%!<>=&²³°"),("grundOp","+-*/")...]
  //   das soll dann in eine Map eingetragen werden in der Form
  //   {'+':['op','grundOp] ,..., '^':['op'], ...}
  // mit dieser Liste kann der Automat dann schnell feststellen,
  // welcher Zustandsübergang erlaubt ist.

    SymbolListe symbolListe, 
    UebergangsTabelle uebergaenge 
    )  
  {
    final SymbolMap transformierteSymbolTabelle = {};
    // über diese Tabelle wird ein eingegebenes Zeichen einem oder mehreren möglichen Symbolen
    // zugeordnet. Das 'e' kann dann dem Symbol kleinbuchstabe, buchstabe und incodechar
    // zugeordnet werden. Der Automat würde dann für jedes der Symbole testen, ob es einen Match 
    //in der uebergangsTabelle gibt. Der erste Treffer wird dann ausgeführt
    for ((String, String) zeile in symbolListe) {
      // jede Zeile beschreibt ein Symbol
      for (String zeichen in zeile.$2.split('')) {
        // Alle für das Symbol erlaubte Zeichen durchgehen. Wenn zeichen noch nicht in der Map, benutzen 
        // den Lambda-Ausdruck () => [] um eine leere Liste zu erzeugen, an die das Symbol angefügt wird.
        transformierteSymbolTabelle.putIfAbsent(zeichen, () => []).add(zeile.$1);
      }
    }
    String start = uebergaenge.isNotEmpty ? uebergaenge.keys.first.$1 : "q0";
 
    return Dea._internal(
      symbolMap         : transformierteSymbolTabelle,
      uebergangsTabelle : uebergaenge, 
      startState        : start 
    );    
  }


  /// Ersatz-Symbol für jedes Zeichen, das in keiner Zeichenklasse vorkommt.
  static const String sonstSymbol = "sonst";

  // Fehlerrückgaben
  // Jeder Fehler begint mit einem X gefolgt von einem Zeichen für die Ursache
  // Dea reserviert die Fehler XX - XZ für sich. Alle anderen Fehlercodes 
  // können von der Grammatik frei verwendet werden.
  final String errorZeichenNichtErlaubt = "XY";
  final String errorZeichenUnbekannt    = "XZ"; // Z für Zeichen

  final Map<String, String> fehlerTexte = const {
    "XX": "Nicht implementiert",
    "XY": "Zeichen an dieser Stelle nicht erlaubt",
    "XZ": "Unbekanntes Zeichen",
  };


  String state="q0"; // aktueller Zustand des Automaten erstmal vorläufig auf q0 gesetzt.
    

  // Dea neu starten und alle Variablen initialisieren
  void restart() {
    state = startState;
  }

  // Einen Schritt im Dea durchführen. 
  //
  // Dazu wird ein Zeichen übergeben. Entsprechend der Eingabe und des aktuellen Zustandes
  // wird der Folgezustand berechnet und die Ausgabe für diesen Übergang zurückgeliefert.
  String step(String eingabe) {
    // Ablauf:
    // 1. Vom Eingabezeichen aus der symbolMap die möglichen Symbole für das Zeichen suchen
    // 2. Für diese testen, ob es einen Übergang im Automaten gibt.
    // 3. Den Übergang durchführen und die Ausgabe merken
    // --- Epsilon Test - Der Automat kann leere Übergänge besitzen, die keine Eingabe erfordern.  
    // 4. Schritt 2 und 3 solange mit leerer Eingabe testen, bis diese einen Fehler meldet.
    // 5. Ausgabe jedes erfolgreichen Schrittes 4 anfügen
    // 6. Ausgabe zurückgeben
    
    // Aufgrund der Einschränkungen durch die SymbolMap dürfen Eingabem nur 1 Charakter lang sein: 
    if (eingabe.isEmpty || eingabe.length > 1) {
      return errorZeichenUnbekannt;
    } 

    // Alle erlaubten Symbolegruppen holen 
    List<String>? symbols = symbolMap[eingabe];
    if (symbols == null) {
      // Dieses Eingabezeichen gibt es nicht in den Symbolen. Hat der Zustand einen Übergang für das
      // Ersatz-Symbol "sonst" (z.B. im Code-Block, der beliebige Zeichen enthalten darf), gilt der;
      // sonst kann mit einer Fehlerrückgabe abgebrochen werden.
      if (!uebergangsTabelle.containsKey((state, sonstSymbol))) return errorZeichenUnbekannt;
      symbols = const [sonstSymbol];
    } 

    // Ausprobieren, ob ein Übergang passt und wenn ja ausführen
    String ausgabe="";
    for (String symbol in symbols) {
      ausgabe=""; // Ausgabepuffer, initialisieren
      (String, String)? uebergang = uebergangsTabelle[(state, symbol)];  
      if (uebergang != null) { // Es wurde ein gültiger Übergang gefunden
        state = uebergang.$1;
        ausgabe = uebergang.$2;
        // Epsilon-Übergänge ausführen, wenn nötig 
        while (true) { 
          var epsilonuebergang = uebergangsTabelle[(state, "")];
          if (epsilonuebergang == null) { break; } 
          state = epsilonuebergang.$1;
          ausgabe += epsilonuebergang.$2; 
        }  
        return ausgabe;
      }
    } 
    // Wenn der Automat hier ankommt, wurde kein gültiges Symbol gefunden
    return errorZeichenNichtErlaubt; 
  }

}

