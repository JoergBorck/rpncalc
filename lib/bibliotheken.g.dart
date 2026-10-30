// Erzeugt von tool/bibliotheken.dart aus library/*.rpnlib, nicht von Hand ändern (doc/api.md 9.1).

/// Die mitgelieferten Bibliotheken: Name → Text der .rpnlib-Datei.
const Map<String, String> mitgelieferteBibliotheken = {
  "schwingungen": r'''{
{{"version":{"name":"schwingungen","bibliothek":"1.0.0","rechner":"0.1.0"}}}rpnjson
{~1_acos*pi/}':rw
{~1_acos/pi*}':wr
{2*pi*}':omega
{2/pi/}':freq
{~/2*pi*}':per
{~:~:S/~²}':eigen
{9.81S/~²}':pendel
{~:~:~:~:R*+rw_cos*}':hx
{~:~:~:~:2:Y*+rw_sin**~}':hv
{~:~:~:~:2:Y*+rw_cos_S²**~}':ha
{~:~:~:/~_°wr}':hamp
{~:~:~:*²*2/}':hen
{~:~:S/2/}':delta
{~:~:S/}':lehr
{~:²~:²-~²}':wd
{~|:S::wd~:D~:S/2*pi*}':dekr
{~:~:2*/}':guete
{Y0>{S~²0:YR*rw_1S~°R/}{Y0<{S~_~²0:YR*exp0:Y~/0:2:Y+2/3:~R-2/R/}{SD1S}ifel}ifel}':osz
{~|:2:Y²2:Y²-Y_osz3:Y7:Y*6:Y+*S6:Y*+1:Y3:Y*~_exp*6:~R5:D}':dx
{~|:R²Y²-~R*2*°wr}':fpol
{~::~::~::fpol_SD}':fphase
{~:~:/~::~::~::fpol_D/}':famp
{~:~:/~|:*3:~R2:D~::~::~::fpol_RS-rw_cos~R/*}':fx
{~:~:Y*2*S²1S-S°D~/}':vgr
{~:²~:²2*-~²}':wres
}
''',
  "statistik": r'''{
{{"version":{"name":"statistik","bibliothek":"1.0.0","rechner":"0.1.0"}}}rpnjson
{0 0 0 0 0 0 6:'!ss}':sclr
{'!tx'!ty'tx'ty*_'ty²_'ty_'tx²_'tx_1_0:6:'+ss_6:D'~tx'~ty_0:'ss}':sadd
{~::{sadd_D}times_0:'ss}':sall
{~::'ss_~::'ss*_0:'ss/~_~::'ss+}':sq
{3:'ss_0:'ss/_1:'ss_0:'ss/}':mean
{3:3:4:sq_0:'ss1-/~²_1:1:2:sq_0:'ss1-/~²}':sdev
{1:3:5:sq_1:1:2:sq_3:3:4:sq*~²/}':corr
{1:3:5:sq_1:1:2:sq/0:Y_1:'ss_0:'ss/*_3:'ss_0:'ss/S-}':lr
{lr_SR*+}':yhat
{lr_RS-S/}':xhat
}
''',
};

/// Systemdateien aus library/system, z.B. die eingebaute Hilfe; sie erscheinen nicht unter den Bibliotheken.
const Map<String, String> systemBibliotheken = {
  "hilfe.de": r'''{
{{"version":{"name":"hilfe","bibliothek":"1.0.0","rechner":"0.1.0"}}}rpnjson
{{"hilfe":[
{"kennung":"#","titel":"Hilfe zum RPN-Rechner","text":"Der Rechner arbeitet mit umgekehrter polnischer Notation: erst die Zahlen, dann die Operation. \"3 4+\" ergibt 7.\nThemen: [[#zahlen]], [[#trenner]], [[#enter]], [[#stack]], [[#argumente]], [[#namen]], [[#variablen]], [[#tags]], [[#funktionen]], [[#code]], [[#winkel]], [[#fehler]]\nDas Leerzeichen wirkt als Enter: [[ ]]\nÜbersicht: [[#alle]]"},
{"kennung":"#zahlen","titel":"Zahlen","verwendungen":[{"schreibweise":"42","kurz":"ganze Zahl"},{"schreibweise":"3.14","kurz":"Dezimalzahl, auch .5 und 5."},{"schreibweise":"~7","kurz":"negative Zahl"},{"schreibweise":"1.5ê3","kurz":"mit Exponent"}],"text":"`~` ist das Vorzeichen, weil `-` subtrahiert; `ê` leitet den Exponenten ein, weil `e` die Eulersche Zahl ist. Ein zweiter Punkt beginnt eine neue Zahl: \"1.2.3\" ergibt [1.2 0.3]. Siehe [[~]], [[ê]]."},
{"kennung":"#trenner","titel":"Trenner","verwendungen":[{"schreibweise":"␣","kurz":"trennt und wirkt als Enter"},{"schreibweise":"_","kurz":"trennt nur"}],"text":"Ein Trenner ist nur nötig, wenn zwei Token gleicher Art sonst verschmelzen würden: \"12\" ist zwölf, \"1_2\" sind 1 und 2. Zeilenende wirkt wie _. Siehe [[#enter]], [[_]]."},
{"kennung":"#enter","titel":"Leerzeichen als Enter","text":"Das Leerzeichen arbeitet wie die Enter-Taste beim HP: Es legt eine Kopie des Tos an, die eine folgende Zahl ersetzt. \"3 4+\" ergibt 7, \"5 *\" ergibt 25, \"1  2\" ergibt [1 1 2]. Zwischen zwei Zahlen und zwischen zwei Namen trennt es nur. Zum reinen Trennen gibt es [[_]]. Siehe [[#trenner]]."},
{"kennung":"#stack","titel":"Stack","text":"Der Stack hält die Werte, der oberste heißt Tos (Position 0). Zahlen kommen oben drauf, Operationen nehmen ihre Werte von oben und legen das Ergebnis zurück. Stackbefehle: [[C]], [[D]], [[S]], [[R]], [[Y]]. Siehe [[#tags]], [[#argumente]]."},
{"kennung":"#argumente","titel":"Argumente","text":"Mit [[:]] übergibt man den Tos als Argument, der nächste Name verbraucht alle Argumente. Zahlen und Operatoren verbrauchen keine, man kann also dazwischen rechnen: \"2 3+:D\" übergibt 5. Jeder Name legt fest, was seine Argumente bedeuten, und hat Standardwerte, z.B. [[S]] tgt:src:len (1:0:1)."},
{"kennung":"#namen","titel":"Namen","text":"Funktionen, Variablen und Tags heißen aus Kleinbuchstaben, Befehle aus einem Großbuchstaben (D, S …). Ein Name endet am ersten Zeichen, das kein Kleinbuchstabe ist: \"deg50\" ist deg und 50. Variablen, Konstanten und Tags teilen sich die Namen, Funktionen haben eigene. Siehe [[']]."},
{"kennung":"#variablen","titel":"Variablen und Konstanten","text":"Variablen speichern Werte außerhalb des Stacks, als Vektor aus einem oder mehreren Elementen. Anlegen mit '!x, lesen mit 'x, schreiben mit '=x, ändern mit '+x '-x '*x '/x, entfernen mit '~x. Eine Konstante ('!!x) kann nach dem Anlegen nur gelesen werden. \"9.81'!!g\" legt g an. Siehe [[']], [[#tags]]."},
{"kennung":"#tags","titel":"Tags","text":"Ein Tag markiert eine Zelle des Stacks, damit man ein Zwischenergebnis wiederfindet, ohne mitzuzählen. Markieren mit '|x, lesen und ändern wie Variablen. Getaggte Zellen sind geschützt: Was sie verbrauchen würde, ist ein Fehler. Mit '||x auch gegen S und R geschützt. Stackbefehle mit ' davor nehmen die Tags mit. Siehe [[|]], [[#variablen]]."},
{"kennung":"#funktionen","titel":"Eigene Funktionen","verwendungen":[{"schreibweise":"\u007b…\u007d':name","kurz":"legt den obersten Block als Funktion name ab"},{"schreibweise":"name","kurz":"ruft die Funktion auf"},{"schreibweise":"'~name","kurz":"entfernt die Funktion"}],"text":"Im Code liest man die Argumente des Aufrufs mit ~: ~|: |: ([[:]]). \"\u007b~:~:-\u007d':sub\" und dann \"10:3:sub\" ergibt 7. Siehe [[#code]]."},
{"kennung":"#code","titel":"Code-Blöcke und Kontrollstrukturen","text":"Ein Block \u007b…\u007d landet auf dem Code-Stack und wird erst bei der Ausführung geprüft. Ausführen mit [[X]], Bedingungen mit [[if]], Schleifen mit [[loop]] und [[times]], ablegen als [[#funktionen]]. Den Code-Stack verwalten [[codedrop]] und seine Verwandten."},
{"kennung":"#winkel","titel":"Winkelmodus","text":"[[deg]] Grad, rad Bogenmaß, grd Gon. Er gilt für [[sin]], [[cos]], [[tan]] und [[°]] und wird mit der Session gespeichert."},
{"kennung":"#fehler","titel":"Fehler","text":"Ein Fehler bricht die Eingabe an dieser Stelle ab und markiert das Token. Der Stack bleibt, wie er vor dem fehlerhaften Token war. Mit Backspace lässt sich der Fehler beheben."},
{"kennung":"+","titel":"Addition","verwendungen":[{"schreibweise":"+","stack":"y x → y+x","kurz":"Summe"}],"text":"Siehe [[#stack]]."},
{"kennung":"-","titel":"Subtraktion","verwendungen":[{"schreibweise":"-","stack":"y x → y−x","kurz":"Differenz"}],"text":"Das Vorzeichen einer Zahl ist `~`, nicht `-`: siehe [[~]]."},
{"kennung":"*","titel":"Multiplikation","verwendungen":[{"schreibweise":"*","stack":"y x → y·x","kurz":"Produkt"}],"text":"\"5 *\" quadriert: Das Leerzeichen legt eine Kopie an ([[#enter]])."},
{"kennung":"/","titel":"Division","verwendungen":[{"schreibweise":"/","stack":"y x → y/x","kurz":"Quotient"},{"schreibweise":"~/","stack":"x → 1/x","kurz":"Kehrwert"},{"schreibweise":"|/","stack":"y x → Quotient, Rest","kurz":"Ganzzahldivision mit Rest"}],"text":"\"7 2|/\" ergibt [3 1]. Division durch 0 ist bei |/ ein Fehler."},
{"kennung":"^","titel":"Potenz und Wurzel","verwendungen":[{"schreibweise":"^","stack":"y x → yˣ","kurz":"Potenz"},{"schreibweise":"~^","stack":"y x → ˣ√y","kurz":"allgemeine Wurzel"}],"text":"\"27 3~^\" ergibt 3."},
{"kennung":"!","titel":"Fakultät, Variablen und Konstanten anlegen","verwendungen":[{"schreibweise":"!","stack":"x → x!","kurz":"Fakultät"},{"schreibweise":"'!x","argumente":"n (1)","kurz":"legt die Variable x mit n Elementen an"},{"schreibweise":"'!!x","argumente":"n (1)","kurz":"legt die Konstante x mit n Elementen an"}],"text":"\"5'!a\" legt a = 5 an, \"1 2 3 3:'!v\" den Vektor v = 3 2 1 (Element 0 ist der Tos). Siehe [[']], [[#variablen]]."},
{"kennung":"²","titel":"Quadrat und Quadratwurzel","verwendungen":[{"schreibweise":"²","stack":"x → x²","kurz":"Quadrat"},{"schreibweise":"~²","stack":"x → √x","kurz":"Quadratwurzel"}]},
{"kennung":"³","titel":"Kubik und Kubikwurzel","verwendungen":[{"schreibweise":"³","stack":"x → x³","kurz":"Kubik"},{"schreibweise":"~³","stack":"x → ∛x","kurz":"Kubikwurzel"}]},
{"kennung":"~","titel":"Vorzeichen, Umkehrung, Entfernen","verwendungen":[{"schreibweise":"~","stack":"x → −x","kurz":"Vorzeichenwechsel des Tos"},{"schreibweise":"~3","kurz":"negative Zahl"},{"schreibweise":"1ê~2","kurz":"negativer Exponent"},{"schreibweise":"'~x","kurz":"entfernt die Variable, den Tag oder die eigene Funktion x"}],"text":"Vor einem Operator oder einer Funktion bildet `~` die Umkehrung: [[²]] (√x), [[^]] (ˣ√y), [[/]] (1/x), [[sin]] (asin), [[ln]] (eˣ), [[log]] (10ˣ), [[%]], [[°]], [[R]], [[seed]]. Bei Vergleichen kehrt es den Vergleich um: [[<]], [[>]], [[=]], [[&]]. Siehe [[#zahlen]]."},
{"kennung":"|","titel":"Ganzzahlteil, Betrag, Varianten, Tags","verwendungen":[{"schreibweise":"|","stack":"x → int(x), frac(x)","kurz":"Ganzzahl- und Nachkommateil"},{"schreibweise":"||","stack":"x → |x|","kurz":"Betrag"},{"schreibweise":"'|x","argumente":"n (1)","kurz":"markiert die Tos-Zelle als Tag x"},{"schreibweise":"'||x","argumente":"n (1)","kurz":"markiert die Tos-Zelle als Tag x mit Schreibschutz"}],"text":"\"3.7|\" ergibt [3 0.7]. Vor einem Operator bildet `|` eine Variante: [[/]] (|/), [[%]] (|%), [[:]] (|:). Siehe [[#tags]]."},
{"kennung":":","titel":"Argumente","verwendungen":[{"schreibweise":":","stack":"x → –","kurz":"übergibt den Tos als Argument an den nächsten Namen"},{"schreibweise":"~:","kurz":"im Code: legt das nächste Argument auf den Stack"},{"schreibweise":"~|:","kurz":"im Code: legt alle übrigen Argumente auf den Stack, sie bleiben in der Liste"},{"schreibweise":"|:","kurz":"im Code: legt die Anzahl der übrigen Argumente auf den Stack"}],"text":"\"3:D\" entfernt 3 Elemente. Siehe [[#argumente]] und [[#funktionen]]."},
{"kennung":"%","titel":"Prozentrechnung","verwendungen":[{"schreibweise":"%","stack":"y x → y, y·x/100","kurz":"Prozentwert"},{"schreibweise":"~%","stack":"y x → y, y·100/x","kurz":"Grundwert: y sind x %, was sind 100 %"},{"schreibweise":"|%","stack":"y x → y·(1−x/100), y·x/100","kurz":"Vorwärts-Split"},{"schreibweise":"~|%","stack":"y x → y/(1+x/100), Rest","kurz":"Rückwärts-Split"}],"text":"\"200 15%\" ergibt [200 30], \"100 20|%\" ergibt [80 20], \"120 20~|%\" ergibt [100 20]."},
{"kennung":"°","titel":"Koordinaten","verwendungen":[{"schreibweise":"°","stack":"x y → r φ","kurz":"kartesisch nach polar"},{"schreibweise":"~°","stack":"r φ → x y","kurz":"polar nach kartesisch"}],"text":"φ im eingestellten Winkelmodus ([[#winkel]]). \"3 4°\" ergibt [5 53.13]."},
{"kennung":"<","titel":"Kleiner, größer oder gleich","verwendungen":[{"schreibweise":"<","stack":"y x → 1 oder 0","kurz":"kleiner"},{"schreibweise":"~<","stack":"y x → 1 oder 0","kurz":"größer oder gleich"}],"text":"Wahrheitswerte für [[if]] und [[loop]]."},
{"kennung":">","titel":"Größer, kleiner oder gleich","verwendungen":[{"schreibweise":">","stack":"y x → 1 oder 0","kurz":"größer"},{"schreibweise":"~>","stack":"y x → 1 oder 0","kurz":"kleiner oder gleich"}],"text":"Wahrheitswerte für [[if]] und [[loop]]."},
{"kennung":"=","titel":"Gleich, ungleich, Variable schreiben","verwendungen":[{"schreibweise":"=","stack":"y x → 1 oder 0","kurz":"gleich"},{"schreibweise":"~=","stack":"y x → 1 oder 0","kurz":"ungleich"},{"schreibweise":"'=x","argumente":"n:m:k (0:1:0)","kurz":"schreibt Werte vom Stack in die Variable x"}],"text":"Siehe [[#variablen]]."},
{"kennung":"&","titel":"Und, oder","verwendungen":[{"schreibweise":"&","stack":"y x → 1 oder 0","kurz":"logisches Und"},{"schreibweise":"~&","stack":"y x → 1 oder 0","kurz":"logisches Oder"}],"text":"0 ist falsch, alles andere wahr."},
{"kennung":"'","titel":"Namen: Variablen, Konstanten, Tags","verwendungen":[{"schreibweise":"'x","argumente":"n:m (0:1)","kurz":"kopiert m Elemente ab Element n von x auf den Stack"},{"schreibweise":"'!x","argumente":"n (1)","kurz":"legt die Variable x an"},{"schreibweise":"'!!x","argumente":"n (1)","kurz":"legt die Konstante x an"},{"schreibweise":"'=x","argumente":"n:m:k (0:1:0)","kurz":"schreibt Werte vom Stack in x"},{"schreibweise":"'+x","argumente":"n:m:k (0:1:0)","kurz":"ändert x mit Werten vom Stack, ebenso '-x '*x '/x"},{"schreibweise":"'~x","kurz":"entfernt x"},{"schreibweise":"'|x","argumente":"n (1)","kurz":"markiert die Tos-Zelle als Tag x"},{"schreibweise":"'||x","argumente":"n (1)","kurz":"Tag mit Schreibschutz"},{"schreibweise":"'S","kurz":"Stackbefehl, der die Tags mitnimmt, ebenso 'R '~R 'D 'C"}],"text":"Siehe [[#namen]], [[#variablen]], [[#tags]]."},
{"kennung":"_","titel":"Trenner","verwendungen":[{"schreibweise":"_","kurz":"trennt zwei Token, sonst keine Wirkung"}],"text":"\"1_2\" ergibt [1 2], \"pi_sin\" ruft zwei Funktionen auf. Siehe [[#trenner]]."},
{"kennung":" ","titel":"Leerzeichen als Enter","verwendungen":[{"schreibweise":"␣","kurz":"trennt und legt eine Kopie des Tos an (Enter)"}],"text":"Siehe [[#enter]]."},
{"kennung":"ê","titel":"Exponent","verwendungen":[{"schreibweise":"1.5ê3","kurz":"Zahl mal Zehnerpotenz: 1500"},{"schreibweise":"1ê~2","kurz":"negativer Exponent: 0,01"}],"text":"Siehe [[#zahlen]]."},
{"kennung":".","titel":"Dezimalpunkt","verwendungen":[{"schreibweise":"3.14","kurz":"Dezimalzahl, auch .5 und 5."}],"text":"Siehe [[#zahlen]]."},
{"kennung":"\u007b","titel":"Code-Block","verwendungen":[{"schreibweise":"\u007b…\u007d","kurz":"legt den Block auf den Code-Stack"}],"text":"Siehe [[#code]]."},
{"kennung":"C","titel":"Stack löschen","verwendungen":[{"schreibweise":"C","kurz":"löscht den Stack; Fehler, solange es Tags gibt"},{"schreibweise":"'C","kurz":"löscht Stack und alle Tags"}],"text":"Siehe [[#stack]], [[#tags]]."},
{"kennung":"D","titel":"Elemente entfernen","verwendungen":[{"schreibweise":"D","argumente":"n (1)","kurz":"entfernt n Elemente"},{"schreibweise":"'D","argumente":"n (1)","kurz":"entfernt n Elemente samt ihren Tags"}]},
{"kennung":"S","titel":"Tauschen","verwendungen":[{"schreibweise":"S","argumente":"tgt:src:len (1:0:1)","kurz":"tauscht len Elemente ab src mit len Elementen ab tgt"},{"schreibweise":"'S","argumente":"tgt:src:len (1:0:1)","kurz":"tauscht Werte und Tags gemeinsam"}],"text":"\"S\" tauscht Position 0 und 1, \"3:S\" Position 0 und 3. Siehe [[#argumente]]."},
{"kennung":"R","titel":"Rotieren","verwendungen":[{"schreibweise":"R","argumente":"items:offset (3:0)","kurz":"rotiert items Elemente ab offset, das unterste kommt nach oben"},{"schreibweise":"~R","argumente":"items:offset (3:0)","kurz":"rotiert in die andere Richtung, der Tos wandert nach unten"},{"schreibweise":"'R","argumente":"items:offset (3:0)","kurz":"rotiert Werte und Tags gemeinsam, ebenso '~R"},{"schreibweise":"'~R","argumente":"items:offset (3:0)","kurz":"rotiert Werte und Tags in die andere Richtung"}],"text":"\"4:R\" holt Position 3 in den Tos."},
{"kennung":"Y","titel":"Kopieren","verwendungen":[{"schreibweise":"Y","argumente":"quelle:anzahl (1:1)","kurz":"kopiert anzahl Elemente ab quelle auf den Stack"}],"text":"Y allein ist „Over“ ([a b] → [a b a]), \"0:Y\" ist dup, \"YY\" verdoppelt die beiden obersten Werte."},
{"kennung":"X","titel":"Code ausführen","verwendungen":[{"schreibweise":"X","kurz":"führt den obersten Code-Block aus"}],"text":"Argumente liest der Block mit ~:, z.B. \"3:5:\u007b~:~:-\u007dX\". Siehe [[#code]]."},
{"kennung":"pi","titel":"Kreiszahl","verwendungen":[{"schreibweise":"pi","kurz":"π = 3,14159…"}]},
{"kennung":"e","titel":"Eulersche Zahl","verwendungen":[{"schreibweise":"e","kurz":"e = 2,71828…"}],"text":"Der Exponent einer Zahl ist [[ê]], nicht e."},
{"kennung":"ln","titel":"Natürlicher Logarithmus","verwendungen":[{"schreibweise":"ln","stack":"x → ln x","kurz":"natürlicher Logarithmus"},{"schreibweise":"~ln","stack":"x → eˣ","kurz":"Exponentialfunktion"},{"schreibweise":"exp","stack":"x → eˣ","kurz":"wie ~ln"}]},
{"kennung":"log","titel":"Logarithmus","verwendungen":[{"schreibweise":"log","stack":"x → log_b x","argumente":"b (10)","kurz":"Logarithmus zur Basis b"},{"schreibweise":"~log","stack":"x → bˣ","argumente":"b (10)","kurz":"Potenz der Basis b"}],"text":"\"8 2:log\" ergibt 3."},
{"kennung":"sin","titel":"Sinus","verwendungen":[{"schreibweise":"sin","stack":"x → sin x","kurz":"Sinus im eingestellten Winkelmodus"},{"schreibweise":"~sin","stack":"x → asin x","kurz":"Arkussinus"},{"schreibweise":"asin","stack":"x → asin x","kurz":"wie ~sin"}],"text":"Bei Vielfachen von 90° exakt 0, 1 oder −1. Siehe [[#winkel]]."},
{"kennung":"cos","titel":"Kosinus","verwendungen":[{"schreibweise":"cos","stack":"x → cos x","kurz":"Kosinus im eingestellten Winkelmodus"},{"schreibweise":"~cos","stack":"x → acos x","kurz":"Arkuskosinus"},{"schreibweise":"acos","stack":"x → acos x","kurz":"wie ~cos"}],"text":"Siehe [[#winkel]]."},
{"kennung":"tan","titel":"Tangens","verwendungen":[{"schreibweise":"tan","stack":"x → tan x","kurz":"Tangens im eingestellten Winkelmodus"},{"schreibweise":"~tan","stack":"x → atan x","kurz":"Arkustangens"},{"schreibweise":"atan","stack":"x → atan x","kurz":"wie ~tan"}],"text":"An den Polstellen unendlich. Siehe [[#winkel]]."},
{"kennung":"deg","titel":"Winkelmodus","verwendungen":[{"schreibweise":"deg","kurz":"Grad (Standard)"},{"schreibweise":"rad","kurz":"Bogenmaß"},{"schreibweise":"grd","kurz":"Gon (Neugrad)"}],"text":"Siehe [[#winkel]]."},
{"kennung":"dms","titel":"Grad, Minuten, Sekunden","verwendungen":[{"schreibweise":"dms","stack":"x → Grad Minuten Sekunden","kurz":"zerlegt einen Winkel"}],"text":"\"12.3456789dms\" ergibt [12 20 44.444]."},
{"kennung":"rnd","titel":"Zufallszahl","verwendungen":[{"schreibweise":"rnd","kurz":"Zufallszahl in [0, 1)"},{"schreibweise":"n:rnd","argumente":"n","kurz":"ganze Zahl von 1 bis n"},{"schreibweise":"a:b:rnd","argumente":"a:b","kurz":"ganze Zahl von a bis b"}],"text":"\"6:rnd\" ist ein Würfel. Siehe [[seed]]."},
{"kennung":"seed","titel":"Startwert für Zufallszahlen","verwendungen":[{"schreibweise":"seed","stack":"x → –","kurz":"nimmt den Tos als Startwert, rnd liefert danach eine reproduzierbare Folge"},{"schreibweise":"~seed","kurz":"hebt den Startwert auf, wieder echte Zufallszahlen"}]},
{"kennung":"round","titel":"Runden","verwendungen":[{"schreibweise":"round","argumente":"stellen:art (0:0)","kurz":"rundet auf stellen Nachkommastellen"}],"text":"Art: 0 kaufmännisch, 1 auf, −1 ab, 2 bei ,5 auf gerade, −2 auf ungerade, 3 vom Nullpunkt weg, −3 zum Nullpunkt hin. \"3.14159 2:round\" ergibt 3,14, \"1234 ~2:round\" ergibt 1200."},
{"kennung":"if","titel":"Bedingung","verwendungen":[{"schreibweise":"\u007bdann\u007dif","stack":"x → –","kurz":"führt den Block aus, wenn der Wert wahr ist"},{"schreibweise":"\u007bdann\u007d\u007bsonst\u007difel","stack":"x → –","kurz":"führt je nach Wert dann oder sonst aus"}],"text":"0 ist falsch, alles andere wahr. Siehe [[#code]], [[<]]."},
{"kennung":"loop","titel":"Schleife","verwendungen":[{"schreibweise":"\u007bcode\u007dloop","kurz":"führt code aus und wiederholt, solange der Wert danach wahr ist"}],"text":"\"0\u007b1+ 5<\u007dloop\" zählt bis 5. Siehe [[#code]]."},
{"kennung":"times","titel":"Wiederholen","verwendungen":[{"schreibweise":"n:\u007bcode\u007dtimes","argumente":"n","kurz":"führt code n-mal aus, der Index ist das Argument"}],"text":"\"5:\u007b~|: *\u007dtimes\" ergibt 0 1 4 9 16. Siehe [[#code]], [[:]]."},
{"kennung":"rpnjson","titel":"Erweiterungen aus JSON","verwendungen":[{"schreibweise":"\u007bjson\u007drpnjson","kurz":"wertet den obersten Block als JSON aus: Versionsangabe und Hilfetexte"}],"text":"Schlüssel version (name, bibliothek, rechner, app: MAJOR.MINOR.PATCH) und hilfe (Liste von Einträgen). Bibliotheken nutzen das für ihre Versionsangabe und ihre Hilfe. Unbekannte Schlüssel werden übergangen. Siehe [[#funktionen]]."},
{"kennung":"codedrop","titel":"Befehle für den Code-Stack","verwendungen":[{"schreibweise":"codedrop","argumente":"n (1)","kurz":"entfernt die obersten n Blöcke"},{"schreibweise":"codeswap","argumente":"tgt:src:len (1:0:1)","kurz":"tauscht Blöcke"},{"schreibweise":"codedup","argumente":"n (1)","kurz":"kopiert die obersten n Blöcke"},{"schreibweise":"codeover","argumente":"quelle:anzahl (1:1)","kurz":"kopiert Blöcke ab einer Position nach oben"}],"text":"Sie arbeiten wie [[D]], [[S]] und [[Y]] auf dem Werte-Stack. Siehe [[#code]]."}
]}}rpnjson
}
''',
};
