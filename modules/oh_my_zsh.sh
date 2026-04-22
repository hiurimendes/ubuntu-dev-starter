#!/usr/bin/env bash

install_oh_my_zsh() {
  if [[ ! -x "$(command -v zsh)" ]]; then
    install_zsh
  fi

  run_as_target_user 'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
}
