
import '../rpnapi.dart';
import 'pruefung.dart';

class UnittestCalculator {

final List<(int, String, String)> data = [
  // ==========================================
  // GRUNDRECHENARTEN & BASIC MATH (IDs 1-15)
  // ==========================================
  (1, "5 3+", "Stack: ...[0.0] [0.0] [0.0] [8.0]<tos"),     // Addition: 5 + 3
  (2, "10 4-", "Stack: ...[0.0] [0.0] [0.0] [6.0]<tos"),    // Subtraktion: 10 - 4
  (3, "0 7-", "Stack: ...[0.0] [0.0] [0.0] [-7.0]<tos"),    // Negative Ergebnisse
  (4, "4 2.5*", "Stack: ...[0.0] [0.0] [0.0] [10.0]<tos"),  // Multiplikation mit Kommazahl
  (5, "3 ~4*", "Stack: ...[0.0] [0.0] [0.0] [-12.0]<tos"),  // Multiplikation mit negativem Wert
  (6, "12 4/", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),    // Division: 12 / 4
  (7, "5 2/", "Stack: ...[0.0] [0.0] [0.0] [2.5]<tos"),    // Division mit Komma-Ergebnis
  (8, "17 5|/", "Stack: ...[0.0] [0.0] [3.0] [2.0]<tos"),   // Ganzzahl (links) & Rest (am <tos)
  (9, "2 3^", "Stack: ...[0.0] [0.0] [0.0] [8.0]<tos"),     // Potenz: 2³
  (10, "5 0^", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),    // Potenz hoch 0
  (11, "5!", "Stack: ...[0.0] [0.0] [0.0] [120.0]<tos"),    // Fakultät von 5
  (12, "4²", "Stack: ...[0.0] [0.0] [0.0] [16.0]<tos"),     // Quadrat: 4²
  (13, "~3²", "Stack: ...[0.0] [0.0] [0.0] [9.0]<tos"),     // Quadrat von negativer Zahl
  (14, "2³", "Stack: ...[0.0] [0.0] [0.0] [8.0]<tos"),      // Kubik: 2³
  (15, "~2³", "Stack: ...[0.0] [0.0] [0.0] [-8.0]<tos"),    // Kubik von negativer Zahl

  // ==========================================
  // SPEZIELLE OPERATOREN & SPLITS (IDs 16-24)
  // ==========================================
  (16, "12.345|", "Stack: ...[0.0] [0.0] [12.0] [0.345]<tos"), // Truncate: Ganzzahl links, Rest am <tos
  (17, "~5.75|", "Stack: ...[0.0] [0.0] [-5.0] [-0.75]<tos"),  // Truncate mit negativer Zahl
  (18, "15||", "Stack: ...[0.0] [0.0] [0.0] [15.0]<tos"),      // Absolutwert
  (19, "~42||", "Stack: ...[0.0] [0.0] [0.0] [42.0]<tos"),     // Absolutwert von negativ
  (20, "5~", "Stack: ...[0.0] [0.0] [0.0] [-5.0]<tos"),        // Vorzeichenwechsel (~)
  (21, "4~/", "Stack: ...[0.0] [0.0] [0.0] [0.25]<tos"),       // Kehrwert (~/)
  (22, "8 3~^", "Stack: ...[0.0] [0.0] [0.0] [2.0]<tos"),      // Allgemeine Wurzel
  (23, "16~²", "Stack: ...[0.0] [0.0] [0.0] [4.0]<tos"),       // Quadratwurzel
  (24, "27~³", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),       // 3. Wurzel

  // ==========================================
  // PROZENTRECHNUNG (IDs 25-28)
  // ==========================================
  (25, "200 5%", "Stack: ...[0.0] [0.0] [200.0] [10.0]<tos"),   // Basiswert links, Prozentwert am <tos
  (26, "30 15~%", "Stack: ...[0.0] [0.0] [30.0] [200.0]<tos"),  // Basiswertermittlung (~%)
  (27, "500 19|%", "Stack: ...[0.0] [0.0] [405.0] [95.0]<tos"), // Netto-Split: Netto links, MwSt am <tos
  (28, "119 19~|%", "Stack: ...[0.0] [0.0] [100.0] [19.0]<tos"),// Rückwärts-Netto-Split

  // ==========================================
  // KONSTANTEN & FUNKTIONEN (IDs 29-33)
  // ==========================================
  (29, "pi", "Stack: ...[0.0] [0.0] [0.0] [3.14159265359]<tos"),       // Pi (gerundet auf 4 Nachkommastellen)
  (30, "e", "Stack: ...[0.0] [0.0] [0.0] [2.718281828459]<tos"),        // E (gerundet auf 4 Nachkommastellen)
  (31, "0exp", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),        // Exponentialfunktion e^0
  (32, "1exp", "Stack: ...[0.0] [0.0] [0.0] [2.718281828459]<tos"),     // Exponentialfunktion e^1
  (33, "1ln", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),         // Natürlicher Logarithmus ln(1)

  // ==========================================
  // TRIGONOMETRIE & MODI (IDs 34-42)
  // ==========================================
  (34, "deg90sin", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),    // sin(90°)
  (35, "deg0cos", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),     // cos(0°)
  (36, "deg45tan", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),    // tan(45°)
  (37, "rad pi2/sin", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"), // sin(π/2)
  (38, "rad pi cos", "Stack: ...[0.0] [0.0] [0.0] [-1.0]<tos"), // cos(π)
  (39, "grd100sin", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),    // sin(100 gon)
  (40, "deg1~sin", "Stack: ...[0.0] [0.0] [0.0] [90.0]<tos"),   // asin(1)
  (41, "deg0~cos", "Stack: ...[0.0] [0.0] [0.0] [90.0]<tos"),   // acos(0)
  (42, "deg1~tan", "Stack: ...[0.0] [0.0] [0.0] [45.0]<tos"),   // atan(1)

  // ==========================================
  // STACK-BEFEHLE & TRENNER (IDs 43-51)
  // ==========================================
  (43, "5 10C", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),       // Clear (C)
  (44, "1 2 3D", "Stack: ...[0.0] [0.0] [1.0] [2.0]<tos"),      // Drop (D): Löscht das oberste Element (3)
  (45, "7 8S", "Stack: ...[0.0] [0.0] [8.0] [7.0]<tos"),        // Swap (S): Tauscht 7 und 8
  (46, "1 2 3R", "Stack: ...[0.0] [2.0] [3.0] [1.0]<tos"),      // ROLL <: Holt das 3. Element (1) nach ganz rechts / oben in den tos
  (47, "1 2 3~R", "Stack: ...[0.0] [3.0] [1.0] [2.0]<tos"),     // ROLL >: Schiebt das oberste Element (3) an 3. Stelle 
  (48, "5 ", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),          // Leerzeichen am Zeilenende: Enter bleibt vorgemerkt
  (49, "2 3 *", "Stack: ...[0.0] [0.0] [2.0] [9.0]<tos"),       // Kette: 2 bleibt links, Ergebnis 9 wandert an den <tos
  (50, "10 2/5+", "Stack: ...[0.0] [0.0] [0.0] [10.0]<tos"),    // Kette: 10/2 = 5 -> 5+5 = 10
  (51, "deg30sin2*", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),  // Kombi: sin(30°) = 0.5 -> 0.5 * 2 = 1.0

  // ==========================================
  // DMS (IDs 52-58)
  // ==========================================
  (52, "12.3456789dms", "Stack: ...[0.0] [12.0] [20.0] [44.44404]<tos"), // d=12, m=20, s=44.444 am <tos
  (53, "45.75dms", "Stack: ...[0.0] [45.0] [45.0] [0.0]<tos"),
  (54, "~12.3456789dms", "Stack: ...[0.0] [-12.0] [20.0] [44.44404]<tos"),
  (55, "0.0002777778dms", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),
  (56, "rad pi dms", "Stack: ...[0.0] [180.0] [0.0] [0.0]<tos"),
  (57, "rad 1dms", "Stack: ...[0.0] [57.0] [17.0] [44.806247]<tos"),
  (58, "90dms", "Stack: ...[0.0] [90.0] [0.0] [0.0]<tos"),

  // ==========================================
  // ARGUMENTE ÜBER ":" (IDs 59-71), Positionen zählen ab 0 (Tos)
  // ==========================================
  (59, "1 2 3 2:S", "Stack: ...[0.0] [3.0] [2.0] [1.0]<tos"),          // tgt=2: tauscht Position 0 und 2
  (60, "8 4 5 2: S", "Stack: ...[8.0] [5.0] [5.0] [4.0]<tos"),         // ":" nimmt die 2, Leerzeichen dupliziert die 5
  (61, "1 2 3 4 2:0:2:S", "Stack: ...[3.0] [4.0] [1.0] [2.0]<tos"),    // tgt=2, src=0, len=2
  (62, "1 2 3 4 2 0 2:::S", "Stack: ...[3.0] [4.0] [1.0] [2.0]<tos"),  // dasselbe, Argumente vom Stack (umgekehrte Reihenfolge)
  (63, "1 2 3 4 5 3:D", "Stack: ...[0.0] [0.0] [1.0] [2.0]<tos"),      // n=3: entfernt 3 Elemente
  (64, "7 8 9 3:degS", "Stack: ...[0.0] [7.0] [9.0] [8.0]<tos"),       // deg verbraucht die Argumente, S tauscht ohne
  (65, "1 2 3 2:5+S", "Stack: ...[0.0] [8.0] [2.0] [1.0]<tos"),        // Operatoren verbrauchen keine Argumente
  (66, "1 2 3 2.9:S", "Stack: ...[0.0] [3.0] [2.0] [1.0]<tos"),        // Funktion wandelt um: 2.9 -> 2
  (67, "1 2 3 4 4:R", "Stack: ...[2.0] [3.0] [4.0] [1.0]<tos"),        // items=4: das 4. Element kommt in den Tos
  (68, "1 2 3 4 4:~R", "Stack: ...[4.0] [1.0] [2.0] [3.0]<tos"),       // items=4: der Tos kommt an 4. Stelle
  (69, "1 2 3 4 3:1:R", "Stack: ...[2.0] [3.0] [1.0] [4.0]<tos"),      // offset=1: Tos bleibt, darunter wird rotiert
  (70, "1 2 3 4 3:1:~R", "Stack: ...[3.0] [1.0] [2.0] [4.0]<tos"),     // offset=1, Gegenrichtung
  (71, "1 2 3 2:R", "Stack: ...[0.0] [1.0] [3.0] [2.0]<tos"),          // items=2 entspricht Swap

  // ==========================================
  // LEERZEICHEN ZWISCHEN IDENTIFIERN (IDs 72-73)
  // ==========================================
  (72, "pi deg deg", "Stack: ...[0.0] [0.0] [0.0] [3.14159265359]<tos"), // Funktion ␣ Funktion: kein dup
  (73, "7'!x_5 'x deg", "Stack: ...[0.0] [5.0] [5.0] [7.0]<tos"),        // Zahl ␣ Variable: dup, Variable ␣ Funktion: kein dup
  (74, "5  ", "Stack: ...[0.0] [0.0] [5.0] [5.0]<tos"),                  // das zweite Leerzeichen löst das erste Enter aus, das zweite bleibt vorgemerkt
  (75, "2 sin S", "Stack: ...[0.0] [2.0] [0.034899496703] [0.034899496703]<tos"), // Zahl ␣ Funktion und Funktion ␣ Befehl: jeweils dup

  // ==========================================
  // DEMO SCHIEFE EBENE, siehe doc/demo.md (IDs 76-77)
  // ==========================================
  (76, "deg50 30 0.2R 9.81*4:R sinScos5:R*-*S/", "Stack: ...[0.0] [0.0] [0.0] [3.205858157775]<tos"), // nur mit dem Stack
  (77, "deg 50'!m 'm9.81*'!fg 'fg30sin*'!fh 'fg30cos*0.2*'!fr 'fh 'fr-'m/",
       "Stack: ...[0.0] [0.0] [0.0] [3.205858157775]<tos"), // mit Variablen, '!x verbraucht den Wert

  // ==========================================
  // RECHENFEHLER (IDs 78-)
  // ==========================================
  (78, "7 5 0|/", "Stack: ...[0.0] [7.0] [5.0] [0.0]<tos"),   // Division durch 0: Fehler, Stack bleibt erhalten
  (79, "1'q", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),       // Variable nicht definiert: Fehler, Stack bleibt
  (80, "2':x", "Stack: ...[0.0] [0.0] [0.0] [2.0]<tos"),      // Operator für Variablen nicht erlaubt
  (81, "3'1", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),       // Argument-Zugriff außerhalb von Code-Blöcken

  // ==========================================
  // VARIABLEN (IDs 82-)
  // ==========================================
  (82, "5'!a 'a 'a+", "Stack: ...[0.0] [0.0] [0.0] [10.0]<tos"),     // anlegen verbraucht, lesen
  (83, "3'!a 4'+a 'a", "Stack: ...[0.0] [0.0] [4.0] [7.0]<tos"),      // '+a addiert den Tos, Tos bleibt stehen
  (84, "10'!a 4'-a 2'*a 3'/a 'a", "Stack: ...[2.0] [2.0] [3.0] [4.0]<tos"), // (10-4)*2/3 = 4
  (85, "7'!a 'a 'a", "Stack: ...[0.0] [0.0] [7.0] [7.0]<tos"),        // Variable ␣ Variable: kein dup

  // ==========================================
  // TAGS (IDs 86-)
  // ==========================================
  (86, "7'|t 1 2 't", "Stack: ...[1.0] [2.0] [2.0] [7.0]<tos"),       // Tag setzen und lesen
  (87, "7'|t+", "Stack: ...[0.0] [0.0] [0.0] [7.0]<tos"),             // Fehler: Tag blockiert, Stack bleibt
  (88, "5 7'|tD", "Stack: ...[0.0] [0.0] [5.0] [7.0]<tos"),           // Fehler: D darf getaggte Zelle nicht entfernen
  (89, "5 7'|t'D", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),          // 'D entfernt Wert und Tag
  (90, "5'|tC", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),             // Fehler: C bei vorhandenen Tags
  (91, "5'|t'C", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),            // 'C löscht Stack und Tags
  (92, "1 2 3 3:'|v1:2:'v", "Stack: ...[2.0] [3.0] [1.0] [2.0]<tos"), // Block lesen, Reihenfolge bleibt erhalten
  (93, "5'|t 9'=t 't", "Stack: ...[9.0] [5.0] [9.0] [9.0]<tos"),      // '=t schreibt direkt in die Zelle
  (94, "1 2'|t 'S'D", "Stack: ...[0.0] [0.0] [1.0] [2.0]<tos"),       // Tag lösen, Wert behalten
  (95, "1 2'|tS 't", "Stack: ...[2.0] [1.0] [1.0] [1.0]<tos"),        // S: Tag bleibt an der Adresse
  (96, "1 2'|t'S 't", "Stack: ...[2.0] [1.0] [1.0] [2.0]<tos"),       // 'S: Tag wandert mit dem Wert
  (97, "1 2 3'|t'R 't", "Stack: ...[3.0] [1.0] [1.0] [3.0]<tos"),     // 'R: Tag wandert mit dem Wert
  (98, "1 2 3 4 2:'|v3:1:'R", "Stack: ...[1.0] [2.0] [3.0] [4.0]<tos"), // Fehler: 'R würde den Block zerteilen
  (99, "1 2 3 2:'|v'D", "Stack: ...[0.0] [1.0] [2.0] [3.0]<tos"),     // Fehler: Block nur als Ganzes entfernen
  (100, "1 2 3 2:'|v2:'D", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),  // Block als Ganzes entfernen
  (101, "1 2 3 2:'|v'R", "Stack: ...[0.0] [2.0] [3.0] [1.0]<tos"),    // 'R verschiebt den Block als Ganzes
  (102, "deg 50'|m 9.81*'|fg 30sin*'|fh 'fg 30cos*0.2*'|fr 'fh 'fr-'m/",
        "Stack: ...[245.25] [490.5] [84.957092111253] [3.205858157775]<tos"), // Demo schiefe Ebene mit Tags

  // ==========================================
  // VARIABLEN UND TAGS ENTFERNEN MIT '~ (IDs 103-)
  // ==========================================
  (103, "5'!a'~a 'a", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),      // Fehler: a wurde entfernt
  (104, "5 7'|t'~t+", "Stack: ...[0.0] [0.0] [0.0] [12.0]<tos"),     // Tag entfernt, Wert bleibt und ist wieder frei
  (105, "1 2 3 3:'|v'~vD", "Stack: ...[0.0] [0.0] [1.0] [2.0]<tos"), // ganzer Block-Tag entfernt
  (106, "4'~q", "Stack: ...[0.0] [0.0] [0.0] [4.0]<tos"),            // Fehler: q gibt es nicht

  // ==========================================
  // ANLEGEN, ZUWEISEN, VEKTOREN (IDs 107-)
  // ==========================================
  (107, "5'=q", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),                    // Fehler: q nicht angelegt
  (108, "1'!a 2'!a 'a", "Stack: ...[0.0] [0.0] [0.0] [2.0]<tos"),            // erneutes Anlegen ersetzt a
  (109, "1 2 3 3:'!v 1:2:'v", "Stack: ...[0.0] [0.0] [1.0] [2.0]<tos"),      // Vektor anlegen, Elemente 1..2 lesen
  (110, "1 2 3 3:'!v 7 8 0:2:'=v 0:3:'v", "Stack: ...[8.0] [1.0] [7.0] [8.0]<tos"), // zwei Elemente zuweisen
  (111, "1 2 3 3:'!v 10 20 30 0:3:'+v 0:3:'v", "Stack: ...[30.0] [11.0] [22.0] [33.0]<tos"), // elementweise
  (112, "1 2 3 3:'!v 10 0:3:1:'*v 0:3:'v", "Stack: ...[10.0] [10.0] [20.0] [30.0]<tos"),    // ein Wert für alle
  (113, "1 2 3 3:'!v 5 0:3:2:'+v", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),  // Fehler: k nur 0 oder 1
  (114, "1'!a 5 1:'=a", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),            // Fehler: Element 1 gibt es nicht
  (115, "5'|t 7'!t 't+", "Stack: ...[0.0] [0.0] [5.0] [12.0]<tos"),          // '!t ersetzt den Tag durch eine Variable

  // ==========================================
  // LOGARITHMUS UND ZUFALLSZAHLEN (IDs 116-)
  // ==========================================
  (116, "100log", "Stack: ...[0.0] [0.0] [0.0] [2.0]<tos"),                  // log zur Basis 10
  (117, "8 2:log", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),                 // b:log, hier log2
  (118, "2~log", "Stack: ...[0.0] [0.0] [0.0] [100.0]<tos"),                 // Umkehrfunktion 10^x
  (119, "3 2:~log", "Stack: ...[0.0] [0.0] [0.0] [8.0]<tos"),                // b:~log = b^x
  (120, "1~ln", "Stack: ...[0.0] [0.0] [0.0] [2.718281828459]<tos"),         // Umkehrfunktion e^x
  // Zufallszahlen: mit seed reproduzierbar (Werte des Dart-Zufallsgenerators)
  (121, "42seed rnd", "Stack: ...[0.0] [0.0] [0.0] [0.150925455978]<tos"),   // Zahl in [0, 1)
  (122, "42seed 10:20:rnd", "Stack: ...[0.0] [0.0] [0.0] [10.0]<tos"),       // ganze Zahl von 10 bis 20
  (123, "6:1:rnd", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),                 // Fehler: ungültiger Bereich

  // ==========================================
  // RUNDEN: stellen:art:round (IDs 124-)
  // ==========================================
  (124, "~2.5round", "Stack: ...[0.0] [0.0] [0.0] [-3.0]<tos"),              // kaufmännisch (Standard)
  (125, "~2.5 0:1:round", "Stack: ...[0.0] [0.0] [0.0] [-2.0]<tos"),         // aufrunden Richtung +∞
  (126, "2.7 0:~1:round", "Stack: ...[0.0] [0.0] [0.0] [2.0]<tos"),          // abrunden Richtung −∞
  (127, "2.5 0:2:round", "Stack: ...[0.0] [0.0] [0.0] [2.0]<tos"),           // bei ,5 auf gerade Ziffer
  (128, "2.5 0:~2:round", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),          // bei ,5 auf ungerade Ziffer
  (129, "~2.1 0:3:round", "Stack: ...[0.0] [0.0] [0.0] [-3.0]<tos"),         // vom Nullpunkt weg
  (130, "~2.7 0:~3:round", "Stack: ...[0.0] [0.0] [0.0] [-2.0]<tos"),        // zum Nullpunkt hin (abschneiden)
  (131, "3.14159 2:round", "Stack: ...[0.0] [0.0] [0.0] [3.14]<tos"),        // 2 Nachkommastellen
  (132, "1234 ~2:round", "Stack: ...[0.0] [0.0] [0.0] [1200.0]<tos"),        // negative Stellen: auf Hunderter
  (133, "2.675 2:round", "Stack: ...[0.0] [0.0] [0.0] [2.68]<tos"),          // Fließkommafehler 267.4999... abgefangen
  (134, "2.5 0:5:round", "Stack: ...[0.0] [0.0] [0.0] [2.5]<tos"),           // Fehler: unbekannte Art, Wert bleibt
  (135, "5 42seed~seed", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),           // ~seed hebt den Seed auf, Stack bleibt unverändert

  // ==========================================
  // UNBEKANNTE NAMEN (IDs 136-)
  // ==========================================
  (136, "5sni", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),                    // Fehler: unbekannte Funktion
  (137, "5 3~~", "Stack: ...[0.0] [0.0] [5.0] [3.0]<tos"),                   // Fehler: unbekannter Operator (~~ ist frei)
  (138, "1Q", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),                      // Fehler: unbekannter Befehl

  // ==========================================
  // KOORDINATEN: x y ° -> r φ, r φ ~° -> x y (IDs 139-)
  // ==========================================
  (139, "3 4°", "Stack: ...[0.0] [0.0] [5.0] [53.130102354156]<tos"),        // kartesisch nach polar (deg)
  (140, "3 4°~°", "Stack: ...[0.0] [0.0] [3.0] [4.0]<tos"),                  // und zurück
  (141, "rad 1 1°", "Stack: ...[0.0] [0.0] [1.414213562373] [0.785398163397]<tos"), // Winkel im Modus rad
  (142, "2 90~°", "Stack: ...[0.0] [0.0] [0.0] [2.0]<tos"),                  // polar nach kartesisch

  // ==========================================
  // KOPIEREN: quelle:anzahl:Y (IDs 143-)
  // ==========================================
  (143, "1 2 3Y", "Stack: ...[1.0] [2.0] [3.0] [2.0]<tos"),                  // Over
  (144, "1 2 3 0:Y", "Stack: ...[1.0] [2.0] [3.0] [3.0]<tos"),               // wie dup
  (145, "1 2 3 2:Y", "Stack: ...[1.0] [2.0] [3.0] [1.0]<tos"),               // Pick
  (146, "1 2 3 1:2:Y", "Stack: ...[2.0] [3.0] [1.0] [2.0]<tos"),             // zwei Elemente, Reihenfolge bleibt
  (147, "5 6YY", "Stack: ...[5.0] [6.0] [5.0] [6.0]<tos"),                   // YY verdoppelt ein Paar
  (148, "1 2 3 5:Y", "Stack: ...[0.0] [1.0] [2.0] [3.0]<tos"),               // Fehler: Position außerhalb des Füllstands

  // ==========================================
  // CODE-STACK, ':name UND TRENNER _ (IDs 149-)
  // ==========================================
  (149, "5{1 2+}", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),                 // Block auf den Code-Stack, Werte-Stack unberührt
  (150, "5 {1}", "Stack: ...[0.0] [0.0] [5.0] [5.0]<tos"),                   // Leerzeichen vor dem Block wirkt als Enter
  (151, "7':pq", "Stack: ...[0.0] [0.0] [0.0] [7.0]<tos"),                   // Fehler: Code-Stack leer
  (152, "3{1}':sin", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),               // Fehler: eingebaute Funktion
  (153, "1_2+", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),                    // _ trennt nur, kein Enter
  (154, "4_ 5+", "Stack: ...[0.0] [0.0] [0.0] [9.0]<tos"),                   // _ ist für die Leerzeichen-Regel unsichtbar: Zahl ␣ Zahl

  // ==========================================
  // EIGENE FUNKTIONEN AUSFÜHREN (IDs 155-)
  // ==========================================
  (155, "{1 2+}':f f", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),             // definieren und aufrufen
  (156, "{S2/~ ²R-~²YY-~R+}':pq 5 6pq", "Stack: ...[0.0] [0.0] [-3.0] [-2.0]<tos"), // pq-Formel: x² + 5x + 6
  (157, "{~:~:-}':sub 10:3:sub", "Stack: ...[0.0] [0.0] [0.0] [7.0]<tos"),   // ~: holt die Argumente von vorn
  (158, "{|:}':n 1:2:3:n", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),         // |: Anzahl der Argumente
  (159, "{~:|:}':m 1:2:m", "Stack: ...[0.0] [0.0] [1.0] [1.0]<tos"),         // |: zählt nur die übrigen
  (160, "{~|:}':alle 1:2:3:alle", "Stack: ...[0.0] [1.0] [2.0] [3.0]<tos"),  // ~|: alle Argumente auf einmal
  (161, "{1+}':inc {inc inc}':two 5two", "Stack: ...[0.0] [0.0] [0.0] [7.0]<tos"), // Funktionen rufen Funktionen auf
  (162, "{'q}':f 4f", "Stack: ...[0.0] [0.0] [0.0] [4.0]<tos"),              // Fehler im Code: "Fehler in f: …"
  (163, "{r}':r r", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),                // Fehler: Endlos-Rekursion wird abgefangen
  (164, "~:", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),                      // Fehler: Argumente nur in eigenen Funktionen

  // ==========================================
  // VERGLEICHE UND LOGIK: 1 = wahr, 0 = falsch (IDs 165-)
  // ==========================================
  (165, "1 2<", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),
  (166, "2 1<", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),
  (167, "2 2=", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),
  (168, "2 2~=", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),                   // ungleich
  (169, "3 2~<", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),                   // größer oder gleich
  (170, "2 3~>", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),                   // kleiner oder gleich
  (171, "2 3&", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),                    // und: alles außer 0 ist wahr
  (172, "1 0&", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),
  (173, "1 0~&", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),                   // oder

  // ==========================================
  // KONTROLLSTRUKTUREN: X, if, ifel, loop (IDs 174-)
  // ==========================================
  (174, "{5}X", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),                    // obersten Block ausführen
  (175, "3:5:{~:~:-}X", "Stack: ...[0.0] [0.0] [0.0] [-2.0]<tos"),           // X mit Argumenten
  (176, "1{7}if", "Stack: ...[0.0] [0.0] [0.0] [7.0]<tos"),                  // wahr: ausführen, Wert verbraucht
  (177, "3 0{7}if", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),                // falsch: nichts ausführen
  (178, "1{7}{8}ifel", "Stack: ...[0.0] [0.0] [0.0] [7.0]<tos"),
  (179, "0{7}{8}ifel", "Stack: ...[0.0] [0.0] [0.0] [8.0]<tos"),
  (180, "{7}{1}Xif", "Stack: ...[0.0] [0.0] [0.0] [7.0]<tos"),               // Bedingung als Block
  (181, "0{1+0:Y5<}loop", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),          // zählt bis 5
  (182, "1if", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),                     // Fehler: kein Block, Wert bleibt
  (183, "1{7}ifel", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),                // Fehler: ifel braucht zwei Blöcke

  // ==========================================
  // BEFEHLE FÜR DEN CODE-STACK (IDs 184-)
  // ==========================================
  (184, "{1}{2}codeswapX", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),         // getauscht: {1} liegt oben
  (185, "{1}{2}codedropX", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),         // {2} entfernt
  (186, "{1}codedupXX", "Stack: ...[0.0] [0.0] [1.0] [1.0]<tos"),            // kopiert, zweimal ausgeführt
  (187, "{1}{2}codeoverX", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),         // Kopie von {1} nach oben
  (188, "{1}{2}{3}2:codedupX", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),     // die beiden obersten kopiert
  (189, "codedrop", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),                // Fehler: Code-Stack leer
  // ==========================================
  // KONSTANTEN '!!x UND TAGS MIT SCHREIBSCHUTZ '||x (IDs 190-)
  // ==========================================
  (190, "9.81'!!g_'g", "Stack: ...[0.0] [0.0] [0.0] [9.81]<tos"),
  (191, "9.81'!!g_5'=g", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),          // Fehler: Konstante nur lesen
  (192, "9.81'!!g_5'!g_1'+g_D'g", "Stack: ...[0.0] [0.0] [0.0] [6.0]<tos"), // '!g hebt den Schutz auf
  (193, "1'||t_2S", "Stack: ...[0.0] [0.0] [1.0] [2.0]<tos"),               // Fehler: S ändert die Zelle von t
  (194, "1'||t_2'S", "Stack: ...[0.0] [0.0] [2.0] [1.0]<tos"),              // 'S nimmt den Tag mit
  (195, "1'||t_2'+t_D'||t~", "Stack: ...[0.0] [0.0] [0.0] [3.0]<tos"),      // über den Namen erlaubt, ~ nicht
  (196, "{~|:~|:}':f 1:2:f", "Stack: ...[1.0] [2.0] [1.0] [2.0]<tos"),        // ~|: lässt die Argumente in der Liste
  (197, "{~|:|:}':g 4:5:g", "Stack: ...[0.0] [4.0] [5.0] [2.0]<tos"),        // |: zählt nach ~|: weiter
  (198, "5:{~|: *}times", "Stack: ...[1.0] [4.0] [9.0] [16.0]<tos"),         // times: Index als Argument
  (199, "0_5:{~|:+}times", "Stack: ...[0.0] [0.0] [0.0] [10.0]<tos"),        // Summe der Indizes 0 bis 4
  (200, "7_0:{1}times", "Stack: ...[0.0] [0.0] [0.0] [7.0]<tos"),            // 0 Durchläufe
  (201, "2.5:{1}times", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),            // Fehler: Anzahl keine ganze Zahl
  (202, "0{1+ 5<}loop", "Stack: ...[0.0] [0.0] [0.0] [5.0]<tos"),            // loop zählt bis 5
  (203, "90cos_180sin_270cos", "Stack: ...[0.0] [0.0] [0.0] [0.0]<tos"),    // Viertelkreise exakt, ohne Rest
  (204, "~90sin_450sin_180tan", "Stack: ...[0.0] [-1.0] [1.0] [0.0]<tos"),  // auch negativ und über 360°
  (205, "90tan", "Stack: ...[0.0] [0.0] [0.0] [Infinity]<tos"),             // Polstelle
  (206, "grd 100cos_rad pi cos", "Stack: ...[0.0] [0.0] [0.0] [-1.0]<tos"), // gon und Bogenmaß
  (207, "2 180~°", "Stack: ...[0.0] [0.0] [-2.0] [0.0]<tos"),               // polar nach kartesisch exakt
  (208, "1ê~30_1ê30*", "Stack: ...[0.0] [0.0] [0.0] [1.0]<tos"),            // kleine Zahlen gehen nicht verloren
];


  /// Jeder Fall startet mit einem zurückgesetzten Rechner und vergleicht die obersten 4 Stack-Werte.
  List<Pruefung> pruefe() {
    RpnApi api = RpnApi();
    return [
      for (var (id, eingabe, erwartet) in data) () {
        api.reset();
        api.eingabe(eingabe);
        return Pruefung("$id", eingabe, erwartet, api.testString());
      }()
    ];
  }

  bool test() => ausgeben("Rechner", pruefe());
}