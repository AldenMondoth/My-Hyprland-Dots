#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Weather entrypoint: prefer Python (Open‑Meteo), fallback to legacy Bash (wttr.in)

SCRIPT_DIR="$(dirname "$0")"
CPP_BIN="$SCRIPT_DIR/Weather"
PY_SCRIPT="$SCRIPT_DIR/Weather.py"

# Prefer the compiled C++ binary (handles network check internally)
if [ -x "$CPP_BIN" ]; then
    exec "$CPP_BIN" "$@"
fi

# Fallback: Python script (slower, requires python3 + requests)
echo "Weather binary not found — falling back to Weather.py" >&2
if command -v python3 >/dev/null 2>&1 && [ -f "$PY_SCRIPT" ]; then
    exec python3 "$PY_SCRIPT" "$@"
fi

echo '{"text":"", "alt":"Unavailable", "tooltip":"No weather binary or python3 found"}' >&2
exit 1
