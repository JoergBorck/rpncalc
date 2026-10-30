# Manuelle Tests

Diese Tests brauchen ein echtes Terminal, die Zwischenablage, Excel oder mehrere laufende Programme.
Deshalb deckt `dart test` sie nicht ab. Alles andere ist automatisch getestet (siehe `doc/reference.md` Anhang D).

**Vorbereitung**

- VS Code mit dem Projekt öffnen, Startkonfigurationen aus `.vscode/launch.json`:
  `rpncalc` (Menüprogramm), `RPN Server`, `RPN Client`, `Server & Client gleichzeitig`.
- Vorher `dart test` laufen lassen, alle Tests müssen grün sein.
- Auf Port 4040 darf kein alter Server mehr laufen.

**Logs:** Wo ein Log hilft, steht es in der Spalte „Log“. Gemeint ist die Ausgabe im Terminal des Servers
bzw. des Programms. Für das Protokoll den Ausschnitt kopieren (Terminal markieren, Strg+C) und unter
„Anhang“ einfügen.

---

## M: Menüprogramm

| ID | Test | Schritte | Erwartet | Log |
|---|---|---|---|---|
| M-01 | Start | `rpncalc` starten | Bildschirm wird geleert, Hauptmenü erscheint | – |
| M-02 | Selbsttests | Test → Test Dea, Test Parser, Test Rechner | jeweils keine fehlgeschlagenen Fälle | Ausgabe |
| M-03 | Terminal nach Abbruch | Zeichenweise Eingabe starten, Programm mit Strg+C abbrechen, `rpncalc` neu starten, Zeilenweise Eingabe wählen, `3 4+` tippen | Eingabe ist sichtbar (Echo an), Cursor sichtbar, Ergebnis 7 | – |
| M-04 | Beenden | Menüpunkt „Beenden“ | Programm endet, Terminal normal bedienbar | – |

## Z: Zeilenweise Eingabe

| ID | Test | Schritte | Erwartet | Log |
|---|---|---|---|---|
| Z-01 | Rechnen | `3 4+` Enter | `[7]` in der Zustandszeile | – |
| Z-02 | Fehlermarke | `7 3+ 1q2 5` Enter | `^` steht unter dem `q`, Text „Unbekannte Funktion: q“; die Zeile bricht ab, Stack `10 10 1` | – |
| Z-03 | Übersicht | Menüpunkt „mit Übersicht“, `1 2 3` | Anzeige in Spalten statt einer Zeile | – |
| Z-04 | Zurück | `\q` | zurück im Menü | – |
| Z-05 | Prompt und Tos | Zeilenweise Eingabe, `1 2 3` | vor der Eingabe `RPN>` mit „RPN“ in Orange; in der Zustandszeile ist `[3]` hellorange hinterlegt; bei einem Fehler steht `^` genau unter dem Token | – |

## C: Zeichenweise Eingabe

| ID | Test | Schritte | Erwartet | Log |
|---|---|---|---|---|
| C-01 | Anzeige je Taste | `3`, Leertaste, `4`, `+` einzeln tippen | nach jeder Taste neu gezeichnet; nach der Leertaste „ENTER↑“; nach `+` Ergebnis 7 | – |
| C-02 | Cursor | beliebig tippen | orangefarbener Block am Ende der Eingabe, kein weißer Terminal-Cursor | – |
| C-03 | Löschen | `12` tippen, Backspace | `1` bleibt in der Zeile, Zahl noch offen | – |
| C-04 | Fehler und Reparatur | `3 4q+` tippen; zweimal Backspace; `+` | nach `+`: `q` rot markiert mit `^` und „Unbekannte Funktion: q“; 1. Backspace nimmt `+` zurück, 2. das `q`; danach Ergebnis 7 | – |
| C-05 | Enter nach Fehler | `1q` tippen, Enter | Zeile mit Fehlermarkierung wandert in den Verlauf, neue Zeile ist leer | – |
| C-06 | Verlauf | sieben Zeilen eingeben (`1` Enter … `7` Enter) | die letzten 5 Zeilen unter dem Stack, darüber „…“ | – |
| C-07 | Mehrbyte-Zeichen | `3²` tippen (AltGr+2) | `²` wird als ein Zeichen erkannt, Ergebnis 9 | – |
| C-08 | Backslash | `\` tippen, dann `x` | `\` erscheint am Zeilenende, nach `x` gehen beide an den Rechner: Fehler „Unbekanntes Zeichen“, Anzeige bleibt sauber | – |
| C-09 | Schmales Fenster | Terminal schmal ziehen, lange Zeile tippen (`1 2+` mehrfach) | keine Umbrüche, Anzeige wird nicht „verschmiert“, Zeilenende bleibt sichtbar | – |
| C-10 | Zurück zum Menü | `\q`, danach Zeilenweise Eingabe wählen | Menü und Zeilen-Eingabe funktionieren normal (Echo, Enter) | – |
| C-11 | Verlauf bleibt | C-10, dann wieder Zeichenweise Eingabe | der Verlauf von vorher ist noch da | – |
| C-12 | Wechsel nach Fehler | Z-02 (Zeile mit Fehler), `\q`, Zeichenweise Eingabe wählen; Backspace; `4` | leere Eingabezeile, keine Fehlermarkierung; Backspace tut nichts; `4` erscheint in einer neuen Zeile | – |
| C-13 | Prompt, Tos und offenes Token | Zeichenweise Eingabe mit Übersicht, `1 22 333`, dann Enter | `RPN>` mit „RPN“ in Orange; vor dem Enter eine graue Zeile `>: 333` über der hellorange hinterlegten 22; nach dem Enter verschwindet die graue Zeile und 333 steht hinterlegt in Zeile 0; die Trennstriche `│` stehen in allen Zeilen untereinander | – |
| C-14 | Hilfezeile und Tab | Zeichenweise Eingabe mit Übersicht; mehrmals Tab | Hilfezeile unter der Eingabe, der gewählte Bereich wandert in Orange: Stack · Verlauf · Variablen · Funktionen; in der kompakten Anzeige nur Stack · Verlauf | – |
| C-15 | Stack blättern | 12 Zahlen eingeben (`1 2 3 … 12`), Bereich Stack, ↓ dreimal, ↑ einmal, dann `+` | erste Zeile zeigt Position 3, dann 2; nach `+` wieder der Tos oben | – |
| C-16 | Verlauf blättern | 8 Zeilen eingeben, Bereich Verlauf, ↑ dreimal | „… n ältere“ oben, ältere Zeilen sichtbar, unten „… 3 neuere“; ↓ zurück | – |
| C-17 | Funktionen schieben | Bibliothek statistik laden, Bereich Funktionen, ↓ und → mehrmals, ← | Liste blättert; Code wandert nach links, der Name bleibt stehen, vorne „…“ | – |
| C-18 | Esc und danach | Esc drücken, dann `5` | nichts passiert beim Esc, die 5 erscheint ganz normal | – |
| C-19 | Terminal danach | C-14 bis C-18, `\q`, Zeilenweise Eingabe | Pfeiltasten in PowerShell danach wieder wie gewohnt; Menü und Eingabe normal | – |
| C-20 | Verlauf schieben | eine Zeile länger als das Fenster und eine mit Fehler in der Mitte abschließen, Bereich Verlauf, ← mehrmals, → mehrmals | jede Zeile schiebt für sich um ein Zeichen bis zu ihrem Anfang bzw. Ende; liegt der Fehler außerhalb, steht ← bzw. → vor der Meldung; nach der nächsten Taste wieder Fehler bzw. Ende | – |

## X: Zwischenablage

| ID | Test | Schritte | Erwartet | Log |
|---|---|---|---|---|
| X-01 | Tos kopieren | `2.25`, dann `\c`; in einem Editor einfügen | `2,25`, Meldung „Kopiert: 2,25“ | – |
| X-02 | Stack kopieren | `1 2.5 3`, dann `\s`; in einem Editor einfügen | `1;2,5;3` (der tiefste zuerst) | – |
| X-03 | Nach Excel | X-02, in Excel in eine Zelle einfügen | alles landet in einer Zelle (bekanntes Verhalten, Trennung mit `;`) | – |
| X-04 | Aus Excel | in Excel zwei Spalten mit Zahlen markieren (z.B. `3,4E-06`, `-2`), kopieren, `\v` | Meldung „n Zahlen eingefügt“, Zahlen auf dem Stack, die letzte als Tos | – |
| X-05 | Aus einem Text | Text `Messwert 1,5; Fehler #DIV/0!; -2` kopieren, `\v` | Stack `1.5 -2`, keine 0 aus `#DIV/0!` | – |
| X-06 | Keine Zahlen | `Hallo` kopieren, `\v` | Meldung „Keine Zahlen in der Zwischenablage“, Stack unverändert | – |
| X-07 | Zeilenweise | X-01, X-02, X-04 in der zeilenweisen Eingabe wiederholen (`\c`, `\s`, `\v` als eigene Zeile) | wie oben | – |
| X-08 | Zeilenweise am Zeilenende | auf leerem Stack `2.25\c`, dann `3 4+ \s`, dann `1q\c` | „Kopiert: 2,25“; „Kopiert: 2,25;7“; Fehler bei `q` und „Wegen des Fehlers nicht kopiert“ | – |

## F: Dateien und Bibliotheken

| ID | Test | Schritte | Erwartet | Log |
|---|---|---|---|---|
| F-01 | Session | Werte, Variable (`5'!a`), Funktion anlegen; Datei → Session speichern; Programm neu starten; Session laden | Stack, Variable und Funktion sind wieder da | Meldungen |
| F-02 | Bibliothek laden | Stack mit Werten; Bibliotheken → schwingungen | Stack bleibt, `0.5:200:eigen` ergibt 20 | – |
| F-03 | Statistik mit Excel | Bibliotheken → statistik; `sclr`; in Excel Spalten y und x (5 Zeilen) kopieren; `\v`; `5:sall`; `mean` | n = 5, Mittelwerte wie in Excel (`MITTELWERT`) | – |
| F-04 | Datei fehlt | Session laden mit einem Namen, den es nicht gibt | Fehlermeldung, Programm läuft weiter | – |
| F-05 | Bibliotheken finden | Menü Bibliotheken öffnen | „schwingungen“ und „statistik“, keine Sessions (`.rpn`) | – |
| F-06 | Eigene Bibliothek | eine Funktion anlegen (`{2*}':dbl`); Datei → Funktionen speichern, Vorschlag `funktionen.rpnlib` übernehmen; Menü Bibliotheken öffnen | „funktionen“ erscheint in der Liste; nach Programmneustart lädt die Auswahl `dbl` wieder; im Menü Datei gibt es kein „Funktionen laden“ mehr | – |
| F-07 | Bibliotheken nicht mitspeichern | Bibliotheken → statistik; eigene Funktion `{2*}':dbl`; Datei → Funktionen speichern | Meldung „Aus Bibliotheken, nicht gespeichert: …“ mit den Statistik-Funktionen; die Datei enthält nur `dbl`; Datei → Session speichern enthält weiterhin alles | – |

## H: Hilfe

| ID | Test | Schritte | Erwartet | Log |
|---|---|---|---|---|
| H-01 | Hilfe zeilenweise | Zeilenweise Eingabe, `\?!` und Enter | Titel „Fakultät, Variablen und Konstanten anlegen“, drei Verwendungen in Spalten, Text, „Siehe auch“ mit `\?'` und `\?#variablen`; der Stack bleibt unverändert | – |
| H-02 | Startseite | Zeilenweise Eingabe, `\?` und Enter | zuerst „Hilfe in der Konsole“, dann „Hilfe zum RPN-Rechner“ mit den Themen; lange Zeilen an Wortgrenzen umgebrochen | – |
| H-03 | Hilfe zeichenweise | Zeichenweise Eingabe mit Übersicht, `1 2`, dann `\?sin` und Enter | während des Tippens steht `\?sin` hinter der Eingabezeile; nach Enter die Hilfe zu sin unter der Eingabe; die nächste Taste lässt sie verschwinden; der Stack ist unverändert | – |
| H-04 | Abbrechen | Zeichenweise Eingabe, `\?si`, dreimal Backspace | erst verschwinden die Buchstaben, dann `\?` selbst; danach geht die Eingabe normal weiter | – |
| H-05 | Eigene Namen | `{1+}':inc` und `7'!a`, dann `\?inc` und `\?a` | „Eigene Funktion inc“ mit Code `{1+}`, „Variable a“ mit Inhalt 7 | – |
| H-06 | Zu lang für das Fenster | Zeichenweise Eingabe in einem niedrigen Fenster, `\?#` und Enter | die Hilfe endet mit „… vollständig in der zeilenweisen Eingabe“, die Anzeige springt nicht | – |
| H-07 | Im Client | im Client H-03 und H-05 wiederholen | wie in der zeichenweisen Eingabe, die eigenen Namen kommen vom Server | Server |

## S: Socket-Server und Client

| ID | Test | Schritte | Erwartet | Log |
|---|---|---|---|---|
| S-01 | Server allein | `RPN Server` starten | „Multi-Client RPN Server läuft auf Port 4040“ | Server |
| S-02 | Gemeinsamer Start | `Server & Client gleichzeitig` | Client zeigt kurz „Warte auf den Server …“, ist spätestens etwa 1 s nach dem Server bereit | Server |
| S-03 | Erste Zeile | gleich nach dem Verbinden im Client `3 4+` tippen | jede Taste sofort sichtbar, schon in der ersten Zeile | – |
| S-04 | Bedienung | im Client C-01, C-03, C-04, C-06 wiederholen | wie bei der zeichenweisen Eingabe | Server (Nachrichten) |
| S-05 | Zwischenablage | im Client `\c`, `\s`, `\v` | wie X-01, X-02, X-04 | – |
| S-06 | Zwei Clients | zweiten Client starten (`dart run bin/client.dart` in neuem Terminal), in beiden rechnen | jeder hat seinen eigenen Stack | Server (zwei Clients) |
| S-07 | Client beenden | `\q` im Client | Client endet mit „Client beendet“, Server läuft weiter, Log „hat die Verbindung getrennt“ | Server |
| S-08 | Strg+C am Server | Client verbunden; im Server-Terminal Strg+C | Client zeigt „Server wird beendet“ und endet; Server-Log „Strg+C: Server wird beendet …“, „Server beendet“ | Server, Client |
| S-09 | Server hart beendet | Client verbunden; Server mit dem roten Stopp-Knopf beenden | Client zeigt „Die Verbindung zum Server ist getrennt“ und endet | Client |
| S-10 | Client ohne Server | nur `RPN Client` starten, nach ein paar Sekunden Strg+C | „Warte auf den Server …“; nach Strg+C ist das Terminal normal bedienbar | – |
| S-11 | Anderer Port | `dart run bin/server.dart 4042` und `dart run bin/client.dart 4042` | Verbindung klappt, Server meldet Port 4042 | Server |
| S-12 | Menüpunkt | im Menüprogramm Eingabe → Socket Multi-Client; einmal Enter, einmal `j` | Erklärung des externen Starts; Enter führt zurück ins Menü; mit `j` startet der Server, Menü blockiert | Programm |
| S-13 | Stopp aus dem Menü-Server | S-12 mit `j`, Client verbinden; Server per `{"stopp":true}` beenden (z.B. mit PowerShell, siehe unten) | Client zeigt „Server wird beendet“, das Menü ist wieder bedienbar | Programm |
| S-14 | Navigation im Client | im Client C-14 bis C-18 wiederholen | wie in der zeichenweisen Eingabe | – |

`{"stopp":true}` von Hand schicken (PowerShell):

```powershell
$c = New-Object Net.Sockets.TcpClient("127.0.0.1", 4040)
$w = New-Object IO.StreamWriter($c.GetStream()); $w.WriteLine('{"stopp":true}'); $w.Flush(); $c.Close()
```

---

## Vorlage für das Testprotokoll

```
Testprotokoll rpncalc
Datum:         
Tester:        
Version:       (git log --oneline -1)
System:        (z.B. Windows 10, VS Code 1.x, Dart 3.x)
dart test:     ___ Tests, alle grün ja/nein

| ID   | Ergebnis (ok / Fehler / nicht getestet) | Bemerkung |
|------|------------------------------------------|-----------|
| M-01 |                                          |           |
| …    |                                          |           |

Anhang: Logs (mit ID)
```
