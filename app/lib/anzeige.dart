import 'package:flutter/material.dart';
import 'package:rpncalc/helper.dart' show zahl;
import 'package:rpncalc/rpnapi.dart';

import 'farben.dart';
import 'hilfe.dart';
import 'modell.dart';
import 'tipp.dart';

/// Die Anzeige: Statuszeile und drei Seiten zum Wischen (Rechnen, Variablen und Tags, Funktionen),
/// siehe doc/app.md Kapitel 2.
class Anzeige extends StatefulWidget {
  final RechnerModell modell;
  const Anzeige(this.modell, {super.key});

  @override
  State<Anzeige> createState() => _AnzeigeState();
}

class _AnzeigeState extends State<Anzeige> {
  final _seiten = PageController();
  int _seite = 0;
  Bereich? _bereich;

  static const _namen = ["Rechnen", "Variablen und Tags", "Funktionen"];
  static const _seitenTipp = "Seiten: Rechnen, Variablen und Tags, Funktionen\nWechsel durch Wischen oder mit TAB";

  /// Tab wischt zur passenden Seite.
  static int _seiteFuer(Bereich b) => switch (b) {
    Bereich.eingabe || Bereich.stack => 0,
    Bereich.variablen => 1,
    Bereich.funktionen => 2,
  };

  @override
  void dispose() {
    _seiten.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.modell;
    if (_bereich != m.bereich) {
      _bereich = m.bereich;
      final ziel = _seiteFuer(m.bereich);
      if (ziel != _seite && _seiten.hasClients) {
        _seiten.animateToPage(ziel, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    }
    return Container(
      decoration: BoxDecoration(color: Farben.anzeige, borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _Statuszeile(m),
          Expanded(
            child: Stack(
              children: [
                PageView(
                  controller: _seiten,
                  onPageChanged: (i) => setState(() => _seite = i),
                  children: [_Rechnen(m), _Liste.variablen(m), _Liste.funktionen(m)],
                ),
                if (m.hilfeSeite != null) Positioned.fill(child: _Hilfeschirm(m, m.hilfeSeite!)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: Row(
              children: [
                tipp(_seitenTipp, Text(_namen[_seite], style: Schrift.monospace(10, Farben.anzeigeBlass))),
                const Spacer(),
                tipp(
                  _seitenTipp,
                  Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _seite ? Farben.anzeigeText : const Color(0xFF2C3D35),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Statuszeile extends StatelessWidget {
  final RechnerModell m;
  const _Statuszeile(this.m);

  @override
  Widget build(BuildContext context) {
    Widget marke(String text, Color farbe, String erklaerung) => _tippStatus(
      erklaerung,
      Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(color: farbe, borderRadius: BorderRadius.circular(4)),
        child: Text(text, style: Schrift.monospace(11, Farben.anzeige, gewicht: FontWeight.w700)),
      ),
    );
    final winkel = switch (m.zustand.winkel) {
      AngleMode.deg => ("DEG", "Winkelmodus = 360°"),
      AngleMode.rad => ("RAD", "Winkelmodus = 2π"),
      AngleMode.grad => ("GRD", "Winkelmodus = 400 gon"),
    };
    final klein = Schrift.monospace(11, Farben.anzeigeBlass, gewicht: FontWeight.w600);
    // im leeren Bereich der Statuszeile: die aktuellen Einstellungen (doc/app.md 7, Punkt 11)
    return _tippStatus(
      _einstellungen(winkel.$1),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
        child: Row(
          children: [
            GestureDetector(
              onTap: m.hilfeModus ? () => m.zeigeHilfe(AppHilfe.nachschlagen(m.api, "#winkel")) : null,
              child: _tippStatus(winkel.$2, Text(winkel.$1, style: klein.copyWith(color: Farben.anzeigeText))),
            ),
            if (m.hilfeModus) marke("HILFE", Farben.hilfe, "Hilfe-Modus: Taste oder Element antippen, ⌫ beendet"),
            if (m.shift)
              marke(
                m.alpha ? "ABC" : "SHIFT",
                Farben.shift,
                m.alpha ? "der nächste Buchstabe groß, danach endet Alpha" : "Umschalter: orange Befehle aktiv",
              ),
            if (m.tilde) marke("~", Farben.tilde, "Präfix ~"),
            if (m.strich) marke("|", Farben.strich, "Präfix |"),
            if (m.apostroph)
              marke("'", Farben.anzeigeText, "Präfix ' (Namen): die Funktionstasten zeigen die Variablen"),
            if (m.alpha) marke("abc", Farben.alpha, "Umschalter: Buchstaben (für Funktionen und Befehle)"),
            // Eingabe maximiert: der Stack ist nicht zu sehen, das Ergebnis steht klein hier (doc/app.md 3.5)
            if (m.maximiert && m.bereich == Bereich.eingabe && m.zustand.stack.isNotEmpty)
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: Farben.tosHinten, borderRadius: BorderRadius.circular(3)),
                  child: _tippStatus(
                    "Tos, der Stack ist ausgeblendet",
                    Text(
                      zahl(m.zustand.stack.first.wert),
                      style: Schrift.monospace(11, Farben.tosText, gewicht: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            const Spacer(),
            Flexible(
              child: _tippStatus(
                "Funktionen: ${[for (final t in m.funktionstasten)
                  if (t != null) t.text].join(", ")}",
                Text("F: ${m.seitenName}", style: klein, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _einstellungen(String winkel) => [
    "Winkelmodus: $winkel",
    "Zufall: ${m.zustand.seed == null ? "echte Zufallszahlen" : "Startwert ${m.zustand.seed}"}",
    "Stack: ${m.zustand.tiefe} Werte",
    "Funktionstasten: ${m.domaene}",
  ].join("\n");

}

/// Seite „Rechnen“: links die Eingabezeilen, rechts der Stack, oben die aktuelle Zeile neben dem Tos,
/// nach unten mit kleinerer Schrift. Lange Zeilen zeigen einen Ausschnitt, den ◄ und ► verschieben.
class _Rechnen extends StatelessWidget {
  final RechnerModell m;
  const _Rechnen(this.m);

  static const _groessen = <double>[24, 21, 19, 17, 15.5, 14, 13, 12, 11.5, 11, 10.5, 10, 10, 10];
  static const _zeichenBreite = 0.55; // Breite eines Zeichens der Monospace-Schrift relativ zur Größe
  static const _luecke = 14.0; // zwischen Eingabe und Stack
  static const _nummer = 30.0; // Breite der Stack-Positionen

  static int _zeichen(double breite, double g) => (breite / (g * _zeichenBreite)).floor().clamp(1, 999);

  @override
  Widget build(BuildContext context) {
    // beim Maximieren gleiten die Spalten auf ihre neue Breite (doc/app.md 3.5)
    return LayoutBuilder(
      builder: (context, platz) => TweenAnimationBuilder<double>(
        tween: Tween(end: m.anteilEingabe),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        builder: (context, anteil, _) => _inhalt(platz, anteil),
      ),
    );
  }

  /// Die Seite bei einem Anteil der Eingabe an der Breite von 0 (Stack maximiert) bis 1 (Eingabe maximiert).
  Widget _inhalt(BoxConstraints platz, double anteil) {
    final innen = platz.maxWidth - 24;
    final luecke = _luecke * (4 * anteil * (1 - anteil)).clamp(0.0, 1.0); // maximiert ohne Lücke
    final links = (innen - luecke) * anteil;
    final rechts = innen - luecke - links;
    final z = m.zustand;

    // zuerst feststellen, wie viele Zeilen passen, damit das Modell den Platz je Zeile kennt
    final fehler = z.fehler != null && !z.zeileFertig;
    final groessen = <double>[];
    double hoehe = fehler ? 14 : 0;
    for (final g in _groessen) {
      if (hoehe + g * 1.3 > platz.maxHeight - 12) break; // 8 oben für ENTER↑ auf dem Rahmen
      hoehe += g * 1.3;
      groessen.add(g);
    }
    final enter = z.enterVorgemerkt && !z.zeileFertig;
    // der Umbruch richtet sich immer nach der halben Breite, auch wenn eine Spalte maximiert ist
    m.zeichenProZeile = _zeichen((innen - _luecke) / 2, _groessen[0]);
    m.platzEingabe = [
      for (int r = 0; r < groessen.length; r++) _zeichen(links, groessen[r]) - (r == 0 ? 1 : 0), // der Cursor
    ];
    m.platzStack = [for (final g in groessen) _zeichen(rechts - _nummer - 10, g)];

    final zeilen = <Widget>[];
    for (int r = 0; r < groessen.length; r++) {
      final g = groessen[r];
      zeilen.add(
        SizedBox(
          height: g * 1.3,
          child: Row(
            children: [
              // ein Tipp wählt den Bereich, im Hilfe-Modus zeigt er die Hilfe zu Zeile bzw. Wert (doc/app.md 3.3, 5.3);
              // volle Zeilenhöhe, damit auch leere Zeilen den Tipp annehmen
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => m.hilfeModus ? m.zeigeHilfe(_hilfeEingabe(r)) : m.waehleBereich(Bereich.eingabe),
                child: SizedBox(
                  width: links,
                  height: g * 1.3,
                  child: r == 0 ? _aktuelleZeile(z, g) : _alteZeile(r, g),
                ),
              ),
              SizedBox(width: luecke),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => m.hilfeModus ? m.zeigeHilfe(_hilfeStack(r)) : m.waehleBereich(Bereich.stack),
                child: SizedBox(
                  width: rechts,
                  height: g * 1.3,
                  child: rechts < _nummer + 12 ? null : _stackZeile(r, g), // zu schmal: leer
                ),
              ),
            ],
          ),
        ),
      );
      if (r == 0 && fehler) {
        zeilen.add(
          SizedBox(
            height: 14,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "^ ${z.fehler!.text}",
                style: Schrift.monospace(10, Farben.fehler),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
    }

    // der gewählte Bereich (Eingabe oder Stack) bekommt einen Rahmen, Pfeile zeigen, wohin ◄ und ► schieben
    final rahmen = switch (m.bereich) {
      Bereich.eingabe => (links: 0.0, breite: links, name: "Eingabe", hilfe: "app:eingabe", aussenLinks: true),
      Bereich.stack => (links: links + luecke, breite: rechts, name: "Stack", hilfe: "app:stack", aussenLinks: false),
      _ => null,
    };
    Widget pfeil(IconData icon) => Container(
      color: Farben.anzeige,
      child: Icon(icon, size: 18, color: Farben.shift),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: zeilen),
          // ein vorgemerktes Enter steht rechts oben auf dem Rahmen der Eingabe, nicht in der Zeile
          if (enter)
            Positioned(
              right: innen - links + 2,
              top: -7,
              child: tipp(
                "Enter vorgemerkt: das nächste Token entscheidet, ob kopiert wird",
                Container(
                  color: Farben.anzeige,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text("ENTER↑", style: Schrift.monospace(10, Farben.anzeigeText, gewicht: FontWeight.w600)),
                ),
              ),
            ),
          if (rahmen != null) ...[
            Positioned(
              left: rahmen.links - 5,
              width: rahmen.breite + 10,
              top: 0,
              height: hoehe + 2,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Farben.shift.withValues(alpha: 0.7), width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            // der Name des Bereichs unten auf dem Rahmen, mit Tooltip (doc/app.md 7, Punkt 12)
            Positioned(
              left: rahmen.aussenLinks ? rahmen.links + 4 : null,
              right: rahmen.aussenLinks ? null : innen - rahmen.links - rahmen.breite + 4,
              top: hoehe + 2 - 7,
              child: tipp(
                [
                  for (final v in AppHilfe.eintraege[rahmen.hilfe]!.verwendungen) "${v.schreibweise}  ${v.kurz}",
                  "Wechsel mit TAB oder durch Antippen",
                ].join("\n"),
                Container(
                  color: Farben.anzeige,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(rahmen.name, style: Schrift.monospace(10, Farben.shift, gewicht: FontWeight.w600)),
                ),
              ),
            ),
            if (m.kannSchieben(false))
              Positioned(
                left: rahmen.links - 14,
                top: hoehe / 2 - 9,
                child: tipp("mit ◄ nach rechts schieben, zum Anfang", pfeil(Icons.arrow_left)),
              ),
            if (m.kannSchieben(true))
              Positioned(
                left: rahmen.links + rahmen.breite - 4,
                top: hoehe / 2 - 9,
                child: tipp("mit ► nach links schieben, zum Ende", pfeil(Icons.arrow_right)),
              ),
          ],
        ],
      ),
    );
  }

  /// Hilfe zu einer Zeile der Eingabe: eine alte Zeile ganz, sonst die Hilfe zur Anzeige „Eingabe“.
  List<Hilfe> _hilfeEingabe(int r) {
    final text = m.eingabeText(r);
    return r > 0 && text.isNotEmpty ? AppHilfe.zeile(text) : AppHilfe.nachschlagen(m.api, "app:eingabe");
  }

  /// Hilfe zu einer Zeile des Stacks: der Wert, das offene Token oder die Hilfe zur Anzeige „Stack“.
  List<Hilfe> _hilfeStack(int r) {
    if (r == 0 && m.offenesToken != null) return AppHilfe.nachschlagen(m.api, "app:stack");
    final s = m.stackZeile(r);
    return s == null ? AppHilfe.nachschlagen(m.api, "app:stack") : AppHilfe.stackWert(m.api, s);
  }

  /// Die aktuelle Zeile mit Fehlermarkierung und Cursor.
  Widget _aktuelleZeile(Zustand z, double g) {
    final text = m.eingabeText(0);
    final von = m.eingabeVon(0);
    final sicht = RechnerModell.ausschnitt(text, von, m.platzEingabe[0]);
    final stil = Schrift.monospace(g, Farben.anzeigeText);
    final f = z.zeileFertig ? null : z.fehler;
    final spans = <InlineSpan>[];
    if (f != null && f.start >= 0 && f.start <= text.length) {
      // Stellen im Ausschnitt: der Ausschnitt beginnt bei von und ist Zeichen für Zeichen gleich lang
      int stelle(int i) => (i - (text.length <= m.platzEingabe[0] ? 0 : von)).clamp(0, sicht.length);
      final a = stelle(f.start), e = stelle(f.start + f.token.length);
      spans.addAll([
        TextSpan(text: sicht.substring(0, a)),
        TextSpan(
          text: sicht.substring(a, e),
          style: const TextStyle(backgroundColor: Farben.fehler, color: Color(0xFF200000)),
        ),
        TextSpan(
          text: sicht.substring(e),
          style: const TextStyle(color: Farben.anzeigeBlass),
        ),
      ]);
    } else {
      spans.add(TextSpan(text: sicht));
    }
    spans.add(
      const TextSpan(
        text: "▌",
        style: TextStyle(color: Farben.shift),
      ),
    );
    return Text.rich(
      TextSpan(style: stil, children: spans),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
    );
  }

  Widget _alteZeile(int r, double g) {
    final text = m.eingabeText(r);
    return Text(
      RechnerModell.ausschnitt(text, m.eingabeVon(r), m.platzEingabe[r]),
      style: Schrift.monospace(g, Farben.anzeigeText),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
    );
  }

  /// Position links, der Wert rechtsbündig; kleinere Zeilen rücken so nach rechts. Der Tos ist hinterlegt.
  /// Ein offenes Token steht grau mit `>:` in der obersten Zeile, die Werte darunter (doc/app.md Kapitel 2).
  Widget _stackZeile(int r, double g) {
    final offen = r == 0 && m.offenesToken != null;
    final s = offen ? null : m.stackZeile(r);
    if (!offen && s == null) return const SizedBox();
    final tos = s?.position == 0;
    final sicht = RechnerModell.ausschnitt(m.stackText(r), m.stackVon(r), m.platzStack[r]);
    final wert = Text(
      sicht,
      style: Schrift.monospace(
        g,
        offen
            ? Farben.anzeigeBlass
            : tos
            ? Farben.tosText
            : Farben.anzeigeText,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
    );
    return Row(
      children: [
        SizedBox(
          width: _nummer,
          child: tipp(
            offen ? "aktuelle Eingabe, liegt noch nicht auf dem Stack" : "",
            Text(
              offen ? ">:" : "${s!.position}:",
              textAlign: TextAlign.right,
              style: Schrift.monospace(g * 0.7, Farben.anzeigeBlass),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: tos
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: Farben.tosHinten, borderRadius: BorderRadius.circular(3)),
                    child: wert,
                  )
                : Padding(padding: const EdgeInsets.only(right: 4), child: wert),
          ),
        ),
      ],
    );
  }
}

/// Seiten „Variablen und Tags“ und „Funktionen“: Name und Inhalt. Im Hilfe-Modus zeigt ein Tipp auf einen
/// Eintrag dessen Hilfe, ein Tipp daneben die Hilfe zur Seite (doc/app.md 5.3).
class _Liste extends StatelessWidget {
  final RechnerModell m;
  final String titel;
  final String hilfe; // Hilfe zur Seite
  final Bereich bereich; // Antippen wählt ihn
  final List<({String anzeige, String inhalt, String name})> eintraege;
  final String leer;
  const _Liste(this.m, this.titel, this.hilfe, this.bereich, this.eintraege, this.leer);

  factory _Liste.variablen(RechnerModell m) => _Liste(m, "Variablen und Tags", "app:variablen", Bereich.variablen, [
    for (Speicher s in m.zustand.speicher)
      if (s.art != SpeicherArt.funktion)
        (
          anzeige: "${s.art == SpeicherArt.tag ? "|" : ""}${s.name}",
          inhalt: s.werte.map(zahl).join(" "), // Vektoren ohne [ ], die sind für Einheiten reserviert
          name: s.name,
        ),
  ], "Noch keine Variablen. Anlegen z.B. mit 5'!a");

  factory _Liste.funktionen(RechnerModell m) => _Liste(m, "Eigene Funktionen", "app:funktionen", Bereich.funktionen, [
    for (Speicher s in m.zustand.speicher)
      if (s.art == SpeicherArt.funktion) (anzeige: s.name, inhalt: "{${s.code.replaceAll("\n", "↵")}}", name: s.name),
  ], "Noch keine eigenen Funktionen. Anlegen z.B. mit {1+}':inc");

  @override
  Widget build(BuildContext context) {
    final klein = Schrift.monospace(11, Farben.anzeigeBlass, gewicht: FontWeight.w600);
    final stil = Schrift.monospace(13, Farben.anzeigeText);
    void zeige(String kennung) => m.zeigeHilfe(AppHilfe.nachschlagen(m.api, kennung));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => m.hilfeModus ? zeige(hilfe) : m.waehleBereich(bereich),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        children: [
          Text(titel.toUpperCase(), style: klein),
          const SizedBox(height: 4),
          if (eintraege.isEmpty) Text(leer, style: stil.copyWith(color: Farben.anzeigeBlass)),
          for (final e in eintraege)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => m.hilfeModus ? zeige(e.name) : m.waehleBereich(bereich),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF16231D))),
                ),
                child: Row(
                  children: [
                    Text(e.anzeige, style: stil),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.inhalt,
                        style: stil.copyWith(color: Farben.anzeigeBlass),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Der Hilfeschirm über der Anzeige (doc/app.md 5.2): je Eintrag Titel und Verwendungen, nach MENÜ die
/// Einzelheiten, unten die Verweise zum Antippen. Ein Tipp daneben schließt ihn.
class _Hilfeschirm extends StatelessWidget {
  final RechnerModell m;
  final List<Hilfe> seite;
  const _Hilfeschirm(this.m, this.seite);

  @override
  Widget build(BuildContext context) {
    final titel = Schrift.monospace(14, Farben.hilfe, gewicht: FontWeight.w700);
    final stil = Schrift.monospace(12, Farben.anzeigeText);
    final blass = Schrift.monospace(11, Farben.anzeigeBlass);
    final verweise = <String>[];
    for (final h in seite) {
      for (final v in h.verweise) {
        if (!verweise.contains(v)) verweise.add(v);
      }
    }
    final einzelheiten = seite.any((h) => h.text.isNotEmpty);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: m.hilfeSchliessen,
      child: Container(
        color: Farben.anzeige.withValues(alpha: 0.97),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          children: [
            for (final h in seite) ...[
              Text(h.titel, style: titel),
              const SizedBox(height: 2),
              for (final v in h.verwendungen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: v.schreibweise,
                          style: stil.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (v.stack.isNotEmpty)
                          TextSpan(
                            text: "  ${v.stack}",
                            style: stil.copyWith(color: Farben.shift),
                          ),
                        if (v.argumente.isNotEmpty) TextSpan(text: "  ${v.argumente}", style: blass),
                        TextSpan(text: "  ${v.kurz}", style: stil),
                      ],
                    ),
                  ),
                ),
              if (m.hilfeDetails && h.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(h.textMit((k) => AppHilfe.titel(m.api, k)), style: stil.copyWith(height: 1.4)),
                ),
              const SizedBox(height: 8),
            ],
            if (verweise.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final v in verweise)
                    ActionChip(
                      label: Text(AppHilfe.titel(m.api, v), style: Schrift.monospace(11, Farben.anzeigeText)),
                      backgroundColor: const Color(0xFF14211B),
                      side: const BorderSide(color: Color(0xFF2C4A3C)),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => m.folgeVerweis(v),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              [
                if (einzelheiten) m.hilfeDetails ? "MENÜ: weniger" : "MENÜ: Einzelheiten",
                "◄ zurück",
                "Tipp: schließen",
                "⌫ beendet die Hilfe",
              ].join(" · "),
              style: blass,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tooltips der Statuszeile stehen unterhalb, über ihr ist kein Platz (doc/app.md 7, Punkt 14).
Widget _tippStatus(String nachricht, Widget kind) => tipp(nachricht, kind, unten: true);
