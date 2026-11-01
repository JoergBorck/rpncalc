# RPN-Rechner: API-Spezifikation

Stand: 28.10.2026 · Entwurf

Diese Spezifikation beschreibt, wie eine Oberfläche den Rechner benutzt: heute die Konsole, später eine
Flutter-App. Was die Eingaben bedeuten, steht in der [Sprachreferenz](reference.md).

---

## 1. Überblick

Die Klasse `RpnApi` (`lib/rpnapi.dart`) ist die einzige Schnittstelle zwischen Oberfläche und Rechner:

```
Oberfläche ── Eingabezeile ──▶ RpnApi ──▶ Parser ──▶ Calculator
           ◀──── Zustand ─────
```

**Aufgabenteilung**

| Rechner (`RpnApi`) | Oberfläche |
|--------------------|------------|
| Eingaben verarbeiten | Eingaben sammeln (Tastatur, Datei, Socket) |
| Zustand als reine Daten liefern | Zustand darstellen |
| Session als Text exportieren und importieren | Dateien lesen und schreiben |
| Fehler mit Code, Text und Position melden | Fehler anzeigen und markieren |

Der Rechner selbst macht keine Ein- oder Ausgabe. Dadurch können Konsole, Socket-Server und Flutter-App
denselben Kern benutzen.

### Beispiel

```dart
final api = RpnApi();
Zustand z = api.eingabe("3 4+");
print(z.stack.first.wert);       // 7
z = api.eingabe("1 0|/");
print(z.fehler?.text);           // Division durch 0
```

---

## 2. Methoden

| Methode | Ergebnis | Beschreibung |
|---------|----------|--------------|
| `RpnApi()` | | erzeugt einen Rechner im Grundzustand |
| `eingabe(String zeile, {int zeilen = 8})` | `Zustand` | verarbeitet eine Eingabezeile; `zeilen` begrenzt die Stack-Zeilen im Ergebnis |
| `taste(String zeichen)`, `zeilenende()`, `loeschen()` | `Zustand` | Eingabe Zeichen für Zeichen (Kapitel 5); alle mit `{int zeilen = 8}` |
| `zustand({int zeilen = 8})` | `Zustand` | liefert den aktuellen Zustand, ohne etwas zu verändern |
| `reset()` | – | setzt alles zurück: Stack, Variablen, Tags, Funktionen, Code-Stack, Argumente, Einstellungen und einen offenen Code-Block |
| `exportieren({bool nurFunktionen = false})` | `Export` | der Zustand als RPN-Skript (Kapitel 4) |
| `importieren(String text, {bool ersetzen = true})` | `String?` | führt ein Skript aus; `null` oder der erste Fehler (Kapitel 4) |
| `testString({int zeilen = 4})` | `String` | nur für Tests: Stack im Format `Stack: ...[a] [b]<tos` |

### 2.1 Eingabezeilen

- Eine Zeile wird ohne Zeilenende übergeben. Das Zeilenende wirkt wie `_`.
- Enthält der Text Zeilenumbrüche, wirkt das wie mehrere Aufrufe nacheinander. Ein Fehler bricht aber den
  ganzen Text ab: Der Rest wird nicht mehr ausgeführt, damit sich der Stack nicht unbemerkt weiter verändert.
- Ein Leerzeichen am Ende bleibt vorgemerkt und wirkt je nach erstem Token der nächsten Zeile (Sprachreferenz 3.4).
- Ist am Ende einer Zeile ein Code-Block offen, setzt die nächste Zeile ihn fort. `Zustand.codeOffen` zeigt das an.
- `reset()` verwirft einen offenen Block.
- Nach einem Fehler beginnt die nächste Zeile normal. Was vor dem Fehler ausgeführt wurde, bleibt erhalten.
- **Code-Blöcke werden erst beim Ausführen geprüft.** Während ein Block eingegeben wird, sammelt der Rechner
  nur den Text. Ein Fehler darin (z.B. eine unbekannte Funktion) fällt erst auf, wenn der Block mit `X`, einer
  Kontrollstruktur oder als eigene Funktion läuft. Die Position zeigt dann auf diesen Aufruf in der aktuellen
  Zeile, nicht auf die Stelle im Block, auch wenn der Block über mehrere Zeilen ging.

---

## 3. Datenmodell

Alle Klassen sind unveränderliche Datenobjekte: Die Felder sind `final`, die Listen unveränderlich
(`List.unmodifiable`). Ein `Zustand` bleibt also so, wie er geliefert wurde, auch wenn der Rechner weiterläuft.

### 3.1 `Zustand`

| Feld | Typ | Inhalt |
|------|-----|--------|
| `stack` | `List<StackZeile>` | die obersten belegten Zellen, Tos zuerst, höchstens `zeilen` |
| `tiefe` | `int` | Füllstand: Anzahl der belegten Zellen |
| `speicher` | `List<Speicher>` | Variablen, Tags und eigene Funktionen |
| `argumente` | `List<num>` | mit `:` übergebene, noch nicht verbrauchte Argumente, das erste zuerst |
| `winkel` | `AngleMode` | `deg`, `rad` oder `grad` |
| `seed` | `int?` | Startwert des Zufallsgenerators, `null` = echte Zufallszahlen |
| `fehler` | `Fehler?` | Fehler der letzten Eingabe oder `null` |
| `codeOffen` | `bool` | ein Code-Block ist noch nicht abgeschlossen |
| `codeStack` | `List<String>` | Inhalt der Blöcke auf dem Code-Stack, der oberste zuerst, ohne `{ }` |
| `offen` | `String` | Text des offenen Tokens, `""` wenn keins (5.3) |
| `enterVorgemerkt` | `bool` | ein Leerzeichen wartet auf das nächste Token (5.3) |
| `zeile` | `String` | die bisher eingegebene Zeile (5.3) |

### 3.2 `StackZeile`

| Feld | Typ | Inhalt |
|------|-----|--------|
| `position` | `int` | 0 = Tos |
| `wert` | `num` | der Wert |
| `tags` | `List<String>` | Namen der Tags auf dieser Zelle; bei Blöcken mit Element, z.B. `v[1]` |

### 3.3 `Speicher`

| Feld | Typ | Inhalt |
|------|-----|--------|
| `name` | `String` | Name ohne `'` |
| `art` | `SpeicherArt` | `variable`, `tag` oder `funktion` |
| `werte` | `List<num>` | Elemente, Element 0 zuerst; bei Tags die aktuellen Werte der Zellen; bei Funktionen leer |
| `code` | `String` | nur bei Funktionen: der Code ohne `{ }` |
| `schreibschutz` | `bool` | Konstante bzw. Tag mit Schreibschutz |

Die Liste enthält erst die Variablen, dann die Tags, dann die Funktionen, jeweils in der Reihenfolge, in der sie angelegt wurden.

`SpeicherArt` kennt keine eigene Art für Konstanten, denn eine Konstante wird wie eine Variable gelesen.

### 3.4 `Fehler`

| Feld | Typ | Inhalt |
|------|-----|--------|
| `code` | `String` | Fehlercode (Sprachreferenz Kapitel 12) |
| `text` | `String` | lesbarer Text mit Detail, z.B. `Unbekannte Funktion: foo` |
| `position` | `int` | Index des Zeichens in der aktuellen Zeile, bei dem der Fehler erkannt wurde |
| `start` | `int` | Index des ersten Zeichens des fehlerhaften Tokens (5.7) |
| `token` | `String` | Text des fehlerhaften Tokens, z.B. `q` (5.7) |

Der Fehler wird oft erst beim Zeichen **nach** dem Token erkannt: Bei `1q2` ist `position` 2 (die `2`),
gemeint ist aber das `q` mit `start` 1. Zum Markieren ist deshalb `start` die richtige Stelle.

- **Fehler im Code einer eigenen Funktion:** Die Position zeigt auf den Aufruf in der eingegebenen Zeile.
- **Markierung:** Die Konsole setzt ein `^` unter `start`.

---

## 4. Skriptformat

Gespeichert wird der Zustand als RPN-Skript. Das Skript ist selbst eine Eingabe für den Rechner:
**Laden heißt, es Zeile für Zeile auszuführen.** Es ist lesbar, lässt sich von Hand bearbeiten und braucht
kein eigenes Dateiformat.

### 4.1 Aufbau

Jede Zeile hat eine Aufgabe, leere Teile entfallen:

| Zeile | Inhalt | Beispiel |
|-------|--------|----------|
| 1 | Einstellungen: Winkelmodus, ggf. Startwert | `rad_42seed` |
| 2… | je eine eigene Funktion | `{1 2+}':f` |
| … | je eine Variable: Werte (tiefstes zuerst), dann `n:'!name` | `~3_1.5ê~7_2_3:'!v` |
| … | der Stack von unten nach oben; ein Tag wird gesetzt, sobald seine oberste Zelle liegt | `1_2_3_2:'\|t` |
| … | der Code-Stack, der unterste Block zuerst | `{x}{y}` |
| letzte | offene Argumente | `5:` |

Die offenen Argumente stehen am Ende, weil sie sonst vom ersten `'!` oder `'|` beim Laden verbraucht würden.

Konstanten werden mit `n:'!!name` geschrieben, Tags mit Schreibschutz mit `n:'||name`.

### 4.2 Schreibweise

- **Trenner:** Werte werden mit `_` getrennt, damit beim Laden kein Enter entsteht.
- **Negative Zahlen und Exponenten** werden mit `~` und `ê` geschrieben: `~3`, `1.5ê~7`.
- **Ganze Zahlen** stehen ohne `.0`.
- **Unendlich und NaN** lassen sich nicht ausdrücken. Sie werden als 0 geschrieben, und der Export liefert eine Warnung.
- **Zeilenenden:** Beim Import werden `\r\n` und `\n` akzeptiert.

### 4.3 Export

```dart
typedef Export = ({String text, List<String> warnungen});
```

Mit `nurFunktionen: true` enthält das Skript nur die eigenen Funktionen. So lässt sich eine Sammlung von
Funktionen weitergeben.

### 4.4 Import

- `ersetzen: true` (Standard) setzt den Rechner vorher zurück. `ersetzen: false` ergänzt den bestehenden
  Zustand, z.B. um Funktionen nachzuladen.
- Ergebnis `null` heißt erfolgreich. Sonst kommt der erste Fehler mit Zeilennummer zurück, z.B.
  `Zeile 2: Variable ist nicht definiert: q`. Die Zeilen bis dahin sind ausgeführt.
- Ist am Ende ein Code-Block offen, ist das ein Fehler: `Ein Code-Block ist am Ende nicht abgeschlossen`.

---

## 5. Eingabe Zeichen für Zeichen

Bisher übergibt die Oberfläche ganze Zeilen. Für eine Bildschirmtastatur und eine Anzeige, die bei jedem
Tastendruck mitläuft, soll der Rechner auch einzelne Zeichen annehmen.

### 5.1 Methoden

| Methode | Ergebnis | Beschreibung |
|---------|----------|--------------|
| `taste(String zeichen)` | `Zustand` | verarbeitet ein einzelnes Zeichen |
| `zeilenende()` | `Zustand` | schließt die Zeile ab, wie das Zeilenende bei `eingabe` |
| `loeschen()` | `Zustand` | nimmt das zuletzt eingegebene Zeichen zurück (5.4) |

**Grundregel:** `eingabe(zeile)` ist dasselbe wie `taste()` für jedes Zeichen der Zeile und danach
`zeilenende()`. Beide Wege liefern denselben Zustand. Das lässt sich mit allen vorhandenen Testfällen prüfen.

### 5.2 Wann wird ausgeführt?

Ein Token wird ausgeführt, sobald feststeht, dass es zu Ende ist. Das ist der Fall, wenn das nächste Zeichen
nicht mehr dazu passt, oder beim Zeilenende. Bis dahin ist es **offen**.

| Taste | offen | Enter vorgemerkt | Stack | Bemerkung |
|-------|-------|------------------|-------|-----------|
| `1` | `1` | | | die Zahl kann noch weitergehen |
| `2` | `12` | | | |
| `␣` | | ja | `12` | 12 ist fertig, das Enter wartet |
| `3` | `3` | ja | `12` | noch offen, das Enter ist noch nicht entschieden |
| `+` | | | `15` | 3 ist fertig (Zahl ␣ Zahl trennt nur, kein dup), `+` wird sofort ausgeführt |
| Zeilenende | | | `15` | nichts mehr offen |

Das Beispiel zeigt, warum die Anzeige das vorgemerkte Enter kennen muss: Erst das **nächste fertige** Token
entscheidet, ob es als dup wirkt. Bei `12␣*` wirkt es als dup, das Ergebnis ist 144.

Ein einfacher Operator wie `+` ist sofort fertig. Offen bleiben Präfixe, die noch länger werden können,
z.B. `~` (zu `~/`) oder `'` (zu `'x`).

Ein Code-Block wird nur gesammelt und erst nach der schließenden Klammer als Ganzes abgelegt.

### 5.3 Neue Felder im `Zustand`

| Feld | Typ | Inhalt |
|------|-----|--------|
| `offen` | `String` | Text des offenen Tokens, `""` wenn keins |
| `enterVorgemerkt` | `bool` | ein Leerzeichen wartet auf das nächste Token (Sprachreferenz 3.4) |
| `zeile` | `String` | die bisher eingegebene Zeile bzw. der Eingabepuffer (5.5), damit die Oberfläche einen Ausschnitt anzeigen und den Fehler markieren kann (5.7) |
| `zeileFertig` | `bool` | die Zeile ist abgeschlossen (nach `zeilenende` oder `eingabe`); die nächste Taste beginnt eine neue Zeile |

`enterVorgemerkt` ist auch bei `eingabe` nützlich: Endet eine Zeile mit einem Leerzeichen, kann die Anzeige
das wie beim HP sichtbar machen.

Nach einer abgeschlossenen Zeile zeigen `zeile` und `fehler` noch diese Zeile, bis die nächste Taste kommt. So
kann die zeilenweise Eingabe den Fehler markieren. Bei `zeileFertig` zeigt die zeichenweise Eingabe dagegen eine
leere Eingabezeile, denn reparieren lässt sich eine abgeschlossene Zeile nicht mehr (`loeschen` tut dann nichts).
Das gilt auch, wenn vorher in einer anderen Oberfläche oder Eingabeart gerechnet wurde.

### 5.4 Löschen

- **Im offenen Token:** Das letzte Zeichen wird entfernt. Der Rechner verarbeitet das Token dazu intern neu
  vom Anfang, denn der DEA kann keinen Schritt zurück.
- **Ein vorgemerktes Enter:** Löschen nimmt die Vormerkung zurück. Hat das Leerzeichen selbst schon ein
  früheres Enter ausgeführt (zwei Leerzeichen hintereinander), gilt es als ausgeführt und bleibt.
- **Nach dem Zeilenende** wirkt Löschen nicht mehr.
- **Nach einem Fehler:** siehe 5.6.
- **Schon ausgeführte Token:** braucht ein Undo (vorgemerkt, siehe 9). Löschen nimmt dann die Wirkung des
  Tokens zurück und öffnet es wieder zum Bearbeiten.

### 5.5 Ohne Zeilenende

Bei der Zeicheneingabe muss kein Zeilenumbruch mehr kommen. Die Eingabe ist ein fortlaufender Strom von
Tasten, wie beim HP. Drückt man doch die Return-Taste, wirkt das wie `zeilenende()`.

- **`zeile`** ist ein laufender Eingabepuffer. Er beginnt nach `reset()` und nach einem Zeilenende neu.
  Positionen in `Fehler` sind Indizes in diesen Puffer.
- **Return nach einem Fehler** beginnt wie bei `eingabe()` eine neue Zeile: Die Tasten nach dem Fehler werden
  verworfen, die Sperre ist aufgehoben, der Stack bleibt unverändert. Return wirkt dann also wie Verwerfen (5.6).
- **Das letzte Token** bleibt offen, bis die nächste Taste es abschließt, z.B. ein Leerzeichen oder ein
  Operator. Es steht sichtbar in `offen`, ist aber noch kein Stack-Wert.

### 5.6 Fehler

Ein Fehler darf den Stack nicht unbemerkt weiter verändern. Deshalb gilt:

1. **Ein Fehler sperrt die Eingabe.** Weitere Tasten werden nicht ausgeführt. Der Stack bleibt so, wie er vor
   dem fehlerhaften Token war, denn ein fehlerhaftes Token legt seine Werte zurück.
2. **Löschen repariert.** Löschen nimmt zuerst die Tasten nach dem Fehler zurück, dann die Taste, die den
   Fehler ausgelöst hat. Danach ist das fehlerhafte Token wieder offen und lässt sich korrigieren. Die Sperre
   ist aufgehoben.
   Beispiel `1q2`: Die `2` schließt `q` ab, `q` ist unbekannt. Löschen nimmt die `2` zurück, `q` ist wieder
   offen. Ein zweites Löschen entfernt das `q`.
3. **Verwerfen:** Return (5.5) hebt die Sperre auf und verwirft das fehlerhafte Token samt der Tasten danach,
   ohne den Stack anzufassen. Ob es zusätzlich eine eigene Taste wie `Esc` braucht, ist offen (siehe 9).

Bei `eingabe()` bleibt es beim bisherigen Verhalten: Der Rest des Textes wird nicht ausgeführt, die nächste
Eingabe beginnt normal.

### 5.7 Anzeige der Eingabe

Der Eingabepuffer kann lang werden. Die Oberfläche zeigt deshalb **nicht die ganze Zeile**, sondern einen
Ausschnitt um die Stelle, an der gerade gearbeitet wird:

```
…7 3+ 1q2 5
       ^
Unbekannte Funktion: q
```

Davor stehen höchstens x Zeichen, das fehlerhafte Token `q` ist markiert, `2 5` wurde nicht mehr ausgeführt.

| Teil | Inhalt | Quelle |
|------|--------|--------|
| davor | höchstens x Zeichen vor dem fehlerhaften Token, abgeschnitten mit `…` | `zeile` bis `fehler.start` |
| Token | das fehlerhafte Token, markiert | `fehler.start`, `fehler.token` |
| danach | die Tasten nach dem Fehler, die nicht ausgeführt wurden, z.B. ausgegraut | `zeile` ab `fehler.position` |

Ohne Fehler zeigt sie die letzten x Zeichen und das offene Token. Wie groß x ist, entscheidet die Oberfläche
nach dem Platz, den sie hat. Die API liefert dafür nur die Daten, keinen fertigen Ausschnitt.

---

## 6. Zustand als JSON

Für Socket, Client und später andere Programme wird der Zustand als JSON übertragen.

- `Zustand.toJson()` liefert eine `Map<String, Object?>`, `Zustand.fromJson(map)` baut ihn wieder auf.
  `jsonEncode(zustand)` aus `dart:convert` ruft `toJson()` selbst auf. Ebenso gibt es `toJson`/`fromJson`
  für `StackZeile`, `Speicher` und `Fehler`.
- Die Feldnamen sind dieselben wie in Dart (`stack`, `tiefe`, `speicher`, …).
- Aufzählungen als Text: `"winkel"` ist `"deg"`, `"rad"` oder `"grad"`, `"art"` ist `"variable"`, `"tag"`
  oder `"funktion"`.
- Ganze Zahlen werden ohne `.0` geschrieben (`7` statt `7.0`), soweit JSON sie exakt darstellen kann (bis 2⁵³).
- `NaN` und unendlich gibt es in JSON nicht. Sie werden als Text geschrieben: `"NaN"`, `"Infinity"`, `"-Infinity"`.
- Ein mit `fromJson` gelesener Zustand ist unveränderlich wie das Original.
- Über einen Socket wird pro Zustand eine Zeile mit einem JSON-Objekt gesendet. So kann der Empfänger einfach
  zeilenweise lesen.

```json
{"stack":[{"position":0,"wert":7,"tags":[]}],"tiefe":1,"speicher":[],"argumente":[],
 "winkel":"deg","seed":null,"fehler":null,"codeOffen":false,"codeStack":[],
 "offen":"","enterVorgemerkt":false,"zeile":"3 4+","zeileFertig":false}
```

(Im Beispiel ist die Zeile umbrochen, gesendet wird sie in einem Stück.)

### 6.1 Protokoll über einen Socket

Der Socket-Server (`bin/server.dart`) macht die API über das Netz verfügbar. Er rechnet, der Client zeigt an.
So lässt sich die Trennung erproben, die später auch die Flutter-App hat: Tasten hinein, Zustand heraus.

**Verbindung**

- TCP auf Port 4040, Text in UTF-8. Server und Client nehmen einen anderen Port als Argument:
  `dart run bin/server.dart 4042`.
- In beide Richtungen eine Nachricht pro Zeile, jede Nachricht ein JSON-Objekt.
- Jede Verbindung bekommt einen eigenen Rechner (`RpnApi`). Er besteht, bis die Verbindung endet.
- Gleich nach dem Verbinden schickt der Server den Zustand, damit der Client etwas anzeigen kann.

**Client → Server.** Jede Nachricht hat genau einen Schlüssel, der sagt, was zu tun ist. Er entspricht einer
Methode der API:

| Nachricht | Methode | Bedeutung |
|---|---|---|
| `{"taste":"3"}` | `taste` | ein Zeichen, oder mehrere wie getippt (z.B. eingefügter Text) |
| `{"zeilenende":true}` | `zeilenende` | Enter |
| `{"loeschen":true}` | `loeschen` | Backspace |
| `{"eingabe":"3 4+"}` | `eingabe` | eine ganze Zeile |
| `{"zustand":true}` | `zustand` | nur den Zustand abfragen |
| `{"hilfe":"!"}` | `hilfe` | Hilfe zu einer Kennung abfragen (Kapitel 8), ändert den Rechner nicht |
| `{"stopp":true}` | – | beendet den Server (zum Ausprobieren, wie bisher `exit`) |

Optional kann jede Nachricht `"zeilen": n` mitgeben, wie viele Stack-Zeilen der Zustand enthalten soll
(Standard 8).

**Server → Client.** Auch hier sagt der Schlüssel, was die Nachricht ist:

| Nachricht | Bedeutung |
|---|---|
| `{"zustand":{…}}` | der Zustand nach der Nachricht des Clients, aufgebaut wie in Kapitel 6 |
| `{"hilfe":{…}}` | die Antwort auf `{"hilfe":…}`: der Eintrag wie in Kapitel 8, oder `null`, wenn es keinen gibt |
| `{"protokollfehler":"…"}` | die Nachricht war kein gültiges JSON oder ist unbekannt; der Rechner bleibt unverändert |
| `{"ende":"…"}` | der Server wird beendet und schließt danach die Verbindung; kommt ohne Anfrage, an alle Clients |

- **Auf jede Nachricht genau eine Antwort.** Der Client kann also nach jeder Nachricht auf die Antwort warten
  und erst dann neu zeichnen (synchrone Anzeige).
- **Fehler beim Rechnen** sind keine Protokollfehler. Sie stehen wie immer im Feld `fehler` des Zustands.
- **Ausnahme `stopp`:** Darauf antwortet der Server nicht mit einem Zustand, sondern schickt allen Clients
  `{"ende":…}`.

**Server beenden**

- Mit Strg+C im Terminal des Servers oder mit `{"stopp":true}` von einem Client.
- In beiden Fällen beendet sich der Server geordnet: Er schickt jedem Client `{"ende":"Server wird beendet"}`,
  schließt alle Verbindungen und schreibt „Server beendet“ ins Log.
- Wird der Server im Menüprogramm gestartet, beendet Strg+C das ganze Programm. Dort geht es nur mit `stopp`.

> **Warum ein Schlüssel pro Nachricht und der Zustand eingepackt?** So kann das Protokoll wachsen, ohne dass
> alte Clients durcheinanderkommen. Später kommen z.B. `{"ausgabe":"…"}` für `print` oder eine Abfrage für
> `input` dazu (Kapitel 9). Ein Client, der einen Schlüssel nicht kennt, kann die Nachricht überspringen.

**Konsolen-Client (`bin/client.dart`)**

- Liest die Tastatur im Rohmodus und schickt jede Taste als Nachricht. Die Bedienung ist dieselbe wie bei der
  zeichenweisen Eingabe: Enter, Backspace, `\q` beendet den Client.
- Die Zwischenablage gehört zum Client, weil sie auf dessen Rechner liegt: `\c` und `\s` kopieren aus dem
  zuletzt empfangenen Zustand, `\v` schickt die Zahlen als `{"taste":"_…_"}`.
- Die Anzeige ist dieselbe wie bei der zeichenweisen Eingabe im Menüprogramm (gemeinsamer Code in
  `lib/console/screen.dart`).
- Beendet der Client sich, schließt er nur seine Verbindung. Der Server läuft weiter.
- Kommt `{"ende":…}` oder bricht die Verbindung ab, verlässt der Client die Eingabe sofort und zeigt den Grund an.
- Läuft beim Start noch kein Server, versucht der Client es jede Sekunde wieder.

---

## 7. Aufgaben der Oberfläche

| Aufgabe | Heute (Konsole) | Später (Flutter) |
|---------|-----------------|------------------|
| Eingabe | Zeile für Zeile über `stdin`, zurück zum Menü mit `\q`; oder Taste für Taste im Rohmodus (Backspace löscht, die letzten 5 Zeilen bleiben sichtbar, `\q` führt zurück; Strg+C beendet unter Windows das ganze Programm) | Bildschirmtastatur; Enter auf der Leertaste |
| Anzeige | `Anzeige.kompakt` / `Anzeige.uebersicht` (`lib/console/display.dart`); der Tos hellorange hinterlegt, vor der Eingabe `RPN>` mit „RPN“ in Orange | eigene Widgets auf Basis von `Zustand` |
| Fehler | `^` unter der Fehlerstelle | Markierung in der Eingabe |
| Zwischenablage | `\c` kopiert den Tos, `\s` den Stack (tiefster zuerst), für ein deutsches Excel: Dezimalkomma, getrennt mit `;`. Ein offenes Token wird vorher mit `_` abgeschlossen, wie eine Funktionstaste beim HP die Zahleneingabe abschließt (nach `2.25` kopiert `\c` also 2,25); geht das nicht, bleibt es offen. In der zeilenweisen Eingabe dürfen `\c` und `\s` auch am Ende einer Zeile stehen (`2.25\c`): erst wird die Zeile gerechnet, dann kopiert, bei einem Fehler nicht. `\v` fügt alle Zahlen aus der Zwischenablage ein (siehe unten) | `Clipboard.setData` / `getData` von Flutter |
| Hilfe | `\?` und ein Zeichen, Name oder Thema zeigt die Hilfe dazu (siehe unten und Kapitel 8) | Hilfe-Modus und Tooltips ([app.md](app.md) Kapitel 5) |
| Dateien | Menü „Datei“: Session speichern und laden (Endung `.rpn`), Funktionen speichern (Endung `.rpnlib`, laden über „Bibliotheken“) | Projekte, automatisch speichern |
| Bibliotheken | Menü „Bibliotheken“: alle `.rpnlib`-Dateien unterhalb des Elternverzeichnisses des Startverzeichnisses, ergänzen die eigenen Funktionen | mitgelieferte Bibliotheken als Assets |
| Menü | Menü zwischen den Eingaben | Bedienelemente der App |

Die Klasse `Anzeige` ist eine Hilfe für die Konsole und gehört nicht zur API.

**Bibliotheken:** Eine Bibliothek ist eine Datei mit der Endung `.rpnlib`, z.B. `library/schwingungen.rpnlib`.
Gespeicherte Sessions haben die Endung `.rpn` und erscheinen deshalb nicht als Bibliothek. Aufbau siehe 9.1.

- **Suche:** Beim Öffnen des Menüs werden alle `.rpnlib`-Dateien unterhalb des Elternverzeichnisses des
  Startverzeichnisses gesucht (damit auch das Startverzeichnis selbst). Übersprungen werden versteckte
  Verzeichnisse (`.git`, `.dart_tool` …), `build` und `node_modules`, und es geht höchstens 5 Ebenen tief.
- **Menü:** Unter „Bibliotheken“ steht jede gefundene Bibliothek mit ihrem Namen ohne Endung. Gibt es einen
  Namen mehrfach, steht das Verzeichnis dahinter. Die Auswahl lädt die Bibliothek und ergänzt damit die
  eigenen Funktionen. Ein eigener Menüpunkt „Funktionen laden“ ist deshalb nicht nötig.
- **Eigene Bibliotheken:** „Funktionen speichern“ schlägt `funktionen.rpnlib` vor. So erscheinen selbst
  gespeicherte Funktionen beim nächsten Mal ebenfalls im Menü.
- **Mitgelieferte Bibliotheken:** Die Bibliotheken im Verzeichnis `library` gehören zum Programm. Der Rechner
  merkt sich zu jeder Funktion, aus welcher Bibliothek sie stammt (reference.md 10.6), und „Funktionen
  speichern“ lässt diese Funktionen aus; alle anderen werden gespeichert. So landen in `funktionen.rpnlib` nur die
  eigenen. „Session speichern“ speichert weiterhin alles, und „Session laden“ vergisst die geladenen
  Bibliotheken (die Session ersetzt den ganzen Rechner).

**Navigation:** In der zeichenweisen Eingabe und im Client gibt es Bereiche, zwischen denen Tab wechselt. Eine
Hilfezeile unter der Eingabe zeigt sie, der gewählte steht in Orange.

| Bereich | ↑ / ↓ | ← / → |
|---|---|---|
| Stack | ↓ zeigt tiefere Werte, ↑ wieder Richtung Tos | – |
| Verlauf | ↑ blättert zu älteren Zeilen (bis zu 100), ↓ zurück | schiebt die Zeilen seitlich; ein Fehler außerhalb wird mit ← bzw. → angezeigt |
| Variablen (Variablen und Tags) | blättert in der Liste | schiebt die Werte seitlich, der Name bleibt stehen |
| Funktionen | blättert in der Liste | schiebt den Code seitlich, der Name bleibt stehen |

- **Kompakte Anzeige:** Nur Stack und Verlauf, weil Variablen und Funktionen dort in einer Zeile stehen.
- **Übersicht:** Die zweite Spalte zeigt entweder Variablen und Tags oder Funktionen, je nachdem, welcher der
  beiden Bereiche zuletzt gewählt war. Stack und zweite Spalte zeigen höchstens 8 Zeilen.
- **Seitlich schieben:** → und ← bewegen im Verlauf, bei Variablen und Funktionen jede sichtbare Zeile um ein Zeichen, jede für sich: höchstens bis
  ihr Ende am Spaltenrand steht bzw. bis zu ihrem Anfang. Was ganz in die Spalte passt, bleibt stehen.
- **Nach einer Eingabe** (Taste, Enter, Backspace) springen Stack und Verlauf zurück zum Tos bzw. zur neuesten
  Zeile, geschobene Verlaufszeilen wieder auf Fehler bzw. Ende; der gewählte Bereich bleibt.
- **Tasten:** Pfeiltasten kommen als Escape-Folgen (`Esc [ A` … `D`). Unter Windows schaltet die Konsole dafür
  „Virtual Terminal Input“ ein (`lib/console/terminal.dart`) und am Ende wieder aus, und zwar erst nach dem
  Zurückschalten des Zeilenmodus, weil Dart dabei selbst am Konsolenmodus dreht. Sonst kämen die Pfeiltasten in
  der zeilenweisen Eingabe als `^[[A` an. Ein einzelnes Esc wird
  überlesen; zurück geht es weiterhin mit `\q`.

**Offenes Token über dem Stack:** Beim HP steht die Zahl, die man gerade tippt, schon im X-Register. Hier liegt
ein Token erst auf dem Stack, wenn es zu Ende ist (nach `1 22 333` ist 22 der Tos, `333` ist noch offen). Damit
man trotzdem sieht, was gerade entsteht, zeigt die Anzeige das offene Token (`Zustand.offen`) grau über dem Tos.

- **Was:** jedes offene Token, so wie es getippt wurde: Zahlen (`333`, `3.5ê~`, `~4`), Namen (`si`), Namen mit
  Präfix (`'!a`), ein offener Code-Block (`{1 2`). Ist es zu lang, wird der Anfang mit „…“ gekürzt, das Ende
  bleibt sichtbar.
- **Wann nicht:** wenn kein Token offen ist (auch nach einem vorgemerkten Enter allein, `4 `), nach einem Fehler
  (dann markiert die Eingabezeile den Fehler) und wenn der Stack zurückgeblättert ist.
- **Nur solange ein Token offen ist** gibt es diese Zeile; eine leere Platzhalterzeile gibt es nicht.
- **Übersicht:** eine graue Zeile `>:` über Position 0, der Text rechtsbündig wie die Werte. Sie zählt zu den
  8 Zeilen des Stacks: Bei einem vollen Stack rutscht der unterste sichtbare Wert dafür in „… n weitere“, die
  Anzeige wird also nie höher als 8 Stackzeilen. Bei weniger Werten kommt die Zeile einfach dazu.

  ```
   >:              333
   x:               22
   y:                1
  ```

- **Namen der Positionen:** Die Übersicht nennt die Positionen x, y, z, t, darunter ₄, ₅ … wie die App
  (reference.md 2.1).

- **Kompakte Anzeige:** grau hinter dem Tos: `deg │ [1] [22]<tos >:333`.
- Die Eingabezeile zeigt das offene Token weiterhin unterstrichen (5.7); die Zeile über dem Stack kommt hinzu.
- Gilt für die zeichenweise Eingabe und den Client. In der zeilenweisen Eingabe ist nach einer Zeile nie ein
  Token offen.

**Hilfe mit `\?`:** Hinter `\?` steht die Kennung (Kapitel 8.1), abgeschlossen mit Enter: `\?!`, `\?sin`,
`\?#tags`, `\?konsole:v`. Die Eingabe dafür geht nicht an den Rechner, Stack und Zeile bleiben unverändert.

- **Ausgabe:** Titel, alle Verwendungen als Tabelle (Schreibweise, Stack, Argumente, Kurztext), die
  Einzelheiten und zuletzt „Siehe auch: …“ mit den Titeln der Verweise und dem Aufruf dazu:

  ```
  !  Fakultät, Variablen und Konstanten anlegen
     x!      x → x!            Fakultät
     '!x     n (1)             legt die Variable x mit n Elementen an
     '!!x    n (1)             legt die Konstante x mit n Elementen an
     "5'!a" legt a = 5 an, "1 2 3 3:'!v" das Feld v = 3 2 1.
     Siehe auch: Namen (\?'), Variablen (\?#variablen), Konstanten (\?#variablen)
  ```

- **`\?#`** zeigt die Startseite der Hilfe (8.1), davor die der Konsole. **`\?` allein** mit Enter zeigt
  ebenfalls die Startseite.
- **Unbekannte Kennung:** Meldung „Keine Hilfe zu …“ und, wenn es ähnliche gibt, Vorschläge.
- **Zeichenweise Eingabe:** Nach `\?` sammelt die Konsole die Zeichen der Kennung bis Enter und zeigt sie
  hinter der Eingabezeile an. Backspace löscht das letzte Zeichen, Backspace direkt nach `\?` bricht die
  Hilfe ab. Die Hilfe steht unter der Eingabe, bis die nächste Taste gedrückt wird. Ist sie höher als das
  Fenster, wird sie gekürzt und endet mit „… vollständig in der zeilenweisen Eingabe“.
- **Zeilenweise Eingabe:** Eine Zeile, die mit `\?` beginnt, wird nicht gerechnet, sondern zeigt die Hilfe.
- **`\` ist damit belegt für:** `\q`, `\c`, `\s`, `\v` und `\?`. Alle anderen Folgen bleiben für spätere
  Sonderzeichen frei.

**Einfügen mit `\v`:** Die Oberfläche sucht im Text der Zwischenablage alle Zahlen und gibt sie dem Rechner
in seiner Schreibweise, getrennt mit `_`. Die erste Zahl kommt zuerst auf den Stack, die letzte ist der Tos.

- **Erkannt** werden Zahlen in deutscher und englischer Schreibweise: `3,4`, `3.4`, `-2`, `3,4E-06`, `1e5`.
  Sie werden umgeschrieben: `3,4E-06` wird zu `3.4ê~6`, `-2` zu `~2`.
- **Übersprungen** wird alles andere: Tab, `;`, Zeilenumbrüche, Leerzeichen, Text wie Spaltenüberschriften
  oder `#DIV/0!`.
- **Ein Minus** gilt nur als Vorzeichen, wenn davor keine Ziffer und kein Buchstabe steht. So wird `2026-10-29`
  zu den drei Zahlen 2026, 10 und 29 und nicht zu 2026, −10 und −29.
- **Eine Zahl hat höchstens ein Dezimalzeichen.** Tausenderpunkte erkennt `\v` nicht: `1.234,5` ergibt 1,234
  und 5. Excel kopiert Zahlen ohne Tausenderpunkte, solange die Zelle nicht so formatiert ist.
- **Zeilenweise Eingabe:** Die Zahlen werden als eine Zeile ausgeführt. **Zeichenweise Eingabe:** Sie werden
  wie getippt an die aktuelle Zeile angehängt, mit `_` davor und danach, damit sie nicht mit Zahlen davor oder
  danach verschmelzen.
- **Meldung:** wie viele Zahlen eingefügt wurden, z.B. „100 Zahlen eingefügt“. Bei Wertepaaren für `sadd`
  (Statistik-Bibliothek) ist die Anzahl der Paare die Hälfte: `50:sall`.

---

## 8. Hilfe

Der Rechner bringt Hilfetexte zu seiner Sprache mit. So gibt es sie nur einmal: Die Konsole zeigt sie mit `\?`
(Kapitel 7), die App im Hilfe-Modus und in Tooltips ([app.md](app.md) Kapitel 5), ein Client könnte sie über
den Socket abfragen. Die ausführliche Beschreibung bleibt [reference.md](reference.md); die Hilfetexte sind
kürzer und werden von Hand mit ihr abgeglichen.

**Ablage:** Die Texte stehen in `library/system/hilfe.de.rpnlib`, im selben Format wie die Hilfe von
Bibliotheken (`{{"hilfe":[…]}}rpnjson`, 9.1), ein Eintrag je Zeile. Sie werden wie die mitgelieferten
Bibliotheken einkompiliert (`tool/bibliotheken.dart`, Konstante `systemBibliotheken`) und beim ersten Nachschlagen
geladen. Systemdateien erscheinen nicht unter `bibliotheken()`. Das `.de` im Namen hält den Weg zu weiteren
Sprachen offen (Punkt 14).

### 8.1 Einträge

Ein Eintrag gehört zu einem Zeichen, einem Namen oder einem Thema und beschreibt **alle Verwendungen**, denn
viele Zeichen bedeuten je nach Umgebung etwas anderes: `!` ist die Fakultät, nach `'` legt es eine Variable
(`'!x`) oder eine Konstante (`'!!x`) an.

| Feld | Bedeutung | Beispiel für `!` |
|---|---|---|
| `kennung` | Zeichen oder Name wie in der Sprache, Themen mit `#` | `!` |
| `titel` | kurze Überschrift | `Fakultät, Variablen und Konstanten anlegen` |
| `verwendungen` | Liste von `Verwendung`, siehe unten | `x!`, `'!x`, `'!!x` |
| `text` | Einzelheiten mit Beispielen, darf Verweise enthalten (8.3); leer, wenn es keine gibt | `"5'!a" legt a = 5 an …` |

Eine `Verwendung` hat diese Felder:

| Feld | Bedeutung | Beispiel |
|---|---|---|
| `schreibweise` | wie man es schreibt | `'!x` |
| `stack` | Wirkung auf den Stack ohne Argumente, leer wenn keine (Schreibweise wie reference.md 1) | `x → x!` |
| `kurz` | ein Satz, was es **ohne Argumente** tut; passt in einen Tooltip | `legt die Variable x an` |
| `argumente` | Liste von `Argument`, siehe unten; leer, wenn es keine gibt | |
| `beispiel` | ein Satz, was das Beispiel mit allen Argumenten tut; nur zusammen mit `argumente` | |
| `beispielStack` | Wirkung des Beispiels auf den Stack, leer wenn sie die Spalte sprengen würde | |

Ein `Argument` beschreibt ein Argument, in der Reihenfolge, in der man sie schreibt (`a:b:c:S`):

| Feld | Bedeutung | Beispiel für das erste Argument von `S` |
|---|---|---|
| `name` | kurzer Name für die Kurzform | `ziel` |
| `vorgabe` | Wert, wenn das Argument fehlt | `1` |
| `beispiel` | Zahl für das Beispiel | `4` |
| `wirkung` | ein Satz, was das Argument mit der Beispielzahl bewirkt | `tauscht mit ≡₄ statt mit y` |
| `stack` | Wirkung auf den Stack mit diesem Argument, leer wenn keine oder zu lang | `≡₄ t z y x → x t z y ≡₄` |

Ein vollständiges Beispiel für `S` (Tauschen):

```json
{"schreibweise":"S", "stack":"y x → x y", "kurz":"tauscht x und y",
 "argumente":[
   {"name":"ziel",   "vorgabe":"1", "beispiel":"4", "wirkung":"tauscht mit ≡₄ statt mit y",
    "stack":"≡₄ t z y x → x t z y ≡₄"},
   {"name":"quelle", "vorgabe":"0", "beispiel":"1", "wirkung":"tauscht ab y statt ab x"},
   {"name":"anzahl", "vorgabe":"1", "beispiel":"2", "wirkung":"tauscht je 2 Werte"}],
 "beispiel":"tauscht y mit ≡₄ und z mit ≡₅"}
```

- **Abgeleitet:** Die Kurzform für die Konsole entsteht aus Namen und Vorgaben (`ziel:quelle:anzahl (1:0:1)`),
  die Eingabe des Beispiels aus den Beispielzahlen und der Schreibweise (`4:1:2:S`). Beides steht deshalb nicht
  im Eintrag.
- **Tooltip** ([app.md](app.md) 5.1): je Argument eine Zeile `▢:1:S  tauscht ab y statt ab x`, die schon
  erklärten Argumente als Kästen, zuletzt `4:1:2:S` mit dem `beispiel`. Bei nur einem Argument gibt es nur
  diese Beispielzeile (`3:D  z y x → –  entfernt x, y und z`). Die Kästen stehen für die Beispielzahlen davor; die letzte Argumentzeile meint deshalb dieselbe Eingabe wie die
  Beispielzeile und zeigt keinen eigenen Stack. Die Vorgabe steht nicht im Tooltip; was
  ohne Argument geschieht, sagt schon die erste Zeile. Einschränkungen (z.B. keine negativen Positionen) stehen
  ebenfalls nicht dort, so wenig wie „Nenner ≠ 0“ beim Teilen.
- **Ältere Einträge:** Ist `argumente` ein Text (`"n (1)"`, bisheriges Format, z.B. in Bibliotheken), gilt er als
  Kurzform ohne Einzelheiten; der Tooltip zeigt dann keinen Argument-Bereich.

**Kennungen:**
- **Zeichen und Namen** wie im Rechner: `!`, `~`, `'`, `sin`, `S`, `round`. Zeichen, die nur zusammen
  vorkommen, haben einen gemeinsamen Eintrag beim ersten Zeichen: `~²` steht bei `~` und bei `²`.
- **Startseite:** `#` allein ist die Startseite der Hilfe: eine kurze Einführung und Verweise auf alle Themen
  und auf `#alle`, die Übersicht aller Zeichen und Namen nach Gruppen.
- **Themen** beginnen mit `#`: `#zahlen`, `#trenner`, `#enter`, `#stack`, `#argumente`, `#namen`, `#variablen`,
  `#tags`, `#funktionen`, `#code`, `#fehler`, `#winkel`.
- **Oberflächen** haben eigene Einträge mit eigenem Präfix, `app:` bzw. `konsole:` (8.4).

### 8.2 Methoden

| Methode | Beschreibung |
|---|---|
| `Hilfe? hilfe(String kennung)` | der Eintrag zu einer Kennung oder `null`; findet auch die Hilfe verfügbarer Bibliotheken, die nicht geladen sind (z.B. `#statistik`), ohne ihre Funktionen zu laden |
| `List<String> hilfeKennungen()` | alle eingebauten Kennungen, für eine Übersicht |

- **Eigene Namen:** Für eine eigene Funktion, eine Variable oder einen Tag liefert `hilfe` einen erzeugten
  Eintrag: Art, Inhalt bzw. Code und ein Verweis auf `#funktionen`, `#variablen` bzw. `#tags`. Eingebaute
  Namen gehen vor.
- **JSON:** `Hilfe` und `Verwendung` haben `toJson`/`fromJson` wie der `Zustand` (Kapitel 6). Im Protokoll
  (6.1) fragt ein Client mit `{"hilfe": "!"}`, der Server antwortet mit `{"hilfe": {…}}` bzw.
  `{"hilfe": null}`. Eine Hilfe-Anfrage verändert den Rechner nicht.

### 8.3 Verweise

Ein Text darf mit `[[kennung]]` auf einen anderen Eintrag verweisen, z.B. `[[#variablen]]` oder `[['|]]`. Jede
Oberfläche stellt Verweise auf ihre Art dar (App: antippbare Felder, Konsole: „Siehe auch: …“) und zeigt dabei
den Titel des Ziels.

- **Warum `[[ ]]`:** Eckige Klammern sind für Einheiten reserviert, doppelte haben dort keinen Sinn. Ein
  späterer Einheiten-Scanner, der wie der Code-Scanner arbeitet, erkennt sie und kann sie überspringen.
- **Richtung:** Einträge des Rechners verweisen nur auf Einträge des Rechners. Einträge einer Oberfläche
  dürfen auf eigene und auf Einträge des Rechners verweisen, nie umgekehrt.
- `Hilfe.verweise` liefert die Kennungen aller Verweise im Text, in ihrer Reihenfolge.

### 8.4 Aufteilung zwischen Rechner und Oberfläche

| Wo | Was | Beispiele |
|---|---|---|
| **Rechner** | die Sprache: Zeichen, Namen, Begriffe | `!`, `sin`, `S`, `'`, `#stack`, `#tags` |
| **App** | die Bedienung der App | `app:shift`, `app:alpha`, `app:tab`, `app:hilfe`, `app:cursorkreuz`, die Anzeigen `app:eingabe`, `app:stack`, `app:funktionen`, `app:variablen` |
| **Konsole** | die Bedienung der Konsole | `konsole:q`, `konsole:c`, `konsole:v`, `konsole:hilfe`, `konsole:tab` |

- **Nachschlagen:** Eine Oberfläche sucht in ihren eigenen Einträgen und mit `hilfe()` im Rechner. Gibt es
  beides, zeigt sie beide gemeinsam, zuerst den der Oberfläche, dann den des Rechners. Eine Oberfläche darf
  deshalb auch Einträge unter Kennungen des Rechners haben, die ihn ergänzen: Die App erklärt unter `~`, wie
  die Präfix-Taste die Beschriftungen umschaltet, darunter folgt die Bedeutung von `~` in der Sprache.
- **Hilfe zu einem Element** (z.B. die Variable `a` mit dem Wert 7) setzt die Oberfläche zusammen: oben die
  aktuellen Daten aus dem `Zustand`, darunter der Eintrag des Rechners (`hilfe("a")` bzw. das Thema), unten
  die Verweise.

### 8.5 Vollständigkeit

Ein Test prüft, dass jeder Operator, jede eingebaute Funktion, jeder Stackbefehl und jedes Präfix (`~`, `|`,
`'`, `:`) einen Eintrag hat und jeder Verweis ein Ziel. Kommt eine neue Funktion dazu (z.B. `sinh`), fällt
eine fehlende Hilfe sofort auf. Die Oberflächen prüfen dasselbe für ihre Einträge.

---

## 9. Erweiterungspunkte (geplant)

- **Bibliotheken:** siehe 9.1.
- **`print` und `input`:** Programme sollen Text ausgeben und Werte abfragen können. Das braucht Rückrufe in
  die Oberfläche, deren Form noch offen ist.
- **Projekt-Persistenz:** automatisch speichern und beim Start das letzte Projekt laden, aufbauend auf dem Skriptformat.

### 9.1 Bibliotheken

Der Rechner führt das Verzeichnis aller Bibliotheken; die Oberflächen fragen ihn danach, wie bei der Hilfe
(Kapitel 8). Der Rechner arbeitet dabei nur mit Texten. Woher eine hinzugefügte Bibliothek kommt (Datei,
Download, Speicher der App), entscheidet die Oberfläche.

**Mitgelieferte Bibliotheken** sind in den Rechner einkompiliert, damit es sie überall gibt: in der Konsole, im
Client, in der App auf dem Handy und im Browser.

- **Quelle** bleiben die Dateien in `library/`.

**Aufbau einer Bibliothek:** ein einziger Block, den der Rechner beim Laden mit `X` ausführt. Zuerst die
Versionsangabe mit dem Namen, dann die Funktionen, zuletzt die Hilfetexte, beides über `rpnjson`
([reference.md](reference.md) 10.5):

```
{
{{"version":{"name":"statistik","bibliothek":"1.0.0","rechner":"0.1.0"}}}rpnjson
{0 0 0 0 0 0 6:'!ss}':sclr
…
{{"hilfe":[{"kennung":"sclr","titel":"Statistik zurücksetzen", … }]}}rpnjson
}
```

- **Versionsprüfung zuerst:** Passt die Version nicht, bricht `X` sofort ab, und von der Bibliothek wird nichts
  angelegt.
- **Version des Rechners:** `RpnApi.version` (MAJOR.MINOR.PATCH, wie in `pubspec.yaml`). Die Oberfläche teilt
  dem Rechner mit `appVersion` ihre eigene Version mit; die Konsole und der Client tun das nicht, bei ihnen wird
  die Angabe `app` übergangen.
- **Hilfe neu aufbereiten:** Die Oberfläche kann sich die Version einer Bibliothek merken und ihre Hilfe nur neu
  aufbereiten, wenn sie sich geändert hat (`bibliotheksVersion(name)`).
- **Erzeugt:** `dart run tool/bibliotheken.dart` schreibt daraus `lib/bibliotheken.g.dart` mit den Texten als
  Konstanten. Die erzeugte Datei wird mit eingecheckt.
- **Wächter-Test:** Ein Test vergleicht die erzeugte Datei mit den Dateien in `library/`. Wurde eine Bibliothek
  geändert, ohne das Werkzeug laufen zu lassen, schlägt `dart test` fehl.

**Hinzugefügte Bibliotheken** meldet die Oberfläche zur Laufzeit an, z.B. eine heruntergeladene oder selbst
gespeicherte Datei. Sie merkt sich, welche das sind, und meldet sie beim nächsten Start wieder an.

| Methode | Beschreibung |
|---|---|
| `List<({String name, bool mitgeliefert})> bibliotheken()` | alle Bibliotheken, mitgelieferte zuerst, jeweils nach Namen |
| `String? bibliothek(String name)` | der Text einer Bibliothek oder `null` |
| `String? bibliothekHinzufuegen(String name, String text)` | meldet eine Bibliothek an; eine hinzugefügte mit gleichem Namen wird ersetzt. Liefert `null` oder einen Fehler, z.B. wenn eine mitgelieferte so heißt oder der Text kein gültiges Skript aus Funktionen ist |
| `String? ladeBibliothek(String name)` | lädt die Bibliothek in den Rechner wie `importieren(text, ersetzen: false)`; liefert `null` oder den Fehler. Gibt es einen ihrer Namen schon als eigene Funktion oder in einer anderen Bibliothek, wird sie gar nicht geladen („Name ist schon vergeben“) |
| `List<String> bibliotheksFunktionen(String name)` | die Namen ihrer Funktionen in der Reihenfolge der Datei, z.B. für die Funktionstasten |
| `Map<String, Object?>? bibliotheksVersion(String name)` | die Versionsangabe einer geladenen Bibliothek |
| `({String beschreibung, String version, int funktionen})? bibliotheksInfo(String name)` | Kurzinfo, auch ohne die Bibliothek zu laden: der Satz aus `beschreibung`, die Version, die Zahl der Funktionen; für Menüs und Tooltips |
| `List<String> hinweise()` | Hinweise seit dem letzten Abruf, z.B. unbekannte Schlüssel in `rpnjson`; danach leer |
| `Export exportiereBibliothek(String name, {String version, Set<String> ohne})` | die eigenen Funktionen als Bibliothek im obigen Aufbau, mit Versionsangabe und eigener Hilfe |

- **Herkunft:** Der Rechner merkt sich zu jeder Funktion die Bibliothek, aus der sie stammt
  (`geladeneBibliotheksFunktionen`). Solche Funktionen sind geschützt (reference.md 10.6), und „Funktionen
  speichern“ lässt sie aus (Kapitel 7).
- **Protokoll** (6.1): `{"bibliotheken":true}` → `{"bibliotheken":[…]}`; `{"ladeBibliothek":"statistik"}` →
  `{"zustand":{…}}` (ein Fehler steht im Zustand wie bei `importieren`).
- **Konsole:** Das Menü „Bibliotheken“ zeigt die mitgelieferten über die API und dazu die selbst gespeicherten
  `.rpnlib`-Dateien von der Festplatte (Suche wie in Kapitel 7). Dateien im Verzeichnis `library/` überspringt die
  Suche, die kommen aus dem Rechner.
- **Hilfetexte** stehen in derselben Datei über `{{"hilfe":[…]}}rpnjson`. Ohne eigene Hilfe bekommt eine
  Funktion die erzeugte Hilfe mit ihrem Code.
- **Sessions** schreiben eigene Hilfen ebenfalls als `{…}rpnjson`-Zeile mit, damit sie beim Speichern nicht
  verloren gehen.

---

## 10. Offene Punkte

Die Nummern bleiben fest; erledigte Punkte wandern mit ihrer Nummer nach Kapitel 11.

1\. **Einheitliche Fehlercodes:** Grammatikfehler haben einstellige Codes (`1`, `Z`), Rechnerfehler Namen
   (`div0`). Sollen alle Codes einem Schema folgen, z.B. `X1` für die Grammatik?

2\. **Import-Fehler als Daten:** `importieren` liefert einen Text. Für Flutter wäre ein `Fehler` mit Zeilennummer
   besser, damit die Stelle in der Datei markiert werden kann.

3\. **Grenzen einstellbar und interne Felder verbergen:** Die Grenze für `loop` und `times` soll einstellbar
   werden; sie gehört dann in den `Zustand` und ins Skriptformat. Heute senken Tests sie über
   `api.calculator.maxSchleife`. Das ist der einzige Grund, warum `parser` und `calculator` öffentlich sind.
   Gibt es einen offiziellen Weg, können beide privat werden, und keine Oberfläche kann mehr an der API vorbei
   arbeiten.

5\. **Anzeigeformat** (z.B. FIX). **Entschieden:** eine Einstellung des Rechners (Core), im Skript gespeichert
   und im `Zustand` gemeldet; die Oberflächen formatieren die Zahlen danach. Noch zu spezifizieren.

6\. **Version des Skriptformats:** Ändert sich die Sprache (wie bei `~|:`), kann ein gespeicherter Funktionscode
   anders wirken als beim Speichern. Braucht das Skript eine Versionsangabe, und was passiert bei einer alten
   Version?

7\. **Undo (vorgemerkt, noch nicht umsetzen):** Löschen ausgeführter Token (5.4) und ein allgemeines Undo.
   - **Entschieden: Änderungsprotokoll (Journal)**, kein Schnappschuss des ganzen Zustands. Jede Änderung merkt
     sich den alten Wert, Undo spielt sie rückwärts ab. Grund: Werden später Vektoren, Matrizen oder Tabellen
     als Stack-Werte erlaubt (Statistik, Simulation), wären Schnappschüsse pro Token zu groß.
   - **Stellen:** Der Stack ist gut gekapselt, alle Schreibzugriffe laufen über `[]=`, `setzeAn`, `push`,
     `pull`, `drop` und `clear`. Dazu kommen Variablen, Tags, Schreibschutz, eigene Funktionen, Code-Stack,
     Argumente, Einstellungen und die Enter-Logik. `geschuetzt` und `schreibgeschuetzt` sollten dafür nur noch
     über Methoden des Stacks geändert werden.
   - **Zufallsgenerator:** Sein Zustand muss sich zurücksetzen lassen (eigener Generator oder Seed plus Anzahl
     der Ziehungen), sonst liefert dieselbe Eingabe nach einem Undo andere Zahlen.
   - **Offen:** Wie Undo bei laufenden Programmen wirkt (eigene Funktionen, `loop`, `times`): ein Schritt pro
     Token der Eingabe oder pro ausgeführtem Token im Code?

8\. **Verwerfen nach einem Fehler** (5.6): Return verwirft schon. Braucht es zusätzlich eine eigene Taste (z.B. `Esc`)?

9\. **Sondertasten** (5.1): eigene Methoden wie `zeilenende()` und `loeschen()` oder Steuerzeichen in `taste()`
   (`"\n"`, `"\b"`)? Eigene Methoden sind lesbarer, Steuerzeichen passen besser zu einem Socket, der Zeichen
   einfach durchreicht.

10\. **Verweise in der Hilfe der Konsole:** Hat eine Hilfeseite Verweise, bekommen sie eine laufende Nummer
    vorweg (`1 Namen  2 Variablen …`). Die Nummer wählt den Verweis und zeigt dessen Seite, Backspace geht zurück
    zur vorigen Seite, Esc verlässt die Hilfe sofort. Bis dahin zeigt die Konsole die Verweise mit dem Aufruf
    (`\?'`), siehe Kapitel 7.

11\. **Texte auslagern:** Die Hilfe des Rechners steht in `library/system/hilfe.de.rpnlib` (Kapitel 8).
    Offen sind noch die Hilfetexte der Oberflächen (`lib/console/help.dart`, `app/lib/hilfe.dart`) und die
    Fehlermeldungen; für sie ist dasselbe Format vorgesehen, siehe auch Punkt 14.

12\. **Felder: Reihenfolge der Elemente und Darstellung:** Heute ist Element 0 der Wert, der beim Anlegen der
    Tos war: `1 2 3 3:'!v` ergibt die Elemente 3 2 1. Was für die Nutzer intuitiver ist, ist noch offen; die
    Elemente lassen sich ohnehin in jeder Reihenfolge vom Stack holen. Angezeigt werden Felder ohne eckige
    Klammern, durch Leerzeichen getrennt, weil `[ ]` für Einheiten reserviert ist.



14\. **Mehrsprachigkeit der Texte des Rechners:** Die eingebaute Hilfe steht in `library/system/hilfe.de.rpnlib`;
    weitere Sprachen kommen als `hilfe.en.rpnlib` usw. mit denselben Kennungen dazu, damit Verweise in jeder
    Sprache stimmen. Der Rechner bekommt eine Einstellung `sprache` und fällt für fehlende Einträge auf Deutsch
    zurück. Die Fehlermeldungen (heute fest in `core.dart` und `dea.dart`) kommen über einen neuen Schlüssel
    `meldungen` in `rpnjson` dazu; ältere Versionen übergehen ihn. Bibliotheken können ihre Hilfe ebenfalls in
    mehreren Sprachen mitbringen. Funktionsnamen und Befehle werden nicht übersetzt, sie sind Teil der Sprache.

---

## 11. Erledigte Punkte

4\. **`AngleMode`** stammt aus dem Calculator. **Entschieden:** Der Winkelmodus ist Sache des Rechners (Core);
   die API reicht dessen Typ weiter, die Oberflächen haben keinen eigenen.
- **Offenes Token über dem Stack** (früher Punkt 10, vor der festen Nummerierung): umgesetzt, siehe
  Kapitel 7 und [app.md](app.md) Kapitel 2.

13\. **Hilfetexte in Bibliotheken:** entschieden: `{json}rpnjson` mit den Schlüsseln `version` und
    `hilfe`, eine Bibliothek ist ein Block, der beim Laden mit `X` ausgeführt wird (9.1, reference.md 10.5).

15\. **Überschreiben schützen, doppelte Modifikatoren:** umgesetzt. Jeder Modifikator nach `'` darf einfach
    oder doppelt stehen, die doppelte Form ist die stärkere (`'::` ersetzen, `'~~` Geschütztes entfernen, `'==`
    füllen, `'++`/`'--` um 1 ändern). `':` legt nur neu an; Funktionen aus Bibliotheken sind geschützt, ein
    Namenskonflikt beim Laden ist ein Fehler. Siehe reference.md 8.2, 10.2 und 10.6.
