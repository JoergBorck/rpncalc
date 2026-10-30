import 'dea.dart';

const String zif     = "0123456789";
const String kbu     = "abcdefghijklmnopqrstuvwxyz";
const String gbu     = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const String ops     = "+*-/^%!<>=&²³°:"; // ":" übergibt den Tos an die Argumentliste des Calculators
const String tren    = " \n";
const String special = ".ê~|'{}_"; // "_" trennt Tokens, ohne selbst etwas zu tun

const SymbolListe rpnSymbols = [
  ("zif"            , zif),
  ("kbu"            , kbu),
  ("gbu"            , gbu),
  ("buc"            , kbu+gbu),
  ("bang"           , "!" ), // nur nach ' für '!!x; überall sonst gilt "!" als Operator (ops)
  ("ops"            , ops), 
  ("enter"          , " " ),
  ("nl"             , "\n"),
  ("tren"           , tren),
  ("tilde"          , "~" ),
  ("split"          , "|" ),
  ("quote"          , "'" ),
  ("exp"            , "ê" ),
  ("dot"            , "." ),
  ("code"           , "{" ),
  ("close"          , "}" ),
  ("etx"            , etx ),
  ("sep"            , "_" ),
  ("alle"           , zif + kbu + gbu + ops + tren + special),
];

/// Ende eines Code-Blocks: wird vom RpnToken nachgeschoben (inject), wenn die passende "}" erkannt ist.
/// Von außen ist das Zeichen nicht erlaubt (siehe rpnParser).
const String etx = "\x03";

/// Texte zu den Fehlercodes, die in rpnGramma verwendet werden.
const Map<String, String> rpnFehler = {
  "X1": "Ungültiges Zeichen am Token-Start",
  "X2": "Ziffer nach Dezimalpunkt erwartet",
  "X3": "Vorzeichen oder Ziffer für Exponent erwartet",
  "X4": "Ziffer für Exponent nach Vorzeichen fehlt",
  "X5": "Nach ~| muss ein Operator folgen",
  "X9": "Ungültiger Variablentyp (nacktes ')",
  "XA": "Bezeichner nach Variablen-Präfix fehlt",
  "XB": "Ungültiges Zeichen im Tag",
};

const UebergangsTabelle rpnGramma = {
('q0'              , 'tren'  ) :('q0'              , '*_!T____') , // Direktes Token-Ende bei Trenner
('q0'              , 'sep'   ) :('q0'              , '________') , // _ trennt nur, ohne Token
('q0'              , 'zif'   ) :('q_Int'           , '*_+z____') , // Start einer Ganzzahl / Real
('q0'              , 'dot'   ) :('q_Real_NoInt'    , '*_Sd____') , // Start Real ohne Vorkommazahl
('q0'              , 'kbu'   ) :('q_Name'          , '*_+n____') , // Start einer Funktion
('q0'              , 'gbu'   ) :('q0'              , '*_+n!B__') , // Ein nackter Befehl (einzelner Großbuchstabe)
('q0'              , 'tilde' ) :('q_Inv'           , '*_______') , // Start mit Invers-Präfix
('q0'              , 'split' ) :('q_Split'         , '*_______') , // Start mit Split-Präfix
('q0'              , 'quote' ) :('q_VarStart'      , '*_______') , // Start eines Variablen-Typs
('q0'              , 'ops'   ) :('q0'              , '*_+o!O__') , // Einfacher Operator (sofort fertig)
('q0'              , 'code'  ) :('q_Code'          , '*_S{____') , // Start eines Code-Blocks, äußere Klammer nicht im Puffer
('q0'              , 'alle'  ) :('q0'              , 'X1______') , // Ungültiges Zeichen am Token-Start
('q_Int'           , 'zif'   ) :('q_Int'           , '+z______') , // Weitere Ziffern der Ganzzahl
('q_Int'           , 'dot'   ) :('q_Real'          , 'Sd______') , // Wechsel zu Real-Zahl mit Vorkomma
('q_Int'           , 'exp'   ) :('q_ExpStart'      , 'Se______') , // Wechsel zum Exponenten
('q_Int'           , 'alle'  ) :('q0'              , '!Z?_____') , // Token fertig (integer)
('q_Real'          , 'zif'   ) :('q_Real'          , '+z______') , // Nachkommaziffern
('q_Real'          , 'exp'   ) :('q_ExpStart'      , 'Se______') , // Wechsel zum Exponenten
('q_Real'          , 'alle'  ) :('q0'              , '!Z?_____') , // Token fertig (real mit Vorkomma)
('q_Real_NoInt'    , 'zif'   ) :('q_Real'          , '+z______') , // Wechsel zu regulärem Real-Zustand
('q_Real_NoInt'    , 'alle'  ) :('q0'              , 'X2______') , // Ziffer nach Dezimalpunkt erwartet
('q_ExpStart'      , 'tilde' ) :('q_ExpSign'       , 'Sm______') , // Negatives Vorzeichen im Exponenten
('q_ExpStart'      , 'zif'   ) :('q_ExpFlanke'     , '+e______') , // Direkt Ziffern im Exponenten
('q_ExpStart'      , 'alle'  ) :('q0'              , 'X3______') , // Vorzeichen oder Ziffer für Exponent erwartet
('q_ExpSign'       , 'zif'   ) :('q_ExpFlanke'     , '+e______') , // Erste Ziffer nach Exponenten-Vorzeichen
('q_ExpSign'       , 'alle'  ) :('q0'              , 'X4______') , // Ziffer für Exponent nach Vorzeichen fehlt
('q_ExpFlanke'     , 'zif'   ) :('q_ExpFlanke'     , '+e______') , // Weitere Exponenten-Ziffern
('q_ExpFlanke'     , 'alle'  ) :('q0'              , '!Z?_____') , // Token fertig (Zahl mit Exponent)
('q_Name'          , 'kbu'   ) :('q_Name'          , '+n______') , // Teil des langen Namens
('q_Name'          , 'alle'  ) :('q0'              , '!F?_____') , // Token fertig (Funktion)
('q_Inv'           , 'tilde' ) :('q0'              , '+~+o!O__') , // Token fertig (~~)
('q_Inv'           , 'ops'   ) :('q0'              , '+~+o!O__') , // Token fertig (~op)
('q_Inv'           , 'split' ) :('q_InvSplit'      , '________') , // Sequenz ~| gelesen, noch unklar, wohin damit
('q_Inv'           , 'zif'   ) :('q_Int'           , 'Ss+z____') , // Negatives Vorzeichen einer Ganzzahl
('q_Inv'           , 'dot'   ) :('q_Real_NoInt'    , 'SsSd____') , // Negatives Vorzeichen einer Real-Zahl
('q_Inv'           , 'gbu'   ) :('q0'              , '+~+n!B__') , // Token fertig (~Befehl)
('q_Inv'           , 'kbu'   ) :('q_Name'          , '+~+n____') , // Wechsel zu Funktion mit ~-Präfix
('q_Inv'           , 'alle'  ) :('q0'              , '+~!O?___') , // Token fertig (Einzelne Tilde als Operator)
('q_InvSplit'      , 'ops'   ) :('q0'              , '+~+|+o!O') , // Token fertig (~|op)
('q_InvSplit'      , 'alle'  ) :('q0'              , 'X5______') , // Nach ~| muss ein Operator folgen
('q_Split'         , 'split' ) :('q0'              , '+|+o!O__') , // Token fertig (||)
('q_Split'         , 'ops'   ) :('q0'              , '+|+o!O__') , // Token fertig (|op)
('q_Split'         , 'alle'  ) :('q0'              , '+|!O?___') , // Token fertig (Einzelnes | als Operator)
('q_VarStart'      , 'zif'   ) :('q0'              , '+v!V____') , // Argument-Zugriff ('3), immer genau eine Ziffer
('q_VarStart'      , 'tilde' ) :('q_VarInv'        , '+v______') , // Variable mit Invers-Präfix (oder '~Befehl)
('q_VarStart'      , 'gbu'   ) :('q0'              , "+'+n!B__") , // Befehl mit Tags ('D, 'S, 'R, 'C)
('q_VarStart'      , 'bang'  ) :('q_VarBang'       , '+v______') , // Anlegen ('!x) oder Konstante ('!!x)
('q_VarStart'      , 'ops'   ) :('q_VarNormPref'   , '+v______') , // Variable mit Zuweisungs-Operator
('q_VarStart'      , 'split' ) :('q_TagSplit'      , '________') , // Start eines Stack-Tags ('|)
('q_VarStart'      , 'kbu'   ) :('q_VarNormIdent'  , '+v______') , // Direkter Variablenname mit Kleinbuchstabe
('q_VarStart'      , 'alle'  ) :('q0'              , 'X9______') , // Ungültiger Variablentyp (nacktes ')
('q_VarInv'        , 'kbu'   ) :('q_VarNormIdent'  , '+v______') , // Variable schreiben ('~x)
('q_VarInv'        , 'gbu'   ) :('q0'              , "+'+~!B__") , // Umkehrbefehl mit Tags ('~R)
('q_VarInv'        , 'alle'  ) :('q0'              , 'XA______') , // Bezeichner nach Variablen-Präfix fehlt
('q_VarBang'       , 'bang'  ) :('q_VarNormPref'   , '+v______') , // Konstante anlegen ('!!x)
('q_VarBang'       , 'kbu'   ) :('q_VarNormIdent'  , '+v______') , // Variable anlegen ('!x)
('q_VarBang'       , 'alle'  ) :('q0'              , 'XA______') , // Bezeichner nach Variablen-Präfix fehlt
('q_VarNormPref'   , 'kbu'   ) :('q_VarNormIdent'  , '+v______') , // Identifier nach dem Präfix
('q_VarNormPref'   , 'alle'  ) :('q0'              , 'XA______') , // Bezeichner nach Variablen-Präfix fehlt
('q_VarNormIdent'  , 'kbu'   ) :('q_VarNormIdent'  , '+v______') , // Verarbeitet langen Variablennamen
('q_VarNormIdent'  , 'alle'  ) :('q0'              , '!V?_____') , // Token fertig (Var_Normal)
('q_TagSplit'      , 'kbu'   ) :('q_TagIdent'      , 'St+v____') , // Direkt der Identifier des Tags ('|tmp)
('q_TagSplit'      , 'split' ) :('q_TagSchutz'     , '+v______') , // Tag mit Schreibschutz ('||tmp)
('q_TagSplit'      , 'alle'  ) :('q0'              , 'XB______') , // Ungültiges Zeichen im Tag
('q_TagSchutz'     , 'kbu'   ) :('q_TagIdent'      , 'St+v____') , // Identifier des geschützten Tags
('q_TagSchutz'     , 'alle'  ) :('q0'              , 'XB______') , // Ungültiges Zeichen im Tag
('q_TagIdent'      , 'kbu'   ) :('q_TagIdent'      , '+v______') , // Sammelt Rest des Tag-Identifiers
('q_TagIdent'      , 'alle'  ) :('q0'              , '!S?_____') , // Token fertig (Tag)
// Code-Blöcke: alle Zeichen landen im Code-Puffer, { und } zählt der RpnToken.
// Ist die passende } erkannt, schiebt der RpnToken ETX nach und der Block ist fertig.
// Blöcke sind immer anonym; einen Namen bekommen sie erst mit ':name.
('q_Code'          , 'code'  ) :('q_Code'          , 'S{+c____') , // innere { zählen und übernehmen
('q_Code'          , 'close' ) :('q_Code'          , 'C}+c____') , // } zählen; die letzte kommt nicht in den Puffer
('q_Code'          , 'etx'   ) :('q0'              , '!K______') , // Token fertig (Code)
('q_Code'          , 'alle'  ) :('q_Code'          , '+c______') , // alle anderen Zeichen inkl. Zeilenumbruch
('q_Code'          , 'sonst' ) :('q_Code'          , '+c______') , // auch Zeichen ohne Klasse (" , [ ] ä → …), z.B. JSON für rpnjson
};