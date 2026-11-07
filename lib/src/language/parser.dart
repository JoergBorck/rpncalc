/// Aufgabe: der allgemeine Parser, unabhängig von einer bestimmten Grammatik. [Parser] schickt jedes Zeichen durch
/// den [Dea], erledigt die Grundkommandos der Ausgabe selbst (neues Token, Zeichen nochmal, nichts tun, Fehler)
/// und gibt alle übrigen an einen [TokenBuilder] weiter. Ist ein Token fertig, ruft er den Callback auf, der für
/// diese Token-Art mit `onToken` angemeldet ist. Für die Eingabe Zeichen für Zeichen merkt er sich das offene
/// Token, die Position eines Fehlers und kann ein Zeichen zurücknehmen (`zurueck`) oder nach einem Fehler das
/// fehlerhafte Token wieder öffnen.
///
/// Abgrenzung: Die RPN-Grammatik steht in grammar.dart, der TokenBuilder für sie (RpnToken) und die Fabrik
/// `rpnParser` in token.dart. Was mit einem Token geschieht, entscheidet der Calculator in engine/ über die
/// Callbacks.
///
/// Siehe auch: dea.dart, token.dart, engine/calculator.dart, doc/api.md Kapitel 5 (Eingabe Zeichen für Zeichen).
library;

import 'dea.dart';

/// Der Parser ruft Callbacks für die gefundenen Tokens auf
///
/// Callbacks werden mit parser.onToken(cmd, param, callback) registriert.
typedef ParserCallback<T extends TokenBuilder> = ParserResult Function(T token, String name);

/// Baut aus den Kommandos des DEA ein Token zusammen.
///
/// Der Parser behandelt die Grundkommandos selbst, die für jede Grammatik gleich sind:
///   *  neues Token beginnen (ruft reset auf)
///   ?  das aktuelle Zeichen noch einmal verarbeiten
///   _  nichts tun
///   X  Fehler, der Parameter ist der Fehlercode
/// Alle anderen Kommandos und ihre Bedeutung legt die Grammatik fest und gibt der Parser an
/// verarbeite() weiter. Dadurch lässt sich der Parser mit anderen Grammatiken wiederverwenden.
abstract class TokenBuilder {
  String errorCode = "";  // z.B. "6" bei X6, oder ein Code des Aufrufers
  String errorMsg  = "";  // lesbarer Text zum Fehler

  /// Zeichen, das der Parser nach dem aktuellen zusätzlich verarbeiten soll (leer = keins).
  /// So kann der TokenBuilder Zustandswechsel auslösen, die der DEA allein nicht erkennen kann,
  /// z.B. das Ende eines verschachtelten Code-Blocks.
  String inject = "";

  /// Name bzw. Wert des fertigen Tokens, wird an die Callbacks übergeben.
  String get name;

  /// Lesbare Form des Tokens, z.B. für Tests und tokenOutput.
  String get anzeige;

  /// Beginnt ein neues Token.
  void reset();

  /// Verarbeitet ein Kommando der Grammatik. Liefert true, wenn das Token damit fertig ist.
  bool verarbeite(String zeichen, String kommando, String parameter);
}

/// Beim Anlegen eines Callbacks wird der Erfolg zurückgegeben.
enum ParserResult {
  /// Noch nichts da
  empty, 

  /// Bin noch nicht fertig
  processing, 

  /// Wird gesendet, wenn man ein leeres Zeichen sendet
  waiting,

  /// Wird gesendet, wenn DEA ein leeres Kommando "__" sendet.
  ignore,

  /// Hat geklappt
  success,

  /// Hat geklappt, aber das letzte Zeicjem muss nochmal durch den Parser
  reconsume, // tritt auf, wenn erst das nächste Zeichen das Ende eines Tokens anzeigt

  /// Der TokenBuilder verlangt, dass ein zusätzliches Zeichen (TokenBuilder.inject) verarbeitet wird
  inject,

  /// Tritt auf, wenn man ein Zeichen in den Parser wirft, obwohl noch ein Zeichen im 
  /// Reconsum Puffer liegt.
  errorReconsume,

  /// Fehler aufgetreten
  error,

  /// Rückfall-Wert bei einem Fehler im Code, nicht in der Eingabe: ein Kommando der Grammatik ist noch nicht
  /// umgesetzt (not yet implemented). Gilt als Fehler (resultError).
  nyi,
}

// Gruppen der Ergebnisse; resultSuccess und resultPending sind Rückfall-Werte für Erweiterungen und Fehler im
// Code und werden heute nicht abgefragt.
final List<ParserResult> resultSuccess= [ParserResult.success, ParserResult.reconsume];
final List<ParserResult> resultError   = [ParserResult.error, ParserResult.errorReconsume, ParserResult.nyi];
final List<ParserResult> resultPending = [ParserResult.empty, ParserResult.waiting, ParserResult.ignore ,ParserResult.processing];

/// Beim Anlegen eines Callbacks wird der Erfolg zurückgegeben. Außer success und inuse sind es Rückfall-Werte für
/// Fehler im Code (falsches Kommando, falscher Parameter), die bei richtiger Grammatik nicht vorkommen.
enum ParserOnTokenResult {
  /// Der Callback wurde eingefügt
  success,
  /// Das übergebene Parser-Kommando gibt es nicht.
  nocmd,
  /// Den übergebene Parser-Parameter gibt es nicht.
  noparam,
  /// Für cmd,param gibt es schon einen Callback.
  ///
  /// Hinweis: Zum Ändern erst mit onToken(cmd,param,null) löschen.
  inuse,
  /// not yet implemented
  nyi,
}

/// zentrale Parserklasse
/// 
/// Ablauf:
/// - Der Parser nimmt die Eingabe entgegen, 
/// - generiert daraus mit Hilfe einer Grammatik Tokens,
/// - gibt  diese an vorher registierte Callbacks weiter
/// - und meldet dann das Ergebnis zurück.
/// Damit der Parser korrekt funktioniert braucht er
/// - Eine Grammatik bestehend aus SymbolListe und Übergangstabelle
/// - Registierte Callbacks die die Tokens entgegen nehmen.
/// - Einen Feeder, der die Zeichen oder Zeilen an den Parser übergibt  
/// Anmerkung: Die eigentlichen Aktionen und Ausgaben werden von den 
/// Callbacks durchgeführt. Das Parserergebnis gibt nur den aktuellen
/// Parsezustand wider. 
class Parser<T extends TokenBuilder> {
  late final Dea dea; // Diesmal late statt Factory Konstruktor wie beim Dea
  final T currentToken;
  final Map<String, String> fehlerTexte; // Texte zu den Fehlercodes von Dea und Grammatik
  /// Zeichen, die nicht von außen kommen dürfen, sondern nur per inject (z.B. ETX).
  Set<String> gesperrt = {};
  Map<String , ParserCallback<T>> actions = {};
  String charToReconsume = "";
  String tokenOutput = "";
  /// Position des Zeichens in der Zeile, bei dem feedLine einen Fehler erkannt hat (-1 = kein Fehler).
  ///
  /// Damit kann eine Oberfläche die Stelle markieren oder ein Programm mit dem Rest der Zeile weitermachen.
  int errorPosition = -1;
  /// Index des nächsten Zeichens in der Zeile, die mit taste() Zeichen für Zeichen eingegeben wird.
  int _position = 0;
  /// Die Zeile ist nach einem Fehler abgebrochen, weitere Zeichen bis zum Zeilenende werden ignoriert.
  bool _abgebrochen = false;
  /// Das letzte Zeichen war ein Zeilenende, das nächste beginnt eine neue Zeile.
  bool _zeileFertig = false;
  /// Text des noch nicht abgeschlossenen Tokens, ggf. mit führenden Trennern.
  String _offen = "";
  /// Beim letzten Fehler: Index des ersten Zeichens des fehlerhaften Tokens (-1 = kein Fehler).
  int fehlerStart = -1;
  /// Beim letzten Fehler: Text des fehlerhaften Tokens.
  String fehlerToken = "";
  /// Text, der beim Reparieren wieder geöffnet wird: das fehlerhafte Token ohne die auslösende Taste.
  String _wiederOffen = "";
  /// Gehört das gerade verarbeitete Zeichen bei einem Fehler noch zum Token? (nein, wenn es das Token nur beendet)
  bool _zeichenImToken = true;

  /// Erzeugung des Parsers mit Übergabe einer Grammatik und des passenden TokenBuilders.
  ///
  /// [fehler] enthält die Texte zu den Fehlercodes der Grammatik (z.B. "X6").
  Parser.fromGrammar(SymbolListe symbols, UebergangsTabelle grammar, this.currentToken, [Map<String, String> fehler = const {}])
      : fehlerTexte = {} {
    dea = Dea.init(symbols, grammar); // mit der Grammatik den Automaten erstellen
    fehlerTexte.addAll({...dea.fehlerTexte, ...fehler});
  }

  /// Einklinken von Callbacks um Aktionen durchzuführen.
  ///
  /// Ein Callback für "X" (oder z.B. "X6") ersetzt die Standard-Fehlerbehandlung.
  ParserOnTokenResult onToken(String command, String param, ParserCallback<T>? callback) {
    if (callback != null) {
      if (actions[command+param] != null) return ParserOnTokenResult.inuse;
      actions[command+param] = callback;
      return ParserOnTokenResult.success;
    } else {
      actions.remove(command+param);
      return ParserOnTokenResult.success;
    }
  } 
  

/// Setzt den Parser in den Grundzustand zurück.
  void reset() {
    dea.restart();  
    currentToken.reset();
    charToReconsume = "";
    tokenOutput = "";
    errorPosition = -1;
    fehlerStart = -1;
    fehlerToken = "";
    _position = 0;
    _abgebrochen = false;
    _zeileFertig = false;
    _offen = "";
  }

  /// Text des noch offenen Tokens ohne führende Trenner, "" wenn keins.
  String get offen => _ohneTrenner(_offen);

  static String _ohneTrenner(String s) => s.replaceFirst(RegExp(r'^[ _\n]+'), "");

  /// Enthält die Ausgabe des DEA (je zwei Zeichen Kommando und Parameter) das Kommando [cmd]?
  static bool _hatKommando(String deaOutput, String cmd) {
    for (int i = 0; i < deaOutput.length; i += 2) {
      if (deaOutput[i] == cmd) return true;
    }
    return false;
  }
  
  /// übergibt den Callback, wenn ein passender gefunden wurde.
  /// 
  /// Dabei kann command und/oder param weggelassen werden, um alle Elemente der Gruppe
  /// zu erfassen. "" ist ein Callback für alle Fälle
  /// Es wird immer nur der erste passende Callback gefunden.
  ParserCallback<T>? _action(String command, String param) {
    return  actions[command + param] ?? actions[command] ?? actions[param] ?? actions[""];
  }

  /// Ein Kommando des DEA verarbeiten: Grundkommandos selbst, alle anderen über den TokenBuilder.
  ParserResult _kommando(String zeichen, String cmd, String param) {
    switch (cmd) {
      case "*": currentToken.reset();
                return ParserResult.processing;
      case "?": return ParserResult.reconsume;
      case "_": return ParserResult.ignore;
      case "X": currentToken.errorCode = param;
                currentToken.errorMsg  = fehlerTexte["X$param"] ?? "Unbekannter Fehler X$param";
                ParserCallback<T>? callback = _action(cmd, param);
                return (callback == null) ? ParserResult.error : callback(currentToken, "X$param");
    }
    bool fertig = currentToken.verarbeite(zeichen, cmd, param);
    if (currentToken.inject.isNotEmpty) return ParserResult.inject;
    ParserCallback<T>? callback = _action(cmd, param);
    if (callback == null) {
      return fertig ? ParserResult.nyi : ParserResult.processing;
    }
    return callback(currentToken, currentToken.name);
  }

/// Ein Zeichen verarbeiten.  
  ParserResult feed(String zeichen) {
    ParserResult result = ParserResult.empty;
    if (zeichen == "") {
      zeichen = charToReconsume;
      charToReconsume = "";
    } else if (charToReconsume != "") {
      return ParserResult.errorReconsume;
    }
    if (zeichen == "") {
      return ParserResult.empty;
    }
    String vorher = _offen;
    _offen += zeichen;
    String deaOutput=dea.step(zeichen);
    String nachschieben = ""; // per inject verlangtes Zeichen, wird nach dieser Ausgabe verarbeitet
    // output verarbeiten. Dazu werden immer 2 Zeichen für Kommando und Parameter gelesen.
    for (int i = 0; i<deaOutput.length; i=i+2) {
      String cmd   = deaOutput[i];
      String param = deaOutput[i+1];
      ParserResult lastResult = result;
      result = _kommando(zeichen, cmd, param);
      // debugging: print("Parser feed: $result"); 
     
      switch (result) {
        case ParserResult.success:
          // debugging: print('Parser.feed: "${currentToken.anzeige}');
          if (tokenOutput != "") tokenOutput += "\t";
          tokenOutput += "$param‖${currentToken.anzeige}";
          _offen = "";
        case ParserResult.reconsume:
          charToReconsume = zeichen;
          _offen = ""; // das Zeichen wird gleich noch einmal verarbeitet und beginnt dann das nächste Token
        case ParserResult.ignore:
          result = lastResult;
        case ParserResult.inject:
          nachschieben = currentToken.inject;
          currentToken.inject = "";
          result = lastResult;
        case ParserResult.error:
          if (tokenOutput != "") tokenOutput += "\t";
          tokenOutput += "X‖${currentToken.errorCode}";
          // Dea zurücksetzen, damit die nächste Eingabe sauber beginnt.
          // Der Token bleibt erhalten, damit errorMsg noch gelesen werden kann.
          dea.restart();
          charToReconsume = "";
          // Ein "?" in der Ausgabe heißt: das Zeichen beendet das Token nur und gehört nicht dazu (z.B. "2" in "q2")
          _zeichenImToken = !_hatKommando(deaOutput, "?");
          String token = _ohneTrenner(vorher) + (_zeichenImToken ? zeichen : "");
          fehlerToken = token.isEmpty ? zeichen : token;
          _wiederOffen = _ohneTrenner(vorher);
          _offen = "";
          return result;
        default:
          break;
      }
    }
    // Erst wenn alle Kommandos dieses Zeichens erledigt sind, das nachgeschobene Zeichen verarbeiten
    if (nachschieben.isNotEmpty) {
      ParserResult r = feed(nachschieben);
      if (r != ParserResult.ignore && r != ParserResult.processing) result = r;
    }
    return result;
  }

  /// Beginnt eine neue Eingabezeile, ohne ein noch offenes Token (z.B. einen Code-Block) zu verwerfen.
  void neueZeile() {
    tokenOutput = "";
    errorPosition = -1;
    fehlerStart = -1;
    fehlerToken = "";
    _position = 0;
    _abgebrochen = false;
    _zeileFertig = false;
  }

  /// Ein Zeichen der Eingabezeile verarbeiten, einschließlich eines wiederholten Zeichens (reconsume).
  /// [i] ist die Position in der Zeile, für errorPosition.
  ParserResult _zeichen(String c, int i) {
    if (gesperrt.contains(c)) { // nur per inject erlaubt, nicht als Eingabe
      currentToken.errorCode = "Z";
      currentToken.errorMsg  = fehlerTexte["XZ"] ?? "Unbekanntes Zeichen";
      if (tokenOutput != "") tokenOutput += "\t";
      tokenOutput += "X‖Z";
      dea.restart();
      _wiederOffen = offen;
      _offen = "";
      errorPosition = i;
      fehlerStart = i;
      fehlerToken = c;
      return ParserResult.error;
    }
    ParserResult result = feed(c);
if (result == ParserResult.reconsume) {
      // Das wiederholte Zeichen kann selbst ein Token abschließen, das einen Fehler meldet (z.B. "1+")
      ParserResult r = feed("");
      if (resultError.contains(r)) result = r;
    }
    if (resultError.contains(result)) {
      errorPosition = i;
      // das fehlerhafte Token beginnt mit dem Text, der vor diesem Zeichen offen war
      fehlerStart = i - _wiederOffen.length;
      if (fehlerStart < 0) fehlerStart = 0; // z.B. ein Code-Block, der in einer früheren Zeile begann
    }
    return result;
  }

  /// Ein einzelnes Zeichen einer Zeile, die Zeichen für Zeichen eingegeben wird ("\n" schließt sie ab).
  /// Nach einem Fehler werden die Zeichen bis zum Zeilenende ignoriert.
  ParserResult taste(String c) {
    if (_zeileFertig) neueZeile(); // erst jetzt, damit tokenOutput und errorPosition lesbar bleiben
    int i = _position++;
    if (c == "\n") _zeileFertig = true;
    if (_abgebrochen) return ParserResult.ignore;
    ParserResult result = _zeichen(c, i);
    if (resultError.contains(result)) _abgebrochen = true;
    return result;
  }

  /// Das letzte Zeichen war ein Zeilenende, das nächste beginnt eine neue Zeile.
  bool get zeileFertig => _zeileFertig;

  /// Die Zeile ist nach einem Fehler abgebrochen.
  bool get abgebrochen => _abgebrochen;

  /// Nach einem Fehler stehen noch Tasten hinter der auslösenden Taste (sie wurden nie ausgeführt).
  bool get tastenNachFehler => _abgebrochen && _position > errorPosition + 1;

  /// Nimmt das letzte Zeichen des offenen Tokens zurück. Liefert false, wenn kein Token offen ist.
  /// Der DEA kann keinen Schritt zurück, deshalb wird das Token ohne das letzte Zeichen neu verarbeitet.
  bool zurueck() {
    if (_abgebrochen) return _reparieren();
    String token = offen;
    if (token.isEmpty) return false;
    String trenner = _offen.substring(0, _offen.length - token.length);
    dea.restart();
    currentToken.reset();
    charToReconsume = "";
    _offen = trenner;
    for (var c in token.substring(0, token.length - 1).split("")) {
      feed(c);
    }
    _position--;
    return true;
  }

  /// Löschen nach einem Fehler: erst die Tasten nach dem Fehler, dann die auslösende Taste.
  /// Danach ist das fehlerhafte Token wieder offen und die Sperre aufgehoben.
  bool _reparieren() {
    if (_position == 0) return false;
    _position--;
    if (_position > errorPosition) return true; // eine Taste nach dem Fehler, sie wurde nie ausgeführt
    dea.restart();
    currentToken.reset();
    charToReconsume = "";
    _offen = "";
    for (var c in _wiederOffen.split("")) {
      feed(c);
    }
    _abgebrochen = false;
    errorPosition = -1;
    fehlerStart = -1;
    fehlerToken = "";
    return true;
  }

  /// Nimmt ein Trennzeichen am Ende zurück, das kein Token geöffnet hat (z.B. ein vorgemerktes Enter).
  void zurueckTrenner() {
    if (_offen.isNotEmpty && offen.isEmpty) _offen = _offen.substring(0, _offen.length - 1);
    _position--;
  }

  /// liest eine ganze Zeile
  ParserResult feedLine(String line) {
    ParserResult result = ParserResult.empty;
    line += "\n";
    for (int i=0; i< line.length; i++) {
      ParserResult lastResult = result;
      result = _zeichen(line[i], i);
      if (result == ParserResult.ignore) {
        result = lastResult;
        continue;
      }
      if (resultError.contains(result)) return result;
    }
    return result; 
  }

}
