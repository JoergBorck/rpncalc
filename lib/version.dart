/// Version des Rechners nach dem Schema MAJOR.MINOR.PATCH, wie in pubspec.yaml (ein Test prüft das).
/// Bibliotheken nennen in `rpnjson` die Version, die sie mindestens brauchen (doc/reference.md 10.5).
const String rechnerVersion = "0.2.0";

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
