import 'dart:math' as math;

import '../helper.dart';
import 'core.dart';
import 'functions.dart';
import 'value.dart';

/// Operatoren. Sie verbrauchen keine Argumente.
/// Baut auf den Funktionen auf, weil ° und ~° den Winkelmodus brauchen.
mixin Operatoren on Kern, Funktionen {
  late final Map<String, Aktion> operatoren = {
    "+"  : (a) { ops=2; result(x+y); },
    "-"  : (a) { ops=2; result(x-y); },
    "*"  : (a) { ops=2; result(x*y); },
    "/"  : (a) { ops=2; result(x/y); },
    "|/" : (a) { ops=2; not0("div0",y) ?? nan("NaN",x,y) ?? result(x~/y,x%y); },
    "^"  : (a) { ops=2; result(math.pow(x, y)); },
    "!"  : (a) { ops=1; result(fakultaet(x)); },
    "²"  : (a) { ops=1; result(x*x); },
    "³"  : (a) { ops=1; result(x*x*x); },
    "|"  : (a) { ops=1; y=intPart(x); result(y, x - y); },
    "||" : (a) { ops=1; result(x.abs()); },
    "~"  : (a) { if (kannAendern(0, 1)) stack.tos = - stack.tos; }, // ändert den Tos in seiner Zelle
    "~/" : (a) { ops=1; result(1/x); },
    "~^" : (a) { ops=2; result(math.pow(x,1/y)); },  // alg. Wurzel
    "~²" : (a) { ops=1; result(math.sqrt(x)); },     // Quadratwurzel
    "~³" : (a) { ops=1; result(math.pow(x,1/3)); },  // 3. Wurzel
    // Prozentrechnung
    "%"  : (a) { ops=2; result(x, x*y/100); },                // x % von y
    "~%" : (a) { ops=2; result(x, x*100/y); },                // Basiswert: wenn x = y%, was sind dann 100%
    "|%" : (a) { ops=2; y=y/100; result(x*(1-y),x*y); },      // Vorwärts-Split: (x*(1-y/100), x*y/100)
    "~|%": (a) { ops=2; y=x/(1+y/100); result(y,x-y); },      // Rückwärts-Split: (x/(1+y/100), x-x')
    // Koordinaten: x y ° -> r φ (kartesisch nach polar), r φ ~° -> x y; φ im eingestellten Winkelmodus
    "°"  : (a) { ops=2; result(math.sqrt(x*x + y*y), angle(math.atan2(y, x), true)); },
    "~°" : (a) { ops=2; result(x * cosinus(y), x * sinus(y)); },
    // Vergleiche: liefern 1 (wahr) oder 0 (falsch); ~ kehrt den Vergleich um
    "<"  : (a) { ops=2; result(_wahr(x <  y)); },
    ">"  : (a) { ops=2; result(_wahr(x >  y)); },
    "="  : (a) { ops=2; result(_wahr(x == y)); },
    "~<" : (a) { ops=2; result(_wahr(x >= y)); },
    "~>" : (a) { ops=2; result(_wahr(x <= y)); },
    "~=" : (a) { ops=2; result(_wahr(x != y)); },
    // dieselben Vergleiche als Zeichen, besser lesbar (doc/reference.md 4)
    "≤"  : (a) { ops=2; result(_wahr(x <= y)); },
    "≥"  : (a) { ops=2; result(_wahr(x >= y)); },
    "≠"  : (a) { ops=2; result(_wahr(x != y)); },
    // Logik auf Wahrheitswerten (0 = falsch, alles andere wahr), nicht bitweise
    "&"  : (a) { ops=2; result(_wahr(x != 0 && y != 0)); },  // und
    "~&" : (a) { ops=2; result(_wahr(x != 0 || y != 0)); },  // oder
    // Argumente
    ":"  : (a) { if (kannEntfernen(1)) args.add(stack.pull()); }, // Tos an die Argumentliste übergeben
    // Argumente im Code einer eigenen Funktion, von vorn nach hinten
    "~:" : (a) { var l = _aufruf(); if (l == null) return;
                 if (l.isEmpty) { error("arg0"); return; }
                 if (kannAnlegen(1)) stack.push(l.removeAt(0)); },                 // nächstes Argument
    "~|:": (a) { var l = _aufruf(); if (l == null) return;
                 if (kannAnlegen(l.length)) l.forEach(stack.push); },             // alle übrigen Argumente, bleiben in der Liste
    "|:" : (a) { var l = _aufruf(); if (l == null) return;
                 if (kannAnlegen(1)) stack.push(l.length); },                      // Anzahl der übrigen Argumente
  };

  static Wert _wahr(bool b) => b ? 1 : 0;

  /// Argumentliste des innersten Aufrufs einer eigenen Funktion, oder ein Fehler außerhalb davon.
  List<Wert>? _aufruf() {
    if (aufrufArgumente.isEmpty) {
      error("argAus");
      return null;
    }
    return aufrufArgumente.last;
  }
}
