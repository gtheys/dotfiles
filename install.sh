#!/usr/bin/env bash
# Idempotent dotfiles installer.
# Safe to run multiple times — skips anything already correct,
# warns about conflicts without touching them.

set -euo pipefail

DOTFILES="$HOME/.dotfiles"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NONE='\033[0m'

ok()    { echo -e "  ${GREEN}✓${NONE}  $1"; }
linked(){ echo -e "  ${BLUE}→${NONE}  $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NONE}  $1"; }
title() { echo -e "\n${BLUE}▸ $1${NONE}"; }

# link <source> <target>
# Creates symlink only if missing or wrong. Never overwrites real files/dirs.
link() {
    local src="${1%/}" dst="$2"  # strip trailing slash for consistent comparison

    local current_target
    current_target=$(readlink "$dst" 2>/dev/null || true)
    if [[ -L "$dst" && "${current_target%/}" == "$src" ]]; then
        ok "$(basename "$dst")"
        return
    fi

    if [[ -L "$dst" ]]; then
        warn "$(basename "$dst") → wrong target (${current_target}) — fix manually"
        return
    fi

    if [[ -e "$dst" ]]; then
        warn "$(basename "$dst") is a real file/dir — remove it to link"
        return
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    linked "$(basename "$dst")"
}

# ─── Symlinks ────────────────────────────────────────────────────────────────

title "Symlinks: home"
for src in "$DOTFILES"/*.symlink; do
    link "$src" "$HOME/.$(basename "$src" .symlink)"
done

title "Symlinks: ~/.config"
mkdir -p "$HOME/.config"
for src in "$DOTFILES"/config/*/; do
    link "$src" "$HOME/.config/$(basename "$src")"
done

title "Symlinks: scripts"
link "$DOTFILES/scripts" "$HOME/.config/scripts"

# ─── Terminfo ─────────────────────────────────────────────────────────────────

title "Terminfo"
if infocmp tmux-256color &>/dev/null; then
    ok "tmux-256color"
else
    tic -x "$DOTFILES/resources/tmux.terminfo"
    linked "tmux-256color"
fi

if infocmp xterm-256color-italic &>/dev/null; then
    ok "xterm-256color-italic"
else
    tic -x "$DOTFILES/resources/xterm-256color-italic.terminfo"
    linked "xterm-256color-italic"
fi

# ─── Git ──────────────────────────────────────────────────────────────────────

title "Git local config"
if [[ -f "$HOME/.gitconfig-local" ]]; then
    ok "~/.gitconfig-local already exists"
else
    echo "  Enter details for ~/.gitconfig-local"
    read -rp "  Name:          " name
    read -rp "  Email:         " email
    read -rp "  GitHub user:   " github
    git config -f "$HOME/.gitconfig-local" user.name    "$name"
    git config -f "$HOME/.gitconfig-local" user.email   "$email"
    git config -f "$HOME/.gitconfig-local" github.user  "$github"
    linked "~/.gitconfig-local"
fi

# ─── GTK dark theme ───────────────────────────────────────────────────────────

title "GTK dark theme"
if ! command -v gsettings &>/dev/null; then
    warn "gsettings not found — skipping"
elif [[ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" == "'prefer-dark'" ]]; then
    ok "prefer-dark already set"
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    linked "set prefer-dark"
fi

# ─────────────────────────────────────────────────────────────────────────────

echo -e "\n${GREEN}All done.${NONE}\n"
