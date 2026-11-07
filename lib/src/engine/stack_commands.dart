/// Aufgabe: die Stackbefehle als Mixin [StackBefehle] mit der Tabelle `befehle`: C, D, S, R, ~R, Y und X sowie
/// die Varianten mit ' ('C, 'D, 'S, 'R, '~R), die die Tags mitnehmen. Ohne ' bleiben die Tags an ihrer Adresse.
///
/// Abgrenzung: Die Grundoperationen auf dem Ringpuffer stehen in stack.dart, das Verschieben der Tags
/// (dropMitTags, swapMitTags, rotMitTags) in storage.dart. Die Befehle für den Code-Stack sind Funktionen
/// (functions.dart).
///
/// Siehe auch: doc/reference.md Kapitel 7 und 9.3, stack.dart, storage.dart.
library;

import 'core.dart';
import 'storage.dart';

/// Stack-Befehle. Ohne ' bleiben die Tags an ihrer Adresse, mit ' werden sie mitbehandelt.
/// Positionen zählen ab 0 (Tos).
mixin StackBefehle on Kern, Speicher {
  late final Map<String, Aktion> befehle = {
    "C"  : (a) { tags.isEmpty ? stack.clear() : error("tagC"); },
    "D"  : (a) { if (kannEntfernen(a.ganz(0, 1))) stack.drop(a.ganz(0, 1)); },   // n:D
    "S"  : (a) { int tgt = a.ganz(0, 1), src = a.ganz(1, 0), len = a.ganz(2, 1);  // tgt:src:len:S
                 if (kannAendern(tgt, len) && kannAendern(src, len)) stack.swap(tgt, src, len); },
    "R"  : (a) { int items = a.ganz(0, 3), offset = a.ganz(1, 0);                  // items:offset:R
                 if (kannAendern(offset, items)) stack.rot(false, items, offset); },
    "~R" : (a) { int items = a.ganz(0, 3), offset = a.ganz(1, 0);                  // items:offset:~R
                 if (kannAendern(offset, items)) stack.rot(true, items, offset); },
    "Y"  : (a) { kopieren(a.ganz(0, 1), a.ganz(1, 1)); },                         // quelle:anzahl:Y
    "X"  : (a) { String? c = codeStack.pull();                                      // obersten Code-Block ausführen
                 c == null ? error("code0", "für X") : codeAusfuehren("X", c, a); },
    "'C" : (a) { tags.clear(); tagsAktualisieren(); stack.clear(); },
    "'D" : (a) { dropMitTags(a.ganz(0, 1)); },
    "'S" : (a) { swapMitTags(a.ganz(0, 1), a.ganz(1, 0), a.ganz(2, 1)); },
    "'R" : (a) { rotMitTags(false, a.ganz(0, 3), a.ganz(1, 0)); },
    "'~R": (a) { rotMitTags(true,  a.ganz(0, 3), a.ganz(1, 0)); },
  };

  /// quelle:anzahl:Y kopiert [anzahl] Elemente ab Position [quelle] auf den Stack,
  /// die Reihenfolge bleibt erhalten. Y allein ist Over (1:1), 0:Y entspricht dup, 0:2:Y verdoppelt ein Paar.
  void kopieren(int quelle, int anzahl) {
    if (quelle < 0 || anzahl < 1 || quelle + anzahl > stack.tiefe) {
      error("tiefe", "der Stack hat ${stack.tiefe} Element(e)");
      return;
    }
    if (!kannAnlegen(anzahl)) return;
    var werte = [for (int i = quelle; i < quelle + anzahl; i++) stack[i]];
    for (var w in werte.reversed) {
      stack.push(w); // tiefstes zuerst, damit die Reihenfolge erhalten bleibt
    }
  }
}
