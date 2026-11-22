# Tastentabelle

Die Spezifikation des Tastenfelds (DG-7): welche Taste wo sitzt, was sie zeigt und was sie tut, in jedem Modus, am
Tastenfeld und an der PC-Tastatur. Wie die Tasten aussehen und sich verhalten, steht in [app.md](app.md) Kapitel 3.

- **Erzeugt und von Hand:** Die Tabellen zwischen `<!-- erzeugt: … -->` und `<!-- ende -->` schreibt
  `dart run tool/keytable.dart` aus app/lib/keys.dart und app/lib/menu_tree.dart; dort nichts von Hand ändern. Der
  Text dazwischen wird von Hand gepflegt.
- **Geplantes** steht *kursiv mit dem Eintrag* (z.B. *csc (FR-15)*) und kommt aus [keys_planned.txt](keys_planned.txt);
  soll eine belegte Zelle etwas anderes bekommen, steht der heutige Wert davor (sinh → *⇄DEG/RAD (FR-15)*).
  Eine Änderung am Tastenfeld kommt zuerst dorthin, dann in den Code.
- **Zellen:** je Zelle eine Belegung; was auf der Taste steht und, wenn es abweicht, in Klammern, was eingegeben
  wird. Reicht der Platz nicht, steht eine Nummer in der Zelle und die Beschreibung als Fußnote unter der Tabelle.
- **⇄ vor einem Namen:** die Funktion schaltet um (Toggle), z.B. *⇄DEG/RAD* zwischen zwei Winkelmodi.
- **PC bei Funktionen:** „sin…“ heißt: alle Belegungen der Taste tippt man mit ihrem Namen (sin, asin, sinh,
  asinh); π tippt man als pi…. Wo eine Belegung anders getippt wird, steht sie dahinter („ln…, außer ~ln für eˣ“).
- **Spalten:** normal, nach den Präfixen `~`, `|`, `~|`, dieselben mit Shift (⇧), der Buchstabe im Alpha-Modus,
  die Symbole von Shift+ALPHA (FA-9) und das Gegenstück auf der PC-Tastatur. **Modi** verweist auf die Tabellen der
  Modi, die die Taste umbelegen; leer heißt: in jedem Modus gleich.

## 1. Anordnung

Hochformat; das Querformat steht in Kapitel 6.

<!-- erzeugt: anordnung -->
Oberer Block (Beschriftung / Shift):

| | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| R1 | SHIFT | ALPHA / ABC | Cursorkreuz, in der Ecke frei | Cursorkreuz, in der Ecke □ / ◫ | TAB / ⇤ | MENÜ / HILFE |
| R2 | ' | ( ) reserviert | [ ] reserviert | { } / } | CL / AC | ⌫ / C |
| R3 | D / Y | F1 | F2 | F3 | F4 | F5 |
| R4 | S / R | F6 | F7 | F8 | F9 | F10 |
| R5 | ! | yˣ | x² | x³ | ° | % |

Unterer Block:

| | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| R6 | ENTER / \_ | 7 | 8 | 9 | ÷ / > |
| R7 | : | 4 | 5 | 6 | × / & |
| R8 | \| | 1 | 2 | 3 | − / < |
| R9 | ~ | ê | 0 | . | + / = |
<!-- ende -->

## 2. Rechnen

### Oberer Block

<!-- erzeugt: rechnen-oben -->
| Taste | Modi | normal | ~ | \| | ~\| | ⇧ | ⇧~ | ⇧\| | ⇧~\| | Alpha | Symbole | PC |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| SHIFT |  | SHIFT |  |  |  |  |  |  |  |  |  | steckt im Zeichen |
| ALPHA |  | ALPHA |  |  |  | ABC |  |  |  |  |  | – |
| TAB |  | TAB |  |  |  | ⇤ |  |  |  |  |  | Tab |
| MENÜ |  | MENÜ |  |  |  | HILFE |  |  |  |  |  | F10, \\m |
| ◄ ▲ ► ▼ |  | Cursorkreuz |  |  |  |  |  |  |  |  |  | Pfeiltasten |
| □ / ◫ |  | maximieren / teilen |  |  |  |  |  |  |  |  |  | – |
| ' |  | ' |  |  |  |  |  |  |  | \\ |  | ⇧+# |
| ( ) |  | reserviert |  |  |  |  |  |  |  | a |  | – |
| [ ] |  | reserviert |  |  |  |  |  |  |  | b |  | – |
| { } |  | { } ({) |  |  |  | } |  |  |  | c |  | AltGr+7 |
| CL |  | CL |  |  |  | AC |  |  |  | d |  | Esc |
| ⌫ |  | ⌫ |  |  |  | C |  |  |  |  |  | Backspace |
| D |  | D |  |  |  | Y |  |  |  | e |  | ⇧+d |
| F1 … F10 |  | [Domänen](#domänen) |  |  |  |  |  |  |  | f–j, l–p |  | Namen tippen (Domänen) |
| S |  | S | ~R |  |  | R |  |  |  | k |  | ⇧+s |
| ! |  | ! |  |  |  |  |  |  |  | q |  | ⇧+1 |
| yˣ |  | yˣ (^) | ˣ√y |  |  |  |  |  |  | r |  | ^ |
| x² |  | x² (²) | √x |  |  |  |  |  |  | s |  | AltGr+2 |
| x³ |  | x³ (³) | ∛x |  |  |  |  |  |  | t |  | AltGr+3 |
| ° |  | ° | →kart |  |  |  |  |  |  | u |  | ⇧+^ |
| % |  | % | ~% | \|% | ~\|% |  |  |  |  | v |  | ⇧+5 |
<!-- ende -->

### Unterer Block

<!-- erzeugt: rechnen-unten -->
| Taste | Modi | normal | ~ | \| | ~\| | ⇧ | ⇧~ | ⇧\| | ⇧~\| | Alpha | Symbole | PC |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ENTER |  | ENTER |  |  |  | \_ |  |  |  |  |  | Leertaste, Enter (Ziffernblock) |
| 7 |  | 7 |  |  |  |  |  |  |  |  |  | 7 |
| 8 |  | 8 |  |  |  |  |  |  |  |  |  | 8 |
| 9 |  | 9 |  |  |  |  |  |  |  |  |  | 9 |
| ÷ |  | ÷ (/) | 1/x | \|/ |  | > | ≤ |  |  | w |  | / |
| : |  | : | ~: | \|: | ~\|: |  |  |  |  |  |  | ⇧+. |
| 4 |  | 4 |  |  |  |  |  |  |  |  |  | 4 |
| 5 |  | 5 |  |  |  |  |  |  |  |  |  | 5 |
| 6 |  | 6 |  |  |  |  |  |  |  |  |  | 6 |
| × |  | × (\*) |  |  |  | & | oder |  |  | x |  | \* |
| \| |  | \| |  | \|x\| |  |  |  |  |  |  |  | AltGr+< |
| 1 |  | 1 |  |  |  |  |  |  |  |  |  | 1 |
| 2 |  | 2 |  |  |  |  |  |  |  |  |  | 2 |
| 3 |  | 3 |  |  |  |  |  |  |  |  |  | 3 |
| − |  | − (-) |  |  |  | < | ≥ |  |  | y |  | - |
| ~ |  | ~ |  |  |  |  |  |  |  |  |  | AltGr++ |
| ê |  | ê |  |  |  |  |  |  |  |  |  | ^ e |
| 0 |  | 0 |  |  |  |  |  |  |  |  |  | 0 |
| . |  | . |  |  |  |  |  |  |  |  |  | . |
| + |  | + |  |  |  | = | ≠ |  |  | z |  | + |
<!-- ende -->

### Domänen

Die Funktionstasten F1–F10 zeigen die Seite der gewählten Domäne. Die eingebauten Domänen stehen hier; die Domänen
aus Bibliotheken (`library/*.rpnlib`) stehen in deren Hilfe.

<!-- erzeugt: domaenen -->
### Grundfunktionen

| Taste | Modi | normal | ~ | \| | ~\| | ⇧ | ⇧~ | ⇧\| | ⇧~\| | Alpha | Symbole | PC |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| π |  | π (pi) |  |  |  | e |  |  |  |  |  | pi… |
| rnd |  | rnd | ~seed |  |  | seed |  |  |  |  |  | rnd… |
| round |  | round |  |  |  |  |  |  |  |  |  | round… |
| dms |  | dms |  |  |  |  |  |  |  |  |  | dms… |
| DEG |  | DEG (deg) |  |  |  |  |  |  |  |  |  | deg… |
| sin | [Trig](#trig) | sin | asin | *csc (FR-15)* | *acsc (FR-15)* | sinh → *⇄DEG/RAD (FR-15)* | asinh |  |  |  |  | sin… |
| cos | [Trig](#trig) | cos | acos | *sec (FR-15)* | *asec (FR-15)* | cosh → *⇄CIRC/HYPR (FR-15)* | acosh |  |  |  |  | cos… |
| tan | [Trig](#trig) | tan | atan | *cot (FR-15)* | *acot (FR-15)* | tanh | atanh |  |  |  |  | tan… |
| ln |  | ln | eˣ |  |  | log |  |  |  |  |  | ln…, außer ~ln für eˣ |
| RAD |  | RAD (rad) |  |  |  | GRD (grd) |  |  |  |  |  | rad… |

### Programm

| Taste | Modi | normal | ~ | \| | ~\| | ⇧ | ⇧~ | ⇧\| | ⇧~\| | Alpha | Symbole | PC |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| X |  | X |  |  |  |  |  |  |  |  |  | X… |
| if |  | if |  |  |  |  |  |  |  |  |  | if… |
| ifel |  | ifel |  |  |  |  |  |  |  |  |  | ifel… |
| loop |  | loop |  |  |  |  |  |  |  |  |  | loop… |
| times |  | times |  |  |  |  |  |  |  |  |  | times… |
<!-- ende -->

## 3. Modi

### Modi, die Tasten umbelegen

Je Modus nur die Tasten, die sich ändern; alle anderen wirken wie im Grundmodus (Kapitel 2).

<!-- erzeugt: modi -->
### Quer

#### Quer: Querformat (FA-5)

(noch keine geänderten Tasten)

### Trig

#### Trig: HYPR, hyperbolisch (FR-15)

| Taste | Modi | normal | ~ | \| | ~\| | ⇧ | ⇧~ | ⇧\| | ⇧~\| | Alpha | Symbole | PC |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| sin |  | *sinh (FR-15)* | *asinh (FR-15)* | *csch (FR-15)* | *acsch (FR-15)* |  |  |  |  |  |  |  |
| cos |  | *cosh (FR-15)* | *acosh (FR-15)* | *sech (FR-15)* | *asech (FR-15)* |  |  |  |  |  |  |  |
| tan |  | *tanh (FR-15)* | *atanh (FR-15)* | *coth (FR-15)* | *acoth (FR-15)* |  |  |  |  |  |  |  |
<!-- ende -->

### Hilfe-Modus

Shift+MENÜ bzw. F1 schaltet ihn ein. Im Inspekt-Modus zeigt jede Taste ihre Hilfe, eingegeben wird nichts. Abweichend
wirken (Einzelheiten in [app.md](app.md) 5.2):

| Taste | Inspekt-Modus | Lese-Modus | PC |
|---|---|---|---|
| MENÜ | BEENDEN: beendet die Hilfe | ANFANG: Startseite | F1, Esc beendet |
| ALPHA | LESEN: in den Lese-Modus | INSPEKT: zurück | – |
| ⌫ | zeigt seine Hilfe | BEENDEN: beendet die Hilfe | – |
| ◄ | zurück zur vorigen Seite | zurück zur vorigen Seite | ← |
| ▲ ▼ | – | blättern in der Seite | ↑ ↓ |
| ► | – | folgt dem gewählten Verweis, ohne Auswahl wählt den ersten | → |
| TAB / ⇤ | zeigt seine Hilfe | nächster bzw. voriger Verweis | Tab, Shift+Tab |
| ENTER | zeigt seine Hilfe | folgt dem gewählten Verweis | Enter |

### Nach `'`

`'` schreibt den Apostroph; die Funktionstasten zeigen danach die Variablen und Tags statt der Domäne
([app.md](app.md) 3.2). Alle anderen Tasten wirken wie im Grundmodus.

## 4. Menü

MENÜ öffnet das Menü, ein weiterer Druck bricht ab (am PC F10, Esc oder `\m`). Im Menü heißt ENTER „OK“ und
übernimmt; es wirken nur MENÜ, SHIFT (für die Hilfe), OK und die Tasten des offenen Bereichs, alle anderen sind leer
([app.md](app.md) 3.6).

### Hauptmenü

Die Bereiche liegen auf dem Ziffernblock; OK schließt das Menü.

<!-- erzeugt: menue-haupt -->
| Taste | Bereich | PC |
|---|---|---|
| 4 | Bibliotheken | 4 |
| 8 | Modi | 8 |
<!-- ende -->

### Bibliotheken

Die Funktionstasten zeigen die Bibliotheken des Rechners; ein Druck schaltet eine Bibliothek ein oder aus, OK lädt
bzw. entlädt. Am PC drückt der Buchstabe der Funktionstaste (f–j, l–p) sie.

### Modi

Ein Druck schaltet zum nächsten Wert, Shift zum vorigen, OK stellt ein. Am PC drückt der Buchstabe die Taste, der
Großbuchstabe wie mit Shift.

<!-- erzeugt: menue-modi -->
| Taste | Modus | Werte | PC |
|---|---|---|---|
| F1 | Format | Std · Fix · Sci · Eng · SI | f |
| F2 | Winkel | Deg · Rad · Grd | g |
| F3 | Trig (kommt mit FR-15) | CIRC · HYPR · CARD · VERS · ELLP · ELLQ | h |
| F4 | Klasse (kommt mit FR-11) | ℝ · 𝔻 · ℚ · ℤ | i |
| F5 | – |  | j |
| F6 | Trenner | 1000 · 1,000 · 1'000 · 1 000 | l |
| F7 | Bruch | #.# · #/# · # #/# | m |
| F8 | Domain (kommt mit FR-11) | ℝ · ℂ | n |
| F9 | Auflösung (kommt mit FR-11) | simple · high · max | o |
| F10 | – |  | p |
<!-- ende -->

Ist Format gewählt und steht nicht auf Std (der erste Druck wählt es dann nur aus), zeigt der Ziffernblock Ziffern
für die Stellen:

| Taste | Stellen | PC |
|---|---|---|
| 0 … 9 | 0 … 9 | 0 … 9 |
| ê | 12 | – |
| . | 15 | – |

## 5. PC-Tastatur und Befehle

Die Spalte PC in den Tabellen nennt das Gegenstück für die normale Belegung; Shift-Zeichen wie `>` oder `=` tippt man,
wie sie auf der Taste stehen. Getippte Zeichen gehen so an den Rechner, wie sie getippt wurden ([app.md](app.md)
Kapitel 6).

### Nur am PC

| Taste | Wirkung |
|---|---|
| Return | Zeilenumbruch, wie ALPHA ⏎ |
| Enter (Ziffernblock) | ENTER, dann Zeilenumbruch |
| Esc | im Hilfe-Modus und im Menü: beendet bzw. bricht ab; sonst wie CL |
| F1 | Hilfe-Modus an und aus |
| F10 | wie MENÜ |
| Strg+C / Strg+Shift+C | x bzw. den ganzen Stack kopieren |
| Strg+V | einfügen: im Stack Werte, sonst Text |
| ^ (Tottaste) | wartet auf die nächste Taste: ^ e ergibt ê, sonst ^ vor der Taste |

### Befehle mit `\`

Das `\` wartet, bis das nächste Zeichen kommt.

| Befehl | Wirkung | App | Konsole |
|---|---|---|---|
| `\c` | x kopieren (für Excel mit Dezimalkomma) | ✓ | ✓ |
| `\s` | den ganzen Stack kopieren | ✓ | ✓ |
| `\v` | Zahlen aus der Zwischenablage einfügen | ✓ | ✓ |
| `\m` | Menü öffnen | ✓ | – |
| `\q` | zurück zum Menü der Konsole | – | ✓ |

## 6. Querformat

Kommt mit FA-5: Anzeige oben über die volle Breite, darunter drei Tastenfelder. Geänderte Belegungen stehen dann als
Modus „Quer“ in Kapitel 3.
