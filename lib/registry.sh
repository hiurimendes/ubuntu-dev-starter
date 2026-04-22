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

module_is_selected() {
  local module="$1"
  local selected
  for selected in "${SELECTED_MODULES[@]}"; do
    [[ "$selected" == "$module" ]] && return 0
  done
  return 1
}

add_selected_module() {
  local module="$1"
  module_is_selected "$module" || SELECTED_MODULES+=("$module")
}

remove_selected_module() {
  local module="$1"
  local updated=()
  local item

  for item in "${SELECTED_MODULES[@]}"; do
    [[ "$item" != "$module" ]] && updated+=("$item")
  done

  SELECTED_MODULES=("${updated[@]}")
}

set_module_selected_state() {
  local module="$1"
  local state="$2"

  if [[ "$state" == "ON" ]]; then
    add_selected_module "$module"
  else
    remove_selected_module "$module"
  fi
}

select_all_modules() {
  SELECTED_MODULES=("${MODULE_KEYS[@]}")
}

clear_all_modules() {
  SELECTED_MODULES=()
}

normalize_whiptail_selection() {
  local raw="$1"
  local parsed=()
  local item

  for item in $raw; do
    item="${item%\"}"
    item="${item#\"}"
    module_exists "$item" && parsed+=("$item")
  done

  printf '%s\n' "${parsed[@]}"
}

get_categories() {
  local seen=()
  local key
  local category
  local exists
  local item

  for key in "${MODULE_KEYS[@]}"; do
    category="${MODULE_CATEGORIES[$key]}"
    exists=0

    for item in "${seen[@]:-}"; do
      if [[ "$item" == "$category" ]]; then
        exists=1
        break
      fi
    done

    if [[ "$exists" -eq 0 ]]; then
      seen+=("$category")
    fi
  done

  printf '%s\n' "${seen[@]}"
}

get_modules_by_category() {
  local wanted="$1"
  local key

  for key in "${MODULE_KEYS[@]}"; do
    [[ "${MODULE_CATEGORIES[$key]}" == "$wanted" ]] && printf '%s\n' "$key"
  done
}

count_selected_modules() {
  echo "${#SELECTED_MODULES[@]}"
}

count_modules_in_category() {
  local category="$1"
  local count=0
  local module

  while IFS= read -r module; do
    [[ -n "$module" ]] && count=$((count + 1))
  done < <(get_modules_by_category "$category")

  echo "$count"
}

count_selected_in_category() {
  local category="$1"
  local count=0
  local module

  while IFS= read -r module; do
    [[ -z "$module" ]] && continue
    if module_is_selected "$module"; then
      count=$((count + 1))
    fi
  done < <(get_modules_by_category "$category")

  echo "$count"
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
      if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        echo "instalado"
      else
        echo "não instalado"
      fi
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