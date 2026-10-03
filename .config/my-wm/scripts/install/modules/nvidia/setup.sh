#!/usr/bin/env bash
# ==============================================================================
# Nvidia Module Setup Hook - Power Management Services
# ==============================================================================
set -e

if command -v systemctl &>/dev/null; then
    echo "  -> Enabling Nvidia power management services..."
    sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service 2>/dev/null || true
fi
