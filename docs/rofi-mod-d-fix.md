# Arreglar Mod+d de Rofi en una instalacion parcial

Esta guia deja el paso a paso para reparar el error de `Mod+d` cuando i3 intenta abrir rofi y falla con una ruta parecida a `__STACKI3_HOME__/.local/bin/rofi-files`.

## Problema

El stack quedo instalado parcialmente. El archivo de configuracion de rofi todavia tiene el placeholder `__STACKI3_HOME__` en vez del `$HOME` real del equipo, o falta el script `~/.local/bin/rofi-files`.

Error tipico:

```text
failed to execute: '__STACKI3_HOME__/.local/bin/rofi-files'
Fallo al ejecutar el proceso hijo "__STACKI3_HOME__/.local/bin/rofi-files"
No existe el archivo o el directorio
```

## Paso rapido

1. Verificar que el script exista:

```sh
ls -l ~/.local/bin/rofi-files
```

2. Si no existe, copiarlo desde el proyecto:

```sh
mkdir -p ~/.local/bin
cp ~/git/space-stack/payload/.local/bin/rofi-files ~/.local/bin/rofi-files
chmod +x ~/.local/bin/rofi-files
```

3. Revisar la configuracion de rofi:

```sh
nano ~/.config/rofi/config.rasi
```

Buscar una linea parecida a:

```rasi
modi: "combi,files:__STACKI3_HOME__/.local/bin/rofi-files,drun,run,window";
```

Cambiarla por:

```rasi
modi: "combi,files:~/.local/bin/rofi-files,drun,run,window";
```

4. Buscar si quedaron mas placeholders rotos:

```sh
rg "__STACKI3_HOME__" ~/.config ~/.local/bin
```

5. Si aparecen resultados, reemplazarlos por el `$HOME` real:

```sh
rg -l "__STACKI3_HOME__" ~/.config ~/.local/bin | xargs sed -i "s#__STACKI3_HOME__#$HOME#g"
```

6. Recargar i3:

```sh
i3-msg reload
i3-msg restart
```

## Verificacion

Probar rofi directo desde terminal:

```sh
rofi -show drun
```

Probar el modo de archivos directo:

```sh
rofi -show files
```

Despues probar `Mod+d`.

## Archivos involucrados

| Archivo | Para que sirve |
|---|---|
| `~/.config/rofi/config.rasi` | Define los modos de rofi, incluido `files` |
| `~/.local/bin/rofi-files` | Script que lista archivos para el modo `files` |
| `~/.config/i3/config` | Define el atajo `Mod+d` |
| `~/git/space-stack/payload/.local/bin/rofi-files` | Copia original del script dentro del proyecto |

## Nota

Si el error menciona `__STACKI3_HOME__`, el problema no es rofi ni i3: es que la instalacion no reemplazo el placeholder por el home real del equipo.
