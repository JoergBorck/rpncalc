# RPN-Rechner: Flutter-App

Die App ist die Oberfläche für Smartphones (hochkant). Sie benutzt denselben Rechnerkern wie die Konsole
(`RpnApi`, `Zustand`, siehe [api.md](api.md)) und liegt im Verzeichnis `app/`, das das Paket `rpncalc` per Pfad
einbindet. Ein klickbares Modell der Oberfläche: https://claude.ai/artifact/XaT5599vaeNVuorCU5VvwS

## 1. Aufbau

- Oben die **Anzeige**, unten das **Tastenfeld**.
- Das Tastenfeld hat einen oberen Block mit 5 Reihen zu 6 Tasten (Funktionen) und darunter einen Block mit
  4 Reihen zu 5 Tasten (Ziffern und Grundrechenarten).
- Ein **Cursorkreuz** aus vier Tasten (◄ ▲ ► ▼, schräg gestellt) sitzt zwischen beiden und ragt etwas in die Anzeige hinein.

### 1.1 Fenstergröße und Zoom

Unter Windows und im Browser lässt sich das Fenster größer und kleiner ziehen.

- **Zoom:** Die App rechnet mit einer festen Breite von 400 Punkten und wird als Ganzes um den Faktor
  Fensterbreite / 400 vergrößert oder verkleinert, Tooltips, Menü und Dialoge eingeschlossen. Breiter ziehen
  vergrößert alles samt Schrift; höher ziehen gibt der Anzeige mehr Zeilen bei gleicher Schrift. Schmaler als
  400 wird der Rechner kleiner und die Anzeige entsprechend höher.
- **Dehnung:** Reicht die Höhe nicht für Tastenfeld und eine Anzeige von 240 Punkten, begrenzt sie den Faktor.
  Dann werden die Tasten breiter, bis die Seite 50 % breiter ist als ohne Dehnung: Die Anzeige bekommt mehr
  Zeichen je Zeile, das Cursorkreuz bleibt so groß, die beiden kleinen Tasten darunter werden breiter und
  füllen den Platz neben ihm. Erst danach steht die Seite mittig mit Rand.
- **Querformat:** Diesen Rand soll später das Querformat nutzen (Backlog FA-5).

## 2. Anzeige

- **Rechnen:** links die Eingabezeilen, rechts der Stack, je die halbe Breite (Werte rechtsbündig). Mit
  Maximieren (3.5) bekommt einer der beiden die ganze Breite. Beide wachsen von oben nach unten: oben stehen die
  aktuelle Eingabe und der Tos auf einer Zeile, darunter ältere Zeilen bzw. tiefere Werte. Die Schrift wird
  nach unten kleiner.
- Der Tos ist hellorange hinterlegt (wie in der Konsole). Ein Fehler wird in der Eingabezeile rot markiert,
  die Meldung steht darunter.
- **Offenes Token:** Ist ein Token offen (z.B. die Zahl, die man gerade tippt), steht es grau mit `>:` oben in
  der Stackspalte, neben der aktuellen Eingabe; alle Werte rücken eine Zeile tiefer, der Tos bleibt hinterlegt.
  Ist das Token zu Ende, rücken die Werte wieder nach oben, und das Ergebnis steht neben der Eingabe. Was
  angezeigt wird und wann nicht, regelt [api.md](api.md) Kapitel 7 („Offenes Token über dem Stack“); in der
  App gibt es keine feste Zeilenzahl, die Zeile kommt einfach dazu. Ohne offenes Token gibt es die Zeile nicht,
  auch keine leere.

  ```
  12 3+ 4.5█             4.5 >:
  7                        15 x
                            7 y
                              z
                              t
  ```
- **Namen der Positionen:** Am rechten Rand stehen klein die Namen x, y, z, t (doc/reference.md 2.1),
  darunter ₄, ₅ … (das ≡ fehlt, die Spalte gehört ohnehin zum Stack). x bis ₆ stehen auch dann da, wenn die
  Position noch leer ist; so ist der Übergang von t zu ₄ zu sehen.
- **Seiten:** Die Anzeige lässt sich seitlich wischen: Rechnen, Variablen und Tags, Funktionen.
- **Seite Funktionen:** zuerst der Abschnitt „Eigene Funktionen“, darunter je geladener Bibliothek ein Abschnitt
  „Bibliothek name“, jeweils mit dem Code der Funktionen; so lässt sich nachlesen, wie eine Bibliothek gebaut ist.
  Blättern die Funktionstasten auf eine Seite einer Bibliothek, scrollt die Liste so, dass deren Funktionen zu
  sehen sind (erste Seite: der Abschnitt, weitere Seiten: ihre erste Funktion oben), sonst nach oben; umgekehrt ändert Scrollen in der Liste die Tasten nicht.
- **Statuszeile:** Winkelmodus, aktive Umschaltungen (Shift, `~`, `|`, `'`, Alpha) und die Seite der
  Funktionstasten. Den gewählten Bereich zeigt der Name unten am orangen Rahmen, immer auf der Außenseite
  (Eingabe links, Stack rechts), damit das Cursorkreuz ihn nicht verdeckt.

### 2.1 Kontextmenü und Zwischenablage

Rechtsklick (PC, Browser) bzw. langes Drücken (Handy) in der Eingabe- oder Stackspalte öffnet ein
Kontextmenü; es bezieht sich auf die Zeile, auf die man geklickt hat. Diese Zeile ist hervorgehoben, solange das
Menü offen ist. Das Menü ist etwas heller als die Anzeige, mit dünnem Rand und Schatten. Gibt es an der Stelle
nichts zu kopieren (z.B. eine leere Stackzeile), sind die Einträge dafür ausgegraut. Die Tasten behalten das
lange Drücken für ihren Tooltip. Im Browser ist das eigene Kontextmenü des Browsers abgeschaltet.

| Stack | Eingabe |
|---|---|
| **Wert kopieren:** der angeklickte Wert | **Zeile kopieren:** die angeklickte Zeile |
| **Stack ab hier kopieren:** von diesem Wert bis x | **Zeilen ab hier kopieren:** von dieser bis zur aktuellen Zeile |
| **Ganzen Stack kopieren** | **Ganzen Verlauf kopieren:** alle Zeilen bis zur aktuellen |
| **Werte einfügen** | **Text einfügen** |
| **Hilfe** | **Hilfe** |

- **Werte** werden für ein deutsches Excel kopiert wie `\c` und `\s` in der Konsole ([api.md](api.md)
  Kapitel 7): der tiefste Wert zuerst, mit Dezimalkomma, getrennt mit `;`. Ein offenes Token wird vorher mit `_`
  abgeschlossen. **Zeilen** werden als Text kopiert, die älteste zuerst, getrennt mit Zeilenumbrüchen.
- **Werte einfügen** löst wie `\v` alle Zahlen aus dem Text (Dezimalkomma oder -punkt, Exponent mit e) und
  legt sie auf den Stack, die erste unten, die letzte wird x; alles andere wird übergangen, es wird nichts
  ausgeführt.
- **Text einfügen** gibt den Text Zeichen für Zeichen an den Rechner, als wäre er getippt; Zeilenumbrüche
  brechen die Zeile um.
- **Hilfe** zeigt die Seite des Elements wie ein Tipp im Inspekt-Modus (5.3); am Handy ersetzt das den Tooltip
  der Anzeige.
- Danach steht kurz eine Meldung unten in der App (z.B. „Kopiert: 2,25“, „3 Zahlen eingefügt“).
- **Im Browser** fragt Firefox beim Einfügen mit einem kleinen „Einfügen“ nach. Aus dem Kontextmenü liest die App
  deshalb erst, wenn das Menü zu ist; lehnt der Browser ab, meldet sie „Die Zwischenablage lässt sich nicht lesen“.
- **Tastatur** (Kapitel 6): Strg+C kopiert x, Strg+Shift+C den ganzen Stack, Strg+V fügt im Stack Werte und
  in der Eingabe Text ein, je nach gewähltem Bereich. `\c`, `\s` und `\v` wirken wie in der Konsole, getippt
  oder im Alpha-Modus (`\` liegt dort auf `'`).

## 3. Tastenfeld

### 3.1 Belegung

Oberer Block (Hauptfunktion / Shift; `~` und `|` zeigen erlaubte Präfixe):

| | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| R1 | SHIFT | ALPHA | Cursorkreuz, in der Ecke frei | Cursorkreuz, in der Ecke □ / ◫ | TAB / ⇤ | MENÜ / HILFE |
| R2 | `'` | `( )` reserviert | `[ ]` reserviert | `{` / `}` | frei | ⌫ / `C` |
| R3 | `D` / `Y` | F1 | F2 | F3 | F4 | F5 |
| R4 | `S` / `R`, `~`: `~R` | F6 | F7 | F8 | F9 | F10 |
| R5 | `!` | `^`, `~`: ˣ√y | `²`, `~`: √x | `³`, `~`: ∛x | `°`, `~`: →kart | `%`, `~%`, `\|%`, `~\|%` |

Unterer Block:

| | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| R6 | ENTER (Leerzeichen) / `_` | 7 | 8 | 9 | `/`, `~`: 1/x, `\|`: `\|/` / `>`, `~`: ≤ |
| R7 | `:`, `~:`, `\|:`, `~\|:` | 4 | 5 | 6 | `*` / `&`, `~`: oder |
| R8 | Präfix `\|` (zweimal: `\|\|` Betrag) | 1 | 2 | 3 | `-` / `<`, `~`: ≥ |
| R9 | Präfix `~` (eingefärbt) | `ê` | 0 | `.` | `+` / `=`, `~`: ≠ |

- `( )` und `[ ]` sind für Vektoren und Einheiten reserviert.
- ENTER liegt wie beim HP links neben der 7.
- **Rechenfunktion auf `~` und `|`:** Mittig unter dem großen Zeichen steht klein, was die Taste allein tut:
  ± auf `~` (Vorzeichenwechsel), □|.□ auf `|` (Ganzzahl- und Nachkommateil, die Kästen als Platzhalter). Die
  Zeichen sind gezeichnet, nicht aus einer Schrift, in der hellen Tastenschrift etwas zurückgenommen und etwa so
  groß wie die Shift-Hinweise; im Alpha-Modus sind sie ausgeblendet. Unten links bleibt frei für die Symbole
  von Shift+ALPHA (Backlog FA-9).

### 3.2 Umschaltungen

- **Shift** gilt für einen Tastendruck. Die Shift-Funktion steht klein links oben auf der Taste.
- **`~` und `|`** sind Präfixe wie in der Sprache: Die Taste schreibt das Zeichen und schaltet die Beschriftung
  der Tasten um, auf denen der Präfix erlaubt ist (kleine Markierung rechts oben). Beide lassen sich kombinieren.
  Diese Tasten tragen dann einen dünnen Rand in der Farbe des Präfixes (dünner als der Rand aktiver
  Umschalttasten). Alle anderen Tasten bleiben normal bedienbar: Vor ihnen wirkt der Präfix allein (`~` als
  Vorzeichenwechsel, `|` als Ganzzahl- und Nachkommateil), die App setzt dafür einen Trenner (`3~ D`, denn
  `3~D` wäre die Umkehrung von D). Ziffern, `.` und `ê` nach `~` ergeben weiter eine negative Zahl.
- **`'`** schreibt den Apostroph; die Funktionstasten zeigen danach die Variablen und Tags.
- **Alpha** schaltet auf Kleinbuchstaben; sie bleiben, bis ALPHA erneut oder ein Nicht-Buchstabe
  gedrückt wird. Im Alpha-Modus heißt SHIFT „ABC“: Ein Druck macht den nächsten Buchstaben groß, danach
  endet Alpha (Befehle bestehen aus genau einem Großbuchstaben); ist Shift schon aktiv, heißt die Taste „abc“
  und schaltet zurück. Shift wirkt im Alpha-Modus nur auf Buchstaben, alle anderen Tasten behalten ihre normale
  Belegung (⌫ bleibt ⌫, nicht C). ⌫ löscht zeichenweise und lässt Alpha an. ALPHA beendet den Alpha-Modus,
  auch mit Shift; Shift+ALPHA bei ausgeschaltetem Alpha schaltet ihn ein, für einen Großbuchstaben. Das Alphabet
  beginnt bei `( )` und läuft zeilenweise durch den oberen Block (`a b c d`, `e`–`j`, `k`–`p`, `q`–`v`),
  `w x y z` liegen auf `/ * - +`. ⌫ bleibt ⌫, `\` liegt auf `'`. Alpha+ENTER ist ein Zeilenumbruch.
- **Farben:** SHIFT ist orange, ALPHA hellgrün wie ihre Hinweise auf den Tasten; ist eine aktiv, hat sie
  einen hellen Rahmen. TAB zeigt groß ⇥, mit Shift ⇤.
- Befehle aus Großbuchstaben wie `X` und Funktionsnamen wie `if` werden mit Alpha getippt.

### 3.3 Bereiche und Cursorkreuz

- **Tab** wechselt den Bereich: Eingabe → Stack → Funktionen → Variablen, Shift+Tab rückwärts. Die Anzeige
  wischt zur passenden Seite.
- **Antippen** in der Anzeige wählt den Bereich ebenso: die Eingabe- oder die Stackspalte, die Seite Variablen
  oder Funktionen. Die Funktionstasten wählen keinen Bereich. Im Hilfe-Modus zeigt ein Tipp statt dessen die Hilfe.
- **Eingabe:** ▲ und ▼ blättern im Verlauf. ◄ und ► schieben lange Zeilen seitlich, jede für sich um ein
  Zeichen bis zu ihrem Anfang bzw. Ende (einen Cursor in der Zeile gibt es erst mit dem Undo, Kapitel 4).
  Die aktuelle Zeile zeigt zuerst ihr Ende.
- **Stack:** ▲ und ▼ blättern zu tieferen Werten, ◄ und ► schieben lange Werte seitlich. ▼ geht so weit, bis der
  unterste Wert in der 7. Zeile steht; so viele Zeilen zeigt auch die kleinste Anzeige ganz.
- Der gewählte Bereich hat einen orangen Rahmen; kleine orange Pfeile links bzw. rechts am Rahmen zeigen, dass
  sich mit ◄ bzw. ► etwas schieben lässt. Jede Eingabe stellt Blättern und Schieben zurück.
- **Funktionen:** ◄ und ► blättern zwischen den Seiten der Funktionstasten: zuerst die Grundfunktionen (sie
  sind immer dabei), dann die gewählte Domäne, zuletzt die eigenen Funktionen. Reichen 10 Tasten nicht, gibt es
  weitere Seiten. Wählt man im Menü eine Domäne, zeigen die Tasten ihre erste Seite. Ohne eigene Funktionen gibt
  es keine (leere) Seite „Eigene“. Unten am orangen Rahmen steht der Name der Seite (z.B. Grundfunktionen, schwingungen 2/3,
  Eigene), bei den Variablen „Variablen“; der Rahmen hat dort eine Lücke, der Name keinen eigenen Hintergrund.
- **Wischen und Mausrad:** Seitlich über die Funktionstasten wischen blättert ebenso (nach links wischen: nächste
  Seite), im Kreis wie ◄ ►. Am PC blättert das Mausrad über ihnen: erst jede dritte Raste in dieselbe Richtung
  wechselt die Seite (nach unten: nächste), und es hält an der ersten bzw. letzten Seite an; solange es dreht,
  zeigen die Tasten keine Tooltips. Beides wählt den Bereich nicht, die Anzeige bleibt, wo sie ist; der orange
  Rahmen erscheint nur kurz (etwa 1,5 s) als Hinweis. Gibt es mehr als eine Seite, zeigt er links und rechts kleine
  Pfeile. Zeigen die Funktionstasten die Variablen, blättern Wischen und Mausrad nicht.
- **Variablen:** Die Funktionstasten zeigen die Variablen und Tags.

- **Beschriftung:** Jede Taste zeigt, was ein Druck bewirkt, nicht den aktuellen Zustand. TAB zeigt mit Shift
  „⇤ TAB“, die Maximieren-Taste □ bzw. ◫ (3.5).

### 3.4 Funktionstasten und Domänen

- **Vergleiche und Logik auf Shift der Rechenspalte:** `>` `&` `<` `=` auf ÷ × − +; `=` liegt dort, wo es auf den
  meisten Taschenrechnern liegt. So gibt es Bedingungen und `'=name` ohne Wechsel der Domäne, z.B. `a b>*` (a, wenn
  a > b, sonst 0).
- **`~` wirkt auch auf die Shift-Funktion:** `~` ⇧ ÷ schreibt `≤` (gleichwertig zu `~>`, reference.md 4),
  entsprechend `~&` (oder), `≥`, `≠`. Bei `~` und Shift zeigen die Tasten diese Umkehrungen.
- **Regel für künftige Belegungen:** Auf `~` ⇧ liegt immer die Umkehrung der Shift-Funktion. Eine Shift-Funktion
  darf also keine weitere eigene Variante mit `~` brauchen, und ihre Varianten mit `|` sind von der Taste aus nicht
  erreichbar.
- F1–F10 sind je nach **Domäne** belegt, z.B. Grundfunktionen, Statistik, Schwingungen, Programm. Die Domäne
  wird im Menü gewählt.
- **Bibliotheken als Domänen:** Das Menü zeigt nach den eingebauten Domänen alle Bibliotheken des Rechners
  ([api.md](api.md) 9.1), mit ihrem Namen als Titel. Wählt man eine, wird sie einmal geladen; die
  Funktionstasten zeigen ihre Funktionen in der Reihenfolge der Datei, bei mehr als zehn auf mehreren Seiten,
  die ◄ ► im Bereich Funktionen durchblättern. Die Tasten tragen den Funktionsnamen (`mean`, `omega`); schönere
  Beschriftungen (ω) kommen mit den Hilfetexten der Bibliotheken.
- Grundfunktionen: π / e, rnd / seed, round, dms, DEG; sin, cos, tan (Shift: sinh, cosh, tanh;
  `~`: asin, acos, atan), ln (Shift: log, `~`: eˣ), RAD / GRD.

### 3.5 Maximieren

Das Cursorkreuz lässt in R1 die beiden unteren Außenecken der Spalten 3 und 4 frei. Dort sitzen zwei kleine Tasten:

- **Rechts neben ▼ (links neben TAB): Maximieren.** Sie zeigt, was ein Druck bewirkt, wie die Zeichen von
  VS Code: ein ganzes Rechteck bei geteilter Anzeige (maximieren), ein geteiltes bei maximierter (wieder teilen).
  Die Zeichen werden gezeichnet, nicht aus einer Schrift genommen; in Texten (Hilfe, Tooltip) stehen dafür □ und ◫.
- **Links neben ▼ (rechts neben ALPHA):** Platzhalter, noch ohne Funktion; vorgesehen für den Wechsel
  zwischen Hoch- und Querformat (Backlog FA-5).

Verhalten:

- **Maximieren wirkt auf den gewählten Bereich:** Stack bzw. Eingabe bekommen die ganze Breite, die andere
  Spalte verschwindet. Bei Funktionen und Variablen haben die Seiten schon die ganze Breite, dort wirkt die
  Taste nicht.
- **Doppelklick** (am Handy Doppeltipp) in Eingabe oder Stack wählt den Bereich und wirkt wie die Taste: geteilt
  wird maximiert, maximiert wieder geteilt. Im Hilfe-Modus nicht, dort zeigt ein Tipp die Hilfe.
- **Stack maximiert:** Was man tippt, zeigt die graue Zeile `>:` (Kapitel 2). Bei einem Fehler bleibt die
  Meldung unter der obersten Zeile sichtbar.
- **Umbruch:** Er richtet sich immer nach der halben Breite (Kapitel 4), auch wenn eine Spalte maximiert ist.
  So ändern sich die Zeilen nicht, wenn man maximiert.
- **Eingabe maximiert:** Der Tos steht klein in der Statuszeile, damit man das Ergebnis im Blick behält.
- **Maximiert gilt allgemein:** Wechselt man mit Tab zwischen Eingabe und Stack, bleibt die Anzeige maximiert und
  zeigt den neu gewählten Bereich in ganzer Breite.
- **Animation:** Beim Umschalten gleiten die Spalten in etwa 250 ms auf ihre neue Breite.

## 4. Eingabezeilen

Der Rechner arbeitet zeichenweise und braucht kein Zeilenende. Die Zeilen der Anzeige entstehen so:

- **Umbruch:** Ist die Zeile zu mehr als 80 % gefüllt, bricht sie nach der nächsten Operation um, nach der kein
  Token mehr offen ist (kein offenes Token, kein vorgemerktes Enter, kein Fehler). Zahlen und ENTER bleiben also
  in der Zeile, `3 4+` endet mit dem `+`. Nach einem ENTER (vorgemerktes Enter) bricht die Zeile ab 90 % um.
- **Im Code** (ein Block ist offen) bricht die Zeile ab 80 % beim nächsten Leerzeichen um; das Leerzeichen wird
  dabei zum Zeilenumbruch im Code.
- Der Umbruch ruft `zeilenende()` auf. Die Zeile wandert in den Verlauf und lässt sich nicht mehr ändern.
- **Fehler:** Die Zeile bleibt stehen, bis der Fehler mit ⌫ behoben ist (`loeschen`).
- **Kein Cursor in der Zeile:** Solange es kein Undo gibt, wird nur am Ende geschrieben und gelöscht.

### 4.1 Namen und Trenner

Funktionstasten schreiben Namen (`sin`, `pi`, `'a`). Damit ein Name nicht mit dem vorigen verschmilzt
(`pisin`), setzt die App bei Bedarf ein `_` davor; danach schließt ein `_` den Namen ab, damit er sofort
ausgeführt wird. Mit Alpha getippte Buchstaben bleiben unverändert.

## 5. Hilfe

Die Hilfetexte zur Sprache kommen aus dem Rechner ([api.md](api.md) Kapitel 8). Die App ergänzt eigene Einträge
für ihre Bedienung (`app:…`) und setzt die Hilfe zu einzelnen Elementen zusammen.

- **App und Rechner zusammen:** Hat eine Kennung einen Eintrag der App und einen des Rechners, zeigt der
  Hilfeschirm beide, zuerst den der App, dann den des Rechners (z.B. bei `~`: die Präfix-Taste, dann `~` in der
  Sprache).
- **Startseite:** Shift+MENÜ und dann MENÜ ohne Auswahl zeigt die Startseite in drei Abschnitten: „Hilfe zur
  Hilfe“ (Bedienung des Hilfe-Modus), „Hilfe zur App“ (`app:start`: Anzeigen, Bedienung, Bibliotheken) und
  „Hilfe zum RPN-Rechner“ (`#`). Die Themen stehen nur als Verweise, nicht noch einmal im Text (api.md 8.3).
- **Bibliotheken:** Die Seite `app:bibliotheken` erzeugt die App aus `bibliotheken()`: je Bibliothek der Satz aus
  `beschreibung` und ein Verweis auf ihre Übersicht (`#statistik`). Die Startseite der App verweist darauf. Lesen
  lässt sich die Hilfe einer Bibliothek auch, bevor sie geladen ist; geladen wird sie über MENÜ (später über den
  Bereich Bibliotheken des Menüs).

### 5.1 Tooltips

- **PC und Browser:** Fährt die Maus über eine Taste, zeigt ein Tooltip **alle** Belegungen der Taste.
- **Handy:** Langes Drücken zeigt denselben Tooltip.
- Tooltips sind reine Anzeige. Die Einzelheiten gibt es im Hilfe-Modus.
- **Bibliotheken** (im Menü, später im Bereich Bibliotheken): ein Satz, wofür die Bibliothek gedacht ist
  (`beschreibung` im version-Eintrag), darunter Version und Zahl der Funktionen; die Funktionen selbst stehen in
  den Tooltips ihrer Tasten.
- **Kurze Pause beim Verlassen:** Verlässt die Maus eine Taste oder Zeile, ruhen alle Tooltips 1 s. So springen sie
  beim Überfahren nicht von Taste zu Taste mit, und man kommt aus einem großen Tooltip leicht heraus.
  Hat das nächste Element denselben Tooltip (z.B. die Zeilen einer Spalte und ihr Name am Rahmen), bleibt er
  ohne Pause stehen.
- **Beim Tippen auf der PC-Tastatur** ruhen die Tooltips, bis die Maus bewegt wird und ein anderes Element
  betritt. Wer tippt, schaut nicht auf die Taste unter der Maus.
- **Solange ein Kontextmenü offen ist** (2.1), erscheinen keine Tooltips, und nach der Auswahl erst wieder, wenn
  die Maus bewegt wird und ein anderes Element betritt. Ohne Maus (Handy) gibt es diese Sperre nicht.

**Aufbau:** Der Tooltip ist eine kleine Tabelle mit drei Spalten: Schreibweise, Stack, Beschreibung. Jede
Funktion hat eine eigene Zeile. Die Zeilen sind in Bereiche gegliedert, in dieser Reihenfolge:

1. **Präfix** (nur `~`, `|` und `'`): was die Taste als Präfix bewirkt („als Präfix: …“).
2. **Grundfunktion** und ihre Varianten mit `~`, `|`, `~|`.
3. **Argumente** (nur bei Funktionen mit Argumenten): je Argument eine Zeile im Format `▢:▢:3:f`. Die schon
   erklärten Argumente stehen als ausgegraute Kästen davor, das erklärte Argument als Beispielzahl, abschließend
   die Beschreibung seiner Wirkung auf die Funktion. Die letzte Zeile zeigt das ganze Beispiel als Satz.
4. **Shift** und dessen Varianten. Die Zeilen tragen vorn ein oranges ⇧.
5. **Alpha:** `Alpha  e / E`, später auch das Symbol von Shift+ALPHA (Backlog FA-9).
6. **Hinweise** zuletzt: bei `~` und `|`, dass ein kleines Zeichen oben rechts die Tasten zeigt, auf die der
   Präfix wirkt.
7. **PC-Tastatur:** wie man die Zeichen der Taste an der Tastatur tippt, wenn sie dort nicht direkt liegen
   (`x²`: AltGr+2, `÷`: `/`, `≤` als `~>`), wie die Kürzel neben Menüeinträgen. Nur bei solchen Tasten.

- **Elemente der Anzeige** (Eingabe, Stack): vorweg ein Bereich mit dem Namen und dem ersten Satz aus dem
  Eintrag der App, was das Element ist; dann die Bedienung, zuletzt der Wechsel mit TAB.
- **Zeilen und Linien:** Innerhalb eines Bereichs wechselt der Hintergrund der Zeilen zwischen Gelb und Hellgelb;
  zwischen zwei Bereichen steht eine etwas dunklere Linie.
- **Schreibweise:** Die erste Spalte zeigt, was man tatsächlich schreibt (`~%`, `|%`, `Y`).
- **Stack:** Die zweite Spalte zeigt die Wirkung auf den Stack (`y x → y+x`) bei Rechenoperationen; bei Befehlen
  bleibt sie leer.
- **Wortwahl:** Ein Präfix wirkt auf die „nächste Funktion“; sie muss nicht direkt danach getippt werden.
- **Farben:** Die Zeichen der Umschaltungen haben im Text dieselbe Farbe wie auf den Tasten: `~` türkis, `|` lila,
  ⇧ orange, „Alpha“ grün. Gefärbt wird nur das Zeichen, nicht die ganze Zeile. Tooltip (gelber Grund) und
  Hilfeschirm (dunkler Grund) haben je eigene, gut lesbare Töne derselben Farbe. Das gilt auch im Fließtext der
  Hilfeseiten.
- **Themes:** Die Farben kommen aus benannten Rollen in `farben.dart` (z.B. „Tilde im Tooltip“), nie als feste
  Werte im Widget. Ein späteres Theme tauscht nur die Werte der Rollen aus.

Beispiele:

```
%      y x → y, y·x/100      Prozentwert
┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
~%     y x → y, y·100/x      Grundwert
┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
|%     y x → Netto, Anteil   Vorwärts-Split
┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
~|%    y x → Brutto, Anteil  Rückwärts-Split
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Alpha  v / V

S          y x → x y         tauscht x und y
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4:S                          tauscht mit ≡₄ statt mit y
▢:1:S                        tauscht ab y statt ab x
▢:▢:2:S                      tauscht je 2 Werte
4:1:2:S                      tauscht y mit ≡₄ und z mit ≡₅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⇧ R                          rotiert …
```

### 5.2 Hilfe-Modus

Die Hilfe hat zwei Modi: im **Inspekt-Modus** schlägt man nach, was eine Taste oder ein Element der Anzeige
tut; im **Lese-Modus** liest man die Hilfe wie ein Dokument.

**Start:** Shift+MENÜ (am PC F1). Der Hilfeschirm zeigt gleich eine Seite: die Hilfe zur Taste des letzten
Tooltips, wenn er höchstens etwa 10 s her ist, sonst die Startseite. Als angeschaut gilt ein Tooltip, wenn der
Mauszeiger mindestens 1 s auf der Taste geruht hat (bloßes Überfahren auf dem Weg zu SHIFT und MENÜ zählt nicht),
am Handy nach langem Drücken. SHIFT und MENÜ selbst zählen nie, mit ihnen öffnet man die Hilfe. Die Statuszeile zeigt „HILFE“ bzw. „HILFE ·
LESEN“ in eigener Farbe (hellblau), die MENÜ-Taste leuchtet.

**Inspekt-Modus** (nach dem Start):

| Aktion | Wirkung |
|---|---|
| **Taste antippen** | zeigt die Hilfe zu allen Belegungen der Taste in Kurzform (Verwendungen); eingegeben wird nichts. Das gilt für jede Taste, auch SHIFT, ⌫ (mit C), TAB und ENTER |
| **Element der Anzeige antippen** | zeigt die Hilfe zu diesem Element (5.3); der Hilfeschirm lässt den Tipp durch, auch wenn er das Element verdeckt |
| **Verweis antippen** | folgt ihm; nur die Verweise lässt der Hilfeschirm nicht durch |
| **◄** | zurück zur vorigen Seite; die erste Seite bleibt stehen |
| **BEENDEN** (MENÜ) | beendet die Hilfe; die Taste trägt im Hilfe-Modus diese Beschriftung |
| **LESEN** (ALPHA) | wechselt in den Lese-Modus; ist kein Hilfeschirm offen, mit der Startseite |

**Lese-Modus:** Tasten lösen keine Hilfe aus; die gezeigte Seite bleibt, mit dem vollen Text.

| Aktion | Wirkung |
|---|---|
| **▲ ▼** | blättern in der Seite |
| **◄** | zurück zur vorigen Seite; die erste Seite bleibt stehen |
| **TAB** / Shift+TAB | wählt den nächsten bzw. vorigen Verweis, er ist hervorgehoben |
| **ENTER** oder **►** | folgt dem gewählten Verweis; ► ohne Auswahl wählt den ersten |
| **Verweis antippen** | folgt ihm ebenfalls |
| **ANFANG** (MENÜ) | zeigt die Startseite |
| **BEENDEN** (⌫) | beendet die Hilfe |
| **ALPHA** | zurück in den Inspekt-Modus |

- **Beschriftungen:** BEENDEN bezieht sich auf den Modus, ANFANG auf das Dokument. Die Tasten mit einer Aufgabe
  in der Hilfe sind blau: MENÜ immer, ⌫ im Lese-Modus. ALPHA zeigt im Inspekt-Modus
  „LESEN“, im Lese-Modus „INSPEKT“ und ist aktiv (Ring).
- **Im Hilfe-Modus wird nichts eingegeben.** Stack, Eingabe und Verlauf bleiben unverändert.
- **Aufbau des Hilfeschirms:** oben der Titel; darunter je Belegung der Taste die Verwendungen (Schreibweise,
  Stack, Argumente, Kurztext); im Lese-Modus dazu der Text mit Beispielen; ganz unten die Verweise als antippbare
  Felder. Ist der Inhalt höher als die Anzeige, lässt er sich scrollen; unten bleibt so viel Platz, dass sich das
  Ende über das Cursorkreuz hinaus nach oben schieben lässt, das in die Anzeige ragt.
- **Tipp auf den Hilfeschirm:** im Inspekt-Modus geht er an das Element darunter; im Lese-Modus blättert man
  im Schirm und tippt Verweise an.
- **PC-Tastatur:** F1 schaltet die Hilfe an und aus, Esc beendet sie; TAB, Enter und die Pfeiltasten wirken wie
  die Knöpfe.

### 5.3 Hilfe zu Elementen der Anzeige

| Element | Inhalt |
|---|---|
| Winkelmodus in der Statuszeile | `#winkel`: die Modi und wie man sie wechselt |
| Marken der Statuszeile (SHIFT, `~`, `\|`, `'`, abc) | die jeweilige Umschaltung |
| Stack-Wert | Position, der volle Wert ohne Kürzung, seine Tags; dazu `#stack` |
| Eintrag auf der Seite Variablen und Tags | Art (Variable, Konstante, Tag), Inhalt; dazu `#variablen` bzw. `#tags` |
| Eintrag auf der Seite Funktionen | der vollständige Code; dazu `#funktionen` |
| Zeile im Verlauf | die vollständige Zeile, falls sie gekürzt war (eine Erklärung Token für Token ist für später vorgemerkt) |
| Fläche eines Bereichs (z.B. leerer Teil der Eingabe) | die Hilfe zur Anzeige dieses Bereichs, siehe unten |

**Hilfe zu den Anzeigen:** `app:eingabe`, `app:stack`, `app:funktionen` und `app:variablen` erklären Blättern,
Schieben, Umbruch, Rahmen und Pfeile des Bereichs und verweisen auf die Begriffe im Rechner (`#stack`,
`#variablen` …). Ganz unten verweist jede auf die nächste in der Reihenfolge von Tab, die letzte wieder auf die
erste. So kann man sich mit den Verweisen durch die ganze Oberfläche führen lassen.

**Einträge der App** (Auswahl): `app:shift`, `app:alpha`, `app:tab`, `app:menue`, `app:hilfe`, `app:cursorkreuz`, `app:maximieren`,
`app:enter` (Leerzeichen als Enter, Shift: Trenner, Alpha: Zeilenumbruch), `app:loeschen`, die vier Anzeigen
und `app:umbruch` (Kapitel 4). Ein Test prüft wie im Rechner, dass jede Bedientaste einen Eintrag hat und jeder
Verweis ein Ziel.

## 6. Tastatur

Eine echte Tastatur (PC, Browser, Bluetooth am Handy) bedient die App wie die Knöpfe.

- **Zeichen** gehen so an den Rechner, wie sie getippt werden, wie in der Konsole. Die Automatik für Namen
  (4.1) gilt nur für die Funktionstasten; wer tippt, setzt `_` selbst. Alpha braucht man nicht, Buchstaben
  kommen direkt; ein getippter Buchstabe ändert den Alpha-Zustand nicht.
- **Präfixe:** Werden `~`, `|` oder `'` getippt, schalten die Beschriftungen um wie beim Knopf. Der helle
  Rahmen um `~` bzw. `|` bleibt, solange das Token mit dem Präfix offen ist: bei `~sin` bis `sin` fertig ist.
  Eine negative Zahl (`~3`) zählt nicht dazu.
- **≤ ≥ ≠:** Getipptes `~>`, `~<`, `~=` wird beim Tippen zu `≤`, `≥`, `≠`, wie es auch die Tasten schreiben
  (3.1). Möglich, weil das `~` bis dahin offen ist.
- **Umbruch und Verlauf** wirken unverändert (Kapitel 4).

| Taste | Wirkung |
|---|---|
| Leertaste | ENTER (Leerzeichen als Enter, Kapitel 4) |
| Return | Zeilenumbruch, wie ALPHA ⏎; jedes weitere Return gibt eine leere Zeile im Verlauf |
| Enter auf dem Ziffernblock | tut, was der Name sagt: ENTER (Leerzeichen), dann Zeilenumbruch. Das Enter bleibt am Zeilenende vorgemerkt, wie beim HP: `5` Enter `+` ergibt 10, `5` Enter `3` `+` ergibt 8. Die Zeile wandert in den Verlauf, im Code ist es ein Zeilenumbruch. Jedes weitere Enter ohne Eingabe verdoppelt x, wie beim HP. Erkannt wird die Taste auch, wenn der Browser sie als Return meldet |
| `_` | Trenner, direkt getippt (Umschalt+Minus) |
| Backspace | ⌫ |
| Tab / Shift+Tab | Bereich wechseln |
| Pfeiltasten | Cursorkreuz |
| F1 | Hilfe-Modus an und aus |
| Strg+C / Strg+Shift+C | x bzw. den ganzen Stack kopieren (2.1) |
| Strg+V | einfügen: im Stack Werte, sonst Text (2.1) |
| `\c` `\s` `\v` | wie in der Konsole: x kopieren, Stack kopieren, Werte einfügen; das `\` wartet, bis das nächste Zeichen kommt |
| Esc | im Hilfe-Modus: Hilfeschirm schließen, beim zweiten Mal den Hilfe-Modus beenden; sonst ohne Wirkung |

- **Rückmeldung:** Der Knopf, der dem getippten Zeichen entspricht, leuchtet kurz auf: Ziffern, `.`, `ê` und
  ENTER etwa 250 ms, Operatoren etwa 600 ms. Ein Buchstabe leuchtet auf seiner Alpha-Taste und zeigt dabei den
  Buchstaben so, wie er getippt wurde (`e` bzw. `E` auf der Taste D). Ein Großbuchstabe mit eigener Taste ist
  ein Befehl (`D`, `S`, `R` …) und lässt diese Taste aufleuchten wie ein Operator. Ist ein Name fertig, leuchtet seine Funktionstaste, falls es eine gibt;
  bei `3 30sin*` leuchten beim `*` also sin und × gleichzeitig. So lernt man nebenbei die Belegung. Gibt es
  keinen passenden Knopf (z.B. `<`), leuchtet nichts.
- **Im Hilfe-Modus** zeigt eine getippte Taste die Hilfe zu ihrem Zeichen.
- **AltGr:** Windows meldet AltGr als Strg+Alt. Diese Kombination geht wie ein normales Zeichen an den
  Rechner, sonst fehlten auf der deutschen Tastatur `|`, `~`, `{`, `}` und `²`. Nur Strg allein bleibt dem
  System, außer Strg+C und Strg+V (2.1).

## 7. Offen

Die offenen Punkte stehen jetzt im Backlog ([process/backlog.md](../process/backlog.md)), jeweils mit ihrer
alten Nummer („alt: app.md 4“). Die erledigten Punkte unten behalten ihre Nummern, weil Code und Texte auf sie
verweisen.

## 8. Erledigt

2\. **Bibliotheken als Domänen:** umgesetzt; die Bibliotheken sind in den Rechner einkompiliert (api.md 9.1),
   die App zeigt sie als Domänen der Funktionstasten.

5\. **Fenstergröße ändern:** umgesetzt als Zoom mit Dehnung (1.1); das Querformat ist Backlog FA-5.

7\. **Farben der Umschalttasten:** SHIFT als orange Taste, passend zu den orangen Shift-Hinweisen; ALPHA in der
   Farbe der Alpha-Hinweise, also hellgrün.

8\. **Alpha und Großbuchstaben:** ALPHA schaltet auf Kleinbuchstaben, sie bleiben bis zum nächsten ALPHA (oder
   einem Nicht-Buchstaben): „ALPHA a b c ALPHA“ ergibt `abc`. Im Alpha-Modus heißt SHIFT „ABC“ (die Taste zeigt,
   was ein Druck bewirkt) und gilt wie sonst für einen Tastendruck: „ALPHA SHIFT J“ ergibt `J`, danach ist der
   Alpha-Modus beendet. Das folgt der Grammatik: Namen bestehen aus Kleinbuchstaben, Befehle aus genau einem
   Großbuchstaben. Das bisherige Umschalten auf dauerhafte Großbuchstaben entfällt.

9\. **TAB:** Das Zeichen ⇥ deutlich größer; der Shift-Hinweis ⇤ fehlt sichtbar auf der Taste; prüfen, ob
   Shift+TAB in allen Lagen rückwärts geht.

10\. **Tooltips für das Cursorkreuz und die Maximieren-Taste:** ◄ „Seite zurück“, ► „nächste Seite“ (bzw. je
   nach Bereich), `[ ]` „Vollbild für die markierte Seite“, `[|]` „2 Seiten“.

11\. **Tooltips für die Elemente der Anzeige** (Vorschläge für die Texte):

   | Element | Tooltip |
   |---|---|
   | leerer Bereich der Statuszeile | die aktuellen Einstellungen |
   | DEG | Winkelmodus = 360° |
   | RAD | Winkelmodus = 2π |
   | GRD | Winkelmodus = 400 gon |
   | SHIFT | Umschalter: orange Befehle aktiv |
   | ALPHA (abc) | Umschalter: Buchstaben (für Funktionen und Befehle) |
   | ~ | Präfix ~ |
   | \| | Präfix \| |
   | Eingabe, Stack … | Seite: letzte Eingaben, Werte-Stack …; Wechsel mit TAB |
   | F: Grundfunktionen | Funktionen: π … RAD |
   | `>:` | aktuelle Eingabe |
   | ◄ / ► | Seite zurück / nächste Seite |

   Für die großen Bereiche (ganze Spalten) keine Tooltips: Am PC würden sie ständig aufpoppen, am Handy bliebe
   langes Drücken frei.

12\. **Orange Rahmen mit Namen:** Unten am Rahmen steht der Name des Bereichs (Eingabe, Stack …); der Name hat
   einen Tooltip.

14\. **Tooltips oberhalb** der Taste statt darunter, wo das Cursorkreuz im Weg ist. Umgesetzt als abgerundeter
   hellgelber Kasten mit schwarzer Schrift, ohne Zipfel: Ein Zipfel säße immer in der Mitte und zeigte oft nicht
   auf die Taste. Passt oben kein Platz, steht er darunter.

23\. **Anzeige passt sich der Höhe an:** umgesetzt. Nach der Liste der Schriftgrößen geht es mit der kleinsten
   weiter, bis die Höhe gefüllt ist; Verlauf, Stack und Rahmen reichen bis zum unteren Rand.

24\. **Doppelklick wechselt die Größe:** umgesetzt; ein Doppelklick in Eingabe oder Stack wechselt zwischen
   `[ ]` und `[|]` (3.5).

21\. **Hilfe springt zum letzten Tooltip:** umgesetzt; der Hilfeschirm startet mit der Seite zur Taste des letzten
   Tooltips, wenn er höchstens etwa 10 s her ist (5.2).
