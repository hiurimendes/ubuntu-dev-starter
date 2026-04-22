#!/usr/bin/env bash

install_pnpm() {
  install_corepack_if_needed

  run_as_target_user '
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    corepack prepare pnpm@latest --activate
  '
}
