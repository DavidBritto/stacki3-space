# TUI auth transition

STACKI3 should keep moving toward an Omarchy-like workflow where frequent privileged actions use an explicit terminal path instead of surprise desktop dialogs.

## Current rule

Polkit remains the compatibility fallback for graphical applications and system services that require a DBus authentication agent. Do not remove it until every frequent privileged workflow has a safe replacement.

## Target interaction model

Rofi → Kitty/TUI → explicit command

The user chooses an action from `space`, sees the exact privileged command or TUI panel, and authenticates in the terminal when possible.

## Migration order

1. Keep `polkit-gnome-authentication-agent-1`, but style it as a STACKI3/Dunst-like fallback.
2. Route stack-owned privileged actions through dedicated helpers:
   - power actions
   - updates
   - mounts
   - network changes
   - service restarts
3. Audit prompts that still appear at login or during normal work.
4. Replace high-frequency prompts with TUI flows only when the command is explicit, reversible enough, and easy to verify.

## Non-goals

- Do not remove Polkit as a security mechanism.
- Do not hide authentication prompts.
- Do not replace system permission checks with broad passwordless sudo rules.
