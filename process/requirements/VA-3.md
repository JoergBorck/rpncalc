# VA-3 JuliaMono als mitgelieferte Monospace-Schrift, auf die benötigten Zeichen beschnitten

Verbesserung · App · mittel · Reife 3 · Stand: Vorgeschlagen

## Ziel
Anzeige, Tooltips und Hilfe sehen auf jedem Gerät gleich aus, und alle Zeichen des Rechners stammen aus einer
Schrift. Heute nimmt die App die Monospace-Schrift des Systems (`Schrift.mono` in app/lib/colors.dart: Consolas,
Roboto Mono, Menlo, monospace). Zeichen wie ₙ fehlen in Consolas; am Handy und im Browser springt eine andere
Schrift ein, mit anderer Breite und Höhe.

## Verhalten
- Die App liefert JuliaMono mit (SIL Open Font License 1.1, Lizenztext liegt bei) und nimmt sie für alles, was
  heute `Schrift.monospace` benutzt: Anzeige, Rahmennamen, Statuszeile, Tooltips, Hilfe, Listen.
- Die Beschriftung der Tasten bleibt, wie sie ist.
- Die Dateien liegen unter `app/assets/fonts/` (der erste Asset-Ordner der App) und sind in app/pubspec.yaml
  unter `fonts:` eingetragen.
- Jedes Zeichen, das Rechner, Bibliotheken, Hilfe und App heute benutzen, kommt aus JuliaMono; die Systemschrift
  bleibt nur als Rückfall.
- Die App wird dadurch höchstens um einige 100 KB größer.

## Entscheidungen
(noch keine)

## Offen
1. **Zeichenumfang beim Beschneiden.** Heute kommen 79 Zeichen außer ASCII vor (gezählt am 2026-11-09 in
   app/lib, lib und library):
   `§°±²³·½ÄÖ×Üßäêö÷üŷȳˣ̂̄ΛΣΩδηκπφω–‖“„…′″₀₁₂₃₄₅₆₇₈₉ₙ←↑→↓↵⇤⇥⇧−√∛∞≈≠≡≤≥⌫⏎␣│█▌□▢▲►▼◄◫`.
   Vorschlag: nicht genau diese, sondern ganze Blöcke, damit eigene Namen und Texte (FS-4, FS-5) nicht auf die
   Systemschrift zurückfallen: ASCII, Latin-1 und Latin Extended-A, Griechisch, kombinierende Akzente,
   Hoch- und Tiefstellungen, Pfeile, mathematische Operatoren, Zeichen aus „Technisches“ (⌫ ⏎), Rahmen und
   Blöcke, geometrische Formen. Ein Skript mit fontTools (`pyftsubset`) schneidet zu; es liegt unter tool/, damit
   es bei neuen Zeichen wiederholbar ist, und prüft, dass alle verwendeten Zeichen enthalten sind.
2. **Welche Schnitte.** Benutzt werden heute w400, w600 (Rahmennamen, ENTER↑), w700 (Hilfe-Titel, Statuszeile,
   Hervorhebungen im Tooltip), einmal w900 (⏎ im Tooltip) und Kursiv (interne Funktionen, VA-11).
   Vorschlag: Regular, SemiBold und Bold; w900 wird Bold. Alternative: JuliaMono als variable Schrift, eine Datei
   für alle Stärken, dafür größer.
   **Kursiv:** Für VA-11 allein wäre es entbehrlich, die internen Funktionen sind ohnehin ausgegraut. In der
   mathematischen Schreibweise ist Kursiv aber üblich (Variablen wie *x*, *n*, *ω* kursiv, Funktionsnamen und
   Einheiten aufrecht); für eine spätere Formelansicht, Einheiten (FS-1) oder die Hilfe kann es also doch nötig
   werden. Offen: Italic gleich mitliefern (eine Datei mehr) oder erst, wenn es gebraucht wird; bis dahin bliebe
   das von Flutter schräg gestellte Regular.
3. **Breite.** JuliaMono ist breiter als Consolas (im Eintrag geschätzt etwa 5 %, beim Umsetzen messen). In
   eine Zeile passen dann weniger Zeichen. Vorschlag: hinnehmen, die Zoom-Regel (doc/app.md 1.1) bleibt; nur
   prüfen, dass der Stack bei der kleinsten Fensterbreite noch einen Wert mit 12 Stellen zeigt.
4. **„…“ am Zeilenende** und die übrigen Zeichen mit Sonderrolle (␣, █, ▌, ◫): nach dem Umstellen am PC, im
   Browser und am Handy ansehen. Vorschlag: Teil des Tests, keine eigene Entscheidung.
5. **Auch für die Tasten?** Vorschlag: nein, wie im Eintrag; die Tasten haben eine eigene, größere Schrift, und
   ihre Zeichen sind alle in den Systemschriften vorhanden.

## Bezüge
FS-4, FS-5 (mehr Zeichen in Namen), VA-11 (Kursiv der internen Funktionen), FA-13 (Mehrsprachigkeit);
Spezifikation: doc/app.md (Schrift), doc/architecture.md (Assets).
Vergleichsbild JuliaMono und Consolas vom 2026-11-04 (im Gespräch, nicht abgelegt).

## Umsetzung und Tests
