#!/usr/bin/env bash

install_yarn() {
  install_corepack_if_needed

  run_as_target_user '
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    corepack prepare yarn@stable --activate
  '
}
