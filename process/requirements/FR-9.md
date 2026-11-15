# FR-9 Einstellungen des Rechners als ein Objekt im Zustand, mit einem einzigen Setter

Feature · Rechner · mittel · Reife 3 · Stand: Angedacht

## Ziel
App, Konsole und Socket stellen den Rechner auf dieselbe Weise ein. Neue Einstellungen erweitern nur eine Klasse,
die API wächst dabei nicht.

## Heute
- Winkelmodus über eigene Methoden bzw. Befehle; Anzeigeformat (FR-3) und Grenzen für Schleifen (VR-2) sind
  geplant, aber nicht da.
- Was zum Rechner und was zur Oberfläche gehört, ist schon entschieden: Winkel, Format und Grenzen stehen im
  `Zustand` und im Skript; Theme, Aufteilung, Enter-Verhalten speichert die Oberfläche selbst.

## Verhalten (Vorschlag)
- Eine unveränderliche Klasse `Einstellungen` (winkel, format, grenzeSchleife, sprache …) mit `mit(...)` für
  Änderungen; sie steht im `Zustand`.
- Die API hat genau einen Setter, z.B. `api.einstellungen = z.einstellungen.mit(winkel: AngleMode.rad)`. Dart
  prüft Namen und Typen schon beim Übersetzen.
- Socket-Protokoll: eine Nachricht `{"einstellen":{"winkel":"rad"}}` (JSON ist nur das Format, in dem sie reist).
- Skript: `Einstellungen.toJson()` als Zeile `{{"einstellungen":{…}}}rpnjson` im Sitzungsexport.
- Menüeinträge für Einstellungen (Modi, Einstellungen im Hauptmenü, FA-6) lesen und setzen über dieses Objekt.

## Entscheidungen
- 2026-11-15: Ein Objekt mit einem Setter statt vieler Setter oder eines JSON-Kanals; JSON nur an den Rändern
  (Socket, Skript) (Jörg).
- 2026-11-15: Die Sprache gehört dazu, weil auch die Konsole sie braucht (Hilfetexte, FR-2) (Jörg).
- 2026-11-15: Die Sprache ist global (an die Person gebunden, mehrere Nutzer sind nicht geplant): sie kommt nicht
  ins Skript, eine geladene Sitzung stellt sie nicht um, und mehrere Rechner (Scratchpad) teilen sie. Später kann
  sie allenfalls ein Dokument oder Problem überladen (FA-27) (Jörg).

## Offen
Bewusst offen gelassen (2026-11-15, Jörg); wird geklärt, wenn es soweit ist.

1. **Modi können wandern:** Der Winkelmodus wird später vielleicht Teil der Einheiten (FS-1); dann verlässt er
   die Einstellungen. Das Objekt sollte das ohne Bruch im Skriptformat erlauben (unbekannte bzw. fehlende
   Schlüssel nur ein Hinweis).
2. **Mehrere Rechner** (Scratchpad, FA-6): hat jeder eigene Einstellungen außer der Sprache?

## Bezüge
FR-3 (Anzeigeformat), VR-2 (Grenze für Schleifen), FR-2 (Mehrsprachigkeit), FS-1 (Einheiten), FA-6 und FK-2
(Menüs), RG-5 (Menü-Modell), RS-1 (Version des Skriptformats); doc/api.md 3.1 (Zustand), 4 (Skriptformat), 6.1
(Socket); scratchpad/Menue.md 3.3.

## Umsetzung und Tests
