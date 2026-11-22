# FS-5 Symbolschreibweise: `\name ` bis einschließlich Leerzeichen wird vor dem DEA durch ein Zeichen ersetzt

Feature · Sprache · groß · Reife 2 · Stand: Angedacht

Zusammengeführt aus dem Backlog, scratchpad/requirements.md „Sonderzeichen“ und doc/reference.md 14.2.

## Ziel
Zeichen, die nicht auf jeder Tastatur zu finden sind (ⅈ ∠ Σ ∞ ≤ ê …), lassen sich wie bei LaTeX umschreiben:
`\sum ` wird Σ. Das gilt in Konsole, Skripten und über den Socket, nicht nur in der App. Damit lassen sich viele
weitere Operatoren und Namen mit Sonderzeichen einführen (FR-14 komplexe Zahlen, FS-1 Einheiten, FS-4 Namen).

## Heute
- `\` ist in der Sprache frei (doc/reference.md 14.2).
- Die Konsole benutzt `\` für ihre Befehle: `\q` (zurück zum Menü), `\c` (Tos kopieren), `\s` (Stack kopieren),
  `\v` (Zahlen einfügen) und `\?` (Hilfe) (doc/api.md, Konsole). Im Rohmodus wirken sie sofort beim Buchstaben
  (lib/src/console/screen.dart); jede andere Folge gibt `\` und das Zeichen an den Rechner weiter.
- Zeichen gibt es heute nur über die Tasten der App oder durch Einfügen. Parser und App zerlegen Text mit
  `split("")` in UTF-16-Einheiten.

## Verhalten (Vorschlag)

### Ersetzungsstufe
- Eine eigene kleine Stufe im Rechner vor dem Haupt-DEA ersetzt `\name␣` (bis einschließlich Leerzeichen) durch
  ein Zeichen. Weil sie im Rechner sitzt, gilt sie auch in Skripten, über den Socket und in der Konsole.
- Eine Tabelle als Daten (z.B. library/system/zeichen.rpnlib) legt je Zeichen fest, ob es ein Name oder ein
  Operator wird. Zeichen ohne Bedeutung melden einen Fehler.

### Schreibweisen
- **Synonyme:** mehrere Namen für ein Zeichen (`\oo`, `\inf`, `\infinity` → ∞; `\<`, `\rad` → ∠).
- **Indizes:** `\.1` → ₁.
- **Hochstellung:** `\^2` → ².
- **Nachgestellte Akzente:** `x\. ` → ẋ, `a\.. ` → ä.
- **Umkehrung:** `~\` macht aus einem Zeichen wieder den Namen.
- **Auch hierher:** `~>` → `≤` (heute schreibt die App das Zeichen selbst).

### Zeichenvorrat (Sammlung)
- Griechisch klein: α β γ δ ε ζ η θ ι κ λ μ ν ξ ο π ρ σ τ υ φ χ ψ ω
- Griechisch groß: Γ Δ Θ Λ Ξ Π Σ Φ Ψ Ω
- Mathematische Operatoren: ∑ ∏ ∫ ∂ ∇ ∆ ∈ ∉ ⊂ ⊃ ⊆ ⊇ ∪ ∩ ⊕ ⊗ ≈
- Logische Operatoren: ∧ ∨ ¬ ⇒ ⇔
- Vergleiche: = ≠ < > ≤ ≥ ≮ ≯ ≡ ≢ ≈ ≉ ≅ ∝ ≔ ≝ ≪ ≫
- Pfeile: → ← ↑ ↓ ↔ ↕
- Mengen und Konstanten: ℕ ℤ ℚ ℝ ℂ ∅ ℵ ℶ ℼ ℽ ∞ π ℯ ⅈ ⅉ
- Komplexe Zahlen (FR-14): ⅈ ∠ ℜ ℑ ρ φ
- Matrizen: · × ⊗ ⊙ ᵀ ⁻¹ ‖
- Winkel: ° ∠ ᵍ
- Physik: Å µ ℧ ℃ ℉ K ℎ ℏ ㎐ ㎑ ㎒ ㎓ ㎔ ㎩ ㎪ ㎫ ㎬ ㍴ ㎷ ㎸ ㎃ ㎄ ㏀ ㏁ ㎽ ㎾ ㎿ ㎈ ㎉ ㎧ ㎨
- Stochastik: μ σ σ² s² x̄ p̂ ! λ χ² Ω ∅ ¦ ρ
- Währungen: $ € £ ¥ ₹ ₽ ₩ ₪ ¤ ¢ ₿
- Finanzen: ‰ ‱ ％ Δ
- Datum und Zeit: ⦂ Δt ☉ ♁ ☽ ♂ ♀ ☄
- Brüche: ⅒ ⅑ ⅛ ⅐ ⅙ ⅕ ¼ ⅓ ⅜ ⅖ ½ ⅗ ⅝ ⅔ ¾ ⅘ ⅚ ⅞ ⅟
- Tiefgestellt: ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉ ₊ ₋ ₌ ₍ ₎ ₐ ₑ ₕ ᵢ ₖ ₗ ₘ ₙ ₒ ₚ ᵣ ₛ ₜ ᵤ ᵥ ₓ ᵧ
- Hochgestellt: ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ⁺ ⁻ ⁼ ⁽ ⁾ ᵃ ᵇ ᶜ ᵈ ᵉ ᶠ ᵍ ʰ ⁱ ʲ ᵏ ˡ ᵐ ⁿ ᵒ ᵖ ʳ ˢ ᵗ ᵘ ᵛ ʷ ˣ ʸ ᶻ ᴬ ᴮ ᴰ ᴱ ᴳ ᴴ ᴵ ᴶ ᴷ
  ᴸ ᴹ ᴺ ᴼ ᴾ ᴿ ᵀ ᵁ ⱽ ᵂ
- Ableitungen: ′ ″ ‴ ⁗ ẋ ẍ (und Punkte über y, z, s, v)
- Akzente (kombinierend): ̂ ̄ ̃ ̇ ̈
- Klammern: ❨ ❩ ❪ ❫ ❬ ❭ ❮ ❯ ❰ ❱ ❴ ❵ ⟦ ⟧ ⟨ ⟩
- Operatoren: ÷ ×

### Namen mit Sonderzeichen
- Aus der Sammlung: Sollen Sonderzeichen in Namen erlaubt sein? Vorteil: sprechende Namen; Nachteil: größerer
  DEA, schwierigere Eingabe. FS-4 schlägt vor: alle Buchstaben außer A–Z gelten wie Kleinbuchstaben (ä, ß, ẋ, ω),
  Operatorzeichen bleiben Operatoren.

## Entscheidungen
- 2026-11-03: Der Rechner versteht die Schreibweise selbst (eigene Stufe vor dem DEA), nicht die Oberfläche; so
  gilt sie auch in Skripten und über den Socket (Jörg). Beantwortet die Frage aus doc/reference.md 14.2.
- 2026-11-03: `\` + ein Kleinbuchstabe und `\?` bleiben den Befehlen der Oberflächen (`\q \c \s \v`) (Jörg).

## Offen
1. **Befehle der Konsole und Symbole:** Im Rohmodus wirken `\q`, `\c`, `\s`, `\v` sofort beim Buchstaben, in der
   App dazu `\m` (Menü, FA-32). Dann lässt sich kein Symbol tippen, das mit q, c, s, v oder m beginnt, also auch
   `\sum`, `\sigma`, `\sqrt`, `\cdot`, `\chi`, `\vec`, `\mu`, `\mid`. Die Entscheidung vom 2026-11-03 reicht dafür nicht, sie schützt nur einbuchstabige Namen.
   Vorschlag (Claude): Auch die Befehle der Konsole enden mit Leerzeichen oder Enter (`\q␣`, `\c␣`). Dann gilt
   eine Regel für alles: `\name␣`; ist `name` ein Befehl der Oberfläche, führt sie ihn aus, sonst ersetzt der
   Rechner. Einbuchstabige Symbole wie `\i␣` → ⅈ werden möglich. Kosten: ein Tastendruck mehr für `\q` usw.;
   `2.25\c` am Zeilenende in der zeilenweisen Eingabe geht weiter, weil dort Enter folgt.
2. **Kollisionen** Zeichengruppe für Zeichengruppe durchgehen (z.B. µ Mikro und μ my, Ω Ohm und Ω Omega, K Kelvin
   und K, ∆ und Δ, ∑ und Σ).
3. **Nur Zeichen der Grundebene:** Zeichen außerhalb (z.B. 𝑖, 𝜑) bestehen aus zwei UTF-16-Einheiten und würden
   von `split("")` zerrissen. Entweder ausschließen oder die Zerlegung auf Unicode-Zeichen (runes) umstellen.
4. **Kombinierende Akzente** (̂ ̄ ̇ ̈): Vor dem Zerlegen auf fertige Zeichen umstellen (NFC, wie FS-4), wo es sie
   gibt (ẋ, ä); für die übrigen (z.B. ẏ gibt es, ṡ gibt es, aber nicht jede Kombination) eine Regel finden.
5. **Namen in der Tabelle:** möglichst wie LaTeX (`\alpha`, `\sum`, `\infty`), dazu kurze Synonyme.
6. **Sonderzeichen in Namen:** zusammen mit FS-4 entscheiden.

## Bezüge
FS-4 (Buchstaben in Namen), FR-14 (komplexe Zahlen: ⅈ ∠ ℜ ℑ ρ φ), FS-1 (Einheiten), FA-9 (Shift+ALPHA mit Vorschau,
baut auf FS-5), FA-17 (Hilfe zu einem Namen in der App), doc/reference.md 14.2, doc/api.md (Befehle der Konsole),
lib/src/console/screen.dart.

## Umsetzung und Tests
