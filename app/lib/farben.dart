import 'package:flutter/material.dart';

/// Farben und Schriften der App, wie im Modell (doc/app.md).
abstract final class Farben {
  static const gehaeuse = Color(0xFF1A1D24);
  static const anzeige = Color(0xFF0D1512);
  static const anzeigeText = Color(0xFFD9EFE4);
  static const anzeigeBlass = Color(0xFF6F8F80);
  static const kontext = Color(0xFF1B2722); // Kontextmenü der Anzeige: etwas heller als sie (doc/app.md 2.1)
  static const kontextRand = Color(0xFF3E5A4D);
  static const kontextZeile = Color(0xFF22352C); // die Zeile, zu der das Kontextmenü offen ist
  static const taste = Color(0xFF262A33);
  static const funktion = Color(0xFF3B4250); // oberste Reihe, Funktionstasten und Cursorkreuz
  static const ziffer = Color(0xFF3A3F4C);       // unterer Block außer den Ziffern
  static const zifferHell = Color(0xFFAEB3BC);   // Ziffern, Punkt und ê: hell, damit sie sich absetzen
  static const zifferText = Color(0xFF111318);
  static const zifferGedimmt = Color(0xFF6E737D);
  static const reserviert = Color(0xFF20232A);
  static const tasteText = Color(0xFFEEF0F5);
  static const gedimmt = Color(0xFF6A7080);
  static const kante = Color(0xFF0B0C0F);
  static const shift = Color(0xFFFF9D4D);
  static const tilde = Color(0xFF3CC9C0);
  static const tildeTaste = Color(0xFF1D4F4C);
  static const strich = Color(0xFFB39BFF);
  static const strichTaste = Color(0xFF3B3166);
  static const alpha = Color(0xFF9BD46E);
  static const hilfe = Color(0xFF8EC9FF);
  static const tipp = Color(0xFFFFE680);      // Tooltips: hellgelb mit schwarzer Schrift
  static const tippText = Color(0xFF14110A);  // Hilfe-Modus: Marke und MENÜ-Taste
  // im Tooltip (gelber Grund): dunklere Töne der Umschaltfarben, Linien zwischen Funktionen und Bereichen
  static const tippTilde = Color(0xFF00726B);
  static const tippStrich = Color(0xFF5B3FB8);
  static const tippAlpha = Color(0xFF3E7A16);
  static const tippKasten = Color(0xFF9C8A4A);      // schon erklärte Argumente: ausgegraut
  static const tippHell = Color(0xFFFFF2B8);        // jede zweite Zeile eines Bereichs: etwas heller
  static const tippLinieBereich = Color(0xFFC9A93A); // zwischen zwei Bereichen: etwas dunkler
  static const tosHinten = Color(0xFFFFD9AE);
  static const tosText = Color(0xFF1A1208);
  static const fehler = Color(0xFFFF5D5D);
}

/// Schriften: Ziffern in einer Schrift mit fester Breite, Tasten schmal.
abstract final class Schrift {
  static const mono = ["Consolas", "Roboto Mono", "Menlo", "monospace"];
  static TextStyle monospace(double groesse, Color farbe, {FontWeight gewicht = FontWeight.w400}) => TextStyle(
      fontFamily: mono.first, fontFamilyFallback: mono.sublist(1), fontSize: groesse, color: farbe, fontWeight: gewicht,
      height: 1.3, fontFeatures: const [FontFeature.tabularFigures()]);
}
