/// Aufgabe: die Version des Rechners ([rechnerVersion]) und der Vergleich mit der Version, die eine Bibliothek
/// verlangt ([versionPasst]).
///
/// Abgrenzung: Die Version einer Bibliothek steht in ihrem version-Eintrag (`rpnjson`); geprüft wird sie beim
/// Laden in engine/functions.dart. Die RpnApi gibt die Version als `RpnApi.version` weiter.
///
/// Siehe auch: doc/reference.md 10.5, doc/api.md 9.1, pubspec.yaml, test/libraries_test.dart.
library;

/// Version des Rechners nach dem Schema MAJOR.MINOR.PATCH, wie in pubspec.yaml (ein Test prüft das).
/// Bibliotheken nennen in `rpnjson` die Version, die sie mindestens brauchen (doc/reference.md 10.5).
const String rechnerVersion = "0.3.0";

/// Ob die vorhandene Version [vorhanden] die verlangte Version [verlangt] erfüllt: MAJOR gleich, MINOR.PATCH
/// mindestens so hoch. null, wenn eine der beiden keine gültige Versionsangabe ist.
bool? versionPasst(String vorhanden, String verlangt) {
  final v = _teile(vorhanden), n = _teile(verlangt);
  if (v == null || n == null) return null;
  if (v[0] != n[0]) return false;
  return v[1] > n[1] || (v[1] == n[1] && v[2] >= n[2]);
}

List<int>? _teile(String version) {
  final m = RegExp(r"^(\d+)\.(\d+)\.(\d+)$").firstMatch(version.trim());
  return m == null ? null : [for (int i = 1; i <= 3; i++) int.parse(m[i]!)];
}
