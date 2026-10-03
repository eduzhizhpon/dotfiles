#!/usr/bin/env bash
# Wrapper entrypoint for MWM Desktop Environment Modular Installer
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="${SCRIPT_DIR}/.config/my-wm/scripts/install/mwm-install.sh"

if [ ! -f "$INSTALLER" ]; then
    echo "Error: Installer script not found at: $INSTALLER" >&2
    exit 1
fi

exec bash "$INSTALLER" "$@"
