/// Aufgabe: die Argumente, die der Operator ":" vom Stack an den nächsten Identifier übergibt.
/// [ArgumentListe] sammelt sie, bis eine Funktion, ein Befehl, eine Variable oder ein Tag sie verbraucht;
/// [Argumente] sind die verbrauchten, mit Zugriff samt Standardwert (`ganz`, `zahl`).
///
/// Abgrenzung: Der Operator ":" selbst und die Argumente im Code einer eigenen Funktion (~:, ~|:, |:) stehen in
/// operators.dart; wann ein Token Argumente nimmt oder zurücklegt, regelt calculator.dart.
///
/// Siehe auch: doc/reference.md Kapitel 5 und 10.3, operators.dart.
library;

import 'value.dart';

/// Die mit ":" übergebenen Argumente, die ein Identifier verbraucht hat.
class Argumente {
  final List<Wert> _liste;
  const Argumente(this._liste);

  int get length => _liste.length;
  bool get isEmpty => _liste.isEmpty;
  Wert operator [](int i) => _liste[i];

  /// Kopie der Argumente, z.B. als Argumentliste für den Aufruf einer eigenen Funktion.
  List<Wert> get liste => List.of(_liste);

  /// Argument [i] als ganze Zahl oder [standard], wenn es nicht übergeben wurde.
  int ganz(int i, int standard) => (i < _liste.length) ? _liste[i].toInt() : standard;

  /// Argument [i] als Wert (z.B. eine Basis wie 2.5) oder [standard].
  Wert zahl(int i, Wert standard) => (i < _liste.length) ? _liste[i] : standard;
}

/// Sammelt die Argumente, die ":" vom Stack holt, bis ein Identifier sie verbraucht.
class ArgumentListe {
  List<Wert> _offen = [];

  /// Die noch nicht verbrauchten Argumente, z.B. für die Anzeige.
  List<Wert> get offen => List.unmodifiable(_offen);

  void add(Wert w) => _offen.add(w);

  /// Übergibt alle Argumente an den Identifier und leert die Liste.
  Argumente nimm() {
    Argumente a = Argumente(_offen);
    _offen = [];
    return a;
  }

  /// Legt Argumente zurück, z.B. wenn der Identifier, der sie genommen hat, mit einem Fehler abbricht.
  void zuruecklegen(List<Wert> werte) => _offen = List.of(werte);

  void reset() => _offen = [];
}
