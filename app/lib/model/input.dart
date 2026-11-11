/// Aufgabe: was ein Druck auf eine Taste des Tastenfelds bewirkt: SHIFT, ALPHA, TAB, MENÜ und Maximieren
/// schalten um, die Präfixe ~, | und ' schreiben sich und färben die Beschriftung, ⌫ löscht, alle anderen Tasten
/// schreiben ihre Eingabe (Namen mit Trennern davor und danach, Großbuchstaben als Befehl).
///
/// Abgrenzung: Das Schreiben in den Rechner und den Zeilenumbruch macht der Kern (model.dart); im Hilfe-Modus
/// übernimmt der Bedienmodus Hilfe (modes.dart); getippte Zeichen der PC-Tastatur kommen über keyboard.dart.
///
/// Siehe auch: doc/app.md 3.1, 3.2 und 4, keys.dart.
part of 'model.dart';

/// Tastendruck und Präfixe.
mixin _Eingabe on ModellKern {
  /// Eine Taste des Tastenfelds; was sie bewirkt, entscheidet der aktive Bedienmodus (modes.dart).
  @override
  void druecke(Taste t) => modus.druecke(t);

  /// Eine Taste im Bedienmodus Rechnen.
  void _druckeRechnen(Taste t) {
    if (t.reserviert && !(alpha && t.buchstabe != null)) return; // reserviert, aber in Alpha ein Buchstabe
    switch (t.aktion) {
      case Aktion.shift:
        shift = !shift; // im Alpha-Modus: der nächste Buchstabe groß
      case Aktion.alpha:
        // ALPHA schaltet um; Shift+ALPHA: Alpha an, Shift bleibt für einen großen Buchstaben
        // (eine eigene Belegung ist noch offen, Backlog FA-9)
        alpha = !alpha;
        if (!alpha) shift = false;
      case Aktion.tab:
        final n = Bereich.values.length;
        bereich = Bereich.values[(bereich.index + (shiftWirkt ? n - 1 : 1)) % n];
        shift = false;
      case Aktion.menue:
        // Shift+MENÜ ist die Hilfe; MENÜ allein öffnet die Oberfläche (Domänen)
        if (shiftWirkt) _hilfeStarten();
      case Aktion.maximieren:
        // nur Eingabe und Stack; die Seiten Funktionen und Variablen haben schon die ganze Breite
        if (bereich == Bereich.eingabe || bereich == Bereich.stack) maximiert = !maximiert;
        shift = false;
      case Aktion.tilde:
        _ende(alphaAus: true);
        _schreibe("~");
        tilde = true;
      case Aktion.strich:
        _ende(alphaAus: true);
        final doppelt = strich; // || ist der Betrag
        _schreibe("|");
        strich = !doppelt;
        if (doppelt) tilde = false;
      // CL leert die aktuelle Zeile, AC dazu Verlauf und Stack mit Tags (doc/app.md 3.1); in Alpha ist es d
      case Aktion.zeileLoeschen when !alpha:
        shiftWirkt ? _allesLoeschen() : _zeileLoeschen();
        shift = false;
      // ⌫ löscht auch im Alpha-Modus zeichenweise und lässt ihn an (z.B. beim Programmieren)
      case Aktion.loeschen when !shiftWirkt && rueckstrich:
        rueckstrich = false; // ⌫ nimmt das wartende \ zurück
      case Aktion.loeschen when !shiftWirkt:
        zustand = api.loeschen(zeilen: _stackZeilen);
        tilde = strich = apostroph = shift = false;
        _zurueckschieben();
      case Aktion.apostroph when !alpha:
        _schreibe("'");
        apostroph = true;
      default:
        _schreibeTaste(t);
    }
    notifyListeners();
  }

  /// CL: leert die aktuelle Zeile ohne Wirkung auf den Stack (verwirft, was noch nicht ausgeführt ist); ist sie
  /// leer, löscht es die Zeile darunter im Verlauf, die Liste rückt hoch.
  void _zeileLoeschen() {
    final leer = zeile.isEmpty && zustand.offen.isEmpty && !rueckstrich;
    tilde = strich = apostroph = rueckstrich = false;
    if (!leer) {
      zustand = api.verwerfen(zeilen: _stackZeilen);
    } else if (verlauf.isNotEmpty) {
      verlauf.removeAt(verlaufVersatz.clamp(0, verlauf.length - 1));
    }
    _zurueckschieben();
  }

  /// AC: löscht die aktuelle Zeile, den Verlauf und den Stack mit allen Tags; Variablen und eigene Funktionen
  /// bleiben.
  void _allesLoeschen() {
    tilde = strich = apostroph = rueckstrich = false;
    api.verwerfen();
    zustand = api.eingabe("'C", zeilen: _stackZeilen); // die Zeile ist danach abgeschlossen und erscheint nicht
    verlauf.clear();
    _zurueckschieben();
    bereich = Bereich.eingabe; // die Anzeige zeigt wieder die Seite Rechnen mit Eingabe und Stack (VA-16)
  }

  void _schreibeTaste(Taste t) {
    // ein wartendes \ ohne Befehl danach geht an den Rechner
    if (rueckstrich && !(alpha && t.buchstabe != null)) {
      rueckstrich = false;
      _schreibe(r"\");
    }
    if (alpha && t.buchstabe != null) {
      if (shift) {
        // ein Großbuchstabe ist ein Befehl aus genau einem Zeichen: danach endet Alpha (wie in der Grammatik)
        _schreibe(t.buchstabe!.toUpperCase());
        shift = alpha = false;
        return;
      }
      if (!_rueckstrichBefehl(t.buchstabe!)) _schreibe(t.buchstabe!); // \c \s \v auch im Alpha-Modus
      return; // Kleinbuchstaben: Alpha bleibt an
    }
    if (alpha && t.aktion == Aktion.enter) {
      _schreibe("\n");
      shift = false;
      return;
    }
    final shiftWirkt = this.shiftWirkt; // vor _ende, das Alpha beendet
    // wirkt der offene Präfix nicht auf die Taste, wirkt er allein: ein Trenner davor, sonst wäre 3~D die
    // Umkehrung von D (doc/app.md 3.2)
    if ((tilde || strich) && t.aktion != Aktion.enter && !_praefixWirkt(t, shiftWirkt)) _schreibe(" ");
    final String text;
    if (shiftWirkt && tilde && t.shiftTildeEingabe != null) {
      zustand = api.loeschen(zeilen: _stackZeilen); // das offene ~ weicht dem Zeichen (≤ statt ~>)
      text = t.shiftTildeEingabe!;
    } else if (shiftWirkt && t.shift != null) {
      text = t.shiftEingabe!;
    } else if (tilde && t.tildeEingabe != null) {
      text = t.tildeEingabe!;
    } else {
      text = t.eingabe;
    }
    final name = t.name || (shiftWirkt && t.shift != null && t.funktion == null && RegExp(r"^[a-z]{2,}").hasMatch(text));
    _ende(alphaAus: true);
    if (name) {
      _schreibeName(text);
    } else {
      _schreibe(text);
    }
  }

  /// Ob der offene Präfix (`~`, `|` oder beide) auf die Taste wirkt; nach `~` gehören Ziffern, `.` und `ê` zur
  /// negativen Zahl.
  bool _praefixWirkt(Taste t, bool shiftWirkt) {
    if (tilde && strich) return t.beide != null;
    if (tilde) return shiftWirkt ? t.shiftTilde != null : t.tilde != null || RegExp(r"^[0-9.ê]$").hasMatch(t.text);
    return !shiftWirkt && t.strich != null;
  }

  /// Schreibt einen Namen: bei Bedarf ein "_" davor, damit er nicht mit dem vorigen verschmilzt,
  /// und ein "_" dahinter, damit er gleich ausgeführt wird (doc/app.md 4.1).
  void _schreibeName(String name) {
    final z = zeile;
    if (z.isNotEmpty && RegExp(r"[A-Za-z]$").hasMatch(z) && !RegExp(r"'[!|=+\-*/~]*$").hasMatch(z)) {
      _schreibe("_");
    }
    _schreibe(name);
    _schreibe("_");
  }
}
