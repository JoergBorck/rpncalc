# DG-8 Funktionsübersicht: jedes Token mit Stackwirkung, Argumenten und Varianten

Doku · Gesamt · mittel · Reife 5 · Stand: Angedacht

## Ziel
Eine Übersicht aller Tokens des Rechners zeigt, was jedes tut: was es vom Stack nimmt und zurücklegt, welche
Argumente es mit `:` annimmt (Bedeutung, Standardwert), welche Varianten es mit `~` und `|` gibt. Sie hilft beim
Planen neuer Funktionen und Argumente (gleiche Namen, gleiche Reihenfolge, keine Widersprüche) und dem Nutzer
zum Nachschlagen. Gegenstück zur Tastentabelle (DG-7): dort *wo* etwas liegt, hier *was* es tut.

## Heute
- doc/reference.md, Anhang B (Kurzreferenz): nur Namen nach Gruppen, ohne Stackwirkung und Argumente.
- doc/reference.md, Kapitel 4 bis 11: ausführlich, aber nach Themen; zum Vergleichen muss man blättern.
- library/system/hilfe.de.rpnlib: je Verwendung Schreibweise, Stack, Argumente, Kurztext; Argumente sind erst
  bei 16 Verwendungen eingetragen (z.B. `anzahl:ab (3:0)`, `ziel:quelle:anzahl (1:0:1)`).
- Ideen für neue Rechenfunktionen mit Argumenten in scratchpad/ideas.md, „neue Rechenfunktionen“ (z.B. `0:→ℙ`).

## Verhalten
- **Alles, was ein Token ist:** Operatoren (`+`, `²`, `%`), Stackbefehle (`D`, `S`, `Y`), Funktionen (`sin`,
  `round`), Befehle (`times`, `loop`, `rpnintern`), Präfixe und Modifikatoren (`'!`, `'|`).
- Sauber gegliedert und nichts doppelt: jedes Token genau einmal, Varianten (`~sin`, `|%`) in der Zeile ihres
  Grund-Tokens.
- Spalten: Schreibweise, Varianten, Stack vorher → nachher, Argumente mit Bedeutung und Standardwert, Kurztext,
  Taste (Verweis in die Tastentabelle, DG-7), Hilfe-Kennung.
- **Erzeugt aus der Hilfe** (hilfe.de.rpnlib), nicht von Hand; die Hilfe bleibt die eine Quelle für Hilfeschirm,
  Prüfseite und Übersicht. Ein Werkzeug für DG-7 und DG-8, damit sich beide Tabellen verlinken.
- **Geplantes** aus einer parallelen Liste wie bei DG-7 (`doc/functions_planned.txt`), abgesetzt dargestellt.
- **Das Werkzeug prüft:** jedes eingebaute Token hat einen Hilfeeintrag; wer Argumente nimmt, hat sie beschrieben,
  mit Standardwert; gleich gemeinte Argumente heißen überall gleich und stehen in derselben Reihenfolge.

## Entscheidungen
- 2026-11-13: Alles gehört hinein, was ein Token ist: Operatoren, Stackbefehle, Funktionen, Befehle. Sauber
  strukturiert, nichts doppelt (Jörg).
- 2026-11-13: Anhang B in reference.md bleibt vorerst als Übersicht; später wird er weiter gekürzt (z.B.
  „trigonometrische Funktionen“ statt sin, cos, …) und verweist auf die Funktionsübersicht (Jörg).
- 2026-11-13: Ort: `doc/functions.md` neben `doc/keys.md`, dazu eine Hilfeseite „Alle Funktionen“ (Jörg).
- 2026-11-13: Gliederung nach den Kapiteln von reference.md, damit Referenz und Übersicht dieselbe Ordnung haben
  (Jörg).
- 2026-11-13: DG-8 baut Übersicht und Werkzeug; das Werkzeug listet die Lücken in der Hilfe (fehlende Argumente,
  Stackwirkung). Das Nachtragen ist ein eigener Eintrag, DG-9 (Jörg).

## Offen

## Bezüge
DG-7 (Tastentabelle, gleiches Werkzeug), DG-9 (Lücken in der Hilfe), DG-3 (Hilfetexte), DS-1 (EBNF), RR-1 (Fehlercodes); doc/reference.md
Kapitel 4–11 und Anhang B, library/system/hilfe.de.rpnlib, lib/src/engine/functions.dart.

## Umsetzung und Tests
