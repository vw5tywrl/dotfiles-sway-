#!/bin/bash
CACHE="$HOME/.cache/current_power_plan"

# Fallback se non esiste
if [ ! -f "$CACHE" ]; then
    current=$(tuned-adm active 2>/dev/null | awk '{print $NF}')
    echo "$current" > "$CACHE"
else
    current=$(cat "$CACHE")
fi

new_profile=""
display=""

if [[ "$current" == *"balanced"* ]]; then
    new_profile="throughput-performance"
    display="performance"
elif [[ "$current" == *"performance"* ]]; then
    new_profile="powersave"
    display="powersave"
else
    new_profile="balanced"
    display="balanced"
fi

# Aggiorna il file cache istantaneamente
echo "$display" > "$CACHE"

# Segnala a Waybar di aggiornarsi immediatamente
pkill -RTMIN+8 waybar

# Applica il vero profilo in background (non blocca l'UI)
tuned-adm profile "$new_profile" &
