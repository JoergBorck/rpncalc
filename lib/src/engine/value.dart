/// Aufgabe: der Typ [Wert] für alles, was der Rechner speichert oder weitergibt: Stack, Variablen, Argumente.
///
/// Abgrenzung: Hier steht nur der Typ. Wie ein Wert angezeigt wird, steht in ../helper.dart, wie er in einem
/// Skript geschrieben wird, in session.dart.
///
/// Siehe auch: doc/reference.md 2.2 (Werte).
library;

/// Ein Wert auf dem Stack, in einer Variablen oder als Argument.
///
/// Vorerst eine Zahl. Später soll daraus eine Klasse für komplexere Typen werden
/// (z.B. Werte mit Einheit, Vektoren oder Code). Wer Werte speichert oder weitergibt,
/// sollte deshalb Wert statt num verwenden; nur dort, wo wirklich gerechnet wird, ist num gemeint.
typedef Wert = num;
