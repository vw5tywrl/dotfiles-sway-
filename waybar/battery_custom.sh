#!/bin/bash
CACHE="$HOME/.cache/current_power_plan"

if [ ! -f "$CACHE" ]; then
    profile=$(tuned-adm active 2>/dev/null | awk '{print $NF}' || echo "balanced")
    if [[ "$profile" == *"performance"* ]]; then
        echo "performance" > "$CACHE"
    elif [[ "$profile" == *"powersave"* ]]; then
        echo "powersave" > "$CACHE"
    else
        echo "balanced" > "$CACHE"
    fi
fi

profile_display=$(cat "$CACHE")

capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
power_microwatts=$(cat /sys/class/power_supply/BAT0/power_now 2>/dev/null || echo "0")

power_watts=$(awk -v p="$power_microwatts" 'BEGIN { printf "%.1f", p / 1000000 }')

if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
    text="[AC ${capacity}% (+${power_watts}W)]"
else
    text="[BAT ${capacity}% (${power_watts}W)]"
fi

echo "{\"text\": \"$text\", \"tooltip\": \"$profile_display\"}"
