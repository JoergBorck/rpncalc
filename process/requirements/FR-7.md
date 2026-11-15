# FR-7 loop mit Argumenten als Zählschleife (bis:von:step) statt times, dazu break und next

Feature · Rechner · mittel · Reife 5 · Stand: Angedacht

## Ziel
Eine Schleife für beide Fälle: ohne Argumente wiederholt `loop` wie bisher, solange die Bedingung am Ende wahr
ist; mit Argumenten zählt es wie eine for-Schleife, mit Bereich und Schrittweite. Dazu `break` und `next`, um
eine Schleife vorzeitig zu verlassen bzw. den Rest eines Durchlaufs zu überspringen.

## Heute
- `{code}loop`: führt `code` aus, nimmt danach einen Wert vom Stack, wiederholt, solange er wahr ist.
- `n:{code}times`: n Durchläufe, der Index (ab 0) ist das einzige Argument jedes Durchlaufs; mehr als 1.000.000
  Durchläufe beginnen gar nicht erst (doc/reference.md 11).
- Kein vorzeitiges Verlassen, kein Überspringen; nur Bereiche ab 0 in Einerschritten.
- `times` wird benutzt: library/statistik.rpnlib (`sall`), doc/demo.md, Tests (test/times_test.dart, Rechner
  174–183, 198–202).

## Verhalten
- **`{code}loop` ohne Argumente:** unverändert (Bedingung am Ende).
- **`bis:von:step:{code}loop` mit Argumenten:** zählt von `von` in Schritten `step` bis vor `bis`; Standard
  `bis:0:1`, also `100:{…}loop` = 100 Durchläufe mit Index 0 bis 99, genau wie heute `100:{…}times`. Keine
  Bedingung vom Stack. Jeder Durchlauf bekommt den Index als einziges Argument (wie heute bei `times`).
  - Die Argumente erweitern sich hinten, jedes hat eine feste Bedeutung (Regel aus reference.md 5); deshalb
    `bis` zuerst.
  - Der Index wird als `von + k·step` berechnet, nicht aufaddiert, damit Kommaschritte wie 0.1 nicht wegdriften.
  - `step` = 0 ist ein Fehler; ein negativer `step` zählt abwärts (dann muss `bis` kleiner als `von` sein).
- **`break`:** beendet die innerste Schleife sofort, auch aus einem if-Block im Rumpf heraus; der Rest des
  Durchlaufs läuft nicht mehr.
- **`next`:** beendet den aktuellen Durchlauf; die Schleife macht mit dem nächsten weiter (bei `loop` ohne
  Argumente: mit der Prüfung der Bedingung? siehe Offen).
- Die Grenze von 1.000.000 Durchläufen gilt für beide Formen.

## Entscheidungen
- 2026-11-13: Keine Argumente, mit denen der Rumpf die Schleife zur Laufzeit umstellt (Rückgabe über die
  Argumentliste); zu viele Fallen: der nächste Identifier verbraucht alle Argumente, verschachtelte Blöcke haben
  eigene Listen, die Reihenfolge dreht sich über den Stack, vergessene Argumente würden still wirken (Jörg).
- 2026-11-13: Statt dessen `break` und `next` (Jörg).
- 2026-11-13: `loop` übernimmt die Zählschleife: ohne Argumente wie bisher, mit Argumenten statt `times`
  (`100:{…}loop` statt `100:{…}times`) (Jörg).
- 2026-11-13: Der Index kommt als Argument in den Rumpf, gelesen mit `~:` bzw. `~|:`, nicht auf den Stack: so
  entscheidet der Code, wann er ihn braucht, und der Stack gehört ganz dem Code (wie heute bei `times`) (Jörg).
- 2026-11-13: `times` bleibt vorerst als zweiter Name, in Hilfe und Referenz als älterer Name; entfernt wird er
  erst mit einer Version des Skriptformats (RS-1) (Jörg).
- 2026-11-13: `bis` ist exklusiv wie heute; bei Kommaschritten mit kleiner Toleranz am Ende, damit z.B.
  `10:~10:0.1:` genau 200 Durchläufe hat (Jörg).
- 2026-11-13: `next` in `loop` ohne Argumente nimmt die Bedingung vom Stack wie das Ende des Rumpfs; fehlt sie,
  ist das ein Fehler (Jörg).
- 2026-11-13: `break` und `next` wirken auch aus if-Blöcken im Rumpf, aber nicht über Funktionsgrenzen; außerhalb
  einer Schleife sind sie ein Fehler mit eigenem Code (Jörg).
- 2026-11-13: Liefert eine berechnete Argumentliste (z.B. `~|:`) zur Laufzeit nichts, ist `loop` eine
  Bedingungsschleife; das steht so in der Referenz (Jörg).

## Offen

## Bezüge
RS-1 (Version des Skriptformats), VR-2 (Grenze für loop und times einstellbar), FR-5 (print und input), DG-8
(Funktionsübersicht); doc/reference.md 11 und 13, test/times_test.dart, library/statistik.rpnlib, doc/demo.md;
Jörgs Idee in scratchpad/ideas.md, „Neue Programmfunktionen“. Nicht hier: weitere Verzweigungen (`ifsgn`, `try`), siehe FR-8.

## Umsetzung und Tests
