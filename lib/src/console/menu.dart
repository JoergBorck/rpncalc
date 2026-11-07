/// Aufgabe: das Textmenü des Konsolenprogramms. [MenuItem] ist ein Eintrag mit oder ohne Untermenü, [Menu] zeigt
/// die Einträge nummeriert, liest die Auswahl mit readLineSync und liefert den gewählten Endpunkt; „<“ führt
/// zurück. [hauptmenue] ist der Menübaum von bin/rpncalc.dart.
///
/// Abgrenzung: Was ein Menüpunkt tut, entscheidet bin/rpncalc.dart; die Eingaben stehen in ui.dart, die
/// Bibliotheken für das Menü in library.dart. Das Menü der App (FA-6) ist etwas anderes.
///
/// Siehe auch: bin/rpncalc.dart, console/ui.dart, doc/architecture.md 3.
library;

import 'dart:io';

class MenuItem {
  final String title;
  final List<MenuItem>? subMenu; // null bedeutet: Es ist ein Endpunkt (Aktion)

  MenuItem(this.title, [this.subMenu]);

  // Hilfsmethode: Hat das Element kein Untermenü?
  bool get isAction => subMenu == null || subMenu!.isEmpty;
}

class Menu {
  final MenuItem root;
  Menu(this.root);
  MenuItem? find(String title,[MenuItem? item]) {
    item ??= root;
    if (title == item.title) { return item; }
    if (item.subMenu == null) { return null; }
    for (MenuItem subitem in item.subMenu!) {
      MenuItem? resultItem = find(title, subitem);
      if (resultItem != null) return resultItem;
    }
    return null;
  }

  MenuItem back = MenuItem("zurück");

  /// Zeigt das Menü ab [start] (sonst ab der Wurzel) und liefert den gewählten Eintrag ohne Untermenü, [back] für
  /// „zurück“ oder null, wenn die Eingabe endet.
  MenuItem? call([MenuItem? start]) {
    final menu = start ?? root;
    if (menu.isAction) return menu;
    int i=0;
    for (MenuItem item in menu.subMenu!) {
        print("${++i} - ${item.title}");
    }
    int auswahl;
    do {
      print("Bitte eine Zahl zwischen 1 und $i oder < für zurück eingeben.");
      String? eingabe = stdin.readLineSync();
      if (eingabe == null) return null; // Ende der Eingabe (z.B. umgeleitete Datei): Menü beenden
      if (eingabe=="<") return back; // Es wird das MenuItem back zurückgegeben
      auswahl = int.tryParse(eingabe) ?? 0; 
      if ((auswahl < 1) || (auswahl > i) ) {
        auswahl = 0;
      }
    } while (auswahl < 1);
    MenuItem item = menu.subMenu![auswahl-1];
    print("${item.title} wurde ausgewählt!");
    while (!item.isAction) {
      MenuItem? result = call(item);
      if (result == null) return null;
      item = result;
      if (item == back) return call(menu);
    }
    return item;
  }
}

/// Das Hauptmenü der Konsole; bin/rpncalc.dart fügt vor dem letzten Eintrag „Bibliotheken“ ein.
MenuItem hauptmenue = 
  MenuItem("Hauptmenue", [
    MenuItem("Eingabe", [
      MenuItem("Zeilenweise Eingabe"),
      MenuItem("Zeilenweise Eingabe mit Übersicht"),
      MenuItem("Zeichenweise Eingabe"),
      MenuItem("Zeichenweise Eingabe mit Übersicht"),
      MenuItem("Socket Multi-Client"),
    ]),
    MenuItem("Datei", [
      MenuItem("Session speichern"),
      MenuItem("Session laden"),
      MenuItem("Funktionen speichern"),
    ]),
    MenuItem("Test", [
      MenuItem("Test Menü", [
        MenuItem("Untermenü 1", [
          MenuItem("Untermenü 1.1"),
          MenuItem("Untermenü 1.1"),
        ]) ,
        MenuItem("Untermenü 2", [
          MenuItem("Untermenü 2.1"),
          MenuItem("Untermenü 2.1"),
        ]) ,
      ]) ,
      MenuItem("Test Dea"),
      MenuItem("Test Parser"),
      MenuItem("Test Rechner"),
      MenuItem("Test Stack"),
    ]),
    MenuItem("Beenden"),
  ]
);



