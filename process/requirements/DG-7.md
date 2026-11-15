# DG-7 Tastentabelle: jede Taste mit Funktion und Beschriftung je Präfix und Modus

Doku · Gesamt · mittel · Reife 5 · Stand: Bereit

## Ziel
Eine Tabelle aller Tasten zeigt auf einen Blick, was jede Taste tut und was sie zeigt: normal, mit Shift, nach
`~`, `|`, `~|`, mit Shift und Präfix, im Alpha-Modus, im Hilfe-Modus. Das hilft beim Planen (wo ist noch Platz,
passt eine neue Funktion zum Muster der Nachbarn) und dem Nutzer als Übersicht zum Nachschlagen.

## Heute
- Die Belegung steht verteilt: im Code (app/lib/keys.dart: `text`, `shift`, `tilde`, `shiftTilde`, `strich`,
  `beide`, `buchstabe`), in doc/app.md 3.1 (Tabelle der Reihen, nur Grund- und Shift-Belegung), in den Tooltips
  und in der Hilfe je Taste.
- Jörg hat in scratchpad/ideas.md, Abschnitt „neue Rechenfunktionen“, eine Tabelle begonnen: je Taste die
  Spalten -, ~, |, ~| und dieselben mit Shift, nach Blöcken getrennt, mit geplanten Funktionen (z.B. asin auf
  ~sin, csc auf |sin, ggT und kgV auf Shift+:, Primfaktoren auf |x).

## Verhalten
- Je Taste eine Zeile, nach Blöcken des Tastenfelds geordnet (obere Reihe, Funktionstasten, Ziffernblock). Hängt
  die Belegung von einem Modus ab (z.B. komplexe Zahlen kartesisch bzw. polar, FS-3), hat die Taste mehrere
  Zeilen, eine je Modus.
- Spalten: Taste, **Modus/Variante** (leer, wenn es nur eine gibt), normal, ~, |, ~| und dieselben mit Shift;
  dazu **Alpha** (Buchstabe), **Symbole** (Shift+ALPHA, FA-9) und, wo abweichend, die Beschriftung im
  Hilfe-Modus.
- In jeder Zelle das, was auf der Taste steht, und, wenn es abweicht, was eingegeben wird (z.B. ≤ für ~>).
- Geplantes ist erkennbar abgesetzt (kursiv und grau, mit Verweis auf den Eintrag), damit dieselbe Tabelle zum
  Planen taugt.
- **Liste des Geplanten** `doc/keys_planned.txt`, eine Zeile je geplanter Belegung:
  ```
  sin.tilde = asin
  sin.strich = csc              (FS-3)
  sin.polar.tilde = …
  :.shift = ggT
  ..tilde = …
  ```
  - Form: `Taste.Spalte = Text` oder `Taste.Variante.Spalte = Text`, dahinter optional der Eintrag in Klammern.
    Gelesen wird von rechts: nach dem letzten Punkt die Spalte, ein Wort davor die Variante, der Rest ist die
    Taste (so gehen auch Tasten wie `.` und `:`).
  - Taste: die normale Beschriftung (`sin`, `x²`, `ENTER`, `:`).
  - Spalten als Wörter wie die Felder in keys.dart: `normal`, `tilde`, `strich`, `beide`, `shift`, `shiftTilde`,
    `shiftStrich`, `shiftBeide`, `alpha`, `symbol`, `hilfe`.
  - Leere Zeilen und Zeilen mit `#` am Anfang sind Kommentare.
- **Das Werkzeug prüft:** unbekannte Taste oder Spalte ist ein Fehler; Geplantes auf einer schon belegten Zelle
  ist eine Warnung (Kollision); ist Geplantes inzwischen in keys.dart umgesetzt, kommt der Hinweis, dass die Zeile
  aus der Liste kann.

## Entscheidungen
- 2026-11-13: Aus app/lib/keys.dart erzeugt (Werkzeug unter tool/), Geplantes aus einer zweiten, von Hand
  gepflegten Liste; so veraltet die Tabelle nicht und taugt trotzdem zum Planen (Jörg).
- 2026-11-13: Ort: doc/keys.md (auch auf GitHub lesbar) und eine Hilfeseite „Alle Tasten“ (Jörg).
- 2026-11-13: Die volle, breite Tabelle auch am Handy; man scrollt seitlich (Jörg).
- 2026-11-13: Eine Spalte Modus/Variante, damit eine Taste je Modus eine Zeile bekommen kann, z.B. komplexe Zahlen
  kartesisch und polar (Jörg).
- 2026-11-13: Eine Spalte Symbole für Shift+ALPHA (FA-9) neben Alpha (Jörg).
- 2026-11-13: Modi in der Tabelle: Alpha, Großbuchstaben, Symbole, Hilfe-Modus, `'`; Domänen der Funktionstasten
  nur als Verweis. Zuerst Deutsch, Englisch mit FA-13 bzw. FR-2 (Jörg).
- 2026-11-13: Geplantes in `doc/keys_planned.txt` im Format `Taste.Variante.Spalte = Text (Eintrag)`, Spalten als
  Wörter; das Werkzeug trägt es ein und meldet Kollisionen (Jörg).
- 2026-11-13: Das Menü gehört nicht in diese Tabelle, auch wenn es auf den Tasten liegen soll; FA-6 kann dasselbe
  Konzept nutzen (erzeugte Tabelle und Liste des Geplanten) (Jörg).

## Offen

## Bezüge
FA-6 (Menü), FA-9 und FA-15 (Alpha, Symbole), FS-3 (komplexe Zahlen), FR-2/FA-13 (Mehrsprachigkeit), DG-3
(Hilfetexte); doc/app.md 3.1 und 3.2, app/lib/keys.dart; Jörgs Entwurf: scratchpad/ideas.md, „neue
Rechenfunktionen“.

## Umsetzung und Tests
