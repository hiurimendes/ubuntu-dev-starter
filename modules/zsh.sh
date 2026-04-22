#!/usr/bin/env bash

install_zsh() {
  install_apt_packages zsh

  local zsh_path
  zsh_path="$(command -v zsh)"
  [[ -n "$zsh_path" ]] || die "zsh não encontrado após instalação."

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] chsh -s $zsh_path $TARGET_USER"
  else
    chsh -s "$zsh_path" "$TARGET_USER" || warn "Falha ao definir zsh como shell padrão."
  fi
}
