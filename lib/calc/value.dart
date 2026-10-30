/// Ein Wert auf dem Stack, in einer Variablen oder als Argument.
///
/// Vorerst eine Zahl. Später soll daraus eine Klasse für komplexere Typen werden
/// (z.B. Werte mit Einheit, Vektoren oder Code). Wer Werte speichert oder weitergibt,
/// sollte deshalb Wert statt num verwenden; nur dort, wo wirklich gerechnet wird, ist num gemeint.
typedef Wert = num;
