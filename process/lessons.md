# Lessons Learned – Team

Was Jörg und Claude gemeinsam aus der Arbeit am RPN-Rechner gelernt haben. Je Lehre: was passiert ist und was
daraus folgt; wirksam wird sie dort, wohin „Folge“ zeigt (Regel, Werkzeug, Backlog-Eintrag). Gelesen wird die Datei
beim Prozess-Review (process/workflow.md). Claudes eigene Lehren stehen in [lessons-claude.md](lessons-claude.md).

## 2026-11-21 Logging früh einbauen und pflegen

Erst nach Wochen haben wir Logging gebaut (RG-4). Die Spur des Rechners (PR-1) hat schon beim ersten Lauf ein
Verhalten sichtbar gemacht, das man aus dem Code nur mühsam abliest; das Tastenprotokoll der App (PA-1) spart
Rückfragen („was hast du genau gedrückt?“) und macht aus einer Fehlermeldung direkt einen Regressionstest. Die alten
`verbosity`-Ausgaben waren dagegen verwaist und wurden gelöscht (VG-3), weil sie niemand benutzt hat.

**Folge:** Neue Teile bekommen ihre Haken für Spur bzw. Protokoll gleich mit, und neue Zustände kommen in die
Zeilen von Spur und Protokoll. Logging ist so geschnitten, dass Claude es selbst auslösen und als Text lesen kann
(tool/trace.dart, process/testing/logs/protokoll.txt). Nächster Schritt: PA-2 (Debug-Verbindung zur App).

## 2026-11-21 Regelmäßige Prozess-Reviews

Ein Blick auf die eigene Arbeitsweise hat an einem Tag gebracht: Backlog halbiert (PG-5), CLAUDE.md (PG-6),
Suche ohne erzeugte Dateien (PG-7), Logging mit Vorrang, Claudes Gedächtnis von zehn auf drei Notizen. Vieles davon
hätte früher auffallen können.

**Folge:** Prozess-Review regelmäßig, etwa wöchentlich oder spätestens vor einer neuen Version; Ablauf in
process/workflow.md („Prozess-Review“).
