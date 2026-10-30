
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

  MenuItem? call([dynamic start]) {
    // Start in der Baumstruktur suchen
    MenuItem? menu;
    start = (start==null)?root:start;
    if (start is String) {
      if (start == "") start = root.title; 
      menu = find(root.title);
    } else if( start is MenuItem ) {
      menu = start;
    } else {
      return null; 
    }
    if (menu == null) return null;
    if (menu.subMenu == null) return menu;
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
    while (item.subMenu != null) {
      MenuItem? result = call(item);
      if (result == null) return null;
      item = result;
      if (item == back) return call(menu);
    }
    return item;
  }
}

// Testdata
MenuItem testmenu = 
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



