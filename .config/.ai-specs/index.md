# Dotfiles AI Specifications & System Index

> **Target Audience:** Autonomous AI Coding Agents & Pair Programming Assistants
> **Purpose:** System architecture index, design patterns, and operational guide for maintaining and extending the user's desktop environment configuration.

---

## Workspace Context

- **Root Directory:** `/home/user/.config` (Dotfiles repository)
- **Primary Customization Package:** [`~/.config/my-wm`](file:///home/user/.config/my-wm)
- **Current Active Window Manager:** Sway (Wayland)
- **Target Supported Window Managers:** Multi-WM (Sway, Hyprland, i3, BSPWM)

---

## Directory & Subsystem Map

| Path | Responsibility | Documentation Link |
|---|---|---|
| [`my-wm/theme/`](file:///home/user/.config/my-wm/theme) | Central Theme Contracts (Single Source of Truth) & Compiled Artifacts | [Theme & Font Architecture](file:///home/user/.config/.ai-specs/docs/theme-architecture.md) |
| [`my-wm/scripts/theme/`](file:///home/user/.config/my-wm/scripts/theme) | Modular Theme Engine & Component Handlers | [Theme Handlers & CLI](file:///home/user/.config/.ai-specs/docs/theme-architecture.md#modular-handlers-scripts) |
| [`my-wm/configs/`](file:///home/user/.config/my-wm/configs) | Per-device monitor and display workspace configurations (`$DEVICE.json`) | — |
| [`sway/`](file:///home/user/.config/sway) | Sway WM configuration and scripts | — |
| [`waybar/`](file:///home/user/.config/waybar) | Dynamic Waybar status bar with multi-WM support | — |
| [`dunst/`](file:///home/user/.config/dunst) | Dunst notification daemon configuration | — |
| [`rofi/`](file:///home/user/.config/rofi) | Rofi application launcher and menu themes | — |

---

## Available Documentation

1. **[Theme & Font Parametrization Architecture](file:///home/user/.config/.ai-specs/docs/theme-architecture.md)**
   - Single Source of Truth contracts (`fonts.json`, `colors.json`).
   - Handler plugin architecture (`scripts/theme/<component>/<feature>.sh`).
   - Compilation lifecycle, shared context (`lib.sh`), and reload orchestration (`reload.sh`).
   - Guidelines for extending to Hyprland, new components, and color palettes.

---

## Core Rules & Invariants for AI Agents

1. **Single Source of Truth:** Never hardcode fonts or colors directly into client configs (`sway/config`, `waybar/style.css`, `rofi/themes/*.rasi`). Always define them in `~/.config/my-wm/theme/` contracts and consume generated artifacts.
2. **Git Cleanliness:** Do not mutate tracked dotfiles in-place with `sed` or similar tools (e.g., `dunst/dunstrc`). Use templates or import directives pointing to `~/.config/my-wm/theme/generated/`.
3. **Multi-WM Compatibility:** All core theme logic must remain WM-agnostic. WM-specific compilation belongs exclusively inside its own handler (e.g., `scripts/theme/sway/` or `scripts/theme/hypr/`).
4. **Decoupled Reloads:** Compilation scripts must only generate files in `theme/generated/`. Process reloads must be delegated to `scripts/theme/reload.sh` or triggered via the orchestrator `apply.sh`.
