# FK-2 Konsolenmenü zum Benutzen statt zum Testen überarbeiten

Feature · Konsole · mittel · Reife 3 · Stand: Angedacht

## Ziel
Ein Menü, mit dem man die Konsole wirklich benutzt, und das sich bedient wie das Menü der App (FA-6): wer eine
Oberfläche kennt, kennt die andere.

## Heute
Das Menü (lib/src/console/menu.dart, bin/rpncalc.dart) ist zum Ausprobieren entstanden: Nummern eintippen,
Meldungen wie „… wurde ausgewählt!“, ein Untermenü „Test“ mit Beispiel-Einträgen und Selbsttests, die
Eingabearten als eigene Einträge, der Server als Menüpunkt. Aus der laufenden Eingabe ist es nicht erreichbar.

## Verhalten (Vorschlag)
Das Konsolenmenü ist die Bedienung des App-Menüs mit der PC-Tastatur (FA-6, „PC-Tastatur“), als Text:
- **Dieselben Nummern wie in der App:** 1–9 wählen den Bereich des Hauptmenüs (3 Ansicht, 4 Bibliotheken, 5 Code
  …).
- **Zweite Ebene als nummerierte Liste:** was in der App auf F1–F10 liegt, mit Name und kurzer Beschreibung.
- **Dieselben Aktionen:** `/` umschalten, `*` leeren, `-` und `+` zählen, Enter übernimmt, Esc bricht ab. Die
  Auswahl allein ändert nichts.
- **Aus der laufenden Eingabe erreichbar** mit einem `\`-Befehl, z.B. `\m`; dazu ein direkter Weg, z.B. `\m 4` für
  die Bibliotheken.
- **Selbsttests** unter Einstellungen → Entwickleroptionen → Tests, wie beim Handy.
- **Ausgeblendet**, was es in der Konsole nicht gibt: Seiten der Anzeige, Scratchpad, Dokumenten-System.
- **Sprache** ist auch in der Konsole einstellbar, schon wegen der Hilfetexte (FR-2, FR-9).
- **Die Einträge kommen aus dem Kern** (Beschreibung der Menüeinträge, RG-5); die Konsole stellt sie nur dar und
  ergänzt eigene Einträge (z.B. Server starten).

## Entscheidungen
- 2026-11-15: Das Konsolenmenü folgt der PC-Tastatur-Bedienung des App-Menüs: dieselben Nummern, dieselben
  Aktionstasten, als Text (Jörg).
- 2026-11-15: Die Sprache ist auch in der Konsole einstellbar (Jörg).
- 2026-11-15: Die Beschreibung der rechnerbezogenen Menüeinträge liegt im Kern (Jörg).
- 2026-11-15: Selbsttests kommen wie beim Handy unter Einstellungen → Entwickleroptionen → Tests (Jörg).

## Offen
Bewusst offen gelassen (2026-11-15, Jörg); wird geklärt, wenn es soweit ist.

1. **Beispiel-Einträge** des Untermenüs „Test“: entfallen sie, oder kommen sie zu den Tests?
2. **Server:** Menüpunkt unter Connect (`.`, FA-28) oder weiter Startparameter?
3. **Eingabearten** (zeilenweise, Zeichen für Zeichen): Einstellung, Startparameter oder beides?
4. **Hilfe zu den Einträgen:** `?` vor der Nummer, oder wie in der App über den Namensraum `menue:`?

## Bezüge
FA-6 (Menü der App), RG-5 (Menü-Modell im Kern), FR-9 (Einstellungen), FR-10 (Herkunft der Funktionen), FR-2
(Mehrsprachigkeit), FA-28 (Connect); lib/src/console/menu.dart, bin/rpncalc.dart.

## Umsetzung und Tests
