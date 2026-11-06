import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc/console/help.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc_app/anzeige.dart';
import 'package:rpncalc_app/farben.dart';
import 'package:rpncalc_app/hilfe.dart';
import 'package:rpncalc_app/modell.dart';
import 'package:rpncalc_app/tasten.dart';
import 'package:rpncalc_app/tipp.dart';

/// Prüfseite für alle Hilfetexte (Aufruf über tool/hilfe.dart im Hauptverzeichnis): zeichnet mit den echten
/// Widgets jeden Tooltip und jeden Hilfeschirm der App als Bild, dazu die Hilfe der Konsole als Text, und
/// schreibt build/hilfe/index.html mit dem Prüfstatus aus tool/hilfe_geprueft.json.

const _ziel = "build/hilfe";
const _pruefDatei = "../tool/hilfe_geprueft.json";

/// Ein zu prüfender Eintrag: [inhalt] ist das, was geprüft wird; ändert er sich, ist die Prüfung hinfällig.
class _Eintrag {
  final String id, gruppe, titel, inhalt;
  String? bild, konsole;
  final List<String> fehler = [];
  _Eintrag(this.id, this.gruppe, this.titel, this.inhalt);
  String get pruefsumme => _fnv(inhalt);
}

/// FNV-1a, 64 Bit: reicht, um Änderungen am Inhalt zu erkennen.
String _fnv(String s) {
  var h = 0xcbf29ce484222325;
  for (final b in utf8.encode(s)) {
    h = (h ^ b) * 0x100000001b3;
  }
  return BigInt.from(h).toUnsigned(64).toRadixString(16).padLeft(16, "0");
}

Future<void> _schrift(String familie, String datei) async {
  final f = File(datei);
  if (!f.existsSync()) return;
  final l = FontLoader(familie)..addFont(Future.value(f.readAsBytesSync().buffer.asByteData()));
  await l.load();
}

String _html(String s) => s.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");

/// Die Hilfe der Konsole als HTML: ANSI fett und blass werden zu Spans.
String _ansi(List<String> zeilen) {
  final aus = StringBuffer();
  for (final z in zeilen) {
    var offen = false;
    final teile = _html(z).split("\x1B[");
    aus.write(teile.first);
    for (final teil in teile.skip(1)) {
      final m = RegExp(r"^(\d*)m").firstMatch(teil);
      if (m == null) {
        aus.write(teil);
        continue;
      }
      if (offen) aus.write("</span>");
      offen = m[1] == "1" || m[1] == "2";
      if (offen) aus.write(m[1] == "1" ? '<span class="fett">' : '<span class="blass">');
      aus.write(teil.substring(m[0]!.length));
    }
    if (offen) aus.write("</span>");
    aus.write("\n");
  }
  return aus.toString();
}

void main() {
  testWidgets('Prüfseite der Hilfetexte', (tester) async {
    await tester.runAsync(() async {
      await _schrift("Consolas", r"C:\Windows\Fonts\consola.ttf");
      await _schrift("Roboto Mono", r"C:\Windows\Fonts\seguisym.ttf"); // Ersatz für ⇧, ≡ und Co.
      await _schrift("Roboto", r"C:\Windows\Fonts\segoeui.ttf");
    });
    await tester.binding.setSurfaceSize(const Size(1200, 4000));
    Directory(_ziel).createSync(recursive: true);

    final m = RechnerModell()..hilfeLesen = true; // der volle Text wie im Lese-Modus
    final api = m.api;
    final eintraege = <_Eintrag>[];
    var nr = 0;

    Future<void> zeichne(_Eintrag e, Widget w, {double? breite}) async {
      final k = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
          backgroundColor: Farben.gehaeuse,
          body: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: k,
              child: Padding(padding: const EdgeInsets.all(8), child: breite == null ? w : SizedBox(width: breite, child: w)),
            ),
          ),
        ),
      ));
      await tester.runAsync(() async {
        final bild = await (k.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage(pixelRatio: 1.5);
        final png = await bild.toByteData(format: ui.ImageByteFormat.png);
        e.bild = "b${nr++}.png";
        File("$_ziel/${e.bild}").writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    // Ziele für die Prüfung der Verweise
    final kennungen = <String>{...api.hilfeKennungen(), ...AppHilfe.eintraege.keys, ...KonsolenHilfe.eintraege.keys,
      "app:bibliotheken"};
    void verweise(_Eintrag e, Hilfe? h) {
      for (final v in h?.verweise ?? const <String>[]) {
        if (!kennungen.contains(v) && api.hilfe(v) == null) e.fehler.add("Verweis ohne Ziel: [[$v]]");
      }
      for (final w in h?.verwendungen ?? const <Verwendung>[]) {
        if (w.kurz.trim().isEmpty) e.fehler.add("Verwendung ohne Kurztext: ${w.schreibweise}");
      }
    }

    // 1. Tooltips aller Tasten
    const r1 = [
      Taste("SHIFT", aktion: Aktion.shift),
      Taste("ALPHA", shift: "ABC", aktion: Aktion.alpha),
      Taste("TAB", shift: "⇤", aktion: Aktion.tab),
      Taste("MENÜ", shift: "HILFE", aktion: Aktion.menue),
    ];
    final reihen = <String, List<Taste?>>{
      "R1": r1,
      for (var i = 0; i < obereTasten.length; i++) "R${i + 2}": obereTasten[i],
      for (var i = 0; i < untereTasten.length; i++) "R${i + 6}": untereTasten[i],
      ...domaenen,
      // die Funktionstasten der Bibliotheken, so wie die App sie nach der Auswahl im Menü zeigt
      for (final b in api.bibliotheken())
        if (api.ladeBibliothek(b.name) == null) b.name: [for (final f in api.bibliotheksFunktionen(b.name)) Taste(f, name: true)],
    };
    for (final r in reihen.entries) {
      for (final t in r.value) {
        if (t == null || t.funktion != null) continue; // Funktionstasten ohne Belegung (F1–F10) kommen aus den Domänen
        final bereiche = AppHilfe.tippBereiche(api, t);
        final inhalt = jsonEncode([
          for (final b in bereiche) [for (final z in b) [z.art.name, z.schreibweise, z.stack, z.text]],
        ]);
        final name = t.text.isEmpty ? "(leer)" : t.text;
        final e = _Eintrag("taste:${r.key}/$name", "Tooltips ${r.key}", name, inhalt);
        if (bereiche.isEmpty) e.fehler.add("kein Tooltip");
        await zeichne(
          e,
          DecoratedBox(
            decoration: BoxDecoration(color: Farben.tipp, borderRadius: BorderRadius.circular(8)),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), child: tippTabelleInhalt(bereiche)),
          ),
        );
        eintraege.add(e);
      }
    }

    // Tooltips der Bibliotheken selbst (Menü bzw. später der Bereich Bibliotheken)
    for (final b in api.bibliotheken()) {
      final bereiche = AppHilfe.tippBibliothek(api, b.name);
      final e = _Eintrag("bibliothek:${b.name}", "Tooltips der Bibliotheken", b.name, jsonEncode([
        for (final x in bereiche) [for (final z in x) [z.schreibweise, z.text]],
      ]));
      await zeichne(
        e,
        DecoratedBox(
          decoration: BoxDecoration(color: Farben.tipp, borderRadius: BorderRadius.circular(8)),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), child: tippTabelleInhalt(bereiche)),
        ),
      );
      eintraege.add(e);
    }

    // Hilfeseiten der Bibliotheken: erst die Übersichten (#name …), dann die Funktionen
    for (final b in api.bibliotheken()) {
      final kennungen = [
        for (final k in api.calculator.eigeneHilfen.keys) if (k.startsWith("#${b.name}")) k,
        ...api.bibliotheksFunktionen(b.name),
      ];
      for (final k in kennungen) {
        final h = api.hilfe(k);
        if (h == null) continue;
        final e = _Eintrag("bibliothek:${b.name}/$k", "Hilfe der Bibliothek ${b.name}", "$k  ${h.titel}", jsonEncode(h.toJson()));
        verweise(e, h);
        await zeichne(e, Hilfeschirm(m, AppHilfe.nachschlagen(api, k), scrollen: false), breite: 400);
        eintraege.add(e);
      }
    }

    // 2. Hilfe des Rechners: in der App (zusammen mit einem Eintrag der App) und in der Konsole
    // Hat die App einen Eintrag mit derselben Kennung (#, ~, |, '), zeigt sie beide zusammen auf einer Seite; er
    // wird hier mitgeprüft und unten nicht noch einmal gezeigt
    for (final k in api.hilfeKennungen()) {
      final h = api.hilfe(k)!;
      final app = AppHilfe.eintraege[k];
      final e = _Eintrag(app == null ? "rechner:$k" : "rechner:$k · app:$k", "Hilfe des Rechners", "$k  ${h.titel}",
          jsonEncode(app == null ? h.toJson() : [app.toJson(), h.toJson()]));
      verweise(e, app);
      verweise(e, h);
      await zeichne(e, Hilfeschirm(m, AppHilfe.nachschlagen(api, k), scrollen: false), breite: 400);
      e.konsole = _ansi(KonsolenHilfe.zeilen([?KonsolenHilfe.eintraege[k], h], k, breite: 79));
      eintraege.add(e);
    }

    // 3. Einträge der App
    for (final h in AppHilfe.eintraege.values) {
      if (api.hilfe(h.kennung) != null) continue; // schon beim Rechner
      // die Kennungen der App beginnen meist schon mit „app:“
      final id = h.kennung.startsWith("app:") ? h.kennung : "app:${h.kennung}";
      final e = _Eintrag(id, "Hilfe der App", "${h.kennung}  ${h.titel}", jsonEncode(h.toJson()));
      verweise(e, h);
      await zeichne(e, Hilfeschirm(m, AppHilfe.nachschlagen(api, h.kennung), scrollen: false), breite: 400);
      eintraege.add(e);
    }

    // die von der App erzeugte Seite der Bibliotheken
    final seite = AppHilfe.bibliothekenSeite(api);
    final bib = _Eintrag("app:bibliotheken", "Hilfe der App", "app:bibliotheken  Bibliotheken", jsonEncode(seite.toJson()));
    verweise(bib, seite);
    await zeichne(bib, Hilfeschirm(m, [seite], scrollen: false), breite: 400);
    eintraege.add(bib);

    // 4. Einträge der Konsole
    for (final h in KonsolenHilfe.eintraege.values) {
      final e = _Eintrag("konsole:${h.kennung}", "Hilfe der Konsole", "${h.kennung}  ${h.titel}", jsonEncode(h.toJson()));
      verweise(e, h);
      e.konsole = _ansi(KonsolenHilfe.zeilen([h, ?api.hilfe(h.kennung)], h.kennung, breite: 79));
      eintraege.add(e);
    }

    // Prüfstatus und Seite
    final pruefDatei = File(_pruefDatei);
    final geprueft = pruefDatei.existsSync()
        ? (jsonDecode(pruefDatei.readAsStringSync()) as Map).cast<String, String>()
        : <String, String>{};
    String status(_Eintrag e) => geprueft[e.id] == e.pruefsumme ? "ok" : geprueft.containsKey(e.id) ? "geaendert" : "offen";
    const zeichen = {"ok": "✓", "geaendert": "✎", "offen": "○"};

    File("$_ziel/manifest.json").writeAsStringSync(const JsonEncoder.withIndent(" ").convert({
      for (final e in eintraege) e.id: e.pruefsumme,
    }));

    final zahl = {for (final s in zeichen.keys) s: eintraege.where((e) => status(e) == s).length};
    final html = StringBuffer('''<!doctype html><html lang="de"><head><meta charset="utf-8">
<title>Hilfetexte prüfen</title><style>
body{background:#1a1d24;color:#d9efe4;font-family:Segoe UI,sans-serif;margin:16px}
h1{font-size:20px} h2{font-size:16px;color:#8ec9ff;margin-top:28px}
.leiste{position:sticky;top:0;background:#1a1d24;padding:8px 0;z-index:1}
button{background:#3b4250;color:#eef0f5;border:0;border-radius:6px;padding:4px 10px;margin-right:6px;cursor:pointer}
.karte{display:inline-block;vertical-align:top;margin:6px;padding:8px;border-radius:8px;background:#262a33;max-width:100%}
.kopf{font-family:Consolas,monospace;font-size:13px;margin-bottom:6px}
.ok .zeichen{color:#9bd46e}.geaendert .zeichen{color:#ff9d4d}.offen .zeichen{color:#6a7080}
.fehler{color:#ff5d5d;font-size:12px}
img{display:block;max-width:100%}
pre{background:#0c0c0c;color:#cccccc;font-family:Consolas,monospace;font-size:12px;padding:8px;margin:6px 0 0;overflow-x:auto}
.fett{font-weight:bold;color:#ffffff}.blass{color:#808080}
.nur-offen .karte.ok{display:none}
.sprung{font-family:Consolas,monospace;font-size:13px;line-height:1.8;margin:8px 0}
.sprung a{color:#d9efe4;text-decoration:none;white-space:nowrap} .sprung a:hover{text-decoration:underline}
.karte:target{outline:2px solid #ff9d4d}
.leiste a{color:#8ec9ff;margin-left:8px}
</style></head><body>
<h1>Hilfetexte prüfen</h1>
<div class="leiste">✓ ${zahl["ok"]} geprüft · ✎ ${zahl["geaendert"]} seit der Prüfung geändert · ○ ${zahl["offen"]} offen · ${eintraege.length} insgesamt
<button onclick="document.body.classList.toggle('nur-offen')">nur offene / alle</button><a href="#">nach oben</a></div>
''');
    // Sprungliste: alle Karten, die noch zu prüfen sind
    final offen = [for (final (i, e) in eintraege.indexed) if (status(e) != "ok") (i, e)];
    if (offen.isNotEmpty) {
      html.write('<div class="sprung">Zu prüfen: ');
      html.write([
        for (final (i, e) in offen) '<a href="#k$i" class="${status(e)}"><span class="zeichen">${zeichen[status(e)]}</span> ${_html(e.id)}</a>'
      ].join(" · "));
      html.write("</div>\n");
    }
    String? gruppe;
    for (final (i, e) in eintraege.indexed) {
      if (e.gruppe != gruppe) {
        gruppe = e.gruppe;
        html.write("<h2>${_html(gruppe)}</h2>\n");
      }
      final s = status(e);
      html.write('<div class="karte $s" id="k$i"><div class="kopf"><span class="zeichen">${zeichen[s]}</span> ${_html(e.id)}</div>');
      for (final f in e.fehler) {
        html.write('<div class="fehler">${_html(f)}</div>');
      }
      if (e.bild != null) html.write('<img src="${e.bild}" alt="${_html(e.titel)}">');
      if (e.konsole != null) html.write("<pre>${e.konsole}</pre>");
      html.write("</div>\n");
    }
    html.write("</body></html>\n");
    File("$_ziel/index.html").writeAsStringSync(html.toString());
    // ignore: avoid_print
    print("Prüfseite: ${File("$_ziel/index.html").absolute.path}  (✓ ${zahl["ok"]}, ✎ ${zahl["geaendert"]}, ○ ${zahl["offen"]})");
  });
}
