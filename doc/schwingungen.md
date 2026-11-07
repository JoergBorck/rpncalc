# Bibliothek: Schwingungen

Die Datei [library/schwingungen.rpnlib](../library/schwingungen.rpnlib) enthält eigene Funktionen für
harmonische, gedämpfte und erzwungene Schwingungen. Sie ist in der Sprache des Rechners geschrieben und
zeigt nebenbei, wie man mit Argumenten, `Y`, `R` und `ifel` größere Funktionen baut.

## Laden

Im Menü **Bibliotheken → schwingungen** auswählen. Die Funktionen kommen
zu den vorhandenen dazu. Eine eigene Funktion mit demselben Namen wird dabei ersetzt.

## Vereinbarungen

- **Eingaben:** Funktionen mit einer Eingabe nehmen den Tos (wie `sin`): `50omega`.
  Funktionen mit mehreren Eingaben bekommen sie als Argumente, in der Reihenfolge der Tabelle: `0.5:200:eigen`.
- **Phasen sind im Bogenmaß**, unabhängig vom Winkelmodus. Die Bibliothek rechnet intern um (`rw`, `wr`)
  und lässt den Winkelmodus unverändert.
- **Einheiten:** SI-Einheiten (m, s, kg, N). ω ist die Kreisfrequenz in 1/s.
- **Keine Spuren:** Die Funktionen legen keine Variablen an, auf dem Stack bleibt nur das Ergebnis.
- **Unmögliche Werte** liefern `NaN` oder `Infinity` statt eines Fehlers, z.B. `wd` im Kriechfall (δ > ω₀).
- **Fehlende Argumente** sind ein Fehler („Es gibt keine weiteren Argumente“). Was die Funktion bis dahin
  auf den Stack gelegt hat, bleibt liegen.

## Grundgrößen

| Funktion | Eingabe | Ergebnis | Formel |
|---|---|---|---|
| `omega` | f | ω | ω = 2π·f |
| `freq` | ω | f | f = ω / 2π |
| `per` | ω | T | T = 2π / ω |
| `eigen` | m:k | ω₀ | ω₀ = √(k/m), Federpendel |
| `pendel` | l | ω₀ | ω₀ = √(g/l), Fadenpendel mit g = 9,81 m/s² |

## Harmonische Schwingung

x(t) = A · cos(ω·t + φ)

| Funktion | Argumente | Ergebnis | Formel |
|---|---|---|---|
| `hx` | A:ω:φ:t | x | A · cos(ωt + φ) |
| `hv` | A:ω:φ:t | v | −A·ω · sin(ωt + φ) |
| `ha` | A:ω:φ:t | a | −A·ω² · cos(ωt + φ) |
| `hamp` | x₀:v₀:ω | A φ | Amplitude und Phase aus den Anfangswerten: A = √(x₀² + (v₀/ω)²) |
| `hen` | m:ω:A | E | Gesamtenergie ½·m·ω²·A² |

## Gedämpfte Schwingung

x″ + 2δ·x′ + ω₀²·x = 0, mit der Abklingkonstante δ = d / 2m (d: Dämpfungskonstante in kg/s).

| Funktion | Argumente | Ergebnis | Formel |
|---|---|---|---|
| `delta` | m:d | δ | d / 2m |
| `lehr` | ω₀:δ | D | Lehrsches Dämpfungsmaß δ / ω₀ |
| `wd` | ω₀:δ | ω_d | Eigenkreisfrequenz der gedämpften Schwingung √(ω₀² − δ²) |
| `dekr` | ω₀:δ | Λ | logarithmisches Dekrement δ · T_d = 2π·δ / ω_d |
| `guete` | ω₀:δ | Q | Güte ω₀ / 2δ |
| `dx` | x₀:v₀:ω₀:δ:t | x | Auslenkung aus den Anfangswerten, für alle drei Fälle (siehe unten) |

`dx` unterscheidet selbst, welcher Fall vorliegt (mit B = v₀ + δ·x₀):

| Fall | Bedingung | x(t) |
|---|---|---|
| Schwingfall | δ < ω₀ | e^(−δt) · (x₀·cos ω_d t + B/ω_d · sin ω_d t) |
| aperiodischer Grenzfall | δ = ω₀ | e^(−δt) · (x₀ + B·t) |
| Kriechfall | δ > ω₀ | e^(−δt) · (x₀·cosh κt + B/κ · sinh κt), κ = √(δ² − ω₀²) |

## Erzwungene Schwingung

x″ + 2δ·x′ + ω₀²·x = (F₀/m) · cos Ωt. Nach dem Einschwingen gilt x(t) = A · cos(Ωt − φ).

| Funktion | Argumente | Ergebnis | Formel |
|---|---|---|---|
| `famp` | F₀:m:ω₀:δ:Ω | A | (F₀/m) / √((ω₀² − Ω²)² + (2δΩ)²) |
| `fphase` | ω₀:δ:Ω | φ | Phasenverschiebung, 0 bis π (π/2 bei Ω = ω₀) |
| `fx` | F₀:m:ω₀:δ:Ω:t | x | A · cos(Ωt − φ), eingeschwungener Zustand |
| `vgr` | η:D | V | Vergrößerungsfunktion 1 / √((1 − η²)² + (2Dη)²), η = Ω/ω₀ |
| `wres` | ω₀:δ | Ω_res | Resonanzkreisfrequenz der Amplitude √(ω₀² − 2δ²) |

## Hilfsfunktionen

Sie werden von den anderen Funktionen benutzt und können auch direkt aufgerufen werden. Sie sind mit
`rpnintern` gekennzeichnet (reference.md 10.2) und haben deshalb in der App keine Funktionstaste.

| Funktion | Eingabe | Ergebnis | Bedeutung |
|---|---|---|---|
| `rw` | x | x′ | Winkel im Bogenmaß → Winkel im eingestellten Modus |
| `wr` | x′ | x | Winkel im eingestellten Modus → Bogenmaß |
| `osz` | s t (Stack) | c g | für `dx`: c = cos, cosh oder 1, g = sin/ω_d, sinh/κ oder t, je nach Vorzeichen von s = ω₀² − δ² |
| `fpol` | ω₀:δ:Ω | N φ | Nenner von `famp` und die Phase, mit `°` in einem Schritt berechnet |

`rw` und `wr` funktionieren ohne Abfrage des Winkelmodus: `~1_acos` liefert π, 180 oder 200, je nach Modus.

## Beispiel: Federpendel

Eine Masse m = 0,5 kg hängt an einer Feder mit k = 200 N/m.

| Eingabe | Ergebnis | Bedeutung |
|---|---|---|
| `0.5:200:eigen` | 20 | ω₀ in 1/s |
| `20freq` | 3,183 | f in Hz |
| `20per` | 0,3142 | T in s |
| `0.05:~1:20:hamp` | 0,0707 0,7854 | ausgelenkt um 5 cm, Startgeschwindigkeit −1 m/s: A = 7,07 cm, φ = π/4 |
| `0.05:20:0:0.1:hx` | −0,02081 | Auslenkung nach 0,1 s bei A = 5 cm, φ = 0 |
| `0.05:20:0:0.1:hv` | −0,9093 | Geschwindigkeit dazu |
| `0.5:20:0.05:hen` | 0,25 | Energie in J |

Mit einem Dämpfer, d = 2 kg/s:

| Eingabe | Ergebnis | Bedeutung |
|---|---|---|
| `0.5:2:delta` | 2 | δ in 1/s |
| `20:2:lehr` | 0,1 | D |
| `20:2:wd` | 19,90 | ω_d etwas kleiner als ω₀ |
| `20:2:dekr` | 0,6315 | Λ: jede Periode schrumpft die Amplitude auf e^(−0,63) ≈ 53 % |
| `20:2:guete` | 5 | Q |
| `0.05:0:20:2:0.5:dx` | −0,01684 | Auslenkung nach 0,5 s, losgelassen bei 5 cm |
| `0.05:0:20:20:0.1:dx` | 0,02030 | Grenzfall δ = ω₀ |
| `0.05:0:20:30:0.1:dx` | 0,02722 | Kriechfall: kehrt langsamer zurück |

Angeregt mit F₀ = 1 N:

| Eingabe | Ergebnis | Bedeutung |
|---|---|---|
| `1:0.5:20:2:15:famp` | 0,01081 | Amplitude bei Ω = 15/s |
| `20:2:15:fphase` | 0,3303 | φ in rad, die Masse läuft der Kraft hinterher |
| `1:0.5:20:2:15:1:fx` | −0,005489 | Auslenkung bei t = 1 s |
| `1:0.5:20:2:20:famp` | 0,025 | in Resonanz: 5-mal die statische Auslenkung F₀/k = 0,005 |
| `20:2:wres` | 19,80 | Resonanzkreisfrequenz |
| `1:0.1:vgr` | 5 | V bei η = 1, gleich der Güte |

## Wie die Funktionen gebaut sind

Zwei Beispiele aus der Datei:

```
{~:~:~:~:R*+rw_cos*}':hx
```

`~:` holt die vier Argumente der Reihe nach: `[A ω φ t]`. `R` holt ω nach oben: `[A φ t ω]`. `*` und `+`
ergeben ωt + φ, `rw` rechnet ins eingestellte Winkelmaß um, `cos` und `*` liefern A·cos(ωt + φ).

```
{~|:R²Y²-~R*2*°wr}':fpol
```

`~|:` legt alle Argumente auf den Stack: `[ω₀ δ Ω]`. `R²` ergibt `[δ Ω ω₀²]`, `Y²-` dann `[δ Ω ω₀²−Ω²]`.
`~R` schiebt den Tos nach unten, `*2*` ergibt 2δΩ. Der Operator `°` (kartesisch nach polar) liefert mit
x = ω₀² − Ω² und y = 2δΩ in einem Schritt den Betrag, also den Nenner von `famp`, und den Winkel, also die
Phase.

In `dx` wird nicht mit Argumenten gerechnet, sondern mit `n:Y` (Kopie von Position n), weil die Blöcke von
`ifel` die Argumente des Aufrufs nicht sehen. Mit `6:~R5:D` bleibt am Ende nur das Ergebnis übrig.

Die Tests stehen in `test/oscillations_test.dart`. Sie prüfen jede Funktion gegen die Formel, in allen drei
Winkelmodi.
