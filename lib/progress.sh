#!/usr/bin/env bash

module_display_name() {
  local module="$1"

  case "$module" in
    zsh) echo "Zsh" ;;
    oh-my-zsh) echo "Oh My Zsh" ;;
    git) echo "Git" ;;
    nvm) echo "NVM" ;;
    docker) echo "Docker Engine" ;;
    docker-compose) echo "Docker Compose" ;;
    github-cli) echo "GitHub CLI" ;;
    pnpm) echo "PNPM" ;;
    bun) echo "Bun" ;;
    yarn) echo "Yarn" ;;
    *) echo "$module" ;;
  esac
}

execute_selected_modules_with_progress() {
  local total="${#SELECTED_MODULES[@]}"
  local current=0
  local module
  local percent
  local label

  {
    for module in "${SELECTED_MODULES[@]}"; do
      current=$((current + 1))
      percent=$(( current * 100 / total ))
      label="$(module_display_name "$module")"

      echo "$percent"
      echo "XXX"
      echo "Instalando: $label"
      echo ""
      echo "Etapa $current de $total"
      echo "Log: $LOG_FILE"
      echo "XXX"

      execute_module "$module"
    done

    echo "100"
    echo "XXX"
    echo "Concluído."
    echo ""
    echo "Todos os módulos selecionados foram processados."
    echo "Log salvo em: $LOG_FILE"
    echo "XXX"
  } | whiptail --title "$SCRIPT_NAME" --gauge "Preparando instalação..." 14 78 0
}

execute_selected_modules_console() {
  local module
  local label

  for module in "${SELECTED_MODULES[@]}"; do
    label="$(module_display_name "$module")"
    echo "[INFO] Executando módulo: $label"
    log "==== Executando módulo: $module ===="
    execute_module "$module"
  done
}