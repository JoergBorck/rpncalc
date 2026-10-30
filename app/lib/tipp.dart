import 'package:flutter/material.dart';

import 'farben.dart';

/// Tooltip als abgerundeter hellgelber Kasten oberhalb des Elements (doc/app.md 7, Punkt 14). Gelb kommt sonst
/// nirgends vor, so hebt er sich klar von der dunklen Oberfläche ab. Am PC erscheint er beim Darüberfahren, am
/// Handy bei langem Drücken. Passt oben kein Platz, steht er darunter.
/// Mit [unten] steht er unterhalb und etwas weiter weg, damit er nicht unter dem Mauszeiger liegt; für die
/// Elemente ganz oben (Statuszeile), über denen kein Platz ist.
Widget tipp(String nachricht, Widget kind, {bool unten = false}) {
  if (nachricht.isEmpty) return kind;
  return Tooltip(
    message: nachricht,
    preferBelow: unten,
    verticalOffset: unten ? 30 : 20,
    waitDuration: const Duration(milliseconds: 600),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    textStyle: Schrift.monospace(12, Farben.tippText),
    decoration: BoxDecoration(
      color: Farben.tipp,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: kind,
  );
}
