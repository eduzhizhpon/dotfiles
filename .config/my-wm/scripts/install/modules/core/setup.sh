#!/usr/bin/env bash
# ==============================================================================
# Core Module Setup Hook
# ==============================================================================
set -e

# Enable gnome-keyring daemon user service if systemd is available
if command -v systemctl &>/dev/null; then
    systemctl --user daemon-reexec 2>/dev/null || true
    systemctl --user enable gnome-keyring-daemon.service 2>/dev/null || true
fi
