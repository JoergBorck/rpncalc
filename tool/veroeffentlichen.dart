/// Aufgabe: legt einen Stand des aktuellen `main` im öffentlichen Repository an, ohne die Ausschlüsse (z.B.
/// Kursmaterial). Die Stände liegen auf dem eigenen Zweig `oeffentlich`; jeder baut auf dem vorigen auf, so kommt
/// der Push ohne Überschreiben aus. Mit `--web` wird zusätzlich die App für den Browser gebaut und auf den Zweig
/// `gh-pages` gelegt; GitHub Pages zeigt sie dann unter https://joergborck.github.io/rpncalc/.
///
///   dart run tool/veroeffentlichen.dart                Stand anlegen, noch nicht pushen
///   dart run tool/veroeffentlichen.dart --push         Stand anlegen und ins öffentliche Repository pushen
///   dart run tool/veroeffentlichen.dart --web --push   dazu die Browser-Version bauen und pushen
///
/// Gate: Solange im Backlog (process/backlog.md) ein Eintrag mit dem Merkmal „· Gate“ offen ist oder einer unter
/// „Erforderlich“ steht, bricht es ab; ebenso, wenn CHANGELOG.md nicht zum Backlog passt (tool/changelog.dart).
///
/// Abgrenzung: Die Historie von `main` (mit allen Commits) bleibt im Akademie-Repository. CHANGELOG.md erzeugt
/// tool/changelog.dart, hier wird er nur geprüft. Die Windows-Version wird von Hand gebaut und hochgeladen.
///
/// Siehe auch: process/workflow.md (Veröffentlichen), tool/changelog.dart, process/backlog.md.
library;

import 'dart:convert';
import 'dart:io';

import 'changelog.dart' show changelog;

const ausschluesse = ["scratchpad", "spec"];
const backlog = "process/backlog.md";
const remote = "oeffentlich";
const adresse = "https://github.com/JoergBorck/rpncalc.git";
const zweig = "oeffentlich";
const webZweig = "gh-pages";
const webPfad = "/rpncalc/"; // Pages liegt unter dem Namen des Repositorys

void main(List<String> argumente) {
  final offen = erforderlich(File(backlog).readAsStringSync());
  if (offen.isNotEmpty) {
    stderr.writeln("Nicht veröffentlicht: im Backlog ist noch offen (Gate)");
    for (final e in offen) {
      stderr.writeln("  $e");
    }
    exit(1);
  }
  // CHANGELOG.md aus „Erledigt“ (DG-2): muss aktuell und in main committet sein, sonst fehlt er im Stand
  final log = changelog(File(backlog).readAsStringSync(), File("pubspec.yaml").readAsStringSync());
  if (log.fehler.isNotEmpty) {
    stderr.writeln("Nicht veröffentlicht: CHANGELOG.md lässt sich nicht erzeugen");
    for (final f in log.fehler) {
      stderr.writeln("  $f");
    }
    exit(1);
  }
  final show = Process.runSync("git", ["show", "main:CHANGELOG.md"], stdoutEncoding: utf8);
  final committet = show.exitCode == 0 ? (show.stdout as String).replaceAll("\r\n", "\n") : "";
  if (committet.trim() != log.text.trim()) {
    stderr.writeln("Nicht veröffentlicht: CHANGELOG.md ist nicht aktuell; dart run tool/changelog.dart, dann committen");
    exit(1);
  }
  final push = argumente.contains("--push");
  final web = argumente.contains("--web");
  final index = File("${git(["rev-parse", "--git-dir"])}/oeffentlich.index").absolute.path; // absolut, weil git für --web woanders läuft
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

    if (web) webStand(index);

    if (push) {
      if (!git(["remote"]).split("\n").contains(remote)) git(["remote", "add", remote, adresse]);
      git(["push", remote, "$zweig:main"]);
      if (web) git(["push", remote, "$webZweig:$webZweig"]);
      print("Gepusht nach $adresse");
    } else {
      print("Noch nicht gepusht; mit --push ins öffentliche Repository.");
    }
  } finally {
    final f = File(index);
    if (f.existsSync()) f.deleteSync();
  }
}

/// Baut die App für den Browser und legt das Ergebnis als neuen Commit auf den Zweig `gh-pages`, über einen
/// eigenen Index und mit dem Build-Verzeichnis als Arbeitskopie; die eigentliche Arbeitskopie bleibt unberührt.
void webStand(String index) {
  print("Baue die Browser-Version …");
  final r = Process.runSync("flutter", ["build", "web", "--release", "--base-href", webPfad],
      workingDirectory: "app", runInShell: true);
  if (r.exitCode != 0) {
    stderr.write(r.stdout);
    stderr.write(r.stderr);
    throw StateError("flutter build web ist fehlgeschlagen");
  }
  final verzeichnis = Directory("app/build/web").absolute.path;
  File("$verzeichnis/.nojekyll").writeAsStringSync(""); // Pages soll die Dateien unverändert ausliefern

  final umgebung = {"GIT_INDEX_FILE": index, "GIT_WORK_TREE": verzeichnis};
  git(["read-tree", "--empty"], umgebung: umgebung);
  git(["add", "-A", "-f", "."], umgebung: umgebung, verzeichnis: verzeichnis);
  final baum = git(["write-tree"], umgebung: umgebung);

  final vorher = git(["rev-parse", "--verify", "--quiet", "refs/heads/$webZweig"], darfFehlen: true);
  if (vorher.isNotEmpty && git(["rev-parse", "$vorher^{tree}"]) == baum) {
    print("Browser-Version unverändert.");
    return;
  }
  final quelle = git(["rev-parse", "--short", "main"]);
  final stand = git([
    "commit-tree", baum,
    if (vorher.isNotEmpty) ...["-p", vorher],
    "-m", "Browser-Version (main $quelle)",
  ]);
  git(["update-ref", "refs/heads/$webZweig", stand]);
  print("Browser-Version angelegt: ${stand.substring(0, 7)} auf dem Zweig $webZweig");
}

/// Führt git aus und liefert die Ausgabe ohne Zeilenende; bricht bei einem Fehler ab.
String git(List<String> argumente, {Map<String, String>? umgebung, String? verzeichnis, bool darfFehlen = false}) {
  final r = Process.runSync("git", argumente, environment: umgebung, workingDirectory: verzeichnis);
  if (r.exitCode != 0) {
    if (darfFehlen) return "";
    stderr.write(r.stderr);
    throw StateError("git ${argumente.first} ist fehlgeschlagen");
  }
  return (r.stdout as String).trim();
}

/// Die Titel der offenen Gate-Einträge des Backlogs: mit dem Merkmal „· Gate“ in einem Bereich außer „Erledigt“
/// und „Abgelehnt“, dazu alle unter „Erforderlich“.
List<String> erforderlich(String text) {
  final eintraege = <String>[];
  var bereich = "";
  String? titel;
  for (final zeile in const LineSplitter().convert(text)) {
    if (zeile.startsWith("## ")) bereich = zeile.substring(3).trim();
    final offen = bereich != "Erledigt" && bereich != "Abgelehnt" && !bereich.startsWith("Version");
    if (zeile.startsWith("### ")) {
      titel = zeile.substring(4).trim();
      if (bereich == "Erforderlich") eintraege.add(titel);
    } else if (titel != null && offen && bereich != "Erforderlich" && zeile.contains("· Gate")) {
      eintraege.add(titel); // die Merkmalszeile direkt unter dem Titel
    }
    if (!zeile.startsWith("### ")) titel = null;
  }
  return eintraege;
}
