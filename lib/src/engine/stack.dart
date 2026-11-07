/// Aufgabe: der Werte-Stack als Ringpuffer wie bei den HP-Rechnern. [Stack] bietet push, pull, drop, dup, swap
/// und rot mit Positionen ab 0 (Tos), den Füllstand (`tiefe`) und den Zugriff über Adressen im Ring. Er kennt
/// die Adressen der Tags (`geschuetzt`, `schreibgeschuetzt`) und meldet, ob ein Entfernen oder Anlegen sie
/// überfahren würde.
///
/// Abgrenzung: Die Namen der Tags und ihr Verschieben verwaltet storage.dart; ob eine Operation wegen eines Tags
/// abbricht, entscheidet der Kern (core.dart, `kannEntfernen`, `kannAnlegen`, `kannAendern`).
///
/// Siehe auch: doc/reference.md 2.1, 7 und 9, core.dart, stack_commands.dart.
library;

import '../helper.dart';
import 'value.dart';

/// Implementierung des Stacks als Ringpuffer.
///
/// Wie bei den originalen HP-Taschenrechnern gibt es keinen Unter- oder Überlauf: Ein leerer Platz liefert 0, ein
/// voller Ring überschreibt den ältesten Wert. Grenzen setzen nur die Tags (`blockiertEntfernen`,
/// `blockiertAnlegen`).
class Stack {
  int stacksize;
  final List<Wert> _stack;
  int _top = 0;
 
  Stack([this.stacksize=20]): 
    _stack = List<Wert>.filled(stacksize, 0.0, growable: false);

  int adr(int pos) {
    return (top + pos + stacksize)%stacksize;
  }

  /// Wert in Position pos vom Stack lesen
  /// 
  /// pos darf nicht negativ sein. Tos ist bei [0]
  Wert operator [](int pos) {
    return _stack[adr(pos)];
  } 

  /// Wert in Position pos vom Stack schreiben
  /// 
  /// pos darf nicht negativ sein. Tos ist bei [0]
  void operator []= (int pos, Wert val) {
    _stack[adr(pos)] = val;
  }

  int get top => _top;

  // Tags: Adressen im Ringpuffer, über die der Stack nicht hinwegfahren darf.
  // Der Stack kennt nur die Adressen, die Namen verwaltet der Calculator.
  Set<int> geschuetzt = {};
  // Zellen von Tags mit Schreibschutz ('||x): ihr Wert darf sich nur über den Namen ändern.
  Set<int> schreibgeschuetzt = {};

  /// Position (0 = Tos) einer Adresse im Ringpuffer.
  int position(int adresse) => (adresse - _top + stacksize) % stacksize;

  Wert wertAn(int adresse) => _stack[adresse];
  void setzeAn(int adresse, Wert wert) => _stack[adresse] = wert;

  /// Geschützte Adresse, die beim Entfernen von [n] Elementen überfahren würde, sonst null.
  int? blockiertEntfernen(int n) {
    for (int i=0; i<n; i++) {
      if (geschuetzt.contains(adr(i))) return adr(i);
    }
    return null;
  }

  /// Geschützte Adresse, die beim Anlegen von [n] Elementen überschrieben würde, sonst null.
  int? blockiertAnlegen(int n) {
    for (int i=1; i<=n; i++) {
      if (geschuetzt.contains(adr(-i))) return adr(-i);
    }
    return null;
  }

  /// Gibt den aktuellen Wert auf dem Top of Stack (ToS) zurück.
  Wert get tos => this[0];
  
  /// Setzt den aktuellen Wert auf dem Top of Stack (ToS).
  set tos(Wert neuerWert) => this[0] = neuerWert;
  
  Wert get x => this[0]; set x(Wert neuerWert) => this[0] = neuerWert;
  Wert get y => this[1]; set y(Wert neuerWert) => this[1] = neuerWert;
  Wert get z => this[2]; set z(Wert neuerWert) => this[2] = neuerWert;
  Wert get t => this[3]; set t(Wert neuerWert) => this[3] = neuerWert;

  // Füllstand: Anzahl der belegten Zellen. Beim Überlauf des Rings bleibt er bei stacksize,
  // beim Entfernen von einem leeren Stack bei 0 (dann werden wie beim HP Nullen geliefert).
  int _tiefe = 0;
  int get tiefe => _tiefe;

  /// Legt ein neues [element] auf den Stack.
   void push(Wert element) {
      _top = adr(-1);
      _stack[_top] = element;
      if (_tiefe < stacksize) _tiefe++;
  }

  /// Setzt die obersten [items] Zellen auf 0, ohne Angabe den ganzen Stack (dann ist er danach leer).
  void clear([int? items]) {
    if (items == null) _tiefe = 0;
    items = items ?? stacksize;
    for (int i=0; i<items;i++) {
      this[i]=0;
    }
  }

  /// Nimmt das oberste Element vom Stack
  Wert pull() {
    Wert wert = _stack[_top];
    drop();
    return wert;
  }

  /// Verwirft das oberste Element des Stacks, ohne es zurückzugeben.
  void drop([int items=1]) {
    items.times(() {
      _stack[_top] = 0.0;
      _top = adr(1);
      if (_tiefe > 0) _tiefe--;
    });
  }

  /// Dupliziert das oberste Element (ToS) und legt es erneut auf den Stack.
  void dup() => push(tos);

  /// Vertauscht [len] Elemente ab Position [src] mit [len] Elementen ab Position [tgt].
  ///
  /// Positionen zählen ab 0 (Tos). Ohne Parameter werden die beiden obersten Elemente getauscht.
  void swap([int tgt=1, int src=0, int len=1]) {
    if (tgt < 0 || src < 0) return;
    for (int i=0; i<len; i++) {
      Wert t = this[src+i];
      this[src+i] = this[tgt+i];
      this[tgt+i] = t;
    }
  }

  /// Rotiert [items] Elemente auf dem Stack, beginnend [offset] Elemente unter dem Tos.
  ///
  /// up bestimmt die Richtung (Beispiel mit items=3, offset=0):
  /// False: Das 3. Element kommt in den Tos, 1. und 2. wandern nach unten.
  /// True : Der Tos kommt an 3. Stelle, das 2. und 3. Element wandern nach oben.
  void rot([bool up=false, int items=3, int offset=0]) {
    if (items < 1 || offset < 0) return;
    if (up) {
      Wert t = this[offset];                         //    down           up
      for (int i=offset; i<offset+items-1; i++) {   // tos => [1]    tos => [2]
        this[i] = this[i+1];                        // [1] => [2]    [1] => tos
      }                                             // [2] => tos    [2] => [1]
      this[offset+items-1] = t;
   } else {
      Wert t = this[offset+items-1];
      for (int i=offset+items-1; i>offset; i--) {
        this[i] = this[i-1];
      }
      this[offset] = t;
    }
  }

 
  /// Gibt den aktuellen ToS formatiert als String über die Hilfsfunktion [str] aus.
  String ausgabe() { return str(tos); }

  String show([int items=0]) {
    String output = "Stack: ...";
    if (items == 0) { items = stacksize; }
    String sep="";
    for (int i=items-1; i>=0; i--) {
      output += "$sep[${str(this[i])}]";
      sep=" ";
    }
    output += "<tos";
    return output;
  }


}