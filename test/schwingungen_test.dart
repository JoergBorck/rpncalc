import 'dart:math';

import 'package:rpncalc/calc/value.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Bibliothek für Schwingungen (library/schwingungen.rpnlib, siehe doc/schwingungen.md),
/// geprüft gegen die Formeln in Dart. Phasen sind im Bogenmaß, unabhängig vom Winkelmodus.
void main() {
  for (final modus in ["rad", "deg", "grd"]) {
    group('im Winkelmodus $modus', () {
      late RpnApi api;

      setUp(() {
        api = RpnApi();
        expect(api.ladeBibliothek("schwingungen"), isNull); // mitgeliefert (doc/api.md 9.1)
        api.eingabe(modus);
      });

      /// Rechnet [eingabe] auf dem leeren Stack und liefert den Stack, der Tos zuletzt.
      List<Wert> rechne(String eingabe) {
        api.eingabe("C");
        final z = api.eingabe(eingabe);
        expect(z.fehler, isNull, reason: "$eingabe: ${z.fehler?.text}");
        expect(api.calculator.variablen, isEmpty, reason: "$eingabe hinterlässt Variablen");
        return [for (int i = api.calculator.stack.tiefe - 1; i >= 0; i--) api.calculator.stack[i]];
      }

      void pruefe(String eingabe, List<num> erwartet) {
        final ist = rechne(eingabe);
        expect(ist.length, erwartet.length, reason: "$eingabe: $ist");
        for (int i = 0; i < ist.length; i++) {
          expect(ist[i], closeTo(erwartet[i], 1e-9), reason: "$eingabe: $ist");
        }
      }

      test('Grundgrößen', () {
        pruefe("50omega", [2 * pi * 50]);
        pruefe("314.159freq", [314.159 / (2 * pi)]);
        pruefe("2per", [pi]);
        pruefe("2:800:eigen", [20]);
        pruefe("0.5pendel", [sqrt(9.81 / 0.5)]);
      });

      test('harmonische Schwingung', () {
        const a = 0.1, w = 4.0, phi = 0.3, t = 1.7;
        pruefe("$a:$w:$phi:$t:hx", [a * cos(w * t + phi)]);
        pruefe("$a:$w:$phi:$t:hv", [-a * w * sin(w * t + phi)]);
        pruefe("$a:$w:$phi:$t:ha", [-a * w * w * cos(w * t + phi)]);
        pruefe("2:$w:$a:hen", [0.5 * 2 * w * w * a * a]);
      });

      test('Amplitude und Phase aus den Anfangswerten', () {
        // x0 = A·cos φ, v0 = −A·ω·sin φ
        const a = 0.25, w = 3.0, phi = -2.1;
        final x0 = a * cos(phi), v0 = -a * w * sin(phi);
        String zahl(double x) => x < 0 ? "~${-x}" : "$x"; // negative Zahlen schreibt der Rechner mit ~
        pruefe("${zahl(x0)}:${zahl(v0)}:$w:hamp", [a, phi]);
        pruefe("0.1:0:2:hamp", [0.1, 0]);
      });

      test('gedämpfte Schwingung: Kenngrößen', () {
        pruefe("2:0.8:delta", [0.2]);
        pruefe("5:0.5:lehr", [0.1]);
        pruefe("5:3:wd", [4]);
        pruefe("5:3:dekr", [2 * pi * 3 / 4]);
        pruefe("5:0.5:guete", [5]);
      });

      /// Lösung von x'' + 2δx' + ω0²x = 0 mit x(0) = x0, x'(0) = v0.
      double ausschwingen(double x0, double v0, double w0, double d, double t) {
        final b = v0 + d * x0, s = w0 * w0 - d * d;
        if (s > 0) return exp(-d * t) * (x0 * cos(sqrt(s) * t) + b / sqrt(s) * sin(sqrt(s) * t));
        if (s < 0) {
          final k = sqrt(-s);
          return exp(-d * t) * (x0 * (exp(k * t) + exp(-k * t)) / 2 + b / k * (exp(k * t) - exp(-k * t)) / 2);
        }
        return exp(-d * t) * (x0 + b * t);
      }

      test('gedämpfte Schwingung: Schwingfall, Grenzfall, Kriechfall', () {
        for (final (w0, d) in [(5.0, 0.5), (2.0, 2.0), (2.0, 3.0)]) {
          for (final t in [0.0, 0.4, 1.3]) {
            pruefe("0.1:~0.3:$w0:$d:$t:dx", [ausschwingen(0.1, -0.3, w0, d, t)]);
          }
        }
        // ohne Dämpfung wie die harmonische Schwingung
        pruefe("0.1:0:4:0:1.7:dx", [0.1 * cos(4 * 1.7)]);
      });

      test('erzwungene Schwingung', () {
        const f0 = 3.0, m = 2.0, w0 = 5.0, d = 0.5, t = 0.9;
        for (final ww in [1.0, 5.0, 8.0]) {
          final n = sqrt(pow(w0 * w0 - ww * ww, 2) + pow(2 * d * ww, 2));
          final phi = atan2(2 * d * ww, w0 * w0 - ww * ww);
          pruefe("$f0:$m:$w0:$d:$ww:famp", [f0 / m / n]);
          pruefe("$w0:$d:$ww:fphase", [phi]);
          pruefe("$f0:$m:$w0:$d:$ww:$t:fx", [f0 / m / n * cos(ww * t - phi)]);
        }
        pruefe("5:0.5:5:fphase", [pi / 2]); // Resonanz: 90° Phasenverschiebung
        pruefe("0.5:0.1:vgr", [1 / sqrt(pow(1 - 0.25, 2) + pow(0.1, 2))]);
        pruefe("1:0.1:vgr", [5]);
        pruefe("5:0.5:wres", [sqrt(25 - 0.5)]);
      });

      test('Winkelmodus bleibt erhalten', () {
        rechne("0.1:4:0.3:1.7:hx");
        expect(api.calculator.angleMode.name, modus == "grd" ? "grad" : modus);
      });
    });
  }
}
