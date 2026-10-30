import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Erzeugt das App-Symbol in allen Größen für Android, Web und Windows: der Stack, oben der Tos hellorange,
/// links der orange Cursor. Aufruf im Verzeichnis app: flutter test tool/symbol_test.dart

const _gehaeuse = Color(0xFF1A1D24), _anzeige = Color(0xFF0D1512);

/// [rand]: Abstand der Anzeige vom Rand (Anteil der Breite); [gehaeuse]: abgerundetes Gehäuse dahinter,
/// [vollflaechig]: Gehäuse ohne Rundung bis in die Ecken (für Symbole, die das System selbst zuschneidet).
class _Symbol extends CustomPainter {
  final double rand;
  final bool gehaeuse, vollflaechig;
  const _Symbol({required this.rand, this.gehaeuse = true, this.vollflaechig = false});

  @override
  void paint(Canvas c, Size s) {
    final w = s.width;
    if (vollflaechig) {
      c.drawRect(Offset.zero & s, Paint()..color = _gehaeuse);
    } else if (gehaeuse) {
      c.drawRRect(RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(w * 0.22)), Paint()..color = _gehaeuse);
    }
    // die Anzeige, darin alles relativ zu ihrer Breite d
    final x0 = w * rand, d = w * (1 - 2 * rand);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x0, x0, d, d), Radius.circular(d * 0.11)), Paint()..color = _anzeige);
    final balken = [
      (breite: 0.66, hoehe: 0.18, farbe: const Color(0xFFFFD9AE)), // Tos
      (breite: 0.52, hoehe: 0.14, farbe: const Color(0xFFD9EFE4)),
      (breite: 0.40, hoehe: 0.11, farbe: const Color(0xFF6F8F80)),
    ];
    const luecke = 0.08;
    final gesamt = balken.fold(0.0, (s, b) => s + b.hoehe) + luecke * (balken.length - 1);
    double y = (1 - gesamt) / 2; // senkrecht in der Mitte der Anzeige
    for (final b in balken) {
      final r = Rect.fromLTWH(x0 + d * (0.89 - b.breite), x0 + d * y, d * b.breite, d * b.hoehe);
      c.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(d * 0.035)), Paint()..color = b.farbe);
      y += b.hoehe + luecke;
    }
    // der Cursor links neben dem Tos, mit etwas Abstand
    final tosOben = (1 - gesamt) / 2;
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x0 + d * 0.11, x0 + d * tosOben, d * 0.065, d * 0.18), Radius.circular(d * 0.016)),
      Paint()..color = const Color(0xFFFF9D4D),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter alt) => false;
}

void main() {
  testWidgets('App-Symbol erzeugen', (tester) async {
    Future<Uint8List> png(_Symbol symbol, int groesse) async {
      final schluessel = GlobalKey();
      await tester.pumpWidget(Center(
        child: RepaintBoundary(
          key: schluessel,
          child: CustomPaint(size: Size(groesse.toDouble(), groesse.toDouble()), painter: symbol),
        ),
      ));
      late Uint8List daten;
      await tester.runAsync(() async {
        final grenze = schluessel.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final bild = await grenze.toImage();
        daten = (await bild.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      });
      return daten;
    }

    Future<void> schreibe(String pfad, _Symbol symbol, int groesse) async {
      File(pfad)
        ..createSync(recursive: true)
        ..writeAsBytesSync(await png(symbol, groesse));
    }

    const normal = _Symbol(rand: 0.14);
    const vordergrund = _Symbol(rand: 0.22, gehaeuse: false); // adaptiv: das System legt Form und Hintergrund
    const maskierbar = _Symbol(rand: 0.22, vollflaechig: true); // Web: der Browser schneidet zu

    // Android: klassische Symbole und Vordergrund des adaptiven Symbols (108 dp, sichtbar sind die mittleren 66)
    const dichten = {"mdpi": 1.0, "hdpi": 1.5, "xhdpi": 2.0, "xxhdpi": 3.0, "xxxhdpi": 4.0};
    for (final e in dichten.entries) {
      await schreibe("android/app/src/main/res/mipmap-${e.key}/ic_launcher.png", normal, (48 * e.value).round());
      await schreibe("android/app/src/main/res/mipmap-${e.key}/ic_launcher_foreground.png", vordergrund, (108 * e.value).round());
    }
    File("android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml")
      ..createSync(recursive: true)
      ..writeAsStringSync('''<?xml version="1.0" encoding="utf-8"?>
<!-- Adaptives Symbol (Android 8+), erzeugt von tool/symbol_test.dart -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''');
    File("android/app/src/main/res/values/ic_launcher_background.xml")
      ..createSync(recursive: true)
      ..writeAsStringSync('''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#1A1D24</color>
</resources>
''');

    // Web
    await schreibe("web/icons/Icon-192.png", normal, 192);
    await schreibe("web/icons/Icon-512.png", normal, 512);
    await schreibe("web/icons/Icon-maskable-192.png", maskierbar, 192);
    await schreibe("web/icons/Icon-maskable-512.png", maskierbar, 512);
    await schreibe("web/favicon.png", normal, 32);

    // Windows: ICO mit eingebetteten PNG-Bildern
    final groessen = [16, 32, 48, 256];
    final bilder = [for (final g in groessen) await png(normal, g)];
    final ico = BytesBuilder();
    void u16(int v) => ico.add([v & 0xFF, v >> 8]);
    void u32(int v) => ico.add([v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]);
    u16(0); u16(1); u16(groessen.length); // Kopf: reserviert, Typ Symbol, Anzahl
    int versatz = 6 + 16 * groessen.length;
    for (int i = 0; i < groessen.length; i++) {
      final g = groessen[i] >= 256 ? 0 : groessen[i]; // 0 steht für 256
      ico.add([g, g, 0, 0]);
      u16(1); u16(32); // Farbebenen, Bit je Pixel
      u32(bilder[i].length);
      u32(versatz);
      versatz += bilder[i].length;
    }
    for (final b in bilder) {
      ico.add(b);
    }
    File("windows/runner/resources/app_icon.ico").writeAsBytesSync(ico.toBytes());

    // Vorschau im Scratchpad
    File(r"C:\Users\xiabo\AppData\Local\Temp\claude\d--AA-Dart-rpncalc\fdb9109b-b596-417a-98e1-c21826f3d11a\scratchpad\symbol_neu.png")
        .writeAsBytesSync(await png(normal, 512));
  });
}
