import 'dart:io';

/// Legt einen Stand des aktuellen `main` im öffentlichen Repository an, ohne die Ausschlüsse (z.B. Kursmaterial).
///
/// Die Stände liegen auf dem eigenen Zweig `oeffentlich`; jeder baut auf dem vorigen auf, so kommt der Push ohne
/// Überschreiben aus. Die Historie von `main` (mit allen Commits) bleibt im Akademie-Repository.
///
///   dart run tool/veroeffentlichen.dart          Stand anlegen, noch nicht pushen
///   dart run tool/veroeffentlichen.dart --push   Stand anlegen und ins öffentliche Repository pushen
const ausschluesse = ["scratchpad", "spec"];
const remote = "oeffentlich";
const adresse = "https://github.com/JoergBorck/rpncalc.git";
const zweig = "oeffentlich";

void main(List<String> argumente) {
  final push = argumente.contains("--push");
  final index = "${git(["rev-parse", "--git-dir"])}/oeffentlich.index";
  final umgebung = {"GIT_INDEX_FILE": index};
  try {
    // der Inhalt von main ohne die Ausschlüsse, in einem eigenen Index, damit die Arbeitskopie unberührt bleibt
    git(["read-tree", "main"], umgebung: umgebung);
    git(["rm", "-r", "--cached", "--quiet", "--ignore-unmatch", ...ausschluesse], umgebung: umgebung);
    final baum = git(["write-tree"], umgebung: umgebung);

    final vorher = git(["rev-parse", "--verify", "--quiet", "refs/heads/$zweig"], darfFehlen: true);
    if (vorher.isNotEmpty && git(["rev-parse", "$vorher^{tree}"]) == baum) {
      print("Keine Änderungen seit dem letzten Stand.");
    } else {
      final heute = DateTime.now();
      final datum = "${heute.day.toString().padLeft(2, "0")}.${heute.month.toString().padLeft(2, "0")}.${heute.year}";
      final quelle = git(["rev-parse", "--short", "main"]);
      final stand = git([
        "commit-tree", baum,
        if (vorher.isNotEmpty) ...["-p", vorher],
        "-m", "Stand vom $datum (main $quelle)",
      ]);
      git(["update-ref", "refs/heads/$zweig", stand]);
      print("Stand angelegt: ${stand.substring(0, 7)} auf dem Zweig $zweig");
    }

    if (push) {
      if (!git(["remote"]).split("\n").contains(remote)) git(["remote", "add", remote, adresse]);
      git(["push", remote, "$zweig:main"]);
      print("Gepusht nach $adresse");
    } else {
      print("Noch nicht gepusht; mit --push ins öffentliche Repository.");
    }
  } finally {
    final f = File(index);
    if (f.existsSync()) f.deleteSync();
  }
}

/// Führt git aus und liefert die Ausgabe ohne Zeilenende; bricht bei einem Fehler ab.
String git(List<String> argumente, {Map<String, String>? umgebung, bool darfFehlen = false}) {
  final r = Process.runSync("git", argumente, environment: umgebung);
  if (r.exitCode != 0) {
    if (darfFehlen) return "";
    stderr.write(r.stderr);
    throw StateError("git ${argumente.first} ist fehlgeschlagen");
  }
  return (r.stdout as String).trim();
}
