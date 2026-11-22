# RA-2 Cursorkreuz und TAB: Nutzen prüfen und ein sauberes Konzept für Navigation und Bereiche finden

Recherche · App · mittel · Reife 2 · Stand: Geplant

## Frage
Das Cursorkreuz (◄ ▲ ► ▼) belegt mitten im Tastenfeld viel Platz und ragt in die Anzeige, bringt beim Rechnen
aber wenig: Blättern und Schieben gehen auch mit Wischen und Mausrad, am PC mit den Pfeiltasten. Welche Aufgaben
sollen Cursorkreuz und TAB haben, und wie viel Platz rechtfertigt das? Ergebnis ist ein Konzept, aus dem eigene
Einträge (meist V) werden.

## Heute (doc/app.md 3.3, 3.5, 3.6, Kapitel 6)
- **TAB / Shift+TAB:** Bereich wechseln, Eingabe → Stack → Funktionen → Variablen; im Hilfe-Modus der nächste
  Verweis.
- **Eingabe:** ▲ ▼ blättern im Verlauf, ◄ ► schieben lange Zeilen seitlich (einen Cursor in der Zeile gibt es erst
  mit dem Undo).
- **Stack:** ▲ ▼ blättern zu tieferen Werten, ◄ ► schieben lange Werte (der Exponent bleibt stehen).
- **Liste der Funktionen bzw. Variablen:** ▲ ▼ scrollen, ◄ ► schieben den Code bzw. die Werte (VA-15).
- **Tastenblock der Funktionstasten:** ◄ ► blättern die Seiten im Kreis, ▲ ▼ begrenzt (VA-14).
- **Hilfe-Modus und Menü:** eigene Belegung der Pfeile.
- **Daneben:** in den freien Ecken die Maximieren-Taste und ein Platzhalter (FA-5, Hoch-/Querformat).
- Wischen, Mausrad und Antippen erledigen Blättern und Bereichswahl schon heute ohne das Kreuz.

## Vorgehen
- Bestandsaufnahme: jede Wirkung von ◄ ▲ ► ▼ und TAB je Seite und Modus, mit dem Weg ohne Kreuz (Wischen, Tipp,
  PC-Taste); das Tastenprotokoll zeigt, was tatsächlich benutzt wird.
- Künftige Aufgaben einbeziehen: Cursor in der Zeile mit Undo (Kapitel 4), Auswahl im Stack (Werte bearbeiten,
  kopieren), Verweise in der Hilfe, Menü, Bedienung ohne Touch (Tastatur, Barrierefreiheit), RA-1.
- Varianten skizzieren und vergleichen, z.B.: Kreuz kleiner oder als zwei Tasten; Kreuz nur, wenn es etwas zu tun
  gibt; Pfeile als Belegung einer anderen Taste (Shift, eigener Modus); den gewonnenen Platz für Tasten oder
  Anzeige nutzen. Je Variante: Platz, Lernaufwand, Folgen für Tooltips, Hilfe, Tastentabelle (DG-7).

## Ergebnis
Ein Konzept in doc/app.md (3.3) mit Entscheidungen hier; daraus eigene Einträge im Backlog.

## Entscheidungen
- 2026-11-22: angelegt auf Wunsch von Jörg, gleich unter „Geplant“.
