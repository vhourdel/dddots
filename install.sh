#!/usr/bin/env bash
set -euo pipefail

DOTFILES_PATH="$HOME/dotfiles"

# Symlink dotfiles to the root within your workspace
find $DOTFILES_PATH -type f -path "$DOTFILES_PATH/.*" |
while read df; do
  link=${df/$DOTFILES_PATH/$HOME}
  mkdir -p "$(dirname "$link")"
  ln -sf "$df" "$link"
done

sudo apt-get update
curl -L https://github.com/helix-editor/helix/releases/download/25.07.1/helix_25.7.1-1_amd64.deb -o helix.deb && sudo apt-get install -y ./helix.deb
