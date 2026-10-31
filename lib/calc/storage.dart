import 'arguments.dart';
import 'core.dart';
import 'value.dart';

/// Variablen, Tags und eigene Funktionen.
///
/// Variablen bestehen aus einem oder mehreren Elementen (Element 0 = beim Anlegen der Tos).
///   n:'!x anlegen (verbraucht n Werte), n:m:'x lesen, n:m:'=x schreiben, n:m:k:'+x usw. ändern,
///   '==x alle Elemente mit dem Tos füllen, n:m:'++x und n:m:'--x um 1 ändern,
///   '~x entfernen, '~~x Geschütztes entfernen (doc/reference.md 8.2).
///   Beim Schreiben und Ändern bleiben die Werte auf dem Stack (wie STO beim HP).
/// Tags sind Adressen von Zellen im Ringpuffer des Stacks (Element 0 = oberste Zelle).
/// Getaggte Zellen sind geschützt, der Stack fährt nicht über sie hinweg.
mixin Speicher on Kern {
  final Map<String, List<Wert>> variablen = {};
  final Map<String, List<int>> tags = {};
  /// Eigene Funktionen: Name -> Code. Angelegt mit {…}':name, aufgerufen wie eine Funktion mit name.
  final Map<String, String> eigeneFunktionen = {};
  /// Funktionen aus Bibliotheken: Name -> Name der Bibliothek. Sie sind geschützt (doc/reference.md 10.6).
  final Map<String, String> herkunft = {};
  /// Namen der Konstanten ('!!x) und der Tags mit Schreibschutz ('||x).
  final Set<String> schreibschutz = {};

  @override
  void reset() {
    super.reset();
    variablen.clear();
    tags.clear();
    tagsAktualisieren();
    eigeneFunktionen.clear();
    herkunft.clear();
  }

  /// Überträgt die Tags auf den Stack und vergisst den Schreibschutz entfernter Namen.
  void tagsAktualisieren() {
    schreibschutz.removeWhere((n) => !tags.containsKey(n) && !variablen.containsKey(n));
    stack.geschuetzt = tags.values.expand((a) => a).toSet();
    stack.schreibgeschuetzt = {for (String n in schreibschutz) ...?tags[n]};
  }

  /// Name eines Tags auf der Adresse, ein Tag mit Schreibschutz zuerst.
  @override
  String tagNameVon(int adresse) {
    List<String> namen = [for (var e in tags.entries) if (e.value.contains(adresse)) e.key];
    return namen.firstWhere(schreibschutz.contains, orElse: () => namen.first);
  }

  // Gemeinsamer Zugriff auf Variablen und Tags: bei Tags liegen die Elemente in den markierten Zellen.
  int? laenge(String v) => variablen[v]?.length ?? tags[v]?.length;
  Wert lies(String v, int i) => variablen.containsKey(v) ? variablen[v]![i] : stack.wertAn(tags[v]![i]);
  void schreib(String v, int i, Wert wert) {
    if (variablen.containsKey(v)) {
      variablen[v]![i] = wert;
    } else {
      stack.setzeAn(tags[v]![i], wert);
    }
  }

  /// Führt ein Variablen-Token aus. [name] beginnt mit dem Modifikator (einfach oder doppelt),
  /// z.B. "~x", "+x", "!!x", "::f", oder nur "x" bzw. "3" (Argument-Zugriff).
  void variable(String name, Argumente a) {
    if (RegExp(r'^[0-9]$').hasMatch(name)) {
      error("arg?", "'$name");
      return;
    }
    String mod = RegExp(r'^[^a-z]*').stringMatch(name)!;
    String v   = name.substring(mod.length);
    if (!["", "!", "!!", "=", "==", "~", "~~", "+", "++", "-", "--", "*", "/", ":", "::"].contains(mod)) {
      error("varOp", "'$mod");
      return;
    }
    switch (mod) {
      case "~" : entfernen(v);
      case "~~": entfernen(v, geschuetzt: true);
      case "!" : anlegen(v, a.ganz(0, 1));
      case "!!": anlegen(v, a.ganz(0, 1), konstante: true);
      case ":" : funktionAblegen(v);
      case "::": funktionAblegen(v, ersetzen: true);
      default  : zugriff(mod, v, a);
    }
  }

  /// '~x entfernt die Variable, den Tag bzw. die eigene Funktion; Werte auf dem Stack bleiben.
  /// Geschütztes (Konstante, Tag mit Schreibschutz, Funktion aus einer Bibliothek) nur mit '~~x ([geschuetzt]).
  void entfernen(String v, {bool geschuetzt = false}) {
    bool? istGeschuetzt = tags.containsKey(v) || variablen.containsKey(v) ? schreibschutz.contains(v)
                        : eigeneFunktionen.containsKey(v) ? herkunft.containsKey(v)
                        : null;
    if (istGeschuetzt == null) {
      error("var?", v);
      return;
    }
    if (istGeschuetzt != geschuetzt) {
      error(istGeschuetzt ? "geschuetzt" : "ungeschuetzt", v);
      return;
    }
    if (tags.remove(v) == null && variablen.remove(v) == null) {
      eigeneFunktionen.remove(v);
      herkunft.remove(v);
    }
    tagsAktualisieren();
  }

  /// ':name nimmt den obersten Block vom Code-Stack und legt ihn als eigene Funktion name ab.
  /// Eine vorhandene eigene Funktion ersetzt nur '::name ([ersetzen]); eingebaute Funktionen und
  /// Funktionen aus Bibliotheken bleiben unangetastet. Im Block einer Bibliothek gehört die Funktion zu ihr;
  /// gibt es den Namen schon (eigene Funktion oder andere Bibliothek), ist das ein Konflikt.
  void funktionAblegen(String name, {bool ersetzen = false}) {
    if (istEingebaut(name)) {
      error("fktName", name);
      return;
    }
    if (name.startsWith("rpn")) {
      error("rpnName", name); // reserviert für das System (doc/reference.md 10.2)
      return;
    }
    String? bibliothek = aktuelleBibliothek;
    String? von = herkunft[name];
    bool vorhanden = eigeneFunktionen.containsKey(name);
    if (bibliothek != null) {
      if (vorhanden && von != bibliothek) { // dieselbe Bibliothek erneut laden ist kein Konflikt
        error("konflikt", von == null ? "$name (eigene Funktion)" : "$name (Bibliothek $von)");
        return;
      }
    } else if (von != null) {
      error("bibFkt", "$name ($von)");
      return;
    } else if (vorhanden && !ersetzen) {
      error("fktDa", name);
      return;
    }
    String? code = codeStack.pull();
    if (code == null) {
      error("code0", "für ':$name");
      return;
    }
    eigeneFunktionen[name] = code;
    if (bibliothek != null) herkunft[name] = bibliothek;
  }

  /// n:'!x legt x mit n Elementen an und verbraucht dafür n Werte vom Stack (Element 0 = Tos),
  /// n:'!!x ebenso als [konstante], die danach nur noch gelesen werden kann.
  /// Eine vorhandene Variable, Konstante oder ein gleichnamiger Tag wird ersetzt.
  void anlegen(String v, int n, {bool konstante = false}) {
    if (n < 1) {
      error("elem", "$v braucht mindestens 1 Element");
      return;
    }
    bool warGeschuetzt = schreibschutz.remove(v);
    List<int>? alterTag = tags.remove(v); // der eigene Tag darf das Verbrauchen nicht blockieren
    tagsAktualisieren();
    if (!kannEntfernen(n)) {
      if (alterTag != null) tags[v] = alterTag;
      if (warGeschuetzt) schreibschutz.add(v);
      tagsAktualisieren();
      return;
    }
    variablen[v] = [for (int i=0; i<n; i++) stack[i]];
    stack.drop(n);
    if (konstante) schreibschutz.add(v);
  }

  /// Lesen, Schreiben und Ändern von Variablen und Tags:
  /// n:m:'x     kopiert m Elemente ab Element n so auf den Stack, dass die Reihenfolge erhalten bleibt,
  /// n:m:'=x    schreibt m Werte vom Stack in die Elemente ab n (Tos -> Element n),
  /// n:m:k:'+x  ändert m Elemente ab n; k = 0 (Standard): je Element ein eigener Wert vom Stack,
  ///            k = 1: der Tos für alle Elemente (gilt auch für '=). Die Werte bleiben auf dem Stack.
  /// '==x       schreibt den Tos in alle Elemente,
  /// n:m:'++x   erhöht m Elemente ab n um 1, n:m:'--x senkt sie.
  void zugriff(String mod, String v, Argumente a) {
    int? len = laenge(v);
    if (len == null) {
      error("var?", mod.isEmpty ? v : "$v (anlegen mit '!)");
      return;
    }
    if (mod.isNotEmpty && variablen.containsKey(v) && schreibschutz.contains(v)) {
      error("konst", v);
      return;
    }
    bool fuellen = mod == "==";
    bool eins = mod == "++" || mod == "--";
    if (fuellen || eins) mod = mod[0];
    int n = fuellen ? 0 : a.ganz(0, 0);
    int m = fuellen ? len : a.ganz(1, 1);
    if (n < 0 || m < 1 || n + m > len) {
      error("elem", "$v hat $len Element(e)");
      return;
    }
    int k = fuellen ? 1 : eins ? 0 : a.ganz(2, 0);
    if (k == m) k = 0;
    if (mod.isNotEmpty && k != 0 && k != 1) {
      error("k", "$k");
      return;
    }
    for (int i = 0; i < m; i++) {
      Wert w = eins ? 1 : (k == 1) ? stack.tos : stack[i]; // Wert vom Stack für Element n+i
      switch (mod) {
        case "=": schreib(v, n+i, w);
        case "+": schreib(v, n+i, lies(v, n+i) + w);
        case "-": schreib(v, n+i, lies(v, n+i) - w);
        case "*": schreib(v, n+i, lies(v, n+i) * w);
        case "/": schreib(v, n+i, lies(v, n+i) / w);
      }
    }
    if (mod == "" && kannAnlegen(m)) {
      for (int i = n+m-1; i >= n; i--) {
        stack.push(lies(v, i)); // tiefstes zuerst, damit die Reihenfolge erhalten bleibt
      }
    }
  }

  /// '|x markiert die Tos-Zelle, n:'|x einen Block aus n Zellen ab dem Tos.
  /// '||x bzw. n:'||x ebenso mit Schreibschutz ([name] beginnt dann mit "|").
  /// Eine gleichnamige Variable, Konstante oder ein alter Tag x wird dabei ersetzt.
  void tagSetzen(String name, Argumente a) {
    bool schutz = name.startsWith("|");
    if (schutz) name = name.substring(1);
    int n = a.ganz(0, 1);
    if (n < 1) {
      error("elem", "$name braucht mindestens 1 Element");
      return;
    }
    variablen.remove(name);
    schreibschutz.remove(name);
    if (schutz) schreibschutz.add(name);
    tags[name] = [for (int i=0; i<n; i++) stack.adr(i)];
    tagsAktualisieren();
  }

  /// Verschiebt die Tags so, wie 'S oder 'R die Werte verschieben ([neuePos]: alte -> neue Position).
  /// Ein Block muss dabei zusammenhängend bleiben, sonst ist es ein Fehler und nichts wird verändert.
  bool tagsVerschieben(Map<int, int> neuePos) {
    Map<String, List<int>> neu = {};
    for (MapEntry<String, List<int>> tag in tags.entries) {
      List<int> pos = [for (int a in tag.value) neuePos[stack.position(a)] ?? stack.position(a)];
      for (int i=1; i<pos.length; i++) {
        if (pos[i] != pos[0] + i) {
          error("block", tag.key);
          return false;
        }
      }
      neu[tag.key] = [for (int p in pos) stack.adr(p)];
    }
    tags.addAll(neu);
    tagsAktualisieren();
    return true;
  }

  /// n:'D entfernt n Elemente samt ihren Tags. Ein Block muss dabei ganz entfernt werden.
  void dropMitTags(int n) {
    Set<int> weg = {for (int i=0; i<n; i++) stack.adr(i)};
    List<String> betroffen = [for (var t in tags.entries) if (t.value.any(weg.contains)) t.key];
    for (String t in betroffen) {
      if (!tags[t]!.every(weg.contains)) {
        error("block", t);
        return;
      }
    }
    betroffen.forEach(tags.remove);
    tagsAktualisieren();
    stack.drop(n);
  }

  /// tgt:src:len:'S tauscht Werte und Tags.
  void swapMitTags(int tgt, int src, int len) {
    Map<int, int> neuePos = {};
    for (int i=0; i<len; i++) {
      neuePos[src+i] = tgt+i;
      neuePos[tgt+i] = src+i;
    }
    if (tagsVerschieben(neuePos)) stack.swap(tgt, src, len);
  }

  /// items:offset:'R bzw. '~R rotiert Werte und Tags.
  void rotMitTags(bool up, int items, int offset) {
    Map<int, int> neuePos = {};
    for (int i=0; i<items; i++) {
      int p = offset + i;
      neuePos[p] = up ? (i == 0 ? offset+items-1 : p-1)   // Tos wandert nach unten, der Rest rückt nach oben
                      : (i == items-1 ? offset : p+1);    // unterstes wandert nach oben, der Rest rückt nach unten
    }
    if (tagsVerschieben(neuePos)) stack.rot(up, items, offset);
  }
}
