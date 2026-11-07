/// Aufgabe: Terminal-Einstellungen für die zeichenweise Eingabe. Die Windows-Konsole liefert Pfeiltasten und Esc
/// im Rohmodus nur, wenn "Virtual Terminal Input" eingeschaltet ist; dann kommen sie wie unter Linux und macOS als
/// Escape-Folgen an (Pfeil hoch: Esc [ A). Dart schaltet beim Rohmodus nur Zeilenmodus und Echo ab, deshalb
/// schalten [virtuellesTerminal] und [virtuellesTerminalSetzen] den Modus direkt über kernel32.dll (FFI).
///
/// Abgrenzung: Rohmodus, Echo und das Auswerten der Escape-Folgen stehen in screen.dart. Auf anderen Systemen
/// tun die Funktionen nichts.
///
/// Siehe auch: console/screen.dart (`Bildschirm.eingabe`), doc/api.md Kapitel 7 (Tab und Pfeiltasten).
library;

import 'dart:ffi';
import 'dart:io';

typedef _GetStdHandleC = IntPtr Function(Int32);
typedef _GetStdHandle = int Function(int);
typedef _GetModeC = Int32 Function(IntPtr, Pointer<Uint32>);
typedef _GetMode = int Function(int, Pointer<Uint32>);
typedef _SetModeC = Int32 Function(IntPtr, Uint32);
typedef _SetMode = int Function(int, int);
typedef _AllocC = Pointer<Void> Function(Uint32, IntPtr);
typedef _Alloc = Pointer<Void> Function(int, int);
typedef _FreeC = Pointer<Void> Function(Pointer<Void>);
typedef _Free = Pointer<Void> Function(Pointer<Void>);

const int _stdInputHandle = -10;
const int _virtualTerminalInput = 0x0200;

/// Liest den Konsolenmodus und setzt, falls [neu] angegeben ist, den daraus berechneten.
/// Liefert den gelesenen Modus, oder null, wenn es nichts zu tun gibt (kein Windows) oder nicht geht.
int? _konsole([int Function(int alt)? neu]) {
  if (!Platform.isWindows) return null;
  try {
    final k = DynamicLibrary.open("kernel32.dll");
    final handle = k.lookupFunction<_GetStdHandleC, _GetStdHandle>("GetStdHandle")(_stdInputHandle);
    final getMode = k.lookupFunction<_GetModeC, _GetMode>("GetConsoleMode");
    final setMode = k.lookupFunction<_SetModeC, _SetMode>("SetConsoleMode");
    final p = k.lookupFunction<_AllocC, _Alloc>("LocalAlloc")(0x40, 4).cast<Uint32>(); // LPTR: mit Nullen
    try {
      if (getMode(handle, p) == 0) return null;
      final alt = p.value;
      if (neu != null && setMode(handle, neu(alt)) == 0) return null;
      return alt;
    } finally {
      k.lookupFunction<_FreeC, _Free>("LocalFree")(p.cast());
    }
  } catch (_) {
    return null; // z.B. keine Konsole: dann eben ohne Pfeiltasten
  }
}

/// Ob Virtual Terminal Input gerade eingeschaltet ist; null, wenn es das nicht gibt (kein Windows).
bool? virtuellesTerminal() {
  final modus = _konsole();
  return modus == null ? null : modus & _virtualTerminalInput != 0;
}

/// Schaltet Virtual Terminal Input ein oder aus, die übrigen Einstellungen der Konsole bleiben.
/// Erst nach dem Umschalten von Zeilenmodus und Echo aufrufen, weil Dart dabei selbst am Modus dreht.
void virtuellesTerminalSetzen(bool an) {
  _konsole((alt) => an ? alt | _virtualTerminalInput : alt & ~_virtualTerminalInput);
}
