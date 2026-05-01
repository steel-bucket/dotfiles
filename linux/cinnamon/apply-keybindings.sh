#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

backup="${HOME}/.config/cinnamon-dotfiles-backup-$(date +%Y%m%d-%H%M%S).dconf"
mkdir -p "${HOME}/.config"

dconf dump /org/cinnamon/ > "${backup}"
dconf load / < keybindings.dconf

printf 'Cinnamon settings loaded. Backup: %s\n' "${backup}"
