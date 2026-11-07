import 'dart:io';

import 'package:test/test.dart';

/// Regeln aus doc/architecture.md 5, die sich am Quelltext prüfen lassen.
void main() {
  /// Imports aus package:rpncalc in den Dateien unter [ordner], die nicht in [erlaubt] stehen.
  List<String> verboten(String ordner, Set<String> erlaubt) => [
        for (final datei in Directory(ordner).listSync(recursive: true).whereType<File>())
          if (datei.path.endsWith(".dart"))
            for (final m in RegExp(r"""import\s+['"]package:rpncalc/([^'"]+)['"]""").allMatches(datei.readAsStringSync()))
              if (!erlaubt.contains(m[1])) "${datei.path}: ${m[1]}",
      ];

  test('die App importiert aus dem Rechner nur rpnapi.dart', () {
    expect(verboten("app/lib", {"rpnapi.dart"}), isEmpty);
  });

  test('die Startpunkte in bin/ benutzen nur die Türen', () {
    expect(verboten("bin", {"rpnapi.dart", "console.dart", "net.dart"}), isEmpty);
  });
}
