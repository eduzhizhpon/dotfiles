# Project Guidelines & Agent Context for ~/.config (Dotfiles)

> **Mandatory AI Directive:**  
> Always review [`~/.config/.ai-specs/index.md`](file:///home/user/.config/.ai-specs/index.md) and related specifications under [`~/.config/.ai-specs/docs/`](file:///home/user/.config/.ai-specs/docs/) before inspecting, creating, or modifying any dotfiles, themes, or window manager components.

---

## 1. Context & Architecture Overview

- **Configuration Root:** `/home/user/.config`
- **Core Orchestrator:** [`~/.config/my-wm`](file:///home/user/.config/my-wm)
- **Active Window Manager:** Sway (Wayland), with multi-WM design (Hyprland, i3, BSPWM).
- **AI Specifications Root:** [`~/.config/.ai-specs/`](file:///home/user/.config/.ai-specs/)

---

## 2. Mandatory Protocol for AI Agents

1. **Check Specifications First:**
   - Before executing changes or designing new features, inspect [`~/.config/.ai-specs/index.md`](file:///home/user/.config/.ai-specs/index.md).
   - Read relevant architecture documents (e.g., [`theme-architecture.md`](file:///home/user/.config/.ai-specs/docs/theme-architecture.md)).

2. **Core Architectural Invariants:**
   - **Single Source of Truth (SSOT):** Never hardcode colors or fonts into client configurations (`sway/config`, `waybar/style.css`, `rofi/themes/*.rasi`, `kitty/kitty.conf`, etc.). Use central theme contracts in `my-wm/theme/` and compile into `my-wm/theme/generated/`.
   - **Git Cleanliness:** Do not mutate tracked configuration files in-place with `sed` or temporary scripts. Use templates, import directives, or generated symlinks.
   - **Multi-WM Agnostic Logic:** Keep shared logic decoupled from specific window managers. WM-specific compilation belongs strictly in its dedicated handler (`my-wm/scripts/theme/<wm>/`).
   - **Decoupled Reloads:** Compilation scripts should only generate artifacts. Live reloading must be delegated to `my-wm/scripts/theme/reload.sh` or executed via `apply.sh`.

3. **Maintain Documentation:**
   - Whenever introducing new components, scripts, or architectural changes, update [`~/.config/.ai-specs/`](file:///home/user/.config/.ai-specs/) to reflect the new state and guidelines.
