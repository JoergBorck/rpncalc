# RPN-Rechner: Flutter-App

Die App ist die Oberfläche für Smartphones (hochkant). Sie benutzt denselben Rechnerkern wie die Konsole
(`RpnApi`, `Zustand`, siehe [api.md](api.md)) und liegt im Verzeichnis `app/`, das das Paket `rpncalc` per Pfad
einbindet. Ein klickbares Modell der Oberfläche: https://claude.ai/artifact/XaT5599vaeNVuorCU5VvwS

## 1. Aufbau

- Oben die **Anzeige**, unten das **Tastenfeld**.
- Das Tastenfeld hat einen oberen Block mit 5 Reihen zu 6 Tasten (Funktionen) und darunter einen Block mit
  4 Reihen zu 5 Tasten (Ziffern und Grundrechenarten).
- Ein **Cursorkreuz** aus vier Tasten (◄ ▲ ► ▼, schräg gestellt) sitzt zwischen beiden und ragt etwas in die Anzeige hinein.

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
  12 3+ 4.5█     >:        4.5
  7               0:         15
                  1:          7
  ```
- **Seiten:** Die Anzeige lässt sich seitlich wischen: Rechnen, Variablen und Tags, Funktionen.
- **Statuszeile:** Winkelmodus, aktive Umschaltungen (Shift, `~`, `|`, `'`, Alpha) und die Seite der
  Funktionstasten. Den gewählten Bereich zeigt der Name unten am orangen Rahmen, immer auf der Außenseite
  (Eingabe links, Stack rechts), damit das Cursorkreuz ihn nicht verdeckt.

## 3. Tastenfeld

### 3.1 Belegung

Oberer Block (Hauptfunktion / Shift; `~` und `|` zeigen erlaubte Präfixe):

| | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| R1 | SHIFT | ALPHA | Cursorkreuz, in der Ecke frei | Cursorkreuz, in der Ecke `[ ]` / `[\|]` | TAB / ⇤ | MENÜ / HILFE |
| R2 | `'` | `( )` reserviert | `[ ]` reserviert | `{` / `}` | frei | ⌫ / `C` |
| R3 | `D` / `Y` | F1 | F2 | F3 | F4 | F5 |
| R4 | `S` / `R`, `~`: `~R` | F6 | F7 | F8 | F9 | F10 |
| R5 | `!` | `^`, `~`: ˣ√y | `²`, `~`: √x | `³`, `~`: ∛x | `°`, `~`: →kart | `%`, `~%`, `\|%`, `~\|%` |

Unterer Block:

| | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| R6 | ENTER (Leerzeichen) / `_` | 7 | 8 | 9 | `/`, `~`: 1/x, `\|`: `\|/` |
| R7 | `:`, `~:`, `\|:`, `~\|:` | 4 | 5 | 6 | `*` |
| R8 | Präfix `\|` (zweimal: `\|\|` Betrag) | 1 | 2 | 3 | `-` |
| R9 | Präfix `~` (eingefärbt) | `ê` | 0 | `.` | `+` |

- `( )` und `[ ]` sind für Vektoren und Einheiten reserviert.
- ENTER liegt wie beim HP links neben der 7.

### 3.2 Umschaltungen

- **Shift** gilt für einen Tastendruck. Die Shift-Funktion steht klein links oben auf der Taste.
- **`~` und `|`** sind Präfixe wie in der Sprache: Die Taste schreibt das Zeichen und schaltet die Beschriftung
  der Tasten um, auf denen der Präfix erlaubt ist (kleine Markierung rechts oben). Beide lassen sich kombinieren.
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
- **Stack:** ▲ und ▼ blättern zu tieferen Werten, ◄ und ► schieben lange Werte seitlich.
- Der gewählte Bereich hat einen orangen Rahmen; kleine orange Pfeile links bzw. rechts am Rahmen zeigen, dass
  sich mit ◄ bzw. ► etwas schieben lässt. Jede Eingabe stellt Blättern und Schieben zurück.
- **Funktionen:** ◄ und ► blättern zwischen den Seiten der Funktionstasten: die Domäne und die eigenen
  Funktionen. Reichen 10 Tasten nicht, gibt es weitere Seiten.
- **Variablen:** Die Funktionstasten zeigen die Variablen und Tags.

- **Beschriftung:** Jede Taste zeigt, was ein Druck bewirkt, nicht den aktuellen Zustand. TAB zeigt mit Shift
  „⇤ TAB“, die Maximieren-Taste `[ ]` bzw. `[|]` (3.5).

### 3.4 Funktionstasten und Domänen

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
  VS Code: `[ ]` bei geteilter Anzeige (maximieren), `[|]` bei maximierter (wieder teilen). Die Zeichen werden
  gezeichnet, nicht aus einer Schrift genommen.
- **Links neben ▼ (rechts neben ALPHA):** Platzhalter, noch ohne Funktion.

Verhalten:

- **Maximieren wirkt auf den gewählten Bereich:** Stack bzw. Eingabe bekommen die ganze Breite, die andere
  Spalte verschwindet. Bei Funktionen und Variablen haben die Seiten schon die ganze Breite, dort wirkt die
  Taste nicht.
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
- **Startseite:** Shift+MENÜ und dann MENÜ ohne Auswahl zeigt die Startseite `#`, davor die der App mit den
  Verweisen auf die vier Anzeigen.

### 5.1 Tooltips

- **PC und Browser:** Fährt die Maus über eine Taste, zeigt ein Tooltip die Kurztexte **aller** Belegungen
  der Taste, je eine Zeile: normal, Shift, `~`, `|`, `~|`. Bei x² also `²  x → x²  Quadrat` und
  `~²  x → √x  Quadratwurzel`.
- **Handy:** Langes Drücken zeigt denselben Tooltip.
- Tooltips sind reine Anzeige. Die Einzelheiten gibt es im Hilfe-Modus.

### 5.2 Hilfe-Modus

| Aktion | Wirkung |
|---|---|
| **Shift+MENÜ** | Hilfe-Modus an. Die Statuszeile zeigt die Marke „HILFE“ in eigener Farbe (hellblau), die MENÜ-Taste leuchtet. Die Anzeige bleibt sonst unverändert, damit man Elemente darin auswählen kann. |
| **Taste antippen** | Der Hilfeschirm erscheint über der Anzeige mit den Verwendungen aller Belegungen der Taste. Eingegeben wird nichts. |
| **Element in der Anzeige antippen** | Der Hilfeschirm zeigt die Hilfe zu diesem Element (5.3). |
| **MENÜ** | bei offenem Hilfeschirm: die Einzelheiten (Text mit Beispielen) zum gezeigten Eintrag |
| **Verweis antippen** | zeigt den Eintrag, auf den verwiesen wird |
| **◄** (Cursorkreuz) | zurück zum vorher gezeigten Eintrag |
| **Tipp auf den Hilfeschirm** (außerhalb der Verweise) | schließt den Hilfeschirm; der Hilfe-Modus bleibt, so lassen sich wieder Elemente der Anzeige auswählen |
| **weitere Taste** | zeigt deren Hilfe; das geht beliebig oft hintereinander |
| **⌫** | beendet den Hilfe-Modus |

- **Im Hilfe-Modus wird nichts eingegeben.** Stack, Eingabe und Verlauf bleiben unverändert, auch Shift, `~`,
  `|` und Alpha schalten nicht um, sondern zeigen ihre eigene Hilfe (`app:shift`, `~`, `|`, `app:alpha`).
- **Aufbau des Hilfeschirms:** oben der Titel; darunter je Belegung der Taste die Verwendungen (Schreibweise,
  Stack, Argumente, Kurztext); nach MENÜ die Einzelheiten; ganz unten die Verweise als antippbare Felder.
  Ist der Inhalt höher als die Anzeige, lässt er sich scrollen.

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
- **Umbruch und Verlauf** wirken unverändert (Kapitel 4).

| Taste | Wirkung |
|---|---|
| Leertaste | ENTER (Leerzeichen als Enter, Kapitel 4) |
| Enter (Return und Enter auf dem Ziffernblock) | tut, was der Name sagt: ENTER (Leerzeichen), dann Zeilenumbruch. Das Enter bleibt am Zeilenende vorgemerkt, wie beim HP: `5` Enter `+` ergibt 10, `5` Enter `3` `+` ergibt 8. Die Zeile wandert in den Verlauf, im Code ist es ein Zeilenumbruch |
| `_` | Trenner, direkt getippt (Umschalt+Minus) |
| Backspace | ⌫ |
| Tab / Shift+Tab | Bereich wechseln |
| Pfeiltasten | Cursorkreuz |
| F1 | Hilfe-Modus an und aus |
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
  System.
- **Später:** Strg+C und Strg+V wie `\c` und `\v` in der Konsole.

## 7. Offen

Die Nummern bleiben fest; erledigte Punkte wandern mit ihrer Nummer nach Kapitel 8.

1\. sinh, cosh und tanh gibt es im Rechner noch nicht (erst reference.md, dann umsetzen).

2\. Bibliotheken (Statistik, Schwingungen) als Domänen: die `.rpnlib`-Dateien müssen als Assets in die App.

3\. Speichern der Session beim Beenden.

4\. **Querformat:** Wird das Handy gedreht, braucht es eine eigene Aufteilung (z.B. Anzeige links, Tastenfeld
   rechts). Heute ist die App nur für Hochkant gebaut.

5\. **Fenstergröße ändern:** Unter Windows und im Browser lässt sich das Fenster größer und kleiner ziehen.
   Heute haben die Tasten eine feste Höhe, nur die Anzeige wächst mit. Das Tastenfeld sollte mitwachsen und
   die Schrift passend skalieren; bei sehr kleinen Fenstern braucht es eine Mindestgröße.

6\. **Shift+ALPHA neu belegen:** Großbuchstaben sind nicht die einzige Möglichkeit, da steckt noch Potential
   drin, z.B. „Lib“ für die Bibliotheken. Zu klären, was am meisten bringt.

13\. **Texte der Tooltips überarbeiten:** Taste für Taste gemeinsam durchgehen.

15\. **Wischen über die Funktionstasten:** Seitlich wischen wechselt zwischen den Sätzen der Funktionstasten
   (Domäne, eigene Funktionen, Variablen …). Der orange Rahmen, der dabei erscheint, zeigt kleine Pfeile links
   bzw. rechts, wenn es in diese Richtung weitere Sätze gibt.

16\. **Verhalten der Enter-Taste einstellbar:** Der Anwender legt fest, ob Enter (ENTER-Knopf der App bzw.
   Enter der Tastatur) nur ein Leerzeichen erzeugt oder Leerzeichen und Zeilenumbruch; die Umschalt-Variante
   tut dann jeweils das andere. Zu klären: wo der Trenner `_` in der App landet, wenn Shift+ENTER dafür frei
   werden muss, und wo die Einstellung liegt (Menü).

17\. **Shift-Hinweis auf ALPHA nach rechts:** Das kleine „ABC“ steht heute links oben auf ALPHA. Es soll nach
   rechts oben, damit links oben Platz bleibt, falls Shift+ALPHA eine eigene Funktion bekommt (Punkt 6).

18\. **Bibliotheken zur Laufzeit hinzufügen:** herunterladen (Paket `http`), aus einer Datei wählen
   (`file_picker`) oder über „Öffnen mit …“ für die Endung `.rpnlib`; die App speichert sie in ihrem eigenen
   Verzeichnis (`path_provider`) und meldet sie bei jedem Start mit `bibliothekHinzufuegen` beim Rechner an. Im
   Browser statt Dateien der Browser-Speicher.

19\. **Mehrsprachigkeit der Oberfläche:** Beschriftungen, Menüs und Hinweise der App über den Standardweg von
   Flutter (`flutter_localizations`, je Sprache eine `.arb`-Datei); die Sprache des Handys wird erkannt. Die
   Texte des Rechners (Hilfe, Meldungen) kommen aus ihm selbst, siehe [api.md](api.md) Punkt 14.

## 8. Erledigt

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
