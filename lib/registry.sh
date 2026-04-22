#!/usr/bin/env bash

MODULE_KEYS=(
  "zsh"
  "oh-my-zsh"
  "git"
  "nvm"
  "docker"
  "docker-compose"
  "github-cli"
  "pnpm"
  "bun"
  "yarn"
)

declare -A MODULE_DESCRIPTIONS=(
  ["zsh"]="Shell Zsh"
  ["oh-my-zsh"]="Framework Oh My Zsh"
  ["git"]="Git SCM"
  ["nvm"]="Node Version Manager"
  ["docker"]="Docker Engine"
  ["docker-compose"]="Docker Compose Plugin"
  ["github-cli"]="GitHub CLI"
  ["pnpm"]="PNPM via Corepack"
  ["bun"]="Bun runtime"
  ["yarn"]="Yarn via Corepack"
)

declare -A MODULE_CATEGORIES=(
  ["zsh"]="Shells"
  ["oh-my-zsh"]="Shells"
  ["git"]="CLI"
  ["nvm"]="Runtimes"
  ["docker"]="Containers"
  ["docker-compose"]="Containers"
  ["github-cli"]="CLI"
  ["pnpm"]="Package Managers"
  ["bun"]="Runtimes"
  ["yarn"]="Package Managers"
)

declare -A MODULE_DEFAULTS=(
  ["zsh"]="ON"
  ["oh-my-zsh"]="OFF"
  ["git"]="ON"
  ["nvm"]="ON"
  ["docker"]="ON"
  ["docker-compose"]="ON"
  ["github-cli"]="ON"
  ["pnpm"]="ON"
  ["bun"]="ON"
  ["yarn"]="ON"
)

module_exists() {
  local module="$1"
  local item
  for item in "${MODULE_KEYS[@]}"; do
    [[ "$item" == "$module" ]] && return 0
  done
  return 1
}

select_all_modules() {
  SELECTED_MODULES=("${MODULE_KEYS[@]}")
}

normalize_whiptail_selection() {
  local raw="$1"
  SELECTED_MODULES=()

  local item
  for item in $raw; do
    item="${item%\"}"
    item="${item#\"}"
    module_exists "$item" && SELECTED_MODULES+=("$item")
  done
}

module_status() {
  local module="$1"

  case "$module" in
    zsh)
      command -v zsh >/dev/null 2>&1 && echo "instalado" || echo "não instalado"
      ;;
    oh-my-zsh)
      [[ -d "$TARGET_HOME/.oh-my-zsh" ]] && echo "instalado" || echo "não instalado"
      ;;
    git)
      command -v git >/dev/null 2>&1 && echo "instalado" || echo "não instalado"
      ;;
    nvm)
      [[ -s "$TARGET_HOME/.nvm/nvm.sh" ]] && echo "instalado" || echo "não instalado"
      ;;
    docker)
      command -v docker >/dev/null 2>&1 && echo "instalado" || echo "não instalado"
      ;;
    docker-compose)
      docker compose version >/dev/null 2>&1 && echo "instalado" || echo "não instalado"
      ;;
    github-cli)
      command -v gh >/dev/null 2>&1 && echo "instalado" || echo "não instalado"
      ;;
    pnpm)
      sudo -H -u "$TARGET_USER" bash -lc 'command -v pnpm >/dev/null 2>&1' && echo "instalado" || echo "não instalado"
      ;;
    bun)
      sudo -H -u "$TARGET_USER" bash -lc 'command -v bun >/dev/null 2>&1' && echo "instalado" || echo "não instalado"
      ;;
    yarn)
      sudo -H -u "$TARGET_USER" bash -lc 'command -v yarn >/dev/null 2>&1' && echo "instalado" || echo "não instalado"
      ;;
    *)
      echo "desconhecido"
      ;;
  esac
}
