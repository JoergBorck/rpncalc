/// Aufgabe: hält process/requirements/README.md aktuell (PT-2). Die Gliederung (Überschriften, Reihenfolge,
/// Zuordnung) steht in der README selbst; je Eintragszeile ergänzt das Werkzeug Link, Titel und Status aus
/// process/backlog.md und process/done.md, löscht erledigte und abgelehnte Bugs, Recherchen und Tests und meldet fehlende,
/// doppelte und unbekannte IDs.
///
///   dart run tool/requirements.dart     README neu schreiben; Meldungen nach stderr, dann Fehlercode 1
///
/// Eine Eintragszeile ist `- [ID](Link) Titel · Status` oder für einen neuen Eintrag nur `- ID`. Ein Teil ohne
/// Einträge bekommt „(noch keine)“.
///
/// Abgrenzung: Was im Backlog steht, wird nicht geändert; test/requirements_test.dart prüft bei jedem Testlauf, dass
/// die README dem entspricht, was [anforderungen] erzeugt. Vorbild ist tool/changelog.dart.
///
/// Siehe auch: process/requirements/PT-2.md, process/workflow.md (Anforderungen).
library;

import 'dart:io';

const _readme = "process/requirements/README.md";

void main() {
  final ergebnis = anforderungen(
    readme: File(_readme).readAsStringSync(),
    backlog: File("process/backlog.md").readAsStringSync(),
    done: File("process/done.md").readAsStringSync(),
    dateien: vorhandeneDateien(),
  );
  File(_readme).writeAsStringSync(ergebnis.text);
  for (final m in ergebnis.meldungen) {
    stderr.writeln(m);
  }
  if (ergebnis.meldungen.isNotEmpty) exit(1);
  print("README.md geschrieben");
}

/// Die eigenen Dateien der Einträge, relativ zu process/requirements/: `FR-3.md`, `research/RG-5.md` …
Set<String> vorhandeneDateien() => {
      for (final ordner in ["", "bugs/", "research/", "tests/"])
        if (Directory("process/requirements/$ordner").existsSync())
          for (final f in Directory("process/requirements/$ordner").listSync().whereType<File>())
            if (_id.hasMatch(f.uri.pathSegments.last.replaceAll(".md", "")))
              "$ordner${f.uri.pathSegments.last}",
    };

/// Eine ID: zwei bis drei Großbuchstaben (Art und Bereich), Bindestrich, Nummer.
final _id = RegExp(r"^[A-Z]{2,3}-\d+$");

/// Eine Eintragszeile der README: `- [ID](…) …` oder `- ID`.
final _eintragszeile = RegExp(r"^- \[?([A-Z]{2,3}-\d+)\b");

/// Ein Eintrag aus Backlog oder done.md.
typedef _Eintrag = ({String id, String titel, String ueberschrift, String status, String datei});

/// Erzeugt die README aus ihrer bisherigen Fassung [readme] (Gliederung) und den Einträgen; [dateien] sind die
/// eigenen Dateien relativ zu process/requirements/.
({String text, List<String> meldungen}) anforderungen(
    {required String readme, required String backlog, required String done, required Set<String> dateien}) {
  final eintraege = <String, _Eintrag>{
    ..._lies(backlog, "backlog.md", (abschnitt) => abschnitt == "Abgelehnt" ? "✗ abgelehnt" : abschnitt,
        nur: _abschnitte),
    ..._lies(done, "done.md", (_) => "✓"),
  };
  final meldungen = <String>[];
  final gesehen = <String>{};
  final aus = <String>[];
  var lauf = <String>[]; // Eintragszeilen eines Teils, „(noch keine)“ eingeschlossen

  void laufBeenden() {
    if (lauf.isEmpty) return;
    final zeilen = <String>[];
    for (final z in lauf) {
      final m = _eintragszeile.firstMatch(z);
      if (m == null) continue; // „(noch keine)“
      final id = m.group(1)!;
      if (!gesehen.add(id)) {
        meldungen.add("$id steht mehrfach in der README");
        continue;
      }
      final e = eintraege[id];
      if (e == null) {
        meldungen.add("$id steht in der README, aber weder im Backlog noch in done.md");
        zeilen.add(z);
        continue;
      }
      if (_entfaellt(e)) continue; // erledigte oder abgelehnte Bugs, Recherchen, Tests
      zeilen.add("- [$id](${_link(e, dateien)}) ${e.titel} · ${e.status}");
    }
    aus.addAll(zeilen.isEmpty ? ["(noch keine)"] : zeilen);
    lauf = [];
  }

  for (final z in readme.replaceAll("\r\n", "\n").split("\n")) {
    if (_eintragszeile.hasMatch(z) || z.trim() == "(noch keine)") {
      lauf.add(z);
    } else {
      laufBeenden();
      aus.add(z);
    }
  }
  laufBeenden();

  for (final e in eintraege.values) {
    if (gesehen.contains(e.id)) continue;
    if (_entfaellt(e)) continue;
    meldungen.add("${e.id} fehlt in der README (${e.datei}: ${e.status})");
  }
  return (text: aus.join("\n"), meldungen: meldungen);
}

/// Bugs, Recherchen und Tests stehen nur in der README, solange sie offen sind (process/workflow.md, Anforderungen).
bool _entfaellt(_Eintrag e) => "BRT".contains(e.id[0]) && (e.status == "✓" || e.status == "✗ abgelehnt");

/// Die Abschnitte des Backlogs, die Einträge enthalten; die übrigen (Bereiche, Einträge, Kategorien …) erklären
/// die Regeln, ihre Beispiele wie „FA-0“ sind keine Einträge.
const _abschnitte = {
  "In Arbeit", "Bereit", "Erforderlich", "Geplant", "Zurückgestellt", "Angedacht", "Vorgeschlagen", "Für die Zukunft",
  "Abgelehnt",
};

/// Die Einträge einer Datei mit dem Status je Abschnitt („## …“), mit [nur] nur aus diesen Abschnitten;
/// Überschriften wie „### Version 0.4.0“ und alles in Codeblöcken sind keine.
Map<String, _Eintrag> _lies(String text, String datei, String Function(String abschnitt) status, {Set<String>? nur}) {
  final eintraege = <String, _Eintrag>{};
  var abschnitt = "";
  var imCode = false;
  for (final z in text.replaceAll("\r\n", "\n").split("\n")) {
    if (z.startsWith("```")) imCode = !imCode;
    if (imCode) continue;
    if (z.startsWith("## ")) abschnitt = z.substring(3).trim();
    if (!z.startsWith("### ") || (nur != null && !nur.contains(abschnitt))) continue;
    final ueberschrift = z.substring(4).trim();
    final leer = ueberschrift.indexOf(" ");
    final id = leer < 0 ? ueberschrift : ueberschrift.substring(0, leer);
    if (!_id.hasMatch(id)) continue;
    eintraege[id] = (
      id: id,
      titel: leer < 0 ? "" : ueberschrift.substring(leer + 1),
      ueberschrift: ueberschrift,
      status: status(abschnitt),
      datei: datei,
    );
  }
  return eintraege;
}

/// Der Link eines Eintrags: die eigene Datei, sonst der Anker im Backlog bzw. in done.md.
String _link(_Eintrag e, Set<String> dateien) {
  for (final ordner in ["", "bugs/", "research/", "tests/"]) {
    if (dateien.contains("$ordner${e.id}.md")) return "$ordner${e.id}.md";
  }
  return "../${e.datei}#${anker(e.ueberschrift)}";
}

/// Der Anker, den GitHub aus einer Überschrift bildet: klein, ohne Satzzeichen (Buchstaben, Ziffern, Leerzeichen,
/// Bindestrich und Unterstrich bleiben), Leerzeichen werden zu Bindestrichen.
String anker(String ueberschrift) => ueberschrift
    .toLowerCase()
    .split("")
    .where((c) => c == " " || c == "-" || c == "_" || RegExp(r"[\p{L}\p{N}]", unicode: true).hasMatch(c))
    .join()
    .replaceAll(" ", "-");
