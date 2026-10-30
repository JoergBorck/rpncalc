import 'dart:convert';
import 'dart:io';

/// Schreibt [text] in die Zwischenablage des Betriebssystems.
///
/// Erst über das passende Programm (clip, pbcopy, wl-copy, xclip), sonst über die Steuerfolge OSC 52,
/// mit der das Terminal selbst in die Zwischenablage schreibt (nicht jedes Terminal kann das).
/// Liefert eine kurze Meldung für die Anzeige.
Future<String> inZwischenablage(String text) async {
  List<List<String>> befehle = Platform.isWindows
      ? [["clip"]]
      : Platform.isMacOS
          ? [["pbcopy"]]
          : [["wl-copy"], ["xclip", "-selection", "clipboard"], ["xsel", "--clipboard", "--input"]];
  for (List<String> befehl in befehle) {
    try {
      Process p = await Process.start(befehl.first, befehl.sublist(1));
      p.stdin.write(text);
      await p.stdin.close();
      if (await p.exitCode == 0) return "Kopiert: $text";
    } on ProcessException {
      // Programm nicht vorhanden, das nächste versuchen
    }
  }
  stdout.write("\x1B]52;c;${base64Encode(utf8.encode(text))}\x07");
  return "Kopiert (über das Terminal): $text";
}

/// Liest den Text aus der Zwischenablage des Betriebssystems (Get-Clipboard, pbpaste, wl-paste, xclip, xsel).
/// Liefert null, wenn das nicht geht.
Future<String?> ausZwischenablage() async {
  List<List<String>> befehle = Platform.isWindows
      ? [["powershell", "-NoProfile", "-Command", "Get-Clipboard -Raw"]]
      : Platform.isMacOS
          ? [["pbpaste"]]
          : [["wl-paste", "--no-newline"], ["xclip", "-selection", "clipboard", "-o"], ["xsel", "--clipboard", "--output"]];
  for (List<String> befehl in befehle) {
    try {
      ProcessResult r = await Process.run(befehl.first, befehl.sublist(1));
      if (r.exitCode == 0) return r.stdout as String;
    } on ProcessException {
      // Programm nicht vorhanden, das nächste versuchen
    }
  }
  return null;
}
