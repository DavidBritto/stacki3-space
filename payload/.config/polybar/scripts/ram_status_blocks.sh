#!/usr/bin/env bash

set -euo pipefail

# Modulo RAM con "unicode art" puro:
# - usa bloques Unicode estandar en vez de iconos Nerd Font
# - muestra un medidor mas ancho para que la forma se aprecie mejor

used_pct="$(
  awk '
    /^MemTotal:/ {total=$2}
    /^MemAvailable:/ {avail=$2}
    END {
      if (total > 0) {
        used = total - avail
        printf "%.0f", (used / total) * 100
      } else {
        print 0
      }
    }
  ' /proc/meminfo
)"

if [ "$used_pct" -le 10 ]; then
  meter="▁▁▁▁▁"
elif [ "$used_pct" -le 20 ]; then
  meter="▁▁▂▁▁"
elif [ "$used_pct" -le 30 ]; then
  meter="▁▂▂▂▁"
elif [ "$used_pct" -le 40 ]; then
  meter="▁▂▃▂▁"
elif [ "$used_pct" -le 50 ]; then
  meter="▂▃▃▃▂"
elif [ "$used_pct" -le 60 ]; then
  meter="▂▃▄▃▂"
elif [ "$used_pct" -le 70 ]; then
  meter="▃▄▅▄▃"
elif [ "$used_pct" -le 80 ]; then
  meter="▃▅▅▅▃"
elif [ "$used_pct" -le 90 ]; then
  meter="▄▅▆▅▄"
else
  meter="▅▆▇▆▅"
fi

printf 'RAM %%{T2}%s%%{T-} |\n' "$meter"
