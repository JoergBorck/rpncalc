# FG-1 Offene Argumente: in der App sichtbar, ein Befehl legt sie zurück auf den Stack

Feature · Gesamt · klein · Reife 4 · Stand: Angedacht

## Ziel
Mit `:` übergebene Argumente warten auf den nächsten Identifier. Heute sieht man sie in der App nicht, und man
wird sie nur los, indem man einen Befehl mit eigener Wirkung aufruft. Man soll sehen, dass Argumente warten, und
sie ohne Nebenwirkung zurückholen können.

## Heute
- Zwei Argumentlisten: die **offene**, die `:` für den nächsten Identifier füllt, und die **erhaltene** einer
  eigenen Funktion. `~:`, `~|:` und `|:` lesen nur die erhaltene; auf oberster Ebene sind sie ein Fehler (`argAus`).
- Die offene Liste leert nur ein Identifier, der sie verbraucht, und der wirkt dabei selbst (z.B. `'C`, das AC
  benutzt, löscht auch den Stack).
- Falle: Ist `5:` schon ausgeführt, verwirft CL die 5 nicht; sie wartet unsichtbar und landet beim nächsten
  Befehl (`D` wirkt dann als `5:D`).
- Der Rechner meldet die offenen Argumente im Zustand (`Zustand.argumente`), die App zeigt sie nicht an.

## Verhalten (Vorschlag)
- **Befehl `rpnargs`:** legt alle offenen Argumente zurück auf den Stack und leert die Liste, in der
  Reihenfolge der Liste wie `~|:`: das zuerst übergebene zuunterst, das zuletzt übergebene als Tos. So nimmt er
  getippte Argumente genau zurück: `3:7:rpnargs` → 3 7. Kamen sie vom Stack, sind sie danach umgedreht:
  `3 7::rpnargs` → 7 3 (wie beim Beispiel `4 7 3:::S` in reference.md 5). Ohne offene Argumente tut er nichts.
  Er gilt überall, auch im Code, und betrifft dort ebenfalls nur die offene, nicht die erhaltene Liste.
- **Anzeige in der App:** Warten Argumente, steht klein über dem Stack (wie das offene Token) z.B. `3:7:`; ein
  Tooltip erklärt, dass sie beim nächsten Befehl verbraucht werden.
- **CL** verwirft auch die Argumente, die in der aktuellen Zeile übergeben wurden (dazu muss die App bzw. die
  API wissen, welche das sind); AC verwirft ohnehin alle (über `'C`).

## Entscheidungen
- 2026-11-13: Ein eigener Befehl statt `~:` und Co. auf oberster Ebene; dasselbe Zeichen soll nicht je nach Ort
  etwas anderes bedeuten (Jörg).
- 2026-11-13: Der Befehl legt die Argumente auf den Stack, statt sie nur zu verwerfen (Jörg).
- 2026-11-13: Die App zeigt offene Argumente an (Jörg).
- 2026-11-13: Anzeige klein über dem Stack wie das offene Token, mit Tooltip; ein Tipp darauf ruft den Befehl auf
  (Jörg).
- 2026-11-13: CL verwirft auch die Argumente, die in der aktuellen Zeile übergeben wurden; `verwerfen()` nimmt
  sie mit zurück wie das offene Token (Jörg).
- 2026-11-13: Keine eigene Taste für den Befehl (Jörg).
- 2026-11-14: Der Befehl heißt `rpnargs`, in der Reihe von `rpnjson` und `rpnintern`; kurze Namen bleiben für
  eigene Funktionen frei (Jörg).

## Offen
1. **Reihenfolge:** wie `~|:` bei der erhaltenen Liste (zuerst übergeben = zuunterst). Das nimmt getippte
   Argumente (`3:7:`) genau zurück, dreht aber vom Stack übergebene (`3 7::`) um. Die Alternative (umgekehrt)
   hätte das Problem genau andersherum. Vorschlag: wie `~|:`, eine Regel für beide Listen.

## Bezüge
FR-7 (Argumente bei loop), FA-25 und VA-16 (CL und AC), DG-8 (Funktionsübersicht); doc/reference.md 5 und
10.3, lib/src/engine/arguments.dart, lib/src/engine/operators.dart, doc/api.md (Zustand).

## Umsetzung und Tests
