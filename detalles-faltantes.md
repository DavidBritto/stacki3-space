# Detalles faltantes para mejorar STACKI3

Este archivo registra mejoras pendientes del stack real. La regla base es: **mantener i3/X11 keyboard-first, sin sumar dependencias salvo que el beneficio sea claro y esté documentado**.

## Estado

- [x] Redimensionado cómodo de ventanas en i3.
- [x] Optimización de rutas estáticas de `space search` (`mod+p`).
- [x] Optimización del menú de volumen en Polybar.

## Principios aplicados

- Preferir capacidades nativas de i3, Polybar, Rofi, Kitty y scripts existentes.
- No reintroducir flujos no canónicos: Yazi como launcher principal, mail dedicado, dashboards de tareas o paneles por encima de tmux.
- No agregar dependencias nuevas.
- Verificar cambios con pruebas o checks de sintaxis cuando el repo lo permite.

## 1. Redimensionado cómodo de ventanas en i3

### Implementado

- Se mantiene `floating_modifier $mod` y `tiling_drag modifier titlebar`, lo que permite ajustar splits tiling con mouse usando Win + arrastre, sin dependencias nuevas.
- Se agregaron shortcuts directos para corregir proporciones sin entrar al modo resize:
  - `Win+Ctrl+Left` — reducir ancho
  - `Win+Ctrl+Right` — aumentar ancho
  - `Win+Ctrl+Up` — reducir alto
  - `Win+Ctrl+Down` — aumentar alto
- Se documentó el flujo en `payload/.config/shortcuts/pages/desktop.txt`.

### Verificación

- `tests/test_i3_resize_controls.py` cubre mouse resize, shortcuts directos y documentación.

## 2. Optimizar `space search` (`mod+p`)

### Implementado

- La búsqueda global conserva acciones finales y elimina saltos redundantes a submenús como `network · open menu` y `clipboard · open menu`.
- Se removieron acciones informativas que ejecutaban `stack-theme list/current` sin una superficie visible clara desde Rofi.
- Se agregaron acciones de audio finales útiles: abrir mixer, mute, volumen arriba/abajo y mute de micrófono.

### Verificación

- `tests/test_deskmenu_search.py` cubre que el catálogo estático no tenga saltos de submenú ni acciones informativas invisibles.

## 3. Optimizar menú de volumen en Polybar

### Implementado

- El click izquierdo de volumen sigue abriendo `space menu audio`.
- El menú de audio ahora es chico y accionable:
  - `open mixer panel`
  - `toggle mute`
  - `volume up`
  - `volume down`
  - `toggle mic mute`
- Se quitó `choose output sink` del menú principal porque era una ruta de mayor fricción y podía terminar en vacío según el estado de `pactl`.

### Verificación

- `tests/test_audio_menu.py` cubre la lista exacta del menú y evita reintroducir el sink picker como callejón sin salida.
