#!/usr/bin/env bash
# Toggle kanata between base and gaming layers via TCP server
PORT=9999
CURRENT=$(echo '{"RequestCurrentLayerName":{}}' | nc -w1 localhost $PORT 2>/dev/null)

if echo "$CURRENT" | grep -q '"gaming"'; then
    echo '{"ChangeLayer":{"new":"base"}}' | nc -w1 localhost $PORT
    notify-send -t 2000 "Kanata" "Home row mods ON"
else
    echo '{"ChangeLayer":{"new":"gaming"}}' | nc -w1 localhost $PORT
    notify-send -t 2000 "Kanata" "Gaming mode ON"
fi
