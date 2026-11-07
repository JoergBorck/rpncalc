/// Aufgabe: die Seiten „Variablen und Tags“ und „Funktionen“ der Anzeige, in Abschnitten: Variablen und Tags mit
/// ihren Werten; eigene Funktionen und je geladener Bibliothek ihre Funktionen mit Code. Beim Blättern der
/// Funktionstasten scrollt die Seite Funktionen zum Abschnitt der gezeigten Bibliothek.
///
/// Abgrenzung: Die Daten kommen aus dem Zustand des Rechners über das Modell; der Rahmen mit dem Wischen
/// zwischen den Seiten steht in display.dart.
///
/// Siehe auch: doc/app.md Kapitel 2 und 5.3, model/model.dart.
library;

import 'package:flutter/material.dart';
import 'package:rpncalc/rpnapi.dart';

import '../colors.dart';
import '../help_texts.dart';
import '../model/model.dart';

/// Ein Eintrag der Liste; [kursiv] für interne Funktionen (rpnintern, doc/app.md 2): kursiv und ausgegraut.
typedef _Eintrag = ({String anzeige, String inhalt, String name, bool kursiv});

/// Ein Abschnitt der Seiten Variablen bzw. Funktionen: Überschrift, Einträge, Text, wenn er leer ist; [ziel] ist
/// der Name, unter dem man zu ihm scrollen kann (die Bibliothek).
typedef _Abschnitt = ({String titel, List<_Eintrag> eintraege, String leer, String? ziel});

/// Die Seiten „Variablen und Tags“ und „Funktionen“ der Anzeige, in Abschnitten (doc/app.md 2). Im Hilfe-Modus
/// zeigt ein Tipp auf einen Eintrag dessen Hilfe, ein Tipp daneben die Hilfe zur Seite (doc/app.md 5.3).
class ListenSeite extends StatefulWidget {
  final RechnerModell m;
  final String hilfe; // Hilfe zur Seite
  final Bereich bereich; // Antippen wählt ihn
  final List<_Abschnitt> _abschnitte;
  // wohin die Liste scrollt, wenn es sich ändert: Abschnitt einer Bibliothek bzw. eine Funktion darin; null: nach oben
  final ({String bibliothek, String? funktion})? ziel;
  const ListenSeite._(this.m, this.hilfe, this.bereich, this._abschnitte, {this.ziel});

  factory ListenSeite.variablen(RechnerModell m) => ListenSeite._(m, "app:variablen", Bereich.variablen, [
        (
          titel: "Variablen und Tags",
          eintraege: [
            for (Speicher s in m.zustand.speicher)
              if (s.art != SpeicherArt.funktion)
                (
                  anzeige: "${s.art == SpeicherArt.tag ? "|" : ""}${s.name}",
                  inhalt: s.werte.map(zahl).join(" "), // Felder ohne [ ], die sind für Einheiten reserviert
                  name: s.name,
                  kursiv: false,
                ),
          ],
          leer: "Noch keine Variablen. Anlegen z.B. mit 5'!a",
          ziel: null,
        ),
      ]);

  /// Eigene Funktionen zuerst, dann je geladener Bibliothek ein Abschnitt mit ihrem Code; beim Blättern der
  /// Funktionstasten scrollt die Liste zum Abschnitt der gezeigten Bibliothek.
  factory ListenSeite.funktionen(RechnerModell m) {
    _Eintrag eintrag(Speicher s) =>
        (anzeige: s.name, inhalt: "{${s.code.replaceAll("\n", "↵")}}", name: s.name, kursiv: s.intern);
    final funktionen = [for (Speicher s in m.zustand.speicher) if (s.art == SpeicherArt.funktion) s];
    final bibliotheken = <String, List<Speicher>>{};
    for (final s in funktionen) {
      final von = m.api.herkunft(s.name);
      if (von != null) (bibliotheken[von] ??= []).add(s);
    }
    // in der Reihenfolge der Datei wie auf den Funktionstasten, damit das Scrollen zu ihren Seiten passt
    List<_Eintrag> geordnet(String name, List<Speicher> liste) {
      final reihe = m.api.bibliotheksFunktionen(name);
      return [for (final s in liste..sort((a, b) => reihe.indexOf(a.name).compareTo(reihe.indexOf(b.name)))) eintrag(s)];
    }
    return ListenSeite._(m, "app:funktionen", Bereich.funktionen, ziel: m.seitenZiel, [
      (
        titel: "Eigene Funktionen",
        eintraege: [for (final s in funktionen) if (m.api.herkunft(s.name) == null) eintrag(s)],
        leer: "Noch keine eigenen Funktionen. Anlegen z.B. mit {1+}':inc",
        ziel: null,
      ),
      for (final MapEntry(key: name, value: liste) in bibliotheken.entries)
        (titel: "Bibliothek $name", eintraege: geordnet(name, liste), leer: "", ziel: name),
    ]);
  }

  @override
  State<ListenSeite> createState() => _ListenSeiteState();
}

class _ListenSeiteState extends State<ListenSeite> {
  final _scroll = ScrollController();
  final _marken = <String, GlobalKey>{};

  @override
  void didUpdateWidget(ListenSeite alt) {
    super.didUpdateWidget(alt);
    // nur wenn die Funktionstasten auf eine andere Bibliothek blättern; sonst bleibt die Liste, wo man sie hinscrollt
    if (alt.ziel != widget.ziel) WidgetsBinding.instance.addPostFrameCallback((_) => _springe());
  }

  void _springe() {
    final z = widget.ziel;
    final ziel = z == null ? null : _marken[z.funktion == null ? z.bibliothek : "${z.bibliothek}:${z.funktion}"]?.currentContext;
    if (ziel != null && ziel.mounted) {
      Scrollable.ensureVisible(ziel, duration: const Duration(milliseconds: 250));
    } else if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.m;
    final klein = Schrift.monospace(11, Farben.anzeigeBlass, gewicht: FontWeight.w600);
    final stil = Schrift.monospace(13, Farben.anzeigeText);
    void zeige(String kennung) => m.zeigeHilfe(AppHilfe.nachschlagen(m.api, kennung));
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => m.hilfeModus ? zeige(widget.hilfe) : m.waehleBereich(widget.bereich),
      // alle Einträge gebaut (keine ListView), damit sich zu jedem Abschnitt scrollen lässt
      child: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, a) in widget._abschnitte.indexed) ...[
              if (i > 0) const SizedBox(height: 10),
              Text(
                a.titel.toUpperCase(),
                key: a.ziel == null ? null : _marken.putIfAbsent(a.ziel!, GlobalKey.new),
                style: klein,
              ),
              const SizedBox(height: 4),
              if (a.eintraege.isEmpty && a.leer.isNotEmpty) Text(a.leer, style: stil.copyWith(color: Farben.anzeigeBlass)),
              for (final e in a.eintraege)
                GestureDetector(
                  // Marke für das Scrollen zu den Funktionen einer weiteren Seite der Funktionstasten
                  key: a.ziel == null ? null : _marken.putIfAbsent("${a.ziel}:${e.name}", GlobalKey.new),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => m.hilfeModus ? zeige(e.name) : m.waehleBereich(widget.bereich),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFF16231D))),
                    ),
                    child: Row(
                      children: [
                        Text(e.anzeige, style: e.kursiv ? stil.copyWith(fontStyle: FontStyle.italic, color: Farben.anzeigeBlass) : stil),
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
          ],
        ),
      ),
    );
  }
}
