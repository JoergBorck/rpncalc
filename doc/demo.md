# Demo: Körper auf der schiefen Ebene

Diese Demorechnung zeigt die Arbeit mit dem RPN-Rechner an einem Beispiel aus der Technischen Mechanik.
Dieselbe Aufgabe wird zweimal gelöst: einmal nur mit dem Stack, einmal mit Variablen.

## Aufgabe

Ein Körper mit der Masse m = 50 kg rutscht eine um α = 30° geneigte Ebene hinab.
Die Reibungszahl zwischen Körper und Ebene ist µ = 0,2. Wie groß ist die Beschleunigung a?

| Größe              | Formel                | Ergebnis        |
|--------------------|-----------------------|-----------------|
| Gewichtskraft      | F_G = m · g           | 490,5 N         |
| Hangabtriebskraft  | F_H = F_G · sin α     | 245,25 N        |
| Normalkraft        | F_N = F_G · cos α     | 424,79 N        |
| Reibungskraft      | F_R = µ · F_N         | 84,96 N         |
| Beschleunigung     | a = (F_H − F_R) / m   | **3,206 m/s²**  |

Zusammengefasst: a = F_G · (sin α − µ · cos α) / m

## Lösung 1: nur mit dem Stack

Die drei Eingabewerte werden einmal am Anfang auf den Stack gelegt und dann mit `R` (Rotate) und `S` (Swap)
dorthin geholt, wo sie gebraucht werden. `4:R` rotiert dabei 4 statt 3 Elemente.

```
deg50 30 0.2R 9.81*4:R sinScos5:R*-*S/
```

| Eingabe         | Stack danach (Tos rechts)                | Bedeutung                              |
|-----------------|------------------------------------------|----------------------------------------|
| `deg50 30 0.2`  | 50  30  0.2                              | Winkel in Grad; m, α, µ eingeben       |
| `R`             | 30  0.2  50                              | m nach oben holen                      |
| ` 9.81*`        | 30  0.2  50  490.5                       | Leerzeichen verdoppelt m, F_G = m · g  |
| `4:R`           | 0.2  50  490.5  30                       | α aus der Tiefe nach oben holen        |
| ` sin`          | 0.2  50  490.5  30  0.5                  | α verdoppeln, sin α                    |
| `S`             | 0.2  50  490.5  0.5  30                  | α wieder nach oben                     |
| `cos`           | 0.2  50  490.5  0.5  0.866               | cos α                                  |
| `5:R`           | 50  490.5  0.5  0.866  0.2               | µ aus der Tiefe nach oben holen        |
| `*`             | 50  490.5  0.5  0.1732                   | µ · cos α                              |
| `-`             | 50  490.5  0.3268                        | sin α − µ · cos α                      |
| `*`             | 50  160.29                               | resultierende Kraft F_H − F_R          |
| `S/`            | 3.2059                                   | durch m teilen: **a = 3,206 m/s²**     |

Das Ergebnis stimmt, und der Stack ist am Ende aufgeräumt. Die Eingabezeile ist aber kaum lesbar:
Man muss beim Schreiben jederzeit wissen, an welcher Position welcher Wert liegt (`4:R`, `5:R`).
Ein Fehler beim Mitzählen liefert ein falsches Ergebnis ohne Warnung.

## Lösung 2: mit Variablen

Zwischenergebnisse bekommen einen Namen. `'!x` legt die Variable x mit dem Tos an und nimmt ihn dabei vom Stack,
`'x` legt den Wert der Variablen wieder auf den Stack.

```
deg 50'!m 'm9.81*'!fg 'fg30sin*'!fh 'fg30cos*0.2*'!fr 'fh 'fr-'m/
```

| Eingabe            | Bedeutung                                       |
|--------------------|-------------------------------------------------|
| `deg 50'!m`        | Winkel in Grad, m = 50 anlegen                  |
| ` 'm9.81*'!fg`     | F_G = m · g                                     |
| ` 'fg30sin*'!fh`   | F_H = F_G · sin 30°                             |
| ` 'fg30cos*0.2*'!fr` | F_R = µ · F_G · cos 30°                       |
| ` 'fh 'fr-'m/`     | (F_H − F_R) / m: **a = 3,206 m/s²**             |

Jede Zeile der Tabelle liest sich wie eine Formel: erst die Zutaten holen, dann rechnen, dann das Ergebnis benennen.
Die Zwischenergebnisse bleiben mit Namen abrufbar, z.B. zeigt `'fr` jederzeit die Reibungskraft.
Am Ende liegt nur das Ergebnis auf dem Stack.

Vor den Zahlen steht hier kein Leerzeichen (`'m9.81*`): Ein Leerzeichen nach einer Variablen wirkt als Enter und
würde den gelesenen Wert verdoppeln.

Ein Tippfehler im Namen fällt sofort auf, statt ein falsches Ergebnis zu liefern:

```
'fgg
 ^ Fehler: Variable ist nicht definiert: fgg
```

Variablen können auch mehrere Elemente haben, z.B. legt `0 0 0 3:'!s` einen Vektor mit drei Nullen an,
`1 2 3 0:3:'+s` addiert elementweise und `0:3:'s` holt alle drei Elemente auf den Stack.

## Lösung 3: mit Tags

Tags markieren Zellen auf dem Stack. Die Zwischenergebnisse bleiben dort sichtbar und werden über ihren Namen gelesen.
`'|x` markiert den Tos, `'x` kopiert den markierten Wert auf den Stack.

```
deg 50'|m 9.81*'|fg 30sin*'|fh 'fg 30cos*0.2*'|fr 'fh 'fr-'m/
```

Der Unterschied zu Lösung 2 liegt darin, wo die Werte stehen:

| | Variablen (`'!x`) | Tags (`'\|x`) |
|---|---|---|
| Wert liegt | in einem eigenen Speicher außerhalb des Stacks | auf dem Stack selbst |
| Anlegen | `'!x` nimmt den Wert vom Stack | `'\|x` markiert den Wert, er bleibt auf dem Stack |
| Wert ändern | `'=x`, `'+x` … | `'=x`, `'+x` … schreiben direkt in die markierte Zelle |
| Schutz | keiner nötig | getaggte Zellen können nicht versehentlich verbraucht werden |

Versucht man, mit einem getaggten Wert direkt weiterzurechnen, schützt der Tag ihn:

```
50'|m+
     ^ Fehler: Tag blockiert den Stack: m, entfernen mit 'D
```

Deshalb steht nach jedem `'|x` ein Leerzeichen, das den Wert verdoppelt; gerechnet wird mit der Kopie.
Am Ende räumt `'C` Stack und Tags auf. Einzelne Tags entfernt `'~x`, der Wert bleibt dabei auf dem Stack.

## Lösung 4: als eigene Funktion

Die ganze Rechnung lässt sich als eigene Funktion ablegen und mit Argumenten aufrufen. `~:` holt im Code
die Argumente der Reihe nach (m, α, µ):

```
{~:'!m~:'!al~:'!mu_'m9.81*'!fg_'fg'al sin*'!fh_'fg'al cos*'mu*'!fr_'fh'fr-'m/}':ebene
deg 50:30:0.2:ebene
```

Ergebnis: **3,206 m/s²**. Ein `_` trennt nur, ohne als Enter zu wirken, und macht den Code etwas lesbarer.

# Demo: Statistik wie mit Σ+ beim HP-41

Dieses Beispiel zeigt, wie man mit eigenen Funktionen eine ganze Funktionsgruppe nachbaut.
Wie beim HP-41 werden nur sechs Summen gespeichert, im Vektor `ss`:
Element 0 = n, 1 = Σx, 2 = Σx², 3 = Σy, 4 = Σy², 5 = Σxy.

Die Funktionen stehen auch als Bibliothek in [library/statistik.rpnlib](../library/statistik.rpnlib)
(Menü **Bibliotheken → statistik**).

```
{0 0 0 0 0 0 6:'!ss}':sclr
{'!tx'!ty'tx'ty*_'ty²_'ty_'tx²_'tx_1_0:6:'+ss_6:D'~tx'~ty_0:'ss}':sadd
{~::{sadd_D}times_0:'ss}':sall
{~::'ss_~::'ss*_0:'ss/~_~::'ss+}':sq
{3:'ss_0:'ss/_1:'ss_0:'ss/}':mean
{3:3:4:sq_0:'ss1-/~²_1:1:2:sq_0:'ss1-/~²}':sdev
{1:3:5:sq_1:1:2:sq_3:3:4:sq*~²/}':corr
{1:3:5:sq_1:1:2:sq/0:Y_1:'ss_0:'ss/*_3:'ss_0:'ss/S-}':lr
{lr_SR*+}':yhat
{lr_RS-S/}':xhat
```

| Funktion | Eingabe | Ergebnis (Tos rechts) | Formel |
|---|---|---|---|
| `sclr` | | | Summen löschen |
| `sadd` | `y x sadd` | n | Wertepaar aufnehmen: n+1, Σx+x, Σx²+x², Σy+y, Σy²+y², Σxy+x·y |
| `sall` | `k:sall` | n | k Wertepaare vom Stack aufnehmen (`sadd` in einer Schleife) |
| `sq` | `a:b:c:sq` | Σc − Σa·Σb/n | Hilfsfunktion für Varianz und Kovarianz |
| `mean` | | ȳ x̄ | Σy/n, Σx/n |
| `sdev` | | s_y s_x | √((Σx² − (Σx)²/n)/(n−1)), für y entsprechend |
| `corr` | | r | S_xy / √(S_xx · S_yy) |
| `lr` | | b a | Gerade y = a + b·x: b = S_xy / S_xx, a = ȳ − b·x̄ |
| `yhat` | `x yhat` | ŷ | a + b·x |
| `xhat` | `y xhat` | x̂ | (y − a) / b |

Beispiel mit x = 1…5 und y = 2, 4, 5, 4, 5:

```
sclr
2 1sadd
4 2sadd
5 3sadd
4 4sadd
5 5sadd
```

Danach ergeben `mean` → ȳ = 4, x̄ = 3; `sdev` → s_y = 1,225, s_x = 1,581; `corr` → r = 0,7746;
`lr` → b = 0,6, a = 2,2; `6yhat` → 5,8; `5xhat` → 4,667.

Mit Messdaten aus Excel oder einer Textdatei geht es schneller: die Spalten y und x markieren (y links),
kopieren und in der Konsole `\v` eingeben. Die Meldung „10 Zahlen eingefügt“ nennt die Anzahl, also 5 Paare:

```
sclr
\v
5:sall
```

`sall` ruft `sadd` in einer Schleife auf. `{sadd}times` allein ginge nicht, denn `sadd` legt n auf den Stack,
und der nächste Durchlauf würde n für ein x halten. Deshalb steht in `sall` ein `D` dahinter: `{sadd_D}`.

Was man dabei sieht:
- **Vektor-Variablen**: `6:'!ss` legt die sechs Summen an, `0:6:'+ss` addiert sechs Werte auf einmal.
- **Argumente**: `sq` bekommt mit `a:b:c:sq` die Nummern der Summen und holt sie mit `~:` ab.
  `~::'ss` legt ein Argument auf den Stack und gibt es mit `:` gleich als Elementnummer an `'ss` weiter.
- **Eigene Funktionen rufen eigene Funktionen auf**: `yhat` und `xhat` nutzen `lr`, `lr` nutzt `sq`.
- **Hilfsvariablen** (`'!tx`, `'!ty`) werden am Ende von `sadd` mit `'~` wieder entfernt.

Median und Quantile lassen sich aus Summen nicht berechnen, dafür bräuchte man die Einzelwerte.
Für Konfidenzintervalle wäre zusätzlich die t-Verteilung nötig.
