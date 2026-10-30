# Allgemein
1.1 Die App stellt einen komplexen RPN-Calculator zur Verfügung.
1.2 Es wird eine eigenen Syntax benutzt, die durch eine konfigurierbare Grammatik definiert wird.
1.3 Der Rechner soll kontinuierlich erweitert werden.
1.4 Die Architektur soll Erweiterbarkeit unterstützen.
# Anforderungen
## Bedienkonzept
Der Rechner kann über verschiedene Interfaces angesteuert werden:
### Console
#### Zeileneingabe
#### Anzeige
#### Zeichenweise Eingabe
### CLI
### GUI
### File
### REST API
### Sockets UI
### Export / Import
#### Anwendungsfälle
##### Bibliotheken
##### Batch-Verarbeitung
##### Programmierung
##### Logging
#### Formate
##### json
##### Excel
##### txt
## Berechnungssystem
### Stack
### Berechnungen
### Variablen und Co
### Programmierung 
## Architektur
### Konzept
### Grammatik
### DEA
### Parser
### Calculator
# interne APIs
# zukünftige Anforderungen
In diesem Abschnitt werden alle die Anforderungen gesammelt, die für spätere Erweiterungen angeplant sind.
Viele dieser Anforderungen basieren auf zwei grundlegende Konzept: Einheiten und Multidimensionale Objekte.
## Einheiten
### Konzept
### Domänen und Basiseinheiten
Es gibt unterschiedliche Domänen mit verschieden vielen Basiseinheiten
* Mathematik: 2 Basiseinheiten [Winkel, Imaginär]
* Physik: 8 Basiseinheiten [m, kg, s, A, K, Mol, Candela, K!] K! für absolute Temperaturen
* Finanz: 1 Basiseinheit [$] es gibt aber beliebieg viele unterschiedliche Währungseinheiten
* Chronos: 3 Basiseinheiten [C!, C, C] CI= Chronos Instant 
### Konvertierungen
#### Optimierung
Mit [?] und [?domain] kann man den Rechner auffordern eine möglichst gute Einheit zu finden.
Die Domain gibt dabei an, was für eine Art von Einheit man haben möchte. 
Die Einheiten werden dann ausgewertet und Größenordnungen berücksichtigt.
Unter Verwendung der verfügbaren Sondersymbolen wird dann die passende Einheit ausgewählt und 
dann     

##### Domänen
Es gibt verschiedene Domänen
💼 [?el] – Elektrotechnik / Energiewirtschaft
• Energie: Optimiert auf Wh, kWh, MWh statt Joule.
• Leistung: Nutzt W, kW oder bei Scheinleistung VA (Voltampere) / var (Var).
⚛️ [?ph] – Atom- & Quantenphysik
• Energie: Schlägt sofort Brücken zu eV, keV, MeV, GeV.
• Länge: Bevorzugt Å (Ångström), nm (Nanometer) oder fm (Femtometer/Fermi).
• Masse: Nutzen von atomaren Masseneinheiten (u).
🍏 [?bio] oder [?nut] – Biologie / Ernährungswissenschaft
• Energie: Optimiert standardmäßig auf kcal (Kilokalorien) oder kJ (Kilojoule).
• Masse: Nutzt typische Lebensmittel-Skalierungen (g, kg).
⚙️ [?ing] – Maschinenbau / Ingenieurwesen
• Frequenz/Drehzahl: Konvertiert 1/s automatisch in rpm oder U/min.
• Druck: Bevorzugt bar oder MPa (Megapascal) statt der reinen SI-Einheit Pascal.
• Fläche: Nutzt mm² oder cm² statt m², da Bauteile meist klein sind.
🗺️ [?geo] – Geographie / Vermessung
• Fläche: Optimiert bei großen Werten auf ha (Hektar) oder km² statt m².
• Geschwindigkeit: Wechselt von m/s zu km/h.
### Mathematik
In der Mathematik sind zwei 
#### Winkel
#### Imaginär
#### Complex
Operationen:
* Erstellen als 
- (3 4[i]) Die Einheit macht aus dem Vektor eine Komplexe Zahl
- 3 4i*+ Man kommt auch ohne Einheit aber mit der Einheit behafteten Konstante i zurecht
- []  Nimmt den Real-Teil oder den Betrag (r Anteil) je nach aktueller Darstellung
- [~i] Auch der Real-Teil aber evtl. mit vorheriger Konvertierung 
- [i] Nimmt den Imaginär-Teil evtl. vorher konvertieren
- [<] Nimmt den Phi, evtl. konvertieren. Wenn nicht, bleibt die Winkeleinheit erhalten
- [+] Wandelt in kartesisch um
- [~+] Wandelt in polar um
- [~] Toggelt zwischen den beiden Formen 
### Physik
### Finanz
### Chronos
## Multidimensionale Objekte
### Struktur
#### Komplexe Zahlen
#### Vektoren
#### Matritzen
#### Tabellen
### Eingabe
### Anwendungsszenarien
#### Wahrscheinlichkeitsrechnung und Kombinatorik
* n! mit Stirling-Formel: n! ≈ √2πn(n/e)²
* Gamma-Funktion
* n über k: n! / (k! * (n-k)!)
* Verteilungen: Binomial, Poisson, Normal, Exponential, Uniform
#### Statistik
Berechnung von:
* Basisdaten: ∑(x), ∑(y), #(x), #(y), ∑(x²), ∑(y²), ∑(xy) 
* Mittelwert
* Varianz
* Varianze auf n:  s² = [∑(x²) - ∑(x)²/n] / n
* Standardabweichung
* Median
* Quantile
* Kovarianz
* Korrelation
* Linear Regression
* Schätzwerte
#### Vektoren und Matritzen
## Domainen
### Konzept
### Physik-Domaine
### Finanz-Domaine
### Chronos-Domaine (Datums- und Zeitarithmetik)
#### Konzept
Einheiten bestimmen, dass ein Wert entsprechen der Chronos-Domaine berechnet werden.
Es gibt Einheiten für Zeitpunkte und Zeiträume. 
Zeiteinheiten aus der Physik-Domain können mit übernommen werden.
#### Einheiten
##### ChronosInstant
##### ChronosPeriod
#### Operationen
Legende: 
* I für ChronosInstant, 
* P für ChronosPeriod (bei Eingabe auch Physik-t erlaubt)
* S für Skalar: Wert ohne Einheit 
##### Addition / Subtraktion
1. I+P = I, I-P  Inklusive Kalenderlogik
2. P+P = I, P-P 
3. I+I = Fehler, I-I = Fehler
4. P+I = Fehler, P-I = Fehler 
##### Multiplikation / Division
5. P*S=P, P/S=P
6. 
#### Funktionen
### Konzept
## Weitere Objekttypen
### Strings
## Konstanten
### Physikalische Konstanten
* Lichtgeschwindigkeit: c = 299,792,458 m/s
* Gravitationskonstante: G = 6.67430 × 10⁻¹¹ m³ kg⁻¹ s⁻²
* Plancksches Wirkungsquantum: h = 6.62607015 × 10⁻³⁴ J·s
* Elementarladung: e = 1.602176634 × 10⁻
* Avogadro-Konstante: Nₐ = 6.02214076 × 10²³ mol⁻¹
* Boltzmann-Konstante: k = 1.380649 × 10⁻²³ J/K
* Gas-Konstante: R = 8.314462618 J/(mol·K)
* Faraday-Konstante: F = 96485.33212 C/mol
* Standard-Atmosphäre: 1 atm = 101325 Pa
* Standard-Temperatur und -Druck (STP, NTP, SATP, ..): 0,20,25 °C, 1 atm
### Mathematische Konstanten
* π = 3.14159265358979323846
* e = 2.71828182845904523536
* φ = 1.61803398874989484820
* γ = 0.57721566490153286060
* ζ(3) = 1.20205690315959428540
* Catalan's constant: G = 0.91596559417721901505
* Apéry's constant: ζ(3) = 1.20205690315959428540
* Euler-Mascheroni constant: γ = 0.57721566490153286060
* Khinchin's constant: K = 2.6854520010
* Landau-Ramanujan constant: L = 0.76422365358922066299
* Meissel-Mertens constant: M = 0.26149721284764278375
## Sonderzeichen
### Konzept
### Verwendung
#### Operatoren
#### Einheiten
#### Strings
#### Namen
Es sollte überlegt werden, ob Sonderzeichen in Namen erlaubt sind
- Vorteil: Sprechende Namen
- Nachteil: Aufblähen des DEA, komplizierte Eingabe
Idee: Zeichen können 
### Unterstützte Zeichen
* Griechische klein: α β γ δ ε ζ η θ ι κ λ μ ν ξ ο π ρ σ τ υ φ χ ψ ω
* Griechisch groß: Γ Δ Θ Λ Ξ Π Σ Φ Ψ Ω
* Mathematische Operatoren: ∑ ∏ ∫ ∂ ∇ ∆ ∈ ∉ ⊂ ⊃ ⊆ ⊇ ∪ ∩ ⊕ ⊗ ≈
* Logische Operatoren: ∧ ∨ ¬ ⇒ ⇔
* Vergleichsoperatoren: = ≠ < > ≤ ≥ ≮  ≯  ≡ ≢  ≈ ≉  ≅ ∝ ≔ ≝ ≪ ≫
* Pfeile: → ← ↑ ↓ ↔ ↕
* Mengen: ℕ ℤ ℚ ℝ ℂ ∅ ℵ ℶ ℼ ℽ ∞ π ℯ ⅈ ⅉ
* Matritzen: · × ⊗ ⊙ ᵀ ⁻¹ ‖
* Einheiten Winkel: ° ∠ ᵍ
* Einheiten Physik: Å µ ℧ ℃ ℉ K ℎ ℏ ㎐ ㎑ ㎒ ㎓ ㎔ ㎩ ㎪ ㎫ ㎬ ㍴ ㎷ ㎸ ㎃ ㎄ ㏀ ㏁ ㎽ ㎾ ㎿ ㎈ ㎉ ㎧ ㎨
* Stochastik: μ σ σ² s² x̄ p̂ ! λ χ² Ω ∅ ¦ ρ 
* Währungen: $ € £ ¥ ₹ ₽ ₩ ₪ ¤ ¢ ₿
* Finanz: ‰ ‱ ％ Δ 
* Datum/Zeit: ⦂ Δt ☉ ♁ ☽ ♂ ♀ ☄
* Zahlen: ⅒ ⅑ ⅛ ⅐ ⅙ ⅕ ¼ ⅓ ⅜ ⅖ ½ ⅗ ⅝ ⅔ ¾ ⅘ ⅚ ⅞ ⅟ ₓ ᵧ
* Tief gestellt: ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉ ₊ ₋ ₌ ₍ ₎ ₐ ₑ ₕ ᵢ ₖ ₗ ₘ ₙ ₒ ₚ ᵣ ₛ ₜ ᵤ ᵥ ₓ ᵧ
* Hoch gestellt: ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ⁺ ⁻ ⁼ ⁽ ⁾ ᵃ ᵇ ᶜ ᵈ ᵉ ᶠ ᵍ ʰ ⁱ ʲ ᵏ ˡ ᵐ ⁿ ᵒ ᵖ ʳ ˢ ᵗ ᵘ ᵛ ʷ ˣ ʸ ᶻ ᴬ ᴮ ᴰ ᴱ ᴳ ᴴ ᴵ ᴶ ᴷ ᴸ ᴹ ᴺ ᴼ ᴾ ᴿ ᵀ ᵁ ⱽ ᵂ
* Ableitungen: ′ ″ ‴ ⁗   ̇   ̈   ẋ ẍ  ̇y ̈y  ̇z ̈z  ̇s ̈s  ̇v ̈v 
* Modifizierer: ̂  ̄   ̃  ̇  ̈            ̃a 
* Klammern; ❨ ❩ ❪ ❫ ❬ ❭ ❮ ❯ ❰ ❱ ❴ ❵ ⟦ ⟧ ⟨ ⟩
## Grammatik
Alle Sonderzeichen werden durch \name eingegeben.
~\zeichen gibt den Namen des Zeichens zurück.
Wenn ein Zeichen mehrere Synonyme hat kann man mit ~\(zeichen) alle Synonyme 
Nach dem \ wird so lange gesucht, bis ein Leerzeichen kommt.
~\(\name) gibt alle Synonyme des Namens wieder  
## Programmierung
## Datei-Zugriff
## CLI und Flutter



Scratch-Pad

Anforderungsdokument (Requirements) – Modul: Parser & Datenstrukturen


1. Fundamentale Datentypen

• 1.1 Basistyp Tabelle: Der universelle Datentyp des Rechenwerks ist die Tabelle. Alle komplexen mathematischen Strukturen werden als Spezialfälle der Tabelle abgeleitet.
• 1.2 Matrix: Eine Matrix ist eine Tabelle, bei der alle Spalten dieselbe physikalische Einheit besitzen.
• 1.3 Vektor: Ein Vektor ist eine Matrix, die entweder exakt eine Zeile (\(1 \times n\)) oder exakt eine Spalte (\(n \times 1\)) besitzt.
• 1.4 Einheiten-Vektor: Ein Einheiten-Vektor ist eine Tabelle mit \(n\) Spalten und 0 Zeilen. Er dient ausschließlich als Metadaten-Träger zur Repräsentation von Einheiten-Vorschlägen.
• 1.5 Tensoren (Höhere Ordnungen): Verschachtelte Tabellenstrukturen, bei denen der Rang (die Dimensionstiefe) dynamisch durch die Eingabesyntax bestimmt wird.

2. RPN-Stack & Einheiten-Verrechnung

• 2.1 Einheiten-Vektor auf ToS: Ein Einheiten-Vektor (0 Zeilen, \(n\) Spalten) auf dem Top-of-Stack (ToS) blockiert mathematische Standardoperationen.
• 2.2 Reduktion via Index: Über den tiefgestellten Index-Operator \vn (z. B. \v1, \v2) wird genau ein Element aus dem ToS-Einheiten-Vektor ausgewählt. Das ToS-Element wird durch diese selektierte einzelne Einheit ersetzt.
• 2.3 Verschmelzung (ToS & Y): Befindet sich auf ToS eine einzelne Einheit und auf dem Element darunter (Y) ein reiner Zahlenwert, werden beide zu einem Einheitenwert verschmolzen.
• 2.4 Globale Rechenmodi:
	• Modus [!] (Zahlenwert-Treue): Der intern gespeicherte Rechenwert entspricht exakt der Anzeige auf dem Display. Bei Einheitenwechseln transformiert sich der numerische Wert.
	• Modus [~] (SI-Physik-Treue): Der Rechner operiert intern ausschließlich mit SI-Basiseinheiten. Gewählte Einheiten dienen als Maske für den View-Layer. Das Abstreifen einer Einheit legt den rohen SI-Wert frei.

3. Parser-Syntax für Tabellen & Tensoren

• 3.1 Tokenizer-Regel: Der Parser liest den Eingabestring als ununterbrochene Kette ein. Das Trennzeichen für Werte innerhalb einer Dimension ist das Leerzeichen. Der Trigger für die Evaluierung eines Kürzels ist das nächste Leerzeichen.
• 3.2 Dimensionierung & Richtungswechsel (|):
	• Die Zeichen ( und ) umschließen die Tabelle/Struktur.
	• Der senkrechte Strich | fungiert als Richtungswechsel- und Schachtelungs-Indikator (Togglestream).
• 3.3 Implizite Dimensionseinrastung (Zeilenweise):
	• Folgt nach einer Sequenz von Werten ein |, steht die feste Breite der ersten Dimension (Spaltenanzahl) unumstößlich fest.
	• Alle nachfolgenden Werte werden vom Parser automatisch ohne weitere Trennzeichen in Blöcke dieser Breite umgebrochen.
	• Syntax-Beispiel: (1 2 3 4|5 6 7 8 9 10 11 12) \(\rightarrow \) Tabelle mit 3 Zeilen, 4 Spalten.
• 3.4 Vertikale Befüllung (Spaltenweise):
	• Ein | direkt nach der öffnenden Klammer ( kippt den Einlesemodus auf vertikal.
	• Der zweite | definiert das Ende der ersten Spalte und rastet die feste Höhe (Zeilenanzahl) ein.
	• Syntax-Beispiel: (|1 2 3 4|5 6 7 8 9 10 11 12) \(\rightarrow \) Tabelle mit 4 Zeilen, 3 Spalten.
• 3.5 Tensor-Schachtelung: Mehrfache |-Striche innerhalb logischer Sequenzen erhöhen den Rang der Dimension (Tiefe). Einheiten und Werte, die als Paar getippt werden (s11 v11), werden vom Parser als eine atomare Zelle behandelt.
