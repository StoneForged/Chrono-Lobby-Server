#!/bin/sh
echo -ne '\033c\033]0;CHRONOCCG_LobbyServer\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/CHRONOCCG_LobbyServer.x86_64" "$@"
