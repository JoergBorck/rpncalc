# FW-1 Browser-Version installierbar und offline nutzbar (PWA)

Feature · Web · mittel · Reife 5 · Stand: Geplant

## Ziel
Wer die Browser-Version (https://joergborck.github.io/rpncalc/) öffnet, kann sie wie eine App installieren: eigenes
Symbol, eigenes Fenster ohne Adressleiste, und sie startet auch ohne Netz. Am Handy ist das die einfachste
Installation, ohne APK und ohne Store.

## Heute
- `app/web/manifest.json` und die Icons sind da, Pages liefert über HTTPS aus; Chrome und Edge sollten damit schon
  „App installieren“ anbieten, Safari „Zum Home-Bildschirm“ (nicht geprüft).
- Im Manifest stehen noch Flutters Platzhalter: `"description": "A new Flutter project."`, die Farben `#0175C2`;
  `id` und `lang` fehlen.
- Offline geht nichts: Flutters `flutter_service_worker.js` ist in Flutter 3.47 nur noch ein Rumpf, der sich
  selbst abmeldet. CanvasKit lädt Flutter außerdem von Googles CDN.

## Verhalten
- Chrome und Edge (PC, Android) bieten „App installieren“ an, Safari (iPhone) „Zum Home-Bildschirm“; die
  installierte App öffnet im eigenen Fenster mit Namen und Symbol des Rechners.
- Das Manifest beschreibt den Rechner (Name, Beschreibung, `lang: de`, `id`), die Farben passen zur App
  (Gehäuse `#1A1D24`).
- Nach dem ersten Aufruf startet die App auch ohne Netz, im Browser wie installiert.
- Nach einer Veröffentlichung bekommt man die neue Version, ohne den Cache von Hand zu leeren.
- Der Service Worker gilt nur für den Pfad `/rpncalc/`.

## Entscheidungen
- 2026-11-11: **Service Worker:** ein eigener, klein (etwa 50 Zeilen), von `tool/veroeffentlichen.dart --web`
  nach dem Bauen mit der Liste der Dateien und der Version gefüllt; kein Workbox, keine weitere Abhängigkeit.
- 2026-11-11: **CanvasKit** wird selbst ausgeliefert (`flutter build web --no-web-resources-cdn`), sonst geht
  offline nicht; die Seite wird einige MB größer (beim Umsetzen messen).
- 2026-11-11: **Neue Version** wird still im Hintergrund geladen und gilt beim nächsten Start, kein Hinweis; die
  App hat noch keinen gespeicherten Zustand, ein Neuladen verliert nichts. Mit FA-8 neu prüfen.
- 2026-11-11: **Speicher** der installierten App (localStorage, IndexedDB) gehört zu RG-2, nicht hierher.

## Offen

## Bezüge
RG-2 und FA-8 (Speicher), TW-1 (Browser-Test), PT-1 (Windows-Version); tool/veroeffentlichen.dart (`webStand`);
Spezifikation: doc/app.md (Browser), README (Installation).

## Umsetzung und Tests
Test: installieren und offline starten auf PC (Chrome, Edge), Android (Chrome), soweit möglich iPhone (Safari);
eine zweite Veröffentlichung kommt ohne Cache-Leeren an.
