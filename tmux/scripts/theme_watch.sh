#!/bin/bash

# Watch macOS appearance changes and refresh tmux theme.
INTERVAL=5
LAST_MODE=""

existing_pid=$(tmux show-environment -g TMUX_THEME_WATCHER_PID 2>/dev/null | sed 's/^[^=]*=//')
if [ -n "$existing_pid" ] && kill -0 "$existing_pid" >/dev/null 2>&1; then
    exit 0
fi

tmux set-environment -g TMUX_THEME_WATCHER_PID "$$" >/dev/null 2>&1
cleanup() {
    tmux set-environment -gu TMUX_THEME_WATCHER_PID >/dev/null 2>&1
}
trap cleanup EXIT

current_mode() {
    if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark; then
        echo "Dark"
    else
        echo "Light"
    fi
}

while true; do
    if ! tmux list-sessions >/dev/null 2>&1; then
        exit 0
    fi

    MODE=$(current_mode)
    if [ "$MODE" != "$LAST_MODE" ]; then
        LAST_MODE="$MODE"
        tmux source-file ~/.config/tmux/conf/macos.conf >/dev/null 2>&1
        tmux refresh-client -S >/dev/null 2>&1
    fi

    sleep "$INTERVAL"
done
