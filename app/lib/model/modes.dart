/// Aufgabe: die Bedienmodi (doc/architecture.md 4.3). Ein [Bedienmodus] bekommt jede Bedienung, solange er
/// aktiv ist: Taste des Tastenfelds, getipptes Zeichen, Zeilenende, Cursorkreuz, Tab, Esc und F1; dazu darf er die
/// Beschriftung einzelner Tasten ändern. Rechnen gibt an Eingabe, Tastatur und Ausschnitt weiter; Hilfe enthält,
/// was Tasten, Zeichen und Pfeile im Inspekt- und im Lese-Modus bewirken.
///
/// Abgrenzung: Den Zustand der Hilfe (Seitenfolge, gewählter Verweis, Lese-Modus) und das Ein- und Ausschalten
/// führt help_mode.dart; das Modell gibt in input.dart, keyboard.dart und viewport.dart nur an [ModellKern.modus]
/// weiter. Das Menü (FA-6) wird ein weiterer Modus.
///
/// Siehe auch: doc/app.md 5.2 und Kapitel 6, help_mode.dart, keyboard.dart.
part of 'model.dart';

/// Ein Bedienmodus: alle Bedienungen gehen an den aktiven Modus.
abstract class Bedienmodus {
  /// Eine Taste des Tastenfelds (auch Backspace auf der Tastatur).
  void druecke(Taste t);

  /// Ein auf der PC-Tastatur getipptes Zeichen.
  void tippeZeichen(String c);

  /// Return bzw. Enter auf dem Ziffernblock; [text] ist das, was im Rechnen geschrieben wird.
  void zeilenende(String text);

  /// Ein Pfeil des Cursorkreuzes oder der Tastatur.
  void pfeil(AxisDirection richtung);

  /// Tab bzw. Umschalt+Tab auf der Tastatur.
  void tab({bool rueckwaerts = false});

  /// Esc auf der Tastatur.
  void esc();

  /// F1 auf der Tastatur.
  void hilfe();

  /// Eine eigene Beschriftung der Taste in diesem Modus, sonst null.
  Beschriftung? beschriftung(Taste t) => null;
}

/// Rechnen: Tasten und Zeichen schreiben in den Rechner, die Pfeile blättern und schieben im Bereich.
class _Rechnen extends Bedienmodus {
  final RechnerModell m;
  _Rechnen(this.m);

  @override
  void druecke(Taste t) => m._druckeRechnen(t);

  @override
  void tippeZeichen(String c) => m._tippeRechnen(c);

  @override
  void zeilenende(String text) => m._zeilenendeRechnen(text);

  @override
  void pfeil(AxisDirection richtung) => m._pfeilRechnen(richtung);

  @override
  void tab({bool rueckwaerts = false}) => m._tabRechnen(rueckwaerts: rueckwaerts);

  /// Esc wirkt wie CL (doc/app.md Kapitel 6).
  @override
  void esc() {
    m._zeileLoeschen();
    m._geaendert();
  }

  @override
  void hilfe() {
    m._hilfeStarten();
    m._geaendert();
  }
}

/// Hilfe: Inspekt-Modus (jede Taste zeigt ihre Hilfe) und Lese-Modus (Verweise wählen und folgen, blättern).
class _Hilfe extends Bedienmodus {
  final RechnerModell m;
  _Hilfe(this.m);

  static const _tab = Taste("TAB", aktion: Aktion.tab);

  /// Inspekt-Modus: jede Taste zeigt ihre Hilfe (auch ⌫ und SHIFT), BEENDEN (MENÜ) beendet, LESEN (ALPHA) wechselt
  /// in den Lese-Modus. Lese-Modus: TAB wählt einen Verweis, ENTER folgt ihm, ANFANG (MENÜ) zeigt die Startseite,
  /// BEENDEN (⌫) beendet, ALPHA geht zurück; andere Tasten tun nichts.
  @override
  void druecke(Taste t) {
    _taste(t);
    m._geaendert();
  }

  void _taste(Taste t) {
    if (m.hilfeLesen) {
      switch (t.aktion) {
        case Aktion.alpha:
          m.hilfeLesen = false;
          m.hilfeVerweis = -1;
        case Aktion.menue:
          m._neueSeite(AppHilfe.nachschlagen(m.api, "#"));
        case Aktion.loeschen:
          m._hilfeBeenden();
        case Aktion.shift:
          m.shift = !m.shift; // für Shift+TAB
          return;
        case Aktion.tab:
          m._waehleVerweis(rueckwaerts: m.shift);
        case Aktion.enter:
          m._folgeGewaehltem();
        default:
      }
      m.shift = false;
      return;
    }
    switch (t.aktion) {
      case Aktion.alpha:
        m.hilfeLesen = true;
        m.hilfeVerweis = -1;
        if (m.hilfeSeite == null) m._neueSeite(AppHilfe.nachschlagen(m.api, "#")); // Schirm war mit einem Tipp geschlossen
      case Aktion.menue:
        m._hilfeBeenden();
      default:
        m._neueSeite(AppHilfe.fuerTaste(m.api, t));
    }
  }

  /// Ein getipptes Zeichen zeigt die Hilfe zu seiner Taste bzw. zu sich; im Lese-Modus tut es nichts.
  @override
  void tippeZeichen(String c) {
    if (m.hilfeLesen) return;
    final kennung = RegExp(r"^[0-9]$").hasMatch(c) ? "#zahlen" : c;
    final t = m.tasteFuer(c);
    m._neueSeite(t != null && t.buchstabe != c.toLowerCase() ? AppHilfe.fuerTaste(m.api, t) : AppHilfe.nachschlagen(m.api, kennung));
    m._geaendert();
  }

  /// Return und Enter wirken wie ENTER des Tastenfelds.
  @override
  void zeilenende(String text) => druecke(_Tastatur._enter);

  /// Das Cursorkreuz: ◄ geht zurück, die erste Seite bleibt; im Lese-Modus blättern ▲ ▼ und ► folgt dem gewählten
  /// Verweis (ohne Auswahl wählt er den ersten), sonst Hilfe zum Cursorkreuz.
  @override
  void pfeil(AxisDirection richtung) {
    if (richtung == AxisDirection.left) {
      if (m._hilfeSeiten.length > 1) m._hilfeSeiten.removeLast();
      m.hilfeVerweis = -1;
    } else if (!m.hilfeLesen) {
      m._neueSeite(AppHilfe.nachschlagen(m.api, "app:cursorkreuz"));
    } else if (richtung == AxisDirection.right) {
      m.hilfeVerweis < 0 ? m._waehleVerweis() : m._folgeGewaehltem();
    } else if (m.hilfeScroll.hasClients) {
      final p = m.hilfeScroll.position;
      final ziel = (p.pixels + (richtung == AxisDirection.down ? 80 : -80)).clamp(0.0, p.maxScrollExtent);
      m.hilfeScroll.animateTo(ziel, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    }
    m._geaendert();
  }

  /// Tab wählt im Lese-Modus einen Verweis; im Inspekt-Modus zeigt es die Hilfe zu TAB.
  @override
  void tab({bool rueckwaerts = false}) {
    if (!m.hilfeLesen) return druecke(_tab);
    m._waehleVerweis(rueckwaerts: rueckwaerts);
    m._geaendert();
  }

  @override
  void esc() => hilfe();

  /// F1 und Esc beenden die Hilfe.
  @override
  void hilfe() {
    m._hilfeBeenden();
    m._geaendert();
  }

  /// MENÜ, ALPHA und ⌫ tragen ihre Aufgabe in der Hilfe (doc/app.md 5.2).
  @override
  Beschriftung? beschriftung(Taste t) {
    final text = switch (t.aktion) {
      Aktion.menue => m.hilfeLesen ? "ANFANG" : "BEENDEN",
      Aktion.alpha => m.hilfeLesen ? "INSPEKT" : "LESEN",
      Aktion.loeschen when m.hilfeLesen => "BEENDEN",
      _ => null,
    };
    return text == null ? null : (text: text, art: Beschriftungsart.normal, gedimmt: false);
  }
}
