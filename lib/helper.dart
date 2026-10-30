import 'dart:math' as math;

String str(num value) {
  // 1. Auf 12 Stellen runden, um Fließkommafehler zu killen
  // 2. Parsen säubert automatisch alle "0.300000" zu "0.3"
  // und behält gleichzeitig die korrekte E-Notation bei großen Zahlen!
  num gerundet = num.parse(value.toStringAsFixed(12));
  // 3. Kleine Zahlen wie 4.1e-19 würden dabei zu 0. Dann statt dessen 12 gültige Stellen mit Exponent.
  if (gerundet == 0 && value != 0) return num.parse(value.toStringAsPrecision(12)).toString();
  return gerundet.toString();
}

/// Zahl für die Anzeige: wie str(), aber ganze Zahlen ohne ".0".
String zahl(num w) => str(w).replaceAll(RegExp(r"\.0$"), "");


extension TimesExtension on int {
  // Definiert die .times() Methode für alle Integers
  void times(void Function() action) {
    for (int i = 0; i < this; i++) {
      action();
    }
  }
}

num fakultaet(num n) => ((int i) => (i<=0)?1:i*fakultaet(i-1))(n.truncate());

num round(num value, int digits) => double.parse(value.toStringAsFixed(digits));

/// Rundet [x] auf [stellen] Nachkommastellen (negativ: auf Zehner, Hunderter ...) nach der Rundungsart [art]:
///  0 kaufmännisch,  1 aufrunden (Richtung +∞),       -1 abrunden (Richtung −∞),
///  2 bei ,5 auf gerade Ziffer,                       -2 bei ,5 auf ungerade Ziffer,
///  3 vom Nullpunkt weg,                              -3 zum Nullpunkt hin (abschneiden).
/// Liefert null bei einer unbekannten Art.
num? runden(num x, int stellen, int art) {
  if (x.isNaN || x.isInfinite) return x;
  num f = math.pow(10, stellen.abs());
  num y = round(stellen >= 0 ? x * f : x / f, 9); // Fließkommafehler wie 2.675*100 = 267.4999... beseitigen
  num betrag = y.abs();
  int unten = betrag.floor();
  num rest = betrag - unten;
  num r;
  switch (art) {
    case  0: r = y.sign * (rest >= 0.5 ? unten + 1 : unten);
    case  1: r = y.ceil();
    case -1: r = y.floor();
    case  2: r = y.sign * ((rest > 0.5 || (rest == 0.5 && unten.isOdd))  ? unten + 1 : unten);
    case -2: r = y.sign * ((rest > 0.5 || (rest == 0.5 && unten.isEven)) ? unten + 1 : unten);
    case  3: r = y.sign * betrag.ceil();
    case -3: r = y.truncate();
    default: return null;
  }
  return stellen >= 0 ? r / f : r * f;
}

num intPart(num x) {
  // Wenn der Wert ungültig oder unendlich ist, das Abschneiden verhindern
  if (x.isNaN || x.isInfinite) {
    return x; // Gibt NaN oder Infinity unverändert zurück, damit der Stack valide bleibt
  }
  return x.truncate();
}

