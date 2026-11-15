# RG-5 Menü-Modell im Kern: Beschreibung der Einträge für App und Konsole, mehrere Rechner nebeneinander

Recherche · Gesamt · mittel · Reife 4 · Stand: Angedacht

## Frage
1. Wie sieht die Beschreibung der Menüeinträge im Kern aus, damit App (FA-6) und Konsole (FK-2) dieselben
   rechnerbezogenen Einträge zeigen und nur die Darstellung verschieden ist?
2. Sind zwei `RpnApi` in einem Prozess wirklich unabhängig (für das Scratchpad, FA-6)?

## Vorgehen
- **Vorgezogen für FA-30:** zuerst nur der Bereich Bibliotheken (Art „Liste mit Mehrfachauswahl“); die anderen
  Bereiche danach.
- Zu 1: Entwurf der Datenstruktur (Kennung, Symbol, Art, Lesen und Setzen, Hilfe-Kennung, Untermenü) und der
  Menübäume (Ebenen; die Zuordnung Ebene → Bereich des Tastenfelds bleibt in der App). Prüfen an drei Bereichen:
  Modi (Einstellungen, FR-9), Bibliotheken (Listen, FR-10), Code (gezielt löschen, FR-10). Klären, wie die
  Oberflächen eigene Einträge ergänzen (App: Ansicht, Seiten; Konsole: Server) und wie die Hilfe (`menue:`)
  dazukommt.
- Zu 2: Suche nach gemeinsamem Zustand (statische Felder, Singletons, globale Bibliotheks- oder Hilfe-Register),
  dazu ein Test mit zwei Instanzen. Ein erster Blick 2026-11-15 fand in lib/ keine veränderlichen statischen
  Felder.

## Ergebnis
Steht dann unter process/testing/ bzw. als Entscheidung in FA-6, FK-2 und doc/architecture.md.

## Entscheidungen
- 2026-11-15: Die Beschreibung der rechnerbezogenen Menüeinträge liegt im Kern (Jörg).

## Offen

## Bezüge
FA-6, FK-2, FR-9, FR-10, RG-1 (Architektur-Review vor dem Menü), VA-9 (Bedienmodi), VR-6 (RpnApi als reine
Tür); doc/architecture.md 4.3.

## Umsetzung und Tests
