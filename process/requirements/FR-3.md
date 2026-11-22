# FR-3 Anzeigeformat als Einstellung des Rechners: Format mit Stellen, Trenner, Bruch

Feature · Rechner · mittel · Reife 5 · Stand: In Arbeit

## Ziel
Zahlen erscheinen in App und Konsole im gewählten Format (Std, Fix, Sci, Eng, SI), auf Wunsch mit Tausendertrenner
und als Bruch. Die Einstellung gehört zum Rechner, die Formatierung auch, damit alle Oberflächen gleich aussehen.

## Heute
- `zahl()` in lib/src/helper.dart schreibt jede Zahl gleich (wie `str()`, ganze Zahlen ohne „.0“). App und
  Konsole rufen es direkt auf.
- Entschieden (2026-11-03): im Skript gespeichert, im Zustand gemeldet.

## Verhalten
- **Nur Anzeige:** Das Format ändert keinen Wert. Gerechnet wird weiter mit voller Genauigkeit, Eingabe und
  Zwischenablage (Excel, doc/api.md 7) bleiben unverändert.
- **Für jeden angezeigten Wert:** Stack, Variablen, Tags, Ergebnisse im Verlauf, Tooltips. Nicht für die Zeile,
  in der man gerade tippt: Sie zeigt, was eingegeben wird.
- **Gerundete Werte:** Zeigt die Anzeige einen Wert gerundet, steht blass „…“ dahinter; der volle Wert steht im
  Tooltip bzw. erscheint beim langen Druck. Das gilt für alle Werte, auch für eingegebene mit mehr Stellen, als
  das Format zeigt (keine Sonderbehandlung der Eingabe). Für einen Bruch, der nur nahe am Wert liegt, gilt
  dasselbe.
- **Format** mit Stellen n:
  - Std: wie heute.
  - Fix n: n Nachkommastellen.
  - Sci n: Mantisse mit n Nachkommastellen und Exponent.
  - Eng n: wie Sci, der Exponent ein Vielfaches von 3.
  - SI n: wie Eng, statt des Exponenten der SI-Vorsatz, z.B. 12.3 k. Vorsätze von a (10⁻¹⁸) bis E (10¹⁸): a f p n
    µ m k M G T P E; außerhalb wie Eng mit Exponent. Die neuen Vorsätze r, q, R, Q kommen nicht vor.
- **Stellen:** 0 bis 15 (mit double rund 15 sichere Stellen). Bei Fix werden nie mehr als 15 gültige Ziffern
  gezeigt; was darüber hinausginge, entfällt, und das blasse „…“ zeigt, dass gerundet ist (12345678.9 bei Fix 12:
  sieben Nachkommastellen und „…“). Mit mehr Genauigkeit (FR-11) wächst die Grenze.
- **Rundung:** kaufmännisch, 0,5 vom Nullpunkt weg (2.5 → 3, −2.5 → −3).
- **Exponent:** in allen Formaten, auch in Std, mit „ê“ wie in der Sprache und einem echten Minuszeichen:
  1.5ê20, 1.234ê−5 (heute zeigt Std die Schreibweise von Dart, 1.5e+20).
- **Trenner:** keiner, „,“, „'“ oder ein schmales Leerzeichen (U+202F, schmal und geschützt, damit die Zahl
  nicht umbricht), in Dreiergruppen vor dem Punkt. Der Dezimalpunkt
  bleibt „.“, wie in der Sprache.
- **Bruch:** aus (#.#), unecht (#/#) oder gemischt (# #/#).
  - **Grundregel:** Der Bruch ist genauer als der Wert, der sonst angezeigt würde: ist der exakt, muss es der
    Bruch auch sein; ist er gerundet, liegt der Bruch um eine Stelle genauer am Wert, höchstens ein Zehntel der
    halben Einheit der letzten angezeigten Stelle daneben. Gezeigt wird der Bruch mit dem kleinsten Nenner, der
    das schafft. Die Regel gilt für alle Formate und später für alle Werttypen (FR-11).
  - Bei Fix n heißt das |x − p/q| ≤ 0,05 · 10⁻ⁿ (123.4567 bei SI 3 bleibt 123.5…, nicht 123 1/2…).
  - **Bruch oder Dezimalzahl:** Maß sind die echten Stellen, Ziffern ohne führende und folgende Nullen (100 hat
    1, 100.1 hat 4, 0.05 hat 1). Verglichen wird nur der Nachkommateil, der ganze Teil ist in beiden
    Schreibweisen gleich. Der Bruch p/q für den Nachkommateil erscheint, wenn
    - q keine Zehnerpotenz ist (sonst wäre er nur die Dezimalzahl) und
    - echte(p) + echte(q) ≤ echte(Nachkommateil) + 1 (ein Bruch braucht immer zwei Zahlen).

    Sonst bleibt es bei der Dezimalzahl. Die Entscheidung gilt für gemischt und unecht gleich, nur die
    Schreibweise unterscheidet sich. Beispiele: 1.5 → 1 1/2 bzw. 3/2; 0.75 → 3/4; 0.125 → 1/8; 0.333… → 1/3;
    100.1 bleibt; 1234.56 bleibt (14/25 hat 4 echte Stellen, .56 nur 2). So bleibt auch bei Std, wo es zu
    jedem double einen genauen Bruch mit riesigem Nenner gibt, die Dezimalzahl, wenn der Bruch nicht aufgeht.
  - **Bei Sci, Eng und SI** werden Nachkommastellen in der Mantisse möglichst vermieden; die Regel der echten
    Stellen gilt für die Mantisse (die Zahl ohne Zehnerpotenz bzw. Vorsatz).
    - Sci: Werte ab 1 als ganze Zahl (mit Bruchteil) und Zehnerpotenz als Exponent, Werte unter 1 als
      p/(q·10ᵏ) mit der Zehnerpotenz im Nenner. Die Zehnerpotenz steht als „ê4“ da, nicht als hochgestellte 4
      (zu klein). Unter den möglichen Schreibweisen gilt die mit dem kleinsten Bruch.
    - Eng und SI: keine Zehnerpotenz im Nenner. Lässt sich die Potenz nicht als Vielfaches von 3 (bzw. als
      Vorsatz k, M, m, µ …) herausziehen, wird sie nicht verwendet.
    - Eng und SI: Ein Bruch erscheint nur ohne Exponent bzw. Vorsatz, also etwa zwischen 1 und 999 (1/3 → 1/3,
      aber 1500 → 1.5 k, nicht 1 1/2 k; 5666.67 → 5.66667 k). „5 2/3 k“ wäre mehrdeutig und ist ungewohnt.

    | Wert | Sci | Eng | SI |
    |---|---|---|---|
    | 1.234ê6 | 1234ê3 | 1234ê3 | 1234 k |
    | 1.23456ê3 | 1.23456ê3 (14/25 zu lang) | 1.23456ê3 | 1.23456 k |
    | 1234ê−5 = 0.01234 | 617/5ê4 (= 123 2/5 · 10⁻⁴) | 12.34ê−3 | 12.34 m |
- **Eine Funktion im Kern** formatiert für alle Oberflächen: `formatiere(wert)` nach den aktuellen Einstellungen
  liefert `(zahl, vorsatz, gerundet)`. Den SI-Vorsatz setzt die Oberfläche ab (siehe SI und Einheiten),
  `gerundet` ergibt das blasse „…“.
- **Einstellung:** vier Felder im Zustand, `format`, `stellen`, `trenner`, `bruch` (auch in JSON, doc/api.md
  3.1), mit Settern in `RpnApi` wie `winkel` (FA-32). FR-9 fasst sie später im Objekt der Einstellungen zusammen;
  FR-3 wartet nicht darauf.
- **Im Skript:** in der Zeile der Einstellungen als Befehle wie der Winkel, z.B. `rad_4:rpn.format.fix_rpn.sep.apos`;
  nur, was nicht auf Standard steht. So liest jeder Rechner die Zeile ohne neues Format.
- **Konsole:** Stack und Ergebnisse im selben Format; eingestellt wird vorerst nur mit den Befehlen
  (`4:rpn.format.fix`), ein Eintrag im Konsolenmenü kann später kommen.
- **Befehle in der Sprache:** je Modus ein Namensraum unter `rpn` (FR-12), der Wert ist Teil des Namens; Stellen
  kommen als Argument über `:`. So lassen sich die Modi auch im Code und im Skript umstellen.

  | Modus | Befehle |
  |---|---|
  | Format | `rpn.format.std`, `4:rpn.format.fix`, `4:rpn.format.sci`, `4:rpn.format.eng`, `4:rpn.format.si` |
  | Bruch | `rpn.frac.off`, `rpn.frac.improper`, `rpn.frac.mixed` |
  | Trenner | `rpn.sep.none`, `rpn.sep.comma`, `rpn.sep.apos`, `rpn.sep.space` |
  | Winkel (FA-32) | `rpn.angle.deg`, `rpn.angle.rad`, `rpn.angle.grd` |

  Kurze Namen kommen über das Freischalten (FR-13): `rpn.angle` ist von Anfang an freigeschaltet, daher bleiben
  `deg`, `rad`, `grd` wie heute. Bis FR-13 umgesetzt ist, bleiben sie eingebaute Funktionen.

## SI und Einheiten
- Mit den Einheiten (FS-1) hängt der SI-Vorsatz an der Einheit: 12.3 km statt 12.3 k m. SI geht dann in den
  Einheiten auf oder wird ihre Anzeige.
- Ohne Einheit ist ein allein stehender Vorsatz mehrdeutig: „1.5 m“ wären 1,5 Milli oder 1,5 Meter. Deshalb
  liefert der Kern den Vorsatz getrennt, und die Anzeige setzt ihn ab (z.B. kleiner, andere Farbe), bis es
  Einheiten gibt.

## Später
- **Konstanten herausziehen** als eigener Modus: 0.477464829275686 erscheint als 3/2π statt als Näherungsbruch,
  ebenso mit √2, e usw. Kostet viel Rechenzeit (für jede Konstante eine Suche nach dem Bruch).
- **Trenner nach dem Punkt** (0.000 012): ein eigener Modus, vorerst nicht.

## Entscheidungen
- 2026-11-03: im Skript gespeichert, im Zustand gemeldet (Jörg).
- 2026-11-16: Format, Trenner und Bruch sind nur Anzeige, die Formatierung gehört aber in den Kern: App und
  Konsole formatieren gleich (Jörg). Das ersetzt „die Oberflächen formatieren danach“.
- 2026-11-16: Trenner werden wie das Format behandelt, auch in der Konsole (Jörg).
- 2026-11-16: Bruch nur, wenn er aufgeht; bei Fix immer ein Bruch, der mindestens so genau ist wie der Fixwert
  (Jörg).
- 2026-11-16: SI im Hinblick auf die Einheiten (FS-1) mit planen (Jörg).
- 2026-11-16: Das Format gilt nur für die Anzeige, dort für jeden Wert (Jörg).
- 2026-11-16: Grundregel für den Bruch: mindestens so genau wie der sonst angezeigte Wert, für alle Formate und
  Werttypen. Ersetzt „nur wenn er aufgeht, bei Fix immer“ (Jörg).
- 2026-11-16: Bei Sci, Eng und SI wird die Mantisse als Bruch ganzzahlig, Nachkommastellen werden vermieden
  (Jörg).
- 2026-11-16: Regel für Sci, Eng und SI wie unter Verhalten; Zehnerpotenz als e4/ê4; möglichst kleiner Bruch,
  auch wenn dafür der SI-Vorsatz wegfällt (Jörg).
- 2026-11-16: Ob Bruch oder Dezimalzahl, entscheiden die echten Stellen des Nachkommateils, mit Nenner ohne
  Zehnerpotenz und einer Stelle Spielraum für den Bruch (Regel unter Verhalten). Verworfen: alle echten Stellen
  der ganzen Zahl zählen, weil dann die Nullen des ganzen Teils den gemischten Bruch bevorzugen und 1.5 dezimal
  bliebe (Jörg, Vorschlag Claude).
- 2026-11-16: Die Regel der echten Stellen gilt bei Sci, Eng und SI für die Mantisse. Bei Eng und SI keine
  Zehnerpotenz im Nenner: lässt sie sich nicht als Vielfaches von 3 bzw. Vorsatz herausziehen, wird sie nicht
  verwendet (Jörg).
- 2026-11-16: Bei Eng und SI kein Bruch zusammen mit Exponent oder Vorsatz (Jörg, Vorschlag Claude).
- 2026-11-16: Gerundete Werte bekommen blass „…“, der volle Wert im Tooltip bzw. beim langen Druck; keine
  Sonderbehandlung eingegebener Werte (Jörg).
- 2026-11-16: Konstanten wie π herausziehen und Trenner nach dem Punkt sind eigene Modi, vorerst nicht (Jörg).
- 2026-11-16: Befehle als `rpn.<modus>.<wert>` (z.B. `rpn.angle.deg`, `4:rpn.format.fix`), englische Namen.
  Verworfen: ein Befehl für alle Modi (`rpn.mod`) und Werte als Zahl-Argument (`1:rpn.angle`), weil unlesbar;
  `rpn.mode.angle.deg`, weil das Wort `mode` nichts unterscheidet (Jörg, Claude).
- 2026-11-21: Reihenfolge geändert: FA-32 zuerst mit ausgegrauten Feldern Format, Trenner, Bruch; FR-3 schaltet
  sie frei, samt der Grundregel „Zahlen im Menü“ für die Stellen (Jörg).
- 2026-11-21: Für Reife 5 (Vorschläge Claude, Jörg: alle ok): FR-3 ohne FR-9, Felder und Setter direkt;
  Exponent „ê“ mit Minuszeichen in allen Formaten; Stellen 0–15, bei Fix höchstens 15 gültige Ziffern;
  kaufmännisch runden; SI-Vorsätze a bis E; `formatiere` liefert Zahl, Vorsatz und gerundet; im Skript als
  Befehle in der Zeile der Einstellungen; Konsole vorerst nur Befehle; schmales Leerzeichen U+202F.
- 2026-11-21, bei der Umsetzung (Claude): „Mindestens so genau“ heißt: ist die Dezimalzahl exakt, muss es der
  Bruch auch sein (sonst würde 100.1 zu 100 1/7); nur eine gerundete Dezimalzahl erlaubt eine Abweichung um eine
  halbe Einheit der letzten Stelle (Fix 2: 2/3). Auch Std zeigt „…“ für gerundete Werte (0.333333333333…), nicht
  für das Rauschen von double (0.1+0.2 zeigt 0.3). Eng n hat n + 1 gültige Ziffern wie Sci n.
- 2026-11-21, Test in der App (Jörg): 123.4567 bei SI 3 zeigte 123 1/2…, das täuscht einen halben vor. Ein Bruch
  zu einer gerundeten Dezimalzahl muss jetzt um eine Stelle genauer sein (ein Zehntel der halben Einheit). Das
  „…“ steht vor dem SI-Vorsatz (123.5… k); das schmale Leerzeichen des Trenners zeigt die App wirklich schmal.
- 2026-11-21, Test in der App (Jörg): Der Exponent muss immer sichtbar sein. Ist ein Wert zu lang für die
  Zeile, bleibt der Exponent rechts stehen und die Mantisse wird gekürzt. Dabei fiel auf: 1ê23 kam als
  1.0000000000000001e23 auf den Stack (pow(10, 23) ist ungenau); der Lexer nimmt jetzt double.parse.
  Auch Sci und Eng zeigen höchstens 15 gültige Ziffern (Fix 15 zeigte 1ê23 als 9.99999999999999999ê22).
  Das „…“ für gerundet steht vor dem Exponenten (1.235…ê6), wie vor dem SI-Vorsatz; bei gekürzter Mantisse
  bleibt so ein einziges „…“ (1.0000000000…ê23).

## Offen

## Bezüge
FA-32 (Menübereich Modi), FR-9 (Einstellungen), FR-12 (Punkt in Namen, für die Befehle), FS-1 (Einheiten), FR-11 (Werttypen; Bruch mit Klasse Q später
exakt), doc/api.md 3.1 (Zustand), 4 (Skriptformat), 7 (Zwischenablage).

## Umsetzung und Tests
- 2026-11-21, Kern: lib/src/number_format.dart (`formatiere`, `Anzeigeformat`), Befehle in
  engine/functions.dart, Zustand `anzeige`, `RpnApi.anzeigeformat` und `formatiere`, Skriptzeile, Konsole;
  Tests test/number_format_test.dart.
- 2026-11-21, App: Stack, Variablen und Tos in der Statuszeile im Anzeigeformat (`wertText`, „…“ und
  SI-Vorsatz blass); Menü Modi: Format, Trenner und Bruch aktiv, Stellen über den Ziffernblock (ê 12, „.“ 15),
  Beispielzahl in der Zeile, Stellenzahl groß im Feld; Statuszeile zeigt FIX 4, 1'000, # #/#. Tests:
  app/test/menu_modes_test.dart.
