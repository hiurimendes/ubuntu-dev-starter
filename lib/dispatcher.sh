#!/usr/bin/env bash

execute_module() {
  local module="$1"

  case "$module" in
    zsh) install_zsh ;;
    oh-my-zsh) install_oh_my_zsh ;;
    git) install_git ;;
    nvm) install_nvm ;;
    docker) install_docker ;;
    docker-compose) install_docker_compose ;;
    github-cli) install_github_cli ;;
    pnpm) install_pnpm ;;
    bun) install_bun ;;
    yarn) install_yarn ;;
    *)
      warn "Módulo desconhecido: $module"
      ;;
  esac
}
