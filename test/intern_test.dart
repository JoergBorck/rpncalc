import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Interne Funktionen mit rpnintern (doc/reference.md 10.2, FL-2).
void main() {
  Set<String> intern(Zustand z) => {for (final s in z.speicher) if (s.intern) s.name};

  test('rpnintern kennzeichnet die zuletzt abgelegte Funktion', () {
    final api = RpnApi();
    final z = api.eingabe("{1+}':inc rpnintern");
    expect(z.fehler, isNull);
    expect(intern(z), {"inc"});
    expect(intern(api.eingabe("{2+}':plus")), {"inc"}, reason: "nur die gekennzeichnete");
    expect(api.eingabe("3 inc").stack.first.wert, 4, reason: "aufrufen geht wie bei allen anderen");
  });

  test('ohne abgelegte Funktion ist rpnintern ein Fehler', () {
    expect(RpnApi().eingabe("rpnintern").fehler?.code, "intern");
    expect(RpnApi().eingabe("{1+}':inc'~inc rpnintern").fehler?.code, "intern", reason: "die Funktion ist entfernt");
  });

  test("'::name ersetzt und hebt die Kennzeichnung auf, bis wieder rpnintern folgt", () {
    final api = RpnApi()..eingabe("{1+}':inc rpnintern");
    expect(intern(api.eingabe("{2+}'::inc")), isEmpty);
    expect(intern(api.eingabe("rpnintern")), {"inc"});
    expect(intern(api.eingabe("'~inc{1+}':inc")), isEmpty, reason: "entfernt und neu angelegt");
  });

  test('Funktionen speichern und Export als Bibliothek schreiben rpnintern mit', () {
    final api = RpnApi()..eingabe("{1+}':inc rpnintern")..eingabe("{2+}':plus");
    final skript = api.exportieren(nurFunktionen: true).text;
    expect(skript, contains("{1+}':inc rpnintern"));
    expect(skript, isNot(contains("plus rpnintern")));
    final neu = RpnApi();
    expect(neu.importieren(skript), isNull);
    expect(intern(neu.zustand()), {"inc"});
    expect(api.exportiereBibliothek("meine").text, contains("{1+}':inc rpnintern"));
    expect(api.exportieren().text, contains("{1+}':inc rpnintern"), reason: "auch die ganze Sitzung");
  });

  test('schwingungen: die Hilfsfunktionen sind intern und fehlen nur ohneIntern', () {
    final api = RpnApi();
    final alle = api.bibliotheksFunktionen("schwingungen");
    final tasten = api.bibliotheksFunktionen("schwingungen", ohneIntern: true);
    expect(alle, containsAll(["rw", "wr", "osz", "fpol"]));
    expect(tasten, isNot(anyOf(contains("rw"), contains("wr"), contains("osz"), contains("fpol"))));
    expect(alle.length - tasten.length, 4);
    expect(api.ladeBibliothek("schwingungen"), isNull);
    expect(intern(api.zustand()), {"rw", "wr", "osz", "fpol"});
    expect(api.hilfe("rw"), isNotNull, reason: "in der Hilfe wie alle anderen");
  });

  test('intern im JSON des Zustands; ältere Server ohne das Feld', () {
    final z = RpnApi().eingabe("{1+}':inc rpnintern");
    final s = Zustand.fromJson(z.toJson()).speicher.single;
    expect(s.intern, isTrue);
    final ohne = Map<String, Object?>.of(z.speicher.single.toJson())..remove("intern");
    expect(Speicher.fromJson(ohne).intern, isFalse);
  });
}
