/// Aufgabe: Einblick für Tests, die hinter die Tür schauen. [apiMitEinblick] baut eine RpnApi um einen eigenen
/// Interpreter; über [Einblick] kommen Tests dann an `api.calculator` und `api.parser`.
///
/// Abgrenzung: Nur für test/; Oberflächen sehen den Interpreter nicht (RpnApi.mit ist für Tests und Werkzeuge).
///
/// Siehe auch: lib/rpnapi.dart, lib/src/engine/interpreter.dart, doc/architecture.md 5.
library;

import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc/src/engine/calculator.dart';
import 'package:rpncalc/src/engine/interpreter.dart';
import 'package:rpncalc/src/language/parser.dart';
import 'package:rpncalc/src/language/token.dart';

final _interpreter = Expando<Interpreter>();

/// Eine RpnApi, deren Interpreter die Tests über [Einblick] erreichen.
RpnApi apiMitEinblick() {
  final i = Interpreter();
  final api = RpnApi.mit(i);
  _interpreter[api] = i;
  return api;
}

extension Einblick on RpnApi {
  Interpreter get _i => _interpreter[this] ?? (throw StateError("Die RpnApi kommt nicht aus apiMitEinblick()"));
  Calculator get calculator => _i.calculator;
  Parser<RpnToken> get parser => _i.parser;
}
