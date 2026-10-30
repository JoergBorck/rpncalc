import 'dart:math';

import 'gramma.dart';
import 'helper.dart';
import 'parser.dart';

/// Erzeugt einen Parser für die RPN-Grammatik.
Parser<RpnToken> rpnParser() => Parser.fromGrammar(rpnSymbols, rpnGramma, RpnToken(), rpnFehler)
    ..gesperrt = {etx}; // ETX beendet Code-Blöcke und darf nur per inject kommen

/// Baut die Tokens der RPN-Grammatik zusammen: Zahlen, Operatoren, Befehle, Funktionen,
/// Variablen, Tags und Trenner.
///
/// Kommandos der Grammatik (Parameter in Klammern):
///   +  an einen Puffer anhängen (z Ziffer, e Exponent, n Name, o Operator, v Variable, c Code, ~ | ' Präfix)
///   S  Flag setzen, C Flag löschen (s Vorzeichen, d Dezimalpunkt, e Exponent, m negativer Exponent, t Tag;
///      S{ und C} zählen die Klammern eines Code-Blocks, bei der passenden } wird ETX nachgeschoben)
///   !  Token fertig (Z Zahl, O Operator, B Befehl, F Funktion, V Variable, S Tag, T Trenner, K Code)
class RpnToken extends TokenBuilder {
  // Puffer für das Kommando +
  String praefixPuffer    = "";    // ~ | Präfixe, die erst etwas später zum Operator, Name, etc. angefügt werden.
  String matissensPuffer  = "";    // z Zahl
  String exponentenPuffer = "";    // e Exponent
  String namenPuffer      = "";    // n Name
  String operatorPuffer   = "";    // o Operator
  String variablenPuffer  = "";    // v Variable
  bool   isNegative       = false; // s Sign
  bool   isReal           = false; // d Dot
  bool   hasExponent      = false; // e Exponent
  bool   isNegExp         = false; // e Exponent
  bool   isTag            = false; // t Tag
  // Code-Blöcke
  String code             = "";    // c Inhalt des Blocks ohne die äußeren Klammern
  int    codeTiefe        = 0;     // Anzahl der offenen {; > 0 heißt: ein Block ist noch nicht abgeschlossen
  bool   _codeEnde        = false; // die letzte } wurde erkannt und kommt nicht in den Puffer
  // Ausgabe
  String _name    = "";
  String _anzeige = "";
  @override
  String get name => _name;
  @override
  String get anzeige => _anzeige;
  // Zahlenerzeugung: finale Nummer = vorzeichen * absNummer / skalierung * 10^exponent
  double absNummer  = 0; // Absolute Nummer
  double skalierung = 1; // Skalierung wird nach dot angepasst
  double exponent   = 0;
  double get number {
    return (isNegative?-1:1)*absNummer/skalierung
           * pow(10,(isNegExp?-1:1)*exponent);
  }

  void clearBuffers(){
    praefixPuffer    = "";
    matissensPuffer  = "";
    exponentenPuffer = "";
    namenPuffer      = "";
    operatorPuffer   = "";
    variablenPuffer  = "";
  }
  void clearFlags(){
    isNegative  = false;
    isReal      = false;
    hasExponent = false;
    isNegExp    = false;
    isTag       = false;
  }
  void clearNumber(){
    absNummer  = 0; // Absolute Nummer
    skalierung = 1; // Skalierung wird nach dot angepasst
    exponent   = 0;
  }

  @override
  void reset() {
    clearBuffers();
    clearFlags();
    clearNumber();
    code      = "";
    codeTiefe = 0;
    _codeEnde = false;
    _name     = "";
    _anzeige  = "";
    errorCode = "";
    errorMsg  = "";
    inject    = "";
  }

  @override
  bool verarbeite(String zeichen, String kommando, String parameter) {
    switch (kommando) {
      case "+": _append(zeichen, parameter);
      case "S": _flag(parameter, true);
      case "C": _flag(parameter, false);
      case "!": _emit(zeichen, parameter);
                return true;
      default : print("RpnToken.verarbeite: unbekanntes Kommando $kommando");
    }
    return false;
  }

  void _append(String zeichen, String param) {
    switch (param) {
      case "e":
        exponentenPuffer  += zeichen;
        exponent = 10*exponent + (int.tryParse(zeichen) ?? 0);
      case "n":
         namenPuffer   += zeichen;
      case "o":
        operatorPuffer += zeichen;
        _anzeige = praefixPuffer + operatorPuffer;
      case "v":
        variablenPuffer   += zeichen;
        _anzeige = variablenPuffer;
      case "z":
        matissensPuffer   += zeichen;
        absNummer = 10*absNummer + (int.tryParse(zeichen) ?? 0);
        if (isReal) skalierung *= 10;
        _anzeige = str(number);
      case "~":
        praefixPuffer += "~";
        _anzeige = praefixPuffer;
      case "|":
        praefixPuffer += "|";
        _anzeige = praefixPuffer;
      case "'": // Befehle mit Tags ('D, 'S ...)
        praefixPuffer += "'";
        _anzeige = praefixPuffer;
      case "c": // Code: die schließende } des Blocks selbst gehört nicht dazu
        if (_codeEnde) {
          _codeEnde = false;
        } else {
          code += zeichen;
        }
      default :
        print("RpnToken._append: unbekannter Parameter ($zeichen => $param)");
    }
  }

  void _emit(String zeichen, String param) {
    switch (param) {
      case "B": // Befehle
        _name = praefixPuffer + zeichen;
      case "F": // Funktionen
        _name = praefixPuffer + namenPuffer;
      case "O": // Operatoren
        _name = praefixPuffer + operatorPuffer;
      case "T": // Trenner: name enthält das echte Zeichen (" " oder "\n")
        _name = zeichen;
      case "V": // Variablen
        _name = variablenPuffer;
      case "S": // StackTag
        _name = variablenPuffer;
      case "Z": // Zahlen
        _name = str(number);
      case "K": // Code-Block: name bleibt leer, der Inhalt steht in code
        _name = "";
        _anzeige = "{${code.replaceAll("\n", r"\n")}}";
        return;
      default:
        _name = "unknown";
    }
    // anzeige ist nur die lesbare Form (Tests, tokenOutput): Trenner werden sichtbar dargestellt
    _anzeige = (_name == "\n") ? r"\n" :
               (_name == " " ) ? "_"   :
                                 _name;
  }

  void _flag(String param, bool state) {
    switch (param) {
      case "s": isNegative  = state; // s für sign
      case "d": isReal      = state; // d für dot
      case "e": hasExponent = state; // e für exponent
      case "m": isNegExp    = state; // m für Minus
      case "t": isTag       = state; // t für Tags
      case "{": codeTiefe++;           // S{ öffnende Klammer im Code
      case "}": codeTiefe--;           // C} schließende Klammer im Code
                if (codeTiefe == 0) {  // passende } gefunden: Ende des Blocks
                  _codeEnde = true;
                  inject = etx;
                }
      default : print("RpnToken._flag: unbekannter Parameter $param (${state?'S':'C'})");
    }
  }
}
