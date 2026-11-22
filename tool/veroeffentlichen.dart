/// Aufgabe: legt einen Stand des aktuellen `main` im öffentlichen Repository an, ohne die Ausschlüsse (z.B.
/// Kursmaterial). Die Stände liegen auf dem eigenen Zweig `oeffentlich`; jeder baut auf dem vorigen auf, so kommt
/// der Push ohne Überschreiben aus. Mit `--web` wird zusätzlich die App für den Browser gebaut und auf den Zweig
/// `gh-pages` gelegt; GitHub Pages zeigt sie dann unter https://joergborck.github.io/rpncalc/.
///
///   dart run tool/veroeffentlichen.dart                Stand anlegen, noch nicht pushen
///   dart run tool/veroeffentlichen.dart --push         Stand anlegen und ins öffentliche Repository pushen
///   dart run tool/veroeffentlichen.dart --web --push   dazu die Browser-Version bauen und pushen
///   dart run tool/veroeffentlichen.dart --exe --push   dazu die Windows-Version bauen und als Release hochladen
///
/// Mit `--exe` (PT-1) entsteht nach dem Push das Pre-release `v<version>` auf JoergBorck/rpncalc mit
/// `rpncalc-<version>-windows.zip`; Titel und Highlights stehen in process/done.md unter „### Version x.y.z“, die
/// übrigen Zeilen kommen aus CHANGELOG.md. Gibt es das Release schon, werden Datei, Titel und Text ersetzt. Braucht
/// die GitHub CLI (`gh`, angemeldet).
///
/// Gate: Solange im Backlog (process/backlog.md) ein Eintrag mit dem Merkmal „· Gate“ offen ist oder einer unter
/// „Erforderlich“ steht, bricht es ab; ebenso, wenn CHANGELOG.md nicht zum Backlog passt (tool/changelog.dart).
///
/// Abgrenzung: Die Historie von `main` (mit allen Commits) bleibt im Akademie-Repository. CHANGELOG.md erzeugt
/// tool/changelog.dart, hier wird er nur geprüft. Highlights schreibt kein Werkzeug, sie stehen von Hand in done.md.
///
/// Siehe auch: process/workflow.md (Veröffentlichen), tool/changelog.dart, process/backlog.md,
/// process/requirements/PT-1.md.
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
const releaseRepo = "JoergBorck/rpncalc";
const pagesAdresse = "https://joergborck.github.io/rpncalc/";
const ghStandard = r"C:\Program Files\GitHub CLI\gh.exe";

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
  final log = changelog(File("process/done.md").readAsStringSync(), File("pubspec.yaml").readAsStringSync());
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
  // --exe prüft alles vor dem Stand, damit nichts halb veröffentlicht wird (PT-1)
  ({String version, String titel, String text, String gh})? release;
  if (argumente.contains("--exe")) {
    Never abbruch(String grund) {
      stderr.writeln("Nicht veröffentlicht: $grund");
      exit(1);
    }
    if (!push) abbruch("--exe braucht --push, das Release zeigt auf den Stand im öffentlichen Repository");
    if (!Platform.isWindows) abbruch("--exe baut die Windows-Version und geht nur unter Windows");
    final gh = ghPfad() ?? abbruch("GitHub CLI fehlt oder ist nicht angemeldet; winget install GitHub.cli, dann gh auth login");
    final version = RegExp(r"^version:\s*(\S+)", multiLine: true).firstMatch(File("pubspec.yaml").readAsStringSync())![1]!;
    final r = releaseText(File("process/done.md").readAsStringSync(), log.text, version);
    if (r.fehler.isNotEmpty) abbruch("--exe: ${r.fehler.join("; ")}");
    release = (version: version, titel: r.titel, text: r.text, gh: gh);
  }
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
      if (release != null) windowsRelease(release, git(["rev-parse", "refs/heads/$zweig"]));
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

/// Baut die Windows-Version, packt sie und legt das Release `v<version>` an oder ersetzt Datei, Titel und Text.
void windowsRelease(({String version, String titel, String text, String gh}) r, String ziel) {
  void lauf(String programm, List<String> argumente, {String? verzeichnis, bool shell = false}) {
    final p = Process.runSync(programm, argumente, workingDirectory: verzeichnis, runInShell: shell);
    if (p.exitCode != 0) {
      stderr.write(p.stdout);
      stderr.write(p.stderr);
      throw StateError("$programm ${argumente.first} ist fehlgeschlagen");
    }
  }

  print("Baue die Windows-Version …");
  lauf("flutter", ["build", "windows", "--release"], verzeichnis: "app", shell: true);
  final ordner = Directory("app/build/windows/x64/runner/Release").absolute;
  final zip = File("app/build/rpncalc-${r.version}-windows.zip").absolute;
  if (zip.existsSync()) zip.deleteSync();
  // die Dateien ohne Ordner darüber, wie v0.3.0; tar von Windows (nicht das von Git) packt mit -a als Zip
  final tar = "${Platform.environment["SystemRoot"] ?? r"C:\Windows"}\\System32\\tar.exe";
  final inhalt = [for (final e in ordner.listSync()) e.path.substring(ordner.path.length + 1)];
  lauf(tar, ["-a", "-c", "-f", zip.path, "-C", ordner.path, ...inhalt]);
  print("Gepackt: ${zip.path}");

  final notizen = File("app/build/release-notes.md").absolute..writeAsStringSync(r.text);
  final tag = "v${r.version}";
  final vorhanden = Process.runSync(r.gh, ["release", "view", tag, "--repo", releaseRepo]).exitCode == 0;
  if (vorhanden) {
    lauf(r.gh, ["release", "upload", tag, zip.path, "--clobber", "--repo", releaseRepo]);
    lauf(r.gh, ["release", "edit", tag, "--title", r.titel, "--notes-file", notizen.path, "--prerelease", "--repo", releaseRepo]);
    print("Release $tag ersetzt: https://github.com/$releaseRepo/releases/tag/$tag");
  } else {
    lauf(r.gh, ["release", "create", tag, zip.path, "--repo", releaseRepo, "--target", ziel, "--prerelease",
        "--title", r.titel, "--notes-file", notizen.path]);
    print("Release $tag angelegt: https://github.com/$releaseRepo/releases/tag/$tag");
  }
}

/// Der Pfad der GitHub CLI, wenn sie da und angemeldet ist: im PATH, sonst am Ort der Installation.
String? ghPfad() {
  for (final gh in ["gh", ghStandard]) {
    try {
      if (Process.runSync(gh, ["auth", "status"]).exitCode == 0) return gh;
    } on ProcessException {
      // nicht da, nächster Ort
    }
  }
  return null;
}

/// Titel und Text des Releases (PT-1): Kurzfassung und Highlights aus done.md unter „### Version x.y.z“, die
/// Zeilen der Version aus CHANGELOG.md, dazu der Abschnitt Download; dazu, was dagegen spricht.
({String titel, String text, List<String> fehler}) releaseText(String done, String changelogText, String version) {
  final fehler = <String>[];
  done = done.replaceAll("\r\n", "\n");
  final naechste = done.indexOf("\n### Nächste Version\n");
  if (naechste >= 0) {
    final danach = done.indexOf("\n### ", naechste + 1);
    if (danach >= 0 && !done.startsWith("\n### Version ", danach)) {
      fehler.add("unter „### Nächste Version“ steht noch Erledigtes, erst die Version erhöhen");
    }
  }
  var kurz = "", punkte = "";
  final kopf = "\n### Version $version\n";
  final start = done.indexOf(kopf);
  if (start < 0) {
    fehler.add("keine Überschrift „### Version $version“ in done.md");
  } else {
    final ende = done.indexOf("\n### ", start + 1);
    final zeilen = done.substring(start + kopf.length, ende < 0 ? done.length : ende).trim().split("\n");
    kurz = zeilen.first.trim();
    punkte = zeilen.skip(1).join("\n").trim();
    if (kurz.isEmpty || punkte.isEmpty) fehler.add("unter „### Version $version“ fehlen Kurzfassung und Highlights");
  }
  final log = changelogText.replaceAll("\r\n", "\n");
  final kapitel = "\n## $version\n";
  final abschnitt = log.indexOf(kapitel);
  var aenderungen = "";
  if (abschnitt < 0) {
    fehler.add("keine Version $version in CHANGELOG.md");
  } else {
    final ende = log.indexOf("\n## ", abschnitt + 1);
    aenderungen = log.substring(abschnitt + kapitel.length, ende < 0 ? log.length : ende).trim();
  }
  final text = "## Highlights\n\n$punkte\n\n## All changes\n\n$aenderungen\n\n## Download\n\n"
      "- **Windows:** download `rpncalc-$version-windows.zip`, unpack it anywhere and start `rpncalc_app.exe`. "
      "No installation needed.\n"
      "- **Browser:** $pagesAdresse\n";
  return (titel: "v$version – $kurz", text: text, fehler: fehler);
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
